
function split_line_space(line)
  local t = {}
  for token in string.gmatch(line, "[^%s]+") do
    t[#t+1] = token
  end
  return t
end

function split_line_letters(line)
  local t = {}
  for i=1,#line do
    t[i] = string.sub(line, i, i)
  end
  return t
end

function split_line_path(line)
  local t = {}
  for token in string.gmatch(line, "%w+") do
    t[#t+1] = token
  end
  return t
end
