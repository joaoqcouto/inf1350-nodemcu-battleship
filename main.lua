local mqtt = require("mqtt_library")
  
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

  -- conexão mqtt
  mqtt_client = mqtt.client.create("139.82.100.100", 7981, mqttcb)
  mqtt_client:connect("battleship1")
  mqtt_client:subscribe({"battleship2", "nodebattleship1"}) -- mensagens do outro battleship, mensagens do nodemcu
end

-- em vez de keypressed aqui, vamos usar o nodeMCU como teclado
-- como ele tem quatro botões, a implentação por nodeMCU tem quatro botões
-- down = anda a mira no eixo vertical
-- right = anda a mira no eixo horizontal
-- enter = atira onde tá mirando
-- esc = reinicia o jogo
function love.keypressed(key)
  if (key == "down") then
    clickboard:down()
  elseif (key == "right") then
    clickboard:right()
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
