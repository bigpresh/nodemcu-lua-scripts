

in_flash = false
flash_count = 0
function checkValue()
    -- print("Checkvalue called")
    value = adc.read(0)

    -- print("value:"..value)
    if value > 200 then
        -- bright enough to be a flash
        if not in_flash then
            print("New flash detected!")
            in_flash = true
            flash_count = flash_count + 1
        end
    else
        in_flash = false
    end
end

-- tmr.register(id/ref, interval_ms, mode, func)
tmr.alarm(0, 50, tmr.ALARM_AUTO, checkValue)
print("registered timer")


-- Now set up a crude webserver to return the flash count, which
-- can be polled to see how much energy has been used since the
-- last call.
-- Rough and ready, but coded beer-in-hand waiting to go out to
-- darts, so if it works, it's good enough for now!
-- In fact, I finished it and flashed it after returning from the pub,
-- somewhat pissed, so I deserve whatever I get for flashing this...
print("Setting up web server")
srv = net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on('receive', function(client,request)
        print('Received a request')
	-- on my meter, it's 1000 flashes per KWh used; if that differs




-- If the input is high, and was not high before, it's the start of a new pulse - fire HTTP request

        -- for your meter, change this to suit
	usage_kwh = flash_count * 0.001;
        flash_count = 0;
        client:send("{usage_kwh:" .. usage_kwh .. "}")
        client:close()
    end)
end)

