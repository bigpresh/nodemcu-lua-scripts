print("Configuring wifi connection")
wifi.setmode(wifi.STATION)
wifi.setphymode(wifi.PHYMODE_B)
wifi.sta.config("...","...")  -- SSID and WiFipswd in inverted commas

print("Registering wifi state event monitors")
wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("STATION_IDLE") end)
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("STATION_CONNECTING") end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("STATION_WRONG_PASSWORD") end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("STATION_NO_AP_FOUND") end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("STATION_CONNECT_FAIL") end)
wifi.sta.eventMonReg(wifi.STA_GOTIP, function() print("STATION_GOT_IP:"..wifi.sta.getip()) end)
wifi.sta.eventMonStart()



