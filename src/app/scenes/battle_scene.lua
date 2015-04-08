local battle_scene = class("battle_scene", function()
    return display.newScene("battle_scene")
end)

battle_card = import(".battle_card")
battle_trap = import(".battle_trap")
battle_field = import(".battle_field")
battle_ui = import(".battle_ui")
battle_combat = import(".battle_combat")
battle_control = import(".battle_control")
battle_ai = import(".battle_ai")
battle_skill = import(".battle_skill")
battle_action = import(".battle_action")
battle_oreo = import(".battle_oreo")
battle_buff = import(".battle_buff")
battle_event = import(".battle_event")

buff_ptt = import("..res.buff_prototype")
trap_ptt = import("..res.trap_prototype")

function battle_scene:ctor(cfg)
    --back ground
    local back_ground = display.newSprite(pic.zhan_chang_bei_jing)   
    back_ground:addTo(self)
    back_ground:pos(display.cx, display.cy)
    local size = back_ground:getContentSize()
        

    --battle ui
    self.ui_ = battle_ui.new()
    self.ui_:setTouchEnabled(false) --(TODO) fix this tmp method, use content window maybe
    self.ui_:addTo(self, DEF.Z_BATTLE_SCENE_UI)

    --battle field
	self.field_ = battle_field.new(
                                    DEF.BATTLE_FIELD_COL_NUM, 
                                    DEF.BATTLE_FIELD_ROW_NUM, 
                                    DEF.BATTLE_FIELD_GRID_WIDTH,
                                    DEF.BATTLE_FIELD_X_OFFSET,
                                    DEF.BATTLE_FIELD_Y_OFFSET,
                                    self.ui_
                                    )
    self.field_:addTo(self, DEF.Z_BATTLE_SCENE_BATTLE_FIELD)
    

    --battle combat
    local combat = battle_combat.new(self.field_, self.ui_)

    --battle ai
    local ai = battle_ai.new(self.field_)

    --battle control
    self.control_ = battle_control.new(self.field_, self.ui_, cfg, combat, ai)

    --anim
    for _, v in ipairs(anim.files) do
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(v)
    end
end

function battle_scene:onEnter()
    self.control_:start()
end

function battle_scene:onExit()
end
 
return battle_scene