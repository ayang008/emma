local battle_action = class("battle_action")

function battle_action:ctor(caster, field, targets, action_sets)
    self.caster_ = caster
    self.field_ = field
    self.targets_ = targets
    self.action_sets_ = action_sets
end

function battle_action:try_cast_actions()
    local try_ret = nil
    local try_time = 0

    for _, action_set in ipairs(self.action_sets_) do
        local try_set_ret = nil
        local try_set_time = 0

        for _, action in ipairs(action_set) do
            local try_one_ret = nil
            local try_one_time = 0

            if (action.type == "damage") then
                try_one_ret, try_one_time = self:try_cast_action_damage_(action)            
            elseif (action.type == "heal") then
                try_one_ret, try_one_time = self:try_cast_action_heal_(action)
            elseif (action.type == "push") then
                try_one_ret, try_one_time = self:try_cast_action_push_(action)
            elseif (action.type == "effect") then
                try_one_ret, try_one_time = self:try_cast_action_effect_(action)
            elseif (action.type == "add_trap") then
                try_one_ret, try_one_time = self:try_cast_action_add_trap_(action)
            elseif (action.type == "add_buff") then
                try_one_ret, try_one_time = self:try_cast_action_add_buff_(action)
            elseif (action.type == "cast_skill") then
                try_one_ret, try_one_time = self:try_cast_action_cast_skill_(action)
            elseif (action.type == "play_anim") then
                try_one_ret, try_one_time = self:try_cast_action_play_anim_(action)
            elseif (action.type == "stop_anim") then
                try_one_ret, try_one_time = self:try_cast_action_stop_anim_(action)
            else
                assert(false)
            end

            if (try_one_ret) then
                if (not try_set_ret) then
                    try_set_ret = try_one_ret
                else
                    try_set_ret = cc.Spawn:create(try_set_ret, try_one_ret)
                end
                try_set_time = math.max(try_set_time, try_one_time)
            end
        end

        if (try_set_ret) then
            try_set_ret = cc.Sequence:create(cc.DelayTime:create(try_time), try_set_ret)
            if (not try_ret) then
                try_ret = try_set_ret
            else
                try_ret = cc.Spawn:create(try_ret, try_set_ret)
            end
            try_set_time = try_set_time + DEF.SKILL_ACTION_SET_INTERVAL
            try_time = try_time + try_set_time
        end
    end

    return try_ret, try_time
end

function battle_action:action_filter_(target, filters)
    assert(target)
    filters = filters or {}

    for _, filter in ipairs(filters) do
        if (filter.type == "enemy") then
            if ((not target.battle_card) or (not self.caster_:is_enemy(target.battle_card))) then
		        return false
            end
        elseif (filter.type == "ally") then
            if ((not target.battle_card) or (not self.caster_:is_ally(target.battle_card))) then
                return false
            end
        elseif (filter.type == "caster") then
            if (not (self.caster_ == target.battle_card)) then
                return false
            end
        elseif (filter.type == "no_card") then
            if (target.battle_card) then
                return false
            end
        elseif (filter.type == "no_buff") then
            assert(target.battle_card)
            if (target.battle_card:have_buff(filter.buff_ptt)) then
                return false
            end
        else
            assert(false)
        end
    end

    return true
end

function battle_action:try_cast_action_damage_(action)
    local ret = nil
    local time = 0

    action.num = action.num or 1

    for _, target in ipairs(self.targets_) do
        if (self:action_filter_(target, action.filters)) then
            assert(target.battle_card)
            for i = 1, action.num do 
                local try_ret, try_time = target.battle_card:try_take_damage(action.base)
                --action
                try_ret = cc.Sequence:create(cc.DelayTime:create((i-1)*DEF.MULTI_DAMAGE_ZI_INTERVAL), try_ret)
                if (not ret) then
                    ret = try_ret
                else
                    ret = cc.Sequence:create(ret, try_ret)
                end
                --time
                time = math.max(time, try_time + (i-1) * DEF.MULTI_DAMAGE_ZI_INTERVAL)
            end
        end
    end
    
    return ret, time
end

function battle_action:try_cast_action_heal_(action)
    local ret = nil
    local time = 0

    for _, target in ipairs(self.targets_) do
        if (self:action_filter_(target, action.filters)) then
            local try_ret, try_time = target.battle_card:try_take_heal(action.base)
            --action
            if (not ret) then
                ret = try_ret
            else
                ret = cc.Sequence:create(ret, try_ret)
            end
            --time
            time = math.max(time, try_time)
        end
    end
    
    return ret, time
end

function battle_action:try_cast_action_push_(action)
    local time = 0
    local cards = {}
    for _, target in ipairs(self.targets_) do
        if (self:action_filter_(target, action.filters)) then
            table.insert(cards, target.battle_card)
        end
    end

    local push_idxes = self.caster_:get_field_idxes()
    local try_ret, try_time = self.field_:try_push_cards(push_idxes, cards, action.num)
  
    return try_ret, try_time
end

function battle_action:try_cast_action_effect_(action)
    local ret = nil
    local time = 0
    local caster = self.caster_
    local caster_x, caster_y = caster:get_center_pos()
    for _, target in ipairs(self.targets_) do
        if (self:action_filter_(target, action.filters)) then
            local target_x, target_y
            if (target.battle_card) then
                target_x, target_y = target.battle_card:get_center_pos()
            else
                target_x, target_y = self.field_:idxsize_2_center_pos(target.idx, 1)
            end
            --effect arg
            local effect_arg = {}
            if (action.start) then
                if (action.start == "caster") then
                    effect_arg.start_x, effect_arg.start_y = caster_x, caster_y
                elseif (action.start == "target") then
                    assert(target_x and target_y)
                    effect_arg.start_x, effect_arg.start_y = target_x, target_y
                else
                    assert(false)
                end 
            end
            if (action["end"]) then
                if (action["end"] == "caster") then
                    effect_arg.end_x, effect_arg.end_y = caster_x, caster_y
                elseif (action["end"] == "target") then
                    assert(target_x and target_y)
                    effect_arg.end_x, effect_arg.end_y = target_x, target_y
                else
                    assert(false)
                end 
            end

            local battle_field = self.field_
            local create_effect = function()
                                      --effect player
                                      local player = nil
                                      if (action.particle) then
                                          player = cc.ParticleSystemQuad:create(action.particle) 
                                                                        :addTo(battle_field, DEF.Z_BATTLE_FIELD_SKILL_EFFECT)              
                                      elseif (action.sprite) then
                                          player = display.newSprite(action.sprite)
                                                          :addTo(battle_field, DEF.Z_BATTLE_FIELD_SKILL_EFFECT)
                                      elseif (action.caster) then   
                                          player = caster  
                                      elseif (action.target) then   
                                          player = target.battle_card   
                                      else
                                          assert(false)
                                      end

                                      if (action.start) then
                                          if (action.start == "caster") then
                                              player:pos(caster_x, caster_y)
                                          elseif (action.start == "target") then
                                              player:pos(target_x, target_y)
                                          else
                                              assert(false)
                                          end 
                                      end

                                      local sequence = effect(action.effect_cfg, effect_arg)  
                                      if (not action.caster and not action.target) then                     
                                          sequence = cc.Sequence:create(sequence, cc.RemoveSelf:create())
                                      end
                                      player:runAction(sequence)
                                  end

            local _, effect_time = effect(action.effect_cfg, effect_arg)
            local effect_action = cc.CallFunc:create(create_effect)
            if (not ret) then
                ret = effect_action
            else
                ret = cc.Sequence:create(ret, effect_action)
            end
            
            time = math.max(time, effect_time)
        end
    end

    return ret, time
end

function battle_action:try_cast_action_add_trap_(action)
    local ret = nil
    local time = 0

    for _, target in ipairs(self.targets_) do
        if (self:action_filter_(target, action.filters)) then
            local func =    function() 
                                self.field_:add_trap(action.ptt, self.caster_, target.idx)
                            end
            local one_ret = cc.CallFunc:create(func)
            if (not ret) then
                ret = one_ret
            else
                ret = cc.Spawn:create(ret, one_ret)
            end
        end
    end

    return ret, time
end

function battle_action:try_cast_action_add_buff_(action)
    local ret = nil
    local time = 0

    for _, target in ipairs(self.targets_) do
        if (self:action_filter_(target, action.filters)) then
            local func =    function() 
                                target.battle_card:add_buff(self.caster_, action.buff_ptt)
                            end
            local one_ret = cc.CallFunc:create(func)
            if (not ret) then
                ret = one_ret
            else
                ret = cc.Spawn:create(ret, one_ret)
            end
        end
    end

    return ret, time
end

function battle_action:try_cast_action_cast_skill_(action)
    local ret = nil
    local time = 0

    local skill = skill.new(action.skill_ptt)
    local battle_skill = battle_skill.new(skill)
    for _, target in ipairs(self.targets_) do
        if (self:action_filter_(target, action.filters)) then
           ret, time = battle_skill:try_cast(self.caster_, self.field_, nil)
        end
    end

    return ret, time
end

function battle_action:try_cast_action_play_anim_(action)
    local ret = nil
    local time = 0

    for _, target in ipairs(self.targets_) do
        if (self:action_filter_(target, action.filters)) then
            assert(target.battle_card)
            target.battle_card:play_anim(action.anim)
        end
    end

    return ret, time
end

function battle_action:try_cast_action_stop_anim_(action)
    local ret = nil
    local time = 0

    for _, target in ipairs(self.targets_) do
        if (self:action_filter_(target, action.filters)) then
            assert(target.battle_card)
            target.battle_card:stop_anim(action.anim)
        end
    end

    return ret, time
end

return battle_action