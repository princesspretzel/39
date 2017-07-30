local setupClass = { }
setupClass.__index = setupClass
 
function Setup(x, y, s)
  local instance = {
    class = 'setup',
    level = 5 --default is medium
  }
  setmetatable(instance, lightClass)
  return instance
end

function setupClass:levelEnums()
  local levels = { }
  local easy = 5
  table.insert(levels, easy)
  local medium = 7
  table.insert(levels, medium)
  local hard = 10
  table.insert(levels, hard)
  local insane = totalLights
  table.insert(levels, insane)

  -- for dev
  for idx, lvl in ipairs(levels) do
    print('idx: ', idx)
    print('lvl: ', lvl)
  end
  return levels
end

function setupClass:draw()
  love.graphics.print('Fix the bulbs that lost power by clicking on them in the order they went out.', 40, gameHeight/2 - 30)
  love.graphics.print('Click to choose your level: ', 40, gameHeight/2 - 10)
  love.graphics.print('Easy', 100, gameHeight/2 + 10)
  love.graphics.print('Medium', 200, gameHeight/2 + 10)
  love.graphics.print('Hard', 300, gameHeight/2 + 10)
  love.graphics.print('Insane', 400, gameHeight/2 + 10)
  love.graphics.print('Press enter to start.', 40, gameHeight/2 + 30)
end

return Setup