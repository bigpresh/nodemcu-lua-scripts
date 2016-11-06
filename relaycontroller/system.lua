-- NodeMCU/ESP8266 Relay control code
-- (c) David Precious <davidp@preshweb.co.uk>
-- Feel free to drop me a line if you found it useful!


-- Define a map of output names to pin numbers as a dict named 'pins'
-- in pins.lua so the calling code can use names rather than numbers
-- e.g. pins = { foo = 3, bar = 4 }
print("Reading pin definitions from pins.lua")
dofile('pins.lua')


-- for each pin, set it up as an output and initialise it as a GPIO output
for name,pin in pairs(pins) do
    print("Configuring GPIO pin " .. pin .. " as name " .. name)
    gpio.mode(pin, gpio.OUTPUT)
    gpio.write(pin, gpio.LOW)
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
        print("Handling request from " .. ip)

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

        print("Requested " .. method .. " /" .. url)


        -- Handle requests for a given pin name first
        if (url ~= '') then
            -- First, look up the path given, see if it is a recognised
            -- pin name
            local pin_num = pins[url]
            if (pin_num == nil) then
                -- it's not a pin we recognise - it's either a request for
                -- status info, or an error
                if (url == 'status') then
                    buf = '{"uptime":'..tmr.time()..'}'
                else
                    buf = '{"error":"invalid_pin_name"}'
                end
            else
                -- if we were told to change the pin's status, do it
                if (query.action) then
                    local new_state = { on = gpio.HIGH, off = gpio.LOW }
                    if (new_state[query.action]) then
                        gpio.write(pin_num, new_state[query.action])
                    else
                        buf = '{"error":"action_invalid"}'
                    end
                end

                -- now return the current state of the pin
                local state = gpio.read(pin_num)
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



