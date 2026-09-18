--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addEvent ( "onIceStatChange", true )
addEvent ( "ElementClickedServer", true )
addEvent ( "HungerChangeServer", true )
addEvent ( "changeClientElementData", true )

elementData = {}

local loginBatch = {}

local MELDE_PAUSE_MS = 5000
local letzteDatenMeldung = {}

function beginElementDataBatch ( player )
	loginBatch[player] = {}
end

function flushElementDataBatch ( player )
	local batch = loginBatch[player]
	loginBatch[player] = nil
	if batch and isElement ( player ) and next ( batch ) then
		triggerClientEvent ( player, "triggerClientElementDataBatch", player, batch )
	end
end

local syncedData = { ["bonuspoints"] = true, ["carslotupgrade"] = true, ["carslotupgrade2"] = true, ["carslotupgrade3"] = true, ["carslotupgrade4"] = true, ["carslotupgrade5"] = true, ["kingofthehill_achiev"] = true, 
["own_foots"] = true, ["rl_achiev"] = true, ["nichtsgehtmehr_achiev"] = true, ["chickendinner_achiev"] = true, ["viewpoints"] = true, ["maxcars"] = true, ["lungenvol"] = true, ["muscle"] = true, ["stamina"] = true, 
["kungfu"] = true,["boxen"] = true, ["streetfighting"] = true, ["pistolskill"] = true, ["deagleskill"] = true, ["assaultskill"] = true, ["shotgunskill"] = true, ["mp5skill"] = true, ["doubleSMG"] = true, 
["vortex"] = true, ["skimmer"] = true,["golfcart"] = true, ["romero"] = true, ["quad"] = true, ["bonusskin1"] = true, ["fruitNotebook"] = true,["fglass"] = true, 
["segellicense"] = true, ["motorbootlicense"] = true,["planelicenseb"] = true, ["planelicensea"] = true, ["helilicense"] = true, ["bikelicense"] = true, ["lkwlicense"] = true, ["carlicense"] = true, 
["drivingSchoolPractise"] = true, ["imzugjob"] = true,["imtramjob"] = true, ["casinoChips"] = true, ["curclicked"] = true, ["food1"] = true, ["food2"] = true, ["food3"] = true, 
["clickedVehicle"] = true, ["bankmoney"] = true, ["job"] = true, ["armyperm10"] = true,["housekey"] = true, ["warns"] = true, ["GangwarKills"] = true, ["GangwarTode"] = true, ["AnzahlGangwarsGewonnen"] = true, ["AnzahlGangwarsVerloren"] = true, 
["foundpackages"] = true, ["drugs"] = true, ["mats"] = true, ["drugFlushPoints"] = true,["cigarettFlushPoints"] = true, ["isInArea51Mission"] = true, ["medikits"] = true, ["repairkits"] = true, ["object"] = true, 
["isafk"] = true, ["skinid"] = true, ["kuerbisse"] = true, ["rang"] = true, ["boxlvl"] = true,["gunboxa"] = true, ["gunboxb"] = true, ["gunboxc"] = true, ["fishingPole"] = true, ["fishingHooks"] = true, 
["fishingWorms"] = true, ["anim"] = true, ["club"] = true, ["presents"] = true, ["gluecksradTickets"] = true, ["gurt"] = true, ["newspaper"] = true,["benzinkannister"] = true, ["flowerseeds"] = true, ["dice"] = true, ["zigaretten"] = true, ["totalHorseShoes"] = true, 
["curcars"] = true, ["spawnpos_y"] = true, ["perso"] = true, ["gunloads"] = true, ["bizkey"] = true,["drugAddictPoints"] = true, ["alcoholAddictPoints"] = true, ["cigarettAddictPoints"] = true, ["armyperm7"] = true, 
["armyperm8"] = true, ["armyperm9"] = true, ["airportlvl"] = true, ["jobDimension"] = true, ["bauarbeiterLVL"] = true, ["jobtime"] = true, ["isInFarmJob"] = true, ["farmerLVL"] = true, ["streetCleanPoints"] = true, 
["truckerlvl"] = true, ["playerid"] = true, ["shaderWater"] = true, ["shaderBloom"] = true,["shaderCarpain"] = true, ["shaderRoadshine"] = true, ["yachtImBesitz"] = true, ["fishingFishATyp"] = true, ["fishingFishBTyp"] = true, 
["fishingFishCTyp"] = true, ["fishingFishAWeight"] = true, ["fishingFishBWeight"] = true,["fishingFishCWeight"] = true, ["timePlayedToday"] = true, ["highscore_achiev"] = true, ["revolverheld_achiev"] = true,
["highwaytohell_achiev"] = true, ["silentassasin_achiev"] = true, ["thetruthisoutthere_achiev"] = true, ["collectr_achiev"] = true, ["licenses_achiev"] = true, ["angler_achiev"] = true, ["schlaflosinsa"] = true,
["curplayingtime"] = true, ["gunlicense"] = true, ["fishinglicense"] = true, ["fishingSkill"] = true, ["gambleSkill"] = true, ["coins"] = true,["lastPremCarGive"] = true,["lastNumberChange"] = true,["lastSocialChange"] = true,["PremiumData"] = true,
["Introtask"] = true,["levelshop1"] = true,["levelshop2"] = true,["levelshop3"] = true,["levelshop4"] = true
}


local notSyncedData = { ["adminEnterVehicle"] = true, ["clickPed"] = true, ["sprint"] = true, ["gotdamoney"] = true, ["alcoholFlushPoints"] = true, ["callswith"] = true, ["call"] = true,
["calls"] = true, ["calledby"] = true, ["isinairportmission"] = true, ["contract"] = true, ["heaventime"] = true, ["boni"] = true, ["amount"] = true, ["tazered"] = true, ["timerrunning"] = true,
["engine"] = true, ["spawnpos_x"] = true, ["spawnpos_y"] = true, ["spawnpos_z"] = true, ["spawnrot_x"] = true, ["spawnrot_y"] = true, ["spawnrot_z"] = true, ["rcVehicle"] = true, ["carToBuyFrom"] = true,
["carToBuySlot"] = true, ["carToBuyPrice"] = true, ["carToBuyModel"] = true, ["spawnposx"] = true, ["spawnposy"] = true, ["spawnposz"] = true, ["spawnrotx"] = true, ["spawnroty"] = true, ["spawnrotz"] = true, 
["packages"] = true, ["ID"] = true, ["isInCarHouse"] = true, ["lookingAtCar"] = true, ["carHouse"] = true, ["drivingSchoolCur"] = true, ["drivingSchoolMarker"] = true, ["drivingSchoolBlip"] = true, 
["drivingSchoolVeh"] = true,["drivingSchoolPed"] = true, ["drivingSchoolCur"] = true, ["drivingSchoolPractise"] = true, ["magpos"] = true, ["magnetic"] = true, ["hasmagnetactivated"] = true, ["magneticVeh"] = true, 
["fireAble"] = true, ["katjuschaID"] = true,["attachedToPacker"] = true, ["gateID"] = true, ["fuelSaving"] = true, ["gps"] = true, ["wheelrefreshable"] = true, ["smokeable"] = true, ["sx"] = true, ["sy"] = true, ["sz"] = true, 
["sr"] = true, ["tuningSx"] = true,["tuningSy"] = true, ["tuningSz"] = true, ["tuningSr"] = true, ["blackJackStarted"] = true, ["curBlackJackBet"] = true, ["airstrike"] = true, ["objectDelete"] = true, ["ticketOffered"] = true, 
["callswithpolice"] = true,["callswithmedic"] = true, ["needhelpmedic"] = true, ["callswithmechaniker"] = true, ["needhelpmechaniker"] = true, ["bail"] = true, ["nodmzone"] = true, ["intdim"] = true, ["curpizza"] = true, 
["expTimer"] = true, ["objectToPlace"] = true, ["formationCount"] = true, ["formationID"] = true, ["curIntIn"] = true, ["wanzen"] = true, ["needMech"] = true, ["newsNotPostable"] = true, ["isLive"] = true, 
["isLiveWith"] = true, ["ticketprice"] = true, ["tied"] = true,["tester"] = true, ["hasBomb"] = true, ["tazer"] = true, ["spawndim"] = true, ["spawnint"] = true, ["armingBomb"] = true, ["secRaceID"] = true, 
["rentedacar"] = true, ["carrenter"] = true, ["rentcar"] = true,["gangCreateTry"] = true, ["lasthp"] = true, ["lastcrime"] = true, ["time"] = true, ["weed"] = true, ["growing"] = true, ["RCVanSeat"] = true, ["RCVan"] = true, 
["player"] = true, ["pickupID"] = true, ["arrester"] = true,["AnzahlEingeknastet"] = true, ["AnzahlGangwars"] = true, ["Kills"] = true, ["Tode"] = true, ["HaeuserGekauft"] = true, ["FahrzeugeGekauft"] = true, 
["FahrzeugeVerkauft"] = true, ["DamageGemacht"] = true, ["DamageBekommen"] = true,["FraktionenBetreten"] = true, ["FraktionenVerlassen"] = true, ["Eingeloggt"] = true, ["MontagSpielzeit"] = true, ["DienstagSpielzeit"] = true, 
["MittwochSpielzeit"] = true, ["DonnerstagSpielzeit"] = true, ["FreitagSpielzeit"] = true, ["SamstagSpielzeit"] = true, ["SonntagSpielzeit"] = true, ["LetzteWocheSpielzeit"] = true, ["AnzahlImKnast"] = true, 
["GangwarDamageGemacht"] = true,["GangwarDamageBekommen"] = true, ["muted"] = true, ["fishingSkillOld"] = true, ["house"] = true, ["housex"] = true, ["housey"] = true, 
["housez"] = true, ["handyCosts"] = true,["handyType"] = true, ["pdayincome"] = true, ["botname"] = true, ["rot"] = true, ["int"] = true, ["dim"] = true, ["kasse"] = true, ["curint"] = true, ["SchleusenNummer"] = true,
["ownerfraktion"] = true, ["price"] = true, ["item"] = true, ["pos"] = true, ["typ"] = true, ["uid"] = true
}

for i=1, 25 do
	notSyncedData["carslot"..i] = true
	notSyncedData["package"..i] = true
	if i~=7 and i~=8 and i~=9 then
		notSyncedData["armyperm"..i] = true
	end
end


-- Hoechstes vergebbares Adminlevel ( 6 = Entwickler, siehe adminLevels in
-- admin/admincmds.lua ). Global, damit auch dort damit geprueft wird.
ADMIN_MAX_LEVEL = 6

function MtxSetElementData ( player, dataString, value )
	if player and dataString and value ~= nil then
		-- Letzte Bremse fuer das Adminlevel: egal welcher Weg den Wert setzt
		-- ( Befehl, Datenbank, Web-Panel ), oberhalb von ADMIN_MAX_LEVEL wird
		-- gekappt und gemeldet.
		if dataString == "adminlvl" then
			local stufe = tonumber ( value )
			if not stufe or stufe < 0 or stufe > ADMIN_MAX_LEVEL then
				local gekappt = math.max ( 0, math.min ( ADMIN_MAX_LEVEL, stufe or 0 ) )
				if meldeAdmins and isElement ( player ) then
					meldeAdmins ( "Adminlevel "..tostring ( value ).." fuer "..getPlayerName ( player ).." abgelehnt - auf "..gekappt.." gesetzt." )
				end
				value = gekappt
			end
		end

		-- Gleiche Bremse fuer "wanteds": setPlayerWantedLevel akzeptiert NUR
		-- ganze Zahlen 0-6 und wirft sonst einen Laufzeitfehler. Ueber 20
		-- Stellen im Projekt lesen "wanteds" und reichen es ungeprueft weiter -
		-- statt jede einzeln abzusichern, wird hier direkt beim Speichern
		-- gekappt, damit ein ungueltiger Wert gar nicht erst entstehen kann.
		if dataString == "wanteds" then
			local stufe = tonumber ( value )
			value = math.max ( 0, math.min ( 6, math.floor ( stufe or 0 ) ) )
		end

		if not elementData[player] then
			elementData[player] = {}
		end
		elementData[player][dataString] = value

		-- Alles Weitere braucht ein echtes Element ( triggerEvent, setPlayerMoney,
		-- setElementData ... ). Wird MtxSetElementData mit einem bereits
		-- zerstoerten oder ungueltigen "player" aufgerufen, nur den Cache setzen.
		if isElement ( player ) then
			triggerEvent ( "onIceStatChange", player, dataString, value )
			if dataString == "money" then
				local value = math.floor ( value )
				triggerClientEvent ( player, "syncMoney", player, value )
				setPlayerMoney ( player, value, true )
				elementData[player][dataString] = value
			elseif dataString == "hitglocke" then
				triggerClientEvent ( player, "changeHitglocke", player, value == 1 )
			elseif syncedData[dataString] then
				if loginBatch[player] then
					loginBatch[player][dataString] = value
				else
					triggerClientEvent ( player, "triggerClientElementData", player, dataString, value )
				end
			elseif not notSyncedData[dataString] then
				setElementData ( player, dataString, value )
			end
		end
	else
		return nil
	end
end

-- Meistgenutzte Funktion des Gamemodes. Verhalten ist unveraendert - es wird
-- lediglich nicht mehr fuer jeden Aufruf vier- bis fuenfmal derselbe Tabellen-
-- eintrag nachgeschlagen. Die Ruecksprung-Bedingungen sind identisch:
--   - ein zwischengespeicherter Wert, der "wahr" ist, wird zurueckgegeben
--   - sonst wird ( ausser bei adminlvl/loggedin und nicht synchronisierten
--     Schluesseln ) einmal echt nachgelesen und das Ergebnis gemerkt
--   - andernfalls nil
function MtxGetElementData ( player, dataString )
	if not player or not dataString then
		return nil
	end

	local cache = elementData[player]
	if not cache then
		cache = {}
		elementData[player] = cache
	end

	local wert = cache[dataString]
	if wert then
		return wert
	end

	if dataString ~= "adminlvl" and dataString ~= "loggedin" and not notSyncedData[dataString] then
		wert = getElementData ( player, dataString )
		cache[dataString] = wert
		return wert
	end

	return nil
end

function freeElementData ()

	loginBatch[source] = nil
	letzteDatenMeldung[source] = nil
	if elementData then
		if getElementType ( source ) ~= "player" then
			if elementData[source] then
				elementData[source] = nil
			end
		end
	end
end
addEventHandler ( "onElementDestroy", getRootElement(), freeElementData )

function findPlayerByName( playerPart )

	local pl = getPlayerFromName ( playerPart )
	if isElement ( pl ) then
		return pl
	end

	if type ( playerPart ) ~= "string" or playerPart == "" then
		return false
	end

	-- Die Teilnamen-Suche gab bisher "v" zurueck - eine Variable, die es hier
	-- gar nicht gibt. Sie lieferte damit immer nil, obwohl der passende Spieler
	-- bereits gefunden war. Betrifft rund 55 Aufrufstellen ( Adminbefehle,
	-- Fraktions- und Polizeibefehle, Knast ).
	local suche = string.lower ( playerPart )
	local players = getElementsByType ( "player" )
	for i = 1, #players do
		local name = string.gsub ( string.lower ( getPlayerName ( players[i] ) ), "#%x%x%x%x%x%x", "" )
		-- "plain": Namen enthalten oft Zeichen wie [ ] ( ) - , die in einem
		-- Lua-Muster eine Sonderbedeutung haetten ( z.B. "[Admin]Name" ).
		if string.find ( name, suche, 1, true ) then
			return players[i]
		end
	end

	return false
 end
 
 
function setElementClicked ( player, value )
	local player = player
	local value = value
	local triggered = false
	if not isElement ( player ) then
		value = player
		player = client 
		triggered = true
	end
	elementData[player]["ElementClicked"] = value
	if not triggered then
		triggerClientEvent ( player, "ElementClicked", player, value )
	end
end
-- SICHERHEIT: nicht setElementClicked direkt anhaengen. Die Funktion faellt nur
-- dann auf "client" zurueck, wenn kein Element uebergeben wurde - ein Cheater
-- konnte also ein fremdes Spielerelement mitschicken und dessen Klicksystem
-- blockieren. Der eigene Client sendet ohnehin nur den Wert.
addEventHandler ( "ElementClickedServer", root, function ( wert )
	if not isElement ( client ) or isElement ( wert ) then return end
	if not elementData[client] then elementData[client] = {} end
	elementData[client]["ElementClicked"] = wert
end )


-- Neben dieser Tabelle melden etliche Fenster ihren Zustand direkt per
-- setElementData. Ohne den zweiten Blick darauf sieht das Klicksystem sie nicht
-- als offen an und oeffnet z.B. beim Klick auf ein Fahrzeug ein weiteres Menue.
function getElementClicked ( player )
	if elementData[player] and elementData[player]["ElementClicked"] then
		return true
	end
	return getElementData ( player, "ElementClicked" ) == true
end


function setElementHunger ( player, value )
	local player = player
	local value = value
	local triggered = false
	if not isElement ( player ) then
		value = player
		player = client 
		triggered = true
	end
	if value > 100 then
		value = 100
	end
	elementData[player]["Hunger"] = value
	if not triggered then
		triggerClientEvent ( player, "HungerChange", player, value )
	end
end
-- SICHERHEIT: siehe ElementClickedServer oben - immer der Absender.
addEventHandler ( "HungerChangeServer", root, function ( wert )
	if not isElement ( client ) then return end
	wert = tonumber ( wert )
	if not wert then return end
	if wert > 100 then wert = 100 end
	if wert < 0 then wert = 0 end
	if not elementData[client] then elementData[client] = {} end
	elementData[client]["Hunger"] = wert
end )


function getElementHunger ( player )
	return elementData[player] and elementData[player]["Hunger"]
end


-- Meldet einen Sicherheitsvorfall allen Admins im Chat und zusaetzlich ins
-- Debugscript. Global, damit auch anticheat_server.lua sie benutzen kann.
function meldeAdmins ( text, mindestlevel )
	mindestlevel = mindestlevel or 1
	outputChatBox ( "[Sicherheit] "..text )
	for _, spieler in ipairs ( getElementsByType ( "player" ) ) do
		if ( tonumber ( MtxGetElementData ( spieler, "adminlvl" ) ) or 0 ) >= mindestlevel then
			outputChatBox ( "[Sicherheit] "..text, spieler, 255, 80, 80 )
		end
	end
end

-- Besonders heikle Schluessel: hier wird auch dann gemeldet, wenn jemand es
-- nur einmal versucht.
local heikleSchluessel = {
	["adminlvl"] = true, ["money"] = true, ["bankmoney"] = true,
	["coins"] = true, ["fraktion"] = true, ["rang"] = true,
	["premium"] = true, ["Paket"] = true, ["level"] = true,
}

-- Diese vier Schluessel setzt vioClientSetElementData ( core/data_client.lua )
-- legitim. Alles andere lehnt der Server ab.
local clientDarfSetzen = {
	["clickedVehicle"] = true,
	["nodmzone"]       = true,
	["object"]         = true,
	["tazered"]        = true,
}

-- SICHERHEIT: Vorher schrieb dieser Handler jeden beliebigen Schluessel mit
-- jedem beliebigen Wert in den Cache. Da MtxGetElementData zuerst aus dem Cache
-- liest, liess sich damit per Lua-Executor "adminlvl", "money" oder "fraktion"
-- frei setzen.
addEventHandler ( "changeClientElementData", root, function ( dataString, value )
	if not isElement ( client ) then
		return
	end

	if type ( dataString ) ~= "string" or not clientDarfSetzen[dataString] then
		local jetzt = getTickCount ()
		-- Heikle Schluessel werden oefter gemeldet, aber nicht unbegrenzt -
		-- sonst liesse sich der Adminchat zuspammen.
		local pause = heikleSchluessel[dataString] and 2000 or MELDE_PAUSE_MS
		if not letzteDatenMeldung[client] or ( jetzt - letzteDatenMeldung[client] ) > pause then
			letzteDatenMeldung[client] = jetzt
			local name = getPlayerName ( client )
			if heikleSchluessel[dataString] then
				meldeAdmins ( name.." hat versucht, sich '"..tostring ( dataString ).."' zu setzen! (abgelehnt)" )
			else
				meldeAdmins ( name.." wollte unerlaubt '"..tostring ( dataString ).."' setzen - abgelehnt." )
			end
		end
		return
	end

	-- Keine Tabellen: damit liessen sich sonst riesige oder zyklische
	-- Strukturen einschleusen, die Server und Clients lahmlegen.
	local typ = type ( value )
	if typ ~= "number" and typ ~= "boolean" and typ ~= "string" and not isElement ( value ) then
		return
	end
	if typ == "string" and #value > 64 then
		return
	end

	if not elementData[client] then
		elementData[client] = {}
	end
	elementData[client][dataString] = value
end )


addEvent ( "socialStateNewChange", true )
addEventHandler ( "socialStateNewChange", root, function ( text )
	MtxSetElementData ( client, "socialState", text )
end )
	