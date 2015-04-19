require("button")
require("stringfuncs")
require("finger")
require("windialog")

local graph = love.graphics
local wstart = winw*0.03
local hstart = winh*0.1
local wend = winw*0.97
local hend = winh*0.8
local wbox = winw-wstart-(winw-wend)
local hbox = winh-hstart-(winh-hend)

local createblock = function(c)
  local t = { 
    letter = c, 
    first_letter = c,
    word = false,
    stone = false,
    picked = false,
    shuffle = false,
  }
  -- # = stoned position
  -- @ = empty space
  if c == "#" then
    t.stone = true
  elseif c == "@" then
    t.letter = " "
    t.first_letter = " "
  end
  return t
end

local blocks = nil
local errmsg = nil
local gw, gh

local set_word_position = function(x, y, dirx, diry, len)
  for i=1,len do
    if x >= 0 and x < gw and y >= 0 and y < gh then
      blocks[y][x].word = true
    end
    x = x+dirx
    y = y+diry
  end
end

local loadlines = function(content, i)
  if gw ~= nil and gh ~= nil then
    local letters
    blocks = {}
    for y=0,gh-1 do
      blocks[y] = {}
      letters = split_line_letters(content[i][1])
      for x=0,gw-1 do
	blocks[y][x] = createblock(letters[x+1])
      end
      i = i+1
    end
  else
    errmsg = "Game proportions haven't been set yet."
  end
  return i-1
end

local bs = 40*(winw/winwbase)
local fontblock = graph.newFont("data/font.ttf", bs-4)
local picked = graph.newImage("data/blockpicked.png")
local shuffle = graph.newImage("data/blockshuffle.png")
local norm = graph.newImage("data/blocknormal.png")
local stone = graph.newImage("data/blockstone.png")
local wordback = graph.newImage("data/wordbackground.png")
local show_goals

local drawletter = function(l, x, y)
  pushfont()
  graph.setFont(fontblock)
  local w, h = fontblock:getWidth(l), fontblock:getHeight()
  graph.print(l, x+(bs-w)/2, y+(bs-h)/2-2)
  popfont()
end

local drawblock = function(b, x, y, shuffle_performed)
  if show_goals then
    if b.word then
      graph.draw(picked, x, y, 0, bs/picked:getWidth(), bs/picked:getHeight())
      drawletter(b.first_letter, x, y)
    else
      graph.draw(norm, x, y, 0, bs/norm:getWidth(), bs/norm:getHeight())
    end
  elseif b.stone then
    graph.draw(stone, x, y, 0, bs/stone:getWidth(), bs/stone:getHeight())
  else
    if b.picked then
      graph.draw(picked, x, y, 0, bs/picked:getWidth(), bs/picked:getHeight())
    elseif b.shuffle then
      graph.draw(shuffle, x, y, 0, bs/shuffle:getWidth(), bs/shuffle:getHeight())
    else
      graph.draw(norm, x, y, 0, bs/norm:getWidth(), bs/norm:getHeight())
    end
    drawletter(b.letter, x, y)
  end
end

local drawarea_wordpos = function()
  local o = bs/bs
  for i=0,gh-1 do
    for j=0,gh-1 do
      -- because the background for position where is the word's letter placed
      -- cannot be translated or moved, you have to draw it separately
      if blocks[i][j].word then
	pushcolor()
	graph.setColor(0, 0, 0, 100)
	graph.rectangle("fill", j*bs, i*bs, bs, bs)
	popcolor()
      end
    end
  end
end

local drawarea_spec = function(x1, y1, x2, y2)
  for i=y1,y2 do
    for j=x1,x2 do
      drawblock(blocks[i][j], j*bs, i*bs)
    end
  end
end

local camx, camy
local rw, rh

-- Shuffle variables
local shuffle_performing
local shuffle_hor
local shuffle_LU -- shuffle LEFT, UP (boolean)
local shuffle_pos
local shuffle_time
local shuffle_len
local shuffle_dir -- 1, -1

local shuffle_fast_horizontal = function(x, y, x2, y2)
  local tmp = {}
  for i=0,gw-1 do
    if blocks[y][i].stone == true then return end
    tmp[i] = blocks[y][i].letter
  end
  local d = x2-x
  if d > 0 then
    for i=d,gw+d-1 do
      blocks[y][math.fmod(i, gw)].letter = tmp[i-d]
    end
  elseif d < 0 then
    d = -d
    for i=d,gw+d-1 do
      blocks[y][i-d].letter = tmp[math.fmod(i, gw)]
    end
  end
end

local shuffle_fast_vertical = function(x, y, x2, y2)
  local tmp = {}
  for i=0,gh-1 do
    if blocks[i][x].stone == true then return end
    tmp[i] = blocks[i][x].letter
  end
  local d = y2-y
  if d > 0 then
    for i=d,gh+d-1 do
      blocks[math.fmod(i, gh)][x].letter = tmp[i-d]
    end
  elseif d < 0 then
    d = -d
    for i=d,gh+d-1 do
      blocks[i-d][x].letter = tmp[math.fmod(i, gh)]
    end
  end
end

local shufflebuf = nil

local shuffle_fast = function(x, y, dirx, diry, length, save)
  if dirx ~= 0 then
    length = math.fmod(length, gw)
  else
    length = math.fmod(length, gh)
  end
  local x2, y2 = x+dirx*length, y+diry*length
  if x2 < 0 then
    x2 = x2+gw
  elseif x2 >= gw then
    x2 = x2-gw
  end
  if y2 < 0 then
    y2 = y2+gh
  elseif y2 >= gh then
    y2 = y2-gh
  end
  if dirx ~= 0 then
    shuffle_fast_horizontal(x, y, x2, y2)
  else
    shuffle_fast_vertical(x, y, x2, y2)
  end
  if save then
    shufflebuf[#shufflebuf+1] = { 
      ["x"] = x,
      ["y"] = y,
      ["dirx"] = dirx,
      ["diry"] = diry,
      ["length"] = length
    }
  end
end

local animation_time = 0.25

local shuffle_animated = function(x1, y1, x2, y2)
  local x, y = x2-x1, y2-y1
  if x ~= 0 and y ~= 0 then
    -- No shuffle possible, because the shuffle must take part 
    -- in absolute vertical or horizontal direction!
    return
  end
  if x ~= 0 then
    -- Horizontal shuffle
    shuffle_pos = y1
    shuffle_hor = true
    shuffle_LU = x < 0
    shuffle_len = math.abs(x)
  elseif y ~= 0 then
    shuffle_pos = x1
    shuffle_hor = false
    shuffle_LU = y < 0
    shuffle_len = math.abs(y)
  else
    return
  end
  shuffle_dir = 1
  if shuffle_LU then
    shuffle_dir = -1
  end
  shuffle_performing = true
  shuffle_time = animation_time
end

local drawshuffled_hor = function()
  local o = (math.fmod(shuffle_time, animation_time)/animation_time)*bs
  graph.push()
  if o == 0 then
    o = bs
  end
  if shuffle_LU then
    graph.translate(o-bs, 0)
    drawarea_spec(0, shuffle_pos, gw-1, shuffle_pos)
    drawblock(blocks[shuffle_pos][0], rw, shuffle_pos*bs)
  else
    graph.translate(-o, 0)
    drawblock(blocks[shuffle_pos][gw-1], 0, shuffle_pos*bs)
    graph.translate(bs, 0)
    drawarea_spec(0, shuffle_pos, gw-1, shuffle_pos)
  end
  graph.pop()
end

local drawshuffled_ver = function()
  local o = (math.fmod(shuffle_time, animation_time)/animation_time)*bs
  graph.push()
  if o == 0 then
    o = bs
  end
  if shuffle_LU then
    graph.translate(0, o-bs)
    drawarea_spec(shuffle_pos, 0, shuffle_pos, gh-1)
    drawblock(blocks[0][shuffle_pos], shuffle_pos*bs, rh)
  else
    graph.translate(0, -o)
    drawblock(blocks[gh-1][shuffle_pos], shuffle_pos*bs, 0)
    graph.translate(0, bs)
    drawarea_spec(shuffle_pos, 0, shuffle_pos, gh-1)
  end
  graph.pop()
end

local drawarea = function()
  graph.push()
  graph.translate(camx, camy)
  drawarea_wordpos()
  if shuffle_performing then
    if shuffle_hor then
      drawarea_spec(0, 0, gw-1, shuffle_pos-1)
      drawarea_spec(0, shuffle_pos+1, gw-1, gh-1)
      drawshuffled_hor()
    else
      drawarea_spec(0, 0, shuffle_pos-1, gh-1)
      drawarea_spec(shuffle_pos+1, 0, gw-1, gh-1)
      drawshuffled_ver()
    end
  else
    drawarea_spec(0, 0, gw-1, gh-1)
  end
  graph.pop()
end

local check_grid = function()
  for j=0,gh-1 do
    for i=0,gw-1 do
      if blocks[j][i].word and 
	  blocks[j][i].letter ~= blocks[j][i].first_letter then
	return
      end
    end
  end
  guistack_pushanimated_removeprev({draw=windialog_draw,update=windialog_update})
end

local update_shuffle = function(dt)
  if shuffle_performing then
    shuffle_time = shuffle_time-dt
    if shuffle_time <= 0 then
      shuffle_time = animation_time
      shuffle_len = shuffle_len-1
      if shuffle_hor then
	shuffle_fast(0, shuffle_pos, shuffle_dir, 0, 1, true)
      else
	shuffle_fast(shuffle_pos, 0, 0, shuffle_dir, 1, true)
      end
      if shuffle_len <= 0 then
	shuffle_performing = false
	check_grid()
      end
    end
  end
end

local move_camera = function(x, y)
  if x ~= 0 and rw > wbox then
    camx = camx+x
    if camx > wstart then
      camx = wstart
    elseif camx < wend-rw then
      camx = wend-rw
    end
  end
  if y ~= 0 and rh > hbox then
    camy = camy+y
    if camy > hstart then
      camy = hstart
    elseif camy < hend-rh then
      camy = hend-rh
    end
  end
end

local getxy_finger = function(x, y)
  if (rw < wbox and (x < camx or x > camx+rw)) or x < wstart or x > wend then
    x = -999
  end
  if (rh < hbox and (y < camy or y > camy+rh)) or y < hstart or y > hend then
    y = -999
  end
  return x-camx, y-camy
end

local canshuffle = function(x, y, dx, dy)
  -- can you make shuffle in this way?
  while x >= 0 and x < gw and y >= 0 and y < gh do
    if blocks[y][x].stone then
      return false
    end
    x = x+dx
    y = y+dy
  end
  return true
end

local markshuffle = function(x, y, dx, dy)
  while x >= 0 and x < gw and y >= 0 and y < gh do
    blocks[y][x].shuffle = true
    x = x+dx
    y = y+dy
  end
end

local pick_letter = function(x, y)
  local l = canshuffle(x, y, -1, 0)
  local r = canshuffle(x, y, 1, 0)
  local u = canshuffle(x, y, 0, -1)
  local d = canshuffle(x, y, 0, 1)
  if l and r then
    markshuffle(x, y, 1, 0)
    markshuffle(x, y, -1, 0)
  end
  if u and d then
    markshuffle(x, y, 0, 1)
    markshuffle(x, y, 0, -1)
  end
  blocks[y][x].picked = true
end

local unpick_letter = function()
  -- iterate through grid and delete all marks
  for i=0,gh-1 do
    for j=0,gw-1 do
      blocks[i][j].picked = false
      blocks[i][j].shuffle = false
    end
  end
end

local but_showgoals = nil
local but_showgrid = nil
local but_reset = nil

local fx, fy = -1, -1
local blockx, blocky = -1, -1

function game_click(x, y)
  -- first handle game buttons, then the grid manipulation
  if button_click(but_reset, x, y) then
    return true
  elseif show_goals == false and button_click(but_showgoals, x, y) then
    return true
  elseif show_goals and button_click(but_showgrid, x, y) then
    return true
  end
  -- blocks manipulation
  if shuffle_performing == false then
    x, y = getxy_finger(x, y)
    if x < 0 or y < 0 then
      return false
    end
    blockx = math.floor(x/bs)
    blocky = math.floor(y/bs)
  end
  return true
end

local letterpicked = false
local pickedx, pickedy = -1, -1
local num_shuffles = 0
local min_shuffles

local action_showgoals_onoff = function()
  show_goals = not show_goals
end

local action_resetgrid = function()
  local s
  for i=#shufflebuf,1,-1 do
    s = shufflebuf[i]
    shuffle_fast(s.x, s.y, -s.dirx, -s.diry, s.length, false) 
  end
  shufflebuf = {}
end

function game_release(x, y)
  -- handle game buttons
  if button_release(but_reset, x, y) then
    return true
  elseif show_goals == false and button_release(but_showgoals, x, y) then
    return true
  elseif show_goals and button_release(but_showgrid, x, y) then
    return true
  end
  -- blocks manipulation
  if shuffle_performing == false then
    x, y = getxy_finger(x, y)
    if x < 0 or y < 0 then
      return false
    end
    x = math.floor(x/bs)
    y = math.floor(y/bs)
    if x == blockx and y == blocky then
      if letterpicked then
	letterpicked = false
	if blocks[y][x].shuffle then
	  shuffle_animated(pickedx, pickedy, x, y)
	  num_shuffles = num_shuffles+1
	end
	unpick_letter()
	pickedx, pickedy = -1, -1
      else
	pick_letter(x, y)
	letterpicked = true
	pickedx = x
	pickedy = y
      end
    end
  end
  return true
end

function game_update(dt)
  update_shuffle(dt)
  -- first click, get finger position!
  if fingerclicked then
    fx, fy = finger_position()
    game_click(fx, fy)
  elseif fingerreleased then
    game_release(fx, fy)
  end
  if finger_isdown() then
    -- get current finger position and update the old one
    local x, y = finger_position()
    local x2, y2 = getxy_finger(x, y)
    if x2 > 0 and y2 > 0 then
      move_camera(x-fx, y-fy)
    end
    fx, fy = x, y
  end
end

function game_draw()
  local x, y, w, h = wstart, hstart, rw, rh
  if x < camx then
    x = camx
  end
  if y < camy then
    y = camy
  end
  if rw > wbox then
    w = wbox
  end
  if rh > hbox then
    h = hbox
  end
  graph.setScissor(x, y, w, h)
  drawarea()
  graph.setScissor()
  if show_goals then
    button_draw(but_showgrid)
  else
    button_draw(but_showgoals)
  end
  button_draw(but_reset)
end

function game_create(filename)
  -- Load the content and split words in lines from given file
  local content, line = {}
  for line in love.filesystem.lines(filename) do
    content[#content+1] = split_line_space(line)
  end
  wordlist = {}
  min_shuffles = 0
  local i = 1
  -- Perform operations with the game
  while i <= #content do
    if content[i][1] == "proportions" then
      gw = tonumber(content[i][2])
      gh = tonumber(content[i][3])
    elseif content[i][1] == "lines" then
      i = loadlines(content, i+1)
    elseif content[i][1] == "//" then
      -- Comment, ignore this line
    elseif content[i][1] == "word" then
      -- Word position
      set_word_position(tonumber(content[i][2]), tonumber(content[i][3]), 
	tonumber(content[i][4]), tonumber(content[i][5]), tonumber(content[i][6]))
    elseif content[i][1] == "shuffle" then
      shuffle_fast(tonumber(content[i][2]), tonumber(content[i][3]), 
	tonumber(content[i][4]), tonumber(content[i][5]), 
	tonumber(content[i][6]), false)
      min_shuffles = min_shuffles+1
    end
    i = i+1
  end
  rw = gw*bs
  rh = gh*bs
  show_goals = false
  shuffle_performing = false
  -- shuffle history
  shufflebuf = {}
  -- if the grid is larger than the window, you can move with camera on it
  -- if not, count the camera position and set the grid on the center
  -- of the window
  if rw < wbox then
    camx = wstart+(wbox-rw)/2
  else
    camx = wstart
  end
  if rh < hbox then
    camy = hstart+(hbox-rh)/2
  else
    camy = hstart
  end
  -- and don't forget to create buttons
  local offx = 10
  local offy = 15
  local hcoef = 0.6
  but_showgoals = button_new("Show words", fontm, offx, hend+offy, 
    winw/2-2*offx, (winh-hend)*hcoef, action_showgoals_onoff)
  but_showgrid = button_new("Show grid", fontm, offx, hend+offy, 
    winw/2-2*offx, (winh-hend)*hcoef, action_showgoals_onoff)  
  but_reset = button_new("Reset grid", fontm, winw/2+offx, hend+offy,
    winw/2-2*offx, (winh-hend)*hcoef, action_resetgrid)
end