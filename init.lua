require("settings")
dofile("tarre.lua")
dofile("wifi.lua")
dofile("postDomoticz.lua")
dofile("sensor.lua")
dofile("tools.lua")
gpio.mode(LEDPIN,gpio.OUTPUT)
	code, reset_reason = node.bootreason();	print ("code:"..code);	print ("reset_reason:"..reset_reason)
	if ( code==2 and reset_reason==6 )  then
		blink(3,100000);
		WAIT_MN=0.001;
		DoTarre();

	elseif adc.force_init_mode(adc.INIT_VDD33) then
		print ("WAIT_MN: "..WAIT_MN);
		sun=get_sun();
		print ("get_sun(): "..sun);
		WAIT_MN= math.floor((WAIT_MN - (3 * sun * WAIT_MN / 1024)) + 1);
		if WAIT_MN<0 then WAIT_MN=5; end
		print ("WAIT_MN: "..WAIT_MN);
		
		if sun > MIN_LIGHT	then 
				nb=3 tmr.alarm(0, 1000, 1, function()		
					nb=nb-1  	
					print (".");blink(2,100000);
					if nb ==0 then  tmr.stop(0) 
 						Sensor();
					end
				end)
		else
			NodeSleep();
		end
	else
			blink(1,100000);
			adc.force_init_mode(adc.INIT_ADC)
			WAIT_MN=0.001; -- x mn entre deux mesures
			alimentation(NodeSleep);
	end