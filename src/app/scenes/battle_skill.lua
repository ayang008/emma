local battle_skill = class("battle_skill")

function battle_skill:ctor(skill)
    self.skill_ = skill
end

function battle_skill:try_cast(caster, field, oreo, percent)
    self.caster_ = caster
    self.field_ = field
    self.oreo_ = oreo

    local try_ret, try_time
    percent = percent or self.skill_:get_percent()
    if (math.random() <= percent) then
        if (self:valid_condition_()) then
            local action_targets = self:range_find_()
            if (next(action_targets)) then 
                try_ret, try_time = self:try_cast_actions_(action_targets)
            end
        end
    end

    return try_ret, try_time
end

function battle_skill:get_name()
    return self.skill_:get_name()
end

function battle_skill:get_icon()
    return self.skill_:get_icon()
end

function battle_skill:has_tag(tag)
    return self.skill_:has_tag(tag)
end

function battle_skill:valid_condition_()
    local condition = self.skill_:get_condition()
    if (condition) then
        if (condition == "oreo_attacker") then
            if ((not self.oreo_) or (not self.oreo_:is_attacker(self.caster_))) then
                return false
            end
        end
    end

    return true
end

function battle_skill:range_find_()
    local action_targets = {}

    local range = self.skill_:get_range()
    if (range.type == "oreo_enemy") then
        local enemies = self.oreo_:get_defenders()
        for _, enemy in ipairs(enemies) do
            local found_one = {}
            found_one.battle_card = enemy
            found_one.idx = enemy:get_field_idx()
            table.insert(action_targets, found_one)
        end
    elseif (range.type == "oreo_link") then
        local cards = nil
        local attackers = self.oreo_:get_attacker_cards()
        for _, attacker in ipairs(attackers) do
            local link = self.oreo_:find_same_link_cards(attacker)
            for _, card in ipairs(link) do
                if (self.caster_ == card) then
                    cards = link
                end
            end
        end

        if (cards) then
            for _, card in ipairs(cards) do
                local found_one = {}
                found_one.battle_card = card
                found_one.idx = card:get_field_idx()
                table.insert(action_targets, found_one)
            end
        end
    elseif (range.type == "cross") then
        local dir_idxes = {} 
        table.insert(dir_idxes, self.field_:find_up_idxes(self.caster_, range.num))
        table.insert(dir_idxes, self.field_:find_down_idxes(self.caster_, range.num))
        table.insert(dir_idxes, self.field_:find_left_idxes(self.caster_, range.num))
        table.insert(dir_idxes, self.field_:find_right_idxes(self.caster_, range.num))
        for _, idxes in ipairs(dir_idxes) do
            for _, idx in ipairs(idxes) do
                local found_one = {}
                found_one.idx = idx
                found_one.battle_card = self.field_:get_idx_card()
                table.insert(action_targets, found_one)
            end
        end
    elseif (range.type == "vertical") then
        local dir_idxes = {} 
        table.insert(dir_idxes, self.field_:find_up_idxes(self.caster_, range.num))
        table.insert(dir_idxes, self.field_:find_down_idxes(self.caster_, range.num))
        for _, idxes in ipairs(dir_idxes) do
            for _, idx in ipairs(idxes) do
                local found_one = {}
                found_one.idx = idx
                found_one.battle_card = self.field_:get_idx_card()
                table.insert(action_targets, found_one)
            end
        end
    elseif (range.type == "horizontal") then
        local dir_idxes = {} 
        table.insert(dir_idxes, self.field_:find_left_idxes(self.caster_, range.num))
        table.insert(dir_idxes, self.field_:find_down_idxes(self.caster_, range.num))
        for _, idxes in ipairs(dir_idxes) do
            for _, idx in ipairs(idxes) do
                local found_one = {}
                found_one.idx = idx
                found_one.battle_card = self.field_:get_idx_card()
                table.insert(action_targets, found_one)
            end
        end
    elseif (range.type == "area") then
        local idxes = self.field_:find_area_idxes(self.caster_)
        for _, idx in ipairs(idxes) do
            local found_one = {}
            found_one.idx = idx
            found_one.battle_card = self.field_:get_idx_card(idx)
            table.insert(action_targets, found_one)
        end
    elseif (range.type == "column") then
        local dir_idxes = {} 
        table.insert(dir_idxes, self.field_:find_up_idxes(self.caster_, math.huge))
        table.insert(dir_idxes, self.field_:find_down_idxes(self.caster_, math.huge))
        for _, idxes in ipairs(dir_idxes) do
            for _, idx in ipairs(idxes) do
                local found_one = {}
                found_one.idx = idx
                found_one.battle_card = self.field_:get_idx_card()
                table.insert(action_targets, found_one)
            end
        end
    elseif (range.type == "row") then
        local dir_idxes = {} 
        table.insert(dir_idxes, self.field_:find_left_idxes(self.caster_, math.huge))
        table.insert(dir_idxes, self.field_:find_right_idxes(self.caster_, math.huge))
        for _, idxes in ipairs(dir_idxes) do
            for _, idx in ipairs(idxes) do
                local found_one = {}
                found_one.idx = idx
                found_one.battle_card = self.field_:get_idx_card()
                table.insert(action_targets, found_one)
            end
        end
    elseif (range.type == "all") then
        local dir_idxes = {} 
        table.insert(dir_idxes, self.field_:get_all_idxes())
        for _, idxes in ipairs(dir_idxes) do
            for _, idx in ipairs(idxes) do
                local found_one = {}
                found_one.idx = idx
                found_one.battle_card = self.field_:get_idx_card(idx)
                table.insert(action_targets, found_one)
            end
        end
    else
        assert(false)
    end

    return action_targets
end

function battle_skill:try_cast_actions_(action_targets)
    local action_sets = self.skill_:get_action_sets()

    local try_ret, try_time = battle_action.new(self.caster_, self.field_, action_targets, action_sets):try_cast_actions()

    return try_ret, try_time
end

return battle_skill