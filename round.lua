local roundClass = { }
roundClass.__index = roundClass

-- light needs access to these
deadBulbs = { }
deadBulbGuesses = { }

function Round(lvl)
  local instance = {
    class = 'round',
    level = lvl,
    flashClockStart = 0,
    flashClockEnd = 3*lvl,
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
  wonLevel = false
  clearGuesses()
  clearSet()
end

function roundClass:nextLevel()
  self:turnOnDeadBulbs()
  self:clearStoredVariables()
  self:resetAllBulbs()
  self.level = self.level + 1
  self:generate()
  self:setFlashClock()
end

function roundClass:levelTitle()
  if currentRound.level < 5 then
    love.window.setTitle('hope u ate yr wheaties this morn')
  end
  if currentRound.level >= 5 and currentRound.level < 10 then
    love.window.setTitle('you are pretty impressive')
  end
  if currentRound.level >= 10 and currentRound.level < 15 then
    love.window.setTitle('this is better than i, the maker of this game, ever did')
  end
  if currentRound.level >= 11 and currentRound.level < 20 then
    love.window.setTitle('holey heck wot a good memory brain you hav')
  end
  if currentRound.level >= 21 and currentRound.level < 25 then
    love.window.setTitle('omgomgomgomgomgomgomgomg')
  end
  if currentRound.level >= 26 and currentRound.level < 28 then
    love.window.setTitle('GO FOR IT WOW BABY JEEBULOUS U CAN DO IT')
  end
  if lost == true then
    love.window.setTitle('the loosermas is ruined')
  end
  if (wonGame == true) and (currentRound.level ~= maxLevel) then
    love.window.setTitle('GREAT JOB! you saved the wintersmas!!! maybe you are ready for an even harder lvl...')
  end
  if (wonGame == true) and (currentRound.level == maxLevel) then
    love.window.setTitle('WOW, AMAZING, YOU are a Golden God!!!')
  end
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

function roundClass:generate()
  -- https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
  math.randomseed(os.time())
  local n = 1
  print('current level: ', self.level)
  while n <= self.level do
    local serialization = math.random(1, totalLights)
    local unique = self:isUnique(serialization)
    if unique == true then
      table.insert(deadBulbs, 1, serialization)
      lights[serialization]:setFlashClock(n)
      n = n + 1
    end
    print('dead bulb sequence (backwards) for cheating & dev: ', serialization)
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
    wonLevel = true
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

function roundClass:setFlashClock()
  self.flashClockStart = 0
  self.flashClockEnd = self.flashClockStart + (3*self.level)
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

function isFinalLightOff()
  if (lights[level].flashClockEnd <= lights[level].flashClockEnd) and (lights[level].on == false) and (lost == true) then
    return true
  end
  return false
end

function roundClass:update(dt)
  self.levelTitle()
  if self.playerTurn == false then
    if self.doneFlashing == true then
      self:giveControlToPlayer()
      self:turnOnDeadBulbs()
    else
      self:countDownFlashClock(dt)
    end
  end
  if wonLevel == true then
    self:takeControlFromPlayer()
    if self.level < maxLevel then
      self:nextLevel()
      -- these will get you into countdown above once
      self.playerTurn = false
      self.doneFlashing = false
    else
      wonGame = true
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