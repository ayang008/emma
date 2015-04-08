local battle_combat = class("battle_combat")

local scheduler = require("framework.scheduler")

function battle_combat:ctor(battle_field, bottle_ui)
    self.field_ = battle_field
    self.ui_ = bottle_ui
end

function battle_combat:attack(attackers, defenders, on_finish_cb)
    self.on_finish_cb_ = on_finish_cb
    self.attackers_ = attackers
    self.defenders_ = defenders
    self.cur_oreo_ = nil
    self.attacked_oreos_ = {}
    self.oreo_attackers_ = {}
    for i = #self.attackers_, 1, -1 do
        table.insert(self.oreo_attackers_, self.attackers_[i])
    end

    self.listeners_ = {}
    local listener = battle_event:add_listener(battle_event.CARD_DEATH_EVENT, handler(self, self.on_card_death_))
    table.insert(self.listeners_, listener)

    self:try_find_new_oreo_()
    if (self.cur_oreo_) then
        self:oreo_attack_()
    else
        self.on_finish_cb_()
    end
end

function battle_combat:on_card_death_(event)
    for i, card in ipairs(self.attackers_) do
        if (card == event.args.card) then
            table.remove(self.attackers_, i)
            return
        end
    end

    for i, card in ipairs(self.defenders_) do
        if (card == event.args.card) then
            table.remove(self.defenders_, i)
            return
        end
    end
end

function battle_combat:oreo_attacked(oreo)
    for _, attacked_oreo in ipairs(self.attacked_oreos_) do
        if (oreo:is_identical(attacked_oreo)) then
            return true
        end
    end

    return false
end

function battle_combat:try_find_new_oreo_()
    assert(not self.cur_oreo_)
    local attacker = self.oreo_attackers_[#self.oreo_attackers_]
    local found_oreos = self.field_:find_oreos({ attacker })
    for _, oreo in ipairs(found_oreos) do
        if (not self:oreo_attacked(oreo)) then
            self.cur_oreo_ = oreo
            break
        end
    end

    if (not self.cur_oreo_) then
        table.remove(self.oreo_attackers_, #self.oreo_attackers_)
        if (next(self.oreo_attackers_)) then
            self:try_find_new_oreo_()
        end
    end
end

function battle_combat:oreo_try_cast_skill_()
    self.oreo_try_cast_skill_num_ = 1
    local time = 0

    local longest_time = 0
    local attackers = self.cur_oreo_:get_attacker_cards()
    for _, attacker in ipairs(attackers) do
        longest_time = math.max(longest_time, self:battle_card_try_attack(attacker, self.cur_oreo_.enemies, time))
    end
    time = time + longest_time

    longest_time = 0
    for _, attacker in ipairs(attackers) do
        local link = self.cur_oreo_:find_same_link_cards(attacker)
        for _, card in ipairs(link) do
            if (card ~= attacker) then
                self.oreo_try_cast_skill_num_ = self.oreo_try_cast_skill_num_ + 1
                longest_time = math.max(longest_time, self:battle_card_try_attack(card, self.cur_oreo_.enemies, time))  
                time = time + longest_time
            end       
        end
    end

    return time
end

function battle_combat:oreo_attack_()
    assert(self.cur_oreo_)
    self.cur_attack_skills_ = {}
    self.cur_heal_skills_ = {}

    local time = self:oreo_try_cast_skill_()
     
    scheduler.performWithDelayGlobal(handler(self, self.oreo_attack_big_sprite_effect_), time)
end

function battle_combat:oreo_cast_attack_skill_()
    local time = 0
    for _, v in ipairs(self.cur_attack_skills_) do
        local show_time = v[1]:show_attack(v[2])
        local try_ret, try_time = v[2]:try_cast(v[1], self.field_, self.cur_oreo_)
        try_time = try_time + show_time
        try_ret = cc.Sequence:create(cc.DelayTime:create(show_time), try_ret)
        self.field_:runAction(try_ret)
        time = math.max(time, try_time)
    end
    self.cur_attack_skills_ = {}

    scheduler.performWithDelayGlobal(handler(self, self.remove_dead_), time + DEF.SKILL_AFTER_OREO_PAUSE)
end

function battle_combat:oreo_cast_heal_skill_()
    local time = 0
    for _, v in ipairs(self.cur_heal_skills_) do
        v[1]:show_attack(v[2], 0)
        local try_ret, try_time = v[2]:try_cast(v[1], self.field_, self.cur_oreo_)
        self.field_:runAction(try_ret)
        time = math.max(time, try_time)
    end
    self.cur_heal_skills_ = {}

    scheduler.performWithDelayGlobal(handler(self, self.one_oreo_attacks_finish_), time + DEF.SKILL_AFTER_OREO_PAUSE)
end

function battle_combat:battle_card_try_attack(attacker, enemies, time)
    local skills = attacker:get_skills()
    
    local longest_time = 0
    local ret_skills = {}
    for _, skill in ipairs(skills) do
        local try_ret, try_time = skill:try_cast(attacker, self.field_, self.cur_oreo_)
        if (try_ret) then
            table.insert(ret_skills, skill)
            if (skill:has_tag("buff")) then
                self.field_:runAction(cc.Sequence:create(cc.DelayTime:create(time), try_ret))
                longest_time = math.max(longest_time, try_time)
            elseif (skill:has_tag("attack")) then
                table.insert(self.cur_attack_skills_, {attacker, skill})
            elseif (skill:has_tag("heal")) then
                table.insert(self.cur_heal_skills_, {attacker, skill})
            else
                assert(false)
            end
        end
    end

    if (next(ret_skills)) then
        longest_time = math.max(longest_time, attacker:show_skill(ret_skills, time))
    end
    longest_time = math.max(longest_time, attacker:oreo_try_attack(time, self.oreo_try_cast_skill_num_))

    return longest_time
end

function battle_combat:remove_dead_()
    local try_ret = nil
    local try_time = 0

    for i = #self.attackers_, 1, -1 do
        if (self.attackers_[i]:is_dead()) then
            local try_one_ret, try_one_time = self.attackers_[i]:try_do_death()
            if (not try_ret) then
                try_ret = try_one_ret
            else
                try_one_ret = cc.Sequence:create(cc.DelayTime:create(try_time), try_one_ret)
                try_ret = cc.Sequence:create(try_ret, try_one_ret)
            end
            try_time = try_time + try_one_time
        end
    end

    for i = #self.defenders_, 1, -1 do
        if (self.defenders_[i]:is_dead()) then
            local try_one_ret, try_one_time = self.defenders_[i]:try_do_death()
            if (not try_ret) then
                try_ret = try_one_ret
            else
                try_one_ret = cc.Sequence:create(cc.DelayTime:create(try_time), try_one_ret)
                try_ret = cc.Sequence:create(try_ret, try_one_ret)
            end
            try_time = try_time + try_one_time
        end
    end

    if (try_ret) then
        self.field_:runAction(try_ret)
    end

    scheduler.performWithDelayGlobal(handler(self, self.oreo_cast_heal_skill_), try_time)
end

function battle_combat:one_oreo_attacks_finish_()
    table.insert(self.attacked_oreos_, self.cur_oreo_)
    self.cur_oreo_ = nil

    self:try_find_new_oreo_()
    if (not self.cur_oreo_) then
        self.on_finish_cb_()
    else
        self:oreo_attack_()
    end
end

function battle_combat:oreo_attack_damage_()
    local longest_time = 0
    local defenders = self.cur_oreo_:get_defenders()
    for _, defender in ipairs(defenders) do
        local try_ret, try_time = defender:try_take_damage(100)
        self.field_:runAction(try_ret)
        longest_time = math.max(longest_time, try_time)
    end

    scheduler.performWithDelayGlobal(handler(self, self.oreo_cast_attack_skill_), longest_time + DEF.SKILL_AFTER_OREO_PAUSE)
end

function battle_combat:oreo_attack_big_sprite_effect_()
    local attackers = self.cur_oreo_:get_attacker_cards()

    for i, battle_card in ipairs(attackers) do
        local dir = self.cur_oreo_:get_attacker_dir(battle_card)
        local x, y = battle_card:getPosition()
        --default as dir up
        local offset = 0.2
        if (i % 2 == 0) then offset = -0.2 end

        local start_x, start_y, pause_x, pause_y, end_x, end_y
        local vertical_limit_x = function(x)
            left_bound = DEF.BIG_SPRITE_X_LEFT_BOUND * display.width
            right_bound = DEF.BIG_SPRITE_X_RIGHT_BOUND * display.width
            if (x < left_bound) then
                return left_bound
            elseif (x > right_bound) then
                return right_bound
            end
            return x
        end
        local horizontal_limit_y = function(y)
            upper_bound = DEF.BIG_SPRITE_Y_UPPER_BOUND * display.height
            lower_bound = DEF.BIG_SPRITE_Y_LOWER_BOUND * display.height
            if (y < lower_bound) then
                return lower_bound
            elseif (y > upper_bound) then
                return upper_bound
            end
            return y
        end 

        if (dir == DEF.BATTLE_FIELD_DIR_UP) then
            x = vertical_limit_x(x + display.width * offset)
        elseif (dir == DEF.BATTLE_FIELD_DIR_DOWN) then
            x = vertical_limit_x(x + display.width * offset)
        elseif (dir == DEF.BATTLE_FIELD_DIR_LEFT) then
            y = horizontal_limit_y(y + display.height * offset)
        elseif (dir == DEF.BATTLE_FIELD_DIR_RIGHT) then
            y = horizontal_limit_y(y + display.height * offset)
        else 
            assert(false)
        end

        local sprite = battle_card:get_big_sprite()
        sprite:setPosition(x, y)
        battle_card:big_play_oreo(dir)
    end

    scheduler.performWithDelayGlobal(handler(self, self.oreo_attack_damage_), 1)
end


return battle_combat