-- import push - https://github.com/Ulydev/push
push = require "libs/push"

-- import class -  https://github.com/vrld/hump/blob/master/class.lua
Class = require "libs/class"

-- inport classes
require "classes/Ball"
require "classes/Paddle"

-- window dimentions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual window dimentions 
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

SIZE_BALL = 4

-- set dimensions for the Paddles
PaddlevX = 5
PaddlevY = 20

--set a default position for paddles
POSITION_PADDLES_y = (VIRTUAL_HEIGHT / 2) - (PaddlevY / 2) 

PADDLE_SPEED = 200


function  love.load()
  love.window.setTitle("pong") 

  --  to prevent blurring of text
  love.graphics.setDefaultFilter("nearest", "nearest")  

  -- set a defaut font
  defaultFont = love.graphics.newFont("fonts/kongtext.ttf", 8)
  scoreFont = love.graphics.newFont("fonts/kongtext.ttf", 8)

  math.randomseed(os.time()) 

  --init with default font
  love.graphics.setFont(defaultFont)

  -- importing sounds
  sounds = {
    ["paddle_hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
    ["score"] = love.audio.newSource("sounds/score.wav", "static"),
    ["wall_hit"] = love.audio.newSource("sounds/wall_hit.wav", "static")
  }

  --  window settings  
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH,WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true,
  })

  -- creating players
  player1 = Paddle(10, POSITION_PADDLES_y , PaddlevX, PaddlevY)
  player2 = Paddle(VIRTUAL_WIDTH - (10 + PaddlevX ) , POSITION_PADDLES_y, PaddlevX, PaddlevY)

  -- instance the ball in the middle of the screen
  ball = Ball((VIRTUAL_WIDTH / 2) - (SIZE_BALL/2),(VIRTUAL_HEIGHT / 2) - (SIZE_BALL/2), SIZE_BALL, SIZE_BALL)
  
  -- init score 
  player1Score = 0
  player2Score = 0

  -- swich player serve
  servingPlayer = 1

  -- who won the game
  winningPlayer = 0

  -- set a game state
  gameState = "start"

end




function love.keypressed(key)
 
  if key == "escape" then 
    love.event.quit() -- quit game
 
  elseif key == "enter" or key == "return" then
    
    -- states control
    if gameState == "start" then -- states start
      gameState = "serve"
    
    elseif gameState == "serve" then -- states serve
      gameState = "play"
    
    elseif gameState == "done" then -- states done
      
      -- restart game
      gameState = "serve"
    
      ball:reset()

      -- reset scores to 0
      player1Score = 0
      player2Score = 0    

      -- decide serving player as the opposite of who won
      if winningPlayer == 1 then 
        servingPlayer = 2
      else 
        servingPlayer = 1
      end
      
    end
  end
end



function love.update(dt)
  
  -- states control
  if gameState == "play" then
    ball:update(dt)

    -- collides events 
    
    -- ball collide to paddles  
    if ball:collides(player1) then collidePlayerEvent(player1, 5) end
    
    if ball:collides(player2) then collidePlayerEvent(player2, -4) end

    -- collide ball on top
    if ball.y <= 0 then CollisionBallWall(0) end

    -- collide ball on bottom
    if  ball.y >= VIRTUAL_HEIGHT - SIZE_BALL then
      CollisionBallWall(VIRTUAL_HEIGHT - SIZE_BALL)
    end

    -- score and serve 1
    if ball.x < 0 then
      reachEdge(1,player2Score , 2)
      player2Score = player2Score + 1

    end

    -- score and serve 2
    if ball.x > VIRTUAL_WIDTH then
      reachEdge(2, player1Score, 1)
      player1Score = player1Score + 1

    end
    
  elseif gameState == "serve" then

    -- ball"s velocity based on player who last scored
    ball.vy = math.random(-50, 50)
    if servingPlayer == 1 then
        ball.vx = math.random(140, 200)
    else
        ball.vx = -math.random(140, 200)
    end

  end

  -- player 1
  movimentPlayer(player1, "w", "s")

  -- player 2
  movimentPlayer(player2, "up", "down")

  player1:update(dt)
  player2:update(dt)

end


function love.draw()
  push:apply("start") -- init rendering at virtual resolution

  -- background color
  love.graphics.clear(24/255, 36/255, 51/255, 1) 

  -- Set game state control 
  if gameState == "start" then  -- state start
    message = "Bem-vindo ao jogo de ping pong"
    messageVisible = true
    action = "iniciar"

  elseif gameState == "serve" then -- state serve
    message = "O saque é do jogador " .. tostring(servingPlayer) .. "!"
    messageVisible = true
    displayScore()
    action = "continuar"

  elseif gameState == "play" then -- state play
    -- no UI messages to display in play
    messageVisible = false
    displayScore()

  elseif gameState == "done" then -- state done
    -- UI messages
    message = "O jogador " .. tostring(winningPlayer) .. " venceu!"
    messageVisible = true
    action = "jogar novamente"
    displayScore()

  end
  
  if messageVisible then 
    love.graphics.setFont(defaultFont)

    love.graphics.printf(
      message,
      0, 9, -- x and y position
      VIRTUAL_WIDTH,
      "center"
    )
    love.graphics.printf(
      'Aperte enter para ' .. action, 
      0, 20, -- x and y position
      VIRTUAL_WIDTH,
      'center'
    )
  end
  
  --displayScore()

  player1:render()
  player2:render()
  
  ball:render()


  push:apply("end") --  end rendering at virtual resolution
end

function love.resize(w, h)
  push:resize(w, h)
end

function displayScore()
  -- score display

  love.graphics.setFont(scoreFont)
  love.graphics.print( -- score player 1
    tostring(player1Score),
    VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT / 2 - 5
  )

  love.graphics.print( -- score player 2
    tostring(player2Score),
    VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 2 - 5
  )
end

function reachEdge(player, playerScore,win)
  servingPlayer = player
  sounds["score"]:play()

  if playerScore >= 9 then
      winningPlayer = win
      gameState = "done"
  else
      gameState = "serve"
  end
  ball:reset()

end 

function CollisionBallWall(wall)
  ball.y = wall
  ball.vy = -ball.vy
  sounds["wall_hit"]:play()
end

function movimentPlayer(player, up, down) 
  if love.keyboard.isDown(up) then
    player.vy = -PADDLE_SPEED
  elseif love.keyboard.isDown(down) then
    player.vy = PADDLE_SPEED
  else
    player.vy = 0
  end
end 

function collidePlayerEvent(player, direction) 
  ball.vx = -ball.vx * 1.03
  ball.x = player.x + direction

  -- set random direction
  if ball.vy < 0 then
      ball.vy = -math.random(10, 150)
  else
      ball.vy = math.random(10, 150)
  end

  sounds["paddle_hit"]:play() 
end