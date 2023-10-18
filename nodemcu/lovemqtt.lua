-- id do conectado (battleship1 e battleship2)
local meuid = "nodebattleship1"
local m = mqtt.Client(meuid, 120)

function publica(c)
  c:publish("nodebattleship1","alo de " .. meuid,0,0, 
            function(client) print("mandou!") end)
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
  publica(client)
  client:subscribe("lovebattleship1", 0, novaInscricao)
end 

m:connect("139.82.100.100", 7981, false, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)


