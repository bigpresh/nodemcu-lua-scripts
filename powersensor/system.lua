-- Use a timer to check the light level, and decide if we're seeing
-- the sartrt of a new flash, increment our flash counter if so
in_flash = false
flash_count = 0
flashes_since = tmr.time()
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
srv = net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on('receive', function(client,request)
        print('Received a request')
	usage_kwh = flash_count * 0.001
	period_s = tmr.time() - flashes_since
	avg_watts = flash_count / (period_s / 60 / 60)
        flash_count = 0
        flashes_since = tmr.time()
        -- work out the average current in watts - watt-hours / hours
        client:send(
            '{"usage_kwh":' .. usage_kwh .. ',"avg_watts":' .. avg_watts
            .. ',"seconds":' .. period_s..'}'
        )
        client:close()
    end)
end)

