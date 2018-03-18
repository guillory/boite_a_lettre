function blink(nb,duree,level_off,LEDPIN) 	
	nb=nb or 2;
	duree=duree or 1000; 
	level_off=level_off or 1;
	LEDPIN=LEDPIN or 4;
	gpio.mode(LEDPIN ,gpio.OUTPUT)
	i=level_off;
	blinktimer = tmr.create();
	blinktimer:register(duree/2, tmr.ALARM_AUTO, function() 	 -- half second on, half second off=1 sec
		i=i+1; gpio.write(LEDPIN,i%2); -- 
		print("i:"..i.." nb "..nb.." mod "..i%2);	
		if i>=(2*nb)+1 then  print('stop'); gpio.write(LEDPIN,level_off); blinktimer:stop() 	end
	end)
	blinktimer:start()
end
function get_sun()
	gpio.mode(2,gpio.OUTPUT)
	gpio.write(2,gpio.HIGH)
	tmr.delay(100000)
	sun =adc.read(0) or 0
	gpio.mode(2,gpio.LOW)
	return sun
end
 function decimal(nb, base)
	local nb_int = nb / base
        local nb_float = (nb >= 0 and nb % base) or (base - nb % base)
	return nb_int.."."..nb_float
end
function NodeSleep()
	if DEBUG then   print("sleeping "..WAIT_MN.." mn") end
	tmr.delay(1000000);
	if (DEEPSLEEP=='YES') then 
			if DEBUG then  print("DEEPSLEEP") end
			node.dsleep(WAIT_MN * 60000000)
	else
			if DEBUG then  print("NO DEEPSLEEP") end
			tmr.delay(WAIT_MN * 60000000)
			node.restart()
	end
end
function moyenne(tab,ratio)
	table.sort (tab)
	-- on va garder ratio% des valeurs , on supprime les 20% les plus petite et les 20% les plus grandes
	nb_ele_delete=math.ceil(table.getn(tab)* (100 - ratio)/200  )
	for i=1, nb_ele_delete do 
		table.remove(tab,table.getn(tab))
		table.remove(tab,1)
	end
	i=0
	total=0
	table.foreach (tab, 		function() 			i=i+1 			total=tab[i]+total		end 	)
	return (total/i)
end

function engramme(val)
	return  (val -TARRE) / HXRATIO 
end