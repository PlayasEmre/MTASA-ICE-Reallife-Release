--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local gHalloweenButton = {}

-- Echte Tuerklingel statt des Duell-Glockenklangs ( sounds/klingel.mp3 ist
-- bereits im Skript und in meta.xml eingetragen, wird sonst fuer den
-- Bankraub-Alarm genutzt - hier einfach am eigenen Bildschirm statt 3D am Ort ).
addEvent ( "haustuerKlingel", true )
addEventHandler ( "haustuerKlingel", getRootElement(), function ()
	local sound = playSound ( ":"..getResourceName ( getThisResource () ).."/sounds/klingel.mp3", false )
	if sound then setSoundVolume ( sound, 0.4 ) end
end )

---------------------------------------------------------------------
-- "Kuerbis"-Text ueber den Kuerbis-Objekten
---------------------------------------------------------------------
-- Der Shader-Klebe-Versuch wurde endgueltig aufgegeben. Stattdessen
-- dieselbe dxDrawTextOnElement-Funktion wie beim Kopf-Text des Halloween-
-- Haendlers und des Zombie-Waechters - nachweislich funktionsfaehig.
local kuerbisObjekte = {}  -- Objekt -> true

local function pruefeKuerbisMarkierung ( el )
	if getElementType ( el ) == "object" and getElementData ( el, "istKuerbis" ) == true then
		kuerbisObjekte[el] = true
	end
end

addEventHandler ( "onClientElementStreamIn", root, function () pruefeKuerbisMarkierung ( source ) end )
addEventHandler ( "onClientElementDataChange", root, function ( key )
	if key ~= "istKuerbis" then return end
	if getElementData ( source, "istKuerbis" ) == true then
		kuerbisObjekte[source] = true
	else
		kuerbisObjekte[source] = nil
	end
end )
addEventHandler ( "onClientElementStreamOut", root, function () kuerbisObjekte[source] = nil end )
addEventHandler ( "onClientElementDestroy", root, function () kuerbisObjekte[source] = nil end )

addEventHandler ( "onClientRender", root, function ()
	for obj in pairs ( kuerbisObjekte ) do
		if isElement ( obj ) then
			dxDrawTextOnElement ( obj, "Kürbis", 1.1, 20, 255, 140, 0, 255, 1.6, "sans" )
		else
			kuerbisObjekte[obj] = nil
		end
	end
end )

-- Der Text ueber dem Kopf des Haendlers steht jetzt in
-- dxDrawTextOnElement/dxDrawTextOnElement.lua, zusammen mit allen anderen
-- Kopf-Texten im Skript ( Fahrzeugverleih, Shops, Geldautomaten, ... ).

-- Kennung fuer den Server, Beschriftung, Preis in Kuerbissen.
local BELOHNUNGEN = {
	{ "premium",     "Premium\n30 Tage",         60 },
	{ "Süßigkeit",   "Süßigkeiten",              10 },
	{ "kettensaege", "Kettensäge",               25 },
	{ "titel",       "Titel:\nKürbis-König",     20 },
	{ "zombieskin",  "Zombie-Skin\n(/zombieskin)", 40 },
	{ "leichenwagen","Leichenwagen\n(exklusiv)", 120 },
}

local SPALTEN   = 3
local KNOPF_B   = 150
local KNOPF_H   = 62
local ABSTAND   = 10
local RAND      = 12

function closeHalloweenGUI ()
	if isElement ( gWindow["halloweenMenue"] ) then
		destroyElement ( gWindow["halloweenMenue"] )
		gHalloweenButton = {}
		showCursor ( false )
		setElementClicked ( false )
	end
end

function createHalloweenGUI ()

	if not event.isHalloween then return end
	if getElementClicked () then return end

	showCursor ( true )
	setElementClicked ( true )

	local zeilen = math.ceil ( #BELOHNUNGEN / SPALTEN )
	local breite = RAND * 2 + SPALTEN * KNOPF_B + ( SPALTEN - 1 ) * ABSTAND
	local hoehe  = 30 + RAND + zeilen * ( KNOPF_H + ABSTAND ) + KNOPF_H

	local x, y = guiGetScreenSize ()
	gWindow["halloweenMenue"] = dgsCreateWindow ( x/2 - breite/2, y/2 - hoehe/2, breite, hoehe,
		"Halloween-Stand   -   deine Kürbisse: "..vioClientGetElementData ( "kuerbisse" ), false )
	dgsWindowSetMovable ( gWindow["halloweenMenue"], false )
	dgsWindowSetSizable ( gWindow["halloweenMenue"], false )
	dgsWindowSetCloseButtonEnabled ( gWindow["halloweenMenue"], false )

	for i = 1, #BELOHNUNGEN do
		local eintrag = BELOHNUNGEN[i]
		local spalte  = ( i - 1 ) % SPALTEN
		local zeile   = math.floor ( ( i - 1 ) / SPALTEN )

		gHalloweenButton[i] = dgsCreateButton (
			RAND + spalte * ( KNOPF_B + ABSTAND ),
			RAND + zeile * ( KNOPF_H + ABSTAND ),
			KNOPF_B, KNOPF_H,
			eintrag[2].."\n"..eintrag[3].." Kürbisse",
			false, gWindow["halloweenMenue"], _, _, _, _, _, _,
			tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255) )

		addEventHandler ( "onDgsMouseClickUp", gHalloweenButton[i], function ( btn )
			if btn ~= "left" then return end
			triggerServerEvent ( "buyEasterBonus", lp, eintrag[1] )
			closeHalloweenGUI ()
		end, false )
	end

	gButton["halloweenClose"] = dgsCreateButton (
		RAND, RAND + zeilen * ( KNOPF_H + ABSTAND ),
		breite - RAND * 2, KNOPF_H - 20, "Schließen",
		false, gWindow["halloweenMenue"], _, _, _, _, _, _,
		tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255) )
	addEventHandler ( "onDgsMouseClickUp", gButton["halloweenClose"], function ( btn )
		if btn == "left" then closeHalloweenGUI () end
	end, false )
end

-- Geoeffnet wird nur noch am Stand ( events/halloween_server.lua ). Die frueher
-- fest belegte Taste H ist damit wieder frei.
addEvent ( "oeffneHalloweenMenue", true )
addEventHandler ( "oeffneHalloweenMenue", getRootElement(), createHalloweenGUI )

---------------------------------------------------------------------
-- Zombie-Nacht: Skins und Stoehnen
---------------------------------------------------------------------
-- Skins stammen aus "Zday script" (slothman, MTA-Community-Resource 347).
-- engineImportTXD reskinnt ein GTA-Basismodell GLOBAL fuer diesen Client,
-- nicht nur den einen Ped - deshalb nur waehrend der eigenen Zombie-Nacht
-- aktiv und danach mit engineRestoreModel wieder zurueckgesetzt. Modelle 192
-- und 229 fehlen bewusst: die nutzt fun/Museumraub/Client.lua fuer eigene
-- NPCs, ein dauerhafter Import haette die permanent zu Zombies gemacht.
local ZOMBIE_SKINS = {13,22,56,67,68,69,70,92,97,105,107,108,126,127,128,152,162,167,188,195,206,209,212,230,258,264,277,280,287}
local zombieSkinsAktiv = false

-- Zwei unabhaengige Gruende, warum die Skins an sein sollen: eine laufende
-- Runde ( vom Server ) und die Naehe zum Waechter-Deko-Ped am Stand ( lokal
-- berechnet ). Nur wenn BEIDE aus sind, wird tatsaechlich zurueckgesetzt -
-- sonst wuerde das Verlassen der Naehe die Skins mitten in einer laufenden
-- Runde in der Arena abschalten, obwohl man dort noch Zombies bekaempft.
local rundeAktiv = false
local naeheAktiv = false

local function zombieSkinsAn ()
	if zombieSkinsAktiv then return end
	zombieSkinsAktiv = true
	for i = 1, #ZOMBIE_SKINS do
		local modell = ZOMBIE_SKINS[i]
		local txd = engineLoadTXD ( "events/zombienacht_assets/skins/"..modell..".txd" )
		if txd then
			engineImportTXD ( txd, modell )
		end
	end
end

local function zombieSkinsAus ()
	if not zombieSkinsAktiv then return end
	zombieSkinsAktiv = false
	for i = 1, #ZOMBIE_SKINS do
		engineRestoreModel ( ZOMBIE_SKINS[i] )
	end
end

local function zombieSkinsAktualisieren ()
	if rundeAktiv or naeheAktiv then
		zombieSkinsAn ()
	else
		zombieSkinsAus ()
	end
end

addEvent ( "zombieNachtSkinsAn", true )
addEventHandler ( "zombieNachtSkinsAn", getRootElement(), function ()
	rundeAktiv = true
	zombieSkinsAktualisieren ()
end )

addEvent ( "zombieNachtSkinsAus", true )
addEventHandler ( "zombieNachtSkinsAus", getRootElement(), function ()
	rundeAktiv = false
	zombieSkinsAktualisieren ()
end )

-- Beide Deko-NPCs sind serverseitig unverwundbar ( onPedDamage abgebrochen ),
-- hier nur noch die lokale Trefferanimation/Blut unterdrueckt.
addEventHandler ( "onClientPedDamage", root, function ()
	local id = getElementID ( source )
	if id == "halloweenHaendler" or id == "zombieNachtWaechter" then
		cancelEvent ()
	end
end )

-- Waechter am Stand: sobald man nah genug ist, um ihn und den Kopf-Text zu
-- sehen ( gleiche Reichweite wie dxDrawTextOnElement, 20m ), zeigt er sich
-- als Zombie. Weiter weg bleibt Modell 105 unveraendert.
setTimer ( function ()
	local waechter = getElementByID ( "zombieNachtWaechter" )
	if waechter and isElement ( waechter ) then
		local x, y, z = getElementPosition ( waechter )
		local px, py, pz = getElementPosition ( localPlayer )
		naeheAktiv = getDistanceBetweenPoints3D ( x, y, z, px, py, pz ) <= 20
	else
		naeheAktiv = false
	end
	zombieSkinsAktualisieren ()
end, 1000, 0 )

addEvent ( "zombieNachtStoehnen", true )
addEventHandler ( "zombieNachtStoehnen", getRootElement(), function ( x, y, z )
	playSound3D ( "events/zombienacht_assets/sounds/mgroan"..math.random(1,10)..".ogg", x, y, z )
end )

-- Auch der Klick auf den Kuerbis im Inventar ruft /halloween auf
-- ( items/inventory_gui_client.lua:234 ) - deshalb muss der Befehl weiterhin
-- funktionieren, nicht nur der Marker. Der Server prueft die Entfernung zum
-- Stand ( er kennt STAND_X/Y/Z ) und oeffnet das Menue nur, wenn man dort
-- tatsaechlich steht, sonst kommt der Hinweis.
addCommandHandler ( "halloween", function ()
	if not event.isHalloween then
		outputChatBox ( "Zurzeit läuft kein Halloween-Event.", 200, 0, 0 )
		return
	end
	triggerServerEvent ( "pruefeHalloweenStandNaehe", lp )
end )
