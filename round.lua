local roundClass = { }
roundClass.__index = roundClass

-- the Light class needs to see these too
deadBulbs = { }
deadBulbGuesses = { }

function Round(level, guesses)
  local instance = {
    class = 'round',
    numLights = level,
    flashClockStart = 0,
    flashClockEnd = 3*guesses,
    playerTurn = false,
    doneFlashing = false,
    over = false
  }
  setmetatable(instance, roundClass)
  return instance
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
      print('you lost.')
      return false
    end
  end
  if table.getn(deadBulbGuesses) == table.getn(deadBulbs) then
    won = true
    print('you won!')
  end
  return true
end

function roundClass:giveControlToPlayer()
  for idx, serialization in ipairs(deadBulbs) do
    lights[serialization]:turnOn()
  end
  self.playerTurn = true
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
    else
      self:countDownFlashClock(dt)
    end
  end
end

return Round