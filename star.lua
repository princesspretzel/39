local stars = require('stars')

local starClass = { }
starClass.__index = starClass

function Star(image, width, height)
  local instance = {
    class = 'star',
    i = image,
    w = width,
    h = height,
    r = 0, --radians, for spin
    x = ((gameWidth / 2) - (width / 2)),
    y = 20
  }
  setmetatable(instance, starClass)
  return instance
end

function starClass:getWinningImageAtIdx(idx)
  local starFiles = { }
  local winStar1File = '/images/winstar1t.png'
  table.insert(starFiles, winStar1File)
  local winStar2File = '/images/winstar2t.png'
  table.insert(starFiles, winStar2File)
  return starFiles[idx]
end

function starClass:winningImageOscillation(idx)
  local starFile = self:getWinningImageAtIdx(idx)
  self:assignNewImage(starFile)
end

function starClass:won()
  local choice = math.random(1,2)
  self:winningImageOscillation(choice)
  -- this might be fun (later)
  -- self.r = math.random(-2,2)
end

function starClass:lost()
  local lostStarFile = '/images/loststart.png'
  starClass:assignNewImageFromFile(lostStarFile)
end

function starClass:nextLevel(lvl)
  local starFile = stars[lvl]
  if starFile == nil then
    starFile = '/images/basestart.png'
  end
  self:assignNewImageFromFile(starFile)
end

function starClass:assignNewImageFromFile(starFile)
  local starImage = love.graphics.newImage(starFile)
  self.i = starImage
end

function starClass:draw()
  love.graphics.draw(self.i, self.x, self.y, self.r)
end

function starClass:update(dt)
  if won == true then
    self:won()
  end
  if lost == true then
    self:lost()
  end
  self:nextLevel(currentRound.level)
end

return Star