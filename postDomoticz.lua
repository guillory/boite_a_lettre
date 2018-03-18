function postDomoticz()
  	if (table.getn(mesures)>0) then 
		print ("postDomoticz "..table.getn(mesures).."")
		nbtry=0;
		TIMOUT=15*table.getn(mesures); -- timer de sécurité 15 secondes par post 
		httptimeout = tmr.create();
		httptimeout:register(1000, tmr.ALARM_AUTO, function() 	
			print("waiting "..nbtry.." s /"..TIMOUT) 	nbtry=nbtry+1		
			if (nbtry>=TIMOUT ) then 	print("abandon")  httptimeout:stop() 	NodeSleep()		end		
		end)
		httptimeout:start();
		postDomoticzall();
	else
		print("Aucune valeure à poster") NodeSleep()
	end
end
function postDomoticzall()
	tmr.delay(1000000); -- wait 1 sec
	if (table.getn(mesures)>0) then 
		url="http://"..DOMO_IP..":"..DOMO_PORT.."/json.htm?";
		print("nb url: "..table.getn(mesures))
		for k,v in pairs(mesures[table.getn(mesures)]) do  	url=url..k.."="..v.."&";	end
		url=url.."rssi="..rssi_level(RSSI).."&battery="..battery_level(VDD);
		print ("URL : "..url);
		http.get(url, nil, function(code, data)
			print(code, data)
		    if (code ==200) then
		      print("HTTP request OK");
		    else
		      print("HTTP request failed");
		    end
		    table.remove(mesures,table.getn(mesures))
		    if (table.getn(mesures)>0) then 
				postDomoticzall()
			else
			  	print ("All posted");
			  	httptimeout:stop() 
			  	NodeSleep();
			end
	  	end)
  else
	print("aucune valeur a poster");
  end
end