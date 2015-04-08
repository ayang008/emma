local skill = class("skill")

function skill:ctor(ptt)
    assert(skill_ptt[ptt])
    self.ptt_ = skill_ptt[ptt]
end

function skill:get_range()
    return self.ptt_.range
end

function skill:get_condition()
    return self.ptt_.condition
end

function skill:get_percent()
    return self.ptt_.percent
end

function skill:get_action_sets()
    return self.ptt_.action_sets
end

function skill:get_name()
    return self.ptt_.name
end

function skill:get_icon()
    return self.ptt_.icon
end

function skill:has_tag(tag)
    for _, v in ipairs(self.ptt_.tags) do
        if (tag == v) then
            return true
        end
    end

    return false
end

return skill