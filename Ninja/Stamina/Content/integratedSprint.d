/*
 * integratedSprint.d
 * Source: https://forum.worldofplayers.de/forum/threads/?p=26441848
 *
 * Add sprint integrated into the internal breath (diving) system
 *
 * - Requires Ikarus 1.2.2, LeGo 2.6.0 (FrameFunctions), breath.d
 * - Compatible with Gothic, Gothic Sequel, Gothic 2, and Gothic 2 NotR
 *
 * Instructions
 * - Initialize from Init_Global with
 *     IntegratedSprint_Init();
 * - Set the variable IntegratedSprint_DurationMS from the scripts. This allows to dynamically change the duration. E.g.
 *     IntegratedSprint_DurationMS = 15000; // 15 seconds of total sprint
 *
 *
 * Note: All symbols are prefixed with "Patch_Stamina_" to not interfere with the mod. Remove if using somewhere else!
 */

// In this patch, these symbols are defined elsewhere with different names
// const string IntegratedSprint_Mds = "HUMANS_SPRINT_CLEAN.MDS"; // MDS overlay name
// var   int    IntegratedSprint_DurationMS;                      // Duration of sprint in milliseconds: Set in scripts

/*
 * Check if an MDS overlay of given name is active
 */
func int Patch_Stamina_Mdl_OverlayMdsIsActive(var C_Npc slf, var string mdsName) {
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    mdsName = STR_Upper(mdsName);

    repeat(i, npc.activeOverlays_numInArray); var int i;
        if (Hlp_StrCmp(mdsName, MEM_ReadStringArray(npc.activeOverlays_array, i))) {
            return TRUE;
        };
    end;

    return FALSE;
};

/*
 * Check if an NPC is running
 */
func int Patch_Stamina_Npc_IsRunning(var C_Npc slf) {
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    var int aiPtr; aiPtr = npc.human_ai;

    if (GOTHIC_BASE_VERSION == 130) || (GOTHIC_BASE_VERSION == 2) {
        const int oCAniCtrl_Human__IsRunning[4] = {0, 0, /*G2*/6625664, /*G2A*/7004672};

        if (CALL_Begin(call)) {
            const int call = 0;
            const int ret = 0;
            CALL_PutRetValTo(_@(ret));
            CALL__thiscall(_@(aiPtr), oCAniCtrl_Human__IsRunning[IDX_EXE]);
            call = CALL_End();
        };

        return +ret;

    } else {
        // Gothic 1 does not have the function oCAniCtrl_Human::IsRunning. Re-implement it here
        // These lines require at lease Ikarus 1.2.2

        var oCAniCtrl_Human ai; ai = _^(aiPtr);
        var int modelPtr; modelPtr = ai._zCAIPlayer_model;

        if (!modelPtr) {
            return FALSE;
        };

        // Modified from auxillary.d in GothicFreeAim
        // https://github.com/szapp/GothicFreeAim/blob/v1.2.0/_work/data/Scripts/Content/GFA/_intern/auxiliary.d#L169
        const int zCModel_numActAnis_offset = 52; //0x34
        const int zCModel_actAniList_offset = 56; //0x37
        const int zCModelAni_aniID_offset   = 76; //0x4C
        var int actAniOffset; actAniOffset = modelPtr+zCModel_actAniList_offset;
        repeat(i, MEM_ReadInt(modelPtr+zCModel_numActAnis_offset)); var int i;
            var int aniID; aniID = MEM_ReadInt(MEM_ReadInt(MEM_ReadInt(actAniOffset))+zCModelAni_aniID_offset);
            if (aniID == MEM_ReadStatArr(ai.s_runl,        npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.s_runr,        npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_run_2_runl,  npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_runl_2_run,  npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_runl_2_runr, npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_runr_2_runl, npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_runr_2_run,  npc.fmode)) {
                return TRUE;
            };
            actAniOffset += 4;
        end;
    };
    return FALSE;
};

/*
 * Breath based sprinting. This function has to be called every single frame
 */
func void Patch_Stamina_IntegratedSprint() {
    const int THRESHOLD_MS             = 1161527296; // 3000.0f
    const int ACTION_WATERWALK         = 4;          // oCAniCtrl_Human.actionMode
    const int oCNpc__SetWeaponMode2[4] = {/*G1*/6904416, /*G1A*/7107152, /*G2*/7185696, /*G2A*/7573120};

    var oCNpc her; her = Hlp_GetNpc(hero);
    var oCAniCtrl_Human ai; ai = _^(her.human_ai);

    // Calculate cost per this frame (dynamically, because frame length varies and divetime might be updated)
    var int factor; factor = divf(her.divetime, mkf(Patch_Stamina_SPRINTTIME));
    var int cost; cost = mulf(MEM_Timer.frameTimeFloat, factor);

    if ((MEM_KeyPressed(MEM_GetKey("keyIntSprint"))) || (MEM_KeyPressed(MEM_GetSecondaryKey("keyIntSprint"))))
    && (Breath_AvailableMsF(hero, cost))
    && (ai.actionMode < ACTION_WATERWALK) {

        // Decrease only while running
        if (Patch_Stamina_Npc_IsRunning(hero)) {
            Breath_DecreaseMsF(hero, cost);

            // Apply overlay after refractory period
            if (!Patch_Stamina_Mdl_OverlayMdsIsActive(hero, Patch_Stamina_SprintMDS))
            && (Breath_AvailableMsF(hero, THRESHOLD_MS)) {
                Mdl_ApplyOverlayMds(her, Patch_Stamina_SprintMDS);
            };
        };
    } else if (Patch_Stamina_Mdl_OverlayMdsIsActive(hero, Patch_Stamina_SprintMDS)) {
        // Check if mid-air, copied from GothicFreeAim <http://github.com/szapp/GothicFreeAim>
        if (lf(ai._zCAIPlayer_aboveFloor, mkf(50))) {
            Mdl_RemoveOverlayMds(her, Patch_Stamina_SprintMDS);

            // Fix ranged combat by re-initializing weapon mode
            if (Npc_HasReadiedRangedWeapon(hero)) {
                var int herPtr; herPtr = _@(her);
                var int fmode; fmode = her.fmode;
                if (CALL_Begin(call)) {
                    const int call = 0;
                    CALL_IntParam(_@(FALSE));
                    CALL__thiscall(_@(herPtr), oCNpc__SetWeaponMode2[IDX_EXE]);
                    CALL_IntParam(_@(fmode));
                    CALL__thiscall(_@(herPtr), oCNpc__SetWeaponMode2[IDX_EXE]);
                    call = CALL_End();
                };
            };
        };
    };
};


/*
 * Initialization function to be called from Init_Global
 */
func void Patch_Stamina_IntegratedSprint_Init() {
    // Requires LeGo FrameFunctions
    if (_LeGo_Flags & LeGo_FrameFunctions) {
        FF_ApplyOnceExtGT(Patch_Stamina_IntegratedSprint, 0, -1);
    };
};
