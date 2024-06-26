/*
 * Menu initialization function called by Ninja every time a menu is opened
 */
func void Ninja_Stamina_Menu(var int menuPtr) {
    // Only on game start
    const int once = 0;
    if (!once) {
        // Initialize Ikarus
        MEM_InitAll();

        // Version check
        if (NINJA_VERSION < 2915) {
            MEM_SendToSpy(zERR_TYPE_FATAL, "Stamina requires at least Ninja 2.9.15 or higher.");
        };

        // Check if the script features are already present in the mod
        Patch_Stamina_IntegratedSprintExists  = (MEM_FindParserSymbol("IntegratedSprint")  != -1);
        Patch_Stamina_IntegratedStaminaExists = (MEM_FindParserSymbol("IntegratedStamina") != -1);

        // Set non-existing values
        MEM_Info("Stamina: Initializing entries in Gothic.ini.");
        if (!MEM_GothOptExists("STAMINA", "sprintTotalSec"  )) { MEM_SetGothOpt("STAMINA", "sprintTotalSec",   "15"); };
        if (!MEM_GothOptExists("STAMINA", "supplySprintAni" )) { MEM_SetGothOpt("STAMINA", "supplySprintAni",   "1"); };
        if (!MEM_GothOptExists("STAMINA", "fistFirstHitCost")) { MEM_SetGothOpt("STAMINA", "fistFirstHitCost", "10"); };
        if (!MEM_GothOptExists("STAMINA", "fistComboCost"   )) { MEM_SetGothOpt("STAMINA", "fistComboCost",     "7"); };
        if (!MEM_GothOptExists("STAMINA", "fistParadeCost"  )) { MEM_SetGothOpt("STAMINA", "fistParadeCost",    "4"); };
        if (!MEM_GothOptExists("STAMINA", "1hFirstHitCost"  )) { MEM_SetGothOpt("STAMINA", "1hFirstHitCost",   "18"); };
        if (!MEM_GothOptExists("STAMINA", "1hComboCost"     )) { MEM_SetGothOpt("STAMINA", "1hComboCost",      "10"); };
        if (!MEM_GothOptExists("STAMINA", "1hParadeCost"    )) { MEM_SetGothOpt("STAMINA", "1hParadeCost",      "8"); };
        if (!MEM_GothOptExists("STAMINA", "2hFirstHitCost"  )) { MEM_SetGothOpt("STAMINA", "2hFirstHitCost",   "25"); };
        if (!MEM_GothOptExists("STAMINA", "2hComboCost"     )) { MEM_SetGothOpt("STAMINA", "2hComboCost",      "15"); };
        if (!MEM_GothOptExists("STAMINA", "2hParadeCost"    )) { MEM_SetGothOpt("STAMINA", "2hParadeCost",     "10"); };

        // Read values
        Patch_Stamina_SPRINTTIME    = STR_ToInt(MEM_GetGothOpt("STAMINA", "sprintTotalSec"  )) * 1000;
        Patch_Stamina_FIST_FIRSTHIT = STR_ToInt(MEM_GetGothOpt("STAMINA", "fistFirstHitCost"));
        Patch_Stamina_FIST_COMBO    = STR_ToInt(MEM_GetGothOpt("STAMINA", "fistComboCost"   ));
        Patch_Stamina_FIST_PARADE   = STR_ToInt(MEM_GetGothOpt("STAMINA", "fistParadeCost"  ));
        Patch_Stamina_1H_FIRSTHIT   = STR_ToInt(MEM_GetGothOpt("STAMINA", "1hFirstHitCost"  ));
        Patch_Stamina_1H_COMBO      = STR_ToInt(MEM_GetGothOpt("STAMINA", "1hComboCost"     ));
        Patch_Stamina_1H_PARADE     = STR_ToInt(MEM_GetGothOpt("STAMINA", "1hParadeCost"    ));
        Patch_Stamina_2H_FIRSTHIT   = STR_ToInt(MEM_GetGothOpt("STAMINA", "2hFirstHitCost"  ));
        Patch_Stamina_2H_COMBO      = STR_ToInt(MEM_GetGothOpt("STAMINA", "2hComboCost"     ));
        Patch_Stamina_2H_PARADE     = STR_ToInt(MEM_GetGothOpt("STAMINA", "2hParadeCost"    ));
        if (!STR_ToInt(MEM_GetGothOpt("STAMINA", "supplySprintAni" ))) {
            Patch_Stamina_SprintMDS = "HUMANS_SPRINT.MDS";
        };

        // Set integrated sprint keys if desired only
        if (Patch_Stamina_SPRINTTIME > 0) && (!Patch_Stamina_IntegratedSprintExists) {
            if (!MEM_GothOptExists("KEYS", "keyIntSprint")) { MEM_SetKeys("keyIntSprint", KEY_V, KEY_PERIOD); };
        };

        // Set MDS overlay according to Gothic version
        if (GOTHIC_BASE_VERSION == 1) || (GOTHIC_BASE_VERSION == 112) {
            Patch_Stamina_DisableMDS = Patch_Stamina_DisableMDS_G1;
        } else {
            Patch_Stamina_DisableMDS = Patch_Stamina_DisableMDS_G2;
        };

        once = 1;
    };

    // Add key menu entry if the desired only
    if (Patch_Stamina_SPRINTTIME > 0) && (!Patch_Stamina_IntegratedSprintExists) {
        Patch_Stamina_AddKeyMenuEntry(menuPtr);
    };
};


/*
 * Initialization function called by Ninja after "Init_Global" (G2) / "Init_<Levelname>" (G1)
 */
func void Ninja_Stamina_Init() {
    // Initialize Ikarus
    MEM_InitAll();

    // Integrate sprint if desired only. And only if not already present in the mod
    if (Patch_Stamina_SPRINTTIME > 0) && (!Patch_Stamina_IntegratedSprintExists) {
        // Wrapper for "LeGo_Init" to ensure correct LeGo initialization without breaking the mod
        LeGo_MergeFlags(LeGo_FrameFunctions);
        Patch_Stamina_IntegratedSprint_Init();
    };

    // Integrate fight stamina if desired only. And only if not already present in the mod
    if (!Patch_Stamina_IntegratedStaminaExists) {
        if (Patch_Stamina_FIST_FIRSTHIT) || (Patch_Stamina_FIST_COMBO) || (Patch_Stamina_FIST_PARADE)
        || (Patch_Stamina_2H_FIRSTHIT)   || (Patch_Stamina_2H_COMBO)   || (Patch_Stamina_2H_PARADE)
        || (Patch_Stamina_1H_FIRSTHIT)   || (Patch_Stamina_1H_COMBO)   || (Patch_Stamina_1H_PARADE) {
            Patch_Stamina_IntegratedStamina_Init();
        };
    };

    // Initialize breath scripts only if either of the above is active
    if  (!Patch_Stamina_IntegratedStaminaExists)
    || ((!Patch_Stamina_IntegratedSprintExists) && (Patch_Stamina_SPRINTTIME > 0)) {
        Breath_Init();
    };
};
