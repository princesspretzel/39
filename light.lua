local lightClass = { }
lightClass.__index = lightClass
 
function Light(x, y, s)
  local instance = {
    class = 'light',
    s = s, -- serialization
    on = true,
    flashClockStart = 0, -- harcode alert, timeInterval-aware
    flashClockEnd = 2, -- harcode alert, timeInterval-aware
    timeInterval = 3, -- start to end inclusive
    doneFlashing = false,
    poweringDown = false,
    r = 10,
    x = x,
    y = y
  }
  setmetatable(instance, lightClass)
  return instance
end

function lightClass:setPowerOffClocks()
  local timeStep = .1
  local base = table.getn(lights)
  self.poweringDown = true
  self.flashClockEnd = base
  self.flashClockStart = self.flashClockEnd - (self.s * timeStep)
end

function lightClass:turnOff()
  self.on = false
end

function lightClass:turnOn()
  self.on = true
end

function lightClass:setFlashClock(setNum)
  self.flashClockEnd = self.flashClockEnd + (self.timeInterval * setNum) - 1
  self.flashClockStart = self.flashClockEnd - (self.timeInterval - 1)
end

function lightClass:countDownFlashClock(dt)
  if self.flashClockEnd <= self.flashClockStart then
    self:turnOn()
    -- preset
    self.flashClockEnd = 0
    self.flashClockStart = 0
  end
  self:turnOff()
  self.flashClockEnd = self.flashClockEnd - dt
end

function lightClass:addGuess()
  table.insert(deadBulbGuesses, self.s)
end

function lightClass:mouseCollision(x, y)
  local xClick = false
  local yClick = false
  if x < (self.x + self.r) and x > (self.x - self.r) then
    xClick = true
  end
  if y < (self.y + self.r) and y > (self.y - self.r) then
    yClick = true
  end
  if xClick and yClick then
    self:turnOff()
    self:addGuess()
    checkGuesses()
  end
end

function lightClass:draw()
  love.graphics.setColor(255, 255, 255)
  if (self.on == true) then
    love.graphics.circle('fill', self.x, self.y, self.r)
  else
    love.graphics.circle('line', self.x, self.y, self.r)
  end
end

function lightClass:update(dt)
  if self.poweringDown == true then
    self.flashClockEnd = self.flashClockEnd - dt
    if self.flashClockEnd <= self.flashClockStart then
      self:turnOff()
    end
  end
end

return Light