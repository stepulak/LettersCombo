-- double-linked list
local linked_list_mt = {
  head = nil,
  tail = nil,
  push_front = function(t, w)
    if t.head == nil then
      t.head = { 
	prev = nil,
	nxt = nil,
	elem = w,
      }
      t.tail = t.head
    else
      t.head = {
	prev = nil,
	nxt = t.head,
	elem = w,
      }
      t.head.nxt.prev = t.head
    end
    return t.head
  end,
  pop_front = function(t)
    if t.head ~= nil then
      t.head.elem = nil
      if t.head.nxt == nil then
	t.head = nil
	t.tail = nil
      else
	local t2 = t.head.nxt
	t2.prev = nil
	t.head = t2
      end
    end
  end,
  push_back = function(t, w)
    if t.tail == nil then
      t.head = { 
	prev = nil,
	nxt = nil,
	elem = w
      }
      t.tail = t.head
    else
      t.tail = {
	prev = t.tail,
	nxt = nil,
	elem = w,
      }
      t.tail.prev.nxt = t.tail
    end
    return t.tail
  end,
  pop_back = function(t)
    if t.tail ~= nil then
      t.tail.elem = nil
      if t.tail.prev == nil then
	t.tail = nil
	t.head = nil
      else
	local t2 = t.tail.prev
	t2.nxt = nil
	t.tail = t2
      end
    end
  end,
  push_before = function(t, it, w)
    if t.head == nil or t.head == it or it == nil then
      t:push_front(w)
    else
      local e = {
	prev = it.prev,
	nxt = it,
	elem = w,
      }
      it.prev.nxt = e
      it.prev = e
    end
  end,
  delete_elem = function(t, w)
    if w == t.head then
      t:pop_front()
    elseif w == t.tail then
      t:pop_back()
    else
      w.elem = nil
      w.prev.nxt = w.nxt
      w.nxt.prev = w.prev
    end
  end,  
}
linked_list_mt.__index = linked_list_mt

function create_linked_list()
  return setmetatable({}, linked_list_mt)
end