local trap_ptt = {
    ["damage_trap"] = {
        ["image"] = "image/trap/test.png",
        ["life"] = 1,
        ["on_card_move_to"] = {
            [1] = {
                [1] = {
                    ["type"] = "damage",
                    ["base"] = 100,
                    ["filters"] = {
                        [1] = {
                            ["type"] = "no_buff",
                            ["buff_ptt"] = "float",
                        },
                    },
                },
            },
        },
        ["on_turn_end"] = {
            [1] = {
                [1] = {
                    ["type"] = "damage",
                    ["base"] = 100,
                    ["filters"] = {
                        [1] = {
                            ["type"] = "no_buff",
                            ["buff_ptt"] = "float",
                        },
                    },
                },
            },
        },
    },
     ["damage_trap_forever"] = {
        ["image"] = "image/trap/test.png",
        ["life"] = math.huge,
        ["on_card_move_to"] = {
            [1] = {
                [1] = {
                    ["type"] = "damage",
                    ["base"] = 100,
                    ["filters"] = {
                        [1] = {
                            ["type"] = "no_buff",
                            ["buff_ptt"] = "float",
                        },
                    },
                },
            },
        },
        ["on_turn_end"] = {
            [1] = {
                [1] = {
                    ["type"] = "damage",
                    ["base"] = 100,
                    ["filters"] = {
                        [1] = {
                            ["type"] = "no_buff",
                            ["buff_ptt"] = "float",
                        },
                    },
                },
            },
        },
    },
}

return trap_ptt