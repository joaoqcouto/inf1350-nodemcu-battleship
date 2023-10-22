local mqtt = require("mqtt_library")

-- controla de quem é a vez
-- 1 = vez do jogador
-- 2 = vez do outro (computador ou outro player)
local turn = 1
  
local function mqttcb (msg)
  print(msg)
end

function love.load ()
  local board_size = 8
  local board_pixels = 500
  math.randomseed(os.time())
  
  -- (DEBUG) activate print
  io.stdout:setvbuf("no")
  
  -- requiring files
  require('Lua Files/ship')
  require('Lua Files/viewboard')
  require('Lua Files/clickboard')
  
  -- espaço na janela para os dois tabuleiros
  love.window.setMode(board_pixels*2,board_pixels+200)
  love.window.setTitle("BATTLESHIP")
  love.graphics.setBackgroundColor(0.1,0.1,0.1)
  
  -- criando barcos
  ships = {
    createShip(5, board_size, board_pixels, {r = 0.5, g = 0.5, b = 0.5}),
    createShip(4, board_size, board_pixels, {r = 0.5, g = 0.5, b = 0.5}),
    createShip(3, board_size, board_pixels, {r = 0.5, g = 0.5, b = 0.5}),
    createShip(3, board_size, board_pixels, {r = 0.5, g = 0.5, b = 0.5}),
    createShip(2, board_size, board_pixels, {r = 0.5, g = 0.5, b = 0.5})
  }
  
  -- criando tabuleiro
  viewboard = createViewboard(board_size, board_pixels)
  
  -- colocando barcos no tabuleiro
  for i,ship in ipairs(ships) do
    viewboard:place_ship(ship)
  end
  
  -- criando tabuleiro de click
  clickboard = createClickboard(board_size, board_pixels)
  
  -- SÓ PARA SINGLEPLAYER = ITENS INIMIGOS
  -- tabuleiro inimigo
  opponent_viewboard = createViewboard(board_size, board_pixels)
  
  -- barcos inimigos
  enemy_ships = {
    createShip(5, board_size, board_pixels, {r = 0.5, g = 0.5, b = 0.5}),
    createShip(4, board_size, board_pixels, {r = 0.5, g = 0.5, b = 0.5}),
    createShip(3, board_size, board_pixels, {r = 0.5, g = 0.5, b = 0.5}),
    createShip(3, board_size, board_pixels, {r = 0.5, g = 0.5, b = 0.5}),
    createShip(2, board_size, board_pixels, {r = 0.5, g = 0.5, b = 0.5})
  }
  
  -- colocando barcos no tabuleiro inimigo
  for i,ship in ipairs(enemy_ships) do
    opponent_viewboard:place_ship(ship)
  end

  -- conexão mqtt
  mqtt_client = mqtt.client.create("139.82.100.100", 7981, mqttcb)
  mqtt_client:connect("battleship1")
  mqtt_client:subscribe({"battleship2", "nodebattleship1"}) -- mensagens do outro battleship, mensagens do nodemcu
end

-- checa se acertou ou não a posição
-- no singleplayer, basta checar o tabuleiro do oponente (PC)
-- no online, precisa mandar pelo MQTT a posição (só vai marcar o erro/acerto quando chegar a resposta)
function check_hit(position)
  print(string.format("check pos (%i, %i)", position.x, position.y))
  if opponent_viewboard:check_hit(position) then
    clickboard:add_hit(position)
  else
    clickboard:add_miss(position)
  end
end

-- em vez de keypressed aqui, vamos usar o nodeMCU como teclado
-- como ele tem quatro botões, a implentação por nodeMCU tem quatro botões
-- down = anda a mira no eixo vertical
-- right = anda a mira no eixo horizontal
-- enter = atira onde tá mirando
-- esc = reinicia o jogo
function love.keypressed(key)
  -- não tá na sua vez = não faz nada
  if (turn ~= 1) then return end
  
  -- down
  if (key == "down") then
    clickboard:down()
    
  -- right
  elseif (key == "right") then
    clickboard:right()
    
  -- attack
  elseif (key == "return") then
    selected_pos = {x = clickboard.selected_square.x, y=clickboard.selected_square.y}
    
    -- já atacou ali = não conta
    if (not clickboard:can_attack(selected_pos)) then return end
    
    -- função que vai checar se acertou ou errou
    check_hit(selected_pos)
    -- turn = 2 -- passa a vez pro outro jogador
  end
end

function love.update(dt)
  
  -- tem que chamar o handler aqui!
  mqtt_client:handler()
end

function love.draw ()
  viewboard:draw()
  clickboard:draw()
  for i,ship in ipairs(ships) do
    ship:draw()
  end
end

function love.quit()
  os.exit()
end
