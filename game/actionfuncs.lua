require("guistack")
require("levelchooser")

function continue_func()
  
end

function newgame_func()
  
end

function chooselevel_func()
  guistack_pushanimated({update = levelchooser_update, draw = levelchooser_draw})
end

function about_func()
  
end

function lvlchooser_startgame_func()
end