local enemy_hero_id_generator = {}

enemy_hero_id_generator.id_ = 1

function enemy_hero_id_generator:new_id()
    ret = self.id_
    self.id_ = self.id_ + 1
    if (self.id_ == 100) then self.id_ = 1 end
    return ret
end

return enemy_hero_id_generator