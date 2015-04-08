
require("config")
require("cocos.init")
require("framework.init")

DEF = require("app.res.common_cfg")
effect = require("app.res.effect_cfg")
anim = require("app.res.anim_cfg")
pic = require("app.res.picture_list")
card_ptt = require("app.res.card_prototype")
skill_ptt = require("app.res.skill_prototype")
hero = require("app.game.hero")
card = require("app.game.card")
player = require("app.game.player").new()
skill = require("app.game.skill")
battle_scene = import(".scenes.battle_scene")
select_battle_scene = import(".scenes.select_battle_scene")
--tcp = require("app.tcp")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
	math.randomseed(os.time()) 
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.Director:getInstance():setContentScaleFactor(480 / CONFIG_SCREEN_WIDTH)
    self:enterScene("select_battle_scene")
end

return MyApp
