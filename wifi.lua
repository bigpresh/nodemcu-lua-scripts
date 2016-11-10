print("Configuring wifi connection")
wifi.setmode(wifi.STATION)
wifi.setphymode(wifi.PHYMODE_B)
wifi.sta.config("...","...")  -- SSID and WPA key

-- Change this in your system.lua; it will be prepended to messages syslogged by
-- syslog()
nodename = 'ESP8266-unnamed';

print("Registering wifi state event monitors")
wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("STATION_IDLE") end)
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("STATION_CONNECTING") end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("STATION_WRONG_PASSWORD") end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("STATION_NO_AP_FOUND") end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("STATION_CONNECT_FAIL") end)
wifi.sta.eventMonReg(wifi.STA_GOTIP, function() 
    print("STATION_GOT_IP:"..wifi.sta.getip())
    cu=net.createConnection(net.UDP)
    cu:on("receive", function(cu, c) print(c) end)
    cu:connect(514, "10.1.10.254")
    cu:send(wifi.sta.gethostname() .. ' started up')
end)
wifi.sta.eventMonStart()


function syslog(message)
    print(message)
    if (cu ~= nil) then
        cu:send(nodename .. ': ' .. message)
    end
end


