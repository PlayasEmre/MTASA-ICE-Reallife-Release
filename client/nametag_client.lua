--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

nameTagRange = 20
nameSphere = createColSphere ( 0, 0, 0, nameTagRange )
nameTagPlayers = {}
nameTagVisible = {}
nameTagHP = {}
nameTagImages = {}
nameTagAimTarget = localPlayer

-- Solange die Todes-/Transport-Freikamera läuft (ego_client.lua), sieht man
-- sich selbst von außen - dann soll auch das eigene Namensschild mit angezeigt
-- werden und der eigenen (angehängten) Position folgen, statt wie sonst
-- ausgeblendet zu bleiben.
addEventHandler ( "startDeathFreecam", localPlayer, function ()
	-- Keine Sichtlinienprüfung hier (nameTagCheckPlayerSight prüft die Sicht
	-- zwischen zwei Spielern - bei sich selbst wäre Start- und Zielpunkt
	-- identisch, das liefert keine sinnvolle/zuverlässige Sichtbarkeit).
	nameTagPlayers[localPlayer] = true
	nameTagVisible[localPlayer] = true
	nameTagHP[localPlayer] = getElementHealth ( localPlayer )
	nameTagImages[localPlayer] = {}
end )

addEventHandler ( "stopDeathFreecam", localPlayer, function ()
	nameTagPlayers[localPlayer] = nil
	nameTagVisible[localPlayer] = nil
	nameTagHP[localPlayer] = nil
end )

local players = getElementsByType ( "player" )
for key, index in pairs ( players ) do
	setPlayerNametagShowing ( index, false )
end

addEventHandler ( "onClientPlayerJoin", getRootElement(),
	function ()
		setPlayerNametagShowing ( source, false )
	end
)

function nameTagSpawn ()
	detachElements ( nameSphere )
	if isElement ( localPlayer ) then
		attachElements ( nameSphere, localPlayer )
	end
end
setTimer ( nameTagSpawn, 500, 0 )

function nameTagSphereHit ( element, dim )
	if getElementType ( element ) == "player" and not ( element == localPlayer ) then
		nameTagPlayers[element] = true
		nameTagImages[element] = {}
		nameTagCheckPlayerSight ( element )
	end
end
addEventHandler ( "onClientColShapeHit", nameSphere, nameTagSphereHit )

function nameTagCheckPlayerSight ( player )

	if isElement ( player ) then
		-- Ein von einem Sanitäter transportierter (angehängter, per Ragdoll
		-- "toter") Spieler hat unzuverlässige Knochen-Positionen - die
		-- Sichtlinienprüfung darüber kann fälschlich "verdeckt" ergeben.
		-- Für diesen Fall Sichtprüfung überspringen und immer anzeigen.
		if getElementData ( player, "medicTransportBy" ) then
			nameTagVisible[player] = true
			nameTagHP[player] = getElementHealth ( player )
		else
			local x1, y1, z1 = getPedBonePosition ( player, 8 )
			local x2, y2, z2 = getPedBonePosition ( localPlayer, 8 )
			local hit = processLineOfSight ( x1, y1, z1, x2, y2, z2, true, false, false, true, false )
			nameTagVisible[player] = not hit
			if nameTagVisible[player] then
				nameTagHP[player] = getElementHealth ( localPlayer )
			end
		end
		
		if not nameTagImages[player] then
			nameTagImages[player] = {}
		end
		nameTagImages[player]["armor.png"] = false
		nameTagImages[player]["police.png"] = false
		nameTagImages[player]["married.png"] = false
		nameTagImages[player]["armed.png"] = false
		nameTagImages[player]["WTD1.png"] = false
		nameTagImages[player]["WTD2.png"] = false
		nameTagImages[player]["WTD3.png"] = false
		nameTagImages[player]["WTD4.png"] = false
		nameTagImages[player]["WTD5.png"] = false
		nameTagImages[player]["WTD6.png"] = false
		nameTagImages[player]["smode.png"] = false
		nameTagImages[player]["mafia.png"] = false
		nameTagImages[player]["aod.png"] = false
		nameTagImages[player]["medic.png"] = false
		nameTagImages[player]["fbi.png"] = false
		nameTagImages[player]["atzen.png"] = false
		nameTagImages[player]["reporter.png"] = false
		nameTagImages[player]["triaden.png"] = false
		nameTagImages[player]["aduty.png"]= false
		
		-- Einmal lesen statt bis zu sechsmal: getElementData ist ein
		-- vergleichsweise teurer Aufruf, das Ergebnis aendert sich hier nicht.
		local wanteds = getElementData ( player, "wanteds" )
		if wanteds == 1 then
			nameTagImages[player]["WTD1.png"] = true
		elseif wanteds == 2 then
			nameTagImages[player]["WTD2.png"] = true
		elseif wanteds == 3 then
			nameTagImages[player]["WTD3.png"] = true
		elseif wanteds == 4 then
			nameTagImages[player]["WTD4.png"] = true
		elseif wanteds == 5 then
			nameTagImages[player]["WTD5.png"] = true
		elseif wanteds == 6 then
			nameTagImages[player]["WTD6.png"] = true
		elseif getElementData ( player, "adminduty" ) == true then
			nameTagImages[player]["aduty.png"] = true
		end
		
		local r, g, b = getPlayerNametagColor ( player )
		if r == 200 and g == 0 and b == 0 then
			nameTagImages[player]["armed.png"] = true
		end
		
		if getElementData ( player, "married") == 1 then
			nameTagImages[player]["married.png"] = true
		end
	else
		nameTagPlayers[player] = nil
		nameTagVisible[player] = nil
		nameTagHP[player] = nil
	end
end

function nameTagSphereLeave ( element )
	nameTagPlayers[element] = nil
	nameTagVisible[element] = nil
	nameTagHP[element] = nil
end
addEventHandler ( "onClientColShapeLeave", nameSphere, nameTagSphereLeave )

local adminNamePrefix = {
	[1] = "[Supporter]", [2] = "[Moderator]", [3] = "[Adminstrator]",
	[4] = "[Stellv. Projektleiter]", [5] = "[Projektleiter]", [6] = "[Entwickler]",
}

-- Wird jeden Frame fuer jeden sichtbaren Spieler gebraucht. Eine einzige
-- wiederverwendete Tabelle statt einer neuen pro Spieler und Frame.
local aktiveBilder = {}

-- dxDrawImage mit einem Pfad-String laesst MTA die Textur bei jedem Aufruf neu
-- ueber den Dateinamen aufloesen. Hier wird jedes Bild einmal geladen. Fehlende
-- Bilder werden als false gemerkt und danach uebersprungen - sonst scheitert
-- jeder Frame erneut und flutet das Log.
local nametagBild = setmetatable ( {}, {
	__index = function ( tabelle, name )
		local textur = dxCreateTexture ( "/images/nametag/"..name ) or false
		rawset ( tabelle, name, textur )
		return textur
	end
} )

-- Fuer den Halloween-Titel: dasselbe Kuerbis-Icon, das auch im Inventar
-- fuer das Item "Kuerbis" verwendet wird ( items/item_defs.lua ), statt
-- eines Emojis - dxDrawText kann keine Emoji-Glyphen darstellen.
local kuerbisIcon = dxCreateTexture ( "/images/inventory/easteregg.bmp" ) or false

local letzterChatStatus = nil

-- Konstante Textbreite: haengt nur von Text, Groesse und Schriftart ab.
-- Wurde vorher im Halloween-Zweig fuer JEDEN Spieler in JEDEM Frame neu
-- ausgemessen; einmal berechnen genuegt.
local kuerbisTitelBreite = nil

function nameTagRender ()
	-- localPlayer's eigener Chat-Status: haengt nicht vom betrachteten Spieler
	-- (key) ab, deshalb nur EINMAL pro Frame setzen statt pro sichtbarem Nametag.
	-- setElementData verschickt eine Netzwerknachricht, daher nur bei Aenderung.
	local chatActive = isChatBoxInputActive()
	if chatActive ~= letzterChatStatus then
		letzterChatStatus = chatActive
		setElementData(localPlayer, "isChatBoxInputActive", chatActive)
	end

	local x, y, z, sx, sy
	local name, social
	local r, g, b
	-- vorher globale Zuweisung: bei jedem Spieler in jedem Frame ein Schreib-
	-- zugriff auf die globale Tabelle _G
	local r1, g1, b1
	local images, drawn
	for key, index in pairs ( nameTagVisible ) do
		if isElement ( key ) then
			if nameTagVisible[key] then
				x, y, z = getElementPosition ( key )
				if x and y and z then
					sx, sy = getScreenFromWorldPosition ( x, y, z + 1.1, 1000, true )
					if sx and sy then
						r, g, b = calcRGBByHP ( key )
						r1, g1, b1 = 0, 185, 255
						name = getPlayerName ( key )
						-- einmal lesen statt zweimal (pruefen + auslesen)
						social = getElementData ( key, "socialState" ) or "Spieler"
						if getElementData( key, "isChatBoxInputActive") == true then
							social = "schreibt..."
						end
						if (getElementData(key,"adminduty") == true) then
							social = "Supportmodus"
							r1, g1, b1 = 255, 78, 0
						end

						-- Halloween-Titel: exklusiv am Halloween-Stand freigeschaltet,
						-- bewusst vor dem Admin-Praefix, weil er den Namen selbst nicht
						-- ersetzt, sondern nur eine Zeile darueber ergaenzt.
						-- Nur solange das Event aktiv ist ( settings.lua: event.isHalloween ) -
						-- freigeschaltet bleibt der Titel in der DB erhalten, taucht bei der
						-- naechsten Aktivierung des Events also automatisch wieder auf.
						if event.isHalloween and getElementData ( key, "hatHalloweenTitel" ) == true then
							-- Icon links, Text direkt daneben rechts davon statt zentriert
							-- ueberlappend - die Textbreite wird dafuer vorher ausgemessen.
							kuerbisTitelBreite = kuerbisTitelBreite or dxGetTextWidth ( "Kürbis-König", 1.0, "default-bold" )
							local titelBreite = kuerbisTitelBreite
							local titelMitte = sx - 2
							local iconBreite = kuerbisIcon and 18 or 0
							local gesamtBreite = titelBreite + iconBreite + ( kuerbisIcon and 4 or 0 )
							local startX = titelMitte - gesamtBreite / 2
							if kuerbisIcon then
								dxDrawImage ( startX, sy - 39, iconBreite, iconBreite, kuerbisIcon )
							end
							dxDrawText ( "Kürbis-König", startX + iconBreite + 4, sy - 32, startX + iconBreite + 4 + titelBreite, sy, tocolor ( 255, 140, 0, 255 ), 1.0, "default-bold", "left", "center" )
						end

						-- nur einmal statt bis zu 7x pro Spieler/Frame abfragen
						local adminlvl = getElementData ( key, "adminlvl" )
						if adminlvl == 0 or not adminlvl then
							-- einmal lesen statt zweimal (pruefen + einsetzen)
							local nachname = getElementData ( key, "nachname" )
							if nachname then
								dxDrawText ( "["..nachname.."]"..name, sx - 2, sy - 2, sx, sy, tocolor ( r, g, b, 255 ), 1.4, "default-bold", "center", "center" )
							else
								dxDrawText ( name, sx, sy, sx, sy, tocolor ( r, g, b, 255 ), 1.4, "default-bold", "center", "center" )
							end
						elseif adminNamePrefix[adminlvl] then
							dxDrawText ( adminNamePrefix[adminlvl]..name , sx - 2, sy - 2, sx, sy, tocolor ( r, g, b, 255 ), 1.4, "default-bold", "center", "center" )
						end

						dxDrawText ( social, sx, sy + 30, sx, sy, tocolor ( 0, 0, 0, 255 ), .9, "default-bold", "center", "center" )
						dxDrawText ( social, sx - 2, sy - 1 + 30, sx, sy, tocolor ( r1, g1, b1, 255 ), .9, "default-bold", "center", "center" )

						-- ein Durchlauf statt zwei (einmal zaehlen, einmal zeichnen).
						-- Fehlende Bilder gar nicht erst aufnehmen, damit die Zentrierung
						-- der uebrigen stimmt und dxDrawImage nicht jeden Frame scheitert.
						local anzahl = 0
						for img, bool in pairs ( nameTagImages[key] ) do
							local textur = bool and nametagBild[img]
							if textur then
								anzahl = anzahl + 1
								aktiveBilder[anzahl] = textur
							end
						end
						images, drawn = anzahl, 0
						for i = 1, anzahl do
							local bild = aktiveBilder[i]
							if images / 2 == math.floor ( images / 2 ) then
								dxDrawImage ( sx + 24 * ( drawn ) - images * 24 + 24, sy + 25, 24, 24, bild )
							else
								dxDrawImage ( sx + 24 * ( drawn ) - images * 24 / 2, sy + 25, 24, 24, bild )
							end
							drawn = drawn + 1
						end
					end
				end
			end
		else
			nameTagCheckPlayerSight ( key )
		end
	end
end
addEventHandler ( "onClientRender", getRootElement(), nameTagRender )

function calcRGBByHP ( player )

	local hp = getElementHealth ( player )
	local armor = getPedArmor ( player )
	if hp <= 0 then
		return 0, 0, 0
	else
		if armor > 0 then
			armor = math.abs ( armor - 0.01 )
			return 0 + (2.55*armor), (255), 0 + (2.55*armor)
		else
		hp = math.abs ( hp - 0.01 )
		return ( 100 - hp ) * 2.55 / 2, ( hp * 2.55 ), 0
		end
	end
end


function reCheckNameTag ()

	if ( isElement ( getCameraTarget () ) ) then
		detachElements ( nameSphere )
		attachElements ( nameSphere, getCameraTarget () )
	end
	setElementInterior ( nameSphere, getElementInterior ( localPlayer ) )
	setElementDimension ( nameSphere, getElementDimension ( localPlayer ) )
	if isPedAiming ( localPlayer ) and ( pedSlot == 6 ) then
		local x1, y1, z1 = getPedTargetStart ( localPlayer )
		local x2, y2, z2 = getPedTargetEnd ( localPlayer )
		local pedSlot = getPedWeaponSlot ( localPlayer )
		local boolean, x, y, z, hit = processLineOfSight ( x1, y1, z1, x2, y2, z2 )
		if boolean then
			if isElement ( hit ) then
				if getElementType ( hit ) == "player" then
					nameTagAimTarget = hit
					nameTagPlayers[nameTagAimTarget] = nameTagAimTarget
				end
			end
		end
	end
	for key, index in pairs ( nameTagPlayers ) do
		nameTagCheckPlayerSight ( key )
	end
end
setTimer ( reCheckNameTag, 500, 0 )
