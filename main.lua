local Light = require('light')
local Round = require('round')

gameWidth, gameHeight = love.graphics.getDimensions()
lights = { }

-- create the tree shape
function stringLights(num)
	-- hardcode alert (radius-aware)
  xBase = (gameWidth / 2) - 10
  yBase = 50
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

function levelsToLightBulbs(levelNum)
	local total = 0
	for n = 1, levelNum do
		total = total + n
		n = n + 1
	end
	return total
end

function love.load()
	-- io.write(' ')love.graphics.printf(text, 0, 0, love.graphics.getWidth())
	-- io.write('Choose a level from 3 to 10: ')
	-- level = io.read()
	level = 4
	guesses = 5
	currentRound = Round(level, guesses)

  stringLights(level)
  currentRound:generate(levelsToLightBulbs(level), guesses)
end

function love.draw()
	for idx, light in ipairs(lights) do
		light:draw()
	end
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		for idx, light in ipairs(lights) do
			light:mouseCollision(x, y)
		end
	end
end

function love.update(dt)
	currentRound:update(dt)
end