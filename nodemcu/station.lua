-- wifi id e senha
wificonf = {
  ssid = "wifi id",
  pwd = "password",
  save = false,
  got_ip_cb = function (con)
                print (con.IP)
              end
}

wifi.sta.config(wificonf)
print("modo: ".. wifi.setmode(wifi.STATION))

