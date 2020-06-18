Class = require 'class'
push = require 'push'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
  math.randomseed(os.time())

  love.graphics.setDefaultFilter('nearest', 'nearest')

  love.window.setTitle('Pong')

  smallFont = love.graphics.newFont('04b_03__.TTF', 8)

  scoreFont = love.graphics.newFont('04b_03__.TTF', 32)

  victoryFont = love.graphics.newFont('04b_03__.TTF', 24)

  sounds = {
    ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
    ['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static')
  }

  player1Score = 0
  player2Score = 0

  servingPlayer = math.random(2) == 1 and 1 or 2

  winningPlayer = 0

  paddle1 = Paddle(5, 20, 5, 20)
  paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

  gameState = 'start'

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    vsync = true,
    resizable = true
  })
end

function love.resize(w, h)
  push:resize(w,h)
end

function love.update(dt)
  if ball.x <= 0 then
    player2Score = player2Score + 1
    servingPlayer = 1
    ball:reset()
    ball.dx = 100
    sounds['point_scored']:play()

    if player2Score >= 3 then
      gameState = 'victory'
      winningPlayer = 2
    else
      gameState = 'serve'
    end
  end

  if ball.x >= VIRTUAL_WIDTH - 4 then
    player1Score = player1Score + 1
    servingPlayer = 2
    ball:reset()
    ball.dx = -100
    sounds['point_scored']:play()

    if player1Score >= 3 then
      gameState = 'victory'
      winningPlayer = 1
    else
      gameState = 'serve'
    end
  end

  if ball:collides(paddle1) then
    ball.dx = -ball.dx * 1.2
    ball.x = paddle1.x + 5
    sounds['paddle_hit']:play()
  end

  if ball:collides(paddle2) then
    ball.dx = -ball.dx * 1.2
    ball.x = paddle2.x - 4
    sounds['paddle_hit']:play()
  end

  if ball.y <= 0 then
    ball.dy = -ball.dy
    ball.y = 0
    sounds['wall_hit']:play()
  end

  if ball.y >= VIRTUAL_HEIGHT - 4 then
    ball.dy = -ball.dy
    ball.y = VIRTUAL_HEIGHT - 4
    sounds['wall_hit']:play()
  end

  if (paddle1.y > (ball.y + ball.height/2)) then
    paddle1.dy = -PADDLE_SPEED
  elseif (paddle1.y + paddle1.height < (ball.y + ball.height / 2)) then
    paddle1.dy = PADDLE_SPEED
  else
    paddle1.dy = 0
  end

  if love.keyboard.isDown('up') then
    paddle2.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('down') then
    paddle2.dy = PADDLE_SPEED
  else
    paddle2.dy = 0
  end

  if gameState == 'play' then
    ball:update(dt)
  end

  paddle1:update(dt)
  paddle2:update(dt)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'serve'
    else if gameState == 'victory' then
      gameState = 'start'
      player1Score = 0
      player2Score = 0
    elseif gameState == 'serve' then
      gameState = 'play'
    end
  end
end
end

function love.draw()
  push:apply('start')

  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

  love.graphics.setFont(smallFont)

  if gameState == 'start' then
    love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
  else if gameState == 'serve' then
    love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Enter to Serve", 0, 32, VIRTUAL_WIDTH, 'center')
  else if gameState == 'victory' then
    love.graphics.setFont(victoryFont)
    love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(smallFont)
    love.graphics.printf("Press Enter to Serve", 0, 42, VIRTUAL_WIDTH, 'center')
  end
  end
  end

  love.graphics.setFont(scoreFont)
  love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

  paddle1:render()
  paddle2:render()
  ball:render()

  displayFPS()

  push:apply('end')
end

function displayFPS()
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.setFont(smallFont)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
  love.graphics.setColor(1, 1, 1, 1)
end
