--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local blitzer={ -- Format: {Blitzer-X, Blitzer-Y, Blitzer-Z, Blitzer-RotZ, Colshape-X, Colshape-Y, Colshape-Z, Colshape-Radius, Max speed}
	{
	pos={-1551.8,601.5,6.1,344,-1555.8,579.9,6.5,4.5,80},--SFPD
	},
	{
	pos={-2012.2,150.8,26.7,167,-2009.5,174.7,26.9,4,80},--SF Bahnhof
	},
	{
	pos={-2150.9,1067.7,54.6,107,-2137.7,1072.5,54.9,5,80},--SF Kirche Tunnel
	},
	{
	pos={-2814.3,115.7,6.2,168,-2811.4,132.6,6.4,4,80},--SF Strand
	},
	{
	pos={-2073,-1145.9,30.3,6.5,-2066.7,-1166.3,31.6,4,80},--SanNews Unten Landstraße
	},
}


for i,v in ipairs(blitzer)do
	local oX,oY,oZ,orZ,cX,cY,cZ,cS,maxSpeed=unpack(v.pos)
	v.object=createObject(3890,oX,oY,oZ,0,0,orZ)
	
	local bin=createObject(1668,0,0,0)
	attachElements(bin,v.object,0.8,-0.7,6)
	local eX,eY,eZ=getElementPosition(bin)
	detachElements(bin,v.object)
	destroyElement(bin)
	
	v.colsphere=createColSphere(cX,cY,cZ,cS)
	addEventHandler("onColShapeHit",v.colsphere,function(ele,dim)
		if(dim and getElementType(ele)=="player")then
			local veh=getPedOccupiedVehicle(ele)
			if isFederalCar(veh) == false and MtxGetElementData(ele,"adminduty") ~= true and not isEmergencyOnDuty(ele) then
				if(veh and getPedOccupiedVehicleSeat(ele)==0)then
					local vehTyp=getVehicleType(veh)
					if(vehTyp=="Automobile" or vehTyp=="Bike" or vehTyp=="Quad" or vehTyp=="Monster Truck")then
						local speed=getElementSpeed(veh)
						if((speed-3)>maxSpeed)then
							-- Die 100er-Kugel wurde bisher angelegt und ungenutzt sofort wieder
							-- zerstoert, waehrend der Blitz an ALLE Spieler des Servers ging -
							-- inklusive derer am anderen Ende der Karte, die den Effekt gar
							-- nicht sehen koennen. Jetzt wird die Kugel wie offensichtlich
							-- gedacht zum Eingrenzen benutzt.
							local effectCol=createColSphere(cX,cY,cZ,100)
							triggerClientEvent(ele,"radarEffect",ele,eX,eY,eZ,true)
							for _,naherSpieler in ipairs(getElementsWithinColShape(effectCol,"player"))do
								if (naherSpieler~=ele)then
									triggerClientEvent(naherSpieler,"radarEffect",naherSpieler,eX,eY,eZ)
								end
							end
							destroyElement(effectCol)

							local over=math.ceil(speed)-maxSpeed
							local points=math.ceil(over/40)
							local price=math.ceil(over*15)
							
							local hasLicense = false
							-- vehTyp steht schon oben fest; getVehicleType wurde hier
							-- bis zu fuenfmal fuer dasselbe Fahrzeug aufgerufen.
							if(vehTyp=="Automobile" and tonumber(MtxGetElementData(ele,"carlicense"))==1)then
								hasLicense="carlicense"
							elseif((vehTyp=="Bike" or vehTyp=="Quad")and tonumber(MtxGetElementData(ele,"bikelicense"))==1)then
								hasLicense="bikelicense"
							elseif((vehTyp=="Monster Truck" or vehTyp=="truck")and tonumber(MtxGetElementData(ele,"lkwlicense"))==1)then
								hasLicense="lkwlicense"
							end
							
							local fix = ""
							if hasLicense ~= false then
								MtxSetElementData(ele,"stvo_punkte",tonumber(MtxGetElementData(ele,"stvo_punkte"))+points)
								if (tonumber(MtxGetElementData(ele,"stvo_punkte")) >= 15)  then
									outputChatBox("Du hast "..tonumber(MtxGetElementData(ele,"stvo_punkte")).." StVo-Punkte, dein Führerschein wurde dir entzogen. Du musst die Führerscheinprüfung nun bei der Fahrschule wiederholen.",ele)
									
									MtxSetElementData(ele,"stvo_punkte",0)
									MtxSetElementData(ele,hasLicense,0)
								end
								
								fix="StVo-Punkte: "..points
								
							else
								fix="\rDa Du keinen Führerschein hast, erhälst Du einen Wanted."
								MtxSetElementData(ele,"wanteds",tonumber(MtxGetElementData(ele,"wanteds"))+1)
							end
							if MtxGetElementData(ele,"wanteds") >= 6 then
								MtxSetElementData(ele,"wanteds",6)
							end
							outputChatBox("Du wurdest mit "..math.ceil(speed).." km/h bei erlaubten "..maxSpeed.." km/h geblitzt.\nGeldbuße: "..price.." "..Tables.waehrung.."\n"..fix,ele)
							MtxSetElementData(ele,"money",tonumber(MtxGetElementData(ele,"money"))-price)
						end
					end
				end
			end
		end
	end)
end