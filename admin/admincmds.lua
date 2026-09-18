--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Table
adminsIngame = {}
local player_admin = {}
local frozen_players = {}
local veh_frozen_players = {}
local veh_frozen_vehs = {}
local muted_players = {}
local Cooldown = {}
local adminLevels = {
    [1] = "#04B404Supporter",
    [2] = "#0000FFModerator",
    [3] = "#D7DF01Adminstrator",
    [4] = "#FF0000Stellv. Projektleiter",
    [5] = "#FF0000Projektleiter",
    [6] = "#FF0000Entwickler",
}

donatorMute = {}
local adminmarks = {}

-- Funktionen

local pack_cmds = {}
pack_cmds["msg"] = true
pack_cmds["pm"] = true

function blockParticularCmds(cmd)
    if pack_cmds[cmd] and MtxGetElementData(source, "adminlvl") < 1 then
        cancelEvent()
        outputChatBox("Benutzung von /msg und /pm ist verboten", source, 135, 206, 250)
    end
end

function blockParticularCmdsJoin()
    addEventHandler("onPlayerCommand", source, blockParticularCmds)
end
addEventHandler("onPlayerJoin", getRootElement(), blockParticularCmdsJoin)


function executeAdminServerCMD_func(cmd, arguments)
    executeCommandHandler(cmd, client, arguments)
end

function doesAnyPlayerOccupieTheVeh(car)
    local bool = false
    for i = 0, 5, 1 do
        local test = getVehicleOccupant(car, i)
        if test ~= false then
            bool = true
        end
    end
    if bool == false then
        return false
    else
        return true
    end
end


function getAdminLevel(player)
    local plevel = MtxGetElementData(player, "adminlvl")
    if not plevel or plevel == nil then
        return 0
    end
    return tonumber(plevel)
end


function isAdminLevel(player, level)
    local plevel = MtxGetElementData(player, "adminlvl")
    if not plevel or plevel == nil then
        return false
    end
    if plevel >= level then
        return true
    else
        return false
    end
end

-- Nimmt auch die Schreibweise aus /pos entgegen ("x=-50.045," wird zu -50.045),
-- damit sich dessen Ausgabe direkt hinter /tpto einfuegen laesst.
local function koordinate ( wert )
    if wert == nil then return nil end
    return tonumber ( ( tostring ( wert ):gsub ( "[^%-%d%.]", "" ) ) )
end

-- Teleportiert den Aufrufer auf feste Koordinaten. Interior und Dimension sind
-- optional und bleiben ohne Angabe unveraendert. Gegenstueck zu /pos.
addCommandHandler ( "tpto", function ( player, cmd, x, y, z, int, dim )
    if not isAdminLevel ( player, 6 ) then
        triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255 )
        return
    end

    x, y, z = koordinate ( x ), koordinate ( y ), koordinate ( z )
    if not x or not y or not z then
        outputChatBox ( "Gebrauch: /tpto x y z [interior] [dimension]", player, 200, 200, 0 )
        outputChatBox ( "Die Ausgabe von /pos kann direkt eingefuegt werden.", player, 200, 200, 0 )
        return
    end

    int = koordinate ( int ) or getElementInterior ( player )
    dim = koordinate ( dim ) or getElementDimension ( player )

    -- Als Fahrer kommt das Fahrzeug mit, als Beifahrer steigt man vorher aus.
    local ziel = player
    if getPedOccupiedVehicleSeat ( player ) == 0 then
        ziel = getPedOccupiedVehicle ( player )
    elseif isPedInVehicle ( player ) then
        removePedFromVehicle ( player )
    end

    setElementPosition ( ziel, x, y, z )
    setElementInterior ( ziel, int )
    setElementDimension ( ziel, dim )

    if ziel ~= player then
        setElementInterior ( player, int )
        setElementDimension ( player, dim )
        setElementVelocity ( ziel, 0, 0, 0 )
        setElementFrozen ( ziel, true )
        setTimer ( setElementFrozen, 500, 1, ziel, false )
    end

    outputChatBox ( string.format ( "Teleportiert nach x=%.3f, y=%.3f, z=%.3f, int=%d, dim=%d", x, y, z, int, dim ), player, 0, 200, 0 )
    outputAdminLog ( getPlayerName ( player ) .. " hat sich nach " .. string.format ( "%.2f, %.2f, %.2f (int %d, dim %d)", x, y, z, int, dim ) .. " teleportiert!" )
end )

-- Gibt die eigene Position (fuer z.B. Kamerapunkte in intro_cutscene_client.lua) im Chat aus.
addCommandHandler ( "pos", function ( player )
    if isAdminLevel ( player, 6 ) then
        local x, y, z = getElementPosition ( player )
        local int = getElementInterior ( player )
        local dim = getElementDimension ( player )
        local _, _, rz = getElementRotation ( player )
        outputChatBox ( string.format ( "x=%.3f, y=%.3f, z=%.3f, int=%d, dim=%d", x, y, z, int, dim ), player, 0, 200, 0 )
        -- Blickrichtung: fuer Objekte wie die Fraktionstresore, die zur Wand
        -- ausgerichtet werden muessen.
        outputChatBox ( string.format ( "rot=%.1f", rz ), player, 0, 200, 0 )
    end
end )


function adminMenueTrigger_func()
    if source == client then
        if ( tonumber ( MtxGetElementData(source, "adminlvl") ) or 0 ) >= 1 then
            triggerClientEvent(source, "PListFill", getRootElement())
        else
            triggerClientEvent(source, "infobox_start", getRootElement(), "\nDu bist kein\nAdmin!", 5000, 135, 206, 250)
        end
    end
end

function nickchange_func(player, cmd, alterName, neuerName)
    if alterName and neuerName then
        if isAdminLevel(player, 3) then
            if alterName then
                if playerUID[alterName] then
                    local UID = playerUID[alterName]
                    local result2 = dbQueryCoro("SELECT ?? FROM ?? WHERE ?? LIKE ?", "Name", "players", "Name", neuerName)
                    if not result2 or not result2[1] then
                        dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "players", "Name", neuerName, "UID", UID)
						dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Name", neuerName, "UID", UID)
						dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "promotion", "Username", neuerName,"Username",alterName)
						dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "clothes", "Name", neuerName,"Name",alterName)
                        playerUID[neuerName] = playerUID[alterName]
                        playerUID[alterName] = nil

                        if allPrivateCars[alterName] then
                            allPrivateCars[neuerName] = allPrivateCars[alterName]
                            allPrivateCars[alterName] = nil
                            for slot, veh in pairs(allPrivateCars[neuerName]) do
                                if isElement(veh) then
                                    MtxSetElementData(veh, "owner", neuerName)
                                end
                            end
                        end

                        outputAdminLog(getPlayerName(player) .. " hat " .. alterName .. " in " .. neuerName .. " umbenannt.")
                        outputChatBox("Du hast den Spieler " .. alterName .. " in " .. neuerName .. " umbenannt!", player, 135, 206, 250)
                    else
                        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDer neue Name\nist bereits\nvergeben!", 7500, 135, 206, 250)
                    end
                else
                    triggerClientEvent(player, "infobox_start", getRootElement(), "\nDer Spieler\nexistiert nicht!", 7500, 135, 206, 250)
                end
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\nDer Spieler ist\nnoch eingeloggt!", 7500, 135, 206, 250)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist\nkein Admin!", 7500, 135, 206, 250)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/nickchange aName nName", 7500, 135, 206, 250)
    end
end

function move_func(player, cmd, direction)
    if direction then
        if (not client or client == player) then
            if isAdminLevel(player, 1) then
                local veh = getPedOccupiedVehicle(player)
                local element = player
                if isElement(veh) then
                    element = veh
                end
                local x, y, z = getElementPosition(element)
                if direction == "up" then
                    y = y + 2
                elseif direction == "down" then
                    y = y - 2
                elseif direction == "left" then
                    x = x - 2
                elseif direction == "right" then
                    x = x + 2
                elseif direction == "higher" then
                    z = z + 2
                elseif direction == "lower" then
                    z = z - 2
                end
                setElementPosition(element, x, y, z)
            else
				triggerClientEvent(player, "infobox_start", getRootElement(), "Du bist kein Admin", 7500, 135, 206, 250)
            end
        else
            outputChatBox("Richtungen: up, down, left, right, higher, lower", player, 135, 206, 250)
			triggerClientEvent(player, "infobox_start", getRootElement(), "Bitte Richtung angeben!", 7500, 135, 206, 250)
        end
    end
end


function moveVehicleAway_func(veh)
    if veh and getElementType(veh) == "vehicle" then
		if isAdminLevel(client, 1) then
			setElementPosition(veh, 999999, 999999, 999999)
			setElementInterior(veh, 999999)
			setElementDimension(veh, 65535)
		 end
	end
end



function pwchange_func(player, cmd, target, newPW)
    if getElementType(player) == "console" or isAdminLevel(player, 3) then
        if newPW and target then
            dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "players", "Passwort", hash("sha512", hash("sha512", newPW)), "UID", playerUID[target])
            outputChatBox("Passwort geändert!", player, 0, 125, 0)
            outputAdminLog(getPlayerName(player) .. " hat das Passwort von " .. target .. " geändert!")
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/pwchange Name PW", 7500, 135, 206, 250)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist\nnicht befugt!", 7500, 135, 206, 250)
    end
end



function shut_func(player)
    if isAdminLevel(player, 4) then
        outputAdminLog(getPlayerName(player) .. " hat die Notabschaltung benutzt.")
        shutdown("Abgeschaltet von: " .. getPlayerName(player))
        setServerPassword("hurensohn")
        local players = getElementsByType("player")
        for i = 1, #players do
            kickPlayer(players[i], player, "Notabschaltung! Für mehr Informationen melde dich im Teamspeak!")
        end
    end
end



function rebind_func(player)
    if isKeyBound(player, "r", "down", reload) then
        unbindKey(player, "r", "down", reload)
    end
    bindKey(player, "r", "down", reload)
    outputChatBox("Hotkeys wurden neu gelegt!", player, 135, 206, 250)
end


function adminlist(player)
if MtxGetElementData ( player, "loggedin" ) == 1 then
    outputChatBox("Momentan stehen dir diese Teammitglieder zur Verfügung:", player, 0, 100, 255)
	for key, index in pairs (getElementsByType("player")) do
			if MtxGetElementData(index,"adminlvl") == 1 then
				outputChatBox("#ffffff"..getPlayerName(index).. " #04B404[Supporter]",player,160,160,0,true)
			elseif MtxGetElementData(index,"adminlvl") == 2 then
				outputChatBox("#ffffff"..getPlayerName(index).. " #0000FF[Moderator]",player,0,85,255,true)
			elseif MtxGetElementData(index,"adminlvl") == 3 then
				outputChatBox("#ffffff"..getPlayerName(index).. " #D7DF01[Administrator]",player,0,150,0,true)
			elseif MtxGetElementData(index,"adminlvl") == 4 then
				outputChatBox("#ffffff"..getPlayerName(index).. " #FF0000[Stv.Projektleiter]",player,200,85,0,true)
			elseif MtxGetElementData(index,"adminlvl") == 5 then
				outputChatBox("#ffffff"..getPlayerName(index).. " #FF0000[Projektleiter]",player,200,0,0,true)
			elseif MtxGetElementData(index,"adminlvl") == 6 then
				outputChatBox("#ffffff"..getPlayerName(index).. " #FF0000[Entwickler]",player,200,0,0,true)
			end
		end
	end
end

function check_func(admin, cmd, target)
    if isAdminLevel(admin, 3) then
        if target then
            local player = findPlayerByName(target)
            if player then
                local playtime = MtxGetElementData(player, "playingtime")
                local playtimehours = math.floor(playtime / 60)
                local playtimeminutes = playtime - playtimehours * 60
                local playtime = playtimehours .. ":" .. playtimeminutes
                outputChatBox("Name: " .. getPlayerName(player) .. " ( ID: " .. MtxGetElementData(player, "playerid") .. " ), Geld ( Bar/Bank ): " .. MtxGetElementData(player, "money") .. "/" .. MtxGetElementData(player, "bankmoney") .. ", Spielzeit: " .. playtime .. " Minuten", admin, 200, 200, 0)
                outputChatBox(" Warns: " .. getPlayerWarnCount(getPlayerName(player)) .. ", Telefonnr: " .. MtxGetElementData(player, "telenr"), admin, 200, 200, 0)
                outputChatBox("Tode: " .. MtxGetElementData(player, "GangwarTode") .. ", Kills: " .. MtxGetElementData(player, "GangwarKills") .. ", Drogen: " .. MtxGetElementData(player, "drugs") .. ", Materials: " .. MtxGetElementData(player, "mats"), admin, 200, 200, 0)
                local fraktion = tonumber(MtxGetElementData(player, "fraktion"))
                fraktion = fraktionNames[fraktion]
                outputChatBox("Gefundene Paeckchen: " .. MtxGetElementData(player, "foundpackages") .. "/25", admin, 200, 200, 0)
                outputChatBox("Fraktion: " .. fraktion .. ", AdminLVL: " .. MtxGetElementData(player, "adminlvl") .. ", Bonuspunkte: " .. MtxGetElementData(player, "bonuspoints"), admin, 200, 200, 0)
                local pname = getPlayerName(player)
                local licenses = ""
                if MtxGetElementData(player, "carlicense") == 1 then licenses = licenses .. "Fuehrerschein " end
                if MtxGetElementData(player, "bikelicense") == 1 then licenses = licenses .. "Motorradschein " end
                if MtxGetElementData(player, "fishinglicense") == 1 then licenses = licenses .. "Angelschein " end
                if MtxGetElementData(player, "lkwlicense") == 1 then licenses = licenses .. "LKW-Fuehrerschein " end
                if MtxGetElementData(player, "gunlicense") == 1 then licenses = licenses .. "Waffenschein " end
                if MtxGetElementData(player, "motorbootlicense") == 1 then licenses = licenses .. "Bootsfuehrerschein " end
                if MtxGetElementData(player, "segellicense") == 1 then licenses = licenses .. "Segelschein " end
                if MtxGetElementData(player, "planelicenseb") == 1 then licenses = licenses .. "Flugschein A " end
                if MtxGetElementData(player, "planelicensea") == 1 then licenses = licenses .. "Flugschein B " end
                if MtxGetElementData(player, "helilicense") == 1 then licenses = licenses .. "Flugschein C " end
                outputChatBox("Vorhandene Lizenzen: ", admin, 200, 0, 200)
                outputChatBox(licenses, admin, 200, 50, 200)
                executeCommandHandler("getchangestate", admin, getPlayerName(player))
                outputChatBox("IP: " .. getPlayerIP(player), admin, 200, 200, 0)
                outputChatBox("Aktuelle Waffe: " .. getPedWeapon(player), admin, 125, 125, 125)
            else
                triggerClientEvent(admin, "infobox_start", getRootElement(), "\n\nUngueltiger Name!", 7500, 125, 0, 0)
            end
        else
            triggerClientEvent(admin, "infobox_start", getRootElement(), "\nGebrauch:\n/check Name!", 7500, 125, 0, 0)
        end
    else
        triggerClientEvent(admin, "infobox_start", getRootElement(), "\n\nDu bist kein\n Admin!", 7500, 125, 0, 0)
    end
end



function mark_func(player, cmd, count)
    if isAdminLevel(player, 1) then
        if not count or tonumber(count) == nil then
            count = 1
        end
        count = tonumber(count)
        if count ~= 1 and count ~= 2 and count ~= 3 then
            outputChatBox("Es sind nur Marker 1, 2 und 3 möglich!", player, 0, 0, 0)
            return
        end
        local x, y, z = getElementPosition(player)
        local int = getElementInterior(player)
        local dim = getElementDimension(player)
        if not adminmarks[player] then
            adminmarks[player] = {}
        end
        adminmarks[player][count] = { ["x"] = x, ["y"] = y, ["z"] = z, ["dim"] = dim, ["int"] = int }
        outputChatBox("Koordinaten für Marker " .. count .. " gesetzt!", player, 0, 0, 0)
    end
end


function gotomark_func(player, cmd, count)
    if isAdminLevel(player, 1) then
        if not count or tonumber(count) == nil then
            count = 1
        end
        count = tonumber(count)
        if count ~= 1 and count ~= 2 and count ~= 3 then
            outputChatBox("Es sind nur Marker 1, 2 und 3 möglich!", player, 0, 0, 0)
            return
        end
        if not adminmarks[player] then
            adminmarks[player] = {}
        end
        if not adminmarks[player][count] then
            outputChatBox("Marker existiert nicht!", player, 0, 0, 0)
            return
        end
        local x, y, z, dim, int = adminmarks[player][count]["x"], adminmarks[player][count]["y"], adminmarks[player][count]["z"], adminmarks[player][count]["dim"], adminmarks[player][count]["int"]
        local seat = getPedOccupiedVehicleSeat(player)
        if seat then
            if seat == 0 then
                local veh = getPedOccupiedVehicle(player)
                setElementPosition(veh, x, y, z)
                setElementDimension(veh, dim)
                setElementInterior(veh, int)
                setElementDimension(player, int)
                setElementInterior(player, dim)
                outputChatBox("Zum " .. count .. ". Marker teleportiert!", player, 0, 0, 0)
                return
            end
        end
        removePedFromVehicle(player)
        setElementPosition(player, x, y, z)
        setElementDimension(player, dim)
        setElementInterior(player, int)
        outputChatBox("Zum " .. count .. ". Marker teleportiert!", player, 0, 0, 0)
    end
end


function respawn_func(player, cmd, respawn)
    local bool = false
    local boole = false
    if respawn then
        if player == "none" or (isElement(player) and isAdminLevel(player, 2)) then
            if respawn == "fishing" then
                for i = 1, 9 do
                    if not getVehicleOccupant(fishReefer[i]) then
                        respawnVehicle(fishReefer[i])
                        setElementDimension(fishReefer[i], 0)
                        setElementInterior(fishReefer[i], 0)
                    end
                end
            elseif respawn == "sfpd" then
                for veh, _ in pairs(factionVehicles[1]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "terror" then
                for veh, _ in pairs(factionVehicles[4]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "mafia" then
                for veh, _ in pairs(factionVehicles[2]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "triaden" then
                for veh, _ in pairs(factionVehicles[3]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "news" then
                for veh, _ in pairs(factionVehicles[5]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "fbi" then
                for veh, _ in pairs(factionVehicles[6]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "hotdog" then
                for i = 1, #hotdogVehicles do
                    if not getVehicleOccupant(hotdogVehicles[i]) then
                        respawnVehicle(hotdogVehicles[i])
                    end
                end
            elseif respawn == "aztecas" then
                for veh, _ in pairs(factionVehicles[7]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "bundeswehr" then
                for veh, _ in pairs(factionVehicles[8]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
                if not getVehicleOccupant(bundeswehrAC130) then
                    destroyElement(bundeswehrAC130)
                    ac130()
                end
            elseif respawn == "biker" then
                for veh, _ in pairs(factionVehicles[9]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "oamt" then
                for veh, _ in pairs(factionVehicles[11]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "medic" then
                for veh, _ in pairs(factionVehicles[10]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "grove" then
                for veh, _ in pairs(factionVehicles[12]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            elseif respawn == "ballas" then
                for veh, _ in pairs(factionVehicles[13]) do
                    if not getVehicleOccupant(veh) then
                        respawnVehicle(veh)
                    end
                end
            else
                if player ~= "none" then outputChatBox("/respawn [sfpd|medic|oamt|mafia|triaden|news|terror|fbi|aztecas|bundeswehr|biker|grove|ballas|fishing|hotdog]", player, 125, 0, 0) end
                boole = true
            end
            if not boole then
                if player ~= "none" then outputChatBox("Fahrzeuge respawned!", player, 0, 125, 0) end
            end
        else
            triggerClientEvent(player, "infobox_start", player, "\n\nDu bist nicht\nautorisiert!", 5000, 125, 0, 0)
        end
    else
        outputChatBox("/respawn [sfpd|medic|oamt|mafia|triaden|news|terror|fbi|aztecas|bundeswehr|biker|grove|ballas|fishing|hotdog]", player, 125, 0, 0)
    end
end


function tunecar_func(player, cmd, part)
    if isAdminLevel(player, 3) then
        if part and tonumber(part) then
            succes = addVehicleUpgrade(getPedOccupiedVehicle(player), tonumber(part))
            outputAdminLog(getPlayerName(player) .. " hat ein Auto upgegradet!")
            if succes == false then
                outputChatBox("Ungueltige Eingabe/Fahrzeug!", player, 125, 0, 0)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nGebrauch:\n/tunecar [Part]", 7500, 125, 0, 0)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nDu bist nicht\nautorisiert!", 5000, 125, 0, 0)
    end
end


function freezeshit()
    setElementFrozen(source, true)
    setElementFrozen(veh_frozen_vehs[getPlayerName(source)], false)
end


function cancelWeaponShit()
    setPedWeaponSlot(source, 0)
end


function freeze_func(player, cmd, target)
    local fix
    if isAdminLevel(player, 1) then
        if target then
            target = findPlayerByName(target)
            if target then
                if frozen_players[getPlayerName(target)] then
                    setElementFrozen(target, false)
                    frozen_players[getPlayerName(target)] = false
                    removeEventHandler("onPlayerWeaponSwitch", target, cancelWeaponShit)
                    outputChatBox("Du hast " .. getPlayerName(target) .. " entfreezed!", player, 0, 125, 0)
                    outputChatBox("Du wurdest von " .. getPlayerName(player) .. " entfreezed!", target, 0, 125, 0)
                    return
                end
                if veh_frozen_players[getPlayerName(target)] then
                    setElementFrozen(target, false)
                    veh_frozen_players[getPlayerName(target)] = false
                    removeEventHandler("onPlayerWeaponSwitch", target, cancelWeaponShit)
                    setElementFrozen(veh_frozen_vehs[getPlayerName(target)], false)
                    veh_frozen_vehs[getPlayerName(target)] = false
                    removeEventHandler("onPlayerVehicleExit", target, freezeshit)
                    outputChatBox("Du hast " .. getPlayerName(target) .. " entfreezed!", player, 0, 125, 0)
                    outputChatBox("Du wurdest von " .. getPlayerName(player) .. " entfreezed!", target, 0, 125, 0)
                    return
                end
                local veh = getPedOccupiedVehicle(target)
                if veh then
                    setElementFrozen(veh, true)
                    veh_frozen_players[getPlayerName(target)] = true
                    veh_frozen_vehs[getPlayerName(target)] = veh
                    addEventHandler("onPlayerWeaponSwitch", target, cancelWeaponShit)
                    setPedWeaponSlot(target, 0)
                    addEventHandler("onPlayerVehicleExit", target, freezeshit)
                    addEventHandler("onPlayerQuit", target,
                        function()
                            setElementFrozen(veh_frozen_vehs[getPlayerName(source)], false)
                            veh_frozen_players[getPlayerName(source)] = false
                            veh_frozen_vehs[getPlayerName(source)] = false
                        end)
                else
                    setElementFrozen(target, true)
                    frozen_players[getPlayerName(target)] = true
                    addEventHandler("onPlayerWeaponSwitch", target, cancelWeaponShit)
                    setPedWeaponSlot(target, 0)
                    addEventHandler("onPlayerQuit", target,
                        function()
                            frozen_players[getPlayerName(source)] = false
                        end)
                end
                outputChatBox("Du hast " .. getPlayerName(target) .. " gefreezed!", player, 0, 125, 0)
                outputChatBox("Du wurdest von " .. getPlayerName(player) .. " gefreezed!", target, 0, 125, 0)
                outputAdminLog(getPlayerName(player) .. " hat " .. getPlayerName(target) .. " gefreezet!")
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/freeze NAME!", 5000, 125, 0, 0)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nDu bist nicht\nautorisiert!", 5000, 125, 0, 0)
    end
end


function intdim(player, cmd, target, int, dim)
    if isAdminLevel(player, 2) then
        if target then
            local target = findPlayerByName(target)
            if not isElement(target) then
                outputChatBox("Der Spieler ist offline!", player, 125, 0, 0)
                return
            end
            if int and tonumber(int) ~= nil and dim and tonumber(dim) ~= nil then
                setElementInterior(target, tonumber(int))
                setElementDimension(target, tonumber(dim))
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/intdim NAME INT DIM!", 5000, 125, 0, 0)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/intdim NAME INT DIM!", 5000, 125, 0, 0)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nDu bist nicht\nautorisiert!", 5000, 125, 0, 0)
    end
end


function cleartext_func(player)
    if getElementType(player) == "console" or isAdminLevel(player, 2) then
        for i = 1, 50 do
            outputChatBox(" ")
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nDu bist nicht\nautorisiert!", 5000, 125, 0, 0)
    end
end


function kickPlayerGMX(player)
    kickPlayer(player, "Serverrestart")
end

function restartNow()
    local resource = getResourceFromName(""..Tables.servername.."")
    elementData = nil
    restartResource(resource)
end

function restartServer()

    local btime = getRealTime()
    local bmonth = btime.month
    local bday = btime.monthday
    local bhour = btime.hour
    local bminute = btime.minute
    local bsecond = btime.second
	
    i = 0

    for id, playeritem in ipairs(getElementsByType("player")) do
        i = i + 1
        setTimer(kickPlayerGMX, 50 + 100 * i, 1, playeritem)
    end

    setTimer(restartNow, 100 + 200 * i, 1)
end

function gmx_func(player, cmd, minutes)

    if getElementType(player) == "console" then
        MtxSetElementData(player, "adminlvl", 5)
    end

    if isAdminLevel(player, 5) then

        outputAdminLog(getPlayerName(player) .. " hat den Server neu gestartet.")
        if not tonumber(minutes) then minutes = 1 end

        setTimer(restartServer, minutes * 60000, 1)
        outputChatBox("Server wird in " .. minutes .. " Minuten neu gestartet.", getRootElement(), 125, 0, 0)

        local btime = getRealTime()
        local bmonth = btime.month
        local bday = btime.monthday
        local bhour = btime.hour
        local bminute = btime.minute
        local bsecond = btime.second
        outputServerLog(bday .. "." .. bmonth .. ", " .. bhour .. ":" .. bminute .. ":" .. bsecond .. " - " .. getPlayerName(player) .. " hat den Server neu gestartet!")
    end
end

-- Gemeinsame Vorpruefung fuer /ochat und /achat: Adminrechte + eingeloggt,
-- und ob ueberhaupt Text uebergeben wurde. table.concat({...}, " ") liefert
-- bei leeren Parametern "" zurueck, niemals nil - der fruehere Vergleich
-- "== nil" griff deshalb nie, die Hinweismeldung erschien nie.
local function adminChatVorbereiten ( player, parametersTable )
    if not ( isAdminLevel ( player, 1 ) and MtxGetElementData ( player, "loggedin" ) == 1 ) then
        triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist\nkein Admin!", 5000, 125, 0, 0 )
        return nil
    end

    local text = table.concat ( parametersTable, " " )
    if text == "" then
        triggerClientEvent ( player, "infobox_start", getRootElement(), "\nBitte einen\nText eingeben!", 5000, 125, 0, 0 )
        return nil
    end

    local rang = MtxGetElementData ( player, "adminlvl" )
    return text, adminLevels[rang]
end

-- Eigene Farbthemen je Kanal, damit auf den ersten Blick klar ist, welcher
-- Chat das ist, ohne den Text lesen zu muessen: Gold fuer den serverweiten
-- Ochat, Cyan fuer den nur-Admin-internen Achat. Die eingebetteten #RRGGBB-
-- Codes wechseln bei outputChatBox( ..., true ) die Farbe MITTEN im Text -
-- vorher stand dort z.B. "#FFFFFF" direkt nach der ohnehin schon weissen
-- Grundfarbe, was also gar keinen sichtbaren Unterschied machte.
function ochat_func(player, cmd, ...)
    local text, rank = adminChatVorbereiten ( player, { ... } )
    if not text then return end

    outputChatBox ( "#FFD700[Serverchat] #FFA500" .. rank .. " #FFD700" .. getPlayerName(player) ..
                    "#FFFFFF: " .. text, getRootElement(), 255, 215, 0, true )
end

function achat_func(player, cmd, ...)
    local text, rank = adminChatVorbereiten ( player, { ... } )
    if not text then return end

    local nachricht = "#00BFFF[Adminchat] #1E90FF" .. rank .. " #00BFFF" .. getPlayerName(player) ..
                       "#FFFFFF: " .. text

    for playeritem, index in pairs ( adminsIngame ) do
        if isElement ( playeritem ) and index >= 1 then
            outputChatBox ( nachricht, playeritem, 0, 191, 255, true )
        end
    end
end

function setrank_func(player, cmd, target, rank)
    if target then
        if rank then
            local targetpl = findPlayerByName(target)
            local rank = math.floor(math.abs(tonumber(rank)))
            if isAdminLevel(player, 2) then
                if isElement(targetpl) then
                    if rank <= 6 then
                        MtxSetElementData(targetpl, "rang", rank)
                        local frac = MtxGetElementData(targetpl, "fraktion")
                        fraktionMemberList[frac][getPlayerName(targetpl)] = rank
                        outputChatBox("Admin " .. getPlayerName(player) .. " hat deinen Rank auf " .. rank .. " gesetzt!", targetpl, 100, 149, 237)
                        outputChatBox("Rang gesetzt!", player, 0, 125, 0)
                        outputAdminLog(getPlayerName(player) .. " hat " .. getPlayerName(targetpl) .. "s Rang auf " .. rank .. " gesetzt!")
                        for playeritem, _ in pairs(fraktionMembers[frac]) do
                            triggerClientEvent(playeritem, "syncPlayerList", player, fraktionMemberList[frac], fraktionMemberListInvite[frac])
                        end
                    else
                        triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/setrank [Name] [Rang]", 5000, 100, 149, 237)
                    end  
                elseif playerUID[target] then
                    local frac = tonumber((dbQueryCoro("SELECT ?? FROM ?? WHERE ??=?", "Fraktion", "userdata", "UID", playerUID[target]))[1]["Fraktion"]) or 0
                    if frac > 0 then
                        dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "FraktionsRang", rank, "UID", playerUID[target])
                        fraktionMemberList[frac][target] = rank
                        offlinemsg("Du wurdest von " .. getPlayerName(player) .. " auf Rang " .. rank .. " gesetzt.", "Server", target)
                        outputChatBox("Rang gesetzt (offline)!", player, 100, 149, 237)
                        outputAdminLog(getPlayerName(player) .. " hat " .. target .. "s Rang offline auf " .. rank .. " gesetzt!")
                        for playeritem, _ in pairs(fraktionMembers[frac]) do
                            triggerClientEvent(playeritem, "syncPlayerList", player, fraktionMemberList[frac], fraktionMemberListInvite[frac])
                        end
                    else
                        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDer Spieler\nist Zivilist!", 5000, 100, 149, 237)
                    end
                else
                    triggerClientEvent(player, "infobox_start", getRootElement(), "\nSpieler\nexistiert nicht!", 5000, 100, 149, 237)
                end
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 100, 149, 237)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/setrank NAME RANG", 5000, 100, 149, 237)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/setrank NAME RANG", 5000, 100, 149, 237)
    end
end

function makeleader_func(player, cmd, target, fraktion)
    if target then
        local targetpl = findPlayerByName(target)
        if fraktion then
            fraktion = math.floor(math.abs(tonumber(fraktion)))
            if isAdminLevel(player, 2) then
                if not isElement(targetpl) then
                    if playerUID[target] then
                        local oldfrac = tonumber((dbQueryCoro("SELECT ?? FROM ?? WHERE ??=?", "Fraktion", "userdata", "UID", playerUID[target]))[1]["Fraktion"]) or 0
                        dbExec(handler, "UPDATE ?? SET ??=?, ??=? WHERE ??=?", "userdata", "FraktionsRang", 5, "Fraktion", fraktion, "UID", playerUID[target])
                        fraktionMemberList[oldfrac][target] = nil
                        fraktionMemberList[fraktion][target] = 5
                        if oldfrac ~= fraktion then
                            fraktionMemberListInvite[oldfrac][target] = nil
                            fraktionMemberListInvite[fraktion][target] = timestampOptical()
                        end

                    else
                        triggerClientEvent(player, "infobox_start", getRootElement(), "\nSpieler existiert\nnicht!", 5000, 0, 125, 125)
                    end
                else
                    if MtxGetElementData(targetpl, "loggedin") == 1 then
                        if fraktion >= 0 then
                            local oldfrac = MtxGetElementData(targetpl, "fraktion")
                            local targetname = getPlayerName(targetpl)
                            if oldfrac >= 0 and oldfrac <= #fraktionNames + 1 then
                                fraktionMembers[oldfrac][targetpl] = nil
                                fraktionMemberList[oldfrac][targetname] = nil
                                fraktionMemberListInvite[oldfrac][targetname] = nil
                            end
                            if fraktion == 0 then
                                MtxSetElementData(targetpl, "rang", 0)
                                outputChatBox("Du wurdest soeben zum Zivilisten gemacht.", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Zivilisten gemacht.")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 1 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du wurdest soeben zum Polizeichief ernannt! Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Polizeichief ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 2 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun Don der Cosa Nostra - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Don ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 3 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun das Oberhaupt der Triaden - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Triadenboss ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 4 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun der Fuehrer der Terroristen - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Revolutionsführer ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 5 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun der Chefredakteur der San News - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Chefredakteur ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 6 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun der Direktor des Federal Bureau of Investigation - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum FBI-Direktor ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 7 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun der Boss der Los Aztecas - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Jefa ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 8 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun der Commander der Bundeswehr - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Commander ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 9 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun der President der Angels of Death - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum President der AoD ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 10 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun der Chefarzt der Sanitäter - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Chefarzt der Sanitäter ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 11 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun der Chef der Mechaniker - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Chef der Mechaniker ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 12 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun der Banger der Ballas - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Banger der Ballas ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 13 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun Leiter der Grove - Für mehr Infos öffne das Hilfemenue!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Sweet der Grove ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            elseif fraktion == 14 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun President der Anonymus! - Glückwunsch!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum President der Anonymus ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
							 elseif fraktion == 15 then
                                MtxSetElementData(targetpl, "rang", 5)
                                outputChatBox("Du bist nun der Leader von der Fahrschule!", targetpl, 0, 125, 0)
                                outputAdminLog(getPlayerName(player) .. " hat " .. targetname .. " zum Leader der Fahrschule ernannt!")
                                dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LastFactionChange", timestampOptical(), "UID", playerUID[targetname])
                            else
                                infobox(player, "Die Fraktion\nexistiert nicht!", 4000, 200, 0, 0)
                                return
                            end
                            MtxSetElementData(targetpl, "fraktion", fraktion)
                            triggerClientEvent(targetpl, "triggeredBlacklist", targetpl, blacklistPlayers[fraktion])
                            if fraktion ~= 0 then
                                fraktionMembers[fraktion][targetpl] = fraktion
                                fraktionMemberList[fraktion][getPlayerName(targetpl)] = 5
                                if oldfrac ~= fraktion then
                                    fraktionMemberListInvite[fraktion][getPlayerName(targetpl)] = timestampOptical()
                                    for playeritem, _ in pairs(fraktionMembers[oldfrac]) do
                                        triggerClientEvent(playeritem, "syncPlayerList", player, fraktionMemberList[oldfrac], fraktionMemberListInvite[oldfrac])
                                    end
                                end
                                for playeritem, _ in pairs(fraktionMembers[fraktion]) do
                                    triggerClientEvent(playeritem, "syncPlayerList", player, fraktionMemberList[fraktion], fraktionMemberListInvite[fraktion])
                                end
                            end
                            if oldfrac > 0 then
                                unbindKey(targetpl, "y", "down", "chatbox")
                            end
                            bindKey(targetpl, "y", "down", "chatbox", "t")
                            triggerClientEvent("aktualisiereMemberTabelle", player, fraktionMembersOffOn, zeitTable)
                            for playeritem, key in pairs(adminsIngame) do
                                if key >= 2 then
                                    outputChatBox(getPlayerName(player) .. " hat " .. getPlayerName(targetpl) .. " zum Leader von Fraktion " .. fraktion .. " gemacht!", playeritem, 255, 255, 0)
                                end
                            end
                        else
                            triggerClientEvent(player, "infobox_start", getRootElement(), "\nUngueltige\nFraktions-ID!", 5000, 0, 125, 125)
                        end
                    else
                        triggerClientEvent(player, "infobox_start", getRootElement(), "\nSpieler ist\nnicht eingeloggt!", 5000, 0, 125, 125)
                    end
                end
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/makeleader NAME FRAKTION.", 5000, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/makeleader NAME FRAKTION.", 5000, 0, 191, 255)
    end
end


function adminlevel_func(player, cmd, target, adminlevel)
    -- Gueltiger Bereich ist 0 bis ADMIN_MAX_LEVEL ( 6 = Entwickler ). Vorher gab
    -- es keine Obergrenze: /adminlevel Name 99 schrieb die 99 in die Datenbank.
    local stufe = tonumber(adminlevel)
    if stufe and (stufe < 0 or stufe > ADMIN_MAX_LEVEL or stufe ~= math.floor(stufe)) then
        outputChatBox("Das Adminlevel muss zwischen 0 und " .. ADMIN_MAX_LEVEL .. " liegen.", player, 255, 0, 0)
        return
    end

    if isAdminLevel(player, 5) then
        local tplayer = getPlayerFromName(target)
        if MtxGetElementData(tplayer, "loggedin") == 1 then
            if getAdminLevel(player) > getAdminLevel(tplayer) then
                if tonumber(adminlevel) and target then
                    local zielExistiert = dbQueryCoro("SELECT ?? FROM ?? WHERE ??=?", "UID", "userdata", "Name", target)
                    if zielExistiert and zielExistiert[1] then
                        local adminlevelnr = tonumber(adminlevel)
                        dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Adminlevel", adminlevelnr, "UID", playerUID[target])
                        MtxSetElementData(tplayer, "adminlvl", adminlevelnr)
                        outputLog(getPlayerName(player) .. " hat den Adminrang von " .. target .. " auf " .. adminlevel .. " gesetzt.", "admin")
                        for playeritem, key in pairs(adminsIngame) do
                            outputChatBox(getPlayerName(player) .. " hat das Adminlevel von " .. target .. " auf " .. (adminLevels[adminlevelnr] or "#FFFFFFkein Admin") .. "#C8C800 gesetzt.", playeritem, 200, 200, 0, true)
                        end
                    else
                        triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nSpieler existiert nicht!", 5000, 255, 0, 0)
                    end
                else
                    triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nVerwende: /adminlevel [Name] [Level]", 5000, 0, 125, 125)
                end
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nHöherer Admin!", 5000, 255, 0, 0)
            end
        else
            if tonumber(adminlevel) and target then
                local zielExistiert = dbQueryCoro("SELECT ?? FROM ?? WHERE ??=?", "UID", "userdata", "Name", target)
                if zielExistiert and zielExistiert[1] then
                    local adminlevelnr = tonumber(adminlevel)
                    dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Adminlevel", adminlevelnr, "UID", playerUID[target])
                    outputLog(getPlayerName(player) .. " hat den Adminrang von " .. target .. " auf " .. adminlevel .. " gesetzt.", "admin")
                    for playeritem, key in pairs(adminsIngame) do
                        outputChatBox(getPlayerName(player) .. " hat das Adminlevel von " .. target .. " auf " .. (adminLevels[adminlevelnr] or "#FFFFFFkein Admin") .. "#C8C800 gesetzt.", playeritem, 200, 200, 0, true)
                    end
                else
                    triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nSpieler existiert nicht!", 5000, 255, 0, 0)
                end
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nVerwende: /adminlevel [Name] [Level]", 5000, 0, 125, 125)
            end
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist\nnicht befugt!", 7500, 125, 0, 0)
    end
end

local oldspecpos = {}
function spec_func(player, command, spec)
    if isAdminLevel(player, 1) then
        local spec = spec and findPlayerByName(spec) or nil
        if spec == nil then
            if oldspecpos[player] then
                setElementInterior(player, oldspecpos[player][2])
                setElementDimension(player, oldspecpos[player][1])
                oldspecpos[player] = nil
            end
            fadeCamera(player, true)
            setCameraTarget(player, player)
            setElementFrozen(player, false)
        elseif spec then
            setElementFrozen(player, true)
            local dim2, int2 = getElementDimension(player), getElementInterior(player)
            oldspecpos[player] = { dim2, int2 }
            local dim, int = getElementDimension(spec), getElementInterior(spec)
            setElementInterior(player, int)
            setElementDimension(player, dim)
            fadeCamera(player, true)
            setCameraTarget(player, spec)
            triggerClientEvent(player, "infobox_start", getRootElement(), "Um den Spectate-Modus\nzu verlassen, tippe\nnur /spec", 5000, 0, 125, 125)
            outputAdminLog(getPlayerName(player) .. " hat " .. getPlayerName(spec) .. " gespectet!")
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/spec [Player]", 5000, 0, 125, 125)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end


function rkick_func(player, command, kplayer, ...)
    if getElementType(player) == "console" or isAdminLevel(player, 1) and (not client or client == player) then
        if kplayer then
            local reason = { ... }
            reason = table.concat(reason, " ")
            local target = findPlayerByName(kplayer)
            if not isElement(target) then
                outputChatBox("Der Spieler ist offline!", player, 125, 0, 0)
                return
            end
            if target == player then
                triggerClientEvent(player, "infobox_start", getRootElement(), "Du kannst dich nicht\nselbst kicken!", 5000, 255, 0, 0)
                return
            end
            if getAdminLevel(player) > getAdminLevel(target) then
                outputChatBox("Spieler " .. getPlayerName(target) .. " wurde von " .. getPlayerName(player) .. " gekickt! (Grund: " .. tostring(reason) .. ")", getRootElement(), 135, 206, 235)
                takeAllWeapons(target)
                kickPlayer(target, player, tostring(reason))
                outputAdminLog(getPlayerName(player) .. " hat " .. kplayer .. " gekickt! Grund: " .. reason)
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "Der Spieler hat\nkeinen niedrigeren\nAdminrang als du!", 5000, 0, 191, 255)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/rkick NAME", 5000, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end

function rban_func(player, command, kplayer, ...)
    if getElementType(player) == "console" or isAdminLevel(player, 2) and (not client or client == player) then
        if kplayer then
            local reason = table.concat({ ... }, " ")
            local target = getPlayerFromName(kplayer)
            if not target then
                if playerUID[kplayer] then
                    local serial = (dbQueryCoro("SELECT ?? FROM ?? WHERE ??=?", "Serial", "players", "UID", playerUID[kplayer]))[1]["Serial"]
                    outputChatBox("Der Spieler wurde (offline) gebannt!", player, 125, 0, 0)
                    dbExec(handler, "INSERT INTO ?? (??, ??, ??, ??, ??, ??) VALUES (?,?,?,?,?,?)", "ban", "UID", "AdminUID", "Grund", "Datum", "IP", "Serial", playerUID[kplayer], playerUID[getPlayerName(player)], reason, timestamp(), '0.0.0.0', serial)
                else
                    outputChatBox("Der Spieler existiert nicht!", player, 125, 0, 0)
                end
            else
                if target == player then
                    triggerClientEvent(player, "infobox_start", getRootElement(), "Du kannst dich nicht\nselbst bannen!", 5000, 255, 0, 0)
                    return
                end
                if getAdminLevel(player) < getAdminLevel(target) then
                    triggerClientEvent(player, "infobox_start", getRootElement(), "Der Spieler hat\neinen höheren\nAdminrang als du!", 5000, 0, 191, 255)
                    return
                end
                outputChatBox("Spieler " .. getPlayerName(target) .. " wurde von " .. getPlayerName(player) .. " bis Weihnachten 2039 gebannt! (Grund: " .. tostring(reason) .. ")", getRootElement(), 255, 52, 179)
                outputAdminLog(getPlayerName(player) .. " hat " .. getPlayerName(target) .. " gebannt! (Grund: " .. tostring(reason) .. ")")
                local ip = getPlayerIP(target)
                local serial = getPlayerSerial(target)
                dbExec(handler, "INSERT INTO ?? (??, ??, ??, ??, ??, ??) VALUES (?,?,?,?,?,?)", "ban", "UID", "AdminUID", "Grund", "Datum", "IP", "Serial", playerUID[kplayer], playerUID[getPlayerName(player)], reason, timestamp(), ip, serial)
                kickPlayer(target, player, tostring(reason) .. " (gebannt!)")
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/rban NAME", 5000, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end

function getip(player, cmd, name)
    if not client or player == client then
        if isAdminLevel(player, 3) then
            if name then
                local target = findPlayerByName(name)
                if isElement(target) then
                    local ip = getPlayerIP(target)
                    outputChatBox("IP von " .. name .. ": " .. ip, player, 200, 200, 0)
                else
					triggerClientEvent(player, "infobox_start", getRootElement(), "Spieler ist nicht online!", 7500, 135, 206, 250)
                end
            else
				triggerClientEvent(player, "infobox_start", getRootElement(), "Gebrauch:\n/getip [Name]", 7500, 135, 206, 250)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
        end
    end
end

function tban_func(player, command, kplayer, btime, ...)
    if getElementType(player) == "console" or isAdminLevel(player, 2) and (not client or client == player) then
        if kplayer and btime and tonumber(btime) ~= nil and tonumber(btime) > 0 then
            local reason = table.concat({ ... }, " ")
            if reason then
                local target = findPlayerByName(kplayer)
                if not isElement(target) then
                    local success = timebanPlayer(kplayer, tonumber(btime), getPlayerName(player), reason)
                    if success == false then
                        triggerClientEvent(player, "infobox_start", getRootElement(), "Gebrauch:\n/tban [Player] [Grund]\n[Zeit],max. 3\nWörter", 5000, 0, 125, 255)
                    end
                    return
                else
                    if target == player then
                        triggerClientEvent(player, "infobox_start", getRootElement(), "Du kannst dich nicht\nselbst zeitbannen!", 5000, 255, 0, 0)
                        return
                    end
                    if getAdminLevel(player) < getAdminLevel(target) then
                        triggerClientEvent(player, "infobox_start", getRootElement(), "Der Spieler hat\neinen höheren\nAdminrang als du!", 5000, 255, 0, 0)
                        return
                    end
                end
                local name = getPlayerName(target)
                local savename = name
                local success = timebanPlayer(savename, tonumber(btime), getPlayerName(player), reason)
                if success == false then
                    triggerClientEvent(player, "infobox_start", getRootElement(), "Gebrauch:\n/tban [Player] [Grund]\n[Zeit],max. 3\nWörter", 5000, 0, 125, 255)
                end
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/tban NAME ZEIT GRUND", 5000, 255, 0, 0)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/tban NAME ZEIT GRUND", 5000, 255, 0, 0)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0)
    end
end


function goto_func(player, command, tplayer)
    if isAdminLevel(player, 1) and (not client or client == player) then
        if tplayer then
            local target = findPlayerByName(tplayer)
            if not isElement(target) then
                outputChatBox("Der Spieler ist offline!", player, 125, 0, 0)
                return
            end
            local x, y, z = getElementPosition(target)
            if getPedOccupiedVehicleSeat(player) == 0 then
                setElementInterior(player, getElementInterior(target))
                setElementInterior(getPedOccupiedVehicle(player), getElementInterior(target))
                setElementPosition(getPedOccupiedVehicle(player), x + 3, y + 3, z)
                setElementDimension(getPedOccupiedVehicle(player), getElementDimension(target))
                setElementDimension(player, getElementDimension(target))
                setElementVelocity(getPedOccupiedVehicle(player), 0, 0, 0)
                setElementFrozen(getPedOccupiedVehicle(player), true)
                setTimer(setElementFrozen, 500, 1, getPedOccupiedVehicle(player), false)
            else
                removePedFromVehicle(player)
                setElementPosition(player, x, y + 1, z)
                setElementInterior(player, getElementInterior(target))
                setElementDimension(player, getElementDimension(target))
            end
            outputAdminLog(getPlayerName(player) .. " hat sich zu " .. getPlayerName(target) .. " teleportiert!")
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/goto NAME", 5000, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end


function gethere_func(player, command, tplayer)
    if isAdminLevel(player, 1) and (not client or client == player) then
        if tplayer then
            local target = findPlayerByName(tplayer)
            local x, y, z = getElementPosition(player)
            if not isElement(target) then
                outputChatBox("Der Spieler ist offline!", player, 125, 0, 0)
                return
            end
            if getPedOccupiedVehicleSeat(target) == 0 then
                setElementInterior(target, getElementInterior(player))
                setElementInterior(getPedOccupiedVehicle(target), getElementInterior(player))
                setElementPosition(getPedOccupiedVehicle(target), x + 3, y + 3, z)
                setElementDimension(target, getElementDimension(player))
                setElementDimension(getPedOccupiedVehicle(target), getElementDimension(player))
                setElementVelocity(getPedOccupiedVehicle(target), 0, 0, 0)
                setElementFrozen(getPedOccupiedVehicle(target), true)
                setTimer(setElementFrozen, 500, 1, getPedOccupiedVehicle(target), false)
            else
                removePedFromVehicle(target)
                setElementPosition(target, x, y + 1, z)
                setElementInterior(target, getElementInterior(player))
                setElementDimension(target, getElementDimension(player))
            end
            outputAdminLog(getPlayerName(player) .. " hat " .. getPlayerName(target) .. " zu sich teleportiert.")
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/gethere NAME", 7500, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 7500, 0, 191, 255)
    end
end


function skydive_func(player, command, tplayer)
    if getElementType(player) == "console" or isAdminLevel(player, 3) and (not client or client == player) then
        if tplayer then
            local target = findPlayerByName(tplayer)
            if not isElement(target) then
                outputChatBox("Der Spieler ist offline!", player, 125, 0, 0)
                return
            end
            giveWeapon(target, 46, 1, true)
            local x, y, z = getElementPosition(target)
            if getPedOccupiedVehicleSeat(target) == 0 then
                setElementPosition(getPedOccupiedVehicle(target), x, y, z + 2000)
            else
                removePedFromVehicle(target)
                setElementPosition(target, x, y, z + 2000)
            end
            for playeritem, key in pairs(adminsIngame) do
                if key >= 1 then
                    outputChatBox(getPlayerName(player) .. " hat " .. getPlayerName(target) .. " geskydived!", playeritem, 255, 255, 0)
                end
            end
            outputAdminLog(getPlayerName(player) .. " hat " .. getPlayerName(target) .. " geskydived!")
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/skydive NAME", 5000, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end

local blocked_cms = {}
blocked_cms["say"] = true
blocked_cms["teamsay"] = true
blocked_cms["ad"] = true
blocked_cms["me"] = true
blocked_cms["t"] = true
blocked_cms["g"] = true
blocked_cms["s"] = true
blocked_cms["l"] = true
blocked_cms["m"] = true


function vioMutePlayer(cmd)
    if blocked_cms[cmd] then
        outputChatBox("Du bist gemuted, benutze /report fuer Fragen!", source, 125, 0, 0)
        cancelEvent()
    end
end


function mute_func(player, command, tplayer)
    if getElementType(player) == "console" or isAdminLevel(player, 1) and (not client or client == player) then
        if tplayer then
            local target = findPlayerByName(tplayer)
            if not isElement(target) then
                outputChatBox("Der Spieler ist offline!", player, 125, 0, 0)
                return
            end
            if muted_players[target] then
                removeEventHandler("onPlayerCommand", target, vioMutePlayer)
                muted_players[target] = false
                for playeritem, key in pairs(adminsIngame) do
                    if key >= 1 then
                        outputChatBox(getPlayerName(player) .. " hat " .. getPlayerName(target) .. " entmuted!", playeritem, 255, 255, 0)
                    end
                end
            else
                addEventHandler("onPlayerCommand", target, vioMutePlayer)
                muted_players[target] = true
                for playeritem, key in pairs(adminsIngame) do
                    if key >= 1 then
                        outputChatBox(getPlayerName(player) .. " hat " .. getPlayerName(target) .. " gemuted!", playeritem, 255, 255, 0)
                    end
                end
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/mute NAME", 5000, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end


function unban_func(player, cmd, nick)
    if playerUID[nick] then
        local adminname = dbQueryCoro("SELECT ?? FROM ?? WHERE ??=?", "AdminUID", "ban", "UID", playerUID[nick])
        if adminname and adminname[1] then
            if getElementType(player) == "console" or isAdminLevel(player, 2) then
                dbExec(handler, "DELETE FROM ?? WHERE ??=?", "ban", "UID", playerUID[nick])
                outputChatBox(getPlayerName(player) .. " hat " .. nick .. " entbannt!", getRootElement(), 125, 0, 0)
                outputAdminLog(getPlayerName(player) .. " hat " .. nick .. " entbannt.")
            elseif playerUIDName[adminname[1]["AdminUID"]] == getPlayerName(player) then
                dbExec(handler, "DELETE FROM ?? WHERE ??=?", "ban", "UID", playerUID[nick])
                outputChatBox(getPlayerName(player) .. " hat " .. nick .. " entbannt!", getRootElement(), 125, 0, 0)
                outputAdminLog(getPlayerName(player) .. " hat " .. nick .. " entbannt.")
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nDer Spieler\nist nicht\ngebannt!", 5000, 255, 0, 0)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "Ungültiger Spieler", 5000, 255, 0, 0)
    end
end



function crespawn_func(player, cmd, radius)
    if isAdminLevel(player, 1) then
        if radius then
            radius = tonumber(radius)
            if radius <= 50 and radius > 0 then
                local x, y, z = getElementPosition(player)
                local sphere_1 = createColSphere(x, y, z, radius)
                local spehere_table = getElementsWithinColShape(sphere_1, "vehicle")
                for theKey, theVehicle in pairs(spehere_table) do
                    if doesAnyPlayerOccupieTheVeh(theVehicle) then
                    else
                        if not MtxGetElementData(theVehicle, "carslotnr_owner") then
                            respawnVehicle(theVehicle)
                        else
                            local towcar = MtxGetElementData(theVehicle, "carslotnr_owner")
                            local pname = MtxGetElementData(theVehicle, "owner")
                            respawnPrivVeh(towcar, pname)
                        end
                    end
                end
                destroyElement(sphere_1)
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/crespawn [0-50]", 5000, 0, 191, 255)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/crespawn RADIUS", 5000, 0, 191, 255)
        end
    end
end


function gotocar_func(player, cmd, targetname, slot)
    if isAdminLevel(player, 1) then
        if targetname and slot then
            slot = tonumber(slot)
            local target = findPlayerByName(targetname)
            local newtargetname = getPlayerName(target)
            if isElement(target) then
                local carslot = MtxGetElementData(target, "carslot" .. slot)
                if carslot then
                    if carslot >= 1 then
                        local veh = allPrivateCars[newtargetname] and allPrivateCars[newtargetname][slot] or false
                        if isElement(veh) then
                            local x, y, z = getElementPosition(veh)
                            local inter = getElementInterior(veh)
                            local dimension = getElementDimension(veh)
                            setElementPosition(player, x, y, z + 1.5)
                            setElementInterior(player, inter)
                            setElementDimension(player, dimension)
                        else
                            respawnPrivVeh(slot, newtargetname)
                            veh = allPrivateCars[newtargetname] and allPrivateCars[newtargetname][slot] or false
                            local x, y, z = getElementPosition(veh)
                            local inter = getElementInterior(veh)
                            local dimension = getElementDimension(veh)
                            setElementPosition(player, x, y, z + 1.5)
                            setElementInterior(player, inter)
                            setElementDimension(player, dimension)
                        end
                        outputAdminLog(getPlayerName(player) .. " hat sich zum Slot " .. slot .. " von " .. targetname .. " geportet.")
                    else
                        outputChatBox("Der Spieler hat keinen Wagen mit dieser Nummer!", player, 125, 0, 0)
                    end
                else
                    outputChatBox("Der Spieler hat keinen Wagen mit dieser Nummer!", player, 125, 0, 0)
                end
            else
                outputChatBox("Spieler muss online sein!", player, 125, 0, 0)
            end
        else
            outputChatBox("/gotocar [Spieler] [Slot]!", player, 125, 0, 0)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end


function getcar_func(player, cmd, targetname, slot)
    if isAdminLevel(player, 1) then
        if targetname and slot then
            slot = tonumber(slot)
            local target = findPlayerByName(targetname)
            local newtargetname = getPlayerName(target)
            if isElement(target) then
                local carslot = MtxGetElementData(target, "carslot" .. slot)
                if carslot then
                    if carslot >= 1 then
                        local veh = allPrivateCars[newtargetname] and allPrivateCars[newtargetname][slot] or false
                        if isElement(veh) then
                            local x, y, z = getElementPosition(player)
                            local inter = getElementInterior(player)
                            local dimension = getElementDimension(player)
                            setElementPosition(veh, x, y, z + 1.5)
                            setElementInterior(veh, inter)
                            setElementDimension(veh, dimension)
                        else
                            respawnPrivVeh(slot, newtargetname)
                            veh = allPrivateCars[newtargetname] and allPrivateCars[newtargetname][slot] or false
                            local x, y, z = getElementPosition(player)
                            local inter = getElementInterior(player)
                            local dimension = getElementDimension(player)
                            setElementPosition(veh, x, y, z + 1.5)
                            setElementInterior(veh, inter)
                            setElementDimension(veh, dimension)
                        end
                        outputAdminLog(getPlayerName(player) .. " hat den Slot " .. slot .. " von " .. targetname .. " zu sich geportet.")
                    else
                        outputChatBox("Der Spieler hat keinen Wagen mit dieser Nummer!", player, 125, 0, 0)
                    end
                else
                    outputChatBox("Der Spieler hat keinen Wagen mit dieser Nummer!", player, 125, 0, 0)
                end
            else
                outputChatBox("Spieler muss online sein!", player, 125, 0, 0)
            end
        else
            outputChatBox("/getcar [Spieler] [Slot]!", player, 125, 0, 0)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end


function astart_func(player, cmd)
    if isAdminLevel(player, 3) then
        local veh = getPedOccupiedVehicle(player)
        if not isElement(veh) then
            outputChatBox("Du musst in einem Wagen sitzen!", player, 125, 0, 0)
            return
        end
        if getElementModel(veh) ~= 438 then
            if (getPedOccupiedVehicleSeat(player) == 0) then
                MtxSetElementData(veh, "fuelstate", 100)
                MtxSetElementData(veh, "engine", false)
                setVehicleOverrideLights(veh, 1)
                MtxSetElementData(veh, "light", false)
                setVehicleEngineState(veh, false)
                if getVehicleEngineState(veh) then
                    setVehicleEngineState(veh, false)
                    MtxSetElementData(veh, "engine", false)
                    return
                end
                setVehicleEngineState(veh, true)
                MtxSetElementData(veh, "engine", true)
                if not MtxGetElementData(veh, "timerrunning") then
                    setVehicleNewFuelState(veh)
                    MtxSetElementData(veh, "timerrunning", true)
                end
            end
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end


function aenter_func(player, cmd)
    if isAdminLevel(player, 3) then
        MtxSetElementData(player, "adminEnterVehicle", true)
        outputChatBox("Klicke auf einen Wagen!", player, 125, 0, 0)
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end


function makeVehFFT(player)
    if isAdminLevel(player, 3) then
        if isPedInVehicle(player) then
            local veh = getPedOccupiedVehicle(player)
            local pname = MtxGetElementData(veh, "owner")
            for l = 1, 6 do
                for i = 1, 6 do
                    if i == l then
                        MtxSetElementData(veh, "stuning" .. i, l)
                    end
                end
            end
            local totTuning = "1|1|1|1|1|1"
            MtxSetElementData(veh, "stuning", totTuning)
            dbExec(handler, "UPDATE vehicles SET STuning=? WHERE ??=? AND ??=?", totTuning, "UID", playerUID[pname], "Slot", MtxGetElementData(veh, "carslotnr_owner"))
            specPimpVeh(veh)
            specialTuningVehEnter(player, 0)
            outputChatBox("Du hast das Auto FFT gemacht.", player, 0, 191, 255)
            outputAdminLog(getPlayerName(player) .. " hat das Auto von " .. MtxGetElementData(veh, "owner") .. " FFT gemacht!")
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu musst im\nFahrzeug sitzen.", 5000, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end

function muteDonator(player, cmd, target)
    if target then
        if MtxGetElementData(player, "premium") == true then
            if findPlayerByName(target) then
                local targetpl = findPlayerByName(target)
                -- Absichern, falls der Spieler ohne Login-Durchlauf hier landet.
                donatorMute[player] = donatorMute[player] or {}
                if not donatorMute[player][getPlayerName(targetpl)] then
                    donatorMute[player][getPlayerName(targetpl)] = true
                    outputChatBox("Du hast " .. target .. " nun für den /muted - Chat gemutet.", player, 0, 155, 0)
                else
                    donatorMute[player][getPlayerName(targetpl)] = nil
                    outputChatBox("Du hast " .. target .. " wieder entmuted.", player, 0, 155, 0)
                end
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\nDer Spieler\nexistiert nicht!", 5000, 0, 191, 255)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nGebrauch:\n/muted NAME", 5000, 0, 191, 255)
    end
end


function oeffnePremium(player)
    if isAdminLevel(player,1) or MtxGetElementData(player, "premium") == true and getElementData(player,"inTactic") == false and not getElementClicked(player) then
        triggerClientEvent(player, "Premiumpanel", player)
    end
end

function fixAdminVeh(player)
    if player ~= client then return end
    if MtxGetElementData(player, "money") >= 100 then
        if isPedInVehicle(player) then
            local veh = getPedOccupiedVehicle(player)
            if getVehicleOccupant(veh, 0) == player then
                fixVehicle(veh)
                executeCommandHandler("meCMD ", player, " hat sein Fahrzeug repariert!")
                MtxSetElementData(player, "money", MtxGetElementData(player, "money") - 100)
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\nNur als\nFahrer erlaubt!", 5000, 0, 191, 255)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "Du sitzt\nin keinem\nFahrzeug!", 5000, 0, 191, 255)
        end
	else
	   triggerClientEvent(player, "infobox_start", getRootElement(), "\nNicht genug\nGeld!", 5000, 0, 191, 255)
    end
end	

function fillAdminLife()
	if Cooldown[client] and getTickCount() - Cooldown[client] < 180000 then
		return outputChatBox ( "Du musst 3 Minuten warten", client, 255, 0, 0 )
	end	
	if MtxGetElementData(client, "money") >= 300 then
		setElementHealth(client, 100)
		setPedArmor(client, 100)
		setElementHunger(client, 100)
		Cooldown[client] = getTickCount()
		MtxSetElementData(client, "money", MtxGetElementData(client, "money") - 300)
		executeCommandHandler("meCMD", client, "hat sein Leben & seine Weste aufgefüllt!")
		outputLog(getPlayerName(client) .. " hat sich mit VIP geheilt", "Heilung")
	else
		triggerClientEvent(client, "infobox_start", getRootElement(), "\nNicht genug\nGeld!", 5000, 0, 191, 255)
	end
end

function fillAdminVeh(player)
    if player ~= client then return end
    if isPedInVehicle(player) then
        local veh = getPedOccupiedVehicle(player)
        if getVehicleOccupant(veh, 0) == player then
            local liters = 100 - MtxGetElementData(veh, "fuelstate")
            if MtxGetElementData(player, "money") >= (liters * 10) then
                if liters > 1 then
                    setElementFrozen(veh, true)
                    setTimer(setElementFrozen, 2000, 1, veh, false)
                    MtxSetElementData(veh, "fuelstate", 100)
                    MtxSetElementData(player, "money", MtxGetElementData(player, "money") - (liters * 10))
                    local the_tankstelle = getNearestTanke(player)
                    if the_tankstelle ~= false then
                        if the_tankstelle == "Nord" then
                            bizArray["TankstelleNord"]["kasse"] = bizArray["TankstelleNord"]["kasse"] + liters * 10
                        elseif the_tankstelle == "Sued" then
                            bizArray["TankstelleSued"]["kasse"] = bizArray["TankstelleSued"]["kasse"] + liters * 10
                        elseif the_tankstelle == "Pine" then
                            bizArray["TankstellePine"]["kasse"] = bizArray["TankstellePine"]["kasse"] + liters * 10
                        end
                    end
                else
                    triggerClientEvent(player, "infobox_start", getRootElement(), "Dein Fahrzeug\nist schon\nbetankt!", 5000, 0, 191, 255)
                end
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "\nNicht genug\nGeld!", 5000, 0, 191, 255)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "\nNur als\nFahrer erlaubt!", 5000, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "Du sitzt\nin keinem\nFahrzeug!", 5000, 0, 191, 255)
    end
end


function prison_func(player, cmd, target, time, ...)
    if isAdminLevel(player, 1) then
        if target then
            if time then
                if tonumber(time) ~= nil then
                    local time = tonumber(time)
                    if time >= 0 then
                        local parametersTable = { ... }
                        local stringWithAllParameters = table.concat(parametersTable, " ")
                        if stringWithAllParameters ~= nil and string.len(stringWithAllParameters) > 3 then
                            if findPlayerByName(target) then
                                local target = findPlayerByName(target)
                                if isPedInVehicle(target) then
                                    removePedFromVehicle(target)
                                end
								if getAdminLevel(player) < getAdminLevel(target) then
									triggerClientEvent(player, "infobox_start", getRootElement(), "Der Spieler hat\neinen höheren\nAdminrang als du!", 5000, 0, 191, 255)
									return
								end
                                if time > 0 then
                                    local knastzeit = tonumber(MtxGetElementData(target, "jailtime"))
                                    MtxSetElementData(target, "prison", time + knastzeit)
                                    MtxSetElementData(target, "jailtime", 0)
                                    outputChatBox(getPlayerName(target) .. " wurde von " .. getPlayerName(player) .. " für " .. time .. " Minuten ins Prison gesteckt.\nGrund: " .. stringWithAllParameters, getRootElement(), 135, 206, 235)
                                    putPlayerInJail(target)
                                    if isOnDuty(player) then
                                        executeCommandHandler("offduty", target)
                                    end
                                elseif MtxGetElementData(target, "prison") > 0 then
                                    MtxSetElementData(target, "prison", 0)
                                    outputChatBox(getPlayerName(target) .. " wurde von " .. getPlayerName(player) .. " aus dem Prison geholt.\nGrund: " .. stringWithAllParameters, getRootElement(), 135, 206, 235)
                                    freePlayerFromJail(target)
                                else
                                    triggerClientEvent(player, "infobox_start", getRootElement(), "Der Spieler\nist nicht im\nPrison!", 5000, 0, 191, 255)
                                end
                            elseif playerUID[target] then
                                if time > 0 then
                                    outputChatBox(target .. " wurde von " .. getPlayerName(player) .. " für " .. time .. " Minuten ins Prison gesteckt.\nGrund: " .. stringWithAllParameters, getRootElement(), 0, 191, 255)
                                    local knastzeit = (dbQueryCoro("SELECT ?? FROM ?? WHERE ??=?", "Knastzeit", "userdata", "UID", playerUID[target]))[1]["Knastzeit"]
                                    dbExec(handler, "UPDATE ?? SET ??=?, ??=? WHERE ??=?", "userdata", "Prison", knastzeit + time, "Knastzeit", 0, "UID", playerUID[target])
                                    if knastzeit == 0 then
                                        offlinemsg("Du wurdest von " .. getPlayerName(player) .. " für " .. time .. " Minuten ins Prison gesteckt.\nGrund: " .. stringWithAllParameters, "Server", target)
                                    else
                                        offlinemsg("Du wurdest von " .. getPlayerName(player) .. " für " .. time .. " Minuten mehr ins Prison gesteckt.\nGrund: " .. stringWithAllParameters, "Server", target)
                                    end
                                else
                                    local prisontimeleftoffline = (dbQueryCoro("SELECT ?? FROM ?? WHERE ??=?", "Prison", "userdata", "UID", playerUID[target]))[1]["Prison"]
                                    if prisontimeleftoffline > 0 then
                                        outputChatBox(target .. " wurde von " .. getPlayerName(player) .. " aus dem Prison geholt\nGrund: " .. stringWithAllParameters, getRootElement(), 0, 191, 255)
                                        dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Prison", 0, "UID", playerUID[target])
                                        offlinemsg("Du wurdest von " .. getPlayerName(player) .. " aus dem Prison geholt\nGrund: " .. stringWithAllParameters, "Server", target)
                                    else
                                        triggerClientEvent(player, "infobox_start", getRootElement(), "Der Spieler\nist nicht im\nPrison!", 5000, 0, 191, 255)
                                    end
                                end
                            else
                                triggerClientEvent(player, "infobox_start", getRootElement(), "Der Spieler\nexistiert nicht!", 5000, 0, 191, 255)
                            end
                        else
                            triggerClientEvent(player, "infobox_start", getRootElement(), "Gebrauch:\n/prison NAME\nZEIT GRUND", 5000, 0, 191, 255)
                        end
                    else
                        triggerClientEvent(player, "infobox_start", getRootElement(), "Negative Zeit\nist nicht\nerlaubt!", 5000, 0, 191, 255)
                    end
                else
                    triggerClientEvent(player, "infobox_start", getRootElement(), "Gebrauch:\n/prison NAME\nZEIT GRUND", 5000, 0, 191, 255)
                end
            else
                triggerClientEvent(player, "infobox_start", getRootElement(), "Gebrauch:\n/prison NAME\nZEIT GRUND", 5000, 0, 191, 255)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "Gebrauch:\n/prison NAME\nZEIT GRUND", 5000, 0, 191, 255)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "\nDu bist nicht autorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255)
    end
end

function kickAll(player, cmd, ...)
    if isAdminLevel(player, 3) then
        local parametersTable = { ... }
        local stringWithAllParameters = table.concat(parametersTable, " ")
        local players = getElementsByType("player")
        for i = 1, #players do
            if players[i] ~= player then
                kickPlayer(players[i], player, stringWithAllParameters)
            end
        end
    end
end


function changeStatus ( player, cmd, status )
	if isAdminLevel (player,1) then
		if status then
			local status = tostring(status)
			if string.len ( status ) >= 3 and string.len ( status ) <= 16 then
				if not socialNeeds[status] then
					if string.find ( status, "'" ) then
						infobox ( player, "Bitte kein ' verwenden!", 4000, 200, 0, 0 )
						return false
					end
					MtxSetElementData ( player, "socialState", status )
				else
					infobox ( player, "Den Status\nmusst du\ndir verdienen", 4000, 200, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "Der Status muss\nlänger als 2\nund kürzer als\n17 Zeichen sein!", 5000, 255, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "Gebrauch:\n/status STATUS", 5000, 255, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nNur ab Donator!", 5000, 255, 0, 0 )
	end
end

local function startPaydayEvents(player,cmd,typ)
	if isAdminLevel(player,1)then
		if(typ)then
			if typ == "coins" then
				if event.ispaydaycoins == true then
					event.ispaydaycoins = false
					outputChatBox("Teammitglied "..getPlayerName(player).." hat ein Payday-Event beendet!",root,255,0,0)
					outputLog("[Payday-Event]:"..getPlayerName(player).." hat ein Payday-Event beendet! (Coins)","Adminsystem")
				else
					event.ispaydaycoins = true
					outputChatBox("Teammitglied "..getPlayerName(player).." hat ein Payday-Event gestartet!",root,0,255,0)
					outputLog("[Payday-Event]:"..getPlayerName(player).." hat ein Payday-Event gestartet! (Coins)","Adminsystem")
				end
			end
		else outputChatBox("Gebe ein Payday-Event an!",player)outputChatBox("Payday-Events: coins",player,255,255,255)end
	else outputChatBox("Du bist kein Supporter oder höher!",player)end
end


addCommandHandler("delacc", function(player, cmd, target)
    if isAdminLevel(player, 5) then
        if playerUID[target] then
            
            -- WICHTIG: Den Namen für die 'clothes'-Tabelle speichern
            local accountName = target
            
            local id = playerUID[target]
            playerUID[target] = nil
            playerUIDName[id] = nil
            
            dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "achievments", "UID", id)
            dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "bonustable", "UID", id)
            dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "inventar", "UID", id)
            dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "packages", "UID", id)
            dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "players", "UID", id)
            dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "skills", "UID", id)
            dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "userdata", "UID", id)
            dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "statistics", "UID", id)
			dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "playingtime", "UID", id)
            
            -- Spezieller Löschbefehl für 'clothes': Verwendet den Namen und die Spalte 'Name'
            dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "clothes", "Name", accountName) 
			dbExec(handler, "DELETE FROM ?? WHERE ?? = ?", "promotion", "Username", accountName)
            
            triggerClientEvent(player, "infobox_start", getRootElement(), "Erledigt", 7500, 135, 206, 250)
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "Account\nexistiert nicht!", 7500, 135, 206, 250)
        end
    end
end)



addCommandHandler("restartresource", function(player)
    if isAdminLevel(player, 5) then
        for index, playeritem in pairs(getElementsByType("player")) do
            if MtxGetElementData(playeritem, "loggedin") == 1 then
                local pname = getPlayerName(playeritem)
                local int = getElementInterior(playeritem)
                local dim = getElementDimension(playeritem)
                local x, y, z = getElementPosition(playeritem)
                local curWeaponsForSave = "|"
                for i = 1, 11 do
                    if i ~= 10 then
                        local weapon = getPedWeapon(playeritem, i)
                        local ammo = getPedTotalAmmo(playeritem, i)
                        if weapon and ammo then
                            if weapon > 0 and ammo > 0 then
                                if #curWeaponsForSave <= 40 then
                                    curWeaponsForSave = curWeaponsForSave .. weapon .. "," .. ammo .. "|"
                                end
                            end
                        end
                    end
                end
                local pos = "|" .. (math.floor(x * 100) / 100) .. "|" .. (math.floor(y * 100) / 100) .. "|" .. (math.floor(z * 100) / 100) .. "|" .. int .. "|" .. dim .. "|"
                if #curWeaponsForSave < 5 then
                    curWeaponsForSave = ""
                end
                dbExec(handler, "INSERT INTO ?? (??, ??, ??) VALUES (?,?,?)", "logout", "Position", "Waffen", "UID", pos, curWeaponsForSave, playerUID[pname])
                datasave_remote(playeritem)
                clearDataSettings(playeritem)
            end
        end
        restartResource(getThisResource())
    end
end)

function heal(player, cmd, targetName)
    if isAdminLevel(player, 2) then
        local target = player
        
        if targetName then
            target = getPlayerFromName(targetName)
            if not target then
                triggerClientEvent(player, "infobox_start", getRootElement(), "Spieler nicht gefunden!", 7500, 255, 0, 0)
                return
            end
        end

        local heaventime = MtxGetElementData(target, "heaventime") or 0
        
        if heaventime >= 1 or target ~= player then
            MtxSetElementData(target, "heaventime", 0)
            showChat(target, true)
            triggerClientEvent(target, "stopDeathFreecam", target)
            setCameraTarget(target)
            RemoteSpawnPlayer(target)
            setElementHealth(target, 100)
            setElementFrozen(target, false)
            toggleAllControls(target, true)
            setPedAnimation(target, false)
            playSoundFrontEnd(target, 17)

            if thedeathtimer and thedeathtimer[target] and isTimer(thedeathtimer[target]) then
                killTimer(thedeathtimer[target])
            end

            if target ~= player then
                triggerClientEvent(player, "infobox_start", getRootElement(), "Du hast den Spieler geheilt!", 7500, 0, 255, 0)
            end
        else
            triggerClientEvent(player, "infobox_start", getRootElement(), "Der Spieler ist nicht tot/im Heaventime!", 7500, 255, 0, 0)
        end
    else
        triggerClientEvent(player, "infobox_start", getRootElement(), "Du bist kein Admin (Level 3)", 7500, 255, 0, 0)
    end
end
addCommandHandler("heal", heal)

local function getPlayerInfos(admin, cmd, target)
    if ( tonumber ( MtxGetElementData(admin, "adminlvl") ) or 0 ) >= 3 then
        local player = getPlayerFromName(target)
        if player then
            local pname = getPlayerName(player)
			local Serial = getPlayerSerial(player)
			local IP = getPlayerIP(player)
            local money = tonumber(MtxGetElementData(player, "money"))
            local bmoney = tonumber(MtxGetElementData(player, "bankmoney"))
            local fraktion = tonumber(MtxGetElementData(player, "fraktion"))
			fraktion = fraktionNames[fraktion]

            outputChatBox("Spielerinformationen von " .. pname, admin, 255, 0, 0)
            outputChatBox("Geld Bar/Bank: " .. money .. "/" .. bmoney, admin, 255,0, 0)
            outputChatBox("Fraktion: ".. fraktion, admin, 255, 0, 0)
			outputChatBox("Serial: ".. Serial, admin, 255, 0, 0)
			outputChatBox("IP: ".. IP, admin, 255, 0, 0)
			
		end
    end
end


function flip(playerSource)
    if ( tonumber ( MtxGetElementData(playerSource, "adminlvl") ) or 0 ) >= 1 then
        local theVehicle = getPedOccupiedVehicle(playerSource)
        if (theVehicle and getVehicleController(theVehicle) == playerSource) then
            local rx, ry, rz = getVehicleRotation(theVehicle)
            if (rx > 110) and (rx < 250) then
                local x, y, z = getElementPosition(theVehicle)
                setVehicleRotation(theVehicle, rx + 180, ry, rz)
                setElementPosition(theVehicle, x, y, z + 2)
            end
        end
    end
end

addEventHandler("testsocial", root, function(bool)
    if bool then
        laststatus[client] = MtxGetElementData(client, "socialState")
        MtxSetElementData(client, "socialState", "Schreibt ...")
    else
        if laststatus[client] then
            MtxSetElementData(client, "socialState", laststatus[client])
        end
    end
end)

addCommandHandler("checkLeader", function(player)
        for i = 1, #fraktionNames + 1 do
            for idx, value in pairs(fraktionMemberList[i]) do
                if value == 5 then
                    outputChatBox("Fraktion " .. i .. " | " .. fraktionNames[i] .. " | " .. idx, player, 255, 255, 0)
                end
           end
     end
end)

local premiumPackageNames = { [1]="Bronze", [2]="Silber", [3]="Gold", [4]="Platin", [5]="TOP DONATOR" }
local premiumPackageList = "1=Bronze, 2=Silber, 3=Gold, 4=Platin, 5=TOP DONATOR"

local function premiumUsageHint ( player, hint )
	triggerClientEvent ( player, "infobox_start", getRootElement(),
		hint.."\n\nGebrauch:\n/setpremium [Name] [Tage] [Paket]\nPakete: "..premiumPackageList, 6000, 255, 0, 0 )
end

-- Fuehrt den Admin schrittweise durch die Eingabe (fehlender Name -> fehlende
-- Tage -> fehlendes/ungueltiges Paket), statt bei fehlenden Argumenten nur
-- pauschal "Gebrauch: ..." zu zeigen bzw. bei /setpremium ohne Tage abzustuerzen
-- (tonumber(nil) > 0 war vorher ein ungeprueftes Bad-Argument).
function setPremium (player, cmd, target, days, package)
	if not isAdminLevel ( player, 5 ) then
		triggerClientEvent ( player, "infobox_start", getRootElement(), "Du bist nicht befugt.", 5000, 255, 0, 0 )
		return
	end

	if not target then
		premiumUsageHint ( player, "Bitte gib zuerst den Spielernamen ein." )
		return
	end

	local targetPlayer = getPlayerFromName ( target )
	if not targetPlayer then
		triggerClientEvent ( player, "infobox_start", getRootElement(), "Spieler ist nicht online.", 5000, 255, 0, 0 )
		return
	end

	local daysNum = tonumber ( days )
	if not daysNum or daysNum <= 0 then
		premiumUsageHint ( player, "Bitte gib jetzt an, fuer wie viele Tage "..getPlayerName(targetPlayer).." Premium bekommen soll." )
		return
	end

	local packageNum = tonumber ( package )
	if not packageNum or not premiumPackageNames[packageNum] then
		premiumUsageHint ( player, "Bitte gib jetzt ein gueltiges Paket an." )
		return
	end

	setPremiumData ( targetPlayer, daysNum, packageNum )
	outputChatBox ( "Du hast soeben fuer "..daysNum.." Tage das Premium Paket "..premiumPackageNames[packageNum].." bekommen.", targetPlayer, 0, 150, 255 )
	for playeritem, index in pairs ( adminsIngame ) do
		outputChatBox ( getPlayerName(player).." hat "..getPlayerName(targetPlayer).." "..daysNum.." Tage das Premium Paket "..premiumPackageNames[packageNum].." gegeben.", playeritem, 7, 158, 207 )
	end
end

function Aktiondeaktivieren ( player )
	if ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 1 then
	    if Aktiondeaktivieren == false then
			Aktiondeaktivieren = true
			outputChatBox ("Alle Aktionen sind wieder verfügbar - Teambesprechung ist beendet!", getRootElement(), 255, 120, 0 )
		else
			Aktiondeaktivieren = false
			outputChatBox ("Alle Aktionen wurden durch eine Teambesprechung deaktiviert!", getRootElement(), 255, 0, 0 )
		end
	end
end

function ad_Blockierung ( player )
	if ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 1 then
		if ad_Blockierung == false then
			ad_Blockierung = true
			outputChatBox ( getPlayerName(player).." hat den ad Chat aktiviert!", getRootElement(), 255, 120, 0 )
		else
			ad_Blockierung = false
			outputChatBox ( getPlayerName(player).." hat den ad Chat deaktiviert!", getRootElement(), 255, 0, 0 )
		end
	end
end

function Jump(player)
	if isAdminLevel(player, 3) then
		local vehicle = getPedOccupiedVehicle(player)
		if vehicle and getPedOccupiedVehicleSeat(player) == 0 then
			local X, Y, Z = getElementVelocity(vehicle)
			setElementVelocity(vehicle, X, Y, Z + 0.3)
			outputChatBox("[AdminJump] Fahrzeug erfolgreich angehoben.", player, 0, 255, 0)
		end
	end
end

function saveuserdata(player)
	if player == client and isAdminLevel(player,5) then
		for _,v in ipairs(getElementsByType("player"))do
			datasave_remote(v)
		end
	end
end

local SPEED_MULTIPLIER = 1.3

function speedup ( player )
	if isAdminLevel(player, 3) then
		local theVehicle = getPedOccupiedVehicle(player)
		if theVehicle and getPedOccupiedVehicleSeat(player) == 0 then
			local x, y, z = getElementVelocity(theVehicle)
			if math.abs(x) > 0.001 or math.abs(y) > 0.001 or math.abs(z) > 0.001 then
				local newX = x * SPEED_MULTIPLIER
				local newY = y * SPEED_MULTIPLIER
				local newZ = z * SPEED_MULTIPLIER
				setElementVelocity(theVehicle, newX, newY, newZ)
				outputChatBox("[Adminspeed] Geschwindigkeit erfolgreich erhöht.", player, 0, 255, 0)
			else
				outputChatBox("[Adminspeed] Fahrzeug bewegt sich nicht.", player, 255, 255, 0)
			end
		end	
	end
end

function setlevel(player,cmd,pname,level)
	if isAdminLevel(player,5) then
		if pname and tonumber(level) >= 0 and tonumber(level) < 31 then
			local pname = getPlayerFromName(pname)
			if pname then
				MtxSetElementData(pname,"level",tonumber(level))
				outputChatBox("Du hast dein Level "..level.." erfolgreich gesetzt!",player,0,255,0)
			else
				outputChatBox("Spieler nicht gefunden!",player,255,0,0)
			end
		else
			outputChatBox("Du kannst Level maximal auf 30 setzen!",player,255,0,0) 
		end
	else 
		outputChatBox("Du bist nicht befugt!",player,255,0,0) 
	end
end

addCommandHandler("give", function(player, cmd, targetName, typ, amount)
    if not (player and isElement(player) and getElementType(player) == "player") then return end
    
    if not isAdminLevel(player, 4) then
        outputChatBox("Du bist nicht befugt!", player, 255, 0, 0)
        return
    end

    if not targetName or not typ or not amount then
        outputChatBox("Syntax: /give [Spielername] [geld/bankgeld/coin] [menge]", player, 255, 255, 0)
        return
    end

    local target = getPlayerFromName(targetName)
    local value = tonumber(amount)

    if target and value and value >= 0 then
        if typ == "geld" then
            MtxSetElementData(target, "money", value)
            outputChatBox("Du hast das Geld von " .. getPlayerName(target) .. " auf " .. value .. " gesetzt.", player, 0, 255, 0)
            outputChatBox("Dein Bargeld wurde durch einen Admin auf " .. value .. " gesetzt.", target, 0, 255, 0)
        
        elseif typ == "bankgeld" then
            MtxSetElementData(target, "bankmoney", value)
            outputChatBox("Du hast das Bankgeld von " .. getPlayerName(target) .. " auf " .. value .. " gesetzt.", player, 0, 255, 0)
            outputChatBox("Dein Bankguthaben wurde durch einen Admin auf " .. value .. " gesetzt.", target, 0, 255, 0)
            
        elseif typ == "coin" then
            MtxSetElementData(target, "coins", value)
            outputChatBox("Du hast die Coins von " .. getPlayerName(target) .. " auf " .. value .. " gesetzt.", player, 0, 255, 0)
            outputChatBox("Deine Coins wurden durch einen Admin auf " .. value .. " gesetzt.", target, 0, 255, 0)
        
        else
            outputChatBox("Ungültiger Typ! Nutze: geld, bankgeld oder coin.", player, 255, 0, 0)
        end
    else
        outputChatBox("Spieler nicht gefunden oder ungültige Menge!", player, 255, 0, 0)
    end
end)

--Events
addEvent("executeAdminServerCMD", true)
addEvent("move", true)
addEvent("moveVehicleAway", true)
addEvent("adminMenueTrigger", true)
addEvent("rkick", true)
addEvent("rban", true)
addEvent("getip", true)
addEvent("tban", true)
addEvent("slap", true)
addEvent("goto", true)
addEvent("gethere", true)
addEvent("skydive", true)
addEvent("mute", true)
addEvent("fixveh1", true)
addEvent("lebenessen", true)
addEvent("fillComplete1", true)
addEvent("saveuserdata",true)

-- Event Handler
addEventHandler("executeAdminServerCMD", getRootElement(), executeAdminServerCMD_func)
addEventHandler("moveVehicleAway", getRootElement(), moveVehicleAway_func)
addEventHandler("move", getRootElement(), move_func)
addEventHandler("adminMenueTrigger", getRootElement(), adminMenueTrigger_func)
addEventHandler("mute", getRootElement(), mute_func)
addEventHandler("skydive", getRootElement(), skydive_func)
addEventHandler("gethere", getRootElement(), gethere_func)
addEventHandler("goto", getRootElement(), goto_func)
addEventHandler("tban", getRootElement(), tban_func)
addEventHandler("getip", getRootElement(), getip)
addEventHandler("rban", getRootElement(), rban_func)
addEventHandler("rkick", getRootElement(), rkick_func)
addEventHandler("fixveh1", getRootElement(), fixAdminVeh)
addEventHandler("lebenessen", getRootElement(), fillAdminLife)
addEventHandler("fillComplete1", getRootElement(), fillAdminVeh)
addEventHandler("saveuserdata",getRootElement(),saveuserdata)


-- Command Handler
addCommandHandler("nickchange", function(player, cmd, alterName, neuerName) runAsync(nickchange_func, player, cmd, alterName, neuerName) end)
addCommandHandler("move", move_func)
addCommandHandler("pwchange", pwchange_func)
addCommandHandler("shut", shut_func)
addCommandHandler("rebind", rebind_func)
addCommandHandler("admins", adminlist)
addCommandHandler("rcheck", check_func)
addCommandHandler("mark", mark_func)
addCommandHandler("gotomark", gotomark_func)
addCommandHandler("respawn", respawn_func)
addCommandHandler("tunecar", tunecar_func)
addCommandHandler("freezen", freeze_func)
addCommandHandler("intdim", intdim)
addCommandHandler("cleartext", cleartext_func)
addCommandHandler("chatclear", cleartext_func)
addCommandHandler("cc", cleartext_func)
addCommandHandler("clearchat", cleartext_func)
addCommandHandler("textclear", cleartext_func)
addCommandHandler("gmx", gmx_func)
addCommandHandler("o", ochat_func)
addCommandHandler("a", achat_func)
addCommandHandler("setrank", function(player, cmd, target, rank) runAsync(setrank_func, player, cmd, target, rank) end)
addCommandHandler("makeleader", function(player, cmd, target, fraktion) runAsync(makeleader_func, player, cmd, target, fraktion) end)
addCommandHandler("spec", spec_func)
addCommandHandler("rkick", rkick_func)
addCommandHandler("rban", function(player, command, kplayer, ...) runAsync(rban_func, player, command, kplayer, ...) end)
addCommandHandler("getip", getip)
addCommandHandler("tban", tban_func)
addCommandHandler("goto", goto_func)
addCommandHandler("gethere", gethere_func)
addCommandHandler("skydive", skydive_func)
addCommandHandler("rmute", mute_func)
addCommandHandler("entban", function(player, cmd, nick) runAsync(unban_func, player, cmd, nick) end)
addCommandHandler("crespawn", crespawn_func)
addCommandHandler("gotocar", gotocar_func)
addCommandHandler("getcar", getcar_func)
addCommandHandler("astart", astart_func)
addCommandHandler("aenter", aenter_func)
addCommandHandler("makefft", makeVehFFT)
addCommandHandler("muted", muteDonator)
addCommandHandler("premium", oeffnePremium)
addCommandHandler("prison", prison_func)
addCommandHandler("kickall", kickAll)
addCommandHandler("status", changeStatus)
addCommandHandler("payday",startPaydayEvents)
addCommandHandler("akn", Aktiondeaktivieren)
addCommandHandler("setPremium", setPremium)
addCommandHandler("flip", flip)
addCommandHandler("f", flip)
addCommandHandler("getinfo", getPlayerInfos)
addCommandHandler("adminlevel", function(player, cmd, target, adminlevel) runAsync(adminlevel_func, player, cmd, target, adminlevel) end)
addCommandHandler("makeadmin", function(player, cmd, target, adminlevel) runAsync(adminlevel_func, player, cmd, target, adminlevel) end)
addCommandHandler("adchat", ad_Blockierung)
addCommandHandler("setlevel",setlevel)