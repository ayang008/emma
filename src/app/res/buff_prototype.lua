local buff_ptt = {
    ["poison"] = {
        ["hp"] = 3,
        ["on_turn_end"] = {
            [1] = {
                [1] = {
                    ["type"] = "damage",
                    ["base"] = 100,
                },
            },
        },
        ["on_second"] = {
            [1] = {
                [1] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_target_flash_sprite",
                    ["start"] = "target",
                    ["sprite"] = "image/skill/poison.png",
                },
            },
        },
    },
    ["float"] = {
        ["hp"] = 3,
        ["on_add"] = {
            [1] = {
                [1] = {
                    ["type"] = "play_anim",
                    ["anim"] = "xuan_zhong",
                },
            },
        },
        ["on_remove"] = {
            [1] = {
                [1] = {
                    ["type"] = "stop_anim",
                    ["anim"] = "xuan_zhong",
                },
            },
        },
    },
    ["cast_area_fire"] = {
        ["hp"] = 0,
        ["on_add"] = {
            [1] = {
                [1] = {
                    ["type"] = "cast_skill",
                    ["skill_ptt"] = "area_fire"
                },
            },
        },
    },
    ["battle_flag"] = {
        ["hp"] = 3,
        ["on_second"] = {
            [1] = {
                [1] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_target_flash_sprite",
                    ["start"] = "target",
                    ["sprite"] = "image/skill/battle_flag.png",
                },
            },
        },
    },
}

return buff_ptt