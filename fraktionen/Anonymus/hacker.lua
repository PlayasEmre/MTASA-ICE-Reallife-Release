--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- ATM-Hacks: statt nur abzuwarten muss jetzt ein Kurzschluss-Minispiel
-- (hacker_client.lua) gelost werden. Die Polizei wird SOFORT beim Start des
-- Hacks alarmiert (nicht erst am Ende), das Minispiel selbst entscheidet
-- Erfolg/Misserfolg. Alle vier ATMs teilen sich jetzt eine Funktion statt
-- vier fast identische Kopien zu pflegen.
local ATM_HACK_TIME_LIMIT = 20 -- Sekunden fuer das Minispiel
local ATM_HACK_COOLDOWN_MS = 10*60*1000

local atms = {
	bhf       = { label = "Bahnhof",   x = -1981.2060546875, y = 145.07421875,     z = 27.6875,          cooldownUntil = 0 },
	noob      = { label = "Noobspawn", x = -2453.7058105469, y = 754.22961425781,  z = 35.171875,        cooldownUntil = 0 },
	stadt     = { label = "Stadthalle",x = -2037.6707763672, y = 451.59509277344,  z = 35.172294616699,  cooldownUntil = 0 },
	wangcars  = { label = "wangcars",  x = -1967.7807617188, y = 296.15774536133,  z = 35.171875,        cooldownUntil = 0 },
}

-- [player] = { kind = "atm"/"door", atmKey/schleuse = ..., failsafeTimer = <timer> }
-- - waehrend ein Minispiel laeuft, damit die Antwort vom Client zugeordnet
-- werden kann. "kind" entscheidet in endHack(), was bei Erfolg passiert.
local activeHacks = {}

local function endHack ( player, success )
	local hack = activeHacks[player]
	if not hack then return end
	activeHacks[player] = nil

	if isTimer ( hack.failsafeTimer ) then
		killTimer ( hack.failsafeTimer )
	end

	if not isElement ( player ) then return end

	setPedAnimation ( player )
	setElementFrozen ( player, false )
	MtxSetElementData ( player, "hackingAtm", false )

	if hack.kind == "atm" then
		if success then
			local reward = math.random ( 500, 3000 )
			local money = MtxGetElementData ( player, "money" )
			MtxSetElementData ( player, "money", money + reward )
			outputChatBox ( "Du hast den Geldautomaten erfolgreich gehackt und erhälst "..reward.." "..Tables.waehrung.."!", player, 200, 0, 0 )
		else
			outputChatBox ( "Der Kurzschluss ist fehlgeschlagen - der Geldautomat bleibt gesperrt!", player, 200, 0, 0 )
		end
	elseif hack.kind == "door" then
		if success then
			if type ( vioOpenAllSchleusen ) == "function" then
				vioOpenAllSchleusen ()
			end
			if type ( vioOpenAllSFPDKerker ) == "function" then
				vioOpenAllSFPDKerker ()
			end
			outputChatBox ( "Du hast den Gefaengnis-Computer gehackt - alle Tueren sind jetzt offen! Beeil dich zur Zelle.", player, 200, 0, 0 )
			outputChatBox ( "Anonymus haben den Gefaengnis-Computer gehackt - alle Schleusen stehen offen!", getRootElement(), 200, 0, 0 )
		else
			outputChatBox ( "Der Kurzschluss ist fehlgeschlagen - der Computer bleibt gesperrt!", player, 200, 0, 0 )
		end
	end
end

local function startAtmHack ( player, atmKey )
	local atm = atms[atmKey]

	if not Aktiondeaktivieren then
		infobox ( player, "Gerade ist es nicht möglich einen Geldautomaten zu starten", 5000, 150, 0, 0 )
		return
	end

	if not isAnonymus ( player ) then
		outputChatBox ( "Du bist kein Mitglied der Anonymus!", player, 255, 0, 0 )
		return
	end

	if activeHacks[player] then
		outputChatBox ( "Du hackst bereits etwas!", player, 200, 0, 0 )
		return
	end

	if getElementType ( player ) ~= "player" or getPedOccupiedVehicle ( player ) ~= false or getDistanceBetweenPoints3D ( atm.x, atm.y, atm.z, getElementPosition ( player ) ) >= 5 then
		return
	end

	if getTickCount() < atm.cooldownUntil then
		outputChatBox ( "Der Geldautomat wurde vor kurzem berreits gehackt !", player, 200, 0, 0 )
		outputChatBox ( "Anonymus versuchten einen Geldautomaten zu hacken ("..atm.label..")!", getRootElement(), 200, 0, 0 )
		return
	end
	atm.cooldownUntil = getTickCount() + ATM_HACK_COOLDOWN_MS

	setElementFrozen ( player, true )
	setPedAnimation ( player, "bomber", "BOM_Plant_Loop", -1, true, false, false )
	MtxSetElementData ( player, "hackingAtm", true )
	outputChatBox ( "Anonymus haben zugeschlagen und versuchen den Geldautomaten("..atm.label..") zu hacken!", getRootElement(), 200, 0, 0 )
	setPlayerWantedLevel ( player, 2 )
	MtxSetElementData ( player, "wanteds", 2 )

	-- Polizei sofort alarmieren, sobald der Hack (und damit das Minispiel)
	-- beginnt - nicht erst nach Abschluss.
	local alarm = "Alarm: Ein Geldautomat ("..atm.label..") wird gerade gehackt!"
	sendMSGForFaction ( alarm, 1, 255, 150, 0 )
	sendMSGForFaction ( alarm, 6, 255, 150, 0 )
	sendMSGForFaction ( alarm, 8, 255, 150, 0 )

	activeHacks[player] = {
		kind = "atm",
		atmKey = atmKey,
		failsafeTimer = setTimer ( function ()
			endHack ( player, false )
		end, ( ATM_HACK_TIME_LIMIT + 5 ) * 1000, 1 ),
	}

	triggerClientEvent ( player, "startAtmHackMinigame", player, ATM_HACK_TIME_LIMIT )
end

------------------------------------------------------------------
-- Zentraler Gefaengnis-Computer: hacken oeffnet ALLE Schleusen auf einmal.
-- Danach muss man physisch runter zum Knast und mit /hackfree den
-- Gefangenen direkt in der Zelle befreien.
------------------------------------------------------------------
local DOOR_HACK_TIME_LIMIT = 20
local DOOR_HACK_COOLDOWN_MS = 10*60*1000
local doorHackCooldownUntil = 0

local PRISON_COMPUTER = { x = 229.904, y = 125.947, z = 1010.219, int = 10, dim = 0 }

local prisonComputerMarker = createMarker ( PRISON_COMPUTER.x, PRISON_COMPUTER.y, PRISON_COMPUTER.z - 1, "cylinder", 1.5, 46, 110, 255, 120 )
setElementInterior ( prisonComputerMarker, PRISON_COMPUTER.int )
setElementDimension ( prisonComputerMarker, PRISON_COMPUTER.dim )
addEventHandler ( "onMarkerHit", prisonComputerMarker, function ( hitElement )
	if getElementType ( hitElement ) ~= "player" then return end
	if isAnonymus ( hitElement ) then
		outputChatBox ( "Gefaengnis-Computer gefunden. Mit /hackcomputer kannst du versuchen, ihn zu hacken.", hitElement, 46, 110, 255 )
	end
end )

function startDoorHack ( player )
	if not isAnonymus ( player ) then
		outputChatBox ( "Du bist kein Mitglied der Anonymus!", player, 255, 0, 0 )
		return
	end

	if activeHacks[player] then
		outputChatBox ( "Du hackst bereits etwas!", player, 200, 0, 0 )
		return
	end

	if getElementInterior ( player ) ~= PRISON_COMPUTER.int or getElementDimension ( player ) ~= PRISON_COMPUTER.dim then
		outputChatBox ( "Du musst am Gefaengnis-Computer sein!", player, 125, 0, 0 )
		return
	end
	local px, py, pz = getElementPosition ( player )
	if getDistanceBetweenPoints3D ( px, py, pz, PRISON_COMPUTER.x, PRISON_COMPUTER.y, PRISON_COMPUTER.z ) > 5 then
		outputChatBox ( "Du musst am Gefaengnis-Computer sein!", player, 125, 0, 0 )
		return
	end

	if getTickCount() < doorHackCooldownUntil then
		outputChatBox ( "Der Gefaengnis-Computer wurde vor kurzem bereits gehackt - versuch es spaeter erneut!", player, 200, 0, 0 )
		return
	end
	doorHackCooldownUntil = getTickCount() + DOOR_HACK_COOLDOWN_MS

	setElementFrozen ( player, true )
	setPedAnimation ( player, "bomber", "BOM_Plant_Loop", -1, true, false, false )
	setPlayerWantedLevel ( player, 3 )
	MtxSetElementData ( player, "wanteds", 3 )

	local alarm = "Alarm: Anonymus hackt gerade den Gefaengnis-Computer!"
	sendMSGForFaction ( alarm, 1, 255, 150, 0 )
	sendMSGForFaction ( alarm, 6, 255, 150, 0 )
	sendMSGForFaction ( alarm, 8, 255, 150, 0 )

	activeHacks[player] = {
		kind = "door",
		failsafeTimer = setTimer ( function ()
			endHack ( player, false )
		end, ( DOOR_HACK_TIME_LIMIT + 5 ) * 1000, 1 ),
	}

	triggerClientEvent ( player, "startAtmHackMinigame", player, DOOR_HACK_TIME_LIMIT )
end
addCommandHandler ( "hackcomputer", startDoorHack )

addEvent ( "atmHackMinigameResult", true )
addEventHandler ( "atmHackMinigameResult", getRootElement(), function ( success )
	if not activeHacks[client] then return end
	endHack ( client, success and true or false )
end )

addEventHandler ( "onPlayerWasted", getRootElement(), function ()
	endHack ( source, false )
end )
addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	endHack ( source, false )
end )

function atmhack ( player ) startAtmHack ( player, "bhf" ) end
addCommandHandler ( "hackbhf", atmhack )

function atmnoob ( player ) startAtmHack ( player, "noob" ) end
addCommandHandler ( "hacknoob", atmnoob )

function atmstadt ( player ) startAtmHack ( player, "stadt" ) end
addCommandHandler ( "hackstadt", atmstadt )

function atmpay ( player ) startAtmHack ( player, "wangcars" ) end
addCommandHandler ( "hackwangcars", atmpay )

function handy_hack(player, cmd, pplayer)
    if isAnonymus(player) then
	    local target = getPlayerFromName(pplayer)
	    if isElement ( target ) then
		    local target = getPlayerFromName(pplayer)
			if MtxGetElementData ( target, "handystate" ) == "on" then
			    MtxSetElementData ( target, "handystate", "off" )
				outputChatBox ( "Du hast das Handy des Spielers gehackt und ausgeschaltet!", player, 125, 0, 0 )
			else
			    MtxSetElementData ( target, "handystate", "on" )
				outputChatBox ( "Du hast das Handy des Spielers gehackt und angeschaltet!!", player, 125, 0, 0 )
			end
		else
		    outputChatBox ( "Ungültiger Spieler!", player, 125, 0, 0 )
		end
	else
	    outputChatBox ( "Du bist kein Mitglied der Anonymus!", player, 125, 0, 0 )
	end
end
addCommandHandler("hackhandy", handy_hack)

-- Ersetzt den frueheren Fernbefehl /hackprison: nachdem Anonymus sich per
-- Computer-Hack (siehe startDoorHack oben) physisch Zugang zum Gefaengnis
-- verschafft hat, muss er/sie bis zu dieser festen Stelle (Zellenblock-
-- Eingang) vordringen, um den Gefangenen freizulassen. Nutzt weiterhin die
-- bestehende freePlayerFromJail(player) aus prison/arrest_server.lua, statt
-- die Freilassung neu zu bauen.
local HACKFREE_POS = { x = 2420.010, y = -1277.974, z = 988.191, int = 2, dim = 0 }

function hackfree_func ( player, cmd, targetname )
	if not isAnonymus ( player ) then
		outputChatBox ( "Du bist kein Mitglied der Anonymus!", player, 255, 0, 0 )
		return
	end

	if not targetname then
		outputChatBox ( "Verwende /hackfree Spielername (nur am Zellenblock-Eingang)", player, 125, 0, 0 )
		return
	end

	local target = getPlayerFromName ( targetname )
	if not target then
		outputChatBox ( "Ungueltiger Spieler!", player, 125, 0, 0 )
		return
	end

	if ( tonumber ( MtxGetElementData ( target, "jailtime" ) ) or 0 ) <= 0 and ( tonumber ( MtxGetElementData ( target, "prison" ) ) or 0 ) <= 0 then
		outputChatBox ( getPlayerName ( target ).." sitzt gerade gar nicht im Gefaengnis!", player, 125, 0, 0 )
		return
	end

	if getElementInterior ( player ) ~= HACKFREE_POS.int or getElementDimension ( player ) ~= HACKFREE_POS.dim then
		outputChatBox ( "Du musst am Zellenblock-Eingang sein!", player, 125, 0, 0 )
		return
	end

	local px, py, pz = getElementPosition ( player )
	if getDistanceBetweenPoints3D ( px, py, pz, HACKFREE_POS.x, HACKFREE_POS.y, HACKFREE_POS.z ) > 5 then
		outputChatBox ( "Du musst am Zellenblock-Eingang sein!", player, 125, 0, 0 )
		return
	end

	freePlayerFromJail ( target )
	outputChatBox ( "Du hast "..getPlayerName ( target ).." befreit!", player, 200, 0, 0 )
	outputChatBox ( "Anonymus haben "..getPlayerName ( target ).." aus dem Gefaengnis befreit!", getRootElement(), 200, 0, 0 )
end
addCommandHandler ( "hackfree", hackfree_func )

function clear_ghost ( player, cmd, target )
	if player == client or not client then
		if isAnonymus(player) then
		if timeStadt == nil or timeStadt ~= nil and getTickCount() - timeStadt >= 600000  then
			local target = getPlayerFromName( target )
			if getElementType ( target ) == "player" and MtxGetElementData ( target, "loggedin" ) == 1 then
			    timeStadt = getTickCount()
				MtxSetElementData ( target, "wanteds", 0 )
				setPlayerWantedLevel ( target, 0 )
				outputChatBox ( "Du hast "..getPlayerName(target).." eine neue Identität verschafft!", player,255, 255, 0 )
				outputChatBox ( "Anonymus "..getPlayerName(player).." hat dir eine neue Identität verschafft, du wirst nun nicht mehr gesucht! ", target, 255, 255, 0 )			
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nUngueltiger\nSpieler!", 5000, 125, 0, 0 )
			end
			else
			   outputChatBox("Du musst noch " .. 10 - math.ceil((getTickCount() - timeStadt) / 600000 ) .. " Minuten warten!", player, 125, 0, 0)
		   end
	   end
	end
end
addCommandHandler("hackwanteds", clear_ghost)