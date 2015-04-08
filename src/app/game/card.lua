local card = class("card")

local skill = import(".skill")

function card:ctor(ptt)
    assert(card_ptt[ptt])
    self.ptt_ = card_ptt[ptt]
    self.skills_ = {}
    if (self.ptt_.skills) then
        for _, v in ipairs(self.ptt_.skills) do
            table.insert(self.skills_, skill.new(v))
        end
    end
end

function card:get_image()
    return self.ptt_.image
end

function card:get_big_image()
    return self.ptt_.big_image
end

function card:get_tip()
    return self.ptt_.tip
end

function card:get_max_hp()
    return self.ptt_.hp
end

function card:get_skills()
    return self.skills_
end

function card:get_buffs()
    return self.ptt_.buffs or {}
end

function card:get_size()
    return self.ptt_.size
end

return card