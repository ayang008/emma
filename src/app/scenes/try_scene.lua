local try_scene = class("try_scene", function()
    return display.newScene("try_scene")
end)

function try_scene:ctor()
    local sprite = display.newSprite("image/card/ai_she.png") 
    local node_grid = cc.NodeGrid:create()
    sprite:addTo(node_grid)
    node_grid:addTo(self)
             :pos(display.cx, display.cy)
    local action = cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(0, 3)), 
                                cc.MoveBy:create(0.1, cc.p(0, -6)),
                                cc.MoveBy:create(0.1, cc.p(0, 6)),
                                cc.MoveBy:create(0.1, cc.p(0, -6)),
                                cc.MoveBy:create(0.1, cc.p(0, 6)),
                                cc.MoveBy:create(0.1, cc.p(0, -6)),
                                cc.MoveBy:create(0.1, cc.p(0, 6)),
                                cc.MoveBy:create(0.1, cc.p(0, -3)))
    action = cc.Spawn:create(cc.SplitRows:create(5, 4096), action)
    --cc.ShuffleTiles:create(10, cc.size(512, 1024), os.time())	
    --cc.FadeOutUpTiles:create(2, cc.size(128, 128))
    --cc.FadeOutTRTiles:create(2, cc.size(128, 128))
    --cc.TurnOffTiles:create(2, cc.size(200, 200))
    --cc.FlipX3D:create(10)
    --cc.ShatteredTiles3D:create(10, cc.size(5, 5), 10, true)	
    --cc.SplitRows:create(5, 999)
    --cc.ShakyTiles3D:create(15, cc.size(15, 10), 4, false)
    node_grid:runAction(action)
end

function try_scene:onEnter()
    print("try_scene:onEnter")
end

function try_scene:onExit()
    print("try_scene:onExit")
end

return try_scene
