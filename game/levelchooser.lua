require("button")
require("label")
require("font")
require("finger")
require("color")
require("game")

local graph = love.graphics

local scroll = 0
local boxh = winh*0.6 -- box height
local wpadding = 0.15 -- padding from left and right
local optionh = winh*0.15
local optionw = winw-2*wpadding*winw
local optionrealh = optionh*0.8
local startex = graph.newImage("data/star.png")

local level_draw = function(lvl)
  -- background
  pushcolor()
  graph.setColor(39, 147, 230, 128)
  graph.rectangle("fill", 0, 0, optionw, optionrealh)
  -- draw stars = level difficulty
  graph.setColor(255, 255, 255, 255)
  local starw = (optionrealh/2)
  local starscw, starsch = starw/startex:getWidth(), starw/startex:getHeight()
  graph.push()
  graph.translate(optionw-5, starw/2)
  for i=1,lvl.difficulty do
    graph.translate(-starw, 0)
    graph.draw(startex, 0, 0, 0, starscw, starsch)
  end
  graph.pop()
  -- and the level name
  pushfont()
  graph.setFont(fontm)
  graph.setColor(0, 0, 0)
  graph.print(lvl.name, 5, (optionrealh-fontm:getHeight())/2)
  popfont()
  popcolor()
end

local lvlinfo = nil
local framex = wpadding*winw
local framey = (winh-boxh)/2
local lvlclicked = -1
local backbut = nil
local startbut = nil
local lab = nil

function levelchooser_activelevel()
  return lvlinfo[lvlclicked+1]
end

function levelchooser_draw()
  local i = math.floor(scroll/optionh)
  local n = i+math.floor(boxh/optionh)+1
  -- check the overflow
  if i < 0 then
    i = 0
  end
  if n >= #lvlinfo then
    n = #lvlinfo-1
  end
  graph.push()
  graph.translate(framex, framey+2-math.fmod(scroll, optionh))
  graph.setScissor(framex, framey, optionw, boxh)
  if lvlclicked >= i and lvlclicked <= n then
    pushcolor()
    graph.setColor(0, 0, 0)
    graph.setLineWidth(2)
    graph.rectangle("line", 0, lvlclicked*optionh, optionw, optionrealh)
    graph.setLineWidth(1)
    popcolor()
  end
  -- draw levels
  while i <= n do
    level_draw(lvlinfo[i+1])
    graph.translate(0, optionh)
    i = i+1
  end
  graph.setScissor() -- reset
  graph.pop()
  -- and finally draw the scroll indicator
  pushcolor()
  graph.setColor(128, 128, 128, 128)
  local sw = 10*(winw/winwbase)
  local sh = 40*(winh/winhbase)
  local sy = scroll/(#lvlinfo*optionh-boxh)*(boxh-sh)
  graph.rectangle("fill", framex+optionw+sw, sy+framey, sw, sh)
  popcolor()
  button_draw(backbut)
  button_draw(startbut)
  label_draw(lab)
end

function levelchooser_click(x, y)
  if x >= framex and x <= framex+optionw and y >= framey and y <= framey+boxh then
    local i = math.floor((y-framey-math.fmod(scroll, optionh))/optionh)
    lvlclicked = i
    return true
  elseif button_click(backbut, x, y) or button_click(startbut, x, y) then
    return true
  end
  return false
end

function levelchooser_release(x, y)
  return button_release(backbut, x, y) or button_release(startbut, x, y)
end

local dragperforming = false
local prevmpos = -1

function levelchooser_update(dt)
  local x, y = finger_position()
  if fingerclicked then
    if levelchooser_click(x, y) then
      dragperforming = true
      prevmpos = y
    end
  elseif fingerreleased then
    levelchooser_release(x, y)
    dragperforming = false
  end
  -- update scrolling if finger is still pressed
  if dragperforming == true then
    scroll = scroll+(prevmpos-y)
    -- and check overflow
    if scroll >= #lvlinfo*optionh-boxh then
      scroll = #lvlinfo*optionh-boxh
    end
    if scroll < 0 then
      scroll = 0
    end
    prevmpos = y
  end
end

local load_level_paths = function()
  lvlinfo = {}
  local i = 1
  local content
  local filename
  while love.filesystem.exists("levels/lvl"..i..".info") do
    filename = "levels/lvl"..i..".info"
    content = {}
    for line in love.filesystem.lines(filename) do
      content[#content+1] = split_line_space(line)
    end
    lvlinfo[i] = {}
    for j=1,#content do
      if content[j][1] == "name" then
	-- join all the words into one
	lvlinfo[i].name = ""
	for k=2,#content[j] do
	  lvlinfo[i].name = lvlinfo[i].name .. content[j][k] .. " "
	end
      elseif content[j][1] == "difficulty" then
	lvlinfo[i].difficulty = tonumber(content[j][2])
      end
    end
    lvlinfo[i].filename = "levels/lvl"..i..".lvl"
    i = i+1
  end
end

local startgame = function()
  local lvl = levelchooser_activelevel()
  if lvl ~= nil then
    game_create(lvl.filename)
    guistack_pushanimated({draw = game_draw, update = game_update})
  end
end

function levelchooser_create()
  load_level_paths()
  -- buttons
  local posx = 10
  local posy = framey+boxh+20
  backbut = button_new("Back", fonts, posx, posy, winw/2-2*posx, 
    optionrealh-2, guistack_popanimated)
  startbut = button_new("Start", fonts, winw/2+posx, posy, winw/2-2*posx, 
    optionrealh-2, startgame)
  -- title
  lab = label_new_center("Choose level", fontb, winw/2, 0, {r=0,g=0,b=0})
end