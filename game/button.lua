require("font")
require("color")

local graph = love.graphics
local b1tex = graph.newImage("data/button.png")
local b2tex = graph.newImage("data/button2.png")

local button_inside = function(t, x, y)
  return t.x <= x and t.x+t.w >= x and t.y <= y and t.y+t.h >= y
end

function button_click(t, x, y)
  if button_inside(t, x, y) then
    t.clicked = true
    return true
  end
  return false
end

function button_release(t, x, y)
  if t.clicked and button_inside(t, x, y) then
    t.released = true
    t.clicked = false
    if t.action then
      t.action()
    end
    return true
  end
  t.clicked = false
  return false
end

function button_used(t)
  local s = t.released
  t.released = false
  return s
end

function button_draw(t)
  graph.translate(t.x, t.y)
  pushcolor()
  if t.clicked then
    graph.draw(b2tex, 0, 0, 0, t.w/b2tex:getWidth(), t.h/b2tex:getHeight())
  else 
    graph.draw(b1tex, 0, 0, 0, t.w/b1tex:getWidth(), t.h/b1tex:getHeight())
  end
  -- label
  pushfont()
  graph.setColor(0, 0, 0)
  graph.setFont(t.font)
  graph.print(t.label, t.lx, t.ly)
  popfont()
  popcolor()
  graph.translate(-t.x, -t.y)
end

function button_new(label, font, x, y, w, h, action)
  local t = {}
  t.label = label
  t.font = font
  t.x = x
  t.y = y
  t.w = w
  t.h = h
  t.action = action
  t.lx = (w-font:getWidth(label))/2
  t.ly = (h-font:getHeight())/2
  t.clicked = false
  t.released = false
  return t
end
