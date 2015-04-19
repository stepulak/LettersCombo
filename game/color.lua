require("linkedlist")

local l = create_linked_list()

function pushcolor()
  local r, g, b, a = love.graphics.getColor()
  l:push_back({r,g,b,a})
end

function popcolor()
  local r, g, b, a = l.tail.elem[1], l.tail.elem[2], l.tail.elem[3], l.tail.elem[4]
  l:pop_back()
  love.graphics.setColor(r, g, b, a)
end