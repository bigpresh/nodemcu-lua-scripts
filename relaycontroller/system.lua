-- NodeMCU/ESP8266 Relay control code
-- (c) David Precious <davidp@preshweb.co.uk>
-- Feel free to drop me a line if you found it useful!


-- Define a map of output names to pin numbers as a dict named 'pins'
-- in pins.lua so the calling code can use names rather than numbers
-- e.g. pins = { foo = 3, bar = 4 }
-- If your relay board operates when the input is pulled LOW, then set
-- reverse_logic = 1 in your pins.lua, too.
-- You can also set nodename there to denote what this relay controller is for
-- so it can be used in syslog messages.
reverse_logic = false
nodename = 'relayctl';

syslog("Reading pin definitions from pins.lua")
dofile('pins.lua')

if (reverse_logic) then
    syslog("Reversing logic state as reverse_logic is set")
end





-- for each pin, set it up as an output and initialise it as a GPIO output
for name,pin in pairs(pins) do
    syslog("Configuring GPIO pin " .. pin .. " as name " .. name)
    gpio.mode(pin, gpio.OUTPUT)
    if (reverse_logic) then
        syslog("Set initial state for "..pin.." to HIGH")
        gpio.write(pin, gpio.HIGH)
    else
        syslog("Set initial state for "..pin.." to LOW")
        gpio.write(pin, gpio.LOW)
    end
end

 
-- We'll use the on-board LED to indicate we're processing a request
-- so set up pin 4 as an output.
led_pin=4
gpio.mode(led_pin, gpio.OUTPUT)


print("Defining web server")
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
	-- turn on LED to indicate we're handling a request
	gpio.write(led_pin, gpio.LOW)
        local ip, port = conn:getpeer()
        syslog("Handling connection from " .. ip)

        -- Crudely parse the HTTP request
        local buf = ""
        local query = {}
        local method, url = string.match(request, "([A-Z]+) /(.*) HTTP")
        local path, querystring = string.match(url, '(.+)?(.+)')
        if (querystring ~= nil) then
            url = path
            for k, v in string.gmatch(querystring, "(%w+)=(%w+)&*") do
                query[k] = v
            end
        end

        syslog("Request for " .. method .. " /" .. url .. ' from ' .. ip)


        -- Handle requests for a given pin name first
        if (url ~= '') then
            -- First, look up the path given, see if it is a recognised
            -- pin name
            local pin_num = pins[url]
            if (pin_num == nil) then
                -- it's not a pin we recognise - it's either a request for
                -- status info, or an error
                if (url == 'status') then
                    -- TODO: refactor this all out
                    syslog('status request from ' .. ip)
                    local meh, bootreasonid = node.bootreason()
                    reasons = {
                        'power on',
                        'hardware watchdog reset',
                        'exception reset',
                        'software watchdog reset',
                        'software restart',
                        'wake from deep sleep',
                        'external reset'
                    }
                    buf = '{"uptime":'..tmr.time()..',"boot_reason_id":'..
                        bootreasonid .. ',"boot_reason_text":"' ..
                        reasons[bootreasonid] .. ',"heap_space":' ..
                        node.heap() .. ',"memory_used":' ..
                        collectgarbage("count") .. '"}'
                else
                    buf = '{"error":"invalid_pin_name"}'
                end
            else
                -- if we were told to change the pin's status, do it
                if (query.action) then
                    syslog("Told to turn pin " .. pin_num .. " " .. query.action)
                    local pin_state = { on = gpio.HIGH, off = gpio.LOW }
                    if (reverse_logic) then
                        pin_state = { on = gpio.LOW, off = gpio.HIGH }
                    end
                    if (pin_state[query.action]) then
                        syslog(
                            "Set pin " .. pin_num .. " to "
                            .. pin_state[query.action]
                        )
                        gpio.write(pin_num, pin_state[query.action])
                    else
                        buf = '{"error":"action_invalid"}'
                    end
                end

                -- If we were told to start toggling the pin for testing, then
                -- set a timer to do so
                if (query.autotoggle) then
                    syslog("Told to start auto-toggling pin " .. pin_num)
                    local mytimer = tmr.create()
                    mytimer:register(1000, tmr.ALARM_AUTO, function (t)
                        syslog("Toggle pin " .. pin_num)
                        if (gpio.read(pin_num) == gpio.HIGH) then
                            syslog("Toggling pin " .. pin_num .. " LOW")
                            gpio.write(pin_num, gpio.LOW)
                        else
                            syslog("Toggling pin " .. pin_num .. " HIGH")
                            gpio.write(pin_num, gpio.HIGH)
                        end
                        
                    end)
                    mytimer:start()
                end

                -- now return the current state of the pin
                local state = gpio.read(pin_num)
                if (reverse_logic) then
                    if (state == 1) then
                        state = 0
                    else
                        state = 1
                    end
                end
                buf = '{"state":'.. state .. ',"pin_num":'.. pin_num .. '}'
            end

        -- but if no path, i.e. request was for just /, then return
        -- a basic web page
        else
            buf = buf.."<h1> ESP8266 Relay Controller by David Precious</h1>";
            local actions = { 'on', 'off' }
            for name,pin in pairs(pins) do
                buf = buf .. "<p><b>"..name.."</b> (GPIO pin "..pin..") - "
                for i=1, #actions do
                    local action = actions[i]
                    buf = buf .. '<a href="/'..name
                        ..'?action='..action..'">'..action..'</a> '
                end
                buf = buf .. '<a href="/'..name..'">status</a></p>'
            end
        end

        -- Send whatever response we generated, clean up, and turn off LED
        client:send(buf);
        client:close();
        collectgarbage();
	gpio.write(led_pin, gpio.HIGH)
    end)
end)



