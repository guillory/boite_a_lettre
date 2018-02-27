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
		      lock=0;
		    else
		      print("HTTP request OK");
		      table.remove(mesures,table.getn(mesures))
		    end
	      if (table.getn(mesures)>0) then 
			postDomoticzall()
		  else
		  	print ("All posted")
		  	lock=0;
		  	NodeSleep();
		  end
		  
	  	end)
  else
	print("aucune valeur a poster");
	
  end
end