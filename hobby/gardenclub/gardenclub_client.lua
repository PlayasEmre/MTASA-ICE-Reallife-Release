--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function showGardenCenterMenue_func ()

	if gWindow["gardenclub"] then
		if isElement ( gWindow["gardenclub"] ) then
			destroyElement ( gWindow["gardenclub"] )
		end
	end
	guiSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	setElementClicked ( true )

	local GRID_X, GRID_Y, GRID_W, GRID_H = 10, 20, 225, 182
	local BTN_X, BTN_W, BTN_H, BTN_SPACING = 245, 95, 50, 10
	local EDIT_Y = GRID_Y + GRID_H + 4
	local EDIT_H = 40
	local BTN_Y1 = GRID_Y
	local BTN_Y2 = BTN_Y1 + BTN_H + BTN_SPACING
	local BTN_Y3 = BTN_Y2 + BTN_H + BTN_SPACING
	local BTN_Y4 = BTN_Y3 + BTN_H + BTN_SPACING
	local WIN_W, WIN_H = 534, 275

	gWindow["gardenclub"] = dgsCreateWindow(screenwidth/2-WIN_W/2,screenheight/2-WIN_H/2,WIN_W,WIN_H,"Gartenclub \"The Uphill Gardner\"",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
	dgsWindowSetSizable ( gWindow["gardenclub"], false )
	dgsWindowSetMovable ( gWindow["gardenclub"], false )
	dgsBringToFront ( gWindow["gardenclub"] )
	dgsSetProperty ( gWindow["gardenclub"], "image", false )
	gLabel[1] = dgsCreateLabel(355,GRID_Y,175,192,"Herzlich Willkommen beim\nGartenclub! Hier kannst du\nalles rund um den Garten\nkaufen - von Blumen-\nsamen ueber Werkzeuge\nbis zu Zierobjekten.\n\n\nDie Kosten fuer eine\nMitgliedschaft betragen\neinmal 200 $ sowie\n30 $ / Stunde",false,gWindow["gardenclub"])
	dgsLabelSetColor(gLabel[1],200,200,0)
	dgsLabelSetVerticalAlign(gLabel[1],"top")
	dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
	dgsSetFont(gLabel[1],"default-bold")
	gLabel[2] = dgsCreateLabel(GRID_X+110,EDIT_Y+(EDIT_H-17)/2,110,17,"Gramm Drogen",false,gWindow["gardenclub"])
	dgsLabelSetColor(gLabel[2],255,255,255)
	dgsLabelSetVerticalAlign(gLabel[2],"top")
	dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
	dgsSetFont(gLabel[2],"default-bold")

	gGrid["gardenclub"] = dgsCreateGridList(GRID_X,GRID_Y,GRID_W,GRID_H,false,gWindow["gardenclub"])
	dgsGridListSetSelectionMode(gGrid["gardenclub"],0)

	gColumn["gardenclubObject"] = dgsGridListAddColumn(gGrid["gardenclub"],"Objekt",0.55)
	gColumn["gardenclubPrice"] = dgsGridListAddColumn(gGrid["gardenclub"],"Preis",0.25)

	gButton["gardenclubBuy"] = dgsCreateButton(BTN_X,BTN_Y2,BTN_W,BTN_H,"Kaufen",false,gWindow["gardenclub"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gButton["gardenclubClose"] = dgsCreateButton(BTN_X,BTN_Y3,BTN_W,BTN_H,"Schliessen",false,gWindow["gardenclub"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gButton["gardenclubSell"] = dgsCreateButton(BTN_X,BTN_Y4,BTN_W,BTN_H,"Verkaufen",false,gWindow["gardenclub"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

	if vioClientGetElementData ( "club" ) == "gartenverein" then
		gButton["joinLeaveGardenclub"] = dgsCreateButton(BTN_X,BTN_Y1,BTN_W,BTN_H,"Mitglied werden",false,gWindow["gardenclub"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	else
		gButton["joinLeaveGardenclub"] = dgsCreateButton(BTN_X,BTN_Y1,BTN_W,BTN_H,"Club verlassen",false,gWindow["gardenclub"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	end

	addEventHandler ( "onDgsMouseClickUp", gButton["joinLeaveGardenclub"],
		function (btn)
			if btn ~= "left" then return end
			if dgsGetText ( gButton["joinLeaveGardenclub"] ) == "Mitglied werden" then
				dgsSetText ( gButton["joinLeaveGardenclub"], "Club verlassen" )
				triggerServerEvent ( "joinGartenverein", lp )
			else
				dgsSetText ( gButton["joinLeaveGardenclub"], "Mitglied werden" )
				triggerServerEvent ( "leaveGardenclub", lp )
			end
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gardenclubClose"],
		function (btn)
			if btn ~= "left" then return end
			guiSetInputMode ( "allow_binds" )
			showCursor ( false )
			setElementClicked ( false )
			destroyElement ( gWindow["gardenclub"] )
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gardenclubSell"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "drugsSellHobby", lp, tonumber ( dgsGetText ( gNumberField["drugCount"] ) ) )
			dgsSetText ( gNumberField["drugCount"], "0" )
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gardenclubBuy"],
		function (btn)
			if btn ~= "left" then return end
			local row, column = dgsGridListGetSelectedItem ( gGrid["gardenclub"] )
			if row == -1 then return end
			local value = dgsGridListGetItemText ( gGrid["gardenclub"], row, gColumn["gardenclubObject"] )

			if value == "Rasenmaeher" then
				triggerServerEvent ( "BuyMowerServer", lp )
				closeGardenClubWindow ()
			elseif value == "Schaufel" then
				triggerServerEvent ( "BuyShovelServer", lp )
			elseif value == "Hansamen" then
				triggerServerEvent ( "BuyFlowersServer", lp )
			else
				local id = 0

				for key, index in pairs ( placeAblesToBeSaved ) do
					if index == value then
						id = key
						break
					end
				end

				triggerServerEvent ( "buyGardenClubObject", lp, id )
			end
		end,
	false )

	local row = dgsGridListAddRow ( gGrid["gardenclub"] )
	dgsGridListSetItemText ( gGrid["gardenclub"], row, gColumn["gardenclubObject"], "Rasenmaeher", false, false )
	dgsGridListSetItemText ( gGrid["gardenclub"], row, gColumn["gardenclubPrice"], "600 $", false, false )
	local row = dgsGridListAddRow ( gGrid["gardenclub"] )
	dgsGridListSetItemText ( gGrid["gardenclub"], row, gColumn["gardenclubObject"], "Schaufel", false, false )
	dgsGridListSetItemText ( gGrid["gardenclub"], row, gColumn["gardenclubPrice"], "15 $", false, false )
	local row = dgsGridListAddRow ( gGrid["gardenclub"] )
	dgsGridListSetItemText ( gGrid["gardenclub"], row, gColumn["gardenclubObject"], "Hansamen", false, false )
	dgsGridListSetItemText ( gGrid["gardenclub"], row, gColumn["gardenclubPrice"], "500 $", false, false )

	for key, index in pairs ( placeAblesToBeSaved ) do
		local row = dgsGridListAddRow ( gGrid["gardenclub"] )
		dgsGridListSetItemText ( gGrid["gardenclub"], row, gColumn["gardenclubObject"], index, false, false )
		dgsGridListSetItemText ( gGrid["gardenclub"], row, gColumn["gardenclubPrice"], placeAblesPrices[key].." $", false, false )
	end

	-- guiCreateNumberField hat kein direktes DGS-Aequivalent: dgsCreateEdit
	-- + Validierung im Change-Handler bildet die Zahlenbeschraenkung nach.
	gNumberField["drugCount"] = dgsCreateEdit ( GRID_X, EDIT_Y, 100, EDIT_H, "0", false, gWindow["gardenclub"] )
	addEventHandler ( "onDgsChanged", gNumberField["drugCount"],
		function ()
			local text = dgsGetText ( gNumberField["drugCount"] )
			local num = tonumber ( ( text:gsub ( "%D", "" ) ) )
			dgsSetText ( gNumberField["drugCount"], tostring ( num or 0 ) )
		end,
	false )
end
addEvent ( "showGardenCenterMenue", true )
addEventHandler ( "showGardenCenterMenue", getRootElement(), showGardenCenterMenue_func )

function closeGardenClubWindow ()

	guiSetInputMode ( "allow_binds" )
	showCursor ( false )
	setElementClicked ( false )
	destroyElement ( gWindow["gardenclub"] )
end

gartenvereinPickup = createPickup ( -2579.8989257813, 310.11599731445, 4.87415599823, 3, 1239, 50, 0 )

function gartenvereinPickup_hit ( hit )

	if hit == lp then
		showGardenCenterMenue_func ()
	end
end
addEventHandler ( "onClientPickupHit", gartenvereinPickup, gartenvereinPickup_hit )


---------------------------------------------------------------------
-- Wachstums-Anzeige ueber gepflanztem Hanf
---------------------------------------------------------------------
-- Der Ertrag richtet sich allein nach der vergangenen Zeit. Die Formel
-- ist dieselbe wie beim Ernten in clicksys/clicksys_server.lua:
--     Gramm = floor( (jetzt - Pflanzzeit) / WEED_MINUTEN_PRO_GRAMM )
-- getMinTime() liefert Minuten und steht ueber usefull/utility.lua auch
-- hier zur Verfuegung, die Pflanzzeit kommt per Elementdata vom Server.

local WEED_MINUTEN_PRO_GRAMM = 20    -- 20 Minuten = 1 Gramm
local WEED_MAX_GRAMM         = 50    -- Deckel, wie beim Ernten (clicksys_server.lua)
local WEED_SICHTWEITE        = 20    -- ab hier wird der Text gezeichnet
local WEED_TEXTHOEHE         = 1.9   -- Hoehe ueber der Pflanze, damit der
                                     -- Text ueber dem Busch steht statt darin

local hanfPflanzen = {}   -- [Objekt] = true, nur was gerade gestreamt ist

local function istHanf ( element )
	return isElement ( element ) and getElementData ( element, "weedPlantTime" ) and true or false
end

local function merkeHanf ( element )
	if istHanf ( element ) then hanfPflanzen[element] = true end
end

addEventHandler ( "onClientElementStreamIn", root, function () merkeHanf ( source ) end )
addEventHandler ( "onClientElementStreamOut", root, function () hanfPflanzen[source] = nil end )
addEventHandler ( "onClientElementDestroy", root, function () hanfPflanzen[source] = nil end )

-- Der Server setzt die Pflanzzeit unmittelbar nach dem Erzeugen - zu diesem
-- Zeitpunkt ist das Objekt eventuell schon gestreamt und der StreamIn oben
-- damit verpasst. Deshalb zusaetzlich auf die Datenaenderung hoeren.
addEventHandler ( "onClientElementDataChange", root, function ( key )
	if key == "weedPlantTime" then merkeHanf ( source ) end
end )

-- Beim Ressourcenstart alles einsammeln, was bereits in der Naehe steht.
addEventHandler ( "onClientResourceStart", resourceRoot, function ()
	for _, obj in ipairs ( getElementsByType ( "object", root, true ) ) do
		merkeHanf ( obj )
	end
end )

-- Gibt Gramm und Fortschritt in Prozent zurueck.
local function getWachstum ( pflanzzeit )
	local minuten = getMinTime () - pflanzzeit
	if minuten < 0 then minuten = 0 end

	local gramm = math.floor ( minuten / WEED_MINUTEN_PRO_GRAMM )
	if gramm > WEED_MAX_GRAMM then gramm = WEED_MAX_GRAMM end

	return gramm, math.floor ( gramm / WEED_MAX_GRAMM * 100 ), minuten
end

-- "noch 3 Std. 20 Min." bis zur vollen Reife
local function getRestText ( minuten )
	local rest = WEED_MAX_GRAMM * WEED_MINUTEN_PRO_GRAMM - minuten
	if rest <= 0 then return "ausgewachsen" end

	local std = math.floor ( rest / 60 )
	local min = math.floor ( rest % 60 )
	if std > 0 then return "noch "..std.." Std. "..min.." Min." end
	return "noch "..min.." Min."
end

addEventHandler ( "onClientRender", root, function ()
	local px, py, pz = getElementPosition ( lp )

	-- Nur EINE Anzeige, naemlich fuer die naechstgelegene Pflanze. Bei einem
	-- ganzen Feld stand sonst ueber jeder Pflanze ein Text und der halbe
	-- Bildschirm war zugepflastert.
	local naechste, kleinsteDistanz

	for pflanze in pairs ( hanfPflanzen ) do
		if not isElement ( pflanze ) then
			hanfPflanzen[pflanze] = nil
		else
			local x, y, z = getElementPosition ( pflanze )
			local entfernung = getDistanceBetweenPoints3D ( px, py, pz, x, y, z )

			if entfernung <= WEED_SICHTWEITE and ( not kleinsteDistanz or entfernung < kleinsteDistanz ) then
				naechste, kleinsteDistanz = pflanze, entfernung
			end
		end
	end

	if not naechste then return end

	local x, y, z = getElementPosition ( naechste )

	-- Nur Gebaeude blockieren die Sicht. Objekte duerfen es NICHT, denn die
	-- Pflanze ist selbst ein Objekt (samt zwei angehefteter Kisten) und hat
	-- sich damit staendig selbst verdeckt.
	if not isLineOfSightClear ( px, py, pz, x, y, z + WEED_TEXTHOEHE, true, false, false, false, false ) then return end

	local sx, sy = getScreenFromWorldPosition ( x, y, z + WEED_TEXTHOEHE )
	if not sx then return end

	local pflanzzeit = tonumber ( getElementData ( naechste, "weedPlantTime" ) ) or 0
	local gramm, prozent, minuten = getWachstum ( pflanzzeit )

	-- Rot -> Gelb -> Gruen, je weiter das Wachstum ist
	local r = ( prozent < 50 ) and 255 or math.floor ( 255 - ( prozent - 50 ) * 5.1 )
	local g = ( prozent < 50 ) and math.floor ( prozent * 5.1 ) or 255

	-- Weiter weg kleiner zeichnen
	local skalierung = 1.15 - ( kleinsteDistanz / WEED_SICHTWEITE ) * 0.4

	local text = "Hanf: "..prozent.." % ("..gramm.." g) - "..getRestText ( minuten )
	dxDrawText ( text, sx+1, sy+1, sx+1, sy+1, tocolor(0,0,0,200), skalierung, "default-bold", "center", "center" )
	dxDrawText ( text, sx, sy, sx, sy, tocolor(r,g,0,255), skalierung, "default-bold", "center", "center" )
end )
