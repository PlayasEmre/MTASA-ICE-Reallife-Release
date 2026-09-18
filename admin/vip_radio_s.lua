--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local isSpeaker = false

local function print ( player, message, r, g, b )
	outputChatBox ( message, player, r, g, b )
end

speakerBox = { }

-- MTA's playSound3D kann keine YouTube-Seiten abspielen, nur direkte
-- Audio-Dateien/Streams. Fuer YouTube-Links wird deshalb ein lokaler
-- Resolver-Dienst (admin/yt_resolver.py, nutzt yt-dlp) angefragt, der als
-- eigener Prozess neben dem MTA-Server laeuft und die direkte Audio-Stream-
-- URL zurueckgibt. Siehe yt_resolver.py fuer Setup/Start.
local YT_RESOLVER_URL = "http://127.0.0.1:8927"

local function extractYoutubeId ( url )
	if not url then return nil end
	return url:match ( "[?&]v=([%w_-]+)" )
		or url:match ( "youtu%.be/([%w_-]+)" )
		or url:match ( "youtube%.com/shorts/([%w_-]+)" )
		or ( url:match ( "^[%w_-]+$" ) and #url == 11 and url or nil )
end

local function resolveYoutubeAudio ( videoId, callback )
	fetchRemote ( YT_RESOLVER_URL.."/resolve?id="..videoId, { connectionAttempts = 1, connectTimeout = 8000 }, function ( data, info )
		local statusCode = info and info.statusCode
		if statusCode == 200 and data then
			local ok, parsed = pcall ( fromJSON, data )
			if ok and parsed and parsed.url then
				callback ( parsed.url )
				return
			end
			outputDebugString ( "[VIP-Radio] Resolver-Antwort ohne 'url' (ok="..tostring(ok)..", Antwort: "..tostring(data)..")" )
		else
			outputDebugString ( "[VIP-Radio] Lokaler YouTube-Resolver nicht erreichbar (statusCode="..tostring(statusCode).."). Laeuft yt_resolver.py?" )
		end
		callback ( nil )
	end )
end

local function placeSpeakerBoxFor ( plr, url, isCar )
	if not isElement ( plr ) then return end

	if ( isElement ( speakerBox [ plr ] ) ) then
		print ( plr, "Ghettoblaster zerstört", 255, 0, 0 )
		destroyElement ( speakerBox [ plr ] )
		removeEventHandler ( "onPlayerQuit", plr, destroySpeakersOnPlayerQuit )
	end
	local x, y, z = getElementPosition ( plr )
	local rx = getElementRotation ( plr )
	speakerBox [ plr ] = createObject ( 2226, x-0.5, y+0.5, z - 1, 0, 0, rx )
	print ( plr, "Ghettoblaster platziert", 0, 255, 0 )
	addEventHandler ( "onPlayerQuit", plr, destroySpeakersOnPlayerQuit )
	triggerClientEvent ( root, "onPlayerStartSpeakerBoxSound", plr, url, isCar )
	if ( isCar ) then
		local car = getPedOccupiedVehicle ( plr )
		attachElements ( speakerBox [ plr ], car, 0, -0.7, 0.3, 0, 0, 0 )
		setElementCollisionsEnabled ( speakerBox [ plr ], false )
	else
		triggerClientEvent ( root, "attachSpeakerBoxOnPlayer", plr, speakerBox [ plr ] )
	end
end

addEvent ( "onPlayerPlaceSpeakerBox", true )
addEventHandler ( "onPlayerPlaceSpeakerBox", root, function ( url, isCar )
	local plr = client
	local videoId = extractYoutubeId ( url )

	if videoId then
		print ( plr, "Suche YouTube-Audio...", 200, 200, 0 )
		resolveYoutubeAudio ( videoId, function ( streamUrl )
			if not streamUrl then
				print ( plr, "YouTube-Video konnte nicht geladen werden (Dienst evtl. nicht erreichbar).", 255, 0, 0 )
				return
			end
			placeSpeakerBoxFor ( plr, streamUrl, isCar )
		end )
		return
	end

	if ( url ) then
		placeSpeakerBoxFor ( plr, url, isCar )
	end
end )

addEvent ( "onPlayerDestroySpeakerBox", true )
addEventHandler ( "onPlayerDestroySpeakerBox", root, function ( )
	if ( isElement ( speakerBox [ client ] ) ) then
		destroyElement ( speakerBox [ client ] )
		triggerClientEvent ( root, "onPlayerDestroySpeakerBox", client )
		removeEventHandler ( "onPlayerQuit", client, destroySpeakersOnPlayerQuit )
		print ( client, "Ghettoblaster wurde entfernt.", 255, 0, 0 )
	else
		print ( client, "Du hast kein Ghettoblaster platziert.", 255, 255, 0 )
	end
end )

addEvent ( "onPlayerChangeSpeakerBoxVolume", true ) 
addEventHandler ( "onPlayerChangeSpeakerBoxVolume", root, function ( to )
	triggerClientEvent ( root, "onPlayerChangeSpeakerBoxVolumeC", client, to )
end )

function destroySpeakersOnPlayerQuit ( )
	if ( isElement ( speakerBox [ source ] ) ) then
		destroyElement ( speakerBox [ source ] )
		triggerClientEvent ( root, "onPlayerDestroySpeakerBox", source )
	end
end