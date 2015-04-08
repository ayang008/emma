local battle_card = class("battle_card", function()
    return display.newNode()
end)

local anim = import("..res.anim_cfg")
local icon_label = import("..ui.icon_label")
local icon_label_window = import("..ui.icon_label_window")

function battle_card:ctor(card, type)
    self.card_ = card
    self.type_ = type or DEF.CARD_BATTLE_TYPE_SYSTEM
    self.max_hp_ = card:get_max_hp()
    self.hp_ = self.max_hp_
    self.buffs_ = {}
    self.listeners_ = {}

    --small card
    self.sprite_ = ccs.Armature:create(anim.small_card_anim):addTo(self)
    local sprite = ccs.Skin:create(card:get_image())
    self.sprite_:getBone(anim.small_card_main_bone):addDisplay(sprite, 0)
    self.sprite_:getBone(anim.small_card_main_bone):changeDisplayWithIndex(0, true)

    local size = sprite:getContentSize()                         

    --blood pic
    local blood_pic = pic.card_xuetiao_enemy
    if (self.type_ == DEF.CARD_BATTLE_TYPE_PLAYER) then
        blood_pic = pic.card_xuetiao
    end
    self.blood_ = cc.ui.UILoadingBar.new({
                    image = blood_pic,
                    percent = 100,
                    viewRect = cc.rect(size.width * 0.2, size.height * 0.2, size.width * 0.6, size.height * 0.6),
                    direction = cc.ui.UILoadingBar.DIRECTION_LEFT_TO_RIGHT,
                })
                :pos(-size.width * 0.5, -size.height * 0.4)
                :addTo(self.sprite_, DEF.Z_BATTLE_CARD_XUETIAO)
            
    --big card
    self.big_sprite_ = ccs.Armature:create(anim.big_card_anim)
    sprite = ccs.Skin:create(card:get_big_image())
    self.big_sprite_:getBone(anim.big_card_main_bone):addDisplay(sprite, 0)
    self.big_sprite_:getBone(anim.big_card_main_bone):changeDisplayWithIndex(0, true)
    self.big_sprite_:setVisible(false)
    self.big_sprite_:getAnimation():setMovementEventCallFunc(function(arm, event, movement)
                                                                if event == ccs.MovementEventType.complete then
                                                                    arm:setVisible(false)
                                                                end
                                                             end)
    
    --battle skills
    self.battle_skills_ = {}
    local skills = self.card_:get_skills()
    for _, v in ipairs(skills) do
        table.insert(self.battle_skills_, battle_skill.new(v))
    end

    --listen turn end event
    local listener = battle_event:add_listener(battle_event.BUFF_DEATH_EVENT, handler(self, self.on_buff_death_))
    table.insert(self.listeners_, listener)
end

function battle_card:add_buff(caster, ptt)
    assert(caster and ptt)
    
    local buff = battle_buff.new(caster, ptt, self, self.field_)
    table.insert(self.buffs_, buff)
    buff:on_add()
end

function battle_card:on_buff_death_(event)
    for i, v in ipairs(self.buffs_) do
        if (v == event.args.buff) then
            v:on_remove()
            table.remove(self.buffs, i)
            return
        end
    end
end

function battle_card:new_big_sprite()
    return display.newSprite(self.card_:get_big_image())
end

function battle_card:new_sprite()
    return display.newSprite(self.card_:get_image())
end

function battle_card:is_player()
    return self.type_ == DEF.CARD_BATTLE_TYPE_PLAYER
end

function battle_card:is_monster()
    return self.type_ == DEF.CARD_BATTLE_TYPE_MONSTER
end

function battle_card:try_do_death()
    local func = function()
        local node_grid = cc.NodeGrid:create()
        local sprite = self:new_sprite()
        sprite:addTo(node_grid)
        node_grid:addTo(self.field_)
                 :pos(self:get_center_pos())
        action = cc.SplitRows:create(5, 4096)
        action = cc.Sequence:create(action, cc.RemoveSelf:create())
        node_grid:runAction(action)
        local sprite_action, time = effect("card_died")
        sprite:runAction(sprite_action)

        battle_event:dispatch_event(battle_event.CARD_DEATH_EVENT, { card = self })
        self:destroy()
    end

    local _, try_time = effect("card_died")
    local try_ret = cc.Sequence:create(cc.CallFunc:create(func))
    return try_ret, try_time
end

function battle_card:active_move(to_idx, time)
    local x, y = self.field_:idxsize_2_center_pos(to_idx, self:get_size())
    local action = cc.Sequence:create(cc.DelayTime:create(time), cc.MoveTo:create(DEF.ACTIVE_MOVE_ONE_GRID_SECOND, cc.p(x, y)))
    self:runAction(action)
    return DEF.ACTIVE_MOVE_ONE_GRID_SECOND
end

function battle_card:swap_move(to_idx, time)
    local x, y = self.field_:idxsize_2_center_pos(to_idx, self:get_size())
    local action = cc.Sequence:create(cc.DelayTime:create(time), cc.MoveTo:create(DEF.SWAP_MOVE_ONE_GRID_SECOND, cc.p(x, y)))
    self:runAction(action)
    return DEF.SWAP_MOVE_ONE_GRID_SECOND
end

function battle_card:pushed_move(to_idx, time)
    self.sprite_:getAnimation():play(anim.small_card_pushed_away)
    local x, y = self.field_:idxsize_2_center_pos(to_idx, self:get_size())
    local action = cc.Sequence:create(cc.DelayTime:create(time), cc.MoveTo:create(DEF.PUSHED_MOVE_ONE_GRID_SECOND, cc.p(x, y)))
    self:runAction(action)
    return DEF.PUSHED_MOVE_ONE_GRID_SECOND
end

function battle_card:try_pushed_move(path)
    local func =    function()
                        local action = nil
                        local time = DEF.SKILL_PUSHED_MOVE_SECOND / #path
                        for _, idx in ipairs(path) do
                            local x, y = self.field_:idxsize_2_center_pos(idx, self:get_size())

                            if (not action) then
                                action = cc.Spawn:create(cc.RotateBy:create(time, 720), cc.MoveTo:create(time, cc.p(x, y)))
                            else
                                action = cc.Sequence:create(action, cc.Spawn:create(cc.RotateBy:create(time, 360), cc.MoveTo:create(time, cc.p(x, y))))
                            end
                        end
                        self:runAction(action)
                    end
    return cc.CallFunc:create(func), DEF.SKILL_PUSHED_MOVE_SECOND
end

function battle_card:adjust_big_sprite_pos_(big_sprite, x, y)
    local content_size = big_sprite:getContentSize()
    x_to_c = display.cx - x
    y_to_c = display.cy - y

    x_to_c = x_to_c * content_size.width / display.width
    y_to_c = y_to_c * content_size.height / display.height

    x = display.cx - x_to_c
    y = display.cy - y_to_c

    return x, y
end

function battle_card:show_attack(skill)
    local msg = nil
    local color = nil
    if (skill:has_tag("attack")) then
        msg = "攻击技能"
        color = DEF.COLOR_RED
    elseif (skill:has_tag("heal")) then
        msg = "恢复技能"
        color = DEF.COLOR_GREEN
    else
        assert(false)
    end

    local x, y = self.field_:idxsize_2_center_pos(self:get_field_idx(), self:get_size())
    local lable = display.newTTFLabel({
                                       UILabelType = 2,
                                       text = msg,
                                       size = DEF.SKILL_TIP_ZI_SIZE,
                                       x = x,
                                       y = y,
                                       color = color,
                                       align = cc.ui.TEXT_ALIGN_CENTER
                                      })
                                      :addTo(self.field_, DEF.Z_BATTLE_FIELD_CARD_SHOW_SKILL)  
    lable:setScale(0.2)
    local effect, effect_time = effect("battle_field_show_attack")
    effect = cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(display.cx, display.cy)), effect)
    effect = cc.Sequence:create(effect, cc.RemoveSelf:create())
    lable:runAction(effect)

    return effect_time
end

function battle_card:try_show_death()
    local func = function()
        local node_grid = cc.NodeGrid:create()
        local sprite = self:new_sprite()
        sprite:addTo(node_grid)
        node_grid:addTo(self.field_)
                 :pos(self:get_center_pos())
        action = cc.SplitRows:create(5, 4096)
        action = cc.Sequence:create(action, cc.RemoveSelf:create())
        node_grid:runAction(action)
        local sprite_action, time = effect("card_died")
        sprite:runAction(sprite_action)
    end

    local _, try_time = effect("card_died")
    local try_ret = cc.Sequence:create(cc.CallFunc:create(func))
    return try_ret, try_time
end

function battle_card:show_skill(skills, delay)
    local action = effect("battle_card_show_skill")
    local x, y = self:get_center_pos()
    
    local big_sprite = self:new_big_sprite():addTo(self.field_, DEF.Z_BATTLE_FIELD_BIG_SPRITE)
    big_sprite:setOpacity(0)
    big_sprite:setScale(DEF.CARD_SHOW_SKILL_SPRITE_SCALE_FROM)

    local labels = {}
    for _, skill in ipairs(skills) do
        table.insert(labels, icon_label.new(skill:get_icon(), skill:get_name(), DEF.SKILL_TIP_ZI_SIZE))
    end
    local label_window = icon_label_window.new():addTo(big_sprite)
                                                :pos(big_sprite:getContentSize().width/2, 0)
    label_window:set_labels(labels)

    x, y = self:adjust_big_sprite_pos_(big_sprite, x, y)
    big_sprite:pos(x, y)

    action = cc.Sequence:create(cc.DelayTime:create(delay), action)
    action = cc.Sequence:create(action, cc.RemoveSelf:create())
    big_sprite:runAction(action)
end

function battle_card:player_picked()
    local x, y = self.field_:idxsize_2_center_pos(self:get_field_idx(), self:get_size())
    self.edge_sprite_ = display.newScale9Sprite(pic.zhan_chang_ge_zi_yidong)
    local width = DEF.BATTLE_FIELD_GRID_WIDTH * 1.15
    local height = DEF.BATTLE_FIELD_GRID_WIDTH * 1.15
    self.edge_sprite_:addTo(self.sprite_)
                     :pos(0, 0)

    self.edge_sprite_:setContentSize(width, height)

    local sequence = transition.sequence({ cc.ScaleTo:create(0.5, 1.1), 
                                           cc.ScaleTo:create(0.5, 1), })
    local repeat_forever = cc.RepeatForever:create(sequence)
    self.edge_sprite_:runAction(repeat_forever)
end

function battle_card:player_no_more_picked()
    self:pos(self:get_center_pos())
    if (self.edge_sprite_) then
        self.edge_sprite_:removeSelf()
        self.edge_sprite_ = nil
    end
end

function battle_card:oreo_try_attack(delay, num)
    local x, y = self.field_:idxsize_2_center_pos(self:get_field_idx(), self:get_size())
    local label = display.newTTFLabel({
                                       UILabelType = 2,
                                       text = string.format("进攻 %d", num),
                                       size = DEF.OREO_TRY_ATTACK_ZI_SIZE,
                                       x = x,
                                       y = y,
                                       color = COLOR_YELLOW,
                                       align = cc.ui.TEXT_ALIGN_CENTER
                                      })
                                      :addTo(self.field_, DEF.Z_BATTLE_CARD_OREO_MULTI)
    label:setScale(0.2) 
    local label_effect, label_effect_time = effect("battle_card_oreo_try_attack")
    label_effect = cc.Sequence:create(cc.DelayTime:create(delay), label_effect)
    label_effect = cc.Sequence:create(label_effect, cc.RemoveSelf:create())
    label:runAction(label_effect)

    local card_effect, card_effect_time = effect("skill_caster_bounce")
    card_effect = cc.Sequence:create(cc.DelayTime:create(delay), card_effect)
    self.sprite_:runAction(card_effect)
    return math.max(card_effect_time, label_effect_time)
end

function battle_card:linked()
    if (self.link_action_) then
        self:no_more_linked()
    end

    self.link_action_ = effect("link_card")
    self.sprite_:runAction(self.link_action_)
end

function battle_card:no_more_linked()
    self.sprite_:stopAction(self.link_action_)
    self.link_action_ = nil

    --(TODO)tmp solve the swap move problem
    if (self.sprite_:getNumberOfRunningActions() <= 0) then
        self.sprite_:pos(0, 0)
    end
end

function battle_card:big_play_oreo(dir)
    self.big_sprite_:setVisible(true)
    --(TODO) remove this when global speed scale is provided
    self.big_sprite_:getAnimation():setSpeedScale(0.5)
    if (dir == DEF.BATTLE_FIELD_DIR_UP) then
        self.big_sprite_:getAnimation():play(anim.big_card_oreo_up)
    elseif (dir == DEF.BATTLE_FIELD_DIR_DOWN) then
        self.big_sprite_:getAnimation():play(anim.big_card_oreo_down)
    elseif (dir == DEF.BATTLE_FIELD_DIR_LEFT) then
        self.big_sprite_:getAnimation():play(anim.big_card_oreo_left)
    elseif (dir == DEF.BATTLE_FIELD_DIR_RIGHT) then
        self.big_sprite_:getAnimation():play(anim.big_card_oreo_right)
    end
end

function battle_card:play_anim(anim)
    self.sprite_:getAnimation():play(anim)
end

function battle_card:stop_anim(anim)
    self.sprite_:getAnimation():stop()
    self.sprite_:pos(0, 0)
end

function battle_card:can_move()
    return not self:is_dead()
end

function battle_card:can_attack()
    return not self:is_dead()
end

function battle_card:can_push(pushed)
    return true
end

function battle_card:is_dead()
    return self.hp_ <= 0
end

function battle_card:head_jump_msg_(msg, color)
    assert(msg)

    local x, y = self.field_:idxsize_2_center_pos(self:get_field_idx(), self:get_size())
    local lable = display.newTTFLabel({
                                        UILabelType = 2,
                                        text = msg,
                                        size = DEF.CARD_HEAD_JUMP_MSG_ZI_SIZE,
                                        x = x,
                                        y = y,
                                        color = color,
                                        align = cc.ui.TEXT_ALIGN_CENTER
                                    })
                                    :addTo(self.field_, DEF.Z_BATTLE_CARD_HEAD_JUMP_MSG)  
    local effect = effect("battle_card_head_msg")                        
    local sequence = cc.Sequence:create(effect, cc.RemoveSelf:create())
    lable:runAction(sequence)
end

function battle_card:try_take_damage(value)
    local func =    function()
                        self.hp_ = self.hp_ - value
                        if (self.hp_ < 0) then 
                            self.hp_ = 0
                        end

                        self.blood_:setPercent(self.hp_ * 100 / self.max_hp_)
                        local sequence = effect("battle_card_damaged")
                        self.sprite_:runAction(sequence)
                        self:head_jump_msg_(tostring(value), DEF.COLOR_RED)
                    end
    local _, msg_time = effect("battle_card_head_msg")
    local _, card_time = effect("battle_card_damaged")
    return cc.CallFunc:create(func), math.max(msg_time, card_time)
end

function battle_card:try_take_heal(value)
    local func =    function()
                        local old_hp = self.hp_
                        self.hp_ = self.hp_ + value
                        if (self.hp_ > self.max_hp_) then 
                            self.hp_ = self.max_hp_
                        end

                        self.blood_:setPercent(self.hp_ * 100 / self.max_hp_)
                        self:head_jump_msg_(tostring(self.hp_ - old_hp), DEF.COLOR_GREEN)
                    end

    local _, time = effect("battle_card_head_msg")
    return cc.CallFunc:create(func), time
end

function battle_card:is_ally(another)
    if (another == nil) then 
        return false 
    end
    return self.type_ == another.type_
end

function battle_card:is_enemy(another)
    if (another == nil) then 
        return false 
    end
    return self.type_ ~= another.type_
end


function battle_card:get_skills()
    return self.battle_skills_
end

function battle_card:get_buffs()
    return self.buffs_
end

function battle_card:have_buff(ptt)
    for _, buff in ipairs(self.buffs_) do
        if (buff:ptt_is(ptt)) then
            return true
        end
    end
    return false
end

function battle_card:get_sprite_pos()
    return self.sprite_:getPosition()
end

function battle_card:get_big_sprite()
    return self.big_sprite_
end

function battle_card:get_size()
    return self.card_:get_size()
end

function battle_card:set_field(field, idx)
    assert(not self.field_ and field and idx)
    self.field_idx_ = idx
    self:pos(field:idxsize_2_center_pos(self:get_field_idx(), self:get_size()))
    self:addTo(field, DEF.Z_BATTLE_FIELD_CARD)
    self.big_sprite_:addTo(field, DEF.Z_BATTLE_FIELD_BIG_SPRITE)
    self.field_ = field
end

function battle_card:set_field_idx(idx)
    self.field_idx_ = idx
end

function battle_card:get_field_idx()
    return self.field_idx_
end

function battle_card:get_field_idxes()
    return self.field_:idxsize_2_idxes(self:get_field_idx(), self:get_size())
end

function battle_card:get_center_pos()
    return self.field_:idxsize_2_center_pos(self:get_field_idx(), self:get_size())
end

function battle_card:destroy()
    assert(self.field_)
    self.sprite_:removeSelf()
	self.big_sprite_:removeSelf()
    for _, listener in ipairs(self.listeners_) do
        battle_event:remove_listener(listener)
    end
    self:removeSelf()
end

return battle_card