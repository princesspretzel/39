local stars = require('stars')

local starClass = { }
starClass.__index = starClass

function Star()
  local starFile = '/images/basestart.png'
  local image = love.graphics.newImage(starFile)
  local width, height = image:getDimensions( )
  local instance = {
    class = 'star',
    i = image,
    w = width,
    h = height,
    r = .2,
    x = ((gameWidth / 2) - (width / 2) + 45),
    y = -30
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
  self:assignNewImageFromFile(starFile)
end

function starClass:won()
  local choice = math.random(1,2)
  self:winningImageOscillation(choice)
end

function starClass:lost()
  local lostStarFile = '/images/loststart.png'
  self:assignNewImageFromFile(lostStarFile)
end

function starClass:levelImage(lvl)
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
  if wonGame == true then
    self:won()
  end
  if lost == true then
    self:lost()
  end
  if lost == false and wonGame == false then
    self:levelImage(currentRound.level)
  end
end

return Star