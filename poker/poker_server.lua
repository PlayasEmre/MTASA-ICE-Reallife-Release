--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local dgsOk, dgsErr = pcall(function()
	loadstring(exports.DGS:dgsImportFunction())()
end)

function showTransporteurRouteSelection_func ()

	local skill = vioClientGetElementData ( "truckerlvl" )
	if skill > 50 then
		skill = 50
	end

	gWindow["transporteur"] = dgsCreateWindow(screenwidth/2-329/2,screenheight/2-209/2,329,209,"Transporteur",false)
	gLabel[1] = dgsCreateLabel(10,22,307,27,"Hier kannst du einen Auftrag annehmen und deinen\nLevel einsehen, der pro Auftrag steigt.",false,gWindow["transporteur"])
	dgsLabelSetColor(gLabel[1],200,200,0,255)
	dgsLabelSetVerticalAlign(gLabel[1],"top")
	dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
	dgsSetFont(gLabel[1],"default-bold")

	gImage["skill"] = createSkillBar ( skill / 50, gWindow["transporteur"], 30, 73, 77, 21 )

	gLabel[2] = dgsCreateLabel(20,2,38,16,"LVL "..skill,false,gImage["skill"])
	dgsLabelSetColor(gLabel[2],0,0,0,255)
	dgsLabelSetVerticalAlign(gLabel[2],"top")
	dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
	dgsSetFont(gLabel[2],"default-bold")
	gLabel[3] = dgsCreateLabel(19,57,85,18,"Dein Level:",false,gWindow["transporteur"])
	dgsLabelSetColor(gLabel[3],255,255,255,255)
	dgsLabelSetVerticalAlign(gLabel[3],"top")
	dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
	dgsSetFont(gLabel[3],"default-bold")
	gLabel[4] = dgsCreateLabel(194,56,57,16,"Fahrzeug",false,gWindow["transporteur"])
	dgsLabelSetColor(gLabel[4],255,255,255,255)
	dgsLabelSetVerticalAlign(gLabel[4],"top")
	dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
	dgsSetFont(gLabel[4],"default-bold")

	if skill >= 5 then
		gCheck["truckerTime"] = dgsCreateCheckBox(14,101,88,23,"Zeitfahrt",false,false,gWindow["transporteur"])
		dgsSetFont(gCheck["truckerTime"],"default-bold")
		if skill >= 20 then
			gCheck["truckerDanger"] = dgsCreateCheckBox(14,121,93,23,"Gefahrengut",false,false,gWindow["transporteur"])
			dgsSetFont(gCheck["truckerDanger"],"default-bold")
		end
	end

	gRadio["truckerPizzaboy"] = dgsCreateRadioButton(163,72,107,16,"Pizzaboy",false,gWindow["transporteur"])
	dgsSetFont(gRadio["truckerPizzaboy"],"default-bold")
	if skill >= 10 then
		gRadio["truckerVan"] = dgsCreateRadioButton(163,88,107,16,"Van",false,gWindow["transporteur"])
		dgsSetFont(gRadio["truckerVan"],"default-bold")
		if skill >= 15 then
			gRadio["truckerRoadtrain"] = dgsCreateRadioButton(163,88+16,107,16,"Roadtrain",false,gWindow["transporteur"])
			dgsSetFont(gRadio["truckerRoadtrain"],"default-bold")
			if skill >= 25 then
				gRadio["truckerLinerunner"] = dgsCreateRadioButton(163,88+16*2,107,16,"Linerunner",false,gWindow["transporteur"])
				dgsSetFont(gRadio["truckerLinerunner"],"default-bold")
				if skill >= 30 then
					gRadio["truckerTanker"] = dgsCreateRadioButton(163,88+16*3,107,16,"Tanker",false,gWindow["transporteur"])
					dgsSetFont(gRadio["truckerTanker"],"default-bold")
				end
			end
		end
	end

	gButton["startTour"] = dgsCreateButton(39,152+5,77,40,"Tour starten",false,gWindow["transporteur"],
		nil,nil,nil,nil,nil,nil, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gButton["closeTourButton"] = dgsCreateButton(329-39-77,152+5,77,40,"Fenster schliessen",false,gWindow["transporteur"],
		nil,nil,nil,nil,nil,nil, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

	gLabel[5] = dgsCreateLabel(123,155,55,16,"Gewinn:",false,gWindow["transporteur"])
	dgsLabelSetColor(gLabel[5],200,200,0,255)
	dgsLabelSetVerticalAlign(gLabel[5],"top")
	dgsLabelSetHorizontalAlign(gLabel[5],"left",false)
	dgsSetFont(gLabel[5],"default-bold")
	gLabel["paymentForJob"] = dgsCreateLabel(136,170,55,16,"0 $",false,gWindow["transporteur"])
	dgsLabelSetColor(gLabel["paymentForJob"],0,200,0,255)
	dgsLabelSetVerticalAlign(gLabel["paymentForJob"],"top")
	dgsLabelSetHorizontalAlign(gLabel["paymentForJob"],"left",false)
	dgsSetFont(gLabel["paymentForJob"],"default-bold")

	addEventHandler ( "onDgsMouseClickUp", gButton["closeTourButton"],
		function ()
			if isElement ( gWindow["transporteur"] ) then
				destroyElement ( gWindow["transporteur"] )
			end
			gWindow["transporteur"] = nil
			showCursor ( false )
			setElementClicked ( false )
		end,
	false )
	addEventHandler ( "onDgsMouseClickUp", gButton["startTour"],
		function ()
			showCursor ( false )
			setElementClicked ( false )

			if  dgsRadioButtonGetSelected ( gRadio["truckerPizzaboy"] ) then
				triggerServerEvent ( "startTransporteurRoute", lp, "pizza", dgsCheckBoxGetSelected ( gCheck["truckerTime"] ), dgsCheckBoxGetSelected ( gCheck["truckerDanger"] ) )

			elseif  dgsRadioButtonGetSelected ( gRadio["truckerVan"] ) then
				triggerServerEvent ( "startTransporteurRoute", lp, "van", dgsCheckBoxGetSelected ( gCheck["truckerTime"] ), dgsCheckBoxGetSelected ( gCheck["truckerDanger"] ) )
			elseif   dgsRadioButtonGetSelected ( gRadio["truckerRoadtrain"] ) then
				triggerServerEvent ( "startTransporteurRoute", lp, "roadtrain", dgsCheckBoxGetSelected ( gCheck["truckerTime"] ), dgsCheckBoxGetSelected ( gCheck["truckerDanger"] ) )
			elseif   dgsRadioButtonGetSelected ( gRadio["truckerLinerunner"] ) then
				triggerServerEvent ( "startTransporteurRoute", lp, "linerunner", dgsCheckBoxGetSelected ( gCheck["truckerTime"] ), dgsCheckBoxGetSelected ( gCheck["truckerDanger"] ) )
			elseif  dgsRadioButtonGetSelected ( gRadio["truckerTanker"] ) then
				triggerServerEvent ( "startTransporteurRoute", lp, "tanker", dgsCheckBoxGetSelected ( gCheck["truckerTime"] ), dgsCheckBoxGetSelected ( gCheck["truckerDanger"] ) )
			end
			if isElement ( gWindow["transporteur"] ) then
				destroyElement ( gWindow["transporteur"] )
			end
			gWindow["transporteur"] = nil
		end,
	false )
	refreshTruckerMoneyAmount ()
end
addEvent ( "showTransporteurRouteSelection", true )
addEventHandler ( "showTransporteurRouteSelection", getRootElement(), showTransporteurRouteSelection_func )

function refreshTruckerMoneyAmount ()

	if isElement ( gWindow["transporteur"] ) then
		local veh
		if gRadio["truckerPizzaboy"] and dgsRadioButtonGetSelected ( gRadio["truckerPizzaboy"] ) then
			veh = "pizza"
		elseif gRadio["truckerVan"] and dgsRadioButtonGetSelected ( gRadio["truckerVan"] ) then
			veh = "van"
		elseif  gRadio["truckerRoadtrain"] and dgsRadioButtonGetSelected ( gRadio["truckerRoadtrain"] ) then
			veh = "roadtrain"
		elseif gRadio["truckerLinerunner"] and  dgsRadioButtonGetSelected ( gRadio["truckerLinerunner"] ) then
			veh = "linerunner"
		elseif gRadio["truckerTanker"] and dgsRadioButtonGetSelected ( gRadio["truckerTanker"] ) then
			veh = "tanker"
		end

		local amount = calcTruckerJobTourValue ( veh, dgsCheckBoxGetSelected ( gCheck["truckerTime"] ), dgsCheckBoxGetSelected ( gCheck["truckerDanger"] ) )

		dgsSetText ( gLabel["paymentForJob"], amount.."$" )
		setTimer ( refreshTruckerMoneyAmount, 200, 1 )
	end
end

local truckerJobMissionTimeLeft

function startTruckerJobTimer_func ( seconds )

	truckerJobMissionTimeLeft = seconds
	-- falls der Timer erneut gestartet wird, bevor der alte fertig/entfernt ist,
	-- nicht doppelt registrieren (sonst zeichnet sich der Text mehrfach uebereinander)
	removeEventHandler ( "onClientRender", getRootElement(), renderTruckerJobTimer )
	addEventHandler ( "onClientRender", getRootElement(), renderTruckerJobTimer )
	setTimer ( truckerJobTime, 950, 1 )
end
addEvent ( "startTruckerJobTimer", true )
addEventHandler ( "startTruckerJobTimer", getRootElement(), startTruckerJobTimer_func )

function truckerJobTime ()

	local veh = getPedOccupiedVehicle ( lp )
	if veh then
		if isElement ( veh ) then
			truckerJobMissionTimeLeft = truckerJobMissionTimeLeft - 1
			if truckerJobMissionTimeLeft > 0 then
				setTimer ( truckerJobTime, 950, 1 )
			else
				removeEventHandler ( "onClientRender", getRootElement(), renderTruckerJobTimer )
				triggerServerEvent ( "truckerJobTimeExpired", lp )
				setTimer (
					function ()
						removeEventHandler ( "onClientRender", getRootElement(), renderTruckerJobTimer )
					end,
				2000, 1 )
			end
		else
			removeEventHandler ( "onClientRender", getRootElement(), renderTruckerJobTimer )
		end
	else
		removeEventHandler ( "onClientRender", getRootElement(), renderTruckerJobTimer )
	end
end

function renderTruckerJobTimer ()

	dxDrawText ( truckerJobMissionTimeLeft.." Sekunden", 1, 1, screenwidth+2, screenheight+2, tocolor ( 0, 0, 0, 255), 1, "bankgothic", "center", "bottom", false, false, true )
	dxDrawText ( truckerJobMissionTimeLeft.." Sekunden", 0, 0, screenwidth, screenheight, tocolor ( 200, 200, 200, 255), 1, "bankgothic", "center", "bottom", false, false, true )
end

-- Outsource? --
local missionStateToShow = ""
local mStateC = { ["r"]=0, ["g"]=0, ["b"]=0 }

function showMissionState ( text, time, r, g, b )

	missionStateToShow = text
	mStateC["r"] = r
	mStateC["g"] = g
	mStateC["b"] = b
	removeEventHandler ( "onClientRender", getRootElement(), renderMissionState )
	addEventHandler ( "onClientRender", getRootElement(), renderMissionState )
	setTimer ( 
		function ()
			removeEventHandler ( "onClientRender", getRootElement(), renderMissionState )
		end,
	time, 1 )
end
addEvent ( "showMissionState", true )
addEventHandler ( "showMissionState", getRootElement(), showMissionState )

function renderMissionState ()

	dxDrawText ( missionStateToShow, 2, 2, screenwidth+2, screenheight+2, tocolor ( 0, 0, 0, 255), 3, "pricedown", "center", "center", false, false, true )
	dxDrawText ( missionStateToShow, 0, 0, screenwidth, screenheight, tocolor ( mStateC["r"], mStateC["g"], mStateC["b"], 255), 3, "pricedown", "center", "center", false, false, true )
end

function showTruckerJobDamageBar_func ()

	gWindow["vehDamage"] = dgsCreateWindow(screenwidth/2-137/2,0,137,58,"Schaden",false)
	gProgress["vehDamage"] = dgsCreateProgressBar(9,19,118,29,false,gWindow["vehDamage"])
	setTimer ( checkTruckerJobVehDamage, 200, 1 )
end
addEvent ( "showTruckerJobDamageBar", true )
addEventHandler ( "showTruckerJobDamageBar", getRootElement(), showTruckerJobDamageBar_func )

function checkTruckerJobVehDamage ()

	local veh = getPedOccupiedVehicle ( lp )
	if veh then
		if isElement ( veh ) then
			if not isPedDead ( lp ) then
				local dmg = ( 1000 - getElementHealth ( veh ) ) * 3
				if dmg > 100 then
					dmg = 100
				end
				dgsProgressBarSetProgress ( gProgress["vehDamage"], dmg )
				if dmg >= 100 then
					triggerServerEvent ( "explodeMyTruck", lp )
				else
					setTimer ( checkTruckerJobVehDamage, 200, 1 )
					return nil
				end
			end
		end
	end
	if isElement ( gWindow["vehDamage"] ) then
		destroyElement ( gWindow["vehDamage"] )
	end
	gWindow["vehDamage"] = nil
end