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
  deadBulbGuesses = { }
end

function clearSet()
  deadBulbs = { }
end

function roundClass:nextLevel()
  poweringDown = false
  doneFlashing = false
  playerTurn = false
  lost = false
  won = false
  clearGuesses()
  clearSet()
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
  while n <= numSet do
    local serialization = math.random(1, numLights)
    local unique = self:isUnique(serialization)
    if unique == true then
      table.insert(deadBulbs, 1, serialization)
      lights[serialization]:setFlashClock(n)
      n = n + 1
    end
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

function roundClass:turnOnAllBulbs()
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

function roundClass:powerOff()
  for idx, light in ipairs(lights) do
    light:setPowerOffClocks(idx)
  end
end

function roundClass:setFlashClock(startTime)
  self.flashClockStart = self.flashClockStart + startTime
  self.flashClockEnd = self.flashClockEnd + startTime
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
      self:turnOnAllBulbs()
    else
      self:countDownFlashClock(dt)
    end
  end
  if won == true then
    self:takeControlFromPlayer()
    -- self:nextLevel()
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