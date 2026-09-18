--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


local function stelleAufDatetimeUm ( spalte )
	local info = dbPoll ( dbQuery ( handler, "SHOW COLUMNS FROM `userdata` LIKE ?", spalte ), -1 )
	local typ = info and info[1] and tostring ( info[1]["Type"] ):lower () or ""
	if typ == "" or typ == "datetime" then return end   -- fehlt oder schon fertig

	local ok = dbExec ( handler, "ALTER TABLE `userdata` ADD COLUMN `"..spalte.."_neu` datetime NULL" )
		and dbExec ( handler, "UPDATE `userdata` SET `"..spalte.."_neu` = FROM_UNIXTIME(`"..spalte.."`) WHERE `"..spalte.."` > 0" )
		and dbExec ( handler, "ALTER TABLE `userdata` DROP COLUMN `"..spalte.."`" )
		and dbExec ( handler, "ALTER TABLE `userdata` CHANGE `"..spalte.."_neu` `"..spalte.."` datetime NULL" )

	outputDebugString ( "[Premium] Spalte "..spalte..( ok and " auf DATETIME umgestellt." or " - Umstellung FEHLGESCHLAGEN!" ), ok and 3 or 1 )
end

if handler then
	stelleAufDatetimeUm ( "PremiumData" )       -- wann laeuft Premium ab
	stelleAufDatetimeUm ( "lastPremCarGive" )   -- wann gibt es das naechste Gratisfahrzeug
else
	outputDebugString ( "[Premium] Kein DB-Handler - Spalten nicht geprueft!", 2 )
end

vipPackageName = { [1] = "Bronze", [2] = "Silber", [3] = "Gold", [4] = "Platin", [5] = "TOP DONATOR" }
vipPayDayExtra = { [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200, [5] = 300 }

vipPremCarIntervall = { [4] = 604800, [5] = 302400 }   -- 7 bzw. 3,5 Tage

changeCarLockedIDs = { ["432"]=true, ["476"]=true, ["447"]=true, ["464"]=true, ["425"]=true, ["520"]=true }

local PREMIUM_UNBEGRENZT = 2147483647   -- Webpanel schreibt das bei "unbegrenzt"
local PREMCAR_CHECK_MS   = 600000       -- wie oft der Anspruch geprueft wird

---------------------------------------------------------------------
-- Hilfsfunktionen
---------------------------------------------------------------------
local function msg ( player, text, r, g, b )
	outputChatBox ( text, player, r or 0, g or 125, b or 0 )
end

local function jetzt () return getRealTime().timestamp end

local function paketVon ( player )
	return tonumber ( MtxGetElementData ( player, "Paket" ) ) or 0
end

local function zahl ( player, key )
	return tonumber ( MtxGetElementData ( player, key ) ) or 0
end


function getPremiumRestText ( ablauf )
	ablauf = tonumber ( ablauf ) or 0
	if ablauf >= PREMIUM_UNBEGRENZT then return "unbegrenzt" end

	local rest = ablauf - jetzt ()
	if rest <= 0 then return "abgelaufen" end

	local tage = math.floor ( rest / 86400 )
	if tage >= 1 then return "noch "..tage..( tage == 1 and " Tag" or " Tage" ) end

	local std = math.floor ( rest / 3600 )
	if std >= 1 then return "noch "..std..( std == 1 and " Stunde" or " Stunden" ) end
	return "laeuft in weniger als einer Stunde ab"
end


local function tageText ( sekunden )
	local tage = ( tonumber ( sekunden ) or 0 ) / 86400
	if tage == math.floor ( tage ) then return tostring ( math.floor ( tage ) ) end
	return ( string.format ( "%.1f", tage ):gsub ( "%.", "," ) )
end


function getPremiumPaketName ( paket )
	return vipPackageName[tonumber ( paket ) or 0] or "Unbekannt"
end

function getNaechstesPremiumFahrzeug ( player )
	return zahl ( player, "lastPremCarGive" )
end

---------------------------------------------------------------------
-- Status pruefen
---------------------------------------------------------------------
local function premiumZuruecksetzen ( player, grund )
	msg ( player, "Premium-Status: "..grund, 125, 0, 0 )
	dbExec ( handler, "UPDATE `userdata` SET `PremiumPaket`=0, `PremiumData`=NULL WHERE `UID`=?", playerUID[getPlayerName ( player )] )
	MtxSetElementData ( player, "PremiumData", 0 )
	MtxSetElementData ( player, "Paket", 0 )
	MtxSetElementData ( player, "premium", false )
end

function checkPremium ( player )
	local ablauf = zahl ( player, "PremiumData" )
	local paket  = paketVon ( player )

	if ablauf == 0 then return premiumZuruecksetzen ( player, "Nicht Aktiv." ) end
	if ablauf < jetzt () then return premiumZuruecksetzen ( player, "Abgelaufen." ) end

	if paket <= 0 then
		msg ( player, "Premium-Status: Paket nicht gefunden, bitte Projektleiter kontaktieren.", 125, 0, 0 )
		return MtxSetElementData ( player, "premium", false )
	end

	MtxSetElementData ( player, "premium", true )
	msg ( player, "Premium: "..getPremiumPaketName ( paket ).." - "..getPremiumRestText ( ablauf ) )
	msg ( player, "/premium oeffnet dein Panel, /phelp zeigt deine weiteren Optionen." )
end

function setPremiumData ( player, tage, paket )
	local ablauf = jetzt () + 86400 * tage
	MtxSetElementData ( player, "Paket", tonumber ( paket ) )
	MtxSetElementData ( player, "PremiumData", ablauf )
	dbExec ( handler, "UPDATE `userdata` SET `PremiumPaket`=?, `PremiumData`=FROM_UNIXTIME(?) WHERE `UID`=?",
		paket, ablauf, playerUID[getPlayerName ( player )] )
	checkPremium ( player )
end


function giveFreePremiumCar ( player )
	if not isElement ( player ) or MtxGetElementData ( player, "premium" ) ~= true then return false end

	local intervall = vipPremCarIntervall[paketVon ( player )]
	if not intervall or getNaechstesPremiumFahrzeug ( player ) >= jetzt () then return false end

	local naechste = jetzt () + intervall
	MtxSetElementData ( player, "PremiumCars", zahl ( player, "PremiumCars" ) + 1 )
	MtxSetElementData ( player, "lastPremCarGive", naechste )

	msg ( player, "Du hast ein gratis Premium Fahrzeug erhalten!", 0, 200, 0 )
	msg ( player, "Setzen mit /pcar [SLOT] [ID]. Das naechste gibt es "..getPremiumRestText ( naechste ).."." )
	return true
end

setTimer ( function ()
	for _, player in ipairs ( getElementsByType ( "player" ) ) do
		if MtxGetElementData ( player, "loggedin" ) == 1 then giveFreePremiumCar ( player ) end
	end
end, PREMCAR_CHECK_MS, 0 )

---------------------------------------------------------------------
-- Befehle
---------------------------------------------------------------------
addCommandHandler ( "phelp", function ( player )
	if MtxGetElementData ( player, "premium" ) ~= true then
		return triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist\nnicht befugt!", 7500, 125, 0, 0 )
	end

	local paket = paketVon ( player )
	msg ( player, "Premium: "..getPremiumPaketName ( paket ).." - "..getPremiumRestText ( zahl ( player, "PremiumData" ) ) )
	msg ( player, "Status und Telefonnummer aenderst du im Webpanel (Reiter 'Coins')." )
	msg ( player, "/pcar [SLOT] [ID] - setzt dir ein Premium Fahrzeug. Verfuegbar: "..zahl ( player, "PremiumCars" ) )

	local intervall = vipPremCarIntervall[paket]
	if intervall then
		local naechste = getNaechstesPremiumFahrzeug ( player )
		msg ( player, "Alle "..tageText ( intervall ).." Tage ein gratis Fahrzeug - "
			..( naechste <= jetzt () and "jetzt abholbereit" or "wieder "..getPremiumRestText ( naechste ) ).."." )
	end
	if ( vipPayDayExtra[paket] or 0 ) > 0 then
		msg ( player, vipPayDayExtra[paket].."% mehr unversteuerte Einnahmen beim Payday." )
	end
end )


local function nurImWebpanel ( player )
	msg ( player, "Das aenderst du jetzt im Webpanel (Reiter 'Coins').", 255, 155, 0 )
end
addCommandHandler ( "premstatus", nurImWebpanel )
addCommandHandler ( "tele", nurImWebpanel )

function changeCar ( player, cmd, slot, id )
	if zahl ( player, "PremiumCars" ) < 1 then
		return msg ( player, "Du kannst momentan keine Premium Fahrzeuge setzen.", 255, 155, 0 )
	end
	if changeCarLockedIDs[id] then
		return msg ( player, "Du darfst dir dieses Fahrzeug nicht geben.", 255, 155, 0 )
	end
	if not slot or not id or not getVehicleNameFromModel ( id ) then
		return msg ( player, "Benutzung: /pcar [SLOT] [FAHRZEUG-ID]", 255, 155, 0 )
	end

	local uid = playerUID[getPlayerName ( player )]
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ??=?", "Typ", "vehicles", "Slot", slot, "UID", uid )

	if not ( result and result[1] ) then
		return msg ( player, "Du besitzt kein Fahrzeug in diesem Slot.", 255, 155, 0 )
	end

	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=? AND ??=?", "vehicles", "Typ", id, "Slot", slot, "UID", uid )
	MtxSetElementData ( player, "PremiumCars", zahl ( player, "PremiumCars" ) - 1 )
	msg ( player, "Slot "..slot.." auf "..getVehicleNameFromModel ( id ).." (ID "..id..") geaendert." )
end
addCommandHandler ( "pcar", function ( player, cmd, slot, id ) runAsync ( changeCar, player, cmd, slot, id ) end )
