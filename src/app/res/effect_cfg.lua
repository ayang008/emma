--effect_sets定义的效果会一个set一个set顺序播放，每个set内部的效果混合
--repeat为effect_sets播放的次数，0代表无限循环，默认为1

--scale_to: 在time秒的时间内将缩放比变为scale
--fade_to: 在time秒的时间内将透明度变为opacity, opacity的范围为：0(完全透明) - 255(完全不透明)
--fade_out: 在time秒的时间内将透明度变为0
--fade_in: 在time秒的时间内将透明度变为255
--delay_time: 等待time秒
--move_to: 在time秒的时间内移动到x, y
--move_by: 在time秒的时间内移动x, y
--bezier_to: 贝塞尔曲线，需要arg起点start和终点end，height为曲线高度，time为时间
--rotate_by: 在time秒的时间内旋转angle

local effect_cfg = {
	["battle_field_tip"] = {
		["effect_sets"] = {
            [1] = {
                [1] = { 
				    ["name"] = "delay_time",
				    ["time"] = 1,
			    },
		    },

            [2] = {
                [1] = { 
				    ["name"] = "fade_out",
				    ["time"] = 0.5,
			    },
            },
        },
        ["repeat"] = 1,
	},

    ["battle_field_skill_tip"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = { 
				    ["name"] = "delay_time",
				    ["time"] = 1,
			    },
            },
		},
        ["repeat"] = 1,
	},

    ["battle_card_damaged"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "move_by", 
				    ["time"] = 0.05, 
                    ["x"] = 3, 
                    ["y"] = -1, 
			    },
		    },
            [2] = {
                [1] = {
				    ["name"] = "move_by", 
				    ["time"] = 0.05, 
                    ["x"] = -3, 
                    ["y"] = 1, 
			    },
            },
            ["repeat"] = 5,
        },
	},

    ["foot_step"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "fade_out", 
				    ["time"] = 0.5, 
			    },
            },
		},
		["repeat"] = 1,
	},

    ["skill_damage_effect"] = {
        ["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "delay_time", 
				    ["time"] = 1, 
			    },
            },
		},
		["repeat"] = 1,
    },

	["battle_card_head_msg"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "move_by", 
                    ["time"] = 0.3,
                    ["x"] = 0, 
                    ["y"] = 30,
			    },
            },
		},
		["repeat"] = 1,
	},

    ["oreo_try_attack_zi"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "scale_to", 
				    ["time"] = 0.2, 
				    ["scale"] = 1.2, 
			    },
            },
            [2] = {
                [1] = {
				    ["name"] = "scale_to", 
				    ["time"] = 0.2, 
				    ["scale"] = 1.0, 
			    },
            },
		},
		["repeat"] = 2,
	},

	["battle_card_oreo_try_attack"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "scale_to", 
				    ["time"] = 0.2, 
				    ["scale"] = 1, 
			    },
                [2] = {
                    ["name"] = "move_by", 
				    ["time"] = 0.2, 
                    ["x"] = 0, 
                    ["y"] = 20, 
                },
            },
            [2] = {
                [1] = {
                    ["name"] = "delay_time", 
				    ["time"] = 0.6, 
                },
            },
            [3] = {
                
            },
		},
		["repeat"] = 1,
	},

    ["battle_field_show_attack"] = {
        ["effect_sets"] = {
            [1] = {
                [1] = {
                    ["name"] = "delay_time", 
				    ["time"] = 0.2, 
                },
            },
            [2] = {
                [1] = {
                    ["name"] = "scale_to", 
				    ["time"] = 0.1,
                    ["scale"] = 0.8, 
                },
                [2] = {
                    ["name"] = "delay_time", 
				    ["time"] = 0.5,
                },
            },
            [3] = {
                [1] = {
                    ["name"] = "fade_out", 
				    ["time"] = 0.5,
                },
                [2] = {
                    ["name"] = "scale_to", 
				    ["time"] = 0.5,
                    ["scale"] = 1, 
                },
            },
	    },
        ["repeat"] = 1,
    },

    ["battle_card_show_skill"] = {
        ["effect_sets"] = {
            [1] = {
                [1] = {
                    ["name"] = "scale_to", 
				    ["time"] = 0.15,
                    ["scale"] = 0.5, 
                },
                [2] = {
                    ["name"] = "fade_in", 
				    ["time"] = 0, 
                },
                [3] = {
                    ["name"] = "delay_time", 
				    ["time"] = 0.5, 
                },
            },
            [2] = {
                [1] = {
                    ["name"] = "fade_out", 
				    ["time"] = 0.8,
                },
            },
	    },
        ["repeat"] = 1,
    },

    ["skill_caster_bounce"] = {
        ["effect_sets"] = {
            [1] = {
		        [1] = {
	                ["name"] = "move_by", 
				    ["time"] = 0.1, 
                    ["x"] = -1, 
				    ["y"] = 3, 
			    },
            },
            [2] = {
                [1] = {
                    ["name"] = "delay_time", 
				    ["time"] = 0.6,
                },
            },
            [3] = {
                [1] = {
	                ["name"] = "move_by", 
				    ["time"] = 0.1, 
                    ["x"] = 1, 
				    ["y"] = -3, 
			    },
            },
	    },
        ["repeat"] = 1,
    },

    ["skill_heal"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "bezier_to", 
				    ["time"] = 1.2, 
				    ["height"] = 64, 
			    },
            },
		},
		["repeat"] = 1,
	},

    ["skill_throw_fire"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "bezier_to", 
				    ["time"] = 0.7, 
				    ["height"] = 64, 
			    },
            },
		},
		["repeat"] = 1,
	},

    ["skill_target_flash_sprite"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "fade_in", 
				    ["time"] = 0.1, 
			    },
            },
            [2] = {
                [1] = {
				    ["name"] = "fade_out", 
				    ["time"] = 0.1, 
			    },
            },
		},
		["repeat"] = 2,
	},

    ["link"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "fade_to", 
				    ["time"] = 0.5, 
                    ["opacity"] = 72,
			    },
            },
            [1] = {
                [1] = {
				    ["name"] = "fade_to", 
				    ["time"] = 0.5, 
                    ["opacity"] = 64, 
			    },
            },
		},
		["repeat"] = 0,
	},

    ["link_card_move"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "move_by", 
				    ["time"] = 0.5, 
                    ["x"] = 0,
                    ["y"] = -6,
			    },
            },
            [1] = {
                [2] = {
				    ["name"] = "move_by", 
				    ["time"] = 0.5,
                    ["x"] = 0,
                    ["y"] = 6, 
			    },
            },
		},
		["repeat"] = 0,
	},

    ["link_card"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
				    ["name"] = "move_by", 
				    ["time"] = 0.3, 
                    ["x"] = 0,
                    ["y"] = -2,
			    },
            },
            [2] = {
                [1] = {
				    ["name"] = "move_by", 
				    ["time"] = 0.3,
                    ["x"] = 0,
                    ["y"] = 2, 
			    },
            },
            [3] = {
                [1] = {
				    ["name"] = "move_by", 
				    ["time"] = 0.3, 
                    ["x"] = 0,
                    ["y"] = 2,
			    },
            },
            [4] = {
                [1] = {
				    ["name"] = "move_by", 
				    ["time"] = 0.3,
                    ["x"] = 0,
                    ["y"] = -2, 
			    },
            },
		},
		["repeat"] = 0,
	},

    ["card_pushed"] = {
		["effect_sets"] = {
            [1] = {
			    [1] = {
                    ["name"] = "rotate_by",
                    ["time"] = 0.2,
                    ["angle"] = 360,
                },
            },
		},
		["repeat"] = 0,
	},

    ["card_died"] = {
		["effect_sets"] = {
            [1] = {
                [1] = {
                    ["name"] = "scale_to",
                    ["scale"] = 1.3,
                    ["time"] = 0.2,
                },     
            },
            [2] = {
			    [1] = {
                    ["name"] = "fade_out",
                    ["time"] = 1,
                },
            },
		},
		["repeat"] = 0,
	},
}

function get_effect(idx, args)
	assert(next(effect_cfg[idx].effect_sets)) 
    args = args or {}

    local create_effect = 	function(effect)
								assert(next(effect))
								if (effect.name == "fade_to") then
									return cc.FadeTo:create(effect.time, effect.opacity), effect.time
								elseif (effect.name == "fade_out") then
									return cc.FadeOut:create(effect.time), effect.time
								elseif (effect.name == "fade_in") then
									return cc.FadeIn:create(effect.time), effect.time
								elseif (effect.name == "scale_to") then
									return cc.ScaleTo:create(effect.time, effect.scale), effect.time
                                elseif (effect.name == "delay_time") then
									return cc.DelayTime:create(effect.time), effect.time
                                elseif (effect.name == "move_by") then
									return cc.MoveBy:create(effect.time, cc.p(effect.x, effect.y)), effect.time
                                elseif (effect.name == "move_to") then
									return cc.MoveBy:create(effect.time, cc.p(effect.x, effect.y)), effect.time
                                elseif (effect.name == "bezier_to") then
                                    local p1_x, p1_y, p2_x, p2_y
                                    p1_x = args.start_x - effect.height
                                    p1_y = args.start_y + effect.height
                                    p2_x = args.end_x - effect.height
                                    p2_y = args.end_y + effect.height
                                    local bezier = {  
                                        cc.p(p1_x, p1_y),
                                        cc.p(p2_x, p2_y), 
                                        cc.p(args.end_x, args.end_y),
                                    }
                                    return cc.BezierTo:create(effect.time, bezier), effect.time
                                elseif (effect.name == "rotate_by") then
                                    return cc.RotateBy:create(effect.time, effect.angle), effect.time 
								else
									assert(false)
								end
						  	end 

	local repeat_times = effect_cfg[idx]["repeat"] or 1

    local ret = nil
    local time = 0
    for _, effect_set in ipairs(effect_cfg[idx].effect_sets) do
        local set_ret = nil
        local set_time = 0
        for _, effect in ipairs(effect_set) do
            local one_ret, one_time = create_effect(effect)
            if (not set_ret) then
                set_ret = one_ret
            else
                set_ret = cc.Spawn:create(set_ret, one_ret)
            end
            set_time = math.max(set_time, one_time)
        end

        if (not ret) then
            ret = set_ret
        else
            ret = cc.Sequence:create(ret, set_ret)
        end
        time = time + set_time
    end

    if (repeat_times == 0) then
    	ret = cc.RepeatForever:create(ret)
    else
    	ret = cc.Repeat:create(ret, repeat_times)
        time = time * repeat_times
        if (args.callback) then
            ret = cc.Sequence:create(ret, cc.CallFunc:create(callback))
        end
    end

    return ret, time
end

return get_effect