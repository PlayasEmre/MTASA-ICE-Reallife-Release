--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


AztecasLager = createObject ( 2332, -1313.24609375, 2544.373046875, 87.784133911133, 0, 0, 269 )
AztecaszweitLager = createObject ( 2332, 715.9721, 1966.29, 5.53 )

TriadenLager = createObject ( 2332, -2173.6677, 632.83, 49.4375,0, 0, 180 )
TriadenzweitLager = createObject ( 2332, 1896.6240, 977.2525, 10.812 )

BikerLager = createObject ( 2332, -2196.11328125, -2331.1474609375, 30.625, 0, 0, 143 )
BikerzweitLager = createObject ( 2332, 2471.2001953125, 1534.400390625, 10.60000038147, 0, 0, 0 )

MafiaLager = createObject ( 2332, -692.271484375, 936.41796875, 13.6328125, 0, 0, 92 )
MafiazweitLager = createObject ( 2332, 2314.7544, 1760.5988, 10.820, 0, 0, 180 )

GroveLagerSF = createObject ( 2332, -2457.7001953125, -94.2998046875, 25.799999237061, 0, 0, 271)

TerrorLager = createObject ( 2332, -1972.8076171875, -1583.5869140625, 87.835296630859,0, 0, 329)

AnonymusLager = createObject ( 2332, -2208.25, 1056.393, 80.008, 0, 0, 3.8 )

ReporterLager = createObject ( 2332, -2540.5, -623.59997558594, 132.5,0, 0, 175)

BallasLager = createObject ( 2332, -2200.6999511719, 77.900001525879, 35.099998474121, 0, 0, 1.5683288574219 )

SFPDLager = createObject ( 2332, 251.70703125, 70.9853515625, 1003.640625, 0, 0, 2.2165222167969 )
setElementInterior ( SFPDLager, 6 )

MechanikerLager = createObject ( 2332, -2081.2421875, -110.8251953125, 39.4, 0, 0, 269 )

MedicLager = createObject ( 2332, 402.6103515625, 254.6900177002, 996.81188964844, 0, 0, 275 )
setElementInterior ( MedicLager, 3 )

-- Jedes Tresor-Objekt zeigt hier auf die Fraktions-ID, der es gehoert (statt nur "true").
-- Damit kann beim Anklicken geprueft werden, ob der Spieler ueberhaupt Mitglied DIESER
-- Fraktion ist, bevor die Kasse angezeigt wird - siehe player_click in clicksys_server.lua.
depots = {
	[AztecasLager] = 7, [AztecaszweitLager] = 7,
	[TriadenLager] = 3, [TriadenzweitLager] = 3,
	[BikerLager] = 9, [BikerzweitLager] = 9,
	[MafiaLager] = 2, [MafiazweitLager] = 2,
	[TerrorLager] = 4,
	[AnonymusLager] = 14,
	[BallasLager] = 12,
	[GroveLagerSF] = 13,
	[ReporterLager] = 5,
	[SFPDLager] = 1,
	[MechanikerLager] = 11,
	[MedicLager] = 10,
}

-- Fraktion 11 (Mechaniker) hat jetzt eine eigene, von Medic (10) getrennte Kasse.
depotFactions = { [1]=true, [2]=true, [3]=true, [4]=true, [5]=true, [7]=true, [9]=true, [10]=true, [11]=true, [12]=true, [13]=true, [14]=true }

-- Welche Ressourcen darf eine Fraktion in ihrer eigenen Kasse ein-/auslagern?
-- Fehlt eine Fraktion hier komplett, sind automatisch alle drei (Geld, Drogen, Mats) erlaubt
-- (kriminelle Fraktionen wie Mafia/Triaden/Aztecas/Biker/Ballas/Grove/Terror muessen hier
-- also nicht extra eingetragen werden). Legale Fraktionen sind bewusst auf Geld beschraenkt.
depotAllowedTypes = {
	[1]  = { money = true }, -- SFPD (inkl. FBI/Bundeswehr, siehe Remap oben)
	[5]  = { money = true }, -- San News
	[10] = { money = true }, -- Medic
	[11] = { money = true }, -- Mechaniker
}
factionDepotData = {}
	factionDepotData["money"] = {}
	factionDepotData["drugs"] = {}
	factionDepotData["mats"] = {}

function depotLoad ()
	local dsatz = dbPoll ( dbQuery ( handler, "SELECT * FROM fraktionen" ), -1 )
	for i=1, #dsatz do
		local id = tonumber ( dsatz[i]["ID"] )
		factionDepotData["money"][id] = tonumber ( dsatz[i]["DepotGeld"] )
		factionDepotData["drugs"][id] = tonumber ( dsatz[i]["DepotDrogen"] )
		factionDepotData["mats"][id] = tonumber ( dsatz[i]["DepotMaterials"] )
	end
end
addEventHandler("onResourceStart", resourceRoot, depotLoad )


function saveDepotInDB ()
	for index, _ in pairs ( depotFactions ) do
		dbExec ( handler, "UPDATE ?? SET ??=?, ??=?, ??=? WHERE ?? = ?", "fraktionen", "DepotGeld", factionDepotData["money"][index], "DepotDrogen", factionDepotData["drugs"][index], "DepotMaterials", factionDepotData["mats"][index], "ID", index )
	end
end
setTimer ( saveDepotInDB, 25*60*1000, 0 )


function fDepotServer_func ( player, take, money, drugs, mats )

	if player == client then

		local fraktion = MtxGetElementData ( player, "fraktion" )

		-- Pro Fraktion einzeln geprueft: darf sie ueberhaupt Geld/Drogen/Mats in ihrer
		-- Kasse haben? (siehe depotAllowedTypes oben) Fehlt der Eintrag, ist alles erlaubt.
		local allowedTypes = depotAllowedTypes[fraktion]
		if allowedTypes then
			if not allowedTypes.money and ( tonumber ( money ) or 0 ) > 0 then
				outputChatBox ( "In dieser Fraktionskasse kann kein Geld verwaltet werden!", player, 125, 0, 0 )
				return nil
			end
			if not allowedTypes.drugs and ( tonumber ( drugs ) or 0 ) > 0 then
				outputChatBox ( "In dieser Fraktionskasse koennen keine Drogen verwaltet werden!", player, 125, 0, 0 )
				return nil
			end
			if not allowedTypes.mats and ( tonumber ( mats ) or 0 ) > 0 then
				outputChatBox ( "In dieser Fraktionskasse koennen keine Materialien verwaltet werden!", player, 125, 0, 0 )
				return nil
			end
		end

		if depotFactions[fraktion] then
			if tonumber ( money ) and tonumber ( drugs ) and tonumber ( mats ) and tonumber ( money ) + tonumber ( drugs ) + tonumber ( mats ) > 0 then
				local pmoney = tonumber ( MtxGetElementData ( player, "money" ) )
				local pdrugs = tonumber ( MtxGetElementData ( player, "drugs" ) )
				local pmats = tonumber ( MtxGetElementData ( player, "mats" ) )
				local money = math.floor ( math.abs ( tonumber ( money ) ) )
				local drugs = math.floor ( math.abs ( tonumber ( drugs ) ) )
				local mats = math.floor ( math.abs ( tonumber ( mats ) ) )
				if take then
					if money > 0 and tonumber ( MtxGetElementData ( player, "rang" ) ) < 5 then
						outputChatBox ( "Du darfst kein Geld entnehmen!", player, 125, 0, 0 )
						return nil
					end
					if drugs > 0 and tonumber ( MtxGetElementData ( player, "rang" ) ) < 5 then
						outputChatBox ( "Du darfst keine Drogen entnehmen!", player, 125, 0, 0 )
						return nil
					end
					if mats > 0 and tonumber ( MtxGetElementData ( player, "rang" ) ) < 5 then
						outputChatBox ( "Du darfst keine Materialien entnehmen!", player, 125, 0, 0 )
						return nil
					end
					if factionDepotData["money"][fraktion] < money then
						outputChatBox ( "In der Fraktionskasse ist nicht genug Geld!", player, 125, 0, 0 )
					elseif factionDepotData["drugs"][fraktion] < drugs then
						outputChatBox ( "In der Fraktionskasse sind nicht genug Drogen!", player, 125, 0, 0 )
					elseif factionDepotData["mats"][fraktion] < mats then
						outputChatBox ( "In der Fraktionskasse sind nicht genug Materialien!", player, 125, 0, 0 )
					else
						local msg = getPlayerName(player).." hat "..money.." "..Tables.waehrung..", "..drugs.." Gramm Drogen und "..mats.." Materialien aus dem Depot genommen."
						outputLog ( msg, "fkasse" )
						outputDebugString ( msg )
						MtxSetElementData ( player, "money", pmoney + money )
						MtxSetElementData ( player, "drugs", pdrugs + drugs )
						MtxSetElementData ( player, "mats", pmats + mats )
						factionDepotData["money"][fraktion] = factionDepotData["money"][fraktion] - money
						factionDepotData["drugs"][fraktion] = factionDepotData["drugs"][fraktion] - drugs
						factionDepotData["mats"][fraktion] = factionDepotData["mats"][fraktion] - mats
						triggerClientEvent ( player, "showFDepot", getRootElement(), factionDepotData["money"][fraktion], factionDepotData["mats"][fraktion], factionDepotData["drugs"][fraktion] )
					end
				else
					if money > pmoney then
						outputChatBox ( "Du hast nicht genug Geld dafür!", player, 125, 0, 0 )
					elseif drugs > pdrugs then
						outputChatBox ( "Du hast nicht genug Drogen dafür!", player, 125, 0, 0 )
					elseif mats > pmats then
						outputChatBox ( "Du hast nicht genug Materialen dafür!", player, 125, 0, 0 )
					else
						MtxSetElementData ( player, "money", pmoney - money )
						MtxSetElementData ( player, "drugs", pdrugs - drugs )
						MtxSetElementData ( player, "mats", pmats - mats )
						factionDepotData["money"][fraktion] = factionDepotData["money"][fraktion] + money
						factionDepotData["drugs"][fraktion] = factionDepotData["drugs"][fraktion] + drugs
						factionDepotData["mats"][fraktion] = factionDepotData["mats"][fraktion] + mats
						local msg = getPlayerName(player).." hat "..money.." "..Tables.waehrung..", "..drugs.." Gramm Drogen und "..mats.." Materialien in das Depot gelegt."
						outputLog ( msg, "fkasse" )
						--sendMSGForFaction ( msg, tonumber(MtxGetElementData ( player, "fraktion" )) )
						outputDebugString ( msg )
						triggerClientEvent ( player, "showFDepot", getRootElement(), factionDepotData["money"][fraktion],  factionDepotData["mats"][fraktion], factionDepotData["drugs"][fraktion] )
					end
				end
			else
				outputChatBox ( "Ungültige Eingabe!", player, 125, 0, 0 )
			end
		else
			outputChatBox ( "Du bist in einer ungültigen Fraktion!", player, 125, 0, 0 )
		end
	end
end
addEvent ( "fDepotServer", true )
addEventHandler ( "fDepotServer", getRootElement(), fDepotServer_func )

local triadFgunsMarker = createMarker( -2186.9372558594, 698.5894165039, 53.9163284301761, "corona", 1, 255, 255, 0, 255 )
local triad2FgunsMarker = createMarker( 1909.1752, 1016.0863, 9.82, "corona", 1, 255, 255, 0, 255 )
local rifasFgunsMarker = createMarker( -1319.382, 2545.64, 87.784, "corona", 1, 255, 255, 0, 255 )
local rifas2FgunsMarker = createMarker( 1210.8363, 4.4482, 999.921, "corona", 1, 255, 255, 0, 255 )
setElementInterior ( rifas2FgunsMarker, 2 )
local mafiaFgunsMarker = createMarker( -50.0453, 1405.4531, 1084.4297, "corona", 1, 255, 255, 0, 255 )
setElementInterior ( mafiaFgunsMarker, 8 )
local mafia2FgunsMarker = createMarker( 2176.2729, 1619.136, 1000.976, "corona", 1, 255, 255, 0, 255 )
setElementInterior ( mafia2FgunsMarker, 1 )
local bikerFgunsMarker = createMarker( -2197.4792, -2329.2456, 30.625, "corona", 1, 255, 255, 0, 255 )
local biker2FgunsMarker = createMarker( 2461.2998046875, 1558.400390625,11.800000190735, "corona", 1, 255, 255, 0, 255 )
local ballasFgunsMarker = createMarker( -2209.6999511719, 78.400001525879, 35.299999237061, "corona", 1, 0, 125, 0 )
local groveFgunsMarker = createMarker(2533.6000976563, -1664.3000488281, 15.199999809265,"corona",2,255,0,0)
local grove2FgunsMarker = createMarker(-2482.4033203125, -122.8857421875, 25.623662948608,"corona",1,255,0,0)
local terrorFgunsMarker = createMarker( -1977.186, -1590.015, 87.882, "corona", 1, 255, 255, 0, 255 )
-- Anonymus: an derselben Stelle wie der frueher automatisch ausruestende Pickup
-- (fraktionen/Anonymus/armsAnonymus_func.lua).
local anonymusFgunsMarker = createMarker( -2211.7697753906, 1056.8997802734, 80.013061523438, "corona", 1, 255, 255, 0, 255 )
-- Waffenkammer im SFPD (Interior 6), neben dem Tresor SFPDLager. Polizei, FBI
-- und Bundeswehr ruesten sich hier aus.
-- Punkte, an denen Staatsfraktionen /fguns benutzen koennen. Das Interior gehoert
-- dazu: mehrere Wachen liegen auf fast denselben Koordinaten in verschiedenen
-- Interiors. Marker und Abstandspruefung stammen beide aus dieser einen Liste,
-- damit ein sichtbarer Marker nie an einer Stelle steht, an der /fguns nicht geht.
local staatFgunsPunkte = {
	{ -1611.5,   679.3,    -5.3,      0 },  -- SFPD, draussen
	{ 259.6,     110.6,    1003,     10 },  -- SFPD, drinnen
	{ 254.746,   65.769,   1003.64,   6 },  -- LSPD
	{ 297.491,   186.004,  1007.172,  3 },  -- LVPD
	{ -2446.82,  518.643,  30.276,    0 },  -- FBI, draussen
	{ 986.469,   -11.641,  248.563,  10 },  -- FBI, drinnen
	{ 251.707,   70.985,   1003.64,   6 },  -- Waffenkammer neben dem SFPD-Tresor
	{ -1327.778, 488.807,  11.195,    0 },  -- Bundeswehr
}

local staatFgunsMarker = {}
for i = 1, #staatFgunsPunkte do
	local p = staatFgunsPunkte[i]
	local marker = createMarker ( p[1], p[2], p[3], "corona", 1, 0, 130, 255, 255 )
	setElementInterior ( marker, p[4] )
	staatFgunsMarker[marker] = true
end

function showFgunsInfo ( hitElement, dim )
	if getElementType ( hitElement ) == "player" and dim then
		local frac = MtxGetElementData ( hitElement, "fraktion" )
		if ( source == triadFgunsMarker or source == triad2FgunsMarker ) and frac == 3 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif ( source == rifasFgunsMarker or source == rifas2FgunsMarker ) and frac == 7 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif ( source == mafiaFgunsMarker or source == mafia2FgunsMarker ) and frac == 2 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif ( source == bikerFgunsMarker or source == biker2FgunsMarker ) and frac == 9 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif source == ballasFgunsMarker and frac == 12 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif ( source == groveFgunsMarker or source == grove2FgunsMarker ) and frac == 13 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif source == terrorFgunsMarker and frac == 4 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif staatFgunsMarker[source] and staatsFraktionen[frac] then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif source == anonymusFgunsMarker and frac == 14 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		end
	end
end
addEventHandler ( "onMarkerHit", triadFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", triad2FgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", rifasFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", rifas2FgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", mafiaFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", mafia2FgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", bikerFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", biker2FgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", ballasFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", groveFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", grove2FgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", terrorFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", anonymusFgunsMarker, showFgunsInfo )
for marker in pairs ( staatFgunsMarker ) do
	addEventHandler ( "onMarkerHit", marker, showFgunsInfo )
end

local function anStaatWaffenlager ( player )
	local px, py, pz = getElementPosition ( player )
	local int = getElementInterior ( player )
	for i = 1, #staatFgunsPunkte do
		local p = staatFgunsPunkte[i]
		if int == p[4] and getDistanceBetweenPoints3D ( px, py, pz, p[1], p[2], p[3] ) < 10 then
			return true
		end
	end
	return false
end

-- Waffenlager je Fraktion. Aus dieser Tabelle speisen sich der /fguns-Befehl
-- und die Standortpruefung beim Kauf - vorher stand beides in neun fast
-- gleichen Zweigen, wodurch bei Ballas und Bikern versehentlich zweimal
-- derselbe Marker geprueft wurde.
local fgunsLagerFuerFraktion = {
	[2]  = { mafiaFgunsMarker, mafia2FgunsMarker },
	[3]  = { triadFgunsMarker, triad2FgunsMarker },
	[4]  = { terrorFgunsMarker },
	[7]  = { rifasFgunsMarker, rifas2FgunsMarker },
	[9]  = { bikerFgunsMarker, biker2FgunsMarker },
	[12] = { ballasFgunsMarker },
	[13] = { groveFgunsMarker, grove2FgunsMarker },
	[14] = { anonymusFgunsMarker },
}

-- Darf diese Fraktion /fguns ueberhaupt benutzen?
function darfFguns ( fac )
	return staatsFraktionen[fac] ~= nil or fgunsLagerFuerFraktion[fac] ~= nil
end

-- Steht der Spieler an einem Waffenlager seiner Fraktion?
function istAmFgunsLager ( player, fac )
	if staatsFraktionen[fac] then return anStaatWaffenlager ( player ) end
	local lager = fgunsLagerFuerFraktion[fac]
	if not lager then return false end
	local px, py, pz = getElementPosition ( player )
	for i = 1, #lager do
		if isElement ( lager[i] ) then
			local mx, my, mz = getElementPosition ( lager[i] )
			if getDistanceBetweenPoints3D ( px, py, pz, mx, my, mz ) < 10 then return true end
		end
	end
	return false
end

addCommandHandler("fguns",
function ( player, cmd )
	-- tonumber, weil die Fraktion je nach Herkunft als Text vorliegen kann.
	local fac = tonumber ( MtxGetElementData ( player, "fraktion" ) )
	local rank = tonumber ( MtxGetElementData ( player, "rang" ) ) or 0

	if gotLastHit[player] and gotLastHit[player] + healafterdmgtime > getTickCount() then
		outputChatBox ( "Es muss dafür "..( healafterdmgtime/1000 ) .." Sekunden nach dem letzten Schuss vergangen sein!", player, 200, 0, 0 )
		return
	end

	if not darfFguns ( fac ) then
		infobox( player, "\nKeine Befugnis!", 3500, 255, 0, 0 )
		return
	end

	if not istAmFgunsLager ( player, fac ) then
		infobox( player, "Du bist nicht\nam Waffenlager!", 3500, 255, 0, 0 )
		return
	end

	-- Die Bundeswehr geht nicht nach Rang. Freigeschaltet wird ueber die
	-- Berechtigungen aus /setpermission; die aktive Klasse dient der Anzeige.
	triggerClientEvent (player, "startFgunsGui", player, rank, fac,
		MtxGetElementData ( player, "job" ),
		fac == 8 and erlaubteArmyKlassen ( player ) or nil)
end)

-- Ab welchem Fraktionsrang Terroristen C4 bekommen. Muss zum Eintrag in
-- fraktionen/fguns_client.lua passen, sonst zeigt das Fenster einen Knopf an,
-- den der Server ablehnt.
C4_MINDESTRANG = 4

-- Polizei, FBI und Bundeswehr teilen sich eine Kasse (wie schon beim Tresor) und
-- fuehren keine Materialien. Ihre Ausruestung wird deshalb allein aus der
-- Fraktionskasse bezahlt.
staatsFraktionen = { [1] = true, [6] = true, [8] = true }

-- Fraktionen ohne eigene Kasse. Sie zahlen aus eigener Tasche; Materialpreis und
-- Kassenbuchung entfallen, sonst liefe der Kauf in einen Vergleich mit nil.
-- Anonymus hat seit dem Nachtrag in der Tabelle "fraktionen" eine eigene Kasse
-- und steht deshalb nicht mehr hier.
kassenloseFraktionen = {}

-- Welche Klasse eine Bundeswehr-Waffe verlangt. Muss zu armyWaffen in
-- fraktionen/fguns_client.lua passen. Das Fenster graut fremde Waffen nur aus -
-- verbindlich ist diese Pruefung hier. Gilt nur fuer Fraktion 8: Shotgun, Mp5
-- und Sniper gehoeren bei der Polizei zum normalen Rangangebot.
-- Berechtigungsnummer aus /setpermission -> Klasse. Die Berechtigung entscheidet,
-- was gekauft werden darf; die aktive Klasse aus /class bleibt davon unberuehrt
-- und steuert weiterhin nur die Ausruestung beim Spawnen.
armyPermKlasse = { [1] = "soldat", [2] = "pionier", [3] = "marine", [4] = "air", [5] = "tankcommander", [6] = "spaeher" }

function erlaubteArmyKlassen ( player )
	local erlaubt = {}
	for nr, klasse in pairs ( armyPermKlasse ) do
		if tonumber ( MtxGetElementData ( player, "armyperm"..nr ) ) == 1 then
			erlaubt[klasse] = true
		end
	end
	return erlaubt
end

local armyWaffenKlasse = {
	["Granate"]        = "pionier",
	["Shotgun"]        = "marine",
	["Mp5"]            = "air",           ["Fallschirm"]   = "air",
	["Suchrakete"]     = "tankcommander", ["Kampfshotgun"] = "tankcommander",
	["Schalldaempfer"] = "spaeher",       ["Sniper"]       = "spaeher",
}

-- Preisstufen, identisch zu Moneycost/Matscost in fraktionen/fguns_client.lua.
local fgunsMoneycost = { 100, 200, 300, 300, 300, 300, 400, 1500, 2000 }
local fgunsMatscost  = {  10,  20,  30,  30,  30,  30,  40,  150,  200 }

-- Waffe -> Preisstufe. Der Client schickt seine Preise zwar weiterhin mit, sie
-- werden aber ignoriert: sonst koennte ein veraenderter Client 0 senden und sich
-- alles umsonst nehmen. Massgeblich ist ausschliesslich diese Tabelle.
local fgunsPreisstufe = {
	["Baseball"] = 1, ["Messer"] = 1, ["Queue"] = 1, ["Tec9"] = 1,
	["Schlagstock"] = 1, ["Fallschirm"] = 1,
	["Deagle"] = 2, ["Pistole"] = 2, ["Schalldaempfer"] = 2,
	["Mp5"] = 3, ["Shotgun"] = 3, ["Granate"] = 3,
	["Katana"] = 4, ["Lupara"] = 4, ["Molotov"] = 4, ["Satchel"] = 4,
	["Gewehr"] = 5,
	["AK47"] = 6,
	["M4"] = 7, ["Kampfshotgun"] = 7,
	["C4"] = 8, ["Sniper"] = 8,
	["Raketenwerfer"] = 9, ["Suchrakete"] = 9,
}

addEvent ("giveFgunsWeapon", true)
addEventHandler ("giveFgunsWeapon", getRootElement(), function (waffe)
	-- Preise kommen aus der Tabelle oben, nicht vom Client.
	local stufe = waffe and fgunsPreisstufe[waffe]
	if stufe then
		local moneycost = fgunsMoneycost[stufe]
		local matscost  = fgunsMatscost[stufe]
		local fac = getPlayerFaction(client)

		-- Dieses Ereignis laesst sich unabhaengig vom Fenster ausloesen, deshalb
		-- werden Befugnis und Standort hier noch einmal geprueft und nicht nur
		-- beim Oeffnen ueber /fguns.
		if not darfFguns ( fac ) then return end
		if not istAmFgunsLager ( client, fac ) then
			outputChatBox ( "Du bist nicht am Waffenlager!", client, 155, 0, 0 )
			return
		end

		-- FBI und Bundeswehr buchen wie beim Tresor ueber die SFPD-Kasse und
		-- zahlen keine Materialien.
		local staat = staatsFraktionen[fac]

		if fac == 8 then
			local noetig = armyWaffenKlasse[waffe]
			if noetig and not erlaubteArmyKlassen ( client )[noetig] then
				outputChatBox ( "Dafuer brauchst du die Berechtigung \""..noetig.."\"!", client, 155, 0, 0 )
				return
			end
		end

		local ohneKasse = kassenloseFraktionen[fac]
		if staat then fac = 1 end
		local matsNoetig = ( staat or ohneKasse ) and 0 or matscost

		if ohneKasse or factionDepotData["mats"][fac] >= matsNoetig then
			if MtxGetElementData ( client, "money" ) >= moneycost then
				setPedArmor( client, 100 )
				if waffe == "Baseball" then
					giveWeapon ( client, 5, 1, true )
				elseif waffe == "Messer" then
					giveWeapon ( client, 4, 1, true )
				elseif waffe == "Queue" then
					giveWeapon ( client, 7, 1, true )
				elseif waffe == "Deagle" then
					giveWeapon ( client, 24, 49, true )
				elseif waffe == "Mp5" then
					giveWeapon ( client, 29, 180, true )
				elseif waffe == "M4" then
					giveWeapon ( client, 31, 350, true )
				elseif waffe == "Katana" then
					giveWeapon ( client, 8, 1, true )
				elseif waffe == "Molotov" then
					giveWeapon ( client, 18, 4, true )
				elseif waffe == "Lupara" then
					giveWeapon ( client, 26, 22, true )
				elseif waffe == "Gewehr" then
					giveWeapon ( client, 33, 51, true )
				elseif waffe == "AK47" then
					giveWeapon ( client, 30, 180, true )
				elseif waffe == "Sniper" then
					giveWeapon ( client, 34, 21, true )
				elseif waffe == "Raketenwerfer" then
					giveWeapon ( client, 35, 3, true )
				-- Ausruestung der Bundeswehr, entspricht armyClassSpawn je Klasse.
				elseif waffe == "Granate" then
					giveWeapon ( client, 16, 3, true )
				elseif waffe == "Fallschirm" then
					giveWeapon ( client, 46, 1, true )
				elseif waffe == "Kampfshotgun" then
					giveWeapon ( client, 27, 500, true )
				elseif waffe == "Schalldaempfer" then
					giveWeapon ( client, 23, 90, true )
				elseif waffe == "Suchrakete" then
					giveWeapon ( client, 36, 20, true )
				elseif waffe == "Schlagstock" then
					giveWeapon ( client, 3, 1, true )
				elseif waffe == "Pistole" then
					giveWeapon ( client, 22, 200, true )
				elseif waffe == "Shotgun" then
					giveWeapon ( client, 25, 100, true )
				elseif waffe == "Tec9" then
					giveWeapon ( client, 32, 180, true )
				elseif waffe == "Satchel" then
					giveWeapon ( client, 39, 3, true )
				elseif waffe == "C4" then
					if ( tonumber ( MtxGetElementData ( client, "rang" ) ) or 0 ) < C4_MINDESTRANG then
						outputChatBox ( "C4 gibt es erst ab Rang "..C4_MINDESTRANG.."!", client, 155, 0, 0 )
						return
					end
					-- Vor dem Abbuchen pruefen, sonst waeren Geld und Materialien
					-- fuer eine C4 weg, die der Spieler gar nicht bekommt.
					if hatTerroristC4 ( client ) then
						outputChatBox ( "Du hast bereits eine C4 dabei!", client, 155, 0, 0 )
						return
					end
					if not gibTerroristC4 ( client ) then
						outputChatBox ( "C4 gibt es nur fuer Terroristen!", client, 155, 0, 0 )
						return
					end
				end
				MtxSetElementData ( client, "money", MtxGetElementData ( client, "money" ) - moneycost )

				if not ohneKasse then
					factionDepotData["money"][fac] = factionDepotData["money"][fac] + moneycost
					factionDepotData["mats"][fac] = factionDepotData["mats"][fac] - matsNoetig
				end
				outputLog ( getPlayerName(client) .. " hat ein(e) "..waffe.." gekauft.", "fguns" )

				-- Wer die C4 hat, ist fuer die ganze Fraktion wichtig - deshalb
				-- hier eine Meldung statt nur eines Logeintrags.
				if waffe == "C4" then
					sendMSGForFaction ( getPlayerName ( client ) .. " hat eine C4 aus dem Lager genommen!", fac, 200, 50, 50 )
					outputChatBox ( "Du hast eine C4 genommen - /c4 zum Ablegen, /detonatec4 zum Zuenden.", client, 0, 200, 0 )
				end
			else
				outputChatBox ( "Nicht genug Geld auf der Hand!", client, 155, 0, 0 )
			end
		else
			outputChatBox ( "Nicht genug Mats im Lager", client, 155, 0, 0 )
		end
	end
end)
