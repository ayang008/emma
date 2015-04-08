local cfg = {
--战斗相关---------------------------------
    ["BATTLE_FIELD_X_OFFSET"] = 0,
    ["BATTLE_FIELD_Y_OFFSET"] = -20,
    ["BATTLE_FIELD_COL_NUM"] = 6,
    ["BATTLE_FIELD_ROW_NUM"] = 8,
    ["BATTLE_FIELD_GRID_WIDTH"] = 66,
    ["BATTLE_FIELD_GRID_ADJUST"] = 2,
    ["PLAYER_YIDONG_DAOJISHI_PINLV"] = 0.05,

    ["BATTLE_FIELD_DIR_UP"] = 1,
    ["BATTLE_FIELD_DIR_DOWN"] = -1,
    ["BATTLE_FIELD_DIR_LEFT"] = 2,
    ["BATTLE_FIELD_DIR_RIGHT"] = -2,
    ["BATTLE_FIELD_DIR_UPRIGHT"] = 3,
    ["BATTLE_FIELD_DIR_UPLEFT"] = 4,
    ["BATTLE_FIELD_DIR_DOWNLEFT"] = -3,
    ["BATTLE_FIELD_DIR_DOWNRIGHT"] = -4,

    ["BATTLE_FIELD_CORNER_LEFTDOWN"] = 1,
    ["BATTLE_FIELD_CORNER_LEFTUP"] = 2,
    ["BATTLE_FIELD_CORNER_RIGHTUP"] = 3,
    ["BATTLE_FIELD_CORNER_RIGHTDOWN"] = 4,

    ["ACTIVE_MOVE_ONE_GRID_SECOND"] = 0.2,
    ["SWAP_MOVE_ONE_GRID_SECOND"] = 0.2,
    ["PUSHED_MOVE_ONE_GRID_SECOND"] = 0.2,
    ["SKILL_PUSHED_MOVE_SECOND"] = 0.2,

    ["CARD_BATTLE_TYPE_PLAYER"] = 1,
    ["CARD_BATTLE_TYPE_MONSTER"] = 2,
    ["CARD_BATTLE_TYPE_SYSTEM"] = 3,

    ["BIG_SPRITE_X_LEFT_BOUND"] = 0.3,
    ["BIG_SPRITE_X_RIGHT_BOUND"] = 0.7,
    ["BIG_SPRITE_Y_UPPER_BOUND"] = 0.7,
    ["BIG_SPRITE_Y_LOWER_BOUND"] = 0.3,

    ["MULTI_DAMAGE_ZI_INTERVAL"] = 0.1,
    ["SKILL_AFTER_OREO_PAUSE"] = 0.5,
    ["SKILL_INTERVAL"] = 0.5,
    ["SKILL_ACTION_SET_INTERVAL"] = 0,
    
    ["CARD_SHOW_SKILL_SPRITE_SCALE_FROM"] = 0.1,
    ["CARD_SHOW_DEATH_SPRITE_SCALE"] = 0.3,
    

--显示深度-----------------------------------
    ["Z_BATTLE_SCENE_BATTLE_FIELD"] = 1,
    ["Z_BATTLE_FIELD_GEZI"] = 1,
    ["Z_BATTLE_FIELD_TRAP_SPRITE"] = 2,
    ["Z_BATTLE_FIELD_FOOT_STEP"] = 3,
    ["Z_BATTLE_FIELD_ATTACK_LINK"] = 4,
    ["Z_BATTLE_FIELD_CARD"] = 5,
    ["Z_BATTLE_FIELD_CARD_PLAYER_MOVING"] = 6,
    ["Z_BATTLE_FIELD_BIG_SPRITE"] = 7,
    ["Z_BATTLE_FIELD_SKILL_EFFECT"] = 8,
    ["Z_BATTLE_CARD_HEAD_JUMP_MSG"] = 9,
    ["Z_BATTLE_FIELD_CARD_SHOW_SKILL"] = 10,
    

    ["Z_BATTLE_CARD_SPRITE"] = 1,
    ["Z_BATTLE_CARD_BIG_SPRITE"] = 2,
    ["Z_BATTLE_CARD_XUETIAO_BG"] = 3,
    ["Z_BATTLE_CARD_XUETIAO"] = 4,
    ["Z_BATTLE_CARD_OREO_MULTI"] = 5,

    ["Z_BATTLE_SCENE_UI"] = 2,
    ["Z_BATTLE_UI_PLAYER_BAR"] = 3,
    ["Z_BATTLE_UI_TIP"] = 4,

--通用---------------------------------------
    ["COLOR_RED"] = cc.c3b(255,0,0),
    ["COLOR_GREEN"] = cc.c3b(0,255,0),
    ["COLOR_BLUE"] = cc.c3b(0,0,255),
    ["COLOR_WHITE"] = cc.c3b(255,255,255),
    ["COLOR_YELLOW"] = cc.c3b(255,255,0),

--字体---------------------------------------
    ["FONT_DEFAULT"] = "fonts/default.ttf",
    ["CARD_HEAD_JUMP_MSG_ZI_SIZE"] = 32,
    ["TIP_ZI_SIZE"] = 96,
    ["OREO_TRY_ATTACK_ZI_SIZE"] = 32,
    ["SKILL_TIP_ZI_SIZE"] = 45,

--UI----------------------------------------
    ["ICON_LABEL_WINDOW_LINE_DIS"] = 0,
    ["ICON_LABEL_WINDOW_FRAME_DIS"] = 30,
}

return cfg