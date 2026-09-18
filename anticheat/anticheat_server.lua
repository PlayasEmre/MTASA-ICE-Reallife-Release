--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--\\                                                  //

local Jetpack = {"brassknuckle","golfclub","nightstick","knife","bat","shovel","poolstick","katana","chainsaw","dildo","vibrator","flower","cane","grenade","teargas","molotov","colt 45","silenced","deagle","shotgun","sawed-off","combat shotgun","uzi","mp5","ak-47","m4","tec-9","rifle","sniper","rocket launcher","rocket launcher hs","flamethrower","minigun","satchel","bomb","spraycan","fire extinguisher","camera","nightvision","infrared"}
local notallowedcharacter = {" ","ä","ü","ö",",","#","'","+","*","~",":",";","=","}","?","\\","{","&","/","§","\"","!","°","@","|","`","´","<",">","none","keiner","niemand","niemandem","scheiss","adolf","hitler","server","german","roleplay","vio","ekonomie","eko","sunrise","coa","deltroyz","exo","ultimate","vnx","venox","neon","nova","touch","reallife","matrix","astro","gur","sex"}

local statLimits = {
    ["coins"]       = 100000000,
    ["money"]       = 100000000,
    ["bankmoney"]   = 100000000,
    ["drugs"]       = 50000,
    ["bonuspoints"] = 100000000,
    ["exp"]         = 100000000,
    ["level"]       = 10000,
}


local LOGIN_SCHONFRIST = 15000
local loginZeit = {}


local setztGeradeZurueck = {}

local function statZuruecksetzen ( player, dataString )
    setztGeradeZurueck[player] = true
    MtxSetElementData ( player, dataString, 0 )
    setztGeradeZurueck[player] = false
end

local function pruefeAlleStats ( player )
    if not isElement ( player ) or getElementType ( player ) ~= "player" then return end
    if MtxGetElementData ( player, "loggedin" ) ~= 1 then return end

    local adminLevel = tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0
    if adminLevel > 0 then return end

    for dataString, limit in pairs ( statLimits ) do
        local zahl = tonumber ( MtxGetElementData ( player, dataString ) )
        if zahl and zahl >= limit then
            statZuruecksetzen ( player, dataString )
            banVioShieldPlayer ( player, "Du wurdest vom Anti Cheat System vom Server ausgeschlossen ("..dataString..")" )
            return
        end
    end
end

addEventHandler ( "onIceStatChange", getRootElement(), function ( dataString, value )
    if setztGeradeZurueck[source] then return end

    if dataString == "loggedin" and tostring ( value ) == "1" and isElement ( source ) then
        loginZeit[source] = getTickCount ()
        local player = source
        setTimer ( function ()
            pruefeAlleStats ( player )
        end, LOGIN_SCHONFRIST + 1000, 1 )
        return
    end

    local limit = statLimits[dataString]
    if not limit then return end

    local player = source
    if not isElement ( player ) or getElementType ( player ) ~= "player" then return end
    if MtxGetElementData ( player, "loggedin" ) ~= 1 then return end

    if not loginZeit[player] or ( getTickCount () - loginZeit[player] ) < LOGIN_SCHONFRIST then
        return
    end

    local adminLevel = tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0
    if adminLevel > 0 then return end

    local zahl = tonumber ( value )
    if zahl and zahl >= limit then
        statZuruecksetzen ( player, dataString )
        banVioShieldPlayer ( player, "Du wurdest vom Anti Cheat System vom Server ausgeschlossen ("..dataString..")" )
    end
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
    loginZeit[source] = nil
    setztGeradeZurueck[source] = nil
end )


setTimer ( function ()
    for _, player in ipairs ( getElementsByType ( "player" ) ) do
        local leben = getElementHealth ( player )
        if MtxGetElementData ( player, "loggedin" ) == 1 and leben > 0 then
            if leben > 100.5 then
                setElementHealth ( player, 100 )
            end
            if getPedArmor ( player ) > 100.5 then
                setPedArmor ( player, 100 )
            end
        end
    end
end, 3000, 0 )


local NotAllowedWeapons  = { [38] = true, [37] = true, [18] = false, [39] = false }
local FEUER_MIN_ABSTAND   = 25   -- ms
local FEUER_STRIKES_LIMIT = 6    -- so viele zu schnelle Schuesse in Folge, bevor reagiert wird

local letzterSchuss = {}
local feuerStrikes   = {}

addEventHandler ( "onPlayerWeaponFire", getRootElement(), function ( weaponID )
    local adminLevel = tonumber ( MtxGetElementData ( source, "adminlvl" ) ) or 0
    if adminLevel > 0 then return end

    if weaponID == 38 and istInZombieNacht and istInZombieNacht ( source ) then
        return
    end

    if NotAllowedWeapons[weaponID] then
        takeAllWeapons ( source )
        kickPlayer ( source, "Anticheat", "Waffen-Betrug ist nicht erlaubt!" )
        return
    end

    local jetzt = getTickCount ()
    local letzte = letzterSchuss[source]
    letzterSchuss[source] = jetzt

    if not letzte then return end

    if ( jetzt - letzte ) < FEUER_MIN_ABSTAND then
        feuerStrikes[source] = ( feuerStrikes[source] or 0 ) + 1
        if feuerStrikes[source] >= FEUER_STRIKES_LIMIT then
            feuerStrikes[source] = 0
            kickPlayer ( source, "Anticheat", "Unmögliche Feuerrate erkannt (Rapid-Fire/No-Recoil)!" )
        end
    else
        feuerStrikes[source] = 0
    end
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
    letzterSchuss[source] = nil
    feuerStrikes[source]  = nil
end )


setTimer ( function ()
    for _, player in ipairs ( getElementsByType ( "player" ) ) do
        if MtxGetElementData ( player, "loggedin" ) == 1 then
            local adminLevel = tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0
            if adminLevel == 0 then
                local waffe = getPedWeapon ( player )
                if NotAllowedWeapons[waffe] and not ( waffe == 38 and istInZombieNacht and istInZombieNacht ( player ) ) then
                    takeAllWeapons ( player )
                    kickPlayer ( player, "Anticheat", "Waffen-Betrug ist nicht erlaubt!" )
                end
            end
        end
    end
end, 2000, 0 )

local clientDatenErlaubt = {
	["chips"] = true, ["color"] = true, ["DamageBekommen"] = true,
	["DamageGemacht"] = true, ["ElementClicked"] = true, ["i"] = true,
	["heligrab.legsUp"] = true, ["heligrab.linePercent"] = true,
	["heligrab.offsets"] = true, ["heligrab.side"] = true,
	["heligrab.vehicle"] = true, ["inDownload"] = true, ["intchange"] = true,
	["isChatBoxInputActive"] = true, ["kiste"] = true, ["lasthp"] = true,
	["mother"] = true, ["nitro"] = true, ["placeableItemId"] = true,
	["radio:channel"] = true, ["SettingClipDistance"] = true,
	["Settinghdaero"] = true, ["Settinghdreflect"] = true,
	["Settinghdroad"] = true, ["Settinghdwater"] = true,
	["socialState"] = true, ["trunkState"] = true, ["typ"] = true,
	["Wpn2Ammo"] = true, ["Wpn2Norm"] = true,
}


local DATEN_STRIKES_LIMIT  = 25
local DATEN_STRIKES_FENSTER = 10000   -- ms

local datenStrikes = {}
local datenStrikesSeit = {}

addEventHandler ( "onElementDataChange", getRootElement(), function ( schluessel, alterWert )
	if not client or not isElement ( client ) then
		return
	end

	local neuerWert = getElementData ( source, schluessel )
	local wertTyp = type ( neuerWert )
	local wertUngueltig = ( wertTyp ~= "number" and wertTyp ~= "boolean" and wertTyp ~= "string" and not isElement ( neuerWert ) )
		or ( wertTyp == "string" and #neuerWert > 64 )

	if not wertUngueltig and clientDatenErlaubt[schluessel] then
		return
	end
	if ( tonumber ( MtxGetElementData ( client, "adminlvl" ) ) or 0 ) > 0 then
		return
	end

	if isElement ( source ) then
		setElementData ( source, schluessel, alterWert )
	end

	local jetzt = getTickCount ()
	if not datenStrikesSeit[client] or ( jetzt - datenStrikesSeit[client] ) > DATEN_STRIKES_FENSTER then
		datenStrikesSeit[client] = jetzt
		datenStrikes[client] = 0
	end
	datenStrikes[client] = ( datenStrikes[client] or 0 ) + 1

	if datenStrikes[client] == 1 then
		if wertUngueltig then
			meldeAdmins ( getPlayerName ( client ).." setzt ungueltigen Wert-Typ auf '"..tostring ( schluessel ).."' ( "..wertTyp.." )" )
		else
			meldeAdmins ( getPlayerName ( client ).." setzt unerlaubte Element-Daten: '"..tostring ( schluessel ).."'" )
		end
	end

	if datenStrikes[client] >= DATEN_STRIKES_LIMIT then
		local name = getPlayerName ( client )
		datenStrikes[client] = 0
		meldeAdmins ( name.." wurde wegen unerlaubter Datenaenderungen gekickt." )
		kickPlayer ( client, "Anticheat", "Unerlaubte Datenänderungen" )
	end
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	datenStrikes[source] = nil
	datenStrikesSeit[source] = nil
end )


addEventHandler ( "onPlayerConnect", getRootElement(), function ( ni, ip, uni, se, ver )
    local lowerName = string.lower ( ni )
    for _, v in ipairs ( notallowedcharacter ) do
        if string.find ( lowerName, v, 1, true ) then
            cancelEvent ( true, "Es sind keine Sonderzeichen, Farbcodes, Clantags oder Servernamen erlaubt!" )
            break
        end
    end
end )

addEventHandler ( "onResourceStart", resourceRoot, function ()
    setJetpackMaxHeight ( 5000 )
    for _, v in ipairs ( Jetpack ) do
        setJetpackWeaponEnabled ( v, false )
    end
end )


-- ####################################################################
-- NEUESTER STAND: Speedhack-Check ( zuletzt hinzugefuegt )
-- ####################################################################
-- Bewusst NUR zu Fuss (Fahrzeuge haben zu unterschiedliche Top-Speeds -
-- Flugzeug, Zug, Boot, Sportwagen - dafuer liesse sich kein einzelnes
-- sinnvolles Limit finden, ohne staendig legitime Spieler zu kicken).
-- Ausserdem zaehlt ein einzelner riesiger Sprung NICHT als Verstoss - das
-- ist so gut wie immer ein normaler Skript-Teleport (Spawn, Job, Haus,
-- Knast, /tp, ...). Nur wenn die Geschwindigkeit ueber MEHRERE Messungen
-- HINTEREINANDER unrealistisch bleibt, ist das ein Speedhack (Teleports
-- sind einmalige Spruenge, kein Dauerzustand).
local SPEED_CHECK_INTERVALL = 1000   -- ms zwischen zwei Messungen
local SPEED_MAX_PRO_SEKUNDE = 20     -- m/s zu Fuss (Sprint liegt real bei ~7-8 m/s, generoes bemessen)
local SPEED_STRIKES_LIMIT   = 4      -- so viele Messungen IN FOLGE ueber dem Limit, bevor reagiert wird

local letztePosition = {}
local speedStrikes = {}

setTimer ( function ()
    for _, player in ipairs ( getElementsByType ( "player" ) ) do
        if MtxGetElementData ( player, "loggedin" ) == 1 and not isPedDead ( player )
           and not isElementFrozen ( player ) and not getPedOccupiedVehicle ( player )
           and not ( istInZombieNacht and istInZombieNacht ( player ) ) then

            local adminLevel = tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0
            local x, y, z = getElementPosition ( player )
            local alt = letztePosition[player]
            letztePosition[player] = { x, y, z }

            if alt and adminLevel == 0 then
                local distanz = getDistanceBetweenPoints3D ( x, y, z, alt[1], alt[2], alt[3] )
                local maxDistanz = SPEED_MAX_PRO_SEKUNDE * ( SPEED_CHECK_INTERVALL / 1000 )

                if distanz > maxDistanz then
                    speedStrikes[player] = ( speedStrikes[player] or 0 ) + 1
                    if speedStrikes[player] >= SPEED_STRIKES_LIMIT then
                        speedStrikes[player] = 0
                        meldeAdmins ( getPlayerName ( player ).." wurde wegen Speedhack-Verdacht gekickt." )
                        kickPlayer ( player, "Anticheat", "Unmoegliche Laufgeschwindigkeit erkannt (Speedhack)!" )
                    end
                else
                    -- Nur ein einzelner Ausreisser (z.B. Teleport) - kein
                    -- anhaltender Speedhack, Zaehler wird zurueckgesetzt.
                    speedStrikes[player] = 0
                end
            end
        else
            -- Fahrzeug betreten/verlassen, gestorben, eingefroren o.ae.:
            -- Position waere hier ohnehin kein verlaesslicher Vergleichswert.
            letztePosition[player] = nil
            speedStrikes[player] = 0
        end
    end
end, SPEED_CHECK_INTERVALL, 0 )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
    letztePosition[source] = nil
    speedStrikes[source] = nil
end )
