--- DO NOT EDIT ME MANUALLY!
-- protocol definition. 
-- @author parse2lua.py
-- Creation: 2014-01-10
local _p = {
send = {
    [1000] = {
        [0] = {
            ["keys"] = {"uid","sid","pid"},
            ["fmt"] = "R3",
            },
        },
    },
receive = {
    [2000] = {
        [0] = {
            ["keys"] = {"role"},
            ["fmt"] = "S",
            },
        },
    },
}
return _p
