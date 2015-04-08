local player = class("player")

function player:ctor()
    --test
    self.cards_ = {}
    table.insert(self.cards_, card.new("chuan_zhang"))
    table.insert(self.cards_, card.new("ai_she"))
    table.insert(self.cards_, card.new("huang_zi"))
    table.insert(self.cards_, card.new("xi_xue_gui"))
    table.insert(self.cards_, card.new("mang_seng"))
    table.insert(self.cards_, card.new("e_yun"))
end

function player:get_cards()
    return self.cards_
end

function player:set_battle_cards(cards)
    self.battle_cards_ = cards
end

function player:get_battle_cards()
    return self.battle_cards_
end


return player