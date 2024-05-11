/*
 * Re-define the menu item class because it is not guaranteed that it exists in every mod.
 * Note, that the original class/prototype are not overwritten but unique symbol names are used.
 */

class Patch_Stamina_C_Menu_Item /* C_Menu_Item */ {
    var string fontName;
    var string text[10];
    var string backPic;
    var string alphaMode;
    var int alpha;
    var int type;
    var int onSelAction[5];
    var string onSelAction_S[5];
    var string onChgSetOption;
    var string onChgSetOptionSection;
    var func onEventAction[10];
    var int posx;
    var int posy;
    var int dimx;
    var int dimy;
    var float sizeStartScale;
    var int flags;
    var float openDelayTime;
    var float openDuration;
    var float userFloat[4];
    var string userString[4];
    var int frameSizeX;
    var int frameSizeY;
  // Gothic 1.30 / Gothic 2.6 only
    var string hideIfOptionSectionSet;
    var string hideIfOptionSet;
    var int hideOnValue;
};

prototype Patch_Stamina_C_Menu_Item_Def(PATCH_STAMINA_C_MENU_ITEM /* C_Menu_Item */) {
    // Constants
    const string MENU_FONT_DEFAULT = "font_old_20_white.tga";
    const int MENU_ITEM_TEXT       = 1;
    const int IT_CHROMAKEYED       = 1;
    const int IT_TRANSPARENT       = 2;
    const int IT_SELECTABLE        = 4;
    const int SEL_ACTION_BACK      = 1;

    fontName = MENU_FONT_DEFAULT;
    text = "";
    alphaMode = "BLEND";
    alpha = 254;
    type = MENU_ITEM_TEXT;
    posx = 0;
    posy = 0;
    dimx = -1;
    dimy = -1;
    flags = IT_CHROMAKEYED|IT_TRANSPARENT|IT_SELECTABLE;
    openDelayTime = 0;
    openDuration = -1;
    sizeStartScale = 1;
    userFloat[0] = 100;
    userFloat[1] = 200;
    onSelAction[0] = SEL_ACTION_BACK;
    onChgSetOption = "";
    onChgSetOptionSection = "INTERNAL";
    frameSizeX = 0;
    frameSizeY = 0;
    hideIfOptionSectionSet = "";
    hideIfOptionSet = "";
    hideOnValue = -1;
};
