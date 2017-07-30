local setupClass = { }
setupClass.__index = setupClass
 
function Setup()
  local instance = {
    class = 'setup',
    level = 5 --default is medium
  }
  setmetatable(instance, setupClass)
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
  return levels
end

function setupClass:chooseLevel(x, y)
  -- default
  local level = self.level
  -- checks if you are on the choice line
  if (y <= gameHeight/2 + 30) and (y >= gameHeight/2 - 30) then
    local levels = self:levelEnums()
    if (x <= 130 and x >= 70) then
      level = levels[1]
    end
    if (x <= 230 and x >= 170) then
      level = levels[2]
    end
    if (x <= 330 and x >= 270) then
      level = levels[3]
    end
    if (x <= 430 and x >= 370) then
      level = levels[4]
    end
  end
  self.level = level
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