local battle_buff = class("battle_buff")

function battle_buff:ctor(caster, ptt, target, field)
    assert(ptt and buff_ptt[ptt])
    self.caster_ = caster
    self.ptt_ = buff_ptt[ptt]
    self.holder_ = target
    self.field_ = field
    self.hp_ = self.ptt_.hp
    self.listeners_ = {}

    if (self.ptt_.on_second) then
        local listener = battle_event:add_listener(battle_event.SECOND_EVENT, handler(self, self.on_second_))
        table.insert(self.listeners_, listener)
        listener = battle_event:add_listener(battle_event.TURN_END_EVENT, handler(self, self.on_turn_end_))
        table.insert(self.listeners_, listener)
    end
end

function battle_buff:ptt_is(ptt)
    return self.ptt_ == buff_ptt[ptt]
end

function battle_buff:is_dead()
    return self.hp_ <= 0
end

function battle_buff:is_enemy(battle_card)
    return self.caster_:is_enemy(battle_card)
end

function battle_buff:is_ally(battle_card)
    return self.caster_:is_ally(battle_card)
end

function battle_buff:get_field_idxes()
    return self.holder_:get_field_idxes()
end

function battle_buff:get_center_pos()
    return self.holder_:get_center_pos()
end

function battle_buff:on_second_()
    if (self.ptt_.on_second) then
        self:try_cast_actions_(self.ptt_.on_second)
    end
end

function battle_buff:on_turn_end_()
    if (self.ptt_.on_turn_end) then
        self:try_cast_actions_(self.ptt_.on_turn_end)
    end

    self.hp_ = self.hp_ - 1
    if (self.hp_ <= 0) then
        battle_event:dispatch_event(battle_event.BUFF_DEATH_EVENT, { buff = self })
        self:destroy()
    end
end

function battle_buff:on_move()
    if (self.ptt_.on_move) then
        self:try_cast_actions_(self.ptt_.on_move)
    end
end

function battle_buff:on_add()
    if (self.ptt_.on_add) then
        self:try_cast_actions_(self.ptt_.on_add)
    end
end

function battle_buff:on_remove()
    if (self.ptt_.on_remove) then
        self:try_cast_actions_(self.ptt_.on_remove)
    end

    self:destroy()
end

function battle_buff:destroy()
    for _, listener in ipairs(self.listeners_) do
        battle_event:remove_listener(listener)
    end
end

function battle_buff:try_cast_actions_(action_sets)
    if (action_sets) then
        local action_targets = { { battle_card = self.holder_, idx = self.holder_:get_field_idx() } }
        local try_ret, try_time = battle_action.new(self, self.field_, action_targets, action_sets):try_cast_actions()
        if (try_ret) then
            self.field_:runAction(try_ret)
        end
    end
end

return battle_buff