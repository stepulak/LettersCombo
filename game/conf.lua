winwbase = 240
winhbase = 320
winw = winwbase
winh = winhbase
gametitle = "Letters Combo"
gameauthor = "Stepan Trcka"

function love.conf(t)
  t.author = gameauthor
  t.identity = ""
  t.window.width = winw
  t.window.height = winh
  t.window.title = gametitle
  t.modules.physics = false
  t.console = true
end
