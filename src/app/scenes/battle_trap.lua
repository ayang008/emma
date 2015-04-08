local battle_trap = class("battle_trap", function()
    return display.newNode()
end)

function battle_trap:ctor(ptt, caster, field, idx)
    assert(trap_ptt[ptt])
    self.ptt_ = trap_ptt[ptt]
    self.hp_ = self.ptt_.life
    self.caster_ = caster
    self.sprite_ = display.newSprite(self.ptt_.image):addTo(self)
    self.field_ = field
    self.field_idx_ = idx
    self:pos(field:idxsize_2_center_pos(self.field_idx_, 1))
	    :addTo(field, DEF.Z_BATTLE_FIELD_TRAP_SPRITE)
    self.listeners_ = {}
    local listener = battle_event:add_listener(battle_event.CARD_DEATH_EVENT, handler(self, self.on_card_death_))
    table.insert(self.listeners_, listener)
    listener = battle_event:add_listener(battle_event.TURN_END_EVENT, handler(self, self.on_turn_end_))
    table.insert(self.listeners_, listener)
    listener = battle_event:add_listener(battle_event.CARD_TOUCH_GRID_EVENT, handler(self, self.on_card_touch_grid_))
    table.insert(self.listeners_, listener)
end

function battle_trap:destroy()
    assert(self.field_)
    self.field_ = nil
    self.field_idx_ = nil
    self.sprite_:removeSelf()
    for _, listener in ipairs(self.listeners_) do
        battle_event:remove_listener(listener)
    end
end

function battle_trap:on_card_death_(event)
    if (event.args.card == self.caster_) then
        self:do_death()
    end
end

function battle_trap:on_turn_end_()
    local action_sets = self.ptt_.on_turn_end
    if (action_sets) then
        local card = self.field_:get_idx_card(self.field_idx_)
        if (card) then
            local action_targets = { { battle_card = card, idx = card:get_field_idx() } }
            if (action_sets) then
                local try_ret, try_time = battle_action.new(self, self.field_, action_targets, action_sets):try_cast_actions()
                if (try_ret) then
                    self.field_:runAction(try_ret)
                end
            end
        end
    end
    self.hp_ = self.hp_ - 1
    if (self.hp_ <= 0) then
        self:do_death()
    end
end

function battle_trap:is_enemy(battle_card)
    return self.caster_:is_enemy(battle_card)
end

function battle_trap:is_ally(battle_card)
    return self.caster_:is_ally(battle_card)
end

function battle_trap:get_field_idx()
    return self.field_idx_
end

function battle_trap:get_field_idxes()
    return { self.field_idx_ }
end

function battle_trap:get_center_pos()
    return self.field_:idxsize_get_center_pos(self.field_idx_, 1)
end

function battle_trap:on_card_touch_grid_(event)
    if (event.args.grid_idx == self:get_field_idx()) then
        local action_sets = self.ptt_.on_card_move_to
        local action_targets = { { battle_card = event.args.card, event.args.grid_idx } }
        if (action_sets) then
            local try_ret, try_time = battle_action.new(self, self.field_, action_targets, action_sets):try_cast_actions()
            if (try_ret) then
                self.field_:runAction(try_ret)
            end
        end
    end
end

function battle_trap:do_death()
    battle_event:dispatch_event(battle_event.TRAP_DEATH_EVENT, { trap = self })
    self:destroy()
end

return battle_trap