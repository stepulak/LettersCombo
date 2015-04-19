require("button")
require("label")
require("font")
require("finger")
require("about")

local graph = love.graphics
local b = nil
local title = nil

function mainmenu_click(x, y)
  for i=1,#b do
    if button_click(b[i], x, y) then
      return true
    end
  end
  return false
end

function mainmenu_release(x, y)
  for i=1,#b do
    if button_release(b[i], x, y) then
      return true
    end
  end
  return false
end

function mainmenu_update(dt)
  local x, y = finger_position()
  if fingerclicked then
    mainmenu_click(x, y)
  elseif fingerreleased then
    mainmenu_release(x, y)
  end
end

function mainmenu_draw()
  label_draw(title)
  for i=1,#b do
    button_draw(b[i])
  end
end

local woffset = 0.1
local buttonh = 0.12

function chooselevel_func()
  guistack_pushanimated({update = levelchooser_update, draw = levelchooser_draw})
end

function mainmenu_create(continue)
  -- Menu title
  title = label_new_center(gametitle, fontb, winw/2, 0, {r = 0, g = 0, b = 0})
  -- Menu buttons proportions
  local wo = woffset*winw
  local bw = winw-2*wo
  local ho = title.h+30*(winh/winhbase)
  local bh = winh*buttonh
  local offseth = bh*1.5
  local index = 1
  -- Menu buttons creation
  b = {}
  b[index] = button_new("Play", fontm, wo, ho, bw, bh, 
    function()
      guistack_pushanimated(
	{update = levelchooser_update, draw = levelchooser_draw}
      )
    end
  )
  ho = ho+offseth
  index = index+1
  b[index] = button_new("About", fontm, wo, ho, bw, bh, 
    function()
      guistack_pushanimated(
	{update = about_update, draw = about_draw}
      )
    end
  )
  ho = ho+offseth
  index = index+1
  b[index] = button_new("Quit", fontm, wo, ho, bw, bh, love.event.quit)
  ho = ho+offseth
  index = index+1
end