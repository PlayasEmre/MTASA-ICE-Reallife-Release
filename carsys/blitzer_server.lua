--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

	radar1 = createColRectangle ( -2011.8345, 218.438, 10, 5) 
	radar2 = createColRectangle ( -2011.4978, 93.25705, 10, 5) 
	radar3 = createColRectangle ( -2010.812133, -185.08035, 11, 5)
	radar4 = createColRectangle ( -2264.72998, -217.94844, 15, 5) 
	radar5 = createColRectangle ( -2229.594482, -432.1216735, 14,13)
	radar7 = createColRectangle ( -1742.245239, -588.8187255, 5, 18)
	radar8 = createColRectangle ( -1159.438354, -633.45825, 11, 5)
	radar9 = createColRectangle ( -1794.294677, -261.0491333, 11, 5)
	radar10 = createColRectangle ( -2415.578125, -49.5086555, 11, 5)
	radar11 = createColRectangle ( -2701.43261, -37.31998, 10, 5)
	radar12 = createColRectangle ( -2614.12939, -205.47074, 5, 11)
	radar13 = createColRectangle ( -2869.687255, 410.109283, 11, 5)
	radar14 = createColRectangle ( -2883.389160, 768.004638, 11, 5)
	radar15 = createColRectangle ( -2886.205078, 1128.89648, 11, 5)
	radar16 = createColRectangle ( -2422.1071777, 1369.45861816, 5, 11)
	radar17 = createColRectangle ( -1951.036254, 1279.9434814, 5, 40)
	radar18 = createColRectangle ( -1661.9119873, 1234.536987, 25, 30)
	radar19 = createColRectangle ( -15677.732666, 945.388427734, 60, 5)
	radar20 = createColRectangle ( -1680.89685, 910.934936, 5, 30)
	radar21 = createColRectangle ( -1721.458496, 1073.769775, 16, 5)
	radar22 = createColRectangle ( -1721.6375732, 799.604248, 16, 5)
	radar23 = createColRectangle ( -1825.1883544, 598.6206665, 5, 16)
	radar24 = createColRectangle ( -2011.3417968, 689.3863525, 6, 5)
	radar25 = createColRectangle ( -1985.794067, 833.4367675, 5, 30)
	radar26 = createColRectangle ( -2060.1665039, 904.36804199, 5, 47)
	radar27 = createColRectangle ( -2122.567138, 726.615234, 5, 11)
	radar28 = createColRectangle ( -1971.79162597, 1092.3215332, 12, 5)
	radar29 = createColRectangle ( -2347.701904, 1168.2774658, 5, 20)
	radar30 = createColRectangle ( -2231.333740, 1260.1766357, 5, 23)
	radar31 = createColRectangle ( -2698.7302246, 1306.87109375, 35, 5)
	radar32 = createColRectangle ( -2739.6440429688, 1076.418457, 10, 7)
	radar33 = createColRectangle ( -2531.4711914, 920.300964355, 11, 5)
	radar34 = createColRectangle ( -2643.4624023, 805.538696289, 5, 11)
	radar35 = createColRectangle ( -2756.2209472656, 726.60247827, 11, 5)
	radar36 = createColRectangle ( -2703.90307617, 558.45233154, 5, 32)
	radar37 = createColRectangle ( -2531.61083984, 638.1580200, 11, 5)
	radar38 = createColRectangle ( -2459.5949707031, 902.8698730, 5, 12)
	radar39 = createColRectangle ( -2274.0903320313, 831.41638183594, 29, 5)
	radar40 = createColRectangle ( -2243.3251953125, 558.54174804688, 5, 15)
	radar41 = createColRectangle ( -2289.5261230469, 503.49188232, 5, 10)
	radar42 = createColRectangle ( -2488.2329101563, 452.47326660156, 6, 8)
	radar43 = createColRectangle ( -2551.5180664063, 266.55944824219, 8, 5)
	radar44 = createColRectangle ( -2638.9128417969, 152.99418640137, 5, 14)
	radar45 = createColRectangle ( -2256.75390625, 249.9610748291, 11, 5)
	radar46 = createColRectangle ( -2090.8374023438, 315.36212158203, 6, 11)
	radar47 = createColRectangle ( -2011.3564453125, 462.02648925781, 20, 5)
	radar48 = createColRectangle ( -1671.8796386719, 370.57818603516, 12, 11)
	
	radarfallentable = {
	 [1] = { radar1,0},
	 [2] = { radar2,0},
	 [3] = { radar3,0},
	 [4] = { radar4,0},
	 [5] = { radar5,0},
	 [6] = { radar6,0},
	 [7] = { radar7,0},
	 [8] = { radar8,0},
	 [9] = { radar9,0},
	 [10] = { radar10,0},
	 [11] = { radar11,0},
	 [12] = { radar12,0},
	 [13] = { radar13,0},
	 [14] = { radar14,0},
	 [15] = { radar15,0},
	 [16] = { radar16,0},
	 [17] = { radar17,0},
	 [18] = { radar18,0},
	 [19] = { radar19,0},
	 [20] = { radar20,0},
	 [21] = { radar21,0},
	 [22] = { radar22,0},
	 [23] = { radar23,0},
	 [24] = { radar24,0},
	 [25] = { radar25,0},
	 [26] = { radar26,0},
	 [27] = { radar27,0},
	 [28] = { radar28,0},
	 [29] = { radar29,0},
	 [30] = { radar30,0},
	 [31] = { radar31,0},
	 [32] = { radar32,0},
	 [33] = { radar33,0},
	 [34] = { radar34,0},
	 [35] = { radar35,0},
	 [36] = { radar36,0},
	 [37] = { radar37,0},
	 [38] = { radar38,0},
	 [39] = { radar39,0},
	 [40] = { radar40,0},
	 [41] = { radar41,0},
	 [42] = { radar42,0},
	 [43] = { radar43,0},
	 [44] = { radar44,0},
	 [45] = { radar45,0},
	 [46] = { radar46,0},
	 [47] = { radar47,0},
	 [48] = { radar48,0},
	 }

addEventHandler("onResourceStart",getRootElement(),
function()
	for index, radartable in ipairs (radarfallentable) do
		radartable[2] = math.random(1,10)
	end
end
)

function waehlefalleaus()
	for index, radartable in ipairs (radarfallentable) do
		radartable[2] = math.random(1,10)
	end
	setTimer(waehlefalleaus, 3600000, 1)
end

function ColRectangleHit(hitElement, matchingDimension)
	for	index, radardaten in ipairs(radarfallentable) do
		for index2, wert in ipairs(radardaten) do
			if (index2 == 1) then
				currentradar = wert
			elseif (index2 == 2) then
				currentradarstatus = wert
			end
		end
		if (source == currentradar) and (currentradarstatus == 10) then
			if getElementType ( hitElement ) == "vehicle" then
				if (getVehicleType ( hitElement )== "Automobile") or (getVehicleType ( hitElement )== "Bike") or (getVehicleType ( hitElement )== "Quad") or (getVehicleType ( hitElement )== "Monster Truck") then
					local currentdriver = getVehicleOccupant ( hitElement,0)
					if getVehicleSirensOn ( hitElement ) or isArmy(currentdriver) or isOnDuty(currentdriver) then
					else
						vx, vy, vz = getElementVelocity (hitElement)
						currentspeed = getKmhBySpeed ( math.sqrt(vx^2 + vy^2 + vz^2) )
						if (currentspeed >= 120 ) then
							local strafgelda = ((currentspeed-120)*2)
							local strafgeld = math.round(tonumber(strafgelda),0,round)
							local roundgeschw = (math.round((currentspeed),0,round)-120)
						
							local oldstvo = MtxGetElementData( currentdriver, "stvo_punkte" )
							
							local stvonumber = math.floor ( ( currentspeed - 140 ) / 20 ) + 1
							if stvonumber < 0 then
								stvonumber = 0
							end
							local newstvo = (oldstvo + tonumber(stvonumber))
							MtxSetElementData( currentdriver, "stvo_punkte", newstvo)
							outputChatBox("Du wurdest geblitzt! Du musst "..strafgeld..""..Tables.waehrung.." Strafe zahlen und hast "..stvonumber.." StVO-Punkt(e) erhalten, da du "..roundgeschw.."km/h zu schnell gefahren bist!", currentdriver,255,0,0)
							playSoundFrontEnd ( currentdriver, 43)
							fadeCamera ( currentdriver, false, 0.3, 255, 255, 255 )
							setTimer ( fadeCamera, 300, 1, currentdriver, true )
							takePlayerMoney ( currentdriver, tonumber(strafgeld))
							MtxSetElementData ( currentdriver, "money", MtxGetElementData ( currentdriver, "money" ) - strafgeld )
						end
					end
				end
			end
		end
	end
end
addEventHandler ( "onColShapeHit", getRootElement(), ColRectangleHit)

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

setTimer(waehlefalleaus, 2000, 1)

function getKmhBySpeed ( speed )
	return speed/218.77
end