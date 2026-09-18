--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

objects = {}
objectCount = 0
clientSoundFiles = {}
	clientSoundFiles["x"] = {}
	clientSoundFiles["y"] = {}
	clientSoundFiles["z"] = {}
	clientSoundFiles["url"] = {}
	

function finishObjectPlace_func ( x, y, z, rx, ry, rz, radioURL )

	local player = client
	local model = MtxGetElementData ( player, "object" )

	if placeAblesToBeSaved[model] then
		createObjectToSave ( model, x, y, z, rx, player, 3 )
	else
		if model > 0 then
			objectCount = objectCount + 1
			local object = createObject ( model, x, y, z, rx, ry, rz )
			objects[objectCount] = object
			MtxSetElementData ( objects[objectCount], "placeableObject", true )
			MtxSetElementData ( player, "object", 0 )
			if model == 841 or model == 842 then -- Fackeln
				local fire = createObject ( 3461, x, y, z - 1.8 )
				setElementParent ( fire, objects[objectCount] )
			end
		end
	end
end
addEvent ( "finishObjectPlace", true )
addEventHandler ( "finishObjectPlace", getRootElement(), finishObjectPlace_func )

function purchaseItem_func ( model )

	local player = client
	local price = placeablePrices[model]
	if MtxGetElementData ( player, "money" ) >= price then
		if MtxGetElementData ( player, "object" ) == 0 then
			takePlayerSaveMoney ( player, price )
			MtxSetElementData ( player, "object", model )
			infobox ( player, "\n\nDu hast das Objekt\nerworben!\nEs ist nun in\ndeinem Inventar.", 5000, 0, 2000, 0 )
		else
			infobox ( player, "\n\n\nDu hast bereits\nein Objekt!", 5000, 200, 0, 0 )
		end
	else
		infobox ( player, "\n\n\nDu hast nicht\ngenug Geld!", 5000, 200, 0, 0 )
	end
end
addEvent ( "purchaseItem", true )
addEventHandler ( "purchaseItem", getRootElement(), purchaseItem_func )

placedObjects = {}

function createObjectToSave ( model, x, y, z, rx, placer, daysToKeep )

	local time = getMinTime () + 60 * 24 * daysToKeep
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "UID", "object", "UID", playerUID[getPlayerName(placer)] )
	if not result or not result[1] or #result < maxPlaceAbleObjectsPerPlayer then
		if MtxGetElementData ( placer, "playingtime" ) >= 600 then
			-- Die Spalte heisst UID (Besitzer) bzw. placer (Name); ein placerUID
			-- gibt es in der Tabelle nicht. UID ist ausserdem NOT NULL ohne
			-- Standardwert, ohne sie schlaegt das Einfuegen komplett fehl.
			dbExec ( handler, "INSERT INTO ?? ( ??, ??, ??, ??, ??, ??, ??, ?? ) VALUES (?,?,?,?,?,?,?,?)", "object", "UID", "model", "x", "y", "z", "rx", "placer", "deleteTime", playerUID[getPlayerName ( placer )], model, x, y, z, rx, getPlayerName ( placer ), time )
			setTimer (
				function ( model, x, y, z, rx, placer )
					local id = tonumber ( (dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "id", "object", "taken", "0" ))[1]["id"] )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "object", "taken", "1", "id", id )
					local object = createObject ( model, x, y, z, 0, 0, rx )
					MtxSetElementData ( object, "placer", getPlayerName ( placer ) )
					MtxSetElementData ( object, "id", id )
					MtxSetElementData ( object, "placeableObjectMySQL", true )
					placedObjects[id] = object
				end,
			500, 1, model, x, y, z, rx, placer )
			MtxSetElementData ( placer, "object", 0 )
			infobox ( placer, "Objekt platziert.", 5000, 0, 200, 0 )
		else
			infobox ( placer, "Du hast keine 10\nSpielstunden!", 5000, 125, 0, 0 )
		end
	else
		infobox ( placer, "Du kannst maximal\n"..maxPlaceAbleObjectsPerPlayer.." Objekte zur\nselben Zeit platzieren.\nTippe /delmyobjects\nzum loeschen.", 5000, 125, 0, 0 )
	end
end

function delmyobjects ( player )
	local pname = getPlayerName ( player )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "id", "object", "UID", playerUID[pname] )
	if result and result[1] then
		for i = 1, #result do
			local id = tonumber ( result[i]["id"] )
			if id and isElement ( placedObjects[id] ) then
				destroyElement ( placedObjects[id] )
				placedObjects[id] = nil
			end
		end
		dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "object", "UID", playerUID[pname] )
	end
	outputChatBox ( "Alle von dir plazierten Objekte wurden geloescht.", player, 200, 200, 0 )
end
addCommandHandler ( "delmyobjects", function ( player ) runAsync ( delmyobjects, player ) end )



function createNextPlaceableObject ( data )

	local id = data["id"]
	
	local model = data["model"]
	
	local x = data["x"]
	local y = data["y"]
	local z = data["z"]
	local rx = data["rx"]
	
	local placer = data["placer"]
	
	local object = createObject ( model, x, y, z, 0, 0, rx )
	
	MtxSetElementData ( object, "placer", placer )
	MtxSetElementData ( object, "id", id )
	MtxSetElementData ( object, "placeableObjectMySQL", true )
	
	placedObjects[id] = object
end