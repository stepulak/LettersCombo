require("linkedlist")

local stack = nil
local pushperforming = false
local popperforming = false
local removeprev = false
local slide_timer = 0.2
local timer = 0

function guistack_pushanimated(t)
  pushperforming = true
  stack:push_back(t)
end

function guistack_popanimated()
  if stack.head ~= stack.tail then
    popperforming = true
  end
end

function guistack_push(t)
  stack:push_back(t)
end

function guistack_pushanimated_removeprev(t)
  guistack_pushanimated(t)
  removeprev = true
end

function guistack_update(dt)
  if not pushperforming and not popperforming then
    stack.tail.elem.update(dt)
  else
    timer = timer+dt
    if timer >= slide_timer then
      timer = 0
      -- don't forget to delete the poped element!
      if popperforming then
	stack:pop_back()
      end
      if removeprev then
	stack:delete_elem(stack.tail.prev)
      end
      removeprev = false
      pushperforming = false
      popperforming = false
    end
  end
end

local graph = love.graphics

function guistack_draw()
  if pushperforming then
    graph.push()
    graph.translate(-timer/slide_timer*winw, 0)
    if stack.tail.prev then
      stack.tail.prev.elem.draw()
    end
    graph.translate(winw, 0)
    stack.tail.elem.draw()
    graph.pop()
  elseif popperforming then
    graph.push()
    graph.translate(timer/slide_timer*winw, 0)
    stack.tail.elem.draw()
    graph.translate(-winw, 0)
    if stack.tail.prev then
      stack.tail.prev.elem.draw()
    end
    graph.pop()
  elseif stack.tail then
    -- is there any element?
    stack.tail.elem.draw()
  end
end

function guistack_create()
  stack = create_linked_list()
end