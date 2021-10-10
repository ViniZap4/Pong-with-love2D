Ball = Class{}

function Ball:init(x,y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height

  -- velocity
  self.vy = 0 -- in y
  self.vx = 0 -- in x
end


function Ball:collides(paddle)

  if self.y > (paddle.y + paddle.height) or paddle.y > (self.y + self.height) then
    return false  -- there isn't an overlap in y axis
  end 

  if paddle.x > (self.x + self.width) or self.x > (paddle.x + paddle.width) then 
    return false -- there isn't an overlap in x axis
  end


  return true -- there is an overlap
end


function Ball:update(dt)

  -- set moviment for Ball
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt 

end

function Ball:reset()

  -- reset Ball position 
  self.x = VIRTUAL_WIDTH  / 2
  self.y = VIRTUAL_HEIGHT / 2
  
  -- reset velocity
  self.vy = 0 
  self.vx = 0

end

function Ball:render()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end