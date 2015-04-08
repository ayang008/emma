local battle_field = class("battle_field", function()
    return display.newLayer()
end)

local card = import("..game.card")
local trap_ptt = import("..res.trap_prototype")

function battle_field:ctor(col_num, row_num, grid_width, x_offset, y_offset, battle_ui, system_card)
	self.col_num_ = col_num
	self.row_num_ = row_num
    self.grid_num_ = col_num * row_num
	self.grid_width_ = grid_width
	self.cx_ = display.cx + x_offset
	self.cy_ = display.cy + y_offset
	self.ui_ = battle_ui
	self.width_ = self.col_num_ * self.grid_width_
	self.height_ = self.row_num_ * self.grid_width_
	self.lbx_ = self.cx_ - self.width_ / 2
    self.lby_ = self.cy_ - self.height_ / 2
    self.cards_ = {}
    self.link_sprites_ = {}
    self.linked_cards_ = {}

    self.traps_ = {}
	self.grids_ = {}
	for col = 1, self.col_num_ do
		for row = 1, self.row_num_ do
			local idx = self:coor_2_idx(col, row)
			self.grids_[idx] = {}
			self.grids_[idx].cx_ = self.cx_ - (self.col_num_ / 2 - col + 0.5) * self.grid_width_
			self.grids_[idx].cy_ = self.cy_ - (self.row_num_ / 2 - row + 0.5) * self.grid_width_
            self.grids_[idx].traps_ = {}
    		display.newScale9Sprite(pic.zhan_chang_ge_zi)
		                :pos(self.grids_[idx].cx_, self.grids_[idx].cy_)
		                :addTo(self, DEF.Z_BATTLE_FIELD_GEZI)
                        :setContentSize(grid_width + DEF.BATTLE_FIELD_GRID_ADJUST, grid_width + DEF.BATTLE_FIELD_GRID_ADJUST)
		end
	end

	self:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, handler(self, self.on_player_touch_))

    self.listeners_ = {}
    local listener = battle_event:add_listener(battle_event.TRAP_DEATH_EVENT, handler(self, self.on_trap_death_))
    table.insert(self.listeners_, listener)
    listener = battle_event:add_listener(battle_event.CARD_DEATH_EVENT, handler(self, self.on_card_death_))
    table.insert(self.listeners_, listener)
end

function battle_field:get_grid_num()
	return self.grid_num_
end

function battle_field:get_col_num()
	return self.col_num_
end

function battle_field:get_row_num()
	return self.row_num_
end

function battle_field:get_grid_width()
	return self.grid_width_
end

function battle_field:idxsize_2_center_pos(idx, size)
	assert(self:idx_is_valid_(idx) and size)

	if (size == 1) then
		return self.grids_[idx].cx_, self.grids_[idx].cy_
	elseif (size == 2) then
		return 	self.grids_[idx].cx_ + self.grid_width_ / 2, 
				self.grids_[idx].cy_ - self.grid_width_ / 2
	else
		assert(false)
	end
end

function battle_field:idxsize_2_idxes(idx, size)
	assert(self:idx_is_valid_(idx) and (size == 1 or size == 2) )
	local ret = {}
	table.insert(ret, idx)
	if (size == 2) then
		local dirs = { DEF.BATTLE_FIELD_DIR_DOWN, DEF.BATTLE_FIELD_DIR_RIGHT, DEF.BATTLE_FIELD_DIR_DOWNRIGHT }
		for _, dir in ipairs(dirs) do
			local idx2 = self:next_idx_(idx, dir)
			if (not idx2) then
				return nil
			else
				table.insert(ret, idx2)
			end
		end
	end
	return ret
end

function battle_field:add_system_card(system_card)
    self.system_card_ = system_card:addTo(self)
    self.system_card_:setVisible(false)
end

function battle_field:add_card(card, coor)
	local idx = self:coor_2_idx(coor[1], coor[2])
	assert(idx and (not self:get_idx_card(idx)))
	local size = card:get_size()
	local idxes = self:idxsize_2_idxes(idx, size)
	assert(idxes)
	card:set_field(self, idx)
	for _, v in ipairs(idxes) do
		assert(not self:get_idx_card(v))
		self:set_idx_card_(v, card)
	end
	table.insert(self.cards_, card)
end

function battle_field:on_card_death_(event)
    for _, card in ipairs(self.cards_) do
        if (card == event.args.card) then
	        local idxes = card:get_field_idxes()
	        assert(idxes)

	        for _, v in ipairs(idxes) do
		        self:set_idx_card_(v, nil)
	        end
            return
        end
    end
end

function battle_field:clear_idxes_for_card(idxes)
    local clear_idxes_map = {}
    for _, idx in ipairs(idxes) do
        clear_idxes_map[idx] = true
    end

    for _, idx in ipairs(idxes) do
        local card = self:get_idx_card(idx)
        if (card) then
            local success = false
            local card_idx = card:get_field_idx()    
            local card_idxes = card:get_field_idxes()
            local candidate_idxes = self:get_all_idxes()
            local cmp_by_dis = function(idx_a, idx_b)
                                   return self:manhattan_(card_idx, idx_a) < self:manhattan_(card_idx, idx_b)
                               end

            table.sort(candidate_idxes, cmp_by_dis)
            for _, candidate_idx in ipairs(candidate_idxes) do
                if ((not clear_idxes_map[candidate_idx]) and (not self:get_idx_card(candidate_idx))) then
                    local target_idxes = self:idxsize_2_idxes(candidate_idx, card:get_size())
                    local target_ok = true
                    for _, target_idx in ipairs(target_idxes) do
                        if (clear_idxes_map[target_idx] or self:get_idx_card(target_idx)) then
                            target_ok = false
                            break
                        end
                    end

                    if (target_ok) then
                        self:move_imp_(card, candidate_idx)
                        local try_one_ret = card:try_pushed_move({ candidate_idx, })
                        self:runAction(try_one_ret)
                        success = true
                        break
                    end
                end
            end

            assert(success) --no process when this case happens yet, fix this later
        end
    end
end

function battle_field:add_trap_by_coor(trap_ptt, caster, coor)
	assert(coor and trap_ptt)

    caster = caster or self.system_card_

    local idx = self:coor_2_idx(coor[1], coor[2])
	assert(idx and (not self:get_idx_card(idx)))

    self:add_trap(trap_ptt, caster, idx)
end

function battle_field:add_trap(trap_ptt, caster, idx)
	assert(idx and trap_ptt)

    caster = caster or self.system_card_

    local trap = battle_trap.new(trap_ptt, caster, self, idx)
    self:add_idx_trap_(idx, trap)
    table.insert(self.traps_, trap)
end

function battle_field:remove_all_traps()
    for i = #self.traps_, 1, -1 do
        local trap = self.traps_[i]
        self:remove_idx_trap_(trap:get_field_idx(), trap)
        table.remove(self.traps_, i)
        trap:destroy()
    end
end

function battle_field:find_near_pair_(idxes, to_idxes)
    assert(next(idxes) and next(to_idxes))

    local near_from = nil
    local near_to = nil
    local near_dis = math.huge
    for _, idx in ipairs(idxes) do
        for _, to_idx in ipairs(to_idxes) do
            assert(self:idx_is_valid_(idx))
            local dis = self:manhattan_(idx, to_idx)
            if (dis < near_dis) then
                near_from = idx
                near_to = to_idx
                near_dis = dis
            end
        end
    end 

    return near_from, near_to, near_dis
end

function battle_field:calc_cards_dis(card_a, card_b)
    local dis = math.huge
    local a_idxes = self:idxsize_2_idxes(card_a:get_field_idx(), card_a:get_size())
    local b_idxes = self:idxsize_2_idxes(card_b:get_field_idx(), card_b:get_size())
    for _, a_idx in ipairs(a_idxes) do
        for _, b_idx in ipairs(b_idxes) do
            dis = math.min(dis, self:manhattan_(a_idx, b_idx))
        end 
    end

    return dis
end

function battle_field:player_move(player_start_cb, player_stop_cb)
	self:setTouchEnabled(true)
	self:setTouchCaptureEnabled(true)
	self:setTouchSwallowEnabled(true)
	self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self.player_start_cb_ = player_start_cb
	self.player_stop_cb_ = player_stop_cb
end

function battle_field:player_stop_move()
	self:setTouchCaptureEnabled(false)
	if (self.cur_moving_ ~= nil) then
        self.cur_moving_:player_no_more_picked()
		self.cur_moving_ = nil
		self:stop_link_effect_()
	end
end

function battle_field:dir_is_valid_(dir)
	return (dir >= DEF.BATTLE_FIELD_DIR_DOWNRIGHT) and (dir <= DEF.BATTLE_FIELD_DIR_UPLEFT)
end

function battle_field:filter_in_dir_dis(idx, dir, dis_min, dis_max)
	assert(self:idx_is_valid_(idx) and self:dir_is_valid_(dir) and dis_min >= 0)
	dis_max = dis_max or dis_min
	assert(dis_max >= dis_min)

	return 	function(self, battle_card_check)
                local find_idx = idx
				for i = 1, dis_min do
				    find_idx = self:next_idx_(find_idx, dir)
				    if (not find_idx) then
					    return false
				    end
				end

				local dis_diff = dis_max - dis_min
				repeat
				    if (self:get_idx_card(find_idx) == battle_card_check) then
					    return true
				    end

				    find_idx = self:next_idx_(find_idx, dir)
				    dis_diff = dis_diff - 1
				until(dis_diff < 0 or (not find_idx))
				return false
			end
end

function battle_field:filter_is_ally(battle_card)
	assert(battle_card and battle_card:get_field_idx())

	return 	function(self, battle_card_check)
		       	return battle_card:is_ally(battle_card_check)
		   	end
end

function battle_field:filter_is_enemy(battle_card)
	assert(battle_card and battle_card:get_field_idx())

	return 	function(self, battle_card_check)
		       	return battle_card:is_enemy(battle_card_check)
		   	end
end

function battle_field:filter_in(battle_cards)
	return 	function(self, battle_card_check) 
				for _, v in ipairs(battle_cards) do
					if (v == battle_card_check) then
						return true
					end
				end
				return false
			end
end

function battle_field:find_filter_notin(battle_cards)
	return 	function(self, battle_card_check) 
				for _, v in ipairs(battle_cards) do
					if (v == battle_card_check) then
						return false
					end
				end
				return true
			end
end

function battle_field:find_cards(filters)
	filters = filters or {}

	if (not next(filters)) then
		local ret = {}
		for _, v in self.cards_ do
			table.insert(ret, v)
		end
		return ret
	end

	local battle_card_tables = {}
	table.insert(battle_card_tables, self.cards_)

	local to = nil
	for _, filter in ipairs(filters) do
		table.insert(battle_card_tables, {})
		local from = battle_card_tables[#battle_card_tables-1]
		to = battle_card_tables[#battle_card_tables]
		for _, v in ipairs(from) do
			if (filter(self, v)) then
				table.insert(to, v)
			end
		end
	end

	assert(to)
	return to
end

--maybe should only provide im
function battle_field:find_up_idxes(card, num)
    assert(card and num > 0)
    local idxes = self:idxsize_2_idxes(card:get_field_idx(), card:get_size())
    local up_idxes = {}
    for _, idx in ipairs(idxes) do
        if (next(up_idxes)) then
            local _, old_row = self:idx_2_coor_(up_idxes[1])
            local _, new_row = self:idx_2_coor_(idx)
            if (new_row > old_row) then
                up_idxes = {}
                table.insert(up_idxes, idx)
            elseif (new_row == old_row) then
                table.insert(up_idxes, idx)
            end
        else
            table.insert(up_idxes, idx)
        end
    end

    local ret = {}
    for _, idx in ipairs(up_idxes) do
        for i = 1, num do
            local idx = self:next_idx_(idx, DEF.BATTLE_FIELD_DIR_UP)
            if (idx) then
                table.insert(ret, idx)
            else
                break
            end
        end
    end
    for _, idx in ipairs(idxes) do
        table.insert(ret, idx)
    end

    return ret
end

function battle_field:find_down_idxes(card, num)
    assert(card and num > 0)
    local idxes = self:idxsize_2_idxes(card:get_field_idx(), card:get_size())
    local down_idxes = {}
    if (next(down_idxes)) then
        local _, old_row = self:idx_2_coor_(down_idxes[1])
        local _, new_row = self:idx_2_coor_(idx)
        if (new_row < old_row) then
            down_idxes = {}
            table.insert(down_idxes, idx)
        elseif (new_row == old_row) then
            table.insert(down_idxes, idx)
        end
    else
        table.insert(down_idxes, idx)
    end

    local ret = {}
    for _, idx in ipairs(down_idxes) do
        for i = 1, num do
            local idx = self:next_idx_(idx, DEF.BATTLE_FIELD_DIR_DOWN)
            if (idx) then
                table.insert(ret, idx)
            else
                break
            end
        end
    end
    for _, idx in ipairs(idxes) do
        table.insert(ret, idx)
    end

    return ret
end

function battle_field:find_left_idxes(card, num)
    assert(card and num > 0)
    local idxes = self:idxsize_2_idxes(card:get_field_idx(), card:get_size())
    local left_idxes = {}
    if (next(left_idxes)) then
        local old_col, _ = self:idx_2_coor_(left_idxes[1])
        local new_col, _ = self:idx_2_coor_(idx)
        if (new_col < old_col) then
            left_idxes = {}
            table.insert(left_idxes, idx)
        elseif (new_col == old_col) then
            table.insert(left_idxes, idx)
        end
    else
        table.insert(left_idxes, idx)
    end

    local ret = {}
    for _, idx in ipairs(left_idxes) do
        for i = 1, num do
            local idx = self:next_idx_(idx, DEF.BATTLE_FIELD_DIR_LEFT)
            if (idx) then
                table.insert(ret, idx)
            else
                break
            end
        end
    end
    for _, idx in ipairs(idxes) do
        table.insert(ret, idx)
    end

    return ret
end

function battle_field:find_right_idxes(card, num)
    assert(card and num > 0)
    local idxes = self:idxsize_2_idxes(card:get_field_idx(), card:get_size())
    local right_idxes = {}
    if (next(right_idxes)) then
        local old_col, _ = self:idx_2_coor_(right_idxes[1])
        local new_col, _ = self:idx_2_coor_(idx)
        if (new_col > old_col) then
            right_idxes = {}
            table.insert(right_idxes, idx)
        elseif (new_col == old_col) then
            table.insert(right_idxes, idx)
        end
    else
        table.insert(right_idxes, idx)
    end

    local ret = {}
    for _, idx in ipairs(right_idxes) do
        for i = 1, num do
            local idx = self:next_idx_(idx, DEF.BATTLE_FIELD_DIR_RIGHT)
            if (idx) then
                table.insert(ret, idx)
            else
                break
            end
        end
    end
    for _, idx in ipairs(idxes) do
        table.insert(ret, idx)
    end

    return ret
end

function battle_field:find_area_idxes(card)
    assert(card)

    local idxes = card:get_field_idxes()
    return self:find_area_idxes_(idxes)
end

function battle_field:find_area_idxes_(idxes)
    assert(idxes and next(idxes))

    local ret = self:find_surround_idxes(idxes)
    for _, idx in ipairs(idxes) do
        table.insert(ret, idx)
    end

    return ret
end

function battle_field:find_surround_idxes(idxes)
    assert(idxes and next(idxes))

    local ret_map = {}
    local dirs = {  DEF.BATTLE_FIELD_DIR_UP,
                    DEF.BATTLE_FIELD_DIR_DOWN,
                    DEF.BATTLE_FIELD_DIR_LEFT,
                    DEF.BATTLE_FIELD_DIR_RIGHT,
                    DEF.BATTLE_FIELD_DIR_UPRIGHT,
                    DEF.BATTLE_FIELD_DIR_UPLEFT,
                    DEF.BATTLE_FIELD_DIR_DOWNLEFT,
                    DEF.BATTLE_FIELD_DIR_DOWNRIGHT, }

    local ret = {}
    for _, idx in ipairs(idxes) do
        for _, dir in ipairs(dirs) do
            local next_idx = self:next_idx_(idx, dir)
            if (next_idx) then
                ret_map[next_idx] = true
            end
        end
    end
    
    for _, idx in ipairs(idxes) do
        ret_map[idx] = false
    end

    for k, v in pairs(ret_map) do
        if (v) then 
            table.insert(ret, k)
        end
    end

    return ret
end

function battle_field:get_all_idxes()
    local ret = {}

    for i = 1, self.grid_num_ do
        table.insert(ret, i)
    end

    return ret
end

function battle_field:try_push_cards(from_idxes, cards, num)
    assert(next(cards) and next(from_idxes) and num > 0)
    local try_ret = nil 
    local try_time = 0

    local pushes = {}
    for _, card in ipairs(cards) do
        assert(card)
        local idxes = self:idxsize_2_idxes(card:get_field_idx(), card:get_size())
        for _, from_idx in ipairs(from_idxes) do
            for _, idx in ipairs(idxes) do
                assert(from_idx ~= idx)
            end
        end
        local push_idx, be_pushed_idx, dis = self:find_near_pair_(from_idxes, idxes)
        assert(push_idx and be_pushed_idx and dis < math.huge)
        local dirs = self:calc_push_dirs_(push_idx, be_pushed_idx)
        assert(next(dirs))
        table.insert(pushes, { card, dirs, dis, })
    end

    table.sort(pushes,  function(push_a, push_b) 
                            return push_a[3] > push_b[3]
                        end)

    local pushed = {}
    for _, push in ipairs(pushes) do
        local path = {}
        local card = push[1]
        local dirs = push[2]

        local cur_idx = card:get_field_idx()
        for i = 1, num do
            for _, dir in ipairs(dirs) do
                local next_idx = self:next_idx_(cur_idx, dir)
                local can_move =    function(card, idx)
	                                    local idxes = self:idxsize_2_idxes(idx, card:get_size())
                                        if (not idxes) then 
                                            return false 
                                        end
	                                    for _, v in ipairs(idxes) do
                                            for _, w in ipairs(pushed) do
                                                if (idx == w[2]) then 
                                                    return false 
                                                end
                                            end
		                                    local idx_card = self:get_idx_card(v)
		                                    if (idx_card) then
                                                local found = false
                                                for _, x in ipairs(pushed) do
                                                    if (idx_card == x[1]) then 
                                                        found = true
                                                        break
                                                    end
                                                end
                                                if (not found) then 
                                                    return false 
                                                end
                                            end
	                                    end

	                                    return true
                                    end

                if (next_idx and can_move(card, next_idx)) then
                    table.insert(path, next_idx)
                    cur_idx = next_idx
 
                    --remove reverse dir so we wont go backward
                    for i, v in ipairs(dirs) do
                        if (v == -dir) then
                            table.remove(dirs, i)
                        end
                    end
                    break                
                end
            end
        end

        if (next(path)) then
            local func = function() self:move_imp_(card, path[#path]) end
            local try_one_ret, try_one_time = card:try_pushed_move(path)
            try_one_ret = cc.Spawn:create(cc.CallFunc:create(func), try_one_ret)

            if (not try_ret) then
                try_ret = try_one_ret
            else
                try_ret = cc.Spawn:create(try_ret, try_one_ret) 
            end
            try_time = math.max(try_time, try_one_time)

            table.insert(pushed, { card, path[#path] })
        end
    end

    return try_ret, try_time
end

function battle_field:find_adjacent_idx_(idxes, idx)
    for _, v in ipairs(idxes) do
		if (self:idx_is_adjacent_(v, idx)) then
			return v
		end
    end
    return nil
end

function battle_field:find_neighbor_idx_(idxes, idx)
    for _, v in ipairs(idxes) do
		if (self:idx_is_neighbor_(v, idx)) then
			return v
		end
    end
    return nil
end

function battle_field:try_move_from_(battle_card, from_idx, to_idx)
	assert(self:idx_is_valid_(from_idx) and self:idx_is_valid_(to_idx))
    assert(self:idx_is_adjacent_(from_idx, to_idx))
	
	local ret = {}
    if (from_idx == to_idx) then 
        return {} 
    end
	
    local can_move =    function(card, from_idx, to_idx)
                            if (self:idx_block_card_(from_idx, card)) then
		                        return false
	                        end
                            local from_col, from_row = self:idx_2_coor_(from_idx)
                            local to_col, to_row = self:idx_2_coor_(to_idx)
                            if (from_col ~= to_col and from_row ~= to_row) then
                                if (self:idx_block_card_(self:coor_2_idx(from_col, to_row), card)
                                    and self:idx_block_card_(self:coor_2_idx(to_col, from_row), card)) then
                                    return false
                                end    
                            end
                            return true
                        end
    
    if (not can_move(battle_card, from_idx, to_idx)) then
        return nil
    end
    
	local battle_card_size = battle_card:get_size()
	local from_idxes = self:idxsize_2_idxes(from_idx, battle_card_size)
	assert(from_idxes)
	local to_idxes = self:idxsize_2_idxes(to_idx, battle_card_size)
	if (not to_idxes) then return nil end

	for i, v in ipairs(to_idxes) do
		local to_card = self:get_idx_card(v)
		if (to_card and to_card ~= battle_card) then
			local to_size = to_card:get_size()			
			if (battle_card:is_ally(to_card)) then
				--(TODO) specific size awared code!!!!!----------------------
				if ((battle_card_size > to_size) or ((battle_card_size == 1) and (to_size == 1))) then
					local swap_idx = self:find_neighbor_idx_(from_idxes, v)
					if (not swap_idx) then
                        swap_idx = self:find_adjacent_idx_(from_idxes, v)
                    end
                    assert(swap_idx)
					if (battle_card_size == 2) then
						swap_idx = self:third_idx_(v, swap_idx)
					end
					table.insert(ret, { handler(self, self.swap_move_), to_card, swap_idx })
				else
					return nil
				end
			elseif (battle_card_size > to_size) then
				local adj_idx = self:find_neighbor_idx_(from_idxes, v)
				assert(adj_idx)
				local push_to_idx = self:third_idx_(adj_idx, v)
				if ((not self:idx_is_valid_(push_to_idx))
					or self:get_idx_card(push_to_idx)) then
					return nil
				else
					table.insert(ret, { handler(self, self.pushed_move_), to_card, push_to_idx })
				end
				--------------------------------------------------------------
			else
				return nil
			end
		end
	end
	
	table.insert(ret, { handler(self, self.active_move_), battle_card, to_idx })
	return ret
end

function battle_field:try_move_(card, to_idx)
	local from_idx = card:get_field_idx()
	assert(self:idx_is_valid_(from_idx) and self:idx_is_adjacent_(from_idx, to_idx))

	return self:try_move_from_(card, from_idx, to_idx)
end

function battle_field:coor_block_card(coor, card)
	assert(card)
	local idx = self:coor_2_idx(coor[1], coor[2])
	assert(idx)
	return self:idx_block_card_(idx, card)
end

function battle_field:idx_block_card_(idx, card)
	assert(self:idx_is_valid_(idx))

	local card_size = card:get_size()
	local idxes = self:idxsize_2_idxes(idx, card_size)
    if (not idxes) then return true end

	for _, v in ipairs(idxes) do
		local idx_card = self:get_idx_card(v)
		if (idx_card) then
			if (idx_card:is_enemy(card) and idx_card:get_size() >= card:get_size()) then
                return true
            elseif (idx_card:is_ally(card) and idx_card:get_size() > card:get_size()) then
                return true
            end
		end
	end

	return false
end

function battle_field:find_path(battle_card, coor)
	local idx = self:coor_2_idx(coor[1], coor[2])
	assert(idx)
	return self:find_path_(battle_card, idx)
end

function battle_field:manhattan_(idx_from, idx_to)
    local col_from, row_from = self:idx_2_coor_(idx_from)
    local col_to, row_to = self:idx_2_coor_(idx_to)
    return math.abs(row_from - row_to) + math.abs(col_from - col_to)
end

--(TODO)the use of find path can be optimized, like adjacent situation or direct line
--(TODO)the use of ai is buggy, coz it didn't consider the swap and push
function battle_field:find_path_(battle_card, to_idx)
	assert(self:idx_is_valid_(to_idx))

	local start_idx = battle_card:get_field_idx()
	assert(self:idx_is_valid_(start_idx))
	local start_col, start_row = self:idx_2_coor_(start_idx)
	local end_col, end_row = self:idx_2_coor_(to_idx)
	local open_list = {}
	local close_list = {}

	local start_node = {}
	start_node.idx = start_idx
	start_node.g = 0
	start_node.h = 0
	start_node.f = 0
	table.insert(open_list, start_node)

	local find_best_open_node = function()
		if (next(open_list) == nil) then 
			return nil
		end

		local ret = open_list[1]
		local ret_i = 1
		for i, v in ipairs(open_list) do
			if (ret.f > v.f) then
				ret = v
				ret_i = i
			end
		end

		table.remove(open_list, ret_i)
		return ret
	end 

	local build_path = function(node)
		local ret = {}
		while (node ~= nil and node.idx ~= start_idx) do
			table.insert(ret, 1, node.idx)
			node = node.father
		end
		return ret
	end 

	local list_find_same_idx = function(list, node)
		for i, v in ipairs(list) do
			if (v.idx == node.idx) then
				return i
			end
		end
	end

	local new_node = function(father, idx, to_idx)
		local node = {}
		node.father = father
		node.idx = idx
		node.g = father.g + 1
		node.h = self:manhattan_(idx, to_idx)
		node.f = node.g + node.h
		return node
	end

	while (next(open_list)) do
		local node = find_best_open_node()
		if (node.idx == to_idx) then
			return build_path(node)
		end

		local try_dir = {
	        				DEF.BATTLE_FIELD_DIR_UP, 
	        				DEF.BATTLE_FIELD_DIR_DOWN,
	        				DEF.BATTLE_FIELD_DIR_LEFT,
	        				DEF.BATTLE_FIELD_DIR_RIGHT,
        				}
       	for _, dir in ipairs(try_dir) do
       		local idx = self:next_idx_(node.idx, dir)
       		if (idx and self:try_move_from_(battle_card, node.idx, idx)) then
       			local cur_node = new_node(node, idx, to_idx)
       			local close_list_i = list_find_same_idx(close_list, cur_node)
       			if (close_list_i == nil) then 
	       			local open_list_i = list_find_same_idx(open_list, cur_node)
	       			if (not open_list_i) then
	       				table.insert(open_list, cur_node)
	       			else
	       				open_list[open_list_i] = cur_node
	       			end 
	       		end
       		end
       	end

        table.insert(close_list, node)
	end
	
	return {}
end

function battle_field:move_(try_ret, time)
    local longest_time = 0
	for _, v in ipairs(try_ret) do
		longest_time = math.max(longest_time, v[1](v[2], v[3], time))
	end

    return longest_time
end

function battle_field:move_one_grid(battle_card, to_idx)
	assert(battle_card and self:idx_is_valid_(to_idx))
	assert(self:idx_is_adjacent_(battle_card:get_field_idx(), to_idx))

    local try_res = self:try_move_(battle_card, to_idx)
    assert(next(try_res) ~= nil)
    self:move_(try_res, 0)
end

function battle_field:move_imp_(card, to_idx)
	local card_size = card:get_size()

	local from_idx = card:get_field_idx()
	local from_idxes = self:idxsize_2_idxes(from_idx, card_size)
	assert(from_idxes)
	for _, v in ipairs(from_idxes) do
		if (self:get_idx_card(v) == card) then
			self:set_idx_card_(v, nil)
		end
	end

	local to_idxes = self:idxsize_2_idxes(to_idx, card_size)
	assert(to_idxes)
	for _, v in ipairs(to_idxes) do
		self:set_idx_card_(v, card)
	end
	
	card:set_field_idx(to_idx)

    battle_event:dispatch_event(battle_event.CARD_TOUCH_GRID_EVENT, { card = card, grid_idx = to_idx, })
end

function battle_field:start_link_effect(link)
    if (next(link.vertical)) then
	    self:start_link_sprite_effect_(link.vertical[1], link.vertical[2])
	end
	if (next(link.horizontal)) then
	    self:start_link_sprite_effect_(link.horizontal[1], link.horizontal[2])
	end
    for _, link_battle_card in ipairs(link.battle_cards) do
        table.insert(self.linked_cards_, link_battle_card)
    end
    self:start_link_card_effect_()
end

function battle_field:start_link_card_effect_()
	for _, v in ipairs(self.linked_cards_) do
        if (v ~= self.cur_moving_) then
		    v:linked()
        end
	end
end

function battle_field:start_link_sprite_effect_(from_idx, to_idx)
	local dirs = { DEF.BATTLE_FIELD_DIR_UP, DEF.BATTLE_FIELD_DIR_DOWN, DEF.BATTLE_FIELD_DIR_LEFT, DEF.BATTLE_FIELD_DIR_RIGHT }
	local idx, grid_num,dir
	for _, v in ipairs(dirs) do
        if (dir) then break end
		idx = from_idx
        grid_num = 1
		while (self:idx_is_valid_(idx)) do
			idx = self:next_idx_(idx, v)
			grid_num = grid_num + 1
			if (idx == to_idx) then
				dir = v
				break
			end
		end
	end
	assert(idx == to_idx and dir)

    local x, y = self:idxsize_2_center_pos(from_idx, 1)
	local width, height
	if (dir == DEF.BATTLE_FIELD_DIR_UP) then
		height = grid_num * self.grid_width_
		width = self.grid_width_ * 0.6
        y = y + height / 2 - self.grid_width_ / 2
	elseif (dir == DEF.BATTLE_FIELD_DIR_DOWN) then
		height = grid_num * self.grid_width_
		width = self.grid_width_ * 0.6
        y = y - height / 2 + self.grid_width_ / 2
	elseif (dir == DEF.BATTLE_FIELD_DIR_LEFT) then
		width = grid_num * self.grid_width_
		height = self.grid_width_ * 0.6
        x = x - width / 2 + self.grid_width_ / 2
	else 
		width = grid_num * self.grid_width_
		height = self.grid_width_ * 0.6
        x = x + width / 2 - self.grid_width_ / 2
	end

	local link_sprite = display.newScale9Sprite(pic.xie_tong_gong_ji_ge_zi)
    link_sprite:addTo(self, DEF.Z_BATTLE_FIELD_ATTACK_LINK)
		   	   :pos(x, y)
	link_sprite:setContentSize(width, height)
	link_sprite:setOpacity(64)

	local sequence = effect("link")
	local repeat_forever = cc.RepeatForever:create(sequence)
	link_sprite:runAction(repeat_forever)

    table.insert(self.link_sprites_, link_sprite)
end

function battle_field:stop_link_effect_()
    for _, v in ipairs(self.link_sprites_) do
    	v:removeSelf()
    end
    self.link_sprites_ = {}

    for _, battle_card in ipairs(self.linked_cards_) do
        --(slightly ugly)
        if (battle_card ~= self.cur_moving_) then
		    battle_card:no_more_linked()
        end
	end
	self.linked_cards_ = {}
end

function battle_field:active_move_(battle_card, to_idx, time)
	assert(battle_card and self:idx_is_valid_(to_idx))
    local longest_time = 0
	
	if (battle_card:is_player()) then
		local battle_card_size = battle_card:get_size()

		local from_idxes = self:idxsize_2_idxes(battle_card:get_field_idx(), battle_card_size)
		for _, v in ipairs(from_idxes) do
			local grid = self.grids_[v]
		    local foot_sprite = display.newScale9Sprite(pic.zhan_chang_ge_zi_yidong)
		    foot_sprite:addTo(self, DEF.Z_BATTLE_FIELD_FOOT_STEP)
		               :pos(grid.cx_, grid.cy_)
                       :setContentSize(self.grid_width_, self.grid_width_)
		    local sequence = cc.Sequence:create(effect("foot_step"), cc.RemoveSelf:create())
		    foot_sprite:runAction(sequence)
		end
	else
		longest_time = battle_card:active_move(to_idx, time)
	end
	self:move_imp_(battle_card, to_idx)

    return longest_time
end

function battle_field:find_oreos(attackers)
	local oreos = {}

	local have_picked = function(oreo)
                            for _, w in ipairs(oreos) do
                                if (w:is_identical(oreo)) then
                                    return true
                                end
                            end
                            return false
                        end

    for _, attacker in ipairs(attackers) do
        local dirs = { DEF.BATTLE_FIELD_DIR_UP, DEF.BATTLE_FIELD_DIR_DOWN, DEF.BATTLE_FIELD_DIR_LEFT, DEF.BATTLE_FIELD_DIR_RIGHT, }
        for _, dir in ipairs(dirs) do
            local attacker_idxes = self:idxsize_2_idxes(attacker:get_field_idx(), attacker:get_size())
            assert(attacker_idxes and next(attacker_idxes))
            for _, idx in ipairs(attacker_idxes) do
                local defenders = {}
                --try to find adjacent enemy chain
                local filters = {}
                filters[1] = self:filter_is_enemy(attacker)

                local dis = 1
                while (true) do
                    filters[2] = self:filter_in_dir_dis(idx, dir, dis)
                    local found = self:find_cards(filters)
                    if (next(found)) then
                        assert(#found == 1)
                        local defender = found[1]
                        if (defenders[#defenders] ~= defender) then
                            table.insert(defenders, defender)
                        end
                        dis = dis + 1
                    else
                        break
                    end
                end

                --found at least 1 enemy
                if (next(defenders)) then
                    local checked_dir = dir
                    local checked_idx = idx
                    local checked_dis = dis
                    --check corner
                    if (#defenders == 1) then
                        local corner = self:idxsize_2_corner_(defenders[1]:get_field_idx(),
                                                                 defenders[1]:get_size())
                        if (corner) then
                            checked_dir = self:dir_corner_turn_(dir, corner)
                            checked_idx = self:idxcorner_2_counter_(idx, corner)
                            checked_dis = 0
                        end
                    end
         
                    filters[1] = self:filter_is_ally(attacker)
                    filters[2] = self:filter_in_dir_dis(checked_idx, checked_dir, checked_dis)
                    local found = self:find_cards(filters)
                    if (next(found)) then
                        assert(#found == 1)
                        local attacker2 = found[1]
                        local one_oreo = battle_oreo.new({ card = attacker, dir = dir, link = self:find_link(attacker) },
                                                         { card = attacker2, dir = -checked_dir, link = self:find_link(attacker2) },
                                                         defenders
                                                         )
                        if (not have_picked(one_oreo)) then
                            table.insert(oreos, one_oreo)
                        end
                    end
                end
            end
        end
    end

    return oreos
end

function battle_field:find_link(battle_card)
    local link = {}
    link.battle_cards = { battle_card }
    link.vertical = {}
    link.horizontal = {}

	-- direct link
	local idx = battle_card:get_field_idx()
	local up_idx = idx
	local down_idx = idx
	local filters = {}
	local found = {}

	local sort_idx_col = function(x, y) 
        return self:idx_2_col_(x:get_field_idx()) < self:idx_2_col_(y:get_field_idx()) end
	local sort_idx_col_reverse = function(x, y)
        return self:idx_2_col_(x:get_field_idx()) > self:idx_2_col_(y:get_field_idx()) end
    local sort_idx_row = function(x, y)
        return self:idx_2_row_(x:get_field_idx()) < self:idx_2_row_(y:get_field_idx()) end
	local sort_idx_row_reverse = function(x, y)
        return self:idx_2_row_(x:get_field_idx()) > self:idx_2_row_(y:get_field_idx()) end

	filters[1] = self:filter_in_dir_dis(idx, DEF.BATTLE_FIELD_DIR_UP, 1, math.huge)
	found = self:find_cards(filters)
    table.sort(found, sort_idx_row)
	for _, v in ipairs(found) do
		if (battle_card:is_ally(v) and battle_card ~= v) then
            up_idx = v:get_field_idx()
			table.insert(link.battle_cards, v)
		elseif (battle_card:is_enemy(v)) then
			break
		end
	end
	filters[1] = self:filter_in_dir_dis(idx, DEF.BATTLE_FIELD_DIR_DOWN, 1, math.huge)
	found = self:find_cards(filters)
	table.sort(found, sort_idx_row_reverse)
	for _, v in ipairs(found) do
		if (battle_card:is_ally(v) and battle_card ~= v) then
            down_idx = v:get_field_idx()
			table.insert(link.battle_cards, v)
		elseif (battle_card:is_enemy(v)) then
			break
		end
	end

	local left_idx = idx
	local right_idx = idx
	filters[1] = self:filter_in_dir_dis(idx, DEF.BATTLE_FIELD_DIR_LEFT, 1, math.huge)
	found = self:find_cards(filters)
	table.sort(found, sort_idx_col_reverse)
	for _, v in ipairs(found) do
		if (battle_card:is_ally(v) and battle_card ~= v) then
            left_idx = v:get_field_idx()
			table.insert(link.battle_cards, v)
		elseif (battle_card:is_enemy(v)) then
			break
		end
	end
	filters[1] = self:filter_in_dir_dis(idx, DEF.BATTLE_FIELD_DIR_RIGHT, 1, math.huge)
	found = self:find_cards(filters)
	table.sort(found, sort_idx_col)
	for _, v in ipairs(found) do
		if (battle_card:is_ally(v) and battle_card ~= v) then
            right_idx = v:get_field_idx()
			table.insert(link.battle_cards, v)
		elseif (battle_card:is_enemy(v)) then
			break
		end
	end

	if (down_idx ~= up_idx) then
		link.vertical = { down_idx, up_idx }
	end
	if (left_idx ~= right_idx) then
        link.horizontal = { left_idx, right_idx }
	end

    return link
end

function battle_field:show_link(battle_card)
	self:stop_link_effect_()

    local found = self:find_oreos({ battle_card })
    if (not next(found)) then
        local link = self:find_link(battle_card)
        found = self:find_oreos(link.battle_cards)
        if (not next(found)) then
            self:start_link_effect(link)
            return
        end
    end

    for _, oreo in ipairs(found) do
        local attackers = oreo:get_attacker_cards()
        for _, attacker in ipairs(attackers) do
            local link = self:find_link(attacker)
	        self:start_link_effect(link)
        end
    end
end

function battle_field:swap_move_(battle_card, to_idx, time)
	assert(battle_card and self:idx_is_valid_(to_idx))

	self:move_imp_(battle_card, to_idx)
	return battle_card:swap_move(to_idx, time)
end

function battle_field:pushed_move_(battle_card, to_idx, time)
	assert(battle_card and self:idx_is_valid_(to_idx))

	self:move_imp_(battle_card, to_idx)
	return battle_card:pushed_move(to_idx, time)
end

function battle_field:try_pushed_move_(battle_card, to_idx)
	assert(battle_card and self:idx_is_valid_(to_idx))

	self:move_imp_(battle_card, to_idx)
	return battle_card:pushed_move(to_idx, time)
end

function battle_field:idx_is_adjacent_(idx_a, idx_b)
	assert(self:idx_is_valid_(idx_a) and self:idx_is_valid_(idx_b))
	return idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_UP)
		or idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_DOWN)
		or idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_LEFT)
		or idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_RIGHT)
        or idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_UPLEFT)
		or idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_DOWNLEFT)
		or idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_UPRIGHT)
        or idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_DOWNRIGHT)
end

function battle_field:idx_is_neighbor_(idx_a, idx_b)
	assert(self:idx_is_valid_(idx_a) and self:idx_is_valid_(idx_b))
	return idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_UP)
		or idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_DOWN)
		or idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_LEFT)
		or idx_a == self:next_idx_(idx_b, DEF.BATTLE_FIELD_DIR_RIGHT)
end

function battle_field:get_adjacent_dir_(from_idx, to_idx)
	assert(self:idx_is_valid_(from_idx) and self:idx_is_valid_(to_idx))
	if (to_idx == self:next_idx_(from_idx, DEF.BATTLE_FIELD_DIR_UP)) then
        return DEF.BATTLE_FIELD_DIR_UP
    elseif (to_idx == self:next_idx_(from_idx, DEF.BATTLE_FIELD_DIR_DOWN)) then
        return DEF.BATTLE_FIELD_DIR_DOWN
    elseif (to_idx == self:next_idx_(from_idx, DEF.BATTLE_FIELD_DIR_LEFT)) then
        return DEF.BATTLE_FIELD_DIR_LEFT
    elseif (to_idx == self:next_idx_(from_idx, DEF.BATTLE_FIELD_DIR_RIGHT)) then
        return DEF.BATTLE_FIELD_DIR_RIGHT
    elseif (to_idx == self:next_idx_(from_idx, DEF.BATTLE_FIELD_DIR_UPLEFT)) then
        return DEF.BATTLE_FIELD_DIR_UPLEFT
    elseif (to_idx == self:next_idx_(from_idx, DEF.BATTLE_FIELD_DIR_UPRIGHT)) then
        return DEF.BATTLE_FIELD_DIR_UPRIGHT
    elseif (to_idx == self:next_idx_(from_idx, DEF.BATTLE_FIELD_DIR_DOWNLEFT)) then
        return DEF.BATTLE_FIELD_DIR_DOWNLEFT
    elseif (to_idx == self:next_idx_(from_idx, DEF.BATTLE_FIELD_DIR_DOWNRIGHT)) then
        return DEF.BATTLE_FIELD_DIR_DOWNRIGHT
    else
        assert(false)
    end
end

function battle_field:calc_move_dirs_(from_idx, to_idx)
    assert(self:idx_is_valid_(from_idx) and self:idx_is_valid_(to_idx))

    local from_col, from_row = self:idx_2_coor_(from_idx)
    local to_col, to_row = self:idx_2_coor_(to_idx)
    local col_diff = from_col - to_col
    local row_diff = from_row - to_row

    if (col_diff == 0 and row_diff == 0) then
        return {}
    elseif (col_diff == 0) then
        if (row_diff > 0) then
            return { DEF.BATTLE_FIELD_DIR_DOWN }
        else
            return { DEF.BATTLE_FIELD_DIR_UP }
        end
    elseif (row_diff == 0) then
        if (col_diff > 0) then
            return { DEF.BATTLE_FIELD_DIR_LEFT }
        else
            return { DEF.BATTLE_FIELD_DIR_RIGHT }
        end
    else
        if (col_diff > 0 and row_diff > 0) then
            return { DEF.BATTLE_FIELD_DIR_DOWNLEFT, DEF.BATTLE_FIELD_DIR_LEFT, DEF.BATTLE_FIELD_DIR_DOWN }
        elseif (col_diff > 0 and row_diff < 0) then
            return { DEF.BATTLE_FIELD_DIR_UPLEFT, DEF.BATTLE_FIELD_DIR_LEFT, DEF.BATTLE_FIELD_DIR_UP }
        elseif (col_diff < 0 and row_diff < 0) then
            return { DEF.BATTLE_FIELD_DIR_UPRIGHT, DEF.BATTLE_FIELD_DIR_RIGHT, DEF.BATTLE_FIELD_DIR_UP }
        else
            return { DEF.BATTLE_FIELD_DIR_DOWNRIGHT, DEF.BATTLE_FIELD_DIR_RIGHT, DEF.BATTLE_FIELD_DIR_DOWN }
        end
    end
    assert(false)
end

function battle_field:calc_push_dirs_(from_idx, to_idx)
	assert(self:idx_is_valid_(from_idx) and self:idx_is_valid_(to_idx))

    local from_col, from_row = self:idx_2_coor_(from_idx)
    local to_col, to_row = self:idx_2_coor_(to_idx)
    local col_diff = from_col - to_col
    local row_diff = from_row - to_row

    if (col_diff == 0 and row_diff == 0) then
        return { DEF.BATTLE_FIELD_DIR_UP, DEF.BATTLE_FIELD_DIR_DOWN, DEF.BATTLE_FIELD_DIR_LEFT, DEF.BATTLE_FIELD_DIR_RIGHT, }
    elseif (col_diff == 0) then
        if (row_diff > 0) then
            return { DEF.BATTLE_FIELD_DIR_DOWN, DEF.BATTLE_FIELD_DIR_RIGHT, DEF.BATTLE_FIELD_DIR_LEFT, }
        else
            return { DEF.BATTLE_FIELD_DIR_UP, DEF.BATTLE_FIELD_DIR_RIGHT, DEF.BATTLE_FIELD_DIR_LEFT, }
        end
    elseif (row_diff == 0) then
        if (col_diff > 0) then
            return { DEF.BATTLE_FIELD_DIR_LEFT, DEF.BATTLE_FIELD_DIR_UP, DEF.BATTLE_FIELD_DIR_DOWN, }
        else
            return { DEF.BATTLE_FIELD_DIR_RIGHT, DEF.BATTLE_FIELD_DIR_DOWN, DEF.BATTLE_FIELD_DIR_UP, }
        end
    else
        local ret_dirs = {}
        if (col_diff > 0) then
            table.insert(ret_dirs, DEF.BATTLE_FIELD_DIR_LEFT)
        elseif (col_diff < 0) then
            table.insert(ret_dirs, DEF.BATTLE_FIELD_DIR_RIGHT)
        end

        if (row_diff > 0) then
            table.insert(ret_dirs, DEF.BATTLE_FIELD_DIR_DOWN)
        elseif (row_diff < 0) then
            table.insert(ret_dirs, DEF.BATTLE_FIELD_DIR_UP)
        end
        return ret_dirs
    end
    assert(false)
end

function battle_field:idxdirdis_2_idx(idx, dir, dis)
	assert(self:idx_is_valid_(idx) and self:dir_is_valid_(dir))

	if (dis < 0) then
		dis = -dis
		dir = -dir
	end

	while (dis > 0) do
		idx = self:next_idx_(idx, dir)
		assert(self:idx_is_valid_(idx))
		dis = dis - 1
	end

	return idx
end

function battle_field:next_idx_(idx, dir)
	assert(self:idx_is_valid_(idx) and self:dir_is_valid_(dir))

	local ret = nil
	local row = self:idx_2_row_(idx)

	if (dir == DEF.BATTLE_FIELD_DIR_UP) then
		ret = idx + self.col_num_
	elseif (dir == DEF.BATTLE_FIELD_DIR_DOWN) then
		ret = idx - self.col_num_
	elseif (dir == DEF.BATTLE_FIELD_DIR_LEFT) then
		ret = idx - 1
		local ret_row = self:idx_2_row_(ret)
		if (ret_row ~= row) then return nil end
	elseif (dir == DEF.BATTLE_FIELD_DIR_RIGHT) then
		ret = idx + 1
		local ret_row = self:idx_2_row_(ret)
		if (ret_row ~= row) then return nil end
	elseif (dir == DEF.BATTLE_FIELD_DIR_UPRIGHT) then
		ret = idx + 1
		local ret_row = self:idx_2_row_(ret)
		if (ret_row ~= row) then return nil end
		ret = ret + self.col_num_
	elseif (dir == DEF.BATTLE_FIELD_DIR_UPLEFT) then
		ret = idx - 1
		local ret_row = self:idx_2_row_(ret)
		if (ret_row ~= row) then return nil end
		ret = ret + self.col_num_
	elseif (dir == DEF.BATTLE_FIELD_DIR_DOWNLEFT) then
		ret = idx - 1
		local ret_row = self:idx_2_row_(ret)
		if (ret_row ~= row) then return nil end
		ret = ret - self.col_num_
	else
		ret = idx + 1
		local ret_row = self:idx_2_row_(ret)
		if (ret_row ~= row) then return nil end
		ret = ret - self.col_num_
	end

	if (self:idx_is_valid_(ret)) then
		return ret
	else
		return nil
	end
end

function battle_field:third_idx_(idx1, idx2)
	assert(self:idx_is_valid_(idx1) 
		and self:idx_is_valid_(idx2)
		and self:idx_is_adjacent_(idx1, idx2))

    local dir = self:get_adjacent_dir_(idx1, idx2)
	return self:next_idx_(idx2, dir)
end

function battle_field:on_player_touch_(event)
    if not (self:pos_is_in_grids_(event.x, event.y)) then 
    	return false 
    end

    local col, row = self:pos_2_coor_(event.x, event.y)
    local idx = self:coor_2_idx(col, row)
    local battle_card = self:get_idx_card(idx)
    if (event.name == "began") then
    	self.cur_moved_ = false
        if (battle_card and battle_card:is_player()) then
            battle_card:player_picked()
            battle_card:setLocalZOrder(DEF.Z_BATTLE_FIELD_CARD_PLAYER_MOVING)
            self.cur_moving_ = battle_card
            self:show_link(battle_card)
        else
        	return false
        end
    elseif (event.name == "moved") then
    	if not (self.cur_moving_) then
    		return false
    	end

        if (idx == self.cur_moving_:get_field_idx()) then 
            self.cur_moving_:pos(event.x, event.y)
        else
            if (not self.cur_moved_) then
                if (self.player_start_cb_) then
                    self.player_start_cb_()
                end
        	    self.cur_moved_ = true
            end

            local x, y = self:idx_2_pos_(self.cur_moving_:get_field_idx()) 
            local half_grid = self:get_grid_width() / 2
            if (x > event.x) then
                x = math.max(event.x, x - half_grid)
            elseif (x < event.x) then
                x = math.min(event.x, x + half_grid)
            end
            if (y > event.y) then
                y = math.max(event.y, y - half_grid)
            elseif (y < event.y) then
                y = math.min(event.y, y + half_grid)
            end
            self.cur_moving_:pos(x, y)

            local cur_idx = self.cur_moving_:get_field_idx()
            local dirs = self:calc_move_dirs_(cur_idx, idx)
            for _, dir in ipairs(dirs) do
                local next_idx = self:next_idx_(cur_idx, dir)
                local try_res = self:try_move_(self.cur_moving_, next_idx)
                if (try_res) then
        			self:move_(try_res, 0)
                    break
                end
            end
            self:show_link(self.cur_moving_)
        end
    elseif (event.name == "ended" or event.name == "cancelled" ) then
        if (self.cur_moving_) then
        	self.cur_moving_:pos(self:idxsize_2_center_pos(self.cur_moving_:get_field_idx(), self.cur_moving_:get_size()))
        	self.cur_moving_:player_no_more_picked()
            self.cur_moving_:setLocalZOrder(DEF.Z_BATTLE_FIELD_CARD)
        	self:stop_link_effect_()
            if (self.cur_moved_) then
        	    self.cur_moving_ = nil
        	    if (self.player_stop_cb_) then
                    self.player_stop_cb_()
                end
            end
        end
    end
    return true
end

function battle_field:on_trap_death_(event)
    for _, trap in ipairs(self.traps_) do
        if (trap == event.args.trap) then
            self:remove_idx_trap_(trap:get_field_idx(), trap)
            table.remove(self.traps_, i)
        end
    end
end

function battle_field:pos_2_coor_(x, y)
    col = math.floor((x - self.lbx_) / self.grid_width_) + 1
    row = math.floor((y - self.lby_) / self.grid_width_) + 1
    return col, row
end

function battle_field:idx_2_col_(idx)
    local cor = idx % self.col_num_
    if (cor == 0) then 
        cor = self.col_num_
    end
    return cor
end

function battle_field:idx_2_row_(idx)
    local row = math.floor((idx - 1) / self.col_num_) + 1
    return row
end

function battle_field:idx_2_coor_(idx)
    return self:idx_2_col_(idx), self:idx_2_row_(idx)
end

function battle_field:set_idx_card_(idx, battle_card)
	assert(self:idx_is_valid_(idx))
	self.grids_[idx].battle_card = battle_card
end

function battle_field:add_idx_trap_(idx, trap)
	assert(self:idx_is_valid_(idx))
	table.insert(self.grids_[idx].traps_, trap)
end

function battle_field:remove_idx_trap_(idx, trap)
	assert(self:idx_is_valid_(idx))
    for i, v in ipairs(self.grids_[idx].traps_) do
        if (v == trap) then
            table.remove(self.grids_[idx].traps_, i)
            break
        end
    end
end

function battle_field:get_coor_battle_card(coor)
	local idx = self:coor_2_idx(coor[1], coor[2])
	assert(self:idx_is_valid_(idx))
	return self.grids_[idx].battle_card
end

function battle_field:get_idx_card(idx)
	assert(self:idx_is_valid_(idx))
	return self.grids_[idx].battle_card
end

function battle_field:pos_is_in_grids_(x, y)
    return (x >= self.lbx_) and (y >= self.lby_)
    	and (x <= self.lbx_ + self.width_) and (y <= self.lby_ + self.height_)
end

function battle_field:idx_is_valid_(idx)
	return idx and (idx >= 1) and (idx <= self.grid_num_) 
end

function battle_field:idx_2_pos_(idx)
    if (self:idx_is_valid_(idx)) then
        return self.grids_[idx].cx_, self.grids_[idx].cy_
    end
end

function battle_field:coor_2_idx(col, row)
	local idx = col + (row - 1) * self.col_num_
	if (self:idx_is_valid_(idx)) then
		return idx
	else
		return nil
	end
end

function battle_field:idxsize_2_corner_(idx, size)
    if ((size == 1 and idx == 1) or (size == 2 and idx == self.col_num_ + 1)) then
        return DEF.BATTLE_FIELD_CORNER_LEFTDOWN
    elseif ((size == 1 and idx == self.col_num_) or (size == 2 and idx == self.col_num_ * 2 - 1)) then
        return DEF.BATTLE_FIELD_CORNER_RIGHTDOWN
    elseif ((size == 1 and idx == self.row_num_ * self.col_num_) or (size == 2 and idx == self.col_num_ * self.row_num_ - 1)) then
        return DEF.BATTLE_FIELD_CORNER_RIGHTUP
    elseif ((size == 1 or size == 2) and idx == (self.row_num_ - 1) * self.col_num_ + 1) then
        return DEF.BATTLE_FIELD_CORNER_LEFTUP
    else
        return nil
    end
end
function battle_field:dir_corner_turn_(dir, corner)
    if (corner == DEF.BATTLE_FIELD_CORNER_LEFTDOWN) then
        if (dir == DEF.BATTLE_FIELD_DIR_LEFT) then
            return DEF.BATTLE_FIELD_DIR_UP
        elseif (dir == DEF.BATTLE_FIELD_DIR_DOWN) then
            return DEF.BATTLE_FIELD_DIR_RIGHT
        else
            assert(false)
        end
    elseif (corner == DEF.BATTLE_FIELD_CORNER_RIGHTDOWN) then
        if (dir == DEF.BATTLE_FIELD_DIR_RIGHT) then
            return DEF.BATTLE_FIELD_DIR_UP
        elseif (dir == DEF.BATTLE_FIELD_DIR_DOWN) then
            return DEF.BATTLE_FIELD_DIR_LEFT
        else
            assert(false)
        end
    elseif (corner == DEF.BATTLE_FIELD_CORNER_RIGHTUP) then
        if (dir == DEF.BATTLE_FIELD_DIR_UP) then
            return DEF.BATTLE_FIELD_DIR_LEFT
        elseif (dir == DEF.BATTLE_FIELD_DIR_RIGHT) then
            return DEF.BATTLE_FIELD_DIR_DOWN
        else
            assert(false)
        end
    elseif (corner == DEF.BATTLE_FIELD_CORNER_LEFTUP) then
        if (dir == DEF.BATTLE_FIELD_DIR_UP) then
            return DEF.BATTLE_FIELD_DIR_RIGHT
        elseif (dir == DEF.BATTLE_FIELD_DIR_LEFT) then
            return DEF.BATTLE_FIELD_DIR_DOWN
        else
            assert(false)
        end
    else
        assert(false)
    end
end

function battle_field:idxcorner_2_counter_(idx, corner)
    local ret
    local col, row = self:idx_2_coor_(idx)
    if (corner == DEF.BATTLE_FIELD_CORNER_LEFTDOWN) then
        ret = self:coor_2_idx(row, col)
    elseif (corner == DEF.BATTLE_FIELD_CORNER_RIGHTDOWN) then
        ret = self:coor_2_idx(self.col_num_ - row + 1, self.col_num_ - col + 1) 
    elseif (corner == DEF.BATTLE_FIELD_CORNER_LEFTUP) then
        ret = self:coor_2_idx(self.row_num_ - row + 1, self.row_num_ - col + 1) 
    elseif (corner == DEF.BATTLE_FIELD_CORNER_RIGHTUP) then
        ret = self:coor_2_idx(self.col_num_ - self.row_num_ + row, self.row_num_ - self.col_num_ + col)
    else
        assert(false)
    end 

    assert(self:idx_is_valid_(ret))
    return ret
end

function battle_field:onEnter()
end

function battle_field:onExit()
    for _, listener in ipairs(self.listeners_) do
        battle_event:remove_listener(listener)
    end
end

return battle_field
