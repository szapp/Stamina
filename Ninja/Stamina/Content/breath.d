/*
 * breath.d
 * Source: https://forum.worldofplayers.de/forum/threads/?p=26441844
 *
 * Collection of functions that expose the swim bar for generalized use (e.g. stamina, breath).
 *
 * - Requires Ikarus 1.2.2
 * - Compatible with Gothic 1 and Gothic 2
 *
 * Instructions
 * - Initialize from Init_Global with these two lines
 *     Breath_Init();
 *     Breath_SetBarVisibleNonEmpty();   - OR -   Breath_SetBarVisibleAlways();
 *
 *
 * Initialize the regeneration and bar visibility (call from Init_Global)
 *  func void Breath_Init()
 *
 * Set visibility of swim bar (to be called optionally AFTER Breath_Init)
 *  func void Breath_SetBarVisibleAlways()
 *  func void Breath_SetBarVisibleNonEmpty()
 *
 * Get/set maximum breath, load/save-persistent for player only. Default is 30000 ms (30 sec)
 *  func intf Breath_TotalF   (C_Npc slf)
 *  func int  Breath_Total    (C_Npc slf)
 *  func void Breath_SetTotalF(C_Npc slf, intf ms)
 *  func void Breath_SetTotal (C_Npc slf, int  ms)
 *
 * Get remaining breath
 *  func intf Breath_RemainingMsF     (C_Npc slf)
 *  func int  Breath_RemainingMs      (C_Npc slf)
 *  func int  Breath_RemainingPercent (C_Npc slf)
 *  func int  Breath_RemainingPermille(C_Npc slf)
 *
 * Check if enough breath is available
 *  func bool Breath_AvailableMsF     (C_Npc slf, intf ms)
 *  func bool Breath_AvailableMs      (C_Npc slf, int  ms)
 *  func bool Breath_AvailablePercent (C_Npc slf, int  percent)
 *  func bool Breath_AvailablePermille(C_Npc slf, int  permille)
 *
 * Set remaining breath
 *  func void Breath_SetMsF     (C_Npc slf, intf ms)
 *  func void Breath_SetMs      (C_Npc slf, int  ms)
 *  func void Breath_SetPercent (C_Npc slf, int  percent)
 *  func void Breath_SetPermille(C_Npc slf, int  permille)
 *
 * Decrease breath
 *  func void Breath_DecreaseMsF     (C_Npc slf, intf ms)
 *  func void Breath_DecreaseMs      (C_Npc slf, int  ms)
 *  func void Breath_DecreasePercent (C_Npc slf, int  percent)
 *  func void Breath_DecreasePermille(C_Npc slf, int  permille)
 *
 * Decrease breath if available, return TRUE if successful
 *  func bool Breath_RequestMsF     (C_Npc slf, intf ms,       intf required)
 *  func bool Breath_RequestMs      (C_Npc slf, int  ms,       int  required)
 *  func bool Breath_RequestPercent (C_Npc slf, int  percent,  int  required)
 *  func bool Breath_RequestPermille(C_Npc slf, int  permille, int  required)
 *
 * Set the regeneration: how many ms of breath are recovered within one sec. Default is 2000 ms
 *  func void Breath_SetRegeneration(int  ms)
 */

/* Internal constants/variables */
const int _Breath_DontRegen = 0;
var   int _Breath_player_max;
var   int _Breath_RegenFactor;

/*
 * Obtain the corresponding number of milliseconds for a fraction of the total breath
 */
func int Breath_ToMs(var C_Npc slf, var int amount, var int frac) {
    if (frac <= 1) { return amount; };
    if (!Hlp_IsValidNpc(slf)) { return FLOATNULL; };
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    var int unit; unit = divf(npc.divetime, mkf(frac));
    return mulf(amount, unit);
};

/*
 * Obtain the corresponding fraction of the total breath for a number of milliseconds
 */
func int Breath_FromMs(var C_Npc slf, var int ms, var int frac) {
    if (frac <= 1) { return ms; };
    if (!Hlp_IsValidNpc(slf)) { return FLOATNULL; };
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    var int unit; unit = divf(mkf(frac), npc.divetime);
    return mulf(ms, unit);
};

/*
 * Return the total breath in milliseconds (integer float)
 */
func int Breath_TotalF(var C_Npc slf) {
    if (!Hlp_IsValidNpc(slf)) { return FLOATNULL; };
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    return npc.divetime;
};
func int Breath_Total(var C_Npc slf) {
    return roundf(Breath_TotalF(slf));
};

/*
 * Set the total breath in milliseconds (integer float)
 * The remaining breath value is not altered and remains as before
 */
func void Breath_SetTotalF(var C_Npc slf, var int ms) {
    if (!Hlp_IsValidNpc(slf)) { return; };
    var oCNpc npc; npc = Hlp_GetNpc(slf);

    // If negative, decrease current total
    if (lf(ms, FLOATNULL)) {
        ms = addf(npc.divetime, ms);
        if (lf(ms, FLOATNULL)) {
            ms = FLOATNULL;
        };
    };

    npc.divetime = ms;

    // Save for loading/level change
    if (Npc_IsPlayer(slf)) {
        _Breath_player_max = npc.divetime;
    };
};
func void Breath_SetTotal(var C_Npc slf, var int ms) {
    Breath_SetTotalF(slf, mkf(ms));
};

/*
 * Return the remaining breath in milliseconds or fraction (integer float)
 */
func int Breath_Remaining(var C_Npc slf, var int frac) {
    if (!Hlp_IsValidNpc(slf)) { return FLOATNULL; };
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    return Breath_FromMs(slf, npc.divectr, frac);
};
func int Breath_RemainingMsF(var C_Npc slf) {
    return Breath_Remaining(slf, 1);
};
func int Breath_RemainingMs(var C_Npc slf) {
    return roundf(Breath_Remaining(slf, 1));
};
func int Breath_RemainingPercent(var C_Npc slf) {
    return roundf(Breath_Remaining(slf, 100));
};
func int Breath_RemainingPermille(var C_Npc slf) {
    return roundf(Breath_Remaining(slf, 1000));
};

/*
 * Check if enough breath (milliseconds or fraction) is available
 */
func int Breath_Available(var C_Npc slf, var int amount, var int frac) {
    var int ms; ms = Breath_ToMs(slf, amount, frac);
    var int avail; avail = Breath_Remaining(slf, 1);
    return gef(avail, ms);
};
func int Breath_AvailableMsF(var C_Npc slf, var int ms) {
    return Breath_Available(slf, ms, 1);
};
func int Breath_AvailableMs(var C_Npc slf, var int ms) {
    return Breath_Available(slf, mkf(ms), 1);
};
func int Breath_AvailablePercent(var C_Npc slf, var int percent) {
    return Breath_Available(slf, mkf(percent), 100);
};
func int Breath_AvailablePermille(var C_Npc slf, var int permille) {
    return Breath_Available(slf, mkf(permille), 1000);
};

/*
 * Set the remaining breath in milliseconds or fraction (integer float)
 */
func void Breath_Set(var C_Npc slf, var int amount, var int frac) {
    if (!Hlp_IsValidNpc(slf)) { return; };
    var int ms; ms = Breath_ToMs(slf, amount, frac);
    var oCNpc npc; npc = Hlp_GetNpc(slf);

    // If negative, decrease current remaining
    if (lf(ms, FLOATNULL)) {
        ms = addf(npc.divectr, ms);
        if (lf(ms, FLOATNULL)) {
            ms = FLOATNULL;
        };
    } else if (gf(ms, npc.divetime)) {
        ms = npc.divetime;
    };

    npc.divectr = ms;

    // Do not regenerate for this frame
    if (!_Breath_DontRegen) { _Breath_DontRegen = MEM_ArrayCreate(); };
    MEM_ArrayInsert(_Breath_DontRegen, _@(npc));
};
func void Breath_SetMsF(var C_Npc slf, var int ms) {
    Breath_Set(slf, ms, 1);
};
func void Breath_SetMs(var C_Npc slf, var int ms) {
    Breath_Set(slf, mkf(ms), 1);
};
func void Breath_SetPercent(var C_Npc slf, var int percent) {
    Breath_Set(slf, mkf(percent), 100);
};
func void Breath_SetPermille(var C_Npc slf, var int permille) {
    Breath_Set(slf, mkf(permille), 1000);
};

/*
 * Decrease the breath (by milliseconds or fraction)
 */
func void Breath_Decrease(var C_Npc slf, var int amount, var int frac) {
    var int ms; ms = Breath_ToMs(slf, amount, frac);
    Breath_Set(slf, negf(ms), 1);
};
func void Breath_DecreaseMsF(var C_Npc slf, var int ms) {
    Breath_Decrease(slf, ms, 1);
};
func void Breath_DecreaseMs(var C_Npc slf, var int ms) {
    Breath_Decrease(slf, mkf(ms), 1);
};
func void Breath_DecreasePercent(var C_Npc slf, var int percent) {
    Breath_Decrease(slf, mkf(percent), 100);
};
func void Breath_DecreasePermille(var C_Npc slf, var int permille) {
    Breath_Decrease(slf, mkf(permille), 1000);
};

/*
 * Decrease the breath (by milliseconds or fraction) only if a required minimum is available
 */
func int Breath_Request(var C_Npc slf, var int amount, var int required, var int frac) {
    if (Breath_Available(slf, required, frac)) {
        Breath_Decrease(slf, amount, frac);
        return TRUE;
    } else {
        return FALSE;
    };
};
func int Breath_RequestMsF(var C_Npc slf, var int ms, var int required) {
    return Breath_Request(slf, ms, required, 1);
};
func int Breath_RequestMs(var C_Npc slf, var int ms, var int required) {
    return Breath_Request(slf, mkf(ms), mkf(required), 1);
};
func int Breath_RequestPercent(var C_Npc slf, var int percent, var int required) {
    return Breath_Request(slf, mkf(percent), mkf(required), 100);
};
func int Breath_RequestPermille(var C_Npc slf, var int permille, var int required) {
    return Breath_Request(slf, mkf(permille), mkf(required), 1000);
};

/*
 * Set how many milliseconds it takes to regenerate one second of breath (for all NPC). Default is 2000 ms per second
 */
func void Breath_SetRegeneration(var int ms) {
    _Breath_RegenFactor = fracf(ms, 1000);
};

/*
 * Change the visibility of the swim bar
 */
func void Breath_SetBarVisible(var int always) {
    const int oCGame__UpdatePlayerStatus_swimBarJmp1_G1 = 6525142; //0x6390D6
    const int oCGame__UpdatePlayerStatus_swimBarJmp1_G2 = 7090988; //0x6C332C
    const int oCGame__UpdatePlayerStatus_swimBarJmp2_G1 = 6525154; //0x6390E2
    const int oCGame__UpdatePlayerStatus_swimBarJmp2_G2 = 7091000; //0x6C3338
    var int addr1; var int addr2;
    addr1 = MEMINT_SwitchG1G2(oCGame__UpdatePlayerStatus_swimBarJmp1_G1, oCGame__UpdatePlayerStatus_swimBarJmp1_G2);
    addr2 = MEMINT_SwitchG1G2(oCGame__UpdatePlayerStatus_swimBarJmp2_G1, oCGame__UpdatePlayerStatus_swimBarJmp2_G2);

    const int once = 0;
    if (!once) {
        MemoryProtectionOverride(addr1,  2);
        MemoryProtectionOverride(addr2, 14);
        once = 1;
    };

    if (always) {
        // Overwrite first conditional jump to unconditional jump
        if (MEM_ReadByte( addr1) ==  /*0F*/ 15) {
            MEM_WriteByte(addr1,     /*EB*/235);                     // jmp
            MEM_WriteByte(addr1+1,   /*1C*/ 28);                     // 0x28
        };
    } else {
        // Revert the above change
        if (MEM_ReadInt(  addr1) ==  /*EB 1C A4 00*/10755307) {      // Compare 4 bytes, because of third-party changes
            MEM_WriteByte(addr1,     /*0F*/ 15);                     // jz
            MEM_WriteByte(addr1+1,   /*84*/132);
        };
        // Overwrite second condition to be true if breath is non-full
        if (MEM_ReadByte( addr2) ==  /*E8*/232) {
            MEM_WriteByte(addr2,     /*8B*/139);                     // mov
            MEM_WriteByte(addr2+1,   /*81*/129);                     // eax,
            MEM_WriteInt( addr2+2,   MEMINT_SwitchG1G2(2064, 2000)); // [offset oCNpc.divetime]
            MEM_WriteByte(addr2+6,   /*3B*/ 59);                     // cmp
            MEM_WriteByte(addr2+7,   /*81*/129);                     // eax,
            MEM_WriteInt( addr2+8,   MEMINT_SwitchG1G2(2068, 2004)); // [offset oCNpc.divectr]
            MEM_WriteByte(addr2+12,  /*0F*/ 15);                     // jz
            MEM_WriteByte(addr2+13,  /*84*/132);
        };
    };
};
func void Breath_SetBarVisibleAlways() {
    Breath_SetBarVisible(TRUE);
};
func void Breath_SetBarVisibleNonEmpty() {
    Breath_SetBarVisible(FALSE);
};


/*
This is the Daedalus-based (very slow) equivalent to the assembly-based initialization below.
It's kept here for better understanding of the purpose and method.

/*
 * Internal hook for regenerating breath
 *
var int _Breath_player;
func void _Breath_RegenHook() {
    var oCNpc npc; npc = _^(ESI);
    if (Npc_IsPlayer(npc)) {
        _Breath_player = npc.divectr;
    };

    var int factor; factor = _Breath_RegenFactor;
    if (_Breath_DontRegen) {
        var int i; i = MEM_ArrayIndexOf(_Breath_DontRegen, ESI);
        if (i != -1) {
            factor = 0;
            MEM_ArrayRemoveIndex(_Breath_DontRegen, i);
        };
    };

    // Additive term to divectr
    var int incr; incr = mulf(MEM_Timer.frameTimeFloat, factor);
    EAX = _@(incr);
};

/*
 * Modify the breath regeneration
 *
func void Breath_Init_slow() {
    const int oCNpc_Process_diveRegen_G1 = 6926517; //0x69B0B5
    const int oCNpc_Process_diveRegen_G2 = 7595752; //0x73E6E8
    var int address; address = MEMINT_SwitchG1G2(oCNpc_Process_diveRegen_G1, oCNpc_Process_diveRegen_G2);

    // Only perform changes if bytes are not already modified
    if (MEM_ReadInt(address + 2) == _@(MEM_Timer.frameTimeFloat)) {
        const int ASMINT_OP_floatLoadFromEAX = 217; //0x00D9
        MemoryProtectionOverride(address, 8);
        MEM_WriteInt(address,     ASMINT_OP_nop + (ASMINT_OP_nop<<8) + (ASMINT_OP_nop<<16) + (ASMINT_OP_nop<<24));
        MEM_WriteInt(address + 4, ASMINT_OP_nop + (ASMINT_OP_nop<<8) + (ASMINT_OP_floatLoadFromEAX<<16));
        HookEngineF(address, 5, _Breath_RegenHook);
    };

    // Reset regenerate list
    if (_Breath_DontRegen) {
        MEM_ArrayClear(_Breath_DontRegen);
    };

    // Set default regeneration first time: regenerate 2 seconds of breath every second
    var int oncePerSave;
    if (!oncePerSave) {
        Breath_SetRegeneration(2000);
        _Breath_player     = mkf(30000); // NPC defaults
        _Breath_player_max = mkf(30000); // NPC defaults
        oncePerSave = TRUE;
    } else if (Hlp_IsValidNpc(hero)) {
        // Hero only exists at this point if a game is being loaded or the world is changed: exactly what we want
        var oCNpc her; her = Hlp_GetNpc(hero);
        if (her.divetime == mkf(30000)) {
            // Double check, in case it was changed elsewhere already (e.g. Init_Global)
            her.divetime = _Breath_player_max;
        };
        her.divectr  = _Breath_player;
    };

    // Set the swim bar to visible when non-empty
    Breath_SetBarVisibleNonEmpty();
};*/


/*
 * Modify the breath regeneration
 * Written in assembly for performance, because it is executed every frame for all NPC with non-full breath
 */
func void Breath_Init() {
    const int oCNpc_Process_diveRegen_G1 = 6926517; //0x69B0B5
    const int oCNpc_Process_diveRegen_G2 = 7595752; //0x73E6E8
    var int address; address = MEMINT_SwitchG1G2(oCNpc_Process_diveRegen_G1, oCNpc_Process_diveRegen_G2);
    var int _Breath_player;

    // Only perform the following changes if the bytes are not already modified
    if (MEM_ReadInt(address + 2) == _@(MEM_Timer.frameTimeFloat)) {

        // Assembly instructions
        const int ASMINT_OP_pushESI          =    86; //0x56
        const int ASMINT_OP_jzShort          =   116; //0x74
        const int ASMINT_OP_jnzShort         =   117; //0x75
        // 2 bytes
        const int ASMINT_OP_testECXtoECX     = 51589; //0xC985
        const int ASMINT_OP_testEAXtoEAX     = 49285; //0xC085
        const int ASMINT_OP_floatLoadFromMem =  1497; //0x05D9
        const int ASMINT_OP_subSTfromST      = 57560; //0xE0D8
        const int ASMINT_OP_mulST0byST1pop   = 51678; //0xC9DE
        const int ASMINT_OP_cmpESItoMem      = 13627; //0x353B
        const int ASMINT_OP_movECXtoMem      =  3465; //0x0D89
        const int ASMINT_OP_movESIplusToECX  = 36491; //0x8E8B

        // Re-write regeneration (assembly for performance: called every frame for all NPC!)
        var int oCNpc_divectr_offset;
        var int oCNpc_player;
        var int zCArray_zCVob__IsInList;
        var int zCArray_zCVob__Remove;
        oCNpc_divectr_offset    = MEMINT_SwitchG1G2(2068, 2004);
        oCNpc_player            = MEMINT_SwitchG1G2(/*0x8DBBB0*/9288624, /*0xAB2684*/11216516);
        zCArray_zCVob__IsInList = MEMINT_SwitchG1G2(/*0x648EB0*/6590128, /*0x6D3D80*/ 7159168);
        zCArray_zCVob__Remove   = MEMINT_SwitchG1G2(/*0x648E60*/6590048, /*0x6D3D30*/ 7159088);

        ASM_Open(83);
        MemoryProtectionOverride(address, 8);
        MEM_WriteByte(address,     ASMINT_OP_jmp);
        MEM_WriteInt (address + 1, ASM_Here() - address - 5);

        // Save breath value of player
        ASM_2(ASMINT_OP_cmpESItoMem);      ASM_4(oCNpc_player);
        ASM_1(ASMINT_OP_jnzShort);         ASM_1(12);
        ASM_2(ASMINT_OP_movESIplusToECX);  ASM_4(oCNpc_divectr_offset);
        ASM_2(ASMINT_OP_movECXtoMem);      ASM_4(_@(_Breath_player));

        // Load regeneration factors
        ASM_2(ASMINT_OP_floatLoadFromMem); ASM_4(_@(MEM_Timer.frameTimeFloat));
        ASM_2(ASMINT_OP_floatLoadFromMem); ASM_4(_@(_Breath_RegenFactor));

        // Check if array exists
        ASM_2(ASMINT_OP_movMemToECX);      ASM_4(_@(_Breath_DontRegen));
        ASM_2(ASMINT_OP_testECXtoECX);
        ASM_1(ASMINT_OP_jzShort);          ASM_1(14+18);

        // Check if NPC is in array
        ASM_1(ASMINT_OP_pushESI);
        ASM_2(ASMINT_OP_movESPtoEAX);
        ASM_1(ASMINT_OP_pushEAX);
        ASM_1(ASMINT_OP_call);             ASM_4(zCArray_zCVob__IsInList - (ASM_Here()+4));
        ASM_1(ASMINT_OP_popECX);
        ASM_2(ASMINT_OP_testEAXtoEAX);
        ASM_1(ASMINT_OP_jzShort);          ASM_1(18);

        // Set one factor to zero
        ASM_2(ASMINT_OP_subSTfromST);
        ASM_1(ASMINT_OP_pushESI);
        ASM_2(ASMINT_OP_movESPtoEAX);
        ASM_1(ASMINT_OP_pushEAX);
        ASM_2(ASMINT_OP_movMemToECX);      ASM_4(_@(_Breath_DontRegen));
        ASM_1(ASMINT_OP_call);             ASM_4(zCArray_zCVob__Remove - (ASM_Here()+4));
        ASM_1(ASMINT_OP_popECX);

        // Multiply regeneration factors
        ASM_2(ASMINT_OP_mulST0byST1pop);
        ASM_1(ASMINT_OP_pushIm);           ASM_4(address+8);
        ASM_1(ASMINT_OP_retn);
        var int i; i = ASM_Close();
    };

    // Reset regenerate list
    if (_Breath_DontRegen) {
        MEM_ArrayClear(_Breath_DontRegen);
    };

    // Set default regeneration first time: regenerate 2 seconds of breath every second
    var int oncePerSave;
    if (!oncePerSave) {
        Breath_SetRegeneration(2000);
        _Breath_player     = mkf(30000); // NPC defaults
        _Breath_player_max = mkf(30000); // NPC defaults
        oncePerSave = TRUE;
    } else if (Hlp_IsValidNpc(hero)) {
        // Restore breath values for player
        // Hero only exists at this point if a game is being loaded or the world is changed: exactly what we want
        var oCNpc her; her = Hlp_GetNpc(hero);
        if (her.divetime == mkf(30000)) {
            // Double check, in case it was changed elsewhere already (e.g. Init_Global)
            her.divetime = _Breath_player_max;
        };
        her.divectr  = _Breath_player;
    };

    // Set the swim bar to visible when non-empty
    Breath_SetBarVisibleNonEmpty();
};
