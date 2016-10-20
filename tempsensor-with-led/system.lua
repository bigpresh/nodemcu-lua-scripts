
print("Configuring GPIO pins")
led_pin=4
dht_pin=5

gpio.mode(led_pin, gpio.OUTPUT)
gpio.mode(dht_pin, gpio.INPUT, gpio.PULLUP)

dht=require("dht") -- is this necessary?

print("Defining web server")
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
	print('Received request')
	-- turn on LED to indicate we're handling a request
	gpio.write(led_pin, gpio.LOW)

	status,temp,humi,temp_decimal,humi_decimal = dht.read(dht_pin)
	if( status == dht.OK ) then
		print("DHT Temperature:"..temp..";".."Humidity:"..humi)
		client:send("{temp:"..temp..",humidity:"..humi.."}")
	elseif( status == dht.ERROR_CHECKSUM ) then
  		print( "DHT Checksum error." )
		client:send("{error:'checksum'}")
	elseif( status == dht.ERROR_TIMEOUT ) then
  		print( "DHT Time out." )
		client:send("{error:'timeout'}")
	end

        client:close();
	print('Sent reply')
        collectgarbage();
	tmr.delay(200000)
	gpio.write(led_pin, gpio.HIGH)
	print("LED off, done with request")
    end)
end)
