local pic = {
    ["zhan_chang_ge_zi"]                = "image/battle/battle_map_grid_bg.png",
    ["zhan_chang_bei_jing"]             = "image/battle/battle_map_bg.jpg",
    ["yidong_daojishi_tiao"]     		= "image/battle/player_count_down.png",
    ["xie_tong_gong_ji_ge_zi"]          = "image/battle/attack_link_effect.png",
    ["zhan_chang_ge_zi_yidong"]         = "image/battle/attack_link_effect.png",
    ["card_xuetiao"]     				= "image/card/xue_tiao.png",
    ["card_xuetiao_enemy"]     			= "image/card/xue_tiao_diren.png",
    ["card_xuetiao_bei_jing"]           = "image/card/xue_tiao_bei_jing.png",
    ["icon_lable_window_bg"]            = "image/battle/battle_map_grid_bg.png",
    ["combat_list_bg"]                  = "image/battle/battle_map_grid_bg.png",
    ["checkbox_on"]                     = "image/ui/checkbox_on.png",
    ["checkbox_off"]                    = "image/ui/checkbox_off.png",
    ["default"]        					= "image/default.png",
}

local pic_mt = {}
pic_mt.__index = function () return pic.default end
setmetatable(pic, pic_mt)

return pic