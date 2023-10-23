-- wifi id e senha
local settings = require("settings")

wificonf = {
  ssid = settings.internet.id,
  pwd = settings.internet.password,
  save = false,
  got_ip_cb = function (con)
                print (con.IP)
              end
}

print ("wifi settings: id " .. settings.internet.id .. " password "..settings.internet.password)
wifi.sta.config(wificonf)
print("modo: ".. wifi.setmode(wifi.STATION))

