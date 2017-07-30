local roundClass = { }
roundClass.__index = roundClass

-- light needs access to these
deadBulbs = { }
deadBulbGuesses = { }

function Round(guesses)
  local instance = {
    class = 'round',
    numLights = guesses,
    flashClockStart = 0,
    flashClockEnd = 3*guesses,
    playerTurn = false,
    doneFlashing = false,
    poweringDown = false
  }
  setmetatable(instance, roundClass)
  return instance
end

function clearGuesses()
  local len = table.getn(deadBulbGuesses)
  local n = 1
  while n <= len do
    table.remove(deadBulbGuesses, 1)
    n = n + 1
  end
end

function clearSet()
  local len = table.getn(deadBulbs)
  local n = 1
  while n <= len do
    table.remove(deadBulbs, 1)
    n = n + 1
  end 
end

function roundClass:clearStoredVariables()
  self.poweringDown = false
  self.doneFlashing = false
  self.playerTurn = false
  lost = false
  won = false
  clearGuesses()
  clearSet()
end

function roundClass:nextLevel()
  self:turnOnDeadBulbs() -- this acts on dead bulbs only
  self:clearStoredVariables()
  self:resetAllBulbs()
  self.numLights = self.numLights + 1
  self:generate(totalLights, self.numLights)
  self:setFlashClock(self.numLights)
end

-- deadBulb is a serialization number
function roundClass:isUnique(deadBulb)
  local deadBulbLength = table.getn(deadBulbs)
  local unique = true
  if deadBulbLength > 0 then
    for idx, db in ipairs(deadBulbs) do
      if deadBulb == db then
        unique = false
        break
      end
    end
  end
  return unique
end

-- numLights will probably never change
-- numSet will increase with level
function roundClass:generate(numLights, numSet)
  -- https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
  math.randomseed(os.time())
  local n = 1
  print('level: ', numSet)
  while n <= numSet do
    local serialization = math.random(1, numLights)
    local unique = self:isUnique(serialization)
    if unique == true then
      table.insert(deadBulbs, 1, serialization)
      lights[serialization]:setFlashClock(n)
      n = n + 1
    end
    print('dead bulb sequence (backwards): ', serialization)
  end
end

-- check the serializations of both the array
-- of dead bulbs and dead bulb guesses, guesses
-- first because it will usually be shorter
function checkGuesses()
  local deadBulbLength = table.getn(deadBulbs)
  local deadBulbGuessesLength = table.getn(deadBulbGuesses)
  for idx, guess in ipairs(deadBulbGuesses) do
    if guess ~= deadBulbs[idx] then
      lost = true
    end
  end
  if table.getn(deadBulbGuesses) == table.getn(deadBulbs) then
    won = true
  end
end

-- the effect of this should be all bulbs are on
function roundClass:turnOnDeadBulbs()
  for idx, serialization in ipairs(deadBulbs) do
    lights[serialization]:turnOn()
  end
end

function roundClass:giveControlToPlayer()
  self.playerTurn = true
end

function roundClass:takeControlFromPlayer()
  self.playerTurn = false
end

function roundClass:resetAllBulbs()
  for idx, light in ipairs(lights) do
    light:resetState()
  end
end

function roundClass:powerOff()
  self.doneFlashing = false
  for idx, light in ipairs(lights) do
    light:setPowerOffClocks(idx)
  end
end

function roundClass:setFlashClock(numLights)
  self.flashClockStart = 0
  self.flashClockEnd = self.flashClockStart + (3*numLights)
end

function roundClass:countDownFlashClock(dt)
  if self.flashClockEnd <= self.flashClockStart then
    self.doneFlashing = true
    return
  end
 
  for idx, serialization in ipairs(deadBulbs) do
    if self.flashClockEnd <= lights[serialization].flashClockEnd and self.flashClockEnd >= lights[serialization].flashClockStart then
      lights[serialization]:countDownFlashClock(dt)
    end
  end
  self.flashClockEnd = self.flashClockEnd - dt
end

function roundClass:update(dt)
  if self.playerTurn == false then
    if self.doneFlashing == true then
      self:giveControlToPlayer()
      self:turnOnDeadBulbs()
    else
      self:countDownFlashClock(dt)
    end
  end
  if won == true then
    self:takeControlFromPlayer()
    if self.numLights <= totalLights then
      self:nextLevel()
      -- these will get you into countdown above once
      self.playerTurn = false
      self.doneFlashing = false
    end
  end
  if lost == true then
    self:takeControlFromPlayer()
    if self.poweringDown == false then
      self.poweringDown = true
      self:powerOff()
    end
  end
end

return Round