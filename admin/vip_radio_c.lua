--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Decompile Security		--
sec = {{{{{{},{},{},{}}}}}} --
------------------------------
-- Variables				--
------------------------------
local subTrackOnSoundDown = 0.1	-- The volume that goes down, when the player clicks "Volume -"
local subTrackOnSoundUp = 0.1	-- The volume that goes up, when the player clicks "Volume +"
local antiSpam = 0

------------------------------
-- The GUI					--
------------------------------
local rx, ry = guiGetScreenSize ( )
button = { }
local carradios = {}

-- Feste Radiosender (direkte Audio-Streams, funktionieren ohne YouTube-Resolver
-- immer sofort) - per Klick direkt aktivierbar, zusaetzlich zum freien URL-Feld
-- weiter unten fuer eigene Links/YouTube.
local radioStations = {
	{ name = "1LIVE",   url = "https://wdr-1live-live.icecastssl.wdr.de/wdr/1live/live/mp3/128/stream.mp3" },
	{ name = "WDR2",    url = "https://wdr-wdr2-rheinland.icecastssl.wdr.de/wdr/wdr2/rheinland/mp3/128/stream.mp3" },
	{ name = "SWR3",    url = "https://liveradio.swr.de/sw282p3/swr3/play.mp3" },
	{ name = "Antenne", url = "https://s1-webradio.antenne.de/antenne" },
	{ name = "BigFM",   url = "https://streams.bigfm.de/bigfm-deutschland-128-mp3" },
}

window = dgsCreateWindow( ( rx - 295 ), ( ry / 2 - 340 / 2 ), 293, 340, ""..Tables.servername.."-Reallife Lautsprecher",false)
dgsWindowSetCloseButtonEnabled(window, false)
dgsWindowSetSizable(window, false)
dgsWindowSetMovable(window ,false)
dgsSetVisible ( window, false )
CurrentSpeaker = dgsCreateLabel(8, 33, 254, 17, "Haben sie derzeit einen Lautsprecher: Nein", false, window)
volume = dgsCreateLabel(10, 50, 252, 17, "Aktuelles Volume: 100%", false, window)
pos = dgsCreateLabel(10, 66, 252, 15, "X: 0 | Y: 0 | Z: 0", false, window)

stationLabel = dgsCreateLabel(11, 82, 251, 15, "Radiosender:", false, window)
dgsLabelSetColor(stationLabel, 63, 160, 224)
dgsSetFont(stationLabel, "default-bold")
button["stations"] = {}
for i, station in ipairs ( radioStations ) do
	button["stations"][i] = dgsCreateButton(9 + (i-1)*55, 97, 52, 20, station.name, false, window,_,_,_,_,_,_,tocolor(100,181,246,255),tocolor(150,205,250,255),tocolor(66,140,205,255),true)
end

urlLabel = dgsCreateLabel(11, 125, 251, 15, "Oder URL (YouTube-Link/direkter Audio-Link):", false, window)
dgsLabelSetColor(urlLabel, 63, 160, 224)
dgsSetFont(urlLabel, "default-bold")
url = dgsCreateEdit(11, 140, 272, 23, "", false, window)
button["place"] = dgsCreateButton(9, 173, 274, 20, "Lautsprecher setzen", false, window,_,_,_,_,_,_,tocolor(100,181,246,255),tocolor(150,205,250,255),tocolor(66,140,205,255),true)
button["remove"] = dgsCreateButton(9, 203, 274, 20, "Lautsprecher löschen", false, window,_,_,_,_,_,_,nil,nil,nil,true)
button["v-"] = dgsCreateButton(9, 233, 128, 20, "Volumen -", false, window,_,_,_,_,_,_,nil,nil,nil,true)
button["v+"] = dgsCreateButton(155, 233, 128, 20, "Volumen +", false, window,_,_,_,_,_,_,nil,nil,nil,true)
button["close"] = dgsCreateButton(9, 259, 280, 10, "Verlassen", false, window,_,_,_,_,_,_,nil,nil,nil,true)

--------------------------
-- My sweet codes		--
--------------------------
local isSound = false
addEvent ( "onPlayerViewSpeakerManagment", true )
addEventHandler ( "onPlayerViewSpeakerManagment", root, function ( current )
	local toState = not dgsGetVisible ( window )
	dgsSetVisible ( window, toState )
	setElementClicked ( toState )
	if ( toState == true ) then
		dgsBringToFront ( window )
		showCursor ( true )
		dgsSetInputMode ( "no_binds_when_editing" )
		local x, y, z = getElementPosition ( localPlayer )
		dgsSetText ( pos, "X: "..math.floor ( x ).." | Y: "..math.floor ( y ).." | Z: "..math.floor ( z ) )
		if ( current ) then dgsSetText ( CurrentSpeaker, "Haben Sie derzeit einen Lautsprecher: Ja" ) isSound = true
		else dgsSetText ( CurrentSpeaker, "Haben Sie derzeitig einen Lautsprecher: Nein" ) end
	else
		showCursor ( false )
		guiSetInputMode ( "allow_binds" )
	end
end )

local function findClickedStation ( )
	for i, stationBtn in ipairs ( button["stations"] ) do
		if source == stationBtn then
			return radioStations[i]
		end
	end
	return nil
end

addEventHandler ( "onDgsMouseClickUp", root, function (btn)
	if ( source == button["close"] ) and btn == "left" then
		dgsSetVisible ( window, false )
		showCursor ( false )
		guiSetInputMode ( "allow_binds" )
		setElementClicked ( false )
	elseif ( btn == "left" and findClickedStation ( ) ) then
		if antiSpam + 1000 <= getTickCount() then
			local station = findClickedStation ( )
			antiSpam = getTickCount()
			triggerServerEvent ( "onPlayerPlaceSpeakerBox", localPlayer, station.url, isPedInVehicle ( localPlayer ) )
		else
			outputChatBox ( "Nicht spamen!.", 255, 0, 0 )
		end
	elseif ( source == button["place"] ) then
		if antiSpam + 1000 <= getTickCount() then
			if ( isURL ( ) ) then
				-- YouTube-Links werden serverseitig ueber den lokalen yt_resolver.py-
				-- Dienst in einen direkten Audio-Stream aufgeloest (siehe vip_radio_s.lua),
				-- da playSound3D selbst keine YouTube-Seiten abspielen kann.
				local theurl = dgsGetText ( url )
				antiSpam = getTickCount()
				triggerServerEvent ( "onPlayerPlaceSpeakerBox", localPlayer, theurl, isPedInVehicle ( localPlayer ) )
				-- isSound/CurrentSpeaker/volume werden erst gesetzt, wenn der
				-- Sound tatsaechlich erstellt wurde (siehe onPlayerStartSpeakerBoxSound
				-- unten) - vorher optimistisch gesetzt, was bei fehlgeschlagener
				-- Erstellung (z.B. kaputter Link)
				-- zu einem Absturz bei Volumen +/- fuehrte, da speakerSound[localPlayer]
				-- dann nie existiert.
			else
				outputChatBox ( "Du braucht einen URL Link.", 255, 0, 0 )
			end
		else
			outputChatBox ( "Nicht spamen!.", 255, 0, 0 )
		end
	elseif ( source == button["remove"] ) then
		if antiSpam + 1000 <= getTickCount() then
			triggerServerEvent ( "onPlayerDestroySpeakerBox", localPlayer )
			dgsSetText ( CurrentSpeaker, "Haben sie derzeitig einen Lautsprecher: Nein" )
			isSound = false
			antiSpam = getTickCount()
			dgsSetText ( volume, "Aktuelles Volumen: 100%" )
		else
			outputChatBox ( "Nicht spamen!.", 255, 0, 0 )
		end
	elseif ( source == button["v-"] ) then
		if antiSpam + 200 <= getTickCount() then
			if ( isSound and isElement ( speakerSound [ localPlayer ] ) ) then
				local toVol = math.round ( getSoundVolume ( speakerSound [ localPlayer ] ) - subTrackOnSoundDown, 2 )
				if ( toVol > 0.0 ) then
					antiSpam = getTickCount()
					outputChatBox ( "Volumen gesetzt auf "..math.floor ( toVol * 100 ).."%!", 0, 255, 0 )
					triggerServerEvent ( "onPlayerChangeSpeakerBoxVolume", localPlayer, toVol )
					dgsSetText ( volume, "Aktuelles Volume: "..math.floor ( toVol * 100 ).."%" )
				else
					outputChatBox ( "Das Volumen kann nicht leiser gemacht werden.", 255, 0, 0 )
				end
			end
		else
			outputChatBox ( "Nicht spamen!.", 255, 0, 0 )
		end
	elseif ( source == button["v+"] ) then
		if antiSpam + 200 <= getTickCount() then
			if ( isSound and isElement ( speakerSound [ localPlayer ] ) ) then
				local toVol = math.round ( getSoundVolume ( speakerSound [ localPlayer ] ) + subTrackOnSoundUp, 2 )
				if ( toVol <= 1.0 ) then
					antiSpam = getTickCount()
					outputChatBox ( "Volumen gesetzt auf "..math.floor ( toVol * 100 ).."%!", 0, 255, 0 )
					triggerServerEvent ( "onPlayerChangeSpeakerBoxVolume", localPlayer, toVol )
					dgsSetText ( volume, "Aktuelles Volume: "..math.floor ( toVol * 100 ).."%" )
				else
					outputChatBox ( "Das Volumen kann nicht höher gemacht werden.", 255, 0, 0 )
				end
			end
		else
			outputChatBox ( "Nicht spamen!.", 255, 0, 0 )
		end
	end
end)

speakerSound = { }
addEvent ( "onPlayerStartSpeakerBoxSound", true )
addEventHandler ( "onPlayerStartSpeakerBoxSound", root, function ( url, isCar )
	local who = source
	if ( isElement ( speakerSound [ who ] ) ) then destroyElement ( speakerSound [ who ] ) end
	local x, y, z = getElementPosition ( who )
	speakerSound [ who ] = playSound3D ( url, x, y, z, true )

	if not isElement ( speakerSound [ who ] ) then
		-- Stream konnte nicht geladen werden (kaputter/nicht unterstuetzter Link).
		if who == localPlayer then
			isSound = false
			dgsSetText ( CurrentSpeaker, "Haben sie derzeitig einen Lautsprecher: Nein" )
			outputChatBox ( "Der Link konnte nicht abgespielt werden.", 255, 0, 0 )
		end
		return
	end

	if who == localPlayer then
		isSound = true
		dgsSetText ( CurrentSpeaker, "Haben sie derzeitig einen Lautsprecher: Ja" )
		dgsSetText ( volume, "Aktuelles Volume: 100%" )
	end

	setSoundVolume ( speakerSound [ who ], 1 )
	setSoundMinDistance ( speakerSound [ who ], 13 )
	setSoundMaxDistance ( speakerSound [ who ], 48 )
	local int = getElementInterior ( who )
	setElementInterior ( speakerSound [ who ], int ) 
	setElementDimension ( speakerSound [ who ], getElementDimension ( who ) )
	if ( isCar ) then
		local car = getPedOccupiedVehicle ( who )
		attachElements ( speakerSound [ who ], car, 0, 0, 1 )
		addEventHandler ( "onClientVehicleRespawn", car, deleteTheVIPRadio )
		addEventHandler ( "onClientVehicleExplode", car, deleteTheVIPRadio )
		carradios[car] = who
	else
		attachElementToBone ( speakerSound [ who ], who, 12, 0, 0, 0.42, 180, 0, 180 )
	end
end )

function deleteTheVIPRadio ( ) 
	if isElement ( speakerSound [ source ] ) then 
		destroyElement ( speakerSound [ source ] ) 
	elseif isElement (source) and getElementType ( source ) == "vehicle" then
		destroyElement ( speakerSound [ carradios[source] ] ) 
		speakerSound [ carradios[source] ] = nil
		carradios[source] = nil
		removeEventHandler ( "onClientVehicleRespawn", source, deleteTheVIPRadio )
		removeEventHandler ( "onClientVehicleExplode", source, deleteTheVIPRadio )
	end
end 
addEvent ( "onPlayerDestroySpeakerBox", true )
addEventHandler ( "onPlayerDestroySpeakerBox", root, deleteTheVIPRadio )

function attackerSpeakerOnPlayer ( thebox ) 
	attachElementToBone ( thebox, source, 12, 0, 0, 0.42, 180, 0, 180 )
end
addEvent ( "attachSpeakerBoxOnPlayer", true )
addEventHandler ( "attachSpeakerBoxOnPlayer", root, attackerSpeakerOnPlayer )

--------------------------
-- Volume				--
--------------------------
addEvent ( "onPlayerChangeSpeakerBoxVolumeC", true )
addEventHandler ( "onPlayerChangeSpeakerBoxVolumeC", root, function ( vol ) 
	if ( isElement ( speakerSound [ source ] ) ) then
		setSoundVolume ( speakerSound [ source ], tonumber ( vol ) )
	end
end )

function isURL ( )
	if ( dgsGetText ( url ) ~= "" ) then
		return true
	else
		return false
	end
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end
