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
  if (y <= gameHeight/2 + 110) and (y >= gameHeight/2 + 50) then
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
  local titleImageFile = '/images/smalltransparenttitlewithsnow.png'
  local titleImage = love.graphics.newImage(titleImageFile)
  love.graphics.draw(titleImage, 30, -50)
  love.graphics.print('Fix the tree lights that lost power by clicking on them in the order they went out.', 40, gameHeight/2 - 30)
  love.graphics.print('Click to choose your difficulty level: ', 40, gameHeight/2 + 30)
  love.graphics.print('EASY', 100, gameHeight/2 + 80)
  love.graphics.print('MEDIUM', 200, gameHeight/2 + 80)
  love.graphics.print('HARD', 300, gameHeight/2 + 80)
  love.graphics.print('INSANE', 400, gameHeight/2 + 80)
  love.graphics.print('through fading memories we unwind' , 350, gameHeight - 100)
  love.graphics.print('the clock to show us a past hour', 350,gameHeight - 80)
  love.graphics.print('to watchfully ourselves remind', 350,gameHeight - 60)
  love.graphics.print('of how we might retrieve lost power', 350,gameHeight - 40)
end

return Setup