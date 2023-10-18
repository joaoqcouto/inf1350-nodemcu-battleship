local mqtt = require("mqtt_library")
local TAM = 400
  
local function mqttcb (msg)
  print(msg)
end

function love.load ()
  love.window.setMode(TAM,TAM)
  love.graphics.setBackgroundColor(0,0,0)

  mqtt_client = mqtt.client.create("139.82.100.100", 7981, mqttcb)
  -- Trocar XX pelo ID da etiqueta do seu NodeMCU
  mqtt_client:connect("battleship1")
  mqtt_client:subscribe({"battleship2", "nodebattleship1"}) -- mensagens do outro battleship, mensagens do nodemcu
end

function love.mousepressed (mx, my)

end

function love.update(dt)
  
  -- tem que chamar o handler aqui!
  mqtt_client:handler()
end

function love.draw ()
  
end

function love.quit()
  os.exit()
end
