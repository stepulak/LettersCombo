require("conf")

fonts = nil
fontm = nil
fontb = nil

function font_load()
  fonts = love.graphics.newFont("data/font.ttf", math.floor(13*winw/winwbase))
  fontm = love.graphics.newFont("data/font.ttf", math.floor(15*winw/winwbase))
  fontb = love.graphics.newFont("data/font.ttf", math.floor(30*winw/winwbase))
end

local f = nil

function pushfont()
  f = love.graphics.getFont()
end

function popfont()
  love.graphics.setFont(f)
end