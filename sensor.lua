function alimentation(call_back)
	mesures={}
	VDD=adc.readvdd33(0)/1000;
	print ("VDD:".. VDD.." volt")
	file.remove("vdd.log" );
	file.open("vdd.log" , "w" );
	file.writeline(VDD);
	file.close();
	call_back();
end 
function Sensor()
	mesures={}
	VDD=0;		
	if 	file.open("vdd.log" , "r" ) then 		
		VDD=tonumber(file.readline()); 
		file.close();
		table.insert(mesures, {type='command' , param='udevice', idx=27, nvalue=0, svalue=VDD , battery=battery_level(VDD)} )
	else
		print("fichier vdd.log introuvable");
	end
	stable, poids, prec_poids=DoMesure();
	
	print ("Poids :".. poids.." grammes")
	
	if ( stable==1   and (poids <0 and poids>-5) ) then 
		poids=0;
		print("entre 65 et zero => zero")
    	table.insert(mesures, {type='command' , param='udevice', idx=29,nvalue=0, svalue=poids, battery=battery_level(VDD)} )
	elseif (stable==1 and poids<0)  then  -- poids trop faible avec 5g de toléreance : on tarre  (poids <POIDSMIN  and not(poids >=0 and poids <=5))) 
		mesures={};
		DoTarre() ;
	elseif  (stable==1   and  (math.abs(poids-prec_poids) < 5) )  then
    	 print('delta faible');
    	 poids=prec_poids;
    	table.insert(mesures, {type='command' , param='udevice', idx=29,nvalue=0, svalue=poids, battery=battery_level(VDD)} )
	elseif  (stable==1 )  then
    	print("facteur")
    	table.insert(mesures, {type='command' , param='udevice', idx=29,nvalue=0, svalue=poids, battery=battery_level(VDD)} )
	end
	
  	if (table.getn(mesures)>0) then 
		print ("postDomoticz "..table.getn(mesures).."")
		ConnectWifi(postDomoticzall, NodeSleep) ;
	else
		print("Aucune valeure à poster") NodeSleep()
	end
end

function DoMesure()
	tabpoids={}
	hx711.init(6,5)
	stable=0;
	nbtry=0;
	while stable==0 and nbtry<=5 do
		tabpoids={}
		nbtry=nbtry+1;
		for i=1, 10 do 
			poids= - hx711.read(0) or 0
			table.insert(tabpoids, poids)
			print ("->mesure : ".. poids .."="..engramme(poids) ) 
		end
		table.sort (tabpoids)
		if math.floor(engramme(tabpoids[table.getn(tabpoids)]) - engramme(tabpoids[1])) >= 30  	 then
			stable=0;			print ("pas stable!")
		else
			stable=1;			print ("stable!")		
		end
	end
	poids=math.floor(engramme(moyenne(tabpoids,60)));

	print ("poids precedent");
	if 	file.open("prec_poids.log" , "r" ) then 		
		prec_poids=file.readline(); 
		if (not tonumber(prec_poids)) then prec_poids=0 end
		file.close();
	else
		print("fichier prec_poids.log introuvable");
		prec_poids=0;
	end
	file.remove("prec_poids.log");
	file.open("prec_poids.log" , "w" );
	file.writeline(poids);
	file.close();


	return stable, poids, prec_poids;
end
function DoTarre()
	stable=0;
	nbtry=0;
	while stable==0 and nbtry<=5 do
		tarres={}
		hx711.init(6,5)
		for i=1, 10 do 
			blink(1,5000);
			tarre= - hx711.read(0) or 0
			table.insert(tarres, tarre)
			print ("->tarre : ".. tarre .."="..engramme(tarre) ) 
		end
		table.sort (tarres)
		if math.floor(engramme(tarres[table.getn(tarres)]) - engramme(tarres[1])) >= 30  	 then
			stable=0;			print ("pas stable!")
		else
			stable=1;			print ("stable!")
			tarre=moyenne(tarres,60)
			file.remove("tarre.lua" )
			file.open("tarre.lua" , "w" )
			file.write("TARRE="..tarre)
			file.close()
			TARRE=tarre;
			print ("TARRE ="..TARRE)
			print ("Tarre :".. engramme(tarre).." grammes")	
		end
	end
	Sensor();
end	
function  battery_level(i)
	local level=math.floor(i /0.05);
	if  (level>100 or level<0) then return 255; else return level; end
end
