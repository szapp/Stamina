// English
INSTANCE MENUITEM_KEY_EN_PATCH_STAMINA(C_MENU_ITEM_DEF)
{
    text[0]             	= "Sprint";
    text[1]             	= "Press DEL to remove and ENTER to define a key.";

    onSelAction[0]      	= /*SEL_ACTION_EXECCOMMANDS*/ 7;
    onSelAction_S[0]    	= "RUN MENUITEM_INP_EN_PATCH_STAMINA";
};

INSTANCE MENUITEM_INP_EN_PATCH_STAMINA(C_MENU_ITEM_DEF)
{
    type       	 			= /*MENU_ITEM_INPUT*/ 3;
    text[1]     			= "Press the desired key.";

    onChgSetOption          = "keyIntSprint";
    onChgSetOptionSection   = "KEYS";
    flags                   = flags & ~/*IT_SELECTABLE*/ 4;
};


// German
INSTANCE MENUITEM_KEY_DE_PATCH_STAMINA(C_MENU_ITEM_DEF)
{
    text[0]             	= "Sprinten";
    text[1]             	= "Taste ENTF zum Löschen und RETURN zum definieren";

    onSelAction[0]      	= /*SEL_ACTION_EXECCOMMANDS*/ 7;
    onSelAction_S[0]    	= "RUN MENUITEM_INP_DE_PATCH_STAMINA";
};

INSTANCE MENUITEM_INP_DE_PATCH_STAMINA(C_MENU_ITEM_DEF)
{
    type        			= /*MENU_ITEM_INPUT*/ 3;
    text[1]     			= "Gewünschte Taste betätigen.";

    onChgSetOption          = "keyIntSprint";
    onChgSetOptionSection   = "KEYS";
    flags                   = flags & ~/*IT_SELECTABLE*/ 4;
};


// Polish
INSTANCE MENUITEM_KEY_PL_PATCH_STAMINA(C_MENU_ITEM_DEF)
{
    text[0]                 = "Sprint";
    text[1]                 = "DEL - usuwa, ENTER - przypisuje klawisz.";

    onSelAction[0]          = /*SEL_ACTION_EXECCOMMANDS*/ 7;
    onSelAction_S[0]        = "RUN MENUITEM_INP_PL_PATCH_STAMINA";
};

INSTANCE MENUITEM_INP_PL_PATCH_STAMINA(C_MENU_ITEM_DEF)
{
    type                    = /*MENU_ITEM_INPUT*/ 3;
    text[1]                 = "Naci¶nij ¿±dany klawisz.";

    onChgSetOption          = "keyIntSprint";
    onChgSetOptionSection   = "KEYS";
    flags                   = flags & ~/*IT_SELECTABLE*/ 4;
};


// Russian
INSTANCE MENUITEM_KEY_RU_PATCH_STAMINA(C_MENU_ITEM_DEF)
{
    text[0]                 = "ñïðèíò";
    text[1]                 = "íàæìèòå DEL, ÷òîáû î÷èñòèòü ñëîò èëè ENTER, ÷òîáû ïåðåîïðåäåëèòü";

    onSelAction[0]          = /*SEL_ACTION_EXECCOMMANDS*/ 7;
    onSelAction_S[0]        = "RUN MENUITEM_INP_RU_PATCH_STAMINA";
};

INSTANCE MENUITEM_INP_RU_PATCH_STAMINA(C_MENU_ITEM_DEF)
{
    type                    = /*MENU_ITEM_INPUT*/ 3;
    text[1]                 = "Ïîæàëóéñòà, íàæìèòå êëàâèøó äëÿ ýòîãî äåéñòâèÿ.";

    onChgSetOption          = "keyIntSprint";
    onChgSetOptionSection   = "KEYS";
    flags                   = flags & ~/*IT_SELECTABLE*/ 4;
};
