--range:
-- type:
--      oreo_enemy:夹击的敌人
--      oreo_self_side:夹击中自己这边的友军(包括自己)
--      cross:十字
--      vertical:垂直
--      horizontal:水平
--      area:周围
--      column:列
--      row:行
-- num: range的大小

--actions:
--  type:
--      damage: 伤害，base为基础数值，physic为物理加成，magic为魔法加成，num为次数默认为1
--      heal: 治疗，base为基础数值，physic为物理加成，magic为魔法加成
--      push: 推开num个格子
--      effect: 播放特效
--          effect_cfg: effect_cfg.lua中的特效
--          如果播放的特效需要参数: caster为技能释放者的位置，target为技能目标的位置
--          particle: 创建一个粒子效果来播放特效
--          sprite: 创建一个精灵来播放特效
--          caster: 技能释放者播放特效
--          target: 技能目标播放特效
--  filters: 对range中的目标进行筛选
--      all: 包括释放者和接收者，此项是所有配置默认初始值
--      ally: 盟友
--      enemy: 敌对
--      no_card: 无牌 --一般只能用来播放特效

local skill_ptt = {
    ["dragon_bite"] = {
        ["name"] = "龙咬",
        ["icon"] = "image/skill/fire.png",
        ["tags"] = { "attack", },
        ["condition"] = "oreo_attacker",
        ["range"] = {
            ["type"] = "oreo_enemy",
        }, 
        ["percent"] = 1,
        ["action_sets"] = {
            [1] = {
                [1] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_caster_bounce",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "caster"
                        } 
                    },
                    ["start"] = "caster",
                    ["caster"] = "",
                },
                [2] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_target_flash_sprite",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "enemy"
                        } 
                    },
                    ["start"] = "target",
                    ["sprite"] = "image/skill/magasword.png",
                },
                [3] = {
                    ["type"] = "damage",
                    ["base"] = 100,
                    ["physic"] = 0.2,
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "enemy"
                        } 
                    },
                },
            },
        },
    },
    ["healchain"] = {
        ["name"] = "治疗链",
        ["icon"] = "image/skill/earth.png",
        ["tags"] = { "heal", },
        ["condition"] = nil,
        ["range"] = {
            ["type"] = "oreo_link",
            ["num"] = 1,
        },  
        ["percent"] = 1,
        ["action_sets"] = {
            [1] = {
                [1] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_caster_bounce",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "caster"
                        } 
                    },
                    ["start"] = "caster",
                    ["caster"] = "",
                },
                [2] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_heal",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "ally"
                        } 
                    },
                    ["start"] = "caster",
                    ["end"] = "target",
                    ["particle"] = "particle/test.plist",
                },
            },
            [2] = {
                [1] = {
                    ["type"] = "heal",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "ally"
                        } 
                    },
                    ["base"] = 100,
                    ["magic"] = 0.2,
                },
            },
        },
    },
    ["float_ally"] = {
        ["name"] = "漂浮术",
        ["icon"] = "image/skill/ice.png",
        ["tags"] = { "buff", },
        ["condition"] = nil,
        ["range"] = {
            ["type"] = "all",
        },  
        ["percent"] = 1,
        ["action_sets"] = {
            [1] = {
                [1] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_caster_bounce",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "caster"
                        } 
                    },
                    ["start"] = "caster",
                    ["caster"] = "",
                },
                [2] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_target_flash_sprite",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "ally"
                        } 
                    },
                    ["start"] = "target",
                    ["sprite"] = "image/skill/float.png",
                },
                [3] = {
                    ["type"] = "add_buff",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "ally"
                        } 
                    },
                    ["buff_ptt"] = "float",
                },
            },
        },
    },
    ["area_fire"] = {
        ["name"] = "区域火",
        ["icon"] = "image/skill/fire.png",
        ["tags"] = { "attack", },
        ["condition"] = nil,
        ["range"] = {
            ["type"] = "area",
        },  
        ["percent"] = 1,
        ["action_sets"] = {
            [1] = {
                [1] = {
                    ["type"] = "damage",
                    ["base"] = 100,
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "enemy"
                        } 
                    },
                },
                [2] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_damage_effect",
                    ["filters"] = {
                    },
                    ["start"] = "target",
                    ["particle"] = "particle/test2.plist",
                },
            },
        },
    },
    ["fire_ball"] = {
        ["name"] = "火球术",
        ["icon"] = "image/skill/fire.png",
        ["tags"] = { "attack", },
        ["range"] = {
            ["type"] = "oreo_enemy",
        }, 
        ["percent"] = 1,
        ["action_sets"] = {
            [1] = {
                [1] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_caster_bounce",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "caster"
                        } 
                    },
                    ["start"] = "caster",
                    ["caster"] = "",
                },
                [2] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_throw_fire",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "enemy"
                        } 
                    },
                    ["start"] = "caster",
                    ["end"] = "target",
                    ["particle"] = "particle/test.plist",
                },
            },
            [2] = {
                [1] = {
                    ["type"] = "add_buff",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "enemy"
                        } 
                    },
                    ["buff_ptt"] = "cast_area_fire",
                },
            },
        },
    },
    ["kick_back"] = {
        ["name"] = "击退",
        ["icon"] = "image/skill/fire.png",
        ["tags"] = { "attack", },
        ["condition"] = "oreo_attacker",
        ["range"] = {
            ["type"] = "oreo_enemy",
        }, 
        ["percent"] = 1,
        ["action_sets"] = {
            [1] = {
                [1] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_caster_bounce",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "caster"
                        } 
                    },
                    ["start"] = "caster",
                    ["caster"] = "",
                },
                [2] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_target_flash_sprite",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "enemy"
                        } 
                    },
                    ["start"] = "target",
                    ["sprite"] = "image/skill/magasword.png",
                },
                [3] = {
                    ["type"] = "damage",
                    ["base"] = 100,
                    ["physic"] = 0.2,
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "enemy"
                        } 
                    },
                },
                [4] = {
                    ["type"] = "push",
                    ["num"] = 2,
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "enemy"
                        } 
                    },
                },
            },
        },
    },
    ["battle_flag"] = {
        ["name"] = "军旗",
        ["icon"] = "image/skill/water.png",
        ["tags"] = { "buff", },
        ["condition"] = "",
        ["range"] = {
            ["type"] = "all",
        }, 
        ["percent"] = 1,
        ["action_sets"] = {
            [1] = {
                [1] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_caster_bounce",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "caster"
                        } 
                    },
                    ["start"] = "caster",
                    ["caster"] = "",
                },
                [2] = {
                    ["type"] = "effect",
                    ["effect_cfg"] = "skill_target_flash_sprite",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "ally"
                        } 
                    },
                    ["start"] = "target",
                    ["sprite"] = "image/skill/water.png",
                },
                [3] = {
                    ["type"] = "add_buff",
                    ["filters"] = { 
                        [1] = {
                            ["type"] = "ally"
                        } 
                    },
                    ["buff_ptt"] = "battle_flag",
                },
            },
        },
    },
}

return skill_ptt