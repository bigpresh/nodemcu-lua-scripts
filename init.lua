function startup()
    if abort == true then
        print('startup aborted')
        return
    end
    if not nowifi then
    	print('Configuring wifi')
    	dofile('wifi.lua')
    end

    print("OK, executing system.lua")
    dofile('system.lua')
end

abort = false
nowifi = false
print('ESP8266 initialisation code by David Precious')
print('Node chipid: ' .. node.chipid())
flash_size_kb = node.flashsize() / 1024;
print('Node flash size: ' .. flash_size_kb)
print('Station MAC addy: ' .. wifi.sta.getmac())
print('About to start, loading system.lua in 5 seconds')
print('To abort, say abort=true now!')
print('To skip wifi, say nowifi=true now!')
tmr.alarm(0,5000,0,startup)
