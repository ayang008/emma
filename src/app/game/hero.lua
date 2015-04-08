local hero = class("hero")

local hero_sprite = {
    ["hua_tuo"] = "image/icon/hua_tuo.png",
    ["zuo_ci"] = "image/icon/zuo_ci.png",
    ["dong_zhuo"] = "image/icon/dong_zhuo.png",
    ["nan_gua"] = "image/icon/nan_gua.png",
}

local hero_sprite_mt = {}
hero_sprite_mt.__index = function () return "image/icon/mo_ren.png" end
setmetatable(hero_sprite, hero_sprite_mt)

function hero:ctor(id, name)
    self.id = id
    self.name = name
    self.hp = 100
    self.grid_size = 1
end

function hero:sprite()
    return hero_sprite[self.name]
end

return hero