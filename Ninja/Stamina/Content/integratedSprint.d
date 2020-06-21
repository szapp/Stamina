/*
 * integratedSprint.d
 * Source: https://forum.worldofplayers.de/forum/threads/?p=26441848
 *
 * Add sprint integrated into the internal breath (diving) system
 *
 * - Requires Ikarus 1.2.2, LeGo 2.6.0 (FrameFunctions), breath.d
 * - Compatible with Gothic 1 and Gothic 2
 *
 * Instructions
 * - Initialize from Init_Global with
 *     IntegratedSprint_Init();
 * - Set the variable IntegratedSprint_DurationMS from the scripts. This allows to dynamically change the duration. E.g.
 *     IntegratedSprint_DurationMS = 15000; // 15 seconds of total sprint
 *
 *
 * Note: All symbols are prefixed with "Ninja_Stamina_" to not interfere with the mod. Remove if using somewhere else!
 */

// In this patch, these symbols are defined elsewhere with different names
// const string IntegratedSprint_Mds = "HUMANS_SPRINT_CLEAN.MDS"; // MDS overlay name
// var   int    IntegratedSprint_DurationMS;                      // Duration of sprint in milliseconds: Set in scripts

/*
 * Check if an MDS overlay of given name is active
 */
func int Ninja_Stamina_Mdl_OverlayMdsIsActive(var C_Npc slf, var string mdsName) {
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
func int Ninja_Stamina_Npc_IsRunning(var C_Npc slf) {
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    var int aiPtr; aiPtr = npc.human_ai;

    if (GOTHIC_BASE_VERSION == 2) {
        const int oCAniCtrl_Human__IsRunning = 7004672; //0x6AE200

        const int call = 0;
        if (CALL_Begin(call)) {
            CALL_PutRetValTo(_@(ret));
            CALL__thiscall(_@(aiPtr), oCAniCtrl_Human__IsRunning);
            call = CALL_End();
        };

        var int ret;
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
func void Ninja_Stamina_IntegratedSprint() {
    const int THRESHOLD_MS     = 1161527296; // 3000.0f
    const int ACTION_WATERWALK = 4;          // oCAniCtrl_Human.actionMode

    var oCNpc her; her = Hlp_GetNpc(hero);
    var oCAniCtrl_Human ai; ai = _^(her.human_ai);

    // Calculate cost per this frame (dynamically, because frame length varies and divetime might be updated)
    var int factor; factor = divf(her.divetime, mkf(Ninja_Stamina_SPRINTTIME));
    var int cost; cost = mulf(MEM_Timer.frameTimeFloat, factor);

    if ((MEM_KeyPressed(MEM_GetKey("keyIntSprint"))) || (MEM_KeyPressed(MEM_GetSecondaryKey("keyIntSprint"))))
    && (Breath_AvailableMsF(hero, cost))
    && (ai.actionMode < ACTION_WATERWALK) {

        // Decrease only while running
        if (Ninja_Stamina_Npc_IsRunning(hero)) {
            Breath_DecreaseMsF(hero, cost);

            // Apply overlay after refractory period
            if (!Ninja_Stamina_Mdl_OverlayMdsIsActive(hero, Ninja_Stamina_SprintMDS))
            && (Breath_AvailableMsF(hero, THRESHOLD_MS)) {
                Mdl_ApplyOverlayMds(her, Ninja_Stamina_SprintMDS);
            };
        };
    } else if (Ninja_Stamina_Mdl_OverlayMdsIsActive(hero, Ninja_Stamina_SprintMDS)) {
        Mdl_RemoveOverlayMds(her, Ninja_Stamina_SprintMDS);
    };
};


/*
 * Initialization function to be called from Init_Global
 */
func void Ninja_Stamina_IntegratedSprint_Init() {
    // Requires LeGo FrameFunctions
    if (_LeGo_Flags & LeGo_FrameFunctions) {
        FF_ApplyOnceExtGT(Ninja_Stamina_IntegratedSprint, 0, -1);
    };
};
