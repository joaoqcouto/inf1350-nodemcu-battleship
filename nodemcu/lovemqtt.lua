-- settings
local settings = require("settings")
local node_settings = settings[settings.player].node

local chave = 0
local delay = 200000
local last = 0
local sw1 = 3
local sw2 = 4
local sw3 = 5
gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)
gpio.mode(sw3,gpio.INT,gpio.PULLUP)


local meuid = node_settings.id
local m = mqtt.Client(meuid, 120)

function publica(c,chave)
  c:publish(node_settings.publish,chave,0,0, 
            function(client) print("mandou! "..chave) end)
end

function novaInscricao (c)
  local msgsrec = 0
  function novamsg (c, t, m)
    print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
    msgsrec = msgsrec + 1
  end
  c:on("message", novamsg)
end

function conectado (client)
  client:subscribe(node_settings.subscribe, 0, novaInscricao)
  gpio.trig(sw1, "down", 
    function (level,timestamp)
        if timestamp - last < delay then return end
        last = timestamp
        chave = 1
        publica(client,chave)
    end)
  gpio.trig(sw2, "down", 
    function (level,timestamp)
        if timestamp - last < delay then return end
        last = timestamp
        chave = 2
        publica(client,chave)
    end)
  gpio.trig(sw3, "down", 
    function (level,timestamp)
        if timestamp - last < delay then return end
        last = timestamp
        chave = 3
        publica(client,chave)
    end)
end 

m:connect(settings.internet.server, settings.internet.port, false, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)
