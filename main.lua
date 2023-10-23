local mqtt = require("mqtt_library")
local settings = require("settings")
local json = require("json/json")
local player_settings = settings[settings.player].love

-- controla de quem é a vez
-- 1 = vez do jogador
-- 2 = vez do outro (computador ou outro player)
-- 3 = vitória nossa
-- 4 = vitória do outro
local turn = settings[settings.player].starting_turn

function love.load ()
  local board_size = 8
  local board_pixels = 500
  math.randomseed(os.time())
  
  -- (DEBUG) activate print
  io.stdout:setvbuf("no")
  
  -- requiring files
  require('lua/ship')
  require('lua/viewboard')
  require('lua/clickboard')
  
  -- getting font
  font = love.graphics.newFont('fonts/Minecraft.TTF', 60)
  
  -- espaço na janela para os dois tabuleiros
  love.window.setMode(board_pixels*2,board_pixels + 250)
  love.window.setTitle("BATTLESHIP")
  love.graphics.setBackgroundColor(0.1,0.1,0.1)
  
  -- afundados
  friendlies_sunk = 0
  opponents_sunk = 0
  
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

  -- conexão mqtt
  mqtt_client = mqtt.client.create(settings.internet.server, settings.internet.port, mqttcb)
  mqtt_client:connect(player_settings.id)
  mqtt_client:subscribe(player_settings.subscribe) -- mensagens do outro battleship, mensagens do nodemcu
end

-- função para mandar ataque para computador oponente
function manda_ataque(msg)
  print("mandando ataque")
  mqtt_client:publish(player_settings.attack_queue,msg,0,0, 
            function(client) print("mandou ataque") end)
end

-- função para mandar resposta de ataque para computador oponente
function manda_resposta(msg)
  print("mandando resposta do ataque")
  mqtt_client:publish(player_settings.response_queue,msg,0,0, 
            function(client) print("mandou resposta do ataque") end)
end

-- quando recebe jogada inimiga
function opponent_play(message)
  attackpos = json.decode(message)
  
  print(string.format("opponent attacks (%i, %i)", attackpos.x, attackpos.y))
  
  -- registra ataque, manda resposta
  if viewboard:check_hit(attackpos) then
    response = {
      pos = attackpos,
      result = "hit",
      sunk = viewboard:ships_sunk()
    }
    manda_resposta(json.encode(response))
  else
    response = {
      pos = attackpos,
      result = "miss",
      sunk = viewboard:ships_sunk()
    }
    manda_resposta(json.encode(response))
  end
  
  turn = 1
  friendlies_sunk = viewboard:ships_sunk()
  if (friendlies_sunk == 5) then turn = 4 end
end

-- processa a resposta de um ataque, se acertou ou não
function check_attack(message)
  attackresponse = json.decode(message)
  attackpos = attackresponse.pos
  
  print(string.format("result of attack on (%i, %i)", attackpos.x, attackpos.y))
  if attackresponse.result == "hit" then
    clickboard:add_hit(attackpos)
  elseif attackresponse.result == "miss" then
    clickboard:add_miss(attackpos)
  end
  
  opponents_sunk = attackresponse.sunk
  if (opponents_sunk == 5) then turn = 3 end
end


function nodemcu_keyboard(node_message)
  -- não tá na sua vez = não faz nada
  if (turn ~= 1) then return end

  --down
  if (node_message == "3") then
    clickboard:down()

  -- right
  elseif (node_message == "2") then
    clickboard:right()
    
  -- attack
  elseif (node_message == "1") then
    selected_pos = {x = clickboard.selected_square.x, y=clickboard.selected_square.y}
    
    -- já atacou ali = não conta
    if (not clickboard:can_attack(selected_pos)) then return end
    
    -- manda mensagem de ataque
    manda_ataque(json.encode(selected_pos))
    turn = 2 -- passa a vez pro outro jogador (vai ficar na vez dele até vir um ataque de volta)
  end
end
  
-- recebe mensagens mqtt
function mqttcb(topic, message)
  print("MENSAGEM RECEBIDA: "..topic)
  
  -- mensagem é na fila do nodemcu = é entrada de teclado
  if (topic == player_settings.subscribe[2]) then
    nodemcu_keyboard(message)
  
  -- mensagem é na fila do outro battleship = é ataque inimigo
  elseif (topic == player_settings.subscribe[1]) then
    opponent_play(message)
    
  -- mensagem é na fila do nosso battleship = é resposta de um ataque nosso
  elseif (topic == player_settings.subscribe[3]) then
    check_attack(message)
    
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
    
    -- manda mensagem de ataque
    manda_ataque(json.encode(selected_pos))
    turn = 2 -- passa a vez pro outro jogador (vai ficar na vez dele até vir um ataque de volta)
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
  
  -- escrevendo situação do jogo
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(font)
  love.graphics.print(string.format("NOSSOS AFUNDADOS: %d/5",friendlies_sunk,5), 20, 625, 0, 0.5)
  love.graphics.print(string.format("INIMIGOS AFUNDADOS: %d/5",opponents_sunk,5), 520, 625, 0, 0.5)
  love.graphics.print(string.format("INIMIGOS AFUNDADOS: %d/5",opponents_sunk,5), 520, 625, 0, 0.5)
  
  -- escrevendo sobre o turno
  if (turn == 1) then
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SUA VEZ", 440, 520, 0, 0.5)
  
  elseif (turn == 2) then
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("VEZ DO OPONENTE", 350, 520, 0, 0.5)
  
  elseif (turn == 3) then -- vitória
    love.graphics.setColor(0.5, 0.5, 1, 0.5)
    love.graphics.rectangle("fill", 0, 0, 1000, 750)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("VITORIA", 370, 260)
  
  elseif (turn == 4) then
    love.graphics.setColor(1, 0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 0, 0, 1000, 750)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("DERROTA", 350, 260)

  end
  love.graphics.setColor(1, 1, 1)
end

function love.quit()
  os.exit()
end
