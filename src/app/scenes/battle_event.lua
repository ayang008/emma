local battle_event = {}

battle_event.TURN_END_EVENT = "battle_event.TURN_END_EVENT"
battle_event.SECOND_EVENT = "battle_event.SECOND_EVENT"
battle_event.CARD_DEATH_EVENT = "battle_event.CARD_DEATH_EVENT"
battle_event.CARD_TOUCH_GRID_EVENT = "battle_event.CARD_TOUCH_GRID_EVENT"

function battle_event:add_listener(event, callback)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerCustom:create(event, callback)
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
    return listener
end

function battle_event:dispatch_event(event, args)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local event = cc.EventCustom:new(event)
    event.args = args
    eventDispatcher:dispatchEvent(event)
end

function battle_event:remove_listener(listener)
    cc.Director:getInstance():getEventDispatcher():removeEventListener(listener)
end

return battle_event