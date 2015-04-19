require("label")
require("button")
require("finger")

local labs = nil
local backbut = nil

function about_update(dt)
  local x, y = finger_position()
  if fingerclicked then
    button_click(backbut, x, y)
  elseif fingerreleased then
    button_release(backbut, x, y)
  end
end

function about_draw()
  for i=1,#labs do
    label_draw(labs[i])
  end
  button_draw(backbut)
end

function about_create()
  labs = {}
  labs[1] = label_new_center(gametitle, fontb, winw/2, 0,{r=0,g=0,b=0})
  labs[2] = label_new_center("(c) 2015 Stepan Trcka", fontm, winw/2, 70,{r=0,g=0,b=0})
  labs[3] = label_new_center("Source code at:", fontm, winw/2, 100,{r=0,g=0,b=0})
  labs[4] = label_new_center("https://github.com/stepulak/", fonts, winw/2, 140,
    {r=0,g=0,b=0})
  backbut = button_new("Back", fontm, winw/2-winw/6, 200, winw/3, winh/10, 
    guistack_popanimated)
end