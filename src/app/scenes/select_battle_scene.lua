local select_battle_scene = class("select_battle_scene", function()
    return display.newScene("select_battle_scene")
end)

local battle_cfg = import("..res.battle_cfg")
local icon_label = import("..ui.icon_label")
local icon_label_window = import("..ui.icon_label_window")

function select_battle_scene:ctor()
    self.selected_battle_ = nil
    self.done_select_battle = false

    local params = {}

    local select_battle_canvas = cc.uiloader:load("select_battle.json")
    local select_battle_panel = cc.uiloader:seekNodeByName(select_battle_canvas, "panel")
    local battle_list = cc.uiloader:seekNodeByName(select_battle_panel, "battle_list")
    local battle_info = cc.uiloader:seekNodeByName(select_battle_panel, "battle_info")
    local select_button = cc.uiloader:seekNodeByName(select_battle_panel, "select_button")
    select_battle_canvas:addTo(self)
                        :pos(0, 0)
    
    for cfg_name, cfg in pairs(battle_cfg) do
        local content = cc.ui.UIPushButton.new(pic.combat_list_bg, {scale9 = true})
                            :setButtonSize(120, 40)
                            :setButtonLabel(cc.ui.UILabel.new({text = cfg_name, size = 16, color = DEF.COLOR_YELLOW}))
                            :onButtonClicked(function(event)
                                                self.selected_battle_ = cfg
                                                battle_info:setString(cfg.tip)
                                             end)
        local battle_item = battle_list:newItem()
        battle_item:addContent(content)
        battle_item:setItemSize(120, 40)
        battle_list:addItem(battle_item)
    end
    battle_list:reload()

    local select_card_canvas = cc.uiloader:load("select_card.json")
    local select_card_panel = cc.uiloader:seekNodeByName(select_card_canvas, "panel")
    local player_card_list = cc.uiloader:seekNodeByName(select_card_panel, "player_card_list")
    local card_big_sprite = cc.uiloader:seekNodeByName(select_card_panel, "card_big_sprite")
    card_big_sprite:setVisible(false)
    local card_info_panel = cc.uiloader:seekNodeByName(select_card_panel, "card_info_panel")
    local card_info = cc.uiloader:seekNodeByName(card_info_panel, "card_info")
    local card_skill_panel = cc.uiloader:seekNodeByName(card_info_panel, "card_skill_panel")
    local label_window = icon_label_window.new():addTo(card_skill_panel)
    local card_skill_panel_size = card_skill_panel:getContentSize()
    label_window:setPosition(card_skill_panel_size.width/2, card_skill_panel_size.height/2)
    select_card_canvas:addTo(self)
                      :pos(display.width, 0)
    local start_battle_button = cc.uiloader:seekNodeByName(select_card_panel, "start_battle_button")
    

    local cards = player:get_cards()
    local images = {
                    off = pic.checkbox_off,
                    off_pressed = pic.checkbox_off,
                    off_disabled = pic.checkbox_off,
                    on = pic.checkbox_on,
                    on_pressed = pic.checkbox_on,
                    on_disabled = pic.checkbox_on,
                   }
    self.button_card_map_ = {}
    for _, card in pairs(cards) do
        local content = cc.ui.UIPushButton.new(card:get_image())
                                         :onButtonClicked(function(event)
                                                              card_big_sprite:setTexture(card:get_big_image())
                                                              card_big_sprite:setScale(0.9)
                                                              card_big_sprite:setVisible(true)
                                                              card_info:setString(card:get_tip())

                                                              local labels = {}
                                                              local skills = card:get_skills()
                                                              for _, skill in ipairs(skills) do
                                                                  table.insert(labels, icon_label.new(skill:get_icon(), skill:get_name()))
                                                              end
                                                              label_window:set_labels(labels)
                                                          end)
        local button = cc.ui.UICheckBoxButton.new(images)
                                            :addTo(content)
        button:setScale(0.5)                               
        button:pos(16, -16)
        table.insert(self.button_card_map_, { button, card })

        local card_item = player_card_list:newItem()
        card_item:addContent(content)
        card_item:setItemSize(64, 64)
        player_card_list:addItem(card_item)
    end
    player_card_list:reload()

    select_button:onButtonClicked(function(event)
                                      if (self.selected_battle_ and (not self.done_select_battle)) then
                                          self.done_select_battle = true
                                          select_battle_canvas:runAction(cc.MoveBy:create(1, cc.p(-display.width, 0)))
                                          select_card_canvas:runAction(cc.MoveBy:create(1, cc.p(-display.width, 0)))
                                      end
                                  end)

    start_battle_button:onButtonClicked(function(event)
                                local selected_cards = {}
                                for _, v in ipairs(self.button_card_map_) do
                                    if (v[1]:isButtonSelected()) then
                                        table.insert(selected_cards, v[2])
                                    end
                                end

                                if (next(selected_cards)) then 
                                    player:set_battle_cards(selected_cards)
                                    local scene = battle_scene.new(self.selected_battle_)
                                    display.replaceScene(scene)
                                end
                            end)
end

function select_battle_scene:onEnter()
    print("select_battle_scene:onEnter")
end

function select_battle_scene:onExit()
    print("select_battle_scene:onExit")
end

return select_battle_scene
