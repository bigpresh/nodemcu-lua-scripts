-- Use a GPIO pin as a trigger, firing a HTTP request every time
-- the pin goes "high", for gate monitoring (or other events)

url = 'http://supernova:8266/esp-trigger'
headers = nil
last_report = tmr.now

-- use pin 1 as the input pulse width counter
pin = 1;
gpio.mode(pin, gpio.INT)
gpio.trig(pin, "up", function(level, when, eventcount)
    if (tmr.now() - last_report < 1000) then
        print("Ignoring GPIO event, already reported recently")
        return 0
    end

    if level == "high" then
        http.post(url, headers, '{"gpio_state":1}', function(code, data)
            if (code < 0) then
                print("HTTP request failed")
            else
                print("Reported event successfully")
                last_report = tmr.now()
            end
        end)
    end
end)


