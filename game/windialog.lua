require("guistack")
require("button")
require("label")
require("font")
require("finger")

local backbut = nil
local winlab = nil

function windialog_update(dt)
  local x, y = finger_position()
  if fingerclicked then
    button_click(backbut, x, y)
  elseif fingerreleased then
    button_release(backbut, x, y)
  end
end

function windialog_draw()
  button_draw(backbut)
  label_draw(winlab)
end

function windialog_create()
  local w = winw/3
  local h = winh/10
  backbut = button_new("Back", fontm, winw/2-w/2, winh*0.7, w, h, 
    function() guistack_popanimated() end)
  winlab = label_new_center("You have won!", fontb, 
    winw/2, winh*0.3, {r=0,g=0,b=0})
end