--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local isintuninggarage = false

---------------------------------------------------------------------
-- Fahrzeug im Tuningmenue mit der rechten Maustaste drehen
---------------------------------------------------------------------
-- Die Kamera steht fest auf der Garage ( tuning_server.lua ), das Fahrzeug ist
-- eingefroren. Gedreht wird deshalb der Wagen, nicht die Kamera.
local DREH_FAKTOR = 0.4   -- Grad pro Pixel Mausbewegung

local drehtGerade   = false
local letzteMausX   = nil
local startRotation = nil

local function tuningDrehStart ()
	drehtGerade = true
	letzteMausX = nil
end

local function tuningDrehStop ()
	drehtGerade = false
	letzteMausX = nil
end

local function tuningDrehBewegung ( _, _, absX )
	if not drehtGerade or not isintuninggarage then return end
	local veh = getPedOccupiedVehicle ( lp )
	if not veh then return end

	if letzteMausX then
		local rx, ry, rz = getElementRotation ( veh )
		setElementRotation ( veh, rx, ry, ( rz + ( absX - letzteMausX ) * DREH_FAKTOR ) % 360 )
	end
	letzteMausX = absX
end

-- Nur waehrend des Tunings gebunden, damit die rechte Maustaste sonst
-- unveraendert bleibt.
local function tuningDrehenAn ()
	local veh = getPedOccupiedVehicle ( lp )
	if veh then
		startRotation = { getElementRotation ( veh ) }
	end
	drehtGerade, letzteMausX = false, nil
	bindKey ( "mouse2", "down", tuningDrehStart )
	bindKey ( "mouse2", "up", tuningDrehStop )
	addEventHandler ( "onClientCursorMove", root, tuningDrehBewegung )
end

local function tuningDrehenAus ()
	unbindKey ( "mouse2", "down", tuningDrehStart )
	unbindKey ( "mouse2", "up", tuningDrehStop )
	removeEventHandler ( "onClientCursorMove", root, tuningDrehBewegung )
	drehtGerade, letzteMausX = false, nil

	-- Ausgangsdrehung wiederherstellen, damit der Wagen nicht schraeg
	-- in der Garage steht, wenn man losfaehrt.
	local veh = getPedOccupiedVehicle ( lp )
	if veh and startRotation then
		setElementRotation ( veh, startRotation[1], startRotation[2], startRotation[3] )
	end
	startRotation = nil
end

-- Die drei Tuningfenster hatten feste Koordinaten ab 0,0 und lagen dadurch auf
-- jeder Aufloesung in der linken oberen Ecke - der Titel des Hauptfensters lag
-- ausserhalb des Bildes und die beiden schmalen Fenster ueberlappten es. Sie
-- werden jetzt als ein Block berechnet: am linken Bildrand, senkrecht mittig.
-- Hauptfenster links, Lichtfarbe und Nummernschild rechts daneben untereinander.
local FENSTER_ABSTAND = 8
local RAND_LINKS      = 20
local BREITE_SEITE = 177
-- Hoehen mit Reserve fuer die Titelleiste: die Kindelemente sitzen unterhalb
-- davon, weshalb die "Uebernehmen"-Knoepfe frueher unten aus dem Fenster ragten.
local HOEHE_LICHT, HOEHE_SCHILD = 235, 215
-- Hauptfenster genauso hoch wie der rechte Stapel, damit der Block unten
-- buendig abschliesst und die Liste die zusaetzliche Hoehe bekommt.
local BREITE_HAUPT = 406
local HOEHE_HAUPT  = HOEHE_LICHT + FENSTER_ABSTAND + HOEHE_SCHILD

-- Linke obere Ecke des gesamten Blocks.
local function tuningBlockEcke ()
	local _, bildHoehe = guiGetScreenSize ()
	local blockHoehe = math.max ( HOEHE_HAUPT, HOEHE_LICHT + FENSTER_ABSTAND + HOEHE_SCHILD )
	return RAND_LINKS, math.floor ( ( bildHoehe - blockHoehe ) / 2 )
end

function showPremiumWindow ()

		showCursor ( true )
		if gWindow["tuningPremium"] then
			dgsSetVisible ( gWindow["tuningPremium"], true )
			dgsBringToFront ( gWindow["tuningPremium"] )
		else
			local ex, ey = tuningBlockEcke ()
			gWindow["tuningPremium"] = dgsCreateWindow(ex+BREITE_HAUPT+FENSTER_ABSTAND,ey,BREITE_SEITE,HOEHE_LICHT,"Lichtfarbe",false)
			dgsBringToFront ( gWindow["tuningPremium"] )
			dgsWindowSetMovable(gWindow["tuningPremium"],false)
			dgsWindowSetSizable(gWindow["tuningPremium"],false)
			-- Kein X: das Fenster gehoert zur laufenden Tuningsitzung. Einzeln
			-- geschlossen bliebe der Wagen eingefroren und der Cursor an.
			dgsWindowSetCloseButtonEnabled(gWindow["tuningPremium"],false)
			gButton["submitLightColor"] = dgsCreateButton(16,152,147,38,"Übernehmen",false,gWindow["tuningPremium"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
			addEventHandler ( "onDgsMouseClickUp", gButton["submitLightColor"],
				function ( btn, state )
					if btn ~= "left" then return end
					local red = math.floor ( dgsScrollBarGetScrollPosition ( redScroll ) * 2.55 )
					local green = math.floor ( dgsScrollBarGetScrollPosition ( greenScroll ) * 2.55 )
					local blue = math.floor ( dgsScrollBarGetScrollPosition ( blueScroll ) * 2.55 )
					triggerServerEvent ( "applyLightValues", lp, red, green, blue )
				end,
			false )
			gLabel["tuningLightColor"] = dgsCreateLabel(16,10,147,18,"Lichtfarbe",false,gWindow["tuningPremium"])
			dgsLabelSetColor(gLabel["tuningLightColor"],255,255,255)
			dgsLabelSetVerticalAlign(gLabel["tuningLightColor"],"top")
			dgsLabelSetHorizontalAlign(gLabel["tuningLightColor"],"left",false)
			dgsSetFont(gLabel["tuningLightColor"],"default-bold")

			redScroll = dgsCreateScrollBar ( 16, 36, 147, 30, true, false, gWindow["tuningPremium"] )
			greenScroll = dgsCreateScrollBar ( 16, 72, 147, 30, true, false, gWindow["tuningPremium"] )
			blueScroll = dgsCreateScrollBar ( 16, 108, 147, 30, true, false, gWindow["tuningPremium"] )

			local function updateLightColorPreview ()
				local red = math.floor ( dgsScrollBarGetScrollPosition ( redScroll ) * 2.55 )
				local green = math.floor ( dgsScrollBarGetScrollPosition ( greenScroll ) * 2.55 )
				local blue = math.floor ( dgsScrollBarGetScrollPosition ( blueScroll ) * 2.55 )
				dgsLabelSetColor ( gLabel["tuningLightColor"], red, green, blue )
			end
			addEventHandler ( "onDgsScrollBarScrollPositionChange", redScroll, updateLightColorPreview )
			addEventHandler ( "onDgsScrollBarScrollPositionChange", greenScroll, updateLightColorPreview )
			addEventHandler ( "onDgsScrollBarScrollPositionChange", blueScroll, updateLightColorPreview )
		end
		-- Die Regler arbeiten mit 0-100, die Lichtfarbe mit 0-255. Ohne das
		-- Teilen wurden alle drei auf Anschlag gesetzt, egal welche Farbe das
		-- Fahrzeug hatte. Umgekehrt rechnet der Uebernehmen-Knopf mit *2.55.
		local veh = getPedOccupiedVehicle ( lp )
		if veh then
			local red, green, blue = getVehicleHeadLightColor ( veh )
			dgsScrollBarSetScrollPosition ( redScroll, ( red or 255 ) / 2.55 )
			dgsScrollBarSetScrollPosition ( greenScroll, ( green or 255 ) / 2.55 )
			dgsScrollBarSetScrollPosition ( blueScroll, ( blue or 255 ) / 2.55 )
		end
end

function showPlateWindow ()

		showCursor ( true )
		if gWindow["tuningPlate"] then
			dgsSetVisible ( gWindow["tuningPlate"], true )
			dgsBringToFront ( gWindow["tuningPlate"] )
		else
			local ex, ey = tuningBlockEcke ()
			gWindow["tuningPlate"] = dgsCreateWindow(ex+BREITE_HAUPT+FENSTER_ABSTAND,ey+HOEHE_LICHT+FENSTER_ABSTAND,BREITE_SEITE,HOEHE_SCHILD,"Nummernschild",false)
			dgsBringToFront ( gWindow["tuningPlate"] )
			dgsWindowSetMovable(gWindow["tuningPlate"],false)
			dgsWindowSetSizable(gWindow["tuningPlate"],false)
			dgsWindowSetCloseButtonEnabled(gWindow["tuningPlate"],false)

			gLabel["tuningPlateColor"] = dgsCreateLabel(16,10,147,80,"Hier kannst du den Text\nauf deinem Nummernschild\nändern, er darf maximal\n8 Zeichen lang sein.",false,gWindow["tuningPlate"])
			dgsLabelSetColor(gLabel["tuningPlateColor"],255,255,255)
			dgsLabelSetVerticalAlign(gLabel["tuningPlateColor"],"top")
			dgsLabelSetHorizontalAlign(gLabel["tuningPlateColor"],"left",false)
			dgsSetFont(gLabel["tuningPlateColor"],"default-bold")

			gEdit["PlateText"] = dgsCreateEdit ( 16, 98, 147, 34, "", false, gWindow["tuningPlate"] )
			dgsEditSetMaxLength(gEdit["PlateText"], 8)

			gButton["submitPlate"] = dgsCreateButton(16,142,147,38,"Übernehmen",false,gWindow["tuningPlate"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

			addEventHandler ( "onDgsMouseClickUp", gButton["submitPlate"],
				function ( btn, state )
					if btn ~= "left" then return end
					local text = dgsGetText(gEdit["PlateText"])
					triggerServerEvent ( "applyPlate", lp, text )
				end,
			false )
		end

		-- Aktuelles Kennzeichen vorbelegen statt eines leeren Feldes.
		local veh = getPedOccupiedVehicle ( lp )
		if veh and isElement ( gEdit["PlateText"] ) then
			dgsSetText ( gEdit["PlateText"], getVehiclePlateText ( veh ) or "" )
		end
end

function SubmitLeaveTuningBtn (btn)

	if btn == "left" then
		isintuninggarage = false
		tuningDrehenAus ()
		setElementCollisionsEnabled ( getPedOccupiedVehicle(lp), true )
		setElementFrozen ( getPedOccupiedVehicle(lp), false )
		dgsSetVisible ( gWindow["tuningMenue"], false )
		if gWindow["tuningPremium"] then
			dgsSetVisible ( gWindow["tuningPremium"], false )
		end
		if gWindow["tuningPlate"] then
			dgsSetVisible ( gWindow["tuningPlate"], false )
		end
		guiSetInputMode ( "allow_binds" )
		showCursor ( false )
		setElementClicked ( false )
		local veh = getPedOccupiedVehicle ( lp )
		for i = 0, 16 do
			removeVehicleUpgrade ( veh, getVehicleUpgradeOnSlot ( veh, i ) )
		end
		for i = 0, 16 do
			_G["t"..i] = _G["upgradeSlot"..i.."MountedID"]
		end
		local c1, c2, c3, c4 = getVehicleColor ( veh )
		triggerServerEvent ( "CancelTuning", lp, lp, veh, c1, c2, c3, c4, curpainting, t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16 )
	end
end
addEvent ( "SubmitLeaveTuningBtnAbbrechen", true)
addEventHandler ( "SubmitLeaveTuningBtnAbbrechen", getRootElement(), SubmitLeaveTuningBtn)

function SubmitPaintLeft ()

	curpainting = tonumber ( dgsGetText(gLabel["PaintingMiddle"]) )
	if curpainting == 0 then curpainting = 3 else
		curpainting = curpainting - 1
	end
	dgsSetText ( gLabel["PaintingMiddle"], curpainting )
	local veh = getPedOccupiedVehicle ( lp )
	setVehiclePaintjob ( veh, curpainting )
end
function SubmitPaintRight ()

	curpainting = tonumber ( dgsGetText(gLabel["PaintingMiddle"]) )
	if curpainting == 3 then curpainting = 0 else
		curpainting = curpainting + 1
	end
	dgsSetText ( gLabel["PaintingMiddle"], curpainting )
	local veh = getPedOccupiedVehicle ( lp )
	setVehiclePaintjob ( veh, curpainting )
end
function SubmitColorLeft ()

	curcolor = tonumber ( dgsGetText(gLabel["FarbeMiddle"]) )
	if curcolor == 0 then curcolor = 126 else
		curcolor = curcolor - 1
	end
	dgsSetText ( gLabel["FarbeMiddle"], curcolor )
	local veh = getPedOccupiedVehicle ( lp )
	local c1, c2, c3, c4 = getVehicleColor ( veh )
	setVehicleColor ( veh, curcolor, c2, c3, c4 )
end
function SubmitColorRight ()

	curcolor = tonumber ( dgsGetText(gLabel["FarbeMiddle"]) )
	if curcolor == 126 then curcolor = 0 else
		curcolor = curcolor + 1
	end
	dgsSetText ( gLabel["FarbeMiddle"], curcolor )
	local veh = getPedOccupiedVehicle ( lp )
	local c1, c2, c3, c4 = getVehicleColor ( veh )
	setVehicleColor ( veh, curcolor, c2, c3, c4 )
end

function SubmitpaintLeft2 ()

	c2 = tonumber ( dgsGetText(gLabel["PaintingMiddle2"]) )
	if c2 == 0 then c2 = 126 else
		c2 = c2 - 1
	end
	dgsSetText ( gLabel["PaintingMiddle2"], c2 )
	local veh = getPedOccupiedVehicle ( lp )
	local c1, TAR, c3, c4 = getVehicleColor ( veh )
	setVehicleColor ( veh, c1, c2, c3, c4 )
end
function SubmitpaintRight2 ()

	c2 = tonumber ( dgsGetText(gLabel["PaintingMiddle2"]) )
	if c2 == 126 then c2 = 0 else
		c2 = c2 + 1
	end
	dgsSetText ( gLabel["PaintingMiddle2"], c2 )
	local veh = getPedOccupiedVehicle ( lp )
	local c1, TAR, c3, c4 = getVehicleColor ( veh )
	setVehicleColor ( veh, c1, c2, c3, c4 )
end
function SubmitpaintLeft3 ()

	c3 = tonumber ( dgsGetText(gLabel["PaintingMiddle3"]) )
	if c3 == 0 then c3 = 126 else
		c3 = c3 - 1
	end
	dgsSetText ( gLabel["PaintingMiddle3"], c3 )
	local veh = getPedOccupiedVehicle ( lp )
	local c1, c2, TAR, c4 = getVehicleColor ( veh )
	setVehicleColor ( veh, c1, c2, c3, c4 )
end
function SubmitpaintRight3 ()

	c3 = tonumber ( dgsGetText(gLabel["PaintingMiddle3"]) )
	if c3 == 126 then c3 = 0 else
		c3 = c3 + 1
	end
	dgsSetText ( gLabel["PaintingMiddle3"], c3 )
	local veh = getPedOccupiedVehicle ( lp )
	local c1, c2, TAR, c4 = getVehicleColor ( veh )
	setVehicleColor ( veh, c1, c2, c3, c4 )
end
function SubmitpaintLeft4 ()

	c4 = tonumber ( dgsGetText(gLabel["PaintingMiddle4"]) )
	if c4 == 0 then c4 = 126 else
		c4 = c4 - 1
	end
	dgsSetText ( gLabel["PaintingMiddle4"], c4 )
	local veh = getPedOccupiedVehicle ( lp )
	local c1, c2, c3, TAR = getVehicleColor ( veh )
	setVehicleColor ( veh, c1, c2, c3, c4 )
end
function SubmitpaintRight4 ()

	c4 = tonumber ( dgsGetText(gLabel["PaintingMiddle4"]) )
	if c4 == 126 then c4 = 0 else
		c4 = c4 + 1
	end
	dgsSetText ( gLabel["PaintingMiddle4"], c4 )
	local veh = getPedOccupiedVehicle ( lp )
	local c1, c2, c3, TAR = getVehicleColor ( veh )
	setVehicleColor ( veh, c1, c2, c3, c4 )
end

function SubmitBuyTuningBtn (btn)

	if btn == "left" then
		local veh = getPedOccupiedVehicle ( lp )
		local rowindex, columnindex = dgsGridListGetSelectedItem ( gGrid["tuningSelect"] )
		if rowindex == -1 then return end
		local selectedText = dgsGridListGetItemText ( gGrid["tuningSelect"], rowindex, gColumn["tuningPart"] )
		local mounted = dgsGridListGetItemText ( gGrid["tuningSelect"], rowindex, gColumn["tuningIn"] )
		local part = tonumber ( selectedText )
		local tdata = _G["tdata"..rowindex]
		if tdata then
			local data1 = tonumber(gettok ( tdata, 1, string.byte('|') ) ) 			-- Upgrade
			local data2 = tonumber(gettok ( tdata, 2, string.byte('|') ) )			-- Preis
			local data3 = gettok ( tdata, 3, string.byte('|') )			            -- Fix ( "    [_]" v. "    [x]"
			local data4 = tonumber(gettok ( tdata, 4, string.byte('|') ) )
			if data2 <= mymoney then
				if mounted == "    [_]" then
					triggerServerEvent ( "buyTuningPart", lp, lp, veh, part, data2 )
					dgsGridListClear ( gGrid["tuningSelect"] )
					listfix (getElementModel(veh))
					dgsSetText ( gLabel["moneyAmount"], (mymoney-data2).." $" )
					dgsGridListSetItemText ( gGrid["tuningSelect"], rowindex, gColumn["tuningIn"], "    [x]", true, false )
					_G["upgradeSlot"..data4.."MountedID"] = data1
					-- Auswahl aufheben. DGS zaehlt Zeilen ab 1, dafuer ist -1
					-- vorgesehen - 0 war ausserhalb des Bereichs und warf jedes
					-- Mal beim Kauf einen Fehler.
					dgsGridListSetSelectedItem ( gGrid["tuningSelect"], -1, -1 )
				else
					infobox_start_func ( "\n\nDieses Teil hast\ndu bereits!", 7500, 125, 0, 0 )
				end
			else
				infobox_start_func ( "\n\n\nDu hast zu\nwenig Geld!", 7500, 125, 0, 0 )
			end
		else
			local price = dgsGridListGetItemText ( gGrid["tuningSelect"], rowindex, gColumn["tuningPrice"] )
			local price = tonumber ( gettok ( price, 1, string.byte('$') ) )
			if price then
				local text = dgsGridListGetItemText ( gGrid["tuningSelect"], rowindex, gColumn["tuningPart"] )
				for i = 1, specialUpgrades do
					if specialUpgrade[i] == text then
						local upgrade = specialUpgrade[i]
						if mymoney >= price then
							local fix = dgsGridListGetItemText ( gGrid["tuningSelect"], rowindex, gColumn["tuningIn"] )
							if fix == "    [_]" then
								dgsSetText ( gLabel["moneyAmount"], mymoney-price.." $" )
								triggerServerEvent ( "addSpecialTuning", lp, i )
								dgsGridListSetItemText ( gGrid["tuningSelect"], rowindex, gColumn["tuningIn"], "    [x]", false, false )
							else
								infobox_start_func ( "\n\n\nDu hast dieses\nTeil bereits!", 7500, 125, 0, 0 )
							end
						end
						break
					end
				end
			else
				infobox_start_func ( "\n\n\nDu hast zu\nwenig Geld!", 7500, 125, 0, 0 )
			end
		end
	end
end
-- Der Knopf hatte bisher keinen Handler und war reine Deko. Ausgebaut wird
-- ohne Rueckerstattung. Ein eigenes Server-Event braucht es nicht: beim
-- Schliessen schreibt CancelTuning den gesamten Tuningstand aus den
-- upgradeSlot*MountedID-Werten in die Datenbank, ein geleerter Slot faellt
-- dort automatisch weg.
function SubmitDelTuningBtn ( btn )

	if btn ~= "left" then return end
	local rowindex = dgsGridListGetSelectedItem ( gGrid["tuningSelect"] )
	if rowindex == -1 then return end

	local tdata = _G["tdata"..rowindex]
	if not tdata then
		infobox_start_func ( "\n\nSondertuning kann\nnicht ausgebaut\nwerden!", 7500, 125, 0, 0 )
		return
	end

	local mounted = dgsGridListGetItemText ( gGrid["tuningSelect"], rowindex, gColumn["tuningIn"] )
	if mounted ~= "    [x]" then
		infobox_start_func ( "\n\nDieses Teil ist\ngar nicht verbaut!", 7500, 125, 0, 0 )
		return
	end

	local upgrade = tonumber ( gettok ( tdata, 1, string.byte('|') ) )
	local slot    = tonumber ( gettok ( tdata, 4, string.byte('|') ) )
	removeVehicleUpgrade ( getPedOccupiedVehicle ( lp ), upgrade )
	_G["upgradeSlot"..slot.."MountedID"] = false
	dgsGridListSetItemText ( gGrid["tuningSelect"], rowindex, gColumn["tuningIn"], "    [_]", false, false )
end

addEvent ( "SubmitBuyTuningBtnAbbrechen", true)
addEventHandler ( "SubmitBuyTuningBtnAbbrechen", getRootElement(), SubmitBuyTuningBtn)

function createTuningMenue ()

	isintuninggarage = true
	guiSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	setElementClicked ( true )
	showPremiumWindow ()
	showPlateWindow ()
	setElementCollisionsEnabled ( getPedOccupiedVehicle(lp), false )
	setElementFrozen ( getPedOccupiedVehicle(lp), true )
	tuningDrehenAn ()
	if gWindow["tuningMenue"] then
		dgsSetVisible ( gWindow["tuningMenue"], true )
		dgsBringToFront ( gWindow["tuningMenue"] )
	else
		local ex, ey = tuningBlockEcke ()
		gWindow["tuningMenue"] = dgsCreateWindow(ex,ey,BREITE_HAUPT,HOEHE_HAUPT,"Tuningmenü",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255))
		dgsBringToFront ( gWindow["tuningMenue"] )
		dgsSetProperty(gWindow["tuningMenue"], "image", false)
		dgsWindowSetMovable(gWindow["tuningMenue"],false)
		dgsWindowSetSizable(gWindow["tuningMenue"],false)
		-- Kein X: zum Verlassen gibt es den Schliessen-Knopf, der auch das
		-- Fahrzeug wieder freigibt und den Kauf abschliesst.
		dgsWindowSetCloseButtonEnabled(gWindow["tuningMenue"],false)
		-- Liste ueber die volle Breite, Knoepfe in einer Reihe darunter. Die
		-- fruehere Seitenspalte liess unter "Ausbauen" fast die halbe
		-- Fensterhoehe leer, waehrend die Liste unnoetig schmal blieb.
		local RAND    = 0.035
		local KNOPF_B = 0.293   -- drei Knoepfe mit 0.025 Abstand ergeben 0.965
		local KNOPF_H = 0.11

		gLabel["Geld"] = dgsCreateLabel(RAND,0.065,0.15,0.06,"Geld:",true,gWindow["tuningMenue"])
		dgsLabelSetColor(gLabel["Geld"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["Geld"],"top")
		dgsLabelSetHorizontalAlign(gLabel["Geld"],"left",false)

		gLabel["moneyAmount"] = dgsCreateLabel(0.17,0.065,0.5,0.06,mymoney.." $",true,gWindow["tuningMenue"])
		dgsLabelSetColor(gLabel["moneyAmount"],000,125,000)
		dgsLabelSetVerticalAlign(gLabel["moneyAmount"],"top")
		dgsLabelSetHorizontalAlign(gLabel["moneyAmount"],"left",false)

		gGrid["tuningSelect"] = dgsCreateGridList(RAND,0.15,0.93,0.63,true,gWindow["tuningMenue"])
		dgsGridListSetSelectionMode(gGrid["tuningSelect"],0)
		gColumn["tuningPart"] = dgsGridListAddColumn(gGrid["tuningSelect"],"Tuningteil",0.50)
		gColumn["tuningPrice"] = dgsGridListAddColumn(gGrid["tuningSelect"],"Preis",0.18)
		gColumn["tuningIn"] = dgsGridListAddColumn(gGrid["tuningSelect"],"Eingebaut",0.26)
		gColumn["tuningID"] = dgsGridListAddColumn(gGrid["tuningSelect"],"",0)

		gButton["buyUpgrade"] = dgsCreateButton(RAND,0.82,KNOPF_B,KNOPF_H,"Kaufen",true,gWindow["tuningMenue"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["delUpgrade"] = dgsCreateButton(0.3535,0.82,KNOPF_B,KNOPF_H,"Ausbauen",true,gWindow["tuningMenue"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["closeUpgradeStore"] = dgsCreateButton(0.672,0.82,KNOPF_B,KNOPF_H,"Schließen",true,gWindow["tuningMenue"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler("onDgsMouseClickUp", gButton["closeUpgradeStore"], SubmitLeaveTuningBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["buyUpgrade"], SubmitBuyTuningBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["delUpgrade"], SubmitDelTuningBtn, false)
	end
	local veh = getPedOccupiedVehicle ( lp )
	dgsGridListClear ( gGrid["tuningSelect"] )
	dgsSetText ( gLabel["moneyAmount"], mymoney.." $" )
	local vehID = getElementModel ( getPedOccupiedVehicle ( lp ) )
	for i = 0, 16 do
		_G["upgradeSlot"..i.."MountedID"] = false
	end
	listfix (vehID)
end
addEvent ( "createTuningMenue", true )
addEventHandler ( "createTuningMenue", getRootElement(), createTuningMenue )

function listfix(vehID)

	local row = dgsGridListAddRow ( gGrid["tuningSelect"] )
	dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPart"], "Spezial", true, false )
	dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPrice"], "", true, false )
	dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningIn"], "", true, false )
	dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningID"], "", true, false )
	for i = 1, specialUpgrades do
		local row = dgsGridListAddRow ( gGrid["tuningSelect"] )
		local fix = getElementData ( getPedOccupiedVehicle ( lp ), "stuning"..i )
		if fix then fix = "    [x]" else fix = "    [_]" end
		dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPart"], specialUpgrade[i], false, false )
		dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPrice"], specialUpgradePrice[i].." $", false, false )
		dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningIn"], fix, false, false )
		dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningID"], "", false, false )
	end
	local row = dgsGridListAddRow ( gGrid["tuningSelect"] )
	dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPart"], "", false, false )
	dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPrice"], "", false, false )
	dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningIn"], "", false, false )
	dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningID"], "", false, false )

	for upgradeSlot=0,16 do
		upin = 0
		local compatList = compatibleUpgrades[vehID][upgradeSlot]
		if compatList then
			for i, upgradeID in ipairs(compatList) do
				upin = 1
			end
		end
		if upin == 1 then
			local row = dgsGridListAddRow ( gGrid["tuningSelect"] )
			dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPart"], slotNames[upgradeSlot], true, false )
			dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPrice"], "", true, false )
			dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningIn"], "", true, false )
			dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningID"], "", true, false )
			for i, upgradeID in ipairs(compatList) do
				local row = dgsGridListAddRow ( gGrid["tuningSelect"] )
				dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPart"], "  "..UpgradeNames[upgradeID], false, false )
				local data1 = tostring ( upgradeID )
				if upgradeSlot == 8 then
					if upgradeID == 1008 then price = 5*nitroprice end
					if upgradeID == 1009 then price = 2*nitroprice end
					if upgradeID == 1010 then price = 10*nitroprice end
				else
					price = tuningpartprice
				end
				local data2 = tostring ( price )
				dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPrice"], price.." $", false, false )
				if getVehicleUpgradeOnSlot ( getPedOccupiedVehicle ( lp ), upgradeSlot ) == upgradeID then
					fix = "    [x]"
					_G["upgradeSlot"..upgradeSlot.."MountedID"] = upgradeID
				else
					fix = "    [_]"
				end
				local data3 = fix
				local data4 = upgradeSlot
				local tdata = data1.."|"..data2.."|"..data3.."|"..data4.."|"
				_G["tdata"..row] = tdata
				dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningIn"], fix, false, false )
					-- Die ID-Spalte ist 0 breit und wird nirgends gelesen - die
				-- Upgrade-ID steht in tdata. Stand hier ein Wert drin, ragte er
				-- rechts sichtbar in die Liste hinein.
				dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningID"], "", false, false )
			end
			local row = dgsGridListAddRow ( gGrid["tuningSelect"] )
			dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPart"], "", true, false )
			dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningPrice"], "", true, false )
			dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningIn"], "", true, false )
			dgsGridListSetItemText( gGrid["tuningSelect"], row, gColumn["tuningID"], "", true, false )
		end
	end
end

function partChange ( button )

	if button ~= "left" then return end
	if isElement(gWindow["tuningMenue"]) and isintuninggarage then
		local rowindex, columnindex = dgsGridListGetSelectedItem ( gGrid["tuningSelect"] )
		if rowindex == -1 then return end
		local selectedText = dgsGridListGetItemText ( gGrid["tuningSelect"], rowindex, gColumn["tuningPart"] )
		if selectedText then
			local veh = getPedOccupiedVehicle ( lp )
			for i = 0, 16 do
				removeVehicleUpgrade ( veh, getVehicleUpgradeOnSlot ( veh, i ) )
			end
			for i = 0, 16 do
				if ( _G["upgradeSlot"..i.."MountedID"] == false ) then
				else
					addVehicleUpgrade ( veh, _G["upgradeSlot"..i.."MountedID"] )
				end
			end
			local tdata = _G["tdata"..rowindex]
			if tdata then
				local data1 = tonumber(gettok ( tdata, 1, string.byte('|') ) ) 			-- Upgrade
				if data1 then
					local data2 = tonumber(gettok ( tdata, 2, string.byte('|') ) )			-- Preis
					local data3 = gettok ( tdata, 3, string.byte('|') )						-- Fix ( "    [_]" v. "    [x]"
					local data4 = tonumber(gettok ( tdata, 4, string.byte('|') ))			-- Slot
					local veh = getPedOccupiedVehicle ( lp )
					if getVehicleUpgradeOnSlot ( veh, data4 ) ~= data1 then
						addVehicleUpgrade ( veh, data1 )
					end
				end
			end
		end
	end
end
addEventHandler ( "onDgsMouseClickUp", getRootElement(), partChange )
