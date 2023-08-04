/*
 * integratedStamina.d
 * Source: https://forum.worldofplayers.de/forum/threads/?p=26441848
 *
 * Add stamina regulation to melee fighting integrated into the internal breath (diving) system
 *
 * - Requires Ikarus 1.2.2, LeGo (HookEngine), breath.d
 * - Compatible with Gothic 1 and Gothic 2
 *
 * Instructions
 * - Initialize from Init_Global with
 *     IntegratedStamina_Init();
 * - Set the below variables somewhere from the scripts. This allows to dynamically change the percentage costs. E.g.
 *     IntegratedStamina_FIST_PARADE   = 10;
 *     IntegratedStamina_FIST_FIRSTHIT =  7;
 *     IntegratedStamina_FIST_COMBO    =  4;
 *     IntegratedStamina_2H_PARADE     = 18;
 *     IntegratedStamina_2H_FIRSTHIT   = 10;
 *     IntegratedStamina_2H_COMBO      =  8;
 *     IntegratedStamina_1H_PARADE     = 25;
 *     IntegratedStamina_1H_FIRSTHIT   = 15;
 *     IntegratedStamina_1H_COMBO      = 10;
 *
 *
 * Note: All symbols are prefixed with "Patch_Stamina_" to not interfere with the mod. Remove if using somewhere else!
 */

// In this patch, these symbols are defined elsewhere with different names
// const string IntegratedStamina_Mds = "HUMANS_DISABLE_MELEE.MDS"; // MDS overlay name
// var   int    IntegratedStamina_FIST_PARADE;                      // Breath cost in percent
// var   int    IntegratedStamina_FIST_FIRSTHIT;                    // Breath cost in percent
// var   int    IntegratedStamina_FIST_COMBO;                       // Breath cost in percent
// var   int    IntegratedStamina_2H_PARADE;                        // Breath cost in percent
// var   int    IntegratedStamina_2H_FIRSTHIT;                      // Breath cost in percent
// var   int    IntegratedStamina_2H_COMBO;                         // Breath cost in percent
// var   int    IntegratedStamina_1H_PARADE;                        // Breath cost in percent
// var   int    IntegratedStamina_1H_FIRSTHIT;                      // Breath cost in percent
// var   int    IntegratedStamina_1H_COMBO;                         // Breath cost in percent


// Already defined in integratedSprint.d
/*
 * Check if an MDS overlay of given name is active
 *
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
*/


/*
 * Unfortunately Gothic 1 does not have the option bShowWeaponTrails, skip the entire function call here
 */
func void Patch_Stamina_HideWeaponTrails(var int hide) {
    const int oCAniCtrl_Human__ShowWeaponTrail_G1 = 6452016; //0x627330
    const int oCAniCtrl_Human__ShowWeaponTrail_G2 = 7011952; //0x6AFE70
    var int addr; addr = MEMINT_SwitchG1G2(oCAniCtrl_Human__ShowWeaponTrail_G1, oCAniCtrl_Human__ShowWeaponTrail_G2);
    var int byte; byte = MEM_ReadByte(addr);

    if (hide) {
        if (byte == /*64*/100) {
            MemoryProtectionOverride(addr, 1);
            MEM_WriteByte(addr, /*C3*/195);
        };
    } else if (byte == /*C3*/195) {
        MEM_WriteByte(addr, /*64*/100);
    };
};


/*
 * Decrease stamina on melee fight actions
 */
func void Patch_Stamina_IntegratedStamina() {
    var oCAniCtrl_Human ai; ai = _^(ESI);
    var C_Npc slf; slf = _^(ai.npc);

    // For player only
    if (!Npc_IsPlayer(slf)) {
        return;
    };

    // Collect information about current action
    var oCNpc npc; npc = _^(ai.npc);
    var int fists; fists = (npc.fmode == FMODE_FIST);
    var int twoHanded; twoHanded = (npc.fmode == 4);
    var int start; start = ((ai.bitfield & /*endCombo*/2) != 0);
    var int firstHit; firstHit = (start) && (truncf(ai.lastHitAniFrame) < 6); // Tolerance for non-combo animations
    var int parade; parade = FALSE;
    if (start) {
        ai.hitAniID = EAX;
        if (ai.hitAniID != ai._t_hitl) && (ai.hitAniID != ai._t_hitr)
        && (ai.hitAniID != ai._t_hitf) && (ai.hitAniID != ai._t_hitfrun) {
            parade = TRUE;

            // Return if already running (only the case for long jump back parades)
            const int oCAniCtrl_Human__IsParadeRunning_G1 = 6456432; //0x628470
            const int oCAniCtrl_Human__IsParadeRunning_G2 = 7017808; //0x6B1550
            const int call = 0;
            if (CALL_Begin(call)) {
                CALL__thiscall(_@(ESI), MEMINT_SwitchG1G2(oCAniCtrl_Human__IsParadeRunning_G1,
                                                          oCAniCtrl_Human__IsParadeRunning_G2));
                call = CALL_End();
            };
            if (CALL_RetValAsInt()) {
                return;
            };
        };
    };

    // Determine decrement/cost
    var int decr;
    if (fists) {
        if      (parade)   {  decr = Patch_Stamina_FIST_FIRSTHIT; }
        else if (firstHit) {  decr = Patch_Stamina_FIST_COMBO;    }
        else /*followHit*/ {  decr = Patch_Stamina_FIST_PARADE;   };
    } else if (twoHanded)  {
        if      (parade)   {  decr = Patch_Stamina_1H_FIRSTHIT;   }
        else if (firstHit) {  decr = Patch_Stamina_1H_COMBO;      }
        else /*followHit*/ {  decr = Patch_Stamina_1H_PARADE;     };
    } else   /*oneHanded*/ {
        if      (parade)   {  decr = Patch_Stamina_2H_FIRSTHIT;   }
        else if (firstHit) {  decr = Patch_Stamina_2H_COMBO;      }
        else /*followHit*/ {  decr = Patch_Stamina_2H_PARADE;     };
    };

    // Decrease breath or disable actions by animation
    if (!Breath_RequestPercent(slf, decr, decr)) {
        // End combo or disable melee
        if (!(ai.bitfield & /*endCombo*/2)) {
            ai.bitfield = ai.bitfield | /*endCombo*/2;
        } else if (!Patch_Stamina_Mdl_OverlayMdsIsActive(slf, Patch_Stamina_DisableMDS)) {
            Mdl_ApplyOverlayMds(slf, Patch_Stamina_DisableMDS);
        };

        // Temporarily disable all(!) weapon trails
        Patch_Stamina_HideWeaponTrails(TRUE);

    } else if (Patch_Stamina_Mdl_OverlayMdsIsActive(slf, Patch_Stamina_DisableMDS)) {
        // Back to normal
        Mdl_RemoveOverlayMds(slf, Patch_Stamina_DisableMDS);
        Patch_Stamina_HideWeaponTrails(FALSE);
    };
};


/*
 * Initialization function to be called from Init_Global
 */
func void Patch_Stamina_IntegratedStamina_Init() {
    const int oCAniCtrl_Human__StartHitCombo_G1 = 6452587; //0x62756B
    const int oCAniCtrl_Human__StartHitCombo_G2 = 7012555; //0x6B00CB
    const int oCAniCtrl_Human__HitCombo_next_G1 = 6453169; //0x6277B1
    const int oCAniCtrl_Human__HitCombo_next_G2 = 7013146; //0x6B031A
    HookEngineF(MEMINT_SwitchG1G2(oCAniCtrl_Human__StartHitCombo_G1,
                                  oCAniCtrl_Human__StartHitCombo_G2), 8, Patch_Stamina_IntegratedStamina);
    HookEngineF(MEMINT_SwitchG1G2(oCAniCtrl_Human__HitCombo_next_G1,
                                  oCAniCtrl_Human__HitCombo_next_G2), 8, Patch_Stamina_IntegratedStamina);
};
