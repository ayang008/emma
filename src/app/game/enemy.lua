local hero_container = import(".hero_container")
local id_generator = import(".enemy_hero_id_generator")

local enemy = class("enemy", hero_container)

local enemy_hero_id = 1

function enemy:ctor()
    self:add_hero(hero.new(id_generator:new_id(), "nan_gua"))
    self:add_hero(hero.new(id_generator:new_id(), "nan_gua"))
    self:add_hero(hero.new(id_generator:new_id(), "nan_gua"))
end

return enemy:new()