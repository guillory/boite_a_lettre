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
		table.insert(mesures, {type='command' , param='udevice', idx=idxvdd, nvalue=0, svalue=VDD} )
	else
		print("fichier vdd.log introuvable");
	end
	stable, poids, prec_poids, poidsnum=DoMesure();
	
	--poids_arrondi=poidstolerance * math.floor(poids/poidstolerance);
	--poids=poids_arrondi;
	print ("Poids :".. poids.." grammes")
	if ( stable==1   and (poids <poidstolerance and poids>-poidstolerance) ) then 
		print("entre -5 et 5 => zero")
    	table.insert(mesures, {type='command' , param='udevice', idx=idxpoids,nvalue=0, svalue=0} )
    	SetTarre(poidsnum);
	elseif (stable==1 and poids<0)  then  -- marge 
		print("< zero")
		mesures={};
		DoTarre() ;
	elseif ((prec_poids - poids )> 2 * poidstolerance)  then  -- On a perdu plus de 10 grammes
		print("Perte de plus de 10 grammes")
		mesures={};
		DoTarre() ;
	elseif  (stable==1   and  (math.abs(poids-prec_poids) < poidstolerance) )  then
     	print('delta faible: poids = prec_poids ='..prec_poids);
    	table.insert(mesures, {type='command' , param='udevice', idx=idxpoids,nvalue=0, svalue=prec_poids} )
    	SetTarre(TARRE + HXRATIO *(poids-prec_poids)); -- on remet la tarre qui annule le poinds
	elseif  (stable==1 )  then
    	print("facteur : "..poids)
    	table.insert(mesures, {type='command' , param='udevice', idx=idxpoids, nvalue=0, svalue=poids} )
	end
	
  	ConnectWifi(postDomoticz, NodeSleep) ;  
end
function SetTarre(tarre)
			file.remove("tarre.lua" )
			file.open("tarre.lua" , "w" )
			file.write("TARRE="..tarre)
			file.close()
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
	poidsnum=moyenne(tabpoids,60);
	poids=math.floor(engramme(poidsnum));

	print ("poids precedent");
	if 	file.open("prec_poids.log" , "r" ) then 		
		prec_poids=tonumber(file.readline()); 
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


	return stable, poids, prec_poids,poidsnum;
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
			prec_poids=0;
			file.remove("prec_poids.log");
			file.open("prec_poids.log" , "w" );
			file.writeline(prec_poids);
			file.close();

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
