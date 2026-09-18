--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function michelleSelect()
	if michelles_Window and isElement(michelles_Window[1]) then
		destroyElement(michelles_Window[1])
	end
	guiSetInputMode("no_binds_when_editing")
	showCursor(true)
	setElementClicked(true)
	michelles_Window = {}
	michelles_Button = {}
	michelles_Label = {}

	michelles_Window[1] = dgsCreateWindow(392,202,222,204,"Michelle's",false)
	dgsWindowSetSizable ( michelles_Window[1], false )
	dgsWindowSetMovable ( michelles_Window[1], false )
	-- Kein x in der Titelleiste: geschlossen wird ueber die Buttons, sonst
	-- bliebe der Cursor haengen und der Server wuesste nichts vom Abbruch.
	dgsWindowSetCloseButtonEnabled ( michelles_Window[1], false )
	dgsBringToFront(michelles_Window[1])
	michelles_Label[1] = dgsCreateLabel(10,27,248,42,"Herzlich Willkommen bei Michelle's!\n\nWas koennen wir fuer dich tun?",false,michelles_Window[1])
	dgsSetFont(michelles_Label[1],"default-bold")
	michelles_Button[1] = dgsCreateButton(38,119,137,30,"Speziallack",false,michelles_Window[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(michelles_Button[1],"default-bold")
	michelles_Button[2] = dgsCreateButton(38,155,137,30,"Nichts",false,michelles_Window[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(michelles_Button[2],"default-bold")


	addEventHandler("onDgsMouseClickUp", michelles_Button[1], function(button)
		if button ~= "left" then return end
		dgsSetVisible(michelles_Window[1], false)
		showSpezialLack()
	end)
	addEventHandler("onDgsMouseClickUp", michelles_Button[2], function(button)
		if button ~= "left" then return end
		dgsSetVisible(michelles_Window[1], false)
		guiSetInputMode("allow_binds")
		showCursor(false)
		triggerServerEvent("closeMichelles", localPlayer)
	end)
end
addEvent( "showMichelles", true )
addEventHandler( "showMichelles", getRootElement(), michelleSelect )

SpezialLack_Window = {}
SpezialLack_Button = {}
SpezialLack_Label = {}
SpezialLack_Scrollbar = {}


function showSpezialLack()
	showCursor(true)

	local veh = getPedOccupiedVehicle(localPlayer)
	if getElementData(veh, "spezcolor") == "" then
		kosten = "2.500"
	else
		kosten = "1.250"
	end


	-- Hoehe 390 statt 337: die Vorschau-Zeile kam dazu, und die Titelleiste
	-- rechnet DGS nicht in die Fensterhoehe ein.
	SpezialLack_Window[1] = dgsCreateWindow(7,160,360,390,"Michelle's Speziallack",false)
	dgsWindowSetSizable ( SpezialLack_Window[1], false )
	dgsWindowSetMovable ( SpezialLack_Window[1], false )
	-- Kein x: ueber "Abbrechen" wird zusaetzlich closeSpezialLack ausgeloest,
	-- das die urspruengliche Lackierung wiederherstellt. Ein x haette die
	-- Vorschaufarbe am Fahrzeug stehen lassen.
	dgsWindowSetCloseButtonEnabled ( SpezialLack_Window[1], false )
	dgsBringToFront(SpezialLack_Window[1])
	SpezialLack_Label[1] = dgsCreateLabel(11,26,308,45,"Willkommen bei Michelle's Speziallack Tuning-Garage!\nHier kannst du dir dein Fahrzeug in knalligen Farben\numlackieren. Mische dir dazu eine Farbe zusammen.",false,SpezialLack_Window[1])
	dgsSetFont(SpezialLack_Label[1],"default-bold")
	SpezialLack_Label[2] = dgsCreateLabel(13,79,50,16,"Farbe 1:",false,SpezialLack_Window[1])
	dgsSetFont(SpezialLack_Label[2],"default-bold")
	SpezialLack_Scrollbar[1] = dgsCreateScrollBar(52,95,265,21,true,false,SpezialLack_Window[1])
	SpezialLack_Label[3] = dgsCreateLabel(12,97,23,13,"Rot:",false,SpezialLack_Window[1])
	dgsLabelSetColor(SpezialLack_Label[3],255,0,0)
	dgsSetFont(SpezialLack_Label[3],"default-bold")
	SpezialLack_Scrollbar[2] = dgsCreateScrollBar(52,120,265,21,true,false,SpezialLack_Window[1])
	SpezialLack_Label[4] = dgsCreateLabel(12,121,38,14,"Grün:",false,SpezialLack_Window[1])
	dgsLabelSetColor(SpezialLack_Label[4],0,255,0)
	dgsSetFont(SpezialLack_Label[4],"default-bold")
	SpezialLack_Scrollbar[3] = dgsCreateScrollBar(52,146,265,21,true,false,SpezialLack_Window[1])
	SpezialLack_Label[5] = dgsCreateLabel(12,147,38,14,"Blau:",false,SpezialLack_Window[1])
	dgsLabelSetColor(SpezialLack_Label[5],0,0,255)
	dgsSetFont(SpezialLack_Label[5],"default-bold")
	SpezialLack_Label[6] = dgsCreateLabel(9,172,278,15,"Farbe 2: (Motorraeder u. Fahrzeuge mit Paintjob)",false,SpezialLack_Window[1])
	dgsSetFont(SpezialLack_Label[6],"default-bold")
	SpezialLack_Scrollbar[4] = dgsCreateScrollBar(52,193,264,21,true,false,SpezialLack_Window[1])
	SpezialLack_Label[7] = dgsCreateLabel(12,195,23,13,"Rot:",false,SpezialLack_Window[1])
	dgsLabelSetColor(SpezialLack_Label[7],255,0,0)
	dgsSetFont(SpezialLack_Label[7],"default-bold")
	SpezialLack_Scrollbar[5] = dgsCreateScrollBar(52,220,263,21,true,false,SpezialLack_Window[1])
	SpezialLack_Scrollbar[6] = dgsCreateScrollBar(52,247,263,21,true,false,SpezialLack_Window[1])
	SpezialLack_Label[8] = dgsCreateLabel(12,222,38,14,"Grün:",false,SpezialLack_Window[1])
	dgsLabelSetColor(SpezialLack_Label[8],0,255,0)
	dgsSetFont(SpezialLack_Label[8],"default-bold")
	SpezialLack_Label[9] = dgsCreateLabel(12,249,38,14,"Blau:",false,SpezialLack_Window[1])
	dgsLabelSetColor(SpezialLack_Label[9],0,0,255)
	dgsSetFont(SpezialLack_Label[9],"default-bold")
	-- Farbvorschau: gefaerbte Blockzeichen zeigen die gemischte Farbe direkt
	-- im Fenster, daneben die RGB-Werte zum Ablesen.
	SpezialLack_Label[11] = dgsCreateLabel(12,272,60,16,"Vorschau:",false,SpezialLack_Window[1])
	dgsSetFont(SpezialLack_Label[11],"default-bold")

	SpezialLack_Label[12] = dgsCreateLabel(78,272,52,16,"██████",false,SpezialLack_Window[1])
	dgsSetFont(SpezialLack_Label[12],"default-bold")
	SpezialLack_Label[13] = dgsCreateLabel(132,272,80,16,"0/0/0",false,SpezialLack_Window[1])

	SpezialLack_Label[14] = dgsCreateLabel(216,272,52,16,"██████",false,SpezialLack_Window[1])
	dgsSetFont(SpezialLack_Label[14],"default-bold")
	SpezialLack_Label[15] = dgsCreateLabel(270,272,80,16,"0/0/0",false,SpezialLack_Window[1])

	SpezialLack_Label[10] = dgsCreateLabel(32,296,300,14,"Umlackieren: 1.250€, Neue Lackierung: 2.500€",false,SpezialLack_Window[1])
	dgsSetFont(SpezialLack_Label[10],"default-bold")
	SpezialLack_Button[1] = dgsCreateButton(11,318,141,29,"Lackieren ("..kosten.." €)",false,SpezialLack_Window[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(SpezialLack_Button[1],"default-bold")
	SpezialLack_Button[2] = dgsCreateButton(171,318,141,29,"Abbrechen",false,SpezialLack_Window[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(SpezialLack_Button[2],"default-bold")

	-- Die Scrollbars liefern 0-100, das Fahrzeug braucht 0-255.
	local function farbwerte()
		local w = {}
		for i = 1, 6 do
			w[i] = math.floor ( dgsScrollBarGetScrollPosition ( SpezialLack_Scrollbar[i] ) * 2.55 )
		end
		return w[1], w[2], w[3], w[4], w[5], w[6]
	end

	local letzterServerRuf = 0

	local function updateSpezialLack()
		local r1, g1, b1, r2, g2, b2 = farbwerte()

		-- Vorschau im Fenster
		dgsLabelSetColor ( SpezialLack_Label[12], r1, g1, b1 )
		dgsSetText ( SpezialLack_Label[13], r1.."/"..g1.."/"..b1 )
		dgsLabelSetColor ( SpezialLack_Label[14], r2, g2, b2 )
		dgsSetText ( SpezialLack_Label[15], r2.."/"..g2.."/"..b2 )

		-- Vorschau am Fahrzeug: lokal sofort, damit es beim Ziehen ohne
		-- Verzoegerung mitgeht.
		local veh = getPedOccupiedVehicle ( localPlayer )
		if veh then
			setVehicleColor ( veh, r1, g1, b1, r2, g2, b2 )
		end

		-- Zusaetzlich an den Server, damit andere Spieler es auch sehen -
		-- aber gedrosselt, sonst geht beim Ziehen pro Pixel ein Event raus.
		local jetzt = getTickCount ()
		if jetzt - letzterServerRuf >= 150 then
			letzterServerRuf = jetzt
			triggerServerEvent("seeSpezialLack", localPlayer,
				dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[1]),
				dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[2]),
				dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[3]),
				dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[4]),
				dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[5]),
				dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[6]))
		end
	end

	-- onDgsScrollBarScrollPositionChange feuert nie: der Shim in DGS
	-- (functions.lua) vergleicht dgsGetType(source) mit "scrollbar", der
	-- echte Typ heisst aber "dgs-dxscrollbar". Deshalb direkt an das Event,
	-- das DGS tatsaechlich ausloest.
	for i = 1, 6 do
		addEventHandler("onDgsElementScroll", SpezialLack_Scrollbar[i], updateSpezialLack, false)
	end
	updateSpezialLack()

	addEventHandler("onDgsMouseClickUp", SpezialLack_Button[1], function(button)
		if button ~= "left" then return end
		dgsSetVisible(SpezialLack_Window[1], false)
		guiSetInputMode("allow_binds")
		showCursor(false)
		setElementClicked(false)
		local red1 = math.floor(dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[1]))
		local green1 = math.floor(dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[2]))
		local blue1 = math.floor(dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[3]))
		local red2 = math.floor(dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[4]))
		local green2 = math.floor(dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[5]))
		local blue2 = math.floor(dgsScrollBarGetScrollPosition(SpezialLack_Scrollbar[6]))
		triggerServerEvent("buySpezialLack", localPlayer, red1, green1, blue1, red2, green2, blue2)
	end)

      addEventHandler ( "onClientVehicleExit", getRootElement(),function()
         dgsSetVisible(SpezialLack_Window[1], false)
         guiSetInputMode("allow_binds")
         showCursor(false)
         setElementClicked(false)
      end)


	addEventHandler("onDgsMouseClickUp", SpezialLack_Button[2], function(button)
		if button ~= "left" then return end
		dgsSetVisible(SpezialLack_Window[1], false)
		guiSetInputMode("allow_binds")
		showCursor(false)
		setElementClicked(false)
		triggerServerEvent("closeSpezialLack", localPlayer)
	end)
end
