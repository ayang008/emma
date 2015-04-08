local battle_ui = class("battle_ui", function()
    return display.newLayer("battle_ui")
end)

function battle_ui:ctor()
    local battle_canvas = cc.uiloader:load("battle.json")
    local battle_panel = cc.uiloader:seekNodeByName(battle_canvas, "panel")
    self.player_bar_ = cc.uiloader:seekNodeByName(battle_panel, "player_bar")
    battle_canvas:addTo(self)
end

function battle_ui:tip(str)
    local label = display.newTTFLabel({
                                        UILabelType = 2,
                                        text = str,
                                        size = DEF.TIP_ZI_SIZE,
                                        x = display.cx,
                                        y = display.cy * 1.2,
                                        align = cc.TEXT_ALIGNMENT_CENTER,
                                    })
                         :addTo(self, DEF.Z_BATTLE_UI_TIP)
    label:enableOutline(cc.c4b(255, 0, 0, 255), 5)        
    local effect = effect("battle_field_tip")
    local effect = cc.Sequence:create(effect, cc.RemoveSelf:create())
    label:runAction(effect)
end

function battle_ui:player_bar(percent)
    self.player_bar_:setPercent(percent)
end

return battle_ui