createBlip( -1693.1865234375, -51.50390625, 3.5613994598389, 38)

carTestCoords = {
    { x = -1756.8759765625, y = -116.1640625, z = 3.5729198455811 },
    { x = -1797.826171875, y = -116.228515625, z = 5.0533576011658 },
	{ x = -1995.5859375, y = -69.837890625, z = 34.562141418457 },
    { x = -2007.18359375, y = -41.078125, z = 34.761821746826 },
	{ x = -2006.30078125, y = 177.640625, z = 27.109518051147 },
	{ x = -1958.59375, y = 227.88671875, z = 32.05989074707 },
	{ x =  -1936.6923828125, y = 247, z = 40.615844726562 },
	{ x =  -1990.40625, y = 286.5302734375, z = 33.68132019043 },
	{ x =  -2023.552734375, y = 504.146484375, z = 34.582042694092 },
	{ x =  -2146.974609375, y = 329.2548828125, z = 34.742309570312 },
	{ x =  -2019.82421875, y = 321.20703125, z = 34.584083557129 },
	{ x =  -2006.35546875, y = 204.4443359375, z = 27.106103897095 },
	{ x =  -2007.115234375, y = -4.91796875, z = 33.876922607422 },
	{ x =  -1835.271484375, y = -116.216796875, z = 5.0665469169617 },
	{ x =  -1738.3798828125, y = -125.693359375, z = 3.0966658592224 },
}

-- Motorrad: engere Streckenfuehrung mit mehr Richtungswechseln kurz
-- hintereinander (Punkte der Auto-Strecke mit den schaerfsten Kurven,
-- z.B. der Zickzack-Abschnitt bei y=247 bis y=504) - andere Reihenfolge/
-- Auswahl derselben bereits verifizierten carTestCoords-Punkte, damit hier
-- keine neuen, ungeprueften Koordinaten ins Spiel kommen.
local bikeTestCoords = {
    { x = -1756.8759765625, y = -116.1640625, z = 3.5729198455811 },
    { x = -1797.826171875, y = -116.228515625, z = 5.0533576011658 },
	{ x = -1995.5859375, y = -69.837890625, z = 34.562141418457 },
	{ x = -2006.30078125, y = 177.640625, z = 27.109518051147 },
	{ x = -1958.59375, y = 227.88671875, z = 32.05989074707 },
	{ x =  -1936.6923828125, y = 247, z = 40.615844726562 },
	{ x =  -1990.40625, y = 286.5302734375, z = 33.68132019043 },
	{ x =  -2023.552734375, y = 504.146484375, z = 34.582042694092 },
	{ x =  -2146.974609375, y = 329.2548828125, z = 34.742309570312 },
	{ x =  -2019.82421875, y = 321.20703125, z = 34.584083557129 },
	{ x =  -1835.271484375, y = -116.216796875, z = 5.0665469169617 },
	{ x =  -1738.3798828125, y = -125.693359375, z = 3.0966658592224 },
}

-- LKW: weiter gespannte Strecke, die die engsten Zickzack-Punkte der
-- Auto-Strecke auslaesst (grosse Fahrzeuge/Anhaenger brauchen mehr
-- Wendekreis) - ebenfalls nur eine andere Auswahl derselben verifizierten
-- carTestCoords-Punkte.
local lkwTestCoords = {
    { x = -1756.8759765625, y = -116.1640625, z = 3.5729198455811 },
    { x = -1797.826171875, y = -116.228515625, z = 5.0533576011658 },
	{ x = -1995.5859375, y = -69.837890625, z = 34.562141418457 },
    { x = -2007.18359375, y = -41.078125, z = 34.761821746826 },
	{ x = -2006.30078125, y = 177.640625, z = 27.109518051147 },
	{ x =  -1990.40625, y = 286.5302734375, z = 33.68132019043 },
	{ x =  -2023.552734375, y = 504.146484375, z = 34.582042694092 },
	{ x =  -2006.35546875, y = 204.4443359375, z = 27.106103897095 },
	{ x =  -2007.115234375, y = -4.91796875, z = 33.876922607422 },
	{ x =  -1835.271484375, y = -116.216796875, z = 5.0665469169617 },
	{ x =  -1738.3798828125, y = -125.693359375, z = 3.0966658592224 },
}

local heliTestCoords = {
    { x = -1756.9, y = -116.2, z = 40.0 },
    { x = -1797.8, y = -116.2, z = 40.0 },
    { x = -1835.3, y = -116.2, z = 40.0 },
    { x = -1870.0, y = -150.0, z = 40.0 },
    { x = -1900.0, y = -192.0, z = 40.0 },
    { x = -1950.0, y = -192.0, z = 40.0 },
    { x = -1990.0, y = -150.0, z = 40.0 },
    { x = -1953.0, y = -116.2, z = 40.0 },
}

-- Die vorherige Version (Punkte 15-23m von den Boot-Spawns entfernt) lag
-- Echte, im Spiel abgefahrene und bestaetigte Wasser-Koordinaten (vom
-- Nutzer direkt uebermittelt) - keine geschaetzten Punkte mehr.
local bootTestCoords = {
    { x = -1710.898, y = -160.590, z = 0.644 },
    { x = -1638.590, y = -90.360, z = -0.192 },
    { x = -1546.082, y = 12.561, z = 1.278 },
    { x = -1412.365, y = 164.029, z = -0.389 },
    { x = -1311.607, y = 317.673, z = 0.389 },
}

local currentTestMarker = {}
local currentTestBlip = {}
local examVehicleFor = {} -- [player] = zuletzt bestaetigt gefahrenes Fahrschulfahrzeug waehrend der Pruefung (Fallback fuer resetFahrschulFahrzeug, falls der Spieler bei /stoppruefung schon ausgestiegen ist)
local fschein_LICENSES = { ["AUTO"] = true, ["LKW"] = true, ["MOTORRAD"] = true, ["HELI"] = true, ["BOOT"] = true }
local fschein_ROUTE_READY = { ["AUTO"] = true, ["LKW"] = true, ["MOTORRAD"] = true, ["HELI"] = true, ["BOOT"] = true }

local fahschuldutymarker = createMarker( -2024.5029296875, -114.63671875, 1035.171875, "cylinder", -0.95, 255, 255, 0)
setElementDimension(fahschuldutymarker,0)
setElementInterior(fahschuldutymarker,3)

addEventHandler("onMarkerHit", fahschuldutymarker, function(player)
    if not isFahrschuleDuty(player) then
        triggerClientEvent ( player, "infobox_start", player, "\n\nverwende /fduty um duty zu gehen.", 3100, 125, 0, 0 )
    else
        triggerClientEvent ( player, "infobox_start", player, "\n\nverwende /foffduty um offduty zu gehen.", 3100, 125, 0, 0 )
    end 
end)

function showFahrlehrerInfo(player)
    outputChatBox("===== Fahrlehrer - Befehlsuebersicht =====", player, 255, 255, 0)
    outputChatBox("/fduty - In den Dienst gehen (am Fahrschul-Marker stehen)", player, 0, 200, 0)
    outputChatBox("/foffduty - Dienst beenden", player, 0, 200, 0)
    outputChatBox("/fpruefung [Spieler] [Schein] - Praktische Pruefung anbieten (du musst im Fahrschulauto sitzen)", player, 200, 200, 0)
    outputChatBox("/stoppruefung [Spieler] [Schein] - Pruefung abschliessen und Fuehrerschein vergeben", player, 200, 200, 0)
    outputChatBox("Scheine fuer /fpruefung: auto, lkw, motorrad, heli, boot", player, 255, 153, 0)
    outputChatBox("Scheine fuer /stoppruefung: auto, lkw, motorrad, heli, boot, durchgefallen", player, 255, 153, 0)
    outputChatBox("----- Ablauf -----", player, 255, 255, 0)
    outputChatBox("1. Der Schueler ruft dich mit /fahrschule und macht mit /fuehrerschein die Theorie.", player, 255, 255, 255)
    outputChatBox("2. Setz dich mit dem Schueler ins Fahrschulauto und biete mit /fpruefung [Spieler] [Schein] die Pruefung an.", player, 255, 255, 255)
    outputChatBox("3. Der Schueler nimmt mit /faccept [Dein Name] an und faehrt die Marker ab.", player, 255, 255, 255)
    outputChatBox("4. Am Ende schliesst du mit /stoppruefung [Spieler] [Schein] ab (oder 'durchgefallen').", player, 255, 255, 255)
end

addCommandHandler("fduty", function(player)
    if isFahrschule(player) then
        local fx,fy,fz = getElementPosition(player)
        local gx,gy,gz = getElementPosition(fahschuldutymarker)
        if getDistanceBetweenPoints3D( fx, fy, fz, -2024.5029296875, -114.63671875, 1035.171875) <= 1 then
            MtxSetElementData(player, "fahrschulonduty", true)
            setElementModel(player, 17)
            triggerClientEvent( player, "infobox_start", getRootElement(), "\n\nDu bist nun duty als Fahrlehrer", 3100, 0, 125, 0)
            showFahrlehrerInfo(player)
        else
            triggerClientEvent ( player, "infobox_start", player, "\n\nDu bist zu weit entfernt", 3100, 125, 0, 0 )
        end
    else
        triggerClientEvent ( player, "infobox_start", player, "\n\nDu bist nicht befugt!", 3100, 125, 0, 0 )
    end
end)

function offdutygehenfahr(player)
    if isFahrschule(player) then
        if  MtxGetElementData( player, "fahrschulonduty") == true then
            MtxSetElementData( player, "fahrschulonduty", false)
            outputChatBox("Du bist nun nicht mehr im Dienst", player, 255, 255, 255)
            setElementModel(player,MtxGetElementData(player,"skinid") or 0)
        else
            outputChatBox("Du bist nicht im Dienst", player, 255, 255, 255)
        end
    end
end
addCommandHandler("foffduty", offdutygehenfahr)

addCommandHandler("finfo", function(player)
    if isFahrschule(player) then
        showFahrlehrerInfo(player)
    else
        triggerClientEvent ( player, "infobox_start", player, "\n\nDu bist nicht befugt!", 3100, 125, 0, 0 )
    end
end)

addCommandHandler("fpruefung", function(player, cmd, targetName, fschein)
    local target = getPlayerFromName(targetName)
    local fscheinUpper = string.upper(fschein or "")
    
    if not target then
        outputChatBox("Der angegebene Spieler konnte nicht gefunden werden.", player, 255, 0, 0)
        return
    end

    local allowedScheine = ""
    for schein, _ in pairs(fschein_LICENSES) do
        allowedScheine = allowedScheine .. string.lower(schein) .. ", "
    end
    allowedScheine = string.sub(allowedScheine, 1, #allowedScheine - 2)
    
    if not fschein or not fschein_LICENSES[fscheinUpper] then
        outputChatBox("Ungültige Führerscheinklasse: '"..tostring(fschein).."'.", player, 255, 150, 0)
        outputChatBox("Erlaubt sind: "..allowedScheine, player, 255, 150, 0)
        outputChatBox("Verwendung: /fpruefung [Spieler] [Schein]", player, 255, 150, 0)
        return
    end

    if not fschein_ROUTE_READY[fscheinUpper] then
        outputChatBox("Fuer den Schein '"..fschein.."' ist die praktische Pruefungsstrecke noch nicht eingerichtet. Bitte wende dich an einen Administrator.", player, 255, 150, 0)
        return
    end

    if isFahrschuleDuty(player) then
        local veh = getPedOccupiedVehicle(player)

        if fahrschulVehicles[veh] and fschein then
            
            local lehrerName = getPlayerName(player)
            
            outputChatBox("Du hast "..lehrerName.." die Fahrprüfung für den Schein "..fschein.." angeboten.", player, 255, 255, 255)
            
            outputChatBox("Fahrlehrer "..lehrerName.." bietet dir an, die Fahrprüfung für den Schein '"..fschein.."' abzulegen.", target, 255, 255, 255)
            outputChatBox("Verwende /faccept "..lehrerName.." um das Angebot anzunehmen.", target, 255, 255, 255)
            
            MtxSetElementData( target, "infahrpruefung", fscheinUpper)
            MtxSetElementData( target, "fahrschullehrername", lehrerName)
            examVehicleFor[target] = veh -- Fallback, siehe holeExamFahrzeug
            
        else
            outputChatBox("Du bist entweder nicht in einem Fahrschulauto oder hast keinen gültigen Führerscheintyp (z.B. A, B) angegeben.", player, 255, 255, 255)
        end
    else
        outputChatBox("Du musst im Dienst sein, um eine Prüfung anzubieten.", player, 255, 0, 0)
    end
end)

function resetPruefungsData(target)
    MtxSetElementData(target, "inpruefung", false)
    MtxSetElementData(target, "inpruefungType", nil)
    MtxSetElementData(target, "infahrpruefung", false) -- Löscht das ausstehende Angebot
    MtxSetElementData(target, "fahrschullehrername", nil) -- Löscht den gespeicherten Lehrer
    if speedStrikes then speedStrikes[target] = nil end -- siehe fahrschule_praxis_aufgaben.lua
    examVehicleFor[target] = nil
end

-- Liefert das Fahrzeug, das der Spieler gerade waehrend der Pruefung faehrt -
-- oder falls er zwischenzeitlich schon ausgestiegen ist (z.B. nach Abfahren
-- der letzten Markierung, wartend auf /stoppruefung), das zuletzt bestaetigte
-- Pruefungsfahrzeug (siehe onMarkerHit weiter unten, das examVehicleFor pflegt).
function holeExamFahrzeug(player)
    return getPedOccupiedVehicle(player) or examVehicleFor[player]
end

-- Setzt ein Fahrschulfahrzeug (egal ob Auto/LKW/Motorrad/Heli/Boot) zurueck an
-- seinen Ursprungsort und macht es wieder normal zerstoerbar (die Unzerstoer-
-- barkeit gilt nur waehrend einer laufenden Pruefung/Fahrt, siehe
-- fahrschule_cars.lua). Stellt bei einem LKW zusaetzlich einen evtl.
-- angehaengten Anhaenger an dessen Ursprungsort zurueck. Wird nach JEDEM Ende
-- einer Pruefung aufgerufen - bestanden, durchgefallen oder abgebrochen.
function resetFahrschulFahrzeug(theVehicle)
    if isElement(theVehicle) and fahrschulVehicles[theVehicle] then
        setVehicleDamageProof(theVehicle, false)
        respawnVehicle(theVehicle)
        setElementFrozen(theVehicle, true)
        if findeAnhaengerPaarFuerTruck then
            setzeAnhaengerZurueck(findeAnhaengerPaarFuerTruck(theVehicle))
        end
    end
end

-- Lässt einen Schüler die praktische Prüfung automatisch (ohne Fahrlehrer-
-- Kurze Sperre nach einer durchgefallenen/abgebrochenen Pruefung, damit nicht
-- sofort im Sekundentakt neu angetreten werden kann. Gilt fuer JEDE Art des
-- Nicht-Bestehens (manuell vom Lehrer, automatisch, Abbruch durch Aussteigen
-- oder Disconnect) - siehe markiereDurchfall weiter unten.
local PRUEFUNG_COOLDOWN_MS = 5 * 60 * 1000 -- 5 Minuten
local letzterDurchfall = {} -- [player] = Tickcount des letzten Durchfallens/Abbruchs

function markiereDurchfall(player)
    if isElement(player) then
        letzterDurchfall[player] = getTickCount()
    end
end

-- Eingriff) durchfallen, z.B. wegen wiederholten zu schnellen Fahrens oder
-- eines unerwartet gelösten Anhängers. Räumt Checkpoint-Marker/-Blip aus dem
-- laufenden Versuch mit auf, damit beim naechsten Versuch nichts hängen bleibt.
function automatischDurchgefallen(target, grund)
    if not isElement(target) or MtxGetElementData(target, "inpruefung") ~= true then return end
    markiereDurchfall(target)

    outputChatBox("Du bist durchgefallen: "..grund, target, 255, 0, 0)
    outputChatBox("Du musst die praktische Prüfung neu beginnen.", target, 255, 0, 0)

    local lehrerName = MtxGetElementData(target, "fahrschullehrername")
    local lehrer = lehrerName and getPlayerFromName(lehrerName)
    if lehrer then
        outputChatBox(getPlayerName(target).." ist automatisch durchgefallen: "..grund, lehrer, 255, 0, 0)
    end

    if currentTestBlip[target] and isElement(currentTestBlip[target]) then
        destroyElement(currentTestBlip[target])
        currentTestBlip[target] = nil
    end
    if currentTestMarker[target] and isElement(currentTestMarker[target]) then
        destroyElement(currentTestMarker[target])
        currentTestMarker[target] = nil
    end

    -- Fahrzeug (falls noch besetzt) zurueck an seinen Ursprungsort respawnen
    -- und wieder normal zerstoerbar machen - soll nicht dauerhaft unzerstoerbar bleiben.
    resetFahrschulFahrzeug(holeExamFahrzeug(target))

    resetPruefungsData(target)
end

addCommandHandler( "faccept", function(player, cmd, targetName)

	if MtxGetElementData(player, "inpruefung")  then
        outputChatBox("Du bist bereits in einer Fahrprüfung.", player, 255, 0, 0)
        return
	end

	if letzterDurchfall[player] then
		local rest = PRUEFUNG_COOLDOWN_MS - (getTickCount() - letzterDurchfall[player])
		if rest > 0 then
			outputChatBox("Nach einer durchgefallenen/abgebrochenen Pruefung musst du noch "..math.ceil(rest / 1000).." Sekunden warten.", player, 255, 150, 0)
			return
		end
	end

    local instructorElement = getPlayerFromName(targetName)
    if not instructorElement then
        outputChatBox("Fahrlehrer nicht gefunden.", player, 255, 0, 0)
        return
    end
    
    local instructorName = getPlayerName(instructorElement)

    local fschein = MtxGetElementData(player, "infahrpruefung")
    local storedLehrerName = MtxGetElementData(player, "fahrschullehrername")
    
    if fschein and storedLehrerName == instructorName then
        
        MtxSetElementData(player, "inpruefung", true)
        MtxSetElementData(player, "inpruefungType", fschein)

        sendMSGForFaction("Spieler "..getPlayerName(player).." hat die Fahrprüfung für den Schein '"..fschein.."' angenommen.", 15, 0, 125, 0)
        outputChatBox("Prüfung für Schein '"..fschein.."' angenommen. Folge dem Marker.", player, 0, 255, 0)
        
        outputChatBox(getPlayerName(player).." hat dein Angebot für die Prüfung angenommen. Fahrt vorsichtig!", instructorElement, 0, 255, 0, true)

        createTestMarker(player, 1, fschein)
    else
        outputChatBox("Du hast kein passendes, ausstehendes Prüfungsangebot von diesem Fahrlehrer.", player, 255, 0, 0)
    end
end)

local fahrschulrufmarker = createMarker(-2033.05859375, -117.375, 1035.171875, "cylinder", -0.95, 255, 255, 255)
setElementDimension(fahrschulrufmarker,0)
setElementInterior(fahrschulrufmarker,3)

addEventHandler("onMarkerHit", fahrschulrufmarker, function(player)
    outputChatBox("Verwende /fahrschule um einen Lehrer zu rufen", player, 255, 255, 255)
    outputChatBox("Verwende /infos um Information von den Lizenzen scheinen zu kriegen", player, 255, 255, 255)
end)

function fahrschuleinfo(player)
    local xd,yd,zd = getElementPosition(player)
    if getDistanceBetweenPoints3D( xd,yd,zd, -2033.05859375, -117.375, 1035.171875) <= 4 then
        outputChatBox("Die Lizenzen die du erhalten kannst",player,255,255,255)
        outputChatBox("Auto Führerschein Preis 2000 " ..Tables.waehrung,player,255,255,255)
        outputChatBox("LKW Führerschein Preis 2700 " ..Tables.waehrung,player,255,255,255)
        outputChatBox("Motorrad Führerschein Preis 2400 " ..Tables.waehrung,player,255,255,255)
        outputChatBox("Helikopter Führerschein Preis 10000 " ..Tables.waehrung,player,255,255,255)
        outputChatBox("Boots Führerschein Preis 20000 " ..Tables.waehrung,player,255,255,255)
    else
        outputChatBox("Du bist zu weit entfernt von dem Marker",player,255,255,255)
    end
end
addCommandHandler("infos",fahrschuleinfo)

addCommandHandler("fahrschule", function(player)
    local xd,yd,zd = getElementPosition(player)
    if not isFahrschule(player) then
        if getFactionMembersOnline(15) >= 1 then
            if getDistanceBetweenPoints3D( xd,yd,zd, -2033.05859375, -117.375, 1035.171875) <= 4 then
                sendMSGForFaction( "Spieler "..getPlayerName(player).." benötigt einen Fahrlehrer. begib dich zur Fahrschule", 15, 0, 125, 0)
                outputChatBox("Du hast nun einen Fahrlehrer gerufen", player,255, 255, 255)
            else
                outputChatBox("Du bist nicht an der Fahrschule", player, 255, 255, 255)
            end
        else
            outputChatBox("Derzeit ist kein Fahrlehrer online!", player, 255, 255, 255)
        end     
    else
        outputChatBox("Du bist Fahrlehrer Warum rufst du deinesgleichen an?", player, 255, 255, 255) 
    end
end)


function beendepruefung(player, cmd, targetName, fschein)
    local target = getPlayerFromName(targetName)
    if isFahrschule(player) and isFahrschuleDuty ( player ) then
        if (target) then
            if MtxGetElementData(target, "inpruefung") == true and MtxGetElementData(target, "fahrschullehrername") == getPlayerName(player) then
                if (fschein == "auto") or (fschein == "lkw") or (fschein == "motorrad") or (fschein == "heli") or (fschein == "boot") or (fschein == "durchgefallen") then
                    if (fschein == "auto") then
                        if MtxGetElementData(target,"inpruefung") == true then
                            if MtxGetElementData(target, "money") >= 2000 then
                                MtxSetElementData(target,"carlicense", 1)
                                MtxSetElementData( target, "money", tonumber(MtxGetElementData(target, "money")) -2000)
                                MtxSetElementData( player, "money", tonumber(MtxGetElementData(player, "money")) +2000)
                                grantIntroTaskReward(target,"give:führerschein")
                                dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Autofuehrerschein", 1, "UID", playerUID[getPlayerName( target )])
                                outputChatBox("Du hast den Führerschein erhalten", target, 125, 125, 0)
                                outputChatBox("Dir wurden 2000 "..Tables.waehrung.." für den Führerschein abgezogen.", target, 200, 200, 0)
                                outputChatBox("Du hast 2000 "..Tables.waehrung.." von "..getPlayerName(target).." für die Prüfung erhalten.", player, 0, 200, 0)
								resetFahrschulFahrzeug(holeExamFahrzeug(target))
								resetPruefungsData(target)
                            else
                                outputChatBox("Du hast nicht genug Geld dabei 2000 "..Tables.waehrung, target, 125, 125, 0)
                                outputChatBox(getPlayerName(target).." hat nicht genug Geld für den Führerschein (2000 "..Tables.waehrung..")!", player, 255, 0, 0)
                            end
                        end 
                    elseif (fschein == "lkw") then
                        if MtxGetElementData(target,"inpruefung") == true then
                            if MtxGetElementData(target, "money") >= 2700 then
                                MtxSetElementData ( target, "lkwlicense", 1 )
                                MtxSetElementData( target, "money", tonumber(MtxGetElementData(target, "money")) -2700)
                                MtxSetElementData( player, "money", tonumber(MtxGetElementData(player, "money")) +2700)
                                grantIntroTaskReward(target,"give:lkwschein")
                                dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "LKWfuehrerschein", 1, "UID", playerUID[getPlayerName( target )])
                                outputChatBox("Du hast den LKW-Schein erhalten", target, 125, 125, 0)
                                outputChatBox("Dir wurden 2700 "..Tables.waehrung.." für den LKW-Schein abgezogen.", target, 200, 200, 0)
                                outputChatBox("Du hast 2700 "..Tables.waehrung.." von "..getPlayerName(target).." für die Prüfung erhalten.", player, 0, 200, 0)
								resetFahrschulFahrzeug(holeExamFahrzeug(target))
								resetPruefungsData(target)
                            else
                                outputChatBox("Du hast nicht genug Geld dabei 2700 "..Tables.waehrung, target, 125, 125, 0)
                                outputChatBox(getPlayerName(target).." hat nicht genug Geld für den LKW-Schein (2700 "..Tables.waehrung..")!", player, 255, 0, 0)
                            end
                        end 
                    elseif (fschein == "motorrad") then
                        if MtxGetElementData(target,"inpruefung") == true then
                            if MtxGetElementData(target, "money") >= 2400 then
                                MtxSetElementData ( target, "bikelicense", 1 )
                                MtxSetElementData( target, "money", tonumber(MtxGetElementData(target, "money")) -2400)
                                MtxSetElementData( player, "money", tonumber(MtxGetElementData(player, "money")) +2400)
                                dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Motorradtfuehrerschein", 1, "UID", playerUID[getPlayerName( target )])
                                outputChatBox("Du hast den Motorradschein erhalten", target, 125, 125, 0)
                                outputChatBox("Dir wurden 2400 "..Tables.waehrung.." für den Motorradschein abgezogen.", target, 200, 200, 0)
                                outputChatBox("Du hast 2400 "..Tables.waehrung.." von "..getPlayerName(target).." für die Prüfung erhalten.", player, 0, 200, 0)
								resetFahrschulFahrzeug(holeExamFahrzeug(target))
								resetPruefungsData(target)
                            else
                                outputChatBox("Du hast nicht genug Geld dabei 2400 "..Tables.waehrung, target, 125, 125, 0)
                                outputChatBox(getPlayerName(target).." hat nicht genug Geld für den Motorradschein (2400 "..Tables.waehrung..")!", player, 255, 0, 0)
                            end
                        end 
                    elseif (fschein == "heli") then
                        if MtxGetElementData(target,"inpruefung") == true then
                            if MtxGetElementData(target, "money") >= 10000 then
                                MtxSetElementData ( target, "helilicense", 1 )
                                dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Helikopterfuehrerschein", 1, "UID", playerUID[getPlayerName( target )])
                                MtxSetElementData( target, "money", tonumber(MtxGetElementData(target, "money")) -10000)
                                MtxSetElementData( player, "money", tonumber(MtxGetElementData(player, "money")) +10000)
                                outputChatBox("Du hast den Helikopterschein erhalten", target, 125, 125, 0)
                                outputChatBox("Dir wurden 10000 "..Tables.waehrung.." für den Helikopterschein abgezogen.", target, 200, 200, 0)
                                outputChatBox("Du hast 10000 "..Tables.waehrung.." von "..getPlayerName(target).." für die Prüfung erhalten.", player, 0, 200, 0)
								resetFahrschulFahrzeug(holeExamFahrzeug(target))
								resetPruefungsData(target)
                            else
                                outputChatBox("Du hast nicht genug Geld dabei 10000 "..Tables.waehrung, target, 125, 125, 0)
                                outputChatBox(getPlayerName(target).." hat nicht genug Geld für den Helikopterschein (10000 "..Tables.waehrung..")!", player, 255, 0, 0)
                            end
                        end 
                    elseif (fschein == "boot") then
                        if MtxGetElementData(target,"inpruefung") == true then
                            if MtxGetElementData(target, "money") >= 20000 then
                                MtxSetElementData ( target, "motorbootlicense", 1 )
                                MtxSetElementData( target, "money", tonumber(MtxGetElementData(target, "money")) -20000)
                                MtxSetElementData( player, "money", tonumber(MtxGetElementData(player, "money")) +20000)
                                dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Motorbootschein", 1, "UID", playerUID[getPlayerName( target )])
                                outputChatBox("Du hast den Motorbootschein erhalten", target, 125, 125, 0)
                                outputChatBox("Dir wurden 20000 "..Tables.waehrung.." für den Motorbootschein abgezogen.", target, 200, 200, 0)
                                outputChatBox("Du hast 20000 "..Tables.waehrung.." von "..getPlayerName(target).." für die Prüfung erhalten.", player, 0, 200, 0)
								resetFahrschulFahrzeug(holeExamFahrzeug(target))
								resetPruefungsData(target)
                            else
                                outputChatBox("Du hast nicht genug Geld dabei 20000 "..Tables.waehrung, target, 125, 125, 0)
                                outputChatBox(getPlayerName(target).." hat nicht genug Geld für den Motorbootschein (20000 "..Tables.waehrung..")!", player, 255, 0, 0)
                            end
                        end 
                    elseif (fschein == "durchgefallen") then
						outputChatBox("Du bist durchgefallen!", target, 125, 125, 0)
						markiereDurchfall(target)
						resetFahrschulFahrzeug(holeExamFahrzeug(target))
						resetPruefungsData(target)
                    else
                        outputChatBox("Bitte Schein angeben", player, 125, 125, 0)
                        outputChatBox("Scheine: auto, lkw, motorrad, heli, boot, durchgefallen", player, 255, 153, 0)
                    end
                else
                    outputChatBox("Bitte gib einen gültigen Schein an", player, 125, 125, 0)
                    outputChatBox("Scheine: auto, lkw, motorrad, heli, boot, durchgefallen", player, 255, 153, 0)
                end

            else
                outputChatBox("Der Spieler ist nicht in einer aktiven Fahrprüfung.", player, 125, 125, 0)
            end
        else
            outputChatBox("Du bist nicht befugt", player, 125, 125, 0)
        end
    end
end
addCommandHandler("stoppruefung", beendepruefung)


function createTestMarker(thePlayer, markerCount, fschein)
    local coordsTable
    local fscheinUpper = string.upper(fschein or "")

    if fscheinUpper == "AUTO" then
        coordsTable = carTestCoords
    elseif fscheinUpper == "MOTORRAD" then
        coordsTable = bikeTestCoords
    elseif fscheinUpper == "LKW" then
        coordsTable = lkwTestCoords
    elseif fscheinUpper == "HELI" then
        coordsTable = heliTestCoords
    elseif fscheinUpper == "BOOT" then
        coordsTable = bootTestCoords
    else
        outputChatBox("Fehler: Unbekannter Schein-Typ für die praktische Prüfung.", thePlayer, 255, 0, 0)
        return false
    end
    
    if not coordsTable or type(coordsTable) ~= "table" or #coordsTable == 0 then
        outputChatBox("Fehler: Es wurden keine gültigen Testkoordinaten für diesen Schein gefunden.", thePlayer, 255, 0, 0)
        return false
    end
    
    if markerCount > #coordsTable then
        outputChatBox("Die praktische Prüfung ist beendet!", thePlayer, 0, 255, 0, true)
        outputChatBox("Warte auf die Anweisungen deines Fahrlehrers zum Abschluss.", thePlayer, 255, 255, 0, true)

        local fahrschullehrerName = MtxGetElementData(thePlayer, "fahrschullehrername")
        local fahrschullehrerElement = getPlayerFromName(fahrschullehrerName)

        if fahrschullehrerElement and isElement(fahrschullehrerElement) then
            outputChatBox("Der Fahrschüler "..getPlayerName(thePlayer).." hat die praktische Prüfung beendet.", fahrschullehrerElement, 255, 165, 0)
            outputChatBox("VERWENDUNG: Bitte nutze /stoppruefung "..getPlayerName(thePlayer).." [ "..fscheinUpper.." / durchgefallen ].", fahrschullehrerElement, 255, 165, 0)
            
            outputChatBox("INFO: Dein Fahrlehrer ist benachrichtigt worden. Warte auf seine Anweisungen.", thePlayer, 255, 165, 0)
            
        else
            sendMSGForFaction("ACHTUNG! Fahrschüler "..getPlayerName(thePlayer).." hat die Prüfung ("..fscheinUpper..") beendet. Sein Lehrer ("..fahrschullehrerName..") ist offline. Ein Ersatz wird benötigt.", 15, 255, 165, 0)
            outputChatBox("INFO: Dein Fahrlehrer ist nicht mehr online. Ein anderer Fahrlehrer wurde benachrichtigt, um abzuschließen.", thePlayer, 255, 165, 0)
        end
        
        if currentTestBlip[thePlayer] and isElement(currentTestBlip[thePlayer]) then
            destroyElement(currentTestBlip[thePlayer])
            currentTestBlip[thePlayer] = nil
        end
        
        if currentTestMarker[thePlayer] and isElement(currentTestMarker[thePlayer]) then
             destroyElement(currentTestMarker[thePlayer])
        end
        
        currentTestMarker[thePlayer] = nil
        return
    end

    local coords = coordsTable[markerCount]
    local marker = createMarker(coords.x, coords.y, coords.z - 1.0, "cylinder", -0.95, 0, 150, 255, 200)
    setMarkerSize(marker, 3)

    setElementData(marker, "examPlayer", thePlayer)
    setElementData(marker, "markerIndex", markerCount)
    
    if currentTestMarker[thePlayer] and isElement(currentTestMarker[thePlayer]) then
         destroyElement(currentTestMarker[thePlayer])
    end
    currentTestMarker[thePlayer] = marker


    if currentTestBlip[thePlayer] and isElement(currentTestBlip[thePlayer]) then
        destroyElement(currentTestBlip[thePlayer])
    end
    
    currentTestBlip[thePlayer] = createBlipAttachedTo(marker, 0, 2, 255, 0, 255, 255, 0, 16383.0, thePlayer)

    zeigeAbbiegehinweis(thePlayer, coordsTable, markerCount)

    outputChatBox("Fahre zur Markierung " .. markerCount .. "/" .. #coordsTable .. "!", thePlayer, 255, 255, 0)
end

function onMarkerHit(hitElement)
    if not isElement(source) or getElementType(source) ~= "marker" then
        return
    end
    if not isElement(hitElement) then
        return
    end

    local examPlayer = getElementData(source, "examPlayer")
    local markerIndex = getElementData(source, "markerIndex")

    local playerToTest = nil
    if getElementType(hitElement) == "player" then
        playerToTest = hitElement
    elseif getElementType(hitElement) == "vehicle" then
        playerToTest = getVehicleController(hitElement)
    end

    if playerToTest and playerToTest == examPlayer then
        local occupiedVehicle = getPedOccupiedVehicle(playerToTest)
        if occupiedVehicle and fahrschulVehicles[occupiedVehicle] then
            examVehicleFor[playerToTest] = occupiedVehicle
            destroyElement(source)
			destroyElement(currentTestBlip[playerToTest])
            local fschein = MtxGetElementData(examPlayer, "infahrpruefung")
            createTestMarker(playerToTest, markerIndex + 1, fschein)
        end
    end
end
addEventHandler("onMarkerHit", root, onMarkerHit)

function onPlayerQuitVehicle(player, seat, jacked)
    local theVehicle = source -- onVehicleExit wird auf dem Fahrzeug ausgeloest, nicht getPedOccupiedVehicle(player) - der Spieler ist zu diesem Zeitpunkt schon draussen
    if seat == 0 or fahrschulVehicles[theVehicle] then
        if currentTestMarker[player] then
            outputChatBox("Prüfung abgebrochen: Du bist aus dem Fahrzeug ausgestiegen.", player, 255, 0, 0)
            markiereDurchfall(player)
            destroyElement(currentTestMarker[player])
            currentTestMarker[player] = nil

            if currentTestBlip[player] then
				destroyElement(currentTestBlip[player])
				currentTestBlip[player] = nil
			end

			-- Fahrzeug zurueck an seinen Ursprungsort respawnen und wieder
			-- normal zerstoerbar machen.
			resetFahrschulFahrzeug(theVehicle)

			resetPruefungsData(player)
        end
    end
end
addEventHandler("onVehicleExit", getRootElement(), onPlayerQuitVehicle)

local drivingSchoolMarker = createMarker(-2033.181640625, -115.7138671875, 1035.171875, "cylinder", -0.95, 255, 140, 0, 150)
setElementInterior(drivingSchoolMarker,3)
setElementDimension(drivingSchoolMarker,0)

function onMarkerEnter(player)
    if getElementType(player) == "player" then
        outputChatBox("Gebe /fuehrerschein ein, um die theoretische Pruefung zu beginnen.", player, 200, 200, 0)
    end
end
addEventHandler("onMarkerHit", drivingSchoolMarker, onMarkerEnter)

function startTheoriePruefung(player)
    if not isElementWithinMarker(player, drivingSchoolMarker) then
        outputChatBox("Du musst dich im Pruefungsbereich befinden, um diesen Befehl zu nutzen.", player, 255, 0, 0)
        return
    end

    if MtxGetElementData(player, "hatTheorieBestanden") then
        outputChatBox("Du hast die theoretische Pruefung bereits abgeschlossen!", player, 255, 0, 0)
    else
        triggerClientEvent(player, "startDrivingLicenseTheory", player)
        outputChatBox("Du hast 7 Fragen, von denen du mindestens 5 richtig beantworten musst.", player, 200, 200, 0)
    end
end
addCommandHandler("fuehrerschein", startTheoriePruefung)

function handlePruefungErgebnis(correctAnswers)
    local player = client
    local minCorrect = 5

    if correctAnswers and correctAnswers >= minCorrect then
        outputChatBox("Herzlichen Glueckwunsch! Du hast die theoretische Pruefung bestanden.", player, 0, 255, 0)
        outputChatBox("Bitte kontaktiere einen Fahrlehrer fuer die praktische Pruefung.", player, 0, 255, 0)
        MtxSetElementData(player, "hatTheorieBestanden", true)

        -- War vorher "MtxGetElementData(player, 'UID')" - dieser Element-Data-Key
        -- wird im ganzen Projekt nirgends gesetzt, war also immer nil und hat die
        -- DB-Speicherung stillschweigend uebersprungen. Die UID steht stattdessen
        -- in der globalen playerUID-Tabelle (wie ueberall sonst im Skript).
        local uid = playerUID[getPlayerName(player)]
        if uid then
            dbExec(handler, "UPDATE userdata SET hatTheorieBestanden = ? WHERE UID = ?", 1, uid)
        end
        

        for i, fahrschulePlayer in ipairs(getElementsByType("player")) do
            if isFahrschule(fahrschulePlayer) and isFahrschuleDuty(fahrschulePlayer) then
                outputChatBox("Theorie bestanden: Der Spieler " .. getPlayerName(player) .. " hat die Theoriepruefung bestanden.", fahrschulePlayer, 0, 255, 0)
            end
        end
    else
        outputChatBox("Leider hast du die Pruefung nicht bestanden. Du hattest nur "..tostring(correctAnswers or 0).." von 7 Fragen richtig.", player, 255, 0, 0)
        outputChatBox("Bitte lerne und versuche es spaeter erneut.", player, 255, 0, 0)
    end
end
addEvent("pruefungErgebnis", true)
addEventHandler("pruefungErgebnis", root, handlePruefungErgebnis)


-- ####################################################################
-- NEUESTER STAND: Disconnect-Absicherung waehrend einer Pruefung
-- ####################################################################
-- Bisher gab es dafuer keinen Schutz: onVehicleExit (siehe
-- onPlayerQuitVehicle oben) faengt zwar das normale Aussteigen ab, aber
-- nicht zuverlaessig ein plötzliches Verbindungsende. Zwei Faelle:
--   1. Der PRUEFLING selbst disconnected mitten in der Pruefung - ohne das
--      hier wuerde das (bei einem erneuten Login-Versuch mit demselben
--      Account) evtl. zu einem haengenden "inpruefung"-Zustand fuehren.
--   2. Der FAHRLEHRER disconnected, waehrend er gerade jemanden prueft -
--      der Schueler waere sonst dauerhaft blockiert, weil laut
--      beendepruefung() nur GENAU dieser Lehrername abschliessen darf.
local function bricheFahrpruefungAb(pruefling)
    if currentTestMarker[pruefling] and isElement(currentTestMarker[pruefling]) then
        destroyElement(currentTestMarker[pruefling])
    end
    currentTestMarker[pruefling] = nil

    if currentTestBlip[pruefling] and isElement(currentTestBlip[pruefling]) then
        destroyElement(currentTestBlip[pruefling])
    end
    currentTestBlip[pruefling] = nil

    resetFahrschulFahrzeug(holeExamFahrzeug(pruefling))
    markiereDurchfall(pruefling)
    resetPruefungsData(pruefling)
end

addEventHandler("onPlayerQuit", getRootElement(), function()
    local disconnectedName = getPlayerName(source)

    -- Fall 1: der Aussteigende war selbst mitten in einer Pruefung.
    if MtxGetElementData(source, "inpruefung") == true then
        bricheFahrpruefungAb(source)
    end

    -- Fall 2: der Aussteigende war Fahrlehrer und hat gerade jemanden geprueft.
    for _, spieler in ipairs(getElementsByType("player")) do
        if spieler ~= source and MtxGetElementData(spieler, "inpruefung") == true
           and MtxGetElementData(spieler, "fahrschullehrername") == disconnectedName then
            outputChatBox("Dein Fahrlehrer hat den Server verlassen - die Pruefung wurde abgebrochen. Bitte erneut anfragen.", spieler, 255, 150, 0)
            bricheFahrpruefungAb(spieler)
        end
    end
end)