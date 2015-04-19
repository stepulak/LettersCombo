local graph = love.graphics

function label_draw(t)
  local f = graph.getFont()
  local r, g, b = graph.getColor()
  graph.setColor(t.col.r, t.col.g, t.col.b)
  graph.setFont(t.font)
  graph.print(t.label, t.x, t.y)
  graph.setFont(f)
  graph.setColor(r, g, b)
end

function label_new(label, font, x, y, col)
  local t = {}
  t.label = label
  t.font = font
  t.x = x
  t.y = y
  t.w = font:getWidth(label)
  t.h = font:getHeight()
  t.col = col
  return t
end

function label_new_center(label, font, x, y, col)
  local t = label_new(label, font, x, y, col)
  t.x = t.x-font:getWidth(label)/2
  return t
end