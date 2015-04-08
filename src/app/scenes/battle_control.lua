local battle_control = class("battle_control")

local card = import("..game.card")
local scheduler = require("framework.scheduler")

function battle_control:ctor(battle_field, battle_ui, battle_cfg, battle_combat, battle_ai)
    self.field_ = battle_field
    self.ui_ = battle_ui
    self.cfg_ = battle_cfg
    self.combat_ = battle_combat
    self.ai_ = battle_ai
    self.player_ = {}
    self.monsters_ = {}
    self.monster_wave_ = 1
    self.round_count_ = self.cfg_.round_count

    self.listeners_ = {}
    local listener = battle_event:add_listener(battle_event.CARD_DEATH_EVENT, handler(self, self.on_card_death_))
    table.insert(self.listeners_, listener)
end

function battle_control:start()
    self:init_system_()

    self:init_player_()
    self:init_traps_()

    if (not self:init_monsters_()) then
        self:player_win_()
    end

    self:player_move_()
end

function battle_control:init_system_()
    local system_card = card.new("system")
    local system_battle_card = battle_card.new(system_card, CARD_BATTLE_TYPE_SYSTEM)
    self.field_:add_system_card(system_battle_card)

    --second event
    scheduler.scheduleGlobal(handler(self, self.dispatch_second_event_), 1)
end

function battle_control:init_player_()
    local cards = player:get_battle_cards()

    for i, card in ipairs(cards) do
        if (self.cfg_.player_coor[i]) then 
            local battle_card = battle_card.new(card, DEF.CARD_BATTLE_TYPE_PLAYER)
            assert(not self.field_:coor_block_card(self.cfg_.player_coor[i], battle_card))
            table.insert(self.player_, battle_card)
            self.field_:add_card(battle_card, self.cfg_.player_coor[i])
        end
    end
end

function battle_control:init_traps_()
    local wave = self.cfg_.waves[self.monster_wave_]
    if not (wave) then return false end

    local col_num = self.field_:get_col_num()
    local row_num = self.field_:get_row_num()

    self.field_:remove_all_traps()

    for i, v in ipairs(wave.traps) do
        local coor = wave.trap_coor[i]
        self.field_:add_trap_by_coor(v, nil, coor)
    end

    return true
end

function battle_control:init_monsters_()
    local wave = self.cfg_.waves[self.monster_wave_]
    if not (wave) then return false end

    local cards = {}
    local need_idxes_map = {}
    for i, v in ipairs(wave.cards) do
        local card = battle_card.new(card.new(v), DEF.CARD_BATTLE_TYPE_MONSTER)
        local idx = self.field_:coor_2_idx(wave.card_coor[i][1], wave.card_coor[i][2])
        local idxes = self.field_:idxsize_2_idxes(idx, card:get_size())
        for _, idx in ipairs(idxes) do
            need_idxes_map[idx] = true
        end
        table.insert(cards, { card, wave.card_coor[i] })
    end
    local need_idxes = {}
    for k, v in pairs(need_idxes_map) do
        if (v) then
            table.insert(need_idxes, k)
        end
    end

    self.field_:clear_idxes_for_card(need_idxes)

    for i, v in ipairs(cards) do
        local card = v[1]
        local coor = v[2]
        table.insert(self.monsters_, card)
        self.field_:add_card(card, coor)
    end

    self.monster_wave_ = self.monster_wave_ + 1
    return true
end

function battle_control:player_move_()
    self.field_:player_move(handler(self, self.player_start_touch_), handler(self, self.player_touch_end_))
    self.player_moving_ = true

    if (self.cfg_.player_count_down > 0) then
        self.ui_:player_bar(100)
    end
end

function battle_control:player_start_touch_()
    if (self.cfg_.player_count_down > 0) then
        self.player_count_down_ = self.cfg_.player_count_down
        scheduler.performWithDelayGlobal(handler(self, self.player_count_down_tick_), DEF.PLAYER_YIDONG_DAOJISHI_PINLV)
    end
end

function battle_control:player_count_down_tick_()
    self.player_count_down_ = self.player_count_down_ - DEF.PLAYER_YIDONG_DAOJISHI_PINLV
    if (self.player_count_down_ < 0 or (not self.player_moving_)) then
        self:player_touch_end_()
    else
        self.ui_:player_bar(100 * self.player_count_down_ / self.cfg_.player_count_down)
        scheduler.performWithDelayGlobal(handler(self, self.player_count_down_tick_), DEF.PLAYER_YIDONG_DAOJISHI_PINLV)
    end
end

function battle_control:player_touch_end_()
    if (not self.player_moving_) then
        return
    end

    self.player_moving_ = false

    self.ui_:player_bar(0)
    self.field_:player_stop_move() 
    self:player_attack_()
end

function battle_control:player_attack_()
    local alive_attackers = {}
    for _, v in ipairs(self.player_) do
        if (v:can_attack()) then
            table.insert(alive_attackers, v)
        end
    end
    self.combat_:attack(alive_attackers, self.monsters_, handler(self, self.on_player_attack_finished_))
end

function battle_control:on_player_attack_finished_()
    if (self:try_judge()) then return end
    self:monster_move_()
end

function battle_control:monster_move_()
    self.monster_move_idx_ = 0
    
    self:one_monster_move_()
end

function battle_control:one_monster_move_()
    if (self:try_judge()) then return end

    for i, v in ipairs(self.monsters_) do
        if (i > self.monster_move_idx_ and v:can_move()) then
            self.monster_move_idx_ = i
            self.ai_:move(self.monsters_[self.monster_move_idx_], self.players_, handler(self, self.one_monster_attack_))
            
            return
        end
    end

    local action, time = self:process_dead_card_()
    if (action) then
        self.field_:runAction()
    end
    scheduler.performWithDelayGlobal(handler(self, self.monster_done_move_), time)
end

function battle_control:monster_done_move_()
    if (self:try_judge()) then return end
    
    self.round_count_ = self.round_count_ - 1
    if (self.round_count_ == 0) then
        self:player_lose_()
    end
    
    battle_event:dispatch_event(battle_event.TURN_END_EVENT)

    self:player_move_()
end

function battle_control:one_monster_attack_()
    local attackers = {}
    table.insert(attackers, self.monsters_[self.monster_move_idx_])
    self.combat_:attack(attackers, self.player_, handler(self, self.one_monster_move_))
end

function battle_control:try_judge()
    local all_dead = true
    for _, v in ipairs(self.player_) do
        if (not v:is_dead()) then
            all_dead = false
            break
        end
    end

    if (all_dead) then
        self:player_lose_()
        return true
    end

    all_dead = true
    for _, v in ipairs(self.monsters_) do
        if (not v:is_dead()) then
            all_dead = false
            break
        end
    end

    if (all_dead) then
        if (not self:init_monsters_()) then
            self:player_win_()
        else
            scheduler.performWithDelayGlobal(handler(self, self.player_move_), 1)
        end

        return true
    end

    return false
end

function battle_control:dispatch_second_event_()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local event = cc.EventCustom:new(battle_event.SECOND_EVENT)
    eventDispatcher:dispatchEvent(event) 
end

function battle_control:on_card_death_(event)
    local cards = self.monsters_
    if (event.args.card:is_player()) then
        cards = self.player_
    end
    
    for i, card in ipairs(cards) do
        if (card == event.args.card) then
            table.remove(cards, i)
            return
        end
    end
end

function battle_control:process_dead_card_()
    local try_ret = nil
    local try_time = 0

    local dead = {}
    for _, card in ipairs(self.player_) do
        if (card:is_dead()) then
            table.insert(dead, card)
        end
    end
    for _, card in ipairs(self.monsters_) do
        if (card:is_dead()) then
            table.insert(dead, card)
        end
    end

    for _, card in ipairs(dead) do
        local try_one_ret, try_one_time = card:try_do_death()
        if (not try_ret) then
            try_ret = try_one_ret
        else
            try_one_ret = cc.Sequence:create(cc.DelayTime:create(try_time), try_one_ret)
            try_ret = cc.Sequence:create(try_ret, try_one_ret)
        end
        try_time = try_time + try_one_time
    end
    
    return try_ret, try_time
end

function battle_control:player_lose_()
    self.ui_:tip("YOU LOSE...")

    display.replaceScene(select_battle_scene.new())
end

function battle_control:player_win_()
    self.ui_:tip("YOU WIN!")

    display.replaceScene(select_battle_scene.new())
end

return battle_control