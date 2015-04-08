local battle_ai = class("battle_ai")

local scheduler = require("framework.scheduler")

function battle_ai:ctor(battle_field)
	self.field_ = battle_field
end

function battle_ai:rand_dir_()
	local dirs = {}
	table.insert(dirs, DEF.BATTLE_FIELD_DIR_UP)
	table.insert(dirs, DEF.BATTLE_FIELD_DIR_DOWN)
	table.insert(dirs, DEF.BATTLE_FIELD_DIR_LEFT)
	table.insert(dirs, DEF.BATTLE_FIELD_DIR_RIGHT)

	return dirs[math.random(#dirs)]

end

function battle_ai:move(mover, enemys, move_finish_cb)
	self.mover_ = mover
	self.move_finish_cb_ = move_finish_cb
	self.path_ = {}
	local col_num = self.field_:get_col_num()
	local row_num = self.field_:get_row_num()

	local try_max = 5
	repeat
		local col = math.random(col_num)
		local row = math.random(row_num)
		self.path_ = self.field_:find_path(mover, {col, row})
		try_max = try_max - 1
	until ((next(self.path_) ~= nil) or try_max <= 0)

	self:move_one_step_()
end

function battle_ai:move_one_step_()
	if (next(self.path_) == nil) then
		self.mover_ = nil
		self.path_ = {}
		self.move_finish_cb_()
	else
		idx = table.remove(self.path_, 1)
		self.field_:move_one_grid(self.mover_, idx, DEF.ACTIVE_MOVE_ONE_GRID_SECOND)
		scheduler.performWithDelayGlobal(handler(self, self.move_one_step_), DEF.ACTIVE_MOVE_ONE_GRID_SECOND)
	end
end

return battle_ai