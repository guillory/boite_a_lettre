function blink(nb,duree) 	
 for i=0,nb do gpio.write(LEDPIN,gpio.HIGH);tmr.delay(duree);gpio.write(LEDPIN,gpio.LOW);tmr.delay(duree); end
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
	if (DEEPSLEEP=='YES') then 
			if DEBUG then  print("DEEP") end
			node.dsleep(WAIT_MN * 60000000)
	else
			if DEBUG then  print("NO DEEP") end
			wifi.sta.disconnect()
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