require("menu")
require("levelchooser")
require("game")
require("guistack")
require("keys")
require("windialog")
require("about")

local graph = love.graphics

function love.load()
  graph.setBackgroundColor(245, 245, 245)
  font_load()
  guistack_create()
  mainmenu_create()
  about_create()
  windialog_create()
  levelchooser_create()
  guistack_push({ update = mainmenu_update, draw = mainmenu_draw })
  --game_create()
end

function love.mousepressed(b, x, y)
  fingerclicked = true
end

function love.mousereleased(b, x, y)
  fingerreleased = true
end

function love.keypressed(k, isrepeated)
  if k == "escape" then
    returnpressed = true
  elseif k == "menu" then
    menupressed = true
  end
end

function love.keyreleased(k)
  if k == "escape" then
    returnreleased = true
  elseif k == "menu" then
    menureleased = true
  end
end


function love.update(dt)
  guistack_update(dt)
  if returnreleased then
    guistack_popanimated()
  end
  if menureleased then 
    guistack_create()
    guistack_push({ update = mainmenu_update, draw = mainmenu_draw })
  end
  fingerclicked = false
  fingerreleased = false
  keys_setdefault()
end

function love.draw()
  guistack_draw()
end
