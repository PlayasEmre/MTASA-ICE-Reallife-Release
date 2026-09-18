--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--\\                                                  //

local ICE = {Window={},Button={},Gridlist={},GridlistColumn={},Label={},Edit={},Image={},Tabpanel={},Tab={},Music={},Memo={},Combo={},ComboItem={},CPicker={},ScrollBar={},Radio={},Blurbox={},Probar={},Browser={}}

local helpmenue = false
local lp = localPlayer

-- Wird vom Server gesetzt/aktualisiert (siehe helpmenue_server.lua).
local webInterfaceURL = "http://185.249.197.200/webpanel/?page=login"

-- Layout-Konstanten. Auf die urspruenglichen, bewaehrten Werte zurueckgesetzt
-- (die "aufgeraeumte" Version mit einheitlichem Rand hat im Spiel schlechter
-- ausgesehen als vorher), nur noch als benannte Konstanten statt Zahlen im Code.
local WIN_W, WIN_H = 700, 450
-- Kategorieliste und Textfeld beginnen auf derselben Hoehe, etwas weiter oben
-- im Fenster als vorher (y=8 statt y=15); Breiten/Hoehen unveraendert.
local GRID_X, GRID_Y, GRID_W, GRID_H = 5, 8, 205, 392
local PANEL_X, PANEL_Y, PANEL_W, PANEL_H = 220, 8, 460, 415

local helpmenueText =
{
	["Willkommen"] = "Willkommen auf "..Tables.servername.."-Reallife\n\n"..Tables.servername.."-Reallife bietet dir ein\neinmaliges Spielerlebnis. Zusammen mit der\nCommunity wirst du sicher viel Spaß haben.\nSolltest du Fragen oder Probleme haben, kannst\ndu dich gerne an das Admin-Team wenden. Nutze\ndazu einfach den Befehl /report und stelle\ndeine Anfrage.\n\nWir freuen uns auf dich!",

	["Serverregeln"] = [[Allgemeine Regeln

§1 - Nutzung von Bugs, Cheats oder Hacks ist strengstens
verboten.

§1.1 - Jedem Spieler ist es nur gestattet mit einem 1
Account zu spielen.

§1.2 - Auf allen Plattformen von ICE-Reallife ist die
Benutzung von härteren Beleidigungen, besonders RL
bezogene, strengstens untersagt.

§1.3 - Den Anweisungen von Teammitgliedern ist Folge zu
leisten.

§1.4 - Das Lügen gegenüber Teammitgliedern ist verboten!

§1.5 - Jeglicher Betrug ist untersagt!

§1.6 - Serverwerbung, Serverbeleidigung sowie
Serverschädigung werden streng geahndet.
Unter Serverwerbung versteht man das gezielte Werben für
andere Tactics- und Reallife-Server.

§1.7 - Das Handeln mit echtem Geld unter den Spielern ist
nicht gestattet.

§1.8 - Solltet ihr an einem PC mit 2 Accounts spielen
wollen, müsst ihr euch bei einem Projektleiter melden.

§1.9 - Erpressung mit Beschwerden ist untersagt.

§2 - Spieler, die den Server verlassen, dürfen ihren
Besitz nicht verschenken.

§2.1 - Meta-Gaming, also die Nutzung von Informationen
auf dem Server, die man im Spiel nicht hätte bekommen
können, ist nicht erlaubt.



Allgemeine Serverregeln

§1 - Carsurfing ist strengstens untersagt!

§1.1 - Sinnloses Deathmatch (SDM) ist verboten!
Unter SDM versteht man sinnloses Schlagen, Treten,
Schießen/Waffennutzung und Umfahren von Personen.

§1.2 - In No-DM-Zonen ist DM untersagt.
Unter No-DM-Zonen versteht man die auf der Karte grün
markierten Gebiete.
Ausnahme: Wantedjagd oder bei Flucht in die No-DM-Zone.

§1.3 - Eventstörung ist verboten!
Während Events haben alle Teilnehmer oder Zuschauer
DM-Schutz. Wird dieser nicht eingehalten, kann es zu
einem Warn und einer Prison-Strafe kommen.

§1.4 - Markerflucht, Offlineflucht und Selbstmordflucht
sind verboten.
Unter Markerflucht versteht man das Flüchten durch einen
Marker, wodurch der Verfolger nicht hindurch kann.
Bei Offlineflucht hat man die Pflicht, die gleiche
Situation vor der Flucht zu wiederholen.
Bei Selbstmordflucht bringt sich der Spieler um und wird
dann nicht verhaftet oder von einem anderen Spieler
getötet.
Dies wird mit einem Time-Ban von 1 Woche bestraft.

§1.5 - Spieler beim Spawnen anzuschießen ist nicht
erlaubt.
Dabei ist auch das Spawnen beim Betreten eines Markers
inbegriffen.

§1.6 - Absichtliche Zerstörung von Fahrzeugen anderer
User ist nicht gestattet.
Ausnahme: bei einer Aktion mit einem Aktionsfahrzeug,
dies zählt aber nur beim Museumsraub.

§1.7 - Driveby ist nur von einem Beifahrer auf einen
anderen Beifahrer erlaubt.

§1.8 - Überfälle dürfen nur mit dem Befehl /rob [Name]
ausgeführt werden.

§1.9 - Binds sind nur gültig bei einem Abstand von
mindestens 5 Sekunden.

§2 - Auf die StVO (Straßenverkehrsordnung) ist zu achten.

§2.1 - Absichtliches Totparken, Überfahren oder Rammen
eines Spielers ist verboten. (Zählt als SDM)

§2.2 - Während einer DM-Situation ist es nicht erlaubt,
Leben oder Rüstung aufzubessern. Dies zählt als
Kampfheilung.

§2.3 - Zivilisten dürfen bösen Fraktionen nicht helfen.
Staatsfraktionen dürfen sie lediglich Informationen
geben.

§2.4 - Nach dem Tod ist es nicht gestattet, zur gleichen
Spielsituation zurückzukehren.
Eine Spielsituation endet erst, wenn eine der Seiten
völlig außer Gefecht ist oder mindestens 3 Minuten seit
dem letzten Schuss vergangen sind.

§2.5 - Spieler mit Wanteds dürfen nach einem
Gesucht-Bind eines Staatsfraktionisten diesen sofort
beschießen. Gilt ab 6 Wanteds.

§2.6 - Bei einer Verkehrskontrolle darf nicht geschossen
werden, außer der Spieler hat 6 Wanteds.

§2.7 - Job-DM und VKK bei Jobbern ist verboten.
Ausnahme: Verfolgungsjagd



Allgemeine Fraktionsregeln

§1 - Jeder Spieler hat nach einem Fraktions-Uninvite 24
Stunden Zivilzeit.
In dieser Zeit darf er sich keiner Fraktion anschließen.

§2 - Das Verlangen von Wertgegenständen im Austausch für
die Annahme eines Bewerbers ist untersagt.

§3 - Eine aktuelle Memberliste im Forum ist Pflicht!

§4 - Schriftliche Beschwerden gegen Fraktionsmitglieder
müssen im Bereich Beschwerden gegen User geschrieben
werden.

§5 - Beschwerden von Fraktionisten gegen andere
Fraktionisten müssen vor einer schriftlichen Beschwerde
im Teamspeak geklärt werden.

§6 - Die Fraktionskasse darf nicht für den eigenen
Gebrauch genutzt werden.

§7 - Rang-Up/Down für etwas zu missbrauchen ist nicht
gestattet.

§8 - Uninvite und Invite aus Spaß sind nicht gestattet.

§9 - Einer bösen Fraktion ist es nicht erlaubt, mit einer
anderen Fraktion gegen andere zusammenzuarbeiten.

§10 - Das unerlaubte Betreten der Basis einer anderen
Fraktion ist verboten.



Hinweis: Dies ist ein Auszug der wichtigsten Regeln. Die
vollständigen und stets aktuellen Regeln (inkl. Aktions-
und Waffenregeln) findest du im Forum.]],

	["Binds/Commands"] = "Hier kannst du einige Befehle sehen \n /commands\n /admincommands",
	["Daten"] = "Hier kannst du paar Informationen vom Server sehen\nUnsere Teamspeak IP: "..Tables.tsip.."\nUnser Forum:"..Tables.forumURL.." ",

	["Sonstiges"] = "Sonstiges\n\nMelde Regelverstöße, Bugs oder sonstige Probleme\njederzeit mit /report - unser Team kümmert sich\nschnellstmöglich darum.\n\nInteresse an einer Bewerbung fürs Team? Schau im\nForum unter "..Tables.forumURL.." im\nBewerbungsbereich vorbei.\n\nViel Spaß auf "..Tables.servername.."-Reallife!",

	["Changelog"] = [[Changelog - Was ist neu?

20.08.2026

- NEU: Glücksrad. Kauf dir am Rad ein Ticket, benutze es
aus dem Inventar heraus und dreh. Zu gewinnen gibt es
Geld, Benzinkanister, Zigaretten, Geschenke, Casino-Chips,
Coins, Premium und Freidrehungen. Ganz selten fällt der
Jackpot - und noch seltener das Fahrzeug, das daneben auf
dem Podest ausgestellt ist. Es wechselt jede Woche und ist
ein Modell, das man sonst nirgends kaufen kann.
Pro Woche kannst du 3 Tickets kaufen; erdrehte Tickets
zählen nicht dagegen.

- NEU: Fahrzeugverleih am Bahnhof San Fierro. Fünf
Fahrzeuge vom BMX für 10 bis zum Tampa für 300. Die Miete
läuft 30 Minuten, fünf Minuten vorher wirst du gewarnt.
Verlängern mit /verleihverlaengern, vorzeitig abgeben mit
/verleihabgeben. Fahren darf nur der Mieter, mitfahren
dürfen alle.

- NEU: Anschnallsystem. Mit [J] oder /gurt schnallst du
dich an. Ohne Gurt kann dich ein Aufprall ab 55 km/h aus
dem Fahrzeug schleudern - du bleibst dann kurz benommen
liegen. Angeschnallt kommst du erst wieder heraus, wenn du
den Gurt löst. Das Gurtsymbol im Tacho zeigt dir jederzeit,
woran du bist.

- Tacho überarbeitet: neue Anzeige mit der Geschwindigkeit
als Zahl, Tankring und Statussymbolen - darunter das neue
Gurtsymbol.

- Mitfahren auf Fahrzeugen [X]: Du klebst nicht mehr an
einer festen Stelle, sondern kannst dich mit den normalen
Laufrichtungen auf dem Fahrzeug bewegen.

- Ladebildschirm überarbeitet: läuft jetzt sauber auf jeder
Bildschirmauflösung, blendet weich ein und aus und zeigt
wechselnde Hinweise.

06.08.2026

- NEU: Intro-Kamerafahrt beim ersten Registrieren - eine
kurze Tour durch die wichtigsten Orte der Stadt (Bahnhof,
Rathaus, Autohäuser, Fahrschule, alle Fraktionen), mit
Untertiteln und Sprachausgabe. Überspringbar mit [N].

- Sanitäter-System überarbeitet: Verletzte werden jetzt
realistisch mit dem Krankenwagen ins Krankenhaus gefahren,
statt sofort vor Ort geheilt zu werden.

- Fahrschule erweitert: Abbiege-Hinweise, Tempolimit-Zonen
und ein LKW-mit-Anhänger-Fahrtest.

- Blitzer: Streifenwagen der Polizei sowie Sanitäter und
Mechaniker im Dienst und Admins im Admin-Duty-Modus werden
nicht mehr geblitzt.

- Diverse Fehlerbehebungen rund um Fahrschule, Schlüssel-
system, Admin-Befehle und mehr.

Ältere Änderungen findest du wie gewohnt in unseren
Ankündigungen im Forum.]],
}

-- Reihenfolge der Kategorien im Menü. "Webinterface" ist ein Sonderfall (siehe unten).
local categories = { "Willkommen", "Changelog", "Serverregeln", "Binds/Commands", "Daten", "Sonstiges", "Webinterface" }

local standartHelpmenuTXT = helpmenueText["Willkommen"]

local function deleteWebInterfaceUI()
	if isElement(ICE.Edit[1]) then destroyElement(ICE.Edit[1]) end
	if isElement(ICE.Edit[2]) then destroyElement(ICE.Edit[2]) end
	if isElement(ICE.Button[2]) then destroyElement(ICE.Button[2]) end
	if isElement(ICE.Button[3]) then destroyElement(ICE.Button[3]) end
	if isElement(ICE.Label[2]) then destroyElement(ICE.Label[2]) end
	if isElement(ICE.Label[3]) then destroyElement(ICE.Label[3]) end
	ICE.Edit[1] = nil
	ICE.Edit[2] = nil
	ICE.Button[2] = nil
	ICE.Button[3] = nil
	ICE.Label[2] = nil
	ICE.Label[3] = nil
end

local function showTextTab(name)
	deleteWebInterfaceUI()
	dgsSetVisible(ICE.Memo[1], true)
	dgsSetText(ICE.Memo[1], helpmenueText[name] or standartHelpmenuTXT)
end

local function showWebInterfaceTab()
	deleteWebInterfaceUI()
	dgsSetVisible(ICE.Memo[1], false)

	local btnW, rowH, rowGap = 100, 28, 10
	local editW = PANEL_W - btnW - rowGap
	local buttonX = PANEL_X + editW + rowGap

	ICE.Label[2] = dgsCreateLabel(PANEL_X,PANEL_Y,PANEL_W,80,"Webinterface\n\nHier findest du unser Webinterface. Kopiere dir unten die Adresse:",false,ICE.Window[1])
	dgsLabelSetVerticalAlign(ICE.Label[2],"top")
	dgsLabelSetHorizontalAlign(ICE.Label[2],"left",true)

	-- Adresse als schreibgeschuetztes Feld: jeder Spieler kann reinklicken und
	-- Strg+C nutzen, zusaetzlich ein Button, der direkt in die Zwischenablage kopiert.
	local urlRowY = PANEL_Y + 90
	ICE.Edit[1] = dgsCreateEdit(PANEL_X,urlRowY,editW,rowH,webInterfaceURL,false,ICE.Window[1])
	dgsEditSetReadOnly(ICE.Edit[1],true)
	ICE.Button[2] = dgsCreateButton(buttonX,urlRowY,btnW,rowH,"Kopieren",false,ICE.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
	dgsSetProperty(ICE.Button[2],"textColor",tocolor(255,255,255))

	addEventHandler("onDgsMouseClickUp",ICE.Button[2],
		function(btn)
			if btn == "left" then
				setClipboard(webInterfaceURL)
				dgsSetText(ICE.Button[2],"Kopiert!")
				setTimer(function()
					if isElement(ICE.Button[2]) then
						dgsSetText(ICE.Button[2],"Kopieren")
					end
				end,1500,1)
			end
		end,
	false)

	if tonumber(getElementData(lp,"adminlvl") or 0) == 6 then
		local adminLabelY = urlRowY + rowH + 30
		local adminRowY = adminLabelY + 25

		ICE.Label[3] = dgsCreateLabel(PANEL_X,adminLabelY,PANEL_W,20,"Adresse aendern (nur Admin):",false,ICE.Window[1])
		dgsLabelSetHorizontalAlign(ICE.Label[3],"left",true)

		ICE.Edit[2] = dgsCreateEdit(PANEL_X,adminRowY,editW,rowH,webInterfaceURL,false,ICE.Window[1])
		ICE.Button[3] = dgsCreateButton(buttonX,adminRowY,btnW,rowH,"Speichern",false,ICE.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
		dgsSetProperty(ICE.Button[3],"textColor",tocolor(255,255,255))

		addEventHandler("onDgsMouseClickUp",ICE.Button[3],
			function(btn)
				if btn == "left" then
					local newURL = dgsGetText(ICE.Edit[2])
					if not newURL or #newURL == 0 then
						outputChatBox ( "Bitte eine gueltige URL eingeben!", 125, 0, 0 )
						return
					end
					triggerServerEvent("helpmenue:setWebInterface",lp,newURL)
				end
			end,
		false)
	end
end

addEvent("helpmenue:webInterfaceSync",true)
addEventHandler("helpmenue:webInterfaceSync",root,
	function(url)
		webInterfaceURL = (url and url ~= "") and url or "Noch nicht gesetzt"
		-- falls der Webinterface-Tab gerade offen ist, sofort aktualisieren
		if isElement(ICE.Edit[1]) then
			dgsSetText(ICE.Edit[1],webInterfaceURL)
		end
	end
)

addEventHandler("onClientResourceStart",resourceRoot,
	function()
		triggerServerEvent("helpmenue:requestWebInterface",localPlayer)
	end
)

bindKey("f1", "down", function()
if introCutsceneAktiv then return end -- Menue waehrend der Intro-Kamerafahrt gesperrt, siehe quest/intro_cutscene_client.lua
if getElementData ( localPlayer, "loggedin" ) == 1 then
	if helpmenue == false then
		if not isPedDead(localPlayer) then
			if getElementData(localPlayer,"ElementClicked") == false then
				triggerServerEvent("set:task",localPlayer,localPlayer,"give:helpmenue")
			    showCursor(true)
				helpmenue = true
				ICE.Window[1] = dgsCreateWindow(GLOBALscreenX/2-WIN_W/2,GLOBALscreenY/2-WIN_H/2,WIN_W,WIN_H,"Hilfe-Panel",false)
				dgsWindowSetCloseButtonEnabled(ICE.Window[1], false)
				dgsWindowSetSizable(ICE.Window[1],false)
				dgsWindowSetMovable(ICE.Window[1],false)
				ICE.Button[1] = dgsCreateButton(WIN_W-26,-25,26,25,"×",false,ICE.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
				dgsSetProperty(ICE.Button[1],"textSize",{1.6,1.6})
				ICE.Gridlist[1] = dgsCreateGridList(GRID_X,GRID_Y,GRID_W,GRID_H,false,ICE.Window[1],_,tocolor(50,50,50,255),tocolor(255,255,255,255),tocolor(30,30,30,255),tocolor(65,65,65,255))
				local Kategorie = dgsGridListAddColumn(ICE.Gridlist[1],"Kategorie",0.9)

				for i, name in ipairs(categories) do
					local row = dgsGridListAddRow(ICE.Gridlist[1])
					dgsGridListSetItemText(ICE.Gridlist[1],row,Kategorie,name)
				end

				ICE.Memo[1] = dgsCreateMemo(PANEL_X,PANEL_Y,PANEL_W,PANEL_H,standartHelpmenuTXT,false,ICE.Window[1])
				dgsMemoSetReadOnly(ICE.Memo[1],true)
				-- KEIN dgsMemoSetWordWrapState(true) hier: DGS baut seine interne
				-- Zeilentabelle beim Aktivieren nur einmal auf und nicht bei jedem
				-- Kategoriewechsel neu, dadurch werden beim Wechseln falsche/alte
				-- Zeilen angezeigt (die noetige interne Rebuild-Funktion ist von DGS
				-- nicht nach aussen freigegeben). Lange Zeilen werden stattdessen
				-- direkt im Text unten mit \n von Hand umgebrochen.

				dgsGridListSetSortEnabled(ICE.Gridlist[1],false)

				addEventHandler("onDgsMouseClick",ICE.Gridlist[1],
					function(btn,state)
						if btn == "left" and state == "up" then
							local item=dgsGridListGetSelectedItem(ICE.Gridlist[1])
							if item > 0 then
									local clicked = dgsGridListGetItemText(ICE.Gridlist[1],item,1)
								if clicked == "Webinterface" then
									showWebInterfaceTab()
								elseif helpmenueText[clicked] then
									showTextTab(clicked)
								end
							else
								showTextTab("Willkommen")
							end
						end
					end,
				false)

				addEventHandler("onDgsMouseClick",ICE.Button[1],
					function(btn,state)
						if btn == "left" and state == "up" then
							dgsCloseWindow(ICE.Window[1])
							showCursor(false)
							helpmenue = false
							deleteWebInterfaceUI()
						end
					end,
				false)

				end
			end
		end
	end
end)
