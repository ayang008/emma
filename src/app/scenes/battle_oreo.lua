local battle_oreo = class("battle_oreo")

function battle_oreo:ctor(attacker1, attacker2, defenders)
    self.attackers_ = { attacker1, attacker2 }
    self.defenders_ = defenders
end

function battle_oreo:is_attacker(card)
    return card == self.attackers_[1].card 
           or card == self.attackers_[2].card
end

function battle_oreo:get_attacker_cards()
    local attackers = {}
    table.insert(attackers, self.attackers_[1].card)
    table.insert(attackers, self.attackers_[2].card)
    return attackers
end

function battle_oreo:get_defenders()
    return self.defenders_
end

function battle_oreo:is_identical(another)
    if (((self.attackers_[1].card == another.attackers_[1].card) and (self.attackers_[2].card == another.attackers_[2].card))
        or ((self.attackers_[1].card == another.attackers_[2].card) and (self.attackers_[2].card == another.attackers_[1].card))) then
        for _, defender in ipairs(self.defenders_) do
            if (defender == another.defenders_[1]) then
                return true
            end
        end
    end
    return false
end

function battle_oreo:get_attacker_dir(attacker)
    if (self.attackers_[1].card == attacker) then
        return self.attackers_[1].dir
    elseif (self.attackers_[2].card == attacker) then
        return self.attackers_[2].dir
    end
end

function battle_oreo:find_same_link_cards(card)
    local ret = {}
    for _, attacker in ipairs(self.attackers_) do
        if (card == attacker.card) then
            table.insert(ret, attacker.card)
            for _, v in ipairs(attacker.link) do
                table.insert(ret, v)
            end
            return ret
        else
            for _, link_card in ipairs(attacker.link) do
                if (card == link_card) then
                    table.insert(ret, attacker.card)
                    for _, v in ipairs(attacker.link) do
                        table.insert(ret, v)
                    end
                    return ret
                end
            end
        end
    end

    return nil
end

return battle_oreo