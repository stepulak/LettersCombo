fingerclicked = false
fingerreleased = false

function finger_position(x, y)
  return love.mouse.getPosition()
end

function finger_isdown()
  return love.mouse.isDown("l")
end