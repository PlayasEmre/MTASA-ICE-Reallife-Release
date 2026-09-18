--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addDist = {}
 addDist[3461] = 1
 addDist[1946] = 0.22
 addDist[1598] = 0.3
 addDist[1481] = 0.5
 addDist[1255] = 0.3
 addDist[13593] = 0.35
 addDist[2984] = 1.1
 addDist[2103] = 0

radioURL = ""

function placeRadio ()

	showCursor ( true )
	setElementClicked ( true )
	
	gWindow["radioChannelSelection"] = guiCreateWindow(screenwidth/2-265/2,screenheight/2-178/2,265,178,"Radiosender",false)
	guiSetAlpha(gWindow["radioChannelSelection"],1)
	
	gGrid["radioChannelSelection"] = guiCreateGridList(9,25,122,144,false,gWindow["radioChannelSelection"])
	guiGridListSetSelectionMode(gGrid["radioChannelSelection"],2)
	gColumn["radioSender"] = guiGridListAddColumn(gGrid["radioChannelSelection"],"Sender",0.8)
	guiSetAlpha(gGrid["radioChannelSelection"],1)
	
	gLabel[1] = guiCreateLabel(142,23,119,61,"Hier kannst du einen\nRadiosender aus-\nwählen, den das\nRadio spielen soll.",false,gWindow["radioChannelSelection"])
	guiSetAlpha(gLabel[1],1)
	guiLabelSetColor(gLabel[1],200,200,0)
	guiLabelSetVerticalAlign(gLabel[1],"top")
	guiLabelSetHorizontalAlign(gLabel[1],"left",false)
	guiSetFont(gLabel[1],"default-bold-small")
	
	gButton["selectRadio"] = guiCreateButton(159,85,67,36,"Auswählen",false,gWindow["radioChannelSelection"])
	guiSetAlpha(gButton["selectRadio"],1)
	guiSetFont(gButton["selectRadio"],"default-bold-small")
	gButton["cancelRadio"] = guiCreateButton(159,131,67,36,"Keine\nMusik",false,gWindow["radioChannelSelection"])
	guiSetAlpha(gButton["cancelRadio"],1)
	guiSetFont(gButton["cancelRadio"],"default-bold-small")
	
	guiGridListClear ( gGrid["radioChannelSelection"] )
	local channels = getCustomRadioChannels ()
	local row
	for key, index in pairs ( channels ) do
		row = guiGridListAddRow ( gGrid["radioChannelSelection"] )
		guiGridListSetItemText ( gGrid["radioChannelSelection"], row, gColumn["radioSender"], key, false, false )
	end
	
	addEventHandler ( "onClientGUIClick", gButton["selectRadio"],
		function ()
			local name = guiGridListGetItemText ( gGrid["radioChannelSelection"], guiGridListGetSelectedItem ( gGrid["radioChannelSelection"] ), 1 )
			if checkIfCustomRadioChannelExists ( name ) then
				radioURL = getCustomRadioChannelURL ( name )
				destroyElement ( gWindow["radioChannelSelection"] )
				startObjectDrop ()
			end
		end
	)
	addEventHandler ( "onClientGUIClick", gButton["cancelRadio"],
		function ()
			radioURL = ""
			destroyElement ( gWindow["radioChannelSelection"] )
			startObjectDrop ()
		end
	)
end

function startObjectDrop ()

	-- vioClientGetElementData liefert false, wenn "object" nie gesetzt wurde.
	-- Ohne diese Pruefung ging ein ungueltiges Modell an createObject, das
	-- dann false zurueckgab - und die Render-Handler unten liefen trotzdem
	-- los und wiederholten den Fehler bei JEDEM Bild.
	local model = tonumber ( vioClientGetElementData ( "object" ) ) or 0
	if model <= 0 then
		outputChatBox ( "Du hast kein Objekt zum Platzieren dabei!", 125, 0, 0 )
		return
	end

	showCursor ( true )

	-- Camera --
	local px, py, pz = getPedBonePosition ( lp, 6 )
	local sicht
	sicht, placeCamX, placeCamY, placeCamZ = processLineOfSight ( px, py, pz, px, py, pz + 5, true, true, false )
	if not sicht then
		placeCamX, placeCamY, placeCamZ = px, py, pz + 5
	else
		placeCamZ = placeCamZ - 0.1
	end
	setCameraMatrix ( placeCamX, placeCamY, placeCamZ, px, py, pz )
	-- Camera --

	if model == 2060 then
		dropObjekt = createSandbagStack ()
	else
		dropObjekt = createObject ( model, 0, 0, 0 )
	end

	-- Modell existiert nicht (oder ist nicht platzierbar): sauber abbrechen,
	-- statt mit einem false weiterzurechnen.
	if not isElement ( dropObjekt ) then
		dropObjekt = nil
		setCameraTarget ( lp )
		showCursor ( false )
		outputChatBox ( "Dieses Objekt kann nicht platziert werden (Modell "..model..").", 125, 0, 0 )
		return
	end

	if model == 841 or model == 842 then
		local fire = createObject ( 3461, 0, 0, -1.8 )
		if isElement ( fire ) then
			attachElementsInCorrectWay ( fire, dropObjekt )
			setElementParent ( fire, dropObjekt )
		end
	end

	massDistance = getElementDistanceFromCentreOfMassToBaseOfModel ( dropObjekt ) or 0
	setElementCollisionsEnabled ( dropObjekt, false )
	addEventHandler ( "onClientRender", getRootElement(), refreshObjectPosition )
	addEventHandler ( "onClientClick", getRootElement(), finishObjectPos )
end

function finishObjectPos ( btn, state )
	if state == "down" then
		if isElement ( dropObjekt ) then
			removeEventHandler ( "onClientRender", getRootElement(), refreshObjectPosition )
			removeEventHandler ( "onClientClick", getRootElement(), finishObjectPos )
			
			addEventHandler ( "onClientRender", getRootElement(), refreshObjectRotation )
			setTimer ( finalObjectPlacement, 1000, 1 )
		end
	end
end

function finalObjectPlacement ()

	addEventHandler ( "onClientClick", getRootElement (), finishObject )
end

function finishObject ( btn, state )
	if state == "down" then
		if isElement ( dropObjekt ) then
			setCameraTarget ( lp )
			
			local x, y, z = getElementPosition ( dropObjekt )
			local rx, ry, rz = getElementRotation ( dropObjekt )
			
			local model = getElementModel ( dropObjekt )
			
			destroyElement ( dropObjekt )
			
			if model == 2060 or model == 1422 then
				placingBarricade = false
				if model == 1422 then
					triggerServerEvent ( "placeObject", lp, "barricade", x, y, z, rz )
				elseif model == 2060 then
					triggerServerEvent ( "placeObject", lp, "sandbag", x, y, z, rz )
				end
			else
				triggerServerEvent ( "finishObjectPlace", lp, x, y, z, rx, ry, rz, radioURL )
			end

			showCursor ( false )

			removeEventHandler ( "onClientRender", getRootElement(), refreshObjectRotation )
			removeEventHandler ( "onClientClick", getRootElement (), finishObject )
		end
	end
end

function refreshObjectPosition ()
	-- Laeuft bei jedem Bild. Ist das Objekt weg, den Handler abhaengen -
	-- sonst wiederholt sich jeder Fehler hier hunderte Male pro Sekunde.
	if not isElement ( dropObjekt ) then
		removeEventHandler ( "onClientRender", getRootElement(), refreshObjectPosition )
		return
	end

	-- Ohne sichtbaren Cursor liefert getCursorPosition nichts - dann gibt es
	-- auch kein Ziel zu berechnen.
	local sx, sy, x, y, z = getCursorPosition ()
	if not x or not y or not z then return end

	local px, py, pz = placeCamX, placeCamY, placeCamZ
	if not px then return end

	local treffer, nx, ny, nz
	treffer, nx, ny, nz = processLineOfSight ( px, py, pz, x, y, z, true, true, false )
	if treffer then
		treffer, nx, ny, nz = processLineOfSight ( nx, ny, nz + 3, x, y, z, true, true, false )
	end
	if treffer then
		treffer, nx, ny, nz = processLineOfSight ( nx, ny, nz + 3, x, y, z, true, true, false )
	end
	if not treffer or not nz then
		nx, ny, nz = x, y, z
	end

	local zusatz = addDist[getElementModel ( dropObjekt )]
	if zusatz then
		nz = nz + zusatz
	end

	setElementPosition ( dropObjekt, nx, ny, nz + ( massDistance or 0 ) )
end

function refreshObjectRotation ()

	if not isElement ( dropObjekt ) then
		removeEventHandler ( "onClientRender", getRootElement(), refreshObjectRotation )
		return
	end

	local sx, sy, cx, cy = getCursorPosition ()
	if not cx or not cy then return end

	local x, y, z = getElementPosition ( dropObjekt )
	local rx, ry, rz = getElementRotation ( dropObjekt )
	setElementRotation ( dropObjekt, rx, ry, findRotation ( cx, cy, x, y ) )
end