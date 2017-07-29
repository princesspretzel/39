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

function starClass:getImageAtIdx(idx)
  local starFiles = { }
  local winStar1File = '/images/winstar1t.png'
  table.insert(starFiles, winStar1File)
  local winStar2File = '/images/winstar2t.png' 
  table.insert(starFiles, winStar2File)
  print('starFiles[idx]: ', starFiles[idx])
  print('idx: ', idx)
  return starFiles[idx]
end

function starClass:winningImageOscillation(idx)
  starFile = self:getImageAtIdx(idx)
  currentImage = love.graphics.newImage(starFile)
  self.i = currentImage
end

function starClass:won()
  local choice = math.random(1,2)
  print('choice: ', choice)
  self:winningImageOscillation(choice)
  -- self.r = math.random(-2,2)
end

function starClass:draw()
  love.graphics.draw(self.i, self.x, self.y, self.r)
end

function starClass:update(dt)
  if won == true then
    self:won()
  end
end

return Star