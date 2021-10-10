Paddle = Class{}

function Paddle:init(x,y, width, height)
  
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  
  -- velocity of moviment in y axis
  self.vy = 0

end


function Paddle:update(dt)
  
  -- to prevent for the paddle don't exit the window
  if self.vy < 0 then -- going up
    self.y = math.max(0, self.y + self.vy * dt)
  
  else -- going down
    self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.vy * dt)

  end

end


function Paddle:render()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end