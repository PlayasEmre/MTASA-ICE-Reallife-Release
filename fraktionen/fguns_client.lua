--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

local GUIEditor = {
    button = {},
    window = {},
    label = {}
}


local Moneycost = {
	[1] = 100,
	[2] = 200,
	[3] = 300,
	[4] = 300,
	[5] = 300,
	[6] = 300,
	[7] = 400,
	[8] = 1500,
	[9] = 2000
}

local Matscost = {
	[1] = 10,
	[2] = 20,
	[3] = 30,
	[4] = 30,
	[5] = 30,
	[6] = 30,
	[7] = 40,
	[8] = 150,
	[9] = 200
}

-- Waffenangebot als Tabelle: { Beschriftung, ab welchem Fraktionsrang, Preisindex }.
-- Der Preisindex zeigt auf Moneycost/Matscost und wird beim Kauf an den Server
-- geschickt; die Beschriftung muss dort in giveFgunsWeapon bekannt sein
-- (siehe fraktionen/fdepots.lua).
local gemeinsameWaffen = {
	{ "Deagle",        0, 2 },
	{ "Mp5",           1, 3 },
	{ "Gewehr",        2, 5 },
	{ "AK47",          3, 6 },
	{ "M4",            3, 7 },
	{ "Sniper",        4, 8 },
	{ "Raketenwerfer", 5, 9 },
}

-- Fraktionseigene Ausruestung. Fraktionen ohne Eintrag bekommen standardWaffen.
local fraktionsWaffen = {
	[3] = { { "Baseball", 0, 1 }, { "Katana",  2, 4 } }, -- Yakuza
	[2] = { { "Messer",   0, 1 }, { "Lupara",  2, 4 } }, -- Mafia
	[4] = { { "Tec9",     0, 1 }, { "Satchel", 3, 4 }, { "C4",      4, 8 } }, -- Terroristen
}
local standardWaffen = { { "Queue", 0, 1 }, { "Molotov", 2, 4 } }

-- Anonymus (14) hat inzwischen eine eigene Fraktionskasse und zahlt Waffen
-- genauso mit Geld+Mats wie die anderen kriminellen Fraktionen (siehe
-- fdepots.lua). Die Waffen hier entsprechen dem, was der fruehere
-- Ausruest-Marker pauschal ausgegeben hat, jetzt aber einzeln nach Rang und
-- Preis wie bei den anderen Fraktionen.
local anonymusWaffen = {
	{ "Deagle",        0, 2 },
	{ "Mp5",           1, 3 },
	{ "M4",            3, 7 },
	{ "Sniper",        4, 8 },
	{ "Raketenwerfer", 5, 9 },
}

-- Polizei, FBI und Bundeswehr teilen sich Ausruestung und Kasse. Sie fuehren
-- keine Materialien (siehe depotAllowedTypes in fdepots.lua) und zahlen nur
-- Geld, deshalb wird bei ihnen die Mats-Zeile weggelassen.
local staatsFraktionen = { [1] = true, [6] = true, [8] = true }

-- Rangpaket der Polizei und des FBI.
local staatsWaffen = {
	{ "Schlagstock", 0, 1 },
	{ "Pistole",     0, 2 },
	{ "Deagle",      1, 2 },
	{ "Shotgun",     1, 3 },
	{ "Mp5",         1, 3 },
	{ "M4",          3, 7 },
	{ "Sniper",      4, 8 },
}

-- Die Bundeswehr (Fraktion 8) richtet sich nicht nach dem Rang, sondern nach der
-- Klasse aus /class. Die Listen entsprechen dem, was armyClassSpawn ausgibt
-- (fraktionen/army/army_func.lua); der Rang spielt hier keine Rolle.
-- Vierter Wert = benoetigte Klasse. Ohne vierten Wert darf es jede Klasse kaufen.
-- Im Fenster werden auch die fremden Waffen angezeigt, aber gesperrt und mit der
-- noetigen Klasse beschriftet, damit man sieht, wofuer sich /class lohnt.
local armyWaffen = {
	{ "Pistole",        0, 2 },
	{ "Deagle",         0, 2 },
	{ "M4",             0, 7 },
	{ "Granate",        0, 3, "pionier" },
	{ "Shotgun",        0, 3, "marine" },
	{ "Mp5",            0, 3, "air" },
	{ "Fallschirm",     0, 1, "air" },
	{ "Suchrakete",     0, 9, "tankcommander" },
	{ "Kampfshotgun",   0, 7, "tankcommander" },
	{ "Schalldaempfer", 0, 2, "spaeher" },
	{ "Sniper",         0, 8, "spaeher" },
}

local SPALTEN     = 3
local SPALTE_X    = { 0.03, 0.365, 0.70 }
local SPALTE_B    = 0.27
local ZEILE_Y     = { 0.07, 0.26, 0.45, 0.64 }
local KNOPF_H     = 0.10
local GELD_DY     = 0.115
local MATS_DY     = 0.152
local LABEL_H     = 0.035

local buttonID = {}
-- Knopf -> Klasse, die dafuer noetig waere (nur bei der Bundeswehr belegt).
local gesperrteKlasse = {}

function zeigeKlassenHinweis ( button )
	if button == "left" and gesperrteKlasse[source] then
		outputChatBox ( "Dafuer brauchst du die Berechtigung \""..gesperrteKlasse[source].."\" - vergeben mit /setpermission", 200, 150, 60 )
	end
end

-- Stellt das Angebot fuer Rang und Fraktion zusammen, aufsteigend nach Rang
-- sortiert, damit die guenstigen/frueh verfuegbaren Waffen oben stehen.
local function baueAngebot ( therank, thefrac, erlaubteKlassen )
	local liste = {}
	if thefrac == 8 then
		-- Bundeswehr: alles anzeigen, die Sperre entscheidet sich beim Zeichnen.
		-- Freigeschaltetes zuerst, damit das Nutzbare oben steht.
		erlaubteKlassen = erlaubteKlassen or {}
		for _, eintrag in ipairs ( armyWaffen ) do
			if not eintrag[4] or erlaubteKlassen[eintrag[4]] then
				liste[#liste+1] = eintrag
			end
		end
		for _, eintrag in ipairs ( armyWaffen ) do
			if eintrag[4] and not erlaubteKlassen[eintrag[4]] then
				liste[#liste+1] = eintrag
			end
		end
		return liste
	elseif thefrac == 14 then
		for _, eintrag in ipairs ( anonymusWaffen ) do
			liste[#liste+1] = eintrag
		end
	elseif staatsFraktionen[thefrac] then
		-- Eigene, vollstaendige Liste statt Fraktionswaffe plus Standardsatz.
		for _, eintrag in ipairs ( staatsWaffen ) do
			liste[#liste+1] = eintrag
		end
	else
		for _, eintrag in ipairs ( fraktionsWaffen[thefrac] or standardWaffen ) do
			liste[#liste+1] = eintrag
		end
		for _, eintrag in ipairs ( gemeinsameWaffen ) do
			liste[#liste+1] = eintrag
		end
	end

	local verfuegbar = {}
	for _, eintrag in ipairs ( liste ) do
		if therank >= eintrag[2] then
			verfuegbar[#verfuegbar+1] = eintrag
		end
	end

	-- Ohne den Positionsvergleich waere die Reihenfolge bei gleichem Rang und
	-- gleichem Preis nicht festgelegt und koennte je nach Rang wechseln.
	local position = {}
	for i, eintrag in ipairs ( verfuegbar ) do
		position[eintrag] = i
	end

	table.sort ( verfuegbar, function ( a, b )
		if a[2] ~= b[2] then return a[2] < b[2] end
		if a[3] ~= b[3] then return a[3] < b[3] end
		return position[a] < position[b]
	end )

	return verfuegbar
end

function createFgunsGui (therank, thefrac, dieKlasse, erlaubteKlassen)
	if isElement(GUIEditor.window[1]) then return end
	therank = tonumber ( therank ) or 0
	guiSetInputMode("no_binds_when_editing")
	showCursor (true)
	setElementClicked ( true )
	GUIEditor.button = {}
	GUIEditor.label = {}
	buttonID = {}
	gesperrteKlasse = {}

	GUIEditor.window[1] = dgsCreateWindow(0.26, 0.05, 0.50, 0.86, "Fraktionslager", true, nil,nil,nil,nil,nil, tocolor(16,29,61,255))
	dgsSetProperty(GUIEditor.window[1], "image", false)
	dgsWindowSetMovable(GUIEditor.window[1], false)
	dgsWindowSetSizable(GUIEditor.window[1], false)
	dgsWindowSetCloseButtonEnabled(GUIEditor.window[1], false)
	dgsBringToFront (GUIEditor.window[1])

	erlaubteKlassen = erlaubteKlassen or {}
	local angebot = baueAngebot ( therank, thefrac, erlaubteKlassen )

	for i, eintrag in ipairs ( angebot ) do
		local name, preisIndex = eintrag[1], eintrag[3]
		local spalte = ( i - 1 ) % SPALTEN + 1
		local zeile  = math.floor ( ( i - 1 ) / SPALTEN ) + 1
		local x, y = SPALTE_X[spalte], ZEILE_Y[zeile]

		if y then
			-- Gesperrt, wenn die Waffe eine andere Klasse verlangt als die eigene.
			local benoetigt = eintrag[4]
			local gesperrt = benoetigt ~= nil and not erlaubteKlassen[benoetigt]

			local knopf
			if gesperrt then
				knopf = dgsCreateButton(x, y, SPALTE_B, KNOPF_H, name, true, GUIEditor.window[1], _, _, _, _, _, _, tocolor(70,78,92,255), tocolor(88,97,112,255), tocolor(60,67,79,255))
				dgsSetProperty(knopf, "textColor", tocolor(160, 166, 178, 227))
			else
				knopf = dgsCreateButton(x, y, SPALTE_B, KNOPF_H, name, true, GUIEditor.window[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
				dgsSetProperty(knopf, "textColor", tocolor(255, 255, 255, 227))
			end

			local geld
			if gesperrt then
				geld = dgsCreateLabel(x, y + GELD_DY, SPALTE_B, LABEL_H, "Klasse: "..benoetigt, true, GUIEditor.window[1])
				dgsLabelSetColor(geld, 200, 150, 60)
			else
				geld = dgsCreateLabel(x, y + GELD_DY, SPALTE_B, LABEL_H, Moneycost[preisIndex]..""..Tables.waehrung.."", true, GUIEditor.window[1])
			end
			dgsLabelSetHorizontalAlign(geld, "center", false)

			GUIEditor.button[#GUIEditor.button+1] = knopf
			GUIEditor.label[#GUIEditor.label+1] = geld

			if not staatsFraktionen[thefrac] then
				local mats = dgsCreateLabel(x, y + MATS_DY, SPALTE_B, LABEL_H, Matscost[preisIndex].." Mats", true, GUIEditor.window[1])
				dgsLabelSetHorizontalAlign(mats, "center", false)
				GUIEditor.label[#GUIEditor.label+1] = mats
			end

			if gesperrt then
				gesperrteKlasse[knopf] = benoetigt
				addEventHandler ("onDgsMouseClickUp", knopf, zeigeKlassenHinweis, false)
			else
				buttonID[knopf] = preisIndex
				addEventHandler ("onDgsMouseClickUp", knopf, sendTheWeaponFromFGunsToServer, false)
			end
		end
	end

	if thefrac == 8 then
		local freigeschaltet = {}
		for klasse in pairs ( erlaubteKlassen ) do
			freigeschaltet[#freigeschaltet+1] = klasse
		end
		table.sort ( freigeschaltet )
		local text
		if #freigeschaltet > 0 then
			text = "Klasse: "..( dieKlasse or "keine" ).."  -  freigeschaltet: "..table.concat ( freigeschaltet, ", " )
		else
			text = "Du hast keine Klassen-Berechtigung - vergeben wird sie mit /setpermission"
		end
		local kopf = dgsCreateLabel(0.03, 0.845, 0.94, 0.035, text, true, GUIEditor.window[1])
		dgsLabelSetHorizontalAlign(kopf, "center", false)
		dgsLabelSetColor(kopf, 200, 200, 200)
		GUIEditor.label[#GUIEditor.label+1] = kopf
	end

	GUIEditor.closeButton = dgsCreateButton(0.29, 0.88, 0.43, 0.08, "Schließen", true, GUIEditor.window[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetProperty(GUIEditor.closeButton, "textColor", tocolor(255, 255, 255, 227))
	addEventHandler ("onDgsMouseClickUp", GUIEditor.closeButton, closeFgunsGui, false)
end
addEvent ( "startFgunsGui", true )
addEventHandler( "startFgunsGui", getRootElement(), createFgunsGui )


function sendTheWeaponFromFGunsToServer ( button )
	if button == "left" then
		-- Nur der Name geht raus; den Preis bestimmt der Server anhand seiner
		-- eigenen Tabelle (fraktionen/fdepots.lua).
		triggerServerEvent ( "giveFgunsWeapon", lp, dgsGetText(source) )
	end
end


function closeFgunsGui ( button )
	if button == "left" then
		showCursor (false)
		guiSetInputMode("allow_binds")
		setElementClicked ( false )
		-- Das Fenster zerstoert seine Kinder mit, die Tabellen muessen aber
		-- geleert werden, sonst bleiben tote Element-Verweise stehen.
		if isElement ( GUIEditor.window[1] ) then
			destroyElement (GUIEditor.window[1])
		end
		GUIEditor.window[1] = nil
		GUIEditor.closeButton = nil
		GUIEditor.button = {}
		GUIEditor.label = {}
		buttonID = {}
		gesperrteKlasse = {}
	end
end
