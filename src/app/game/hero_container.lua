local hero_container = class("hero_container")

hero_container.heros = hero_container.heros or {}

function hero_container:add_hero(hero)
    assert(self.heros[hero.id] == nil, "hero id collasped")
    self.heros[hero.id] = hero
end

function hero_container:find_hero(id)
    return self.heros[id]
end

function hero_container:remove_hero(id)
    self.heros[id] = nil
end

function hero_container:get_heros()
    return self.heros
end

return hero_container