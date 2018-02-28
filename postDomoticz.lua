function postDomoticzall()
	--mesures
	if (table.getn(mesures)>0) then 
		url="http://"..DOMO_IP..":"..DOMO_PORT.."/json.htm?";
		print("nb url: "..table.getn(mesures))
		for k,v in pairs(mesures[table.getn(mesures)]) do

			url=url..k.."="..v.."&";
		end
		url=url.."rssi="..rssi_level(wifi.sta.getrssi());
		print ("URL : "..url)
		
		http.get(url, nil, function(code, data)
			print(code, data)
		    if (code < 0) then
		      print("HTTP request failed");
		    else
		      print("HTTP request OK");
		    end
		    table.remove(mesures,table.getn(mesures))
	      if (table.getn(mesures)>0) then 
			postDomoticzall();
		  else
		  	print ("All posted")
		  	NodeSleep();
		  end
		  
	  	end)
  else
	print("aucune valeur a poster");
	
  end
end