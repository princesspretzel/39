local Light = require('light')
local Round = require('round')
local Star = require('star')

lights = { }

-- convert lines of lights to number of bulbs
function levelsToLightBulbs(levelNum)
  local total = 0
  for n = 1, levelNum do
    total = total + n
    n = n + 1
  end
  return total
end

-- create the tree shape
function stringLights(num)
  -- hardcode alert (radius-aware)
  xBase = (gameWidth / 2) - 10
  yBase = 200
  for row = 1, num do
    xBase = xBase - 20
    local x = xBase
    local y = yBase
    for col = 1, row do
      -- hardcode alert (https://stackoverflow.com/questions/17295861/how-to-create-concentric-triangles-with-cairo)
      y = y + 10
      x = x + 30
      local light = Light(x, y, ((levelsToLightBulbs(row-1))+col))
      table.insert(lights, light)
      col = col + 1
    end
    yBase = yBase + 40
    row = row + 1
  end
end

function love.load()
  gameWidth, gameHeight = love.graphics.getDimensions()
  won = false
  lost = false

  -- don't want to listen to this during development... or ever
  -- music = love.audio.newSource('/audio/bells.mp3')
  -- music:setLooping(true)
  -- music:play()
  
  -- used to build the game board
  local lines = 7
  totalLights = levelsToLightBulbs(lines)
  stringLights(lines)

  -- set the level, which is the number of lights that will go out from a gameplay POV
  local startLevel = 1
  currentRound = Round(startLevel)
  currentRound:generate()

  -- this will move out of here probably, or be deleted
  local starFile = '/images/basestart.png'
  local starImage = love.graphics.newImage(starFile)
  local starWidth, starHeight = starImage:getDimensions( )
  star = Star(starImage, starWidth, starHeight)
end

function love.draw()
  star:draw()
  for idx, light in ipairs(lights) do
    light:draw()
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  if key == "return" then
    love.event.quit("restart")
  end
end

function love.mousepressed(x, y, button, istouch)
  if button == 1 and (currentRound.playerTurn == true) then
    for idx, light in ipairs(lights) do
      light:mouseCollision(x, y)
    end
  end
end

function love.update(dt)
  currentRound:update(dt)
  star:update(dt)
  for idx, light in ipairs(lights) do
    light:update(dt)
  end
end