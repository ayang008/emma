local battle_cfg = {
    ["战斗1"] = {
        ["tip"] = "模式:回合制\n回合数:30\n怪物数量:8\n",
        ["player_count_down"] = 0,
        ["round_count"] = 30,
        ["player_coor"] = { {1, 1}, {2, 2}, {3, 1}, {4, 2}, {5, 2}, {6, 1}, },
        ["waves"] = {
            [1] = {
                ["cards"]   = { "bei_si","bei_si","bei_si", "bei_si", },
                ["card_coor"] = { {2, 5},   {1, 8},   {6, 7},   {4, 6}, },
                ["traps"]   = { "damage_trap_forever" },
                ["trap_coor"]   = { {3, 4} },
            },
            [2] = {
                ["cards"]   = { "xian_ren_zhang1", "xian_ren_zhang2", "xian_ren_zhang3", "xian_ren_zhang4" },
                ["card_coor"] = { {2, 8},                 {5, 4},              {1, 6},            {2, 5}, },
                ["traps"]   = { "damage_trap_forever" },
                ["trap_coor"]   = { {3, 4} },
            },
        },
    },

    ["战斗2"] = {
        ["tip"] = "模式:回合制\n回合数:30\n怪物数量:11\n",
        ["player_count_down"] = 0,
        ["round_count"] = 30,
        ["player_coor"] = { {1, 1}, {2, 2}, {3, 1}, {4, 2}, {5, 2}, {6, 1}, },
        ["waves"] = {
            [1] = {
                ["cards"]   = { "dian_qiu1", "dian_qiu2", "dian_qiu3", "dian_qiu4", },
                ["card_coor"] = { {4, 6},        {1, 4},      {3, 6},        {4, 6}, },
                ["traps"]   = { "damage_trap_forever" },
                ["trap_coor"]   = { {3, 4} },
            },
            [2] = {
                ["cards"]   = { "ku_lou1", "ku_lou1", "ku_lou1", "ku_lou1","ku_lou1", "ku_lou1" ,"ku_lou2" },
                ["card_coor"] = { {1, 6},    {2, 6},     {3, 6},     {4, 6},   {5, 6},    {6, 6},    {3, 7},  },
                ["traps"]   = { "damage_trap_forever" },
                ["trap_coor"]   = { {3, 4} },
            },
        },
    },

    ["战斗3"] = {
        ["tip"] = "模式:玩家移动限时\n移动时限:10秒\n怪物数量:8\n",
        ["player_count_down"] = 10,
        ["round_count"] = math.huge,
        ["player_coor"] = { {1, 1}, {2, 2}, {3, 1}, {4, 2}, {5, 2}, {6, 1}, },
        ["waves"] = {
            [1] = {
                ["cards"]   = { "bei_si","bei_si","bei_si", "bei_si", },
                ["card_coor"] = { {2, 6},   {5, 4},   {6, 5},   {6, 8}, },
                ["traps"]   = { "damage_trap_forever" },
                ["trap_coor"]   = { {3, 4} },
            },
            [2] = {
                ["cards"]   = { "xian_ren_zhang1", "xian_ren_zhang2", "xian_ren_zhang3", "xian_ren_zhang4" },
                ["card_coor"] = { {2, 8},                 {5, 4},              {1, 6},            {2, 5}, },
                ["traps"]   = { "damage_trap_forever" },
                ["trap_coor"]   = { {3, 4} },
            },
        },
    },

    ["战斗4"] = {
        ["tip"] = "模式:玩家移动限时\n移动时限:10秒\n怪物数量:11\n",
        ["player_count_down"] = 10,
        ["round_count"] = math.huge,
        ["player_coor"] = { {1, 1}, {2, 2}, {3, 1}, {4, 2}, {5, 2}, {6, 1}, },
        ["waves"] = {
            [1] = {
                ["cards"]   = { "dian_qiu1", "dian_qiu2", "dian_qiu3", "dian_qiu4", },
                ["card_coor"] = { {4, 6},        {1, 4},      {3, 6},        {4, 8}, },
                ["traps"]   = { "damage_trap_forever" },
                ["trap_coor"]   = { {3, 4} },
            },
            [2] = {
                ["cards"]   = { "ku_lou1", "ku_lou1", "ku_lou1", "ku_lou1","ku_lou1", "ku_lou1" ,"ku_lou2" },
                ["card_coor"] = { {1, 6},    {2, 6},     {3, 6},     {4, 6},   {5, 6},    {6, 6},    {3, 7},  },
                ["traps"]   = { "damage_trap_forever" },
                ["trap_coor"]   = { {3, 4} },
            },
        },
    },
}

return battle_cfg