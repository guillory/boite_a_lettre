
function ConnectWifi(callback_ok, callback_ko)
	local nbtry=0
	tmr.alarm(0, 1000, 1, function()
		if nbtry==0 then 
			wifi.setmode(wifi.STATION)
			wifi.sta.config(cfg)
			print("Connecting to ssid '", cfg.ssid,"'")
		end
	  if (wifi.sta.status()<=4 and nbtry<=30) then 
	    	nbtry=nbtry + 1
	        print(getStatusString(wifi.sta.status()))
	  elseif (wifi.sta.status()<=4 and nbtry>30) then 
		print("NO WIFI wait ")
		tmr.stop(0);
		WAIT_MN=1;
		callback_ko();
	  else
	        ip, nm, gw=wifi.sta.getip();
	        print("Wifi Status:\t\t", getStatusString(wifi.sta.status()))
		      print("Wifi mode:\t\t", wifi.getmode())
		      print("Wifi RSSI:\t\t", wifi.sta.getrssi())
		      print("IP Address:\t\t", ip)
		      print("IP Netmask:\t\t", nm)
		      print("IP Gateway Addr:\t", gw)
		      print("DNS 1:\t\t\t", net.dns.getdnsserver(0))
		      print("DNS 2:\t\t\t", net.dns.getdnsserver(1))
		      table.insert(mesures, {type='command' , param='udevice', idx=30,nvalue=0, svalue=-wifi.sta.getrssi(), battery=battery_level(VDD)} )
	        tmr.stop(0);
		callback_ok();
	   end
	end)
end


function getStatusString(status)
    if status == 0 then
        return "STATION IDLE"
    elseif status == 1 then
        return "STATION CONNECTING"
    elseif status == 2 then
        return "STATION WRONG PASSWORD"
    elseif status == 3 then
        return "STATION NO AP FOUND"
    elseif status == 4 then
        return "STATION CONNECT FAIL"
    elseif status == 5 then
        return "STATION GOT IP"
    else
    	return "other"
    end
end

function  rssi_level(rssi)
	local level=math.floor((- (rssi*rssi)  +  (15000 *rssi) + 1700000 )/100000  ) ;
		if  level>12 then return 12; else return level; end
end