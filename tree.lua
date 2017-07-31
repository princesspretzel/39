local treeClass = { }
treeClass.__index = treeClass

function Tree()
  local treeFile = '/images/treetryt.png'
  local image = love.graphics.newImage(treeFile)
  local width, height = image:getDimensions( )
  local instance = {
    class = 'tree',
    i = image,
    w = width,
    h = height,
    r = .15,
    x = (gameWidth / 2) - 250,
    y = 30
  }
  setmetatable(instance, treeClass)
  return instance
end

function treeClass:draw()
  love.graphics.draw(self.i, self.x, self.y, self.r)
end

return Tree