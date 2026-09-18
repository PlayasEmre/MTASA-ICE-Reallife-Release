------------------------------
-------- Urheberrecht --------
------- by [LA]Leyynen -------
-------- 2012 - 2013 ---------
------------------------------
---- Script by Noneatme ------

loadstring(exports.DGS:dgsImportFunction())()

local Guivar = 0
local GuivarMech = 0

addEvent("onVioOrdnungsamtTuningGuiStart1", true)
addEvent("onVioOrdnungsamtTuningGuiStart2", true)
local aramp1, aramp2
local aramp3

local Fenster = {}

local Knopf = {}
local Label = {}
local Grid = {}
	

local oamt_tunings = {
	{ "Kleine Reparatur", 50, "fix" },
	{ "Nitro auffüllen", 250, "fix" },
	{ "Sportmotor 1", 100000, "sportmotor" },
	{ "Sportmotor 2", 250000, "sportmotor" },
	{ "Sportmotor 3", 500000, "sportmotor" },
	{ "Bremse 1", 25000, "bremse" },
	{ "Bremse 2", 50000, "bremse" },
	{ "Bremse 3", 100000, "bremse" },
	{ "Frontantrieb", 40000, "antrieb" },
	{ "Heckantrieb", 40000, "antrieb" },
	{ "Allradantrieb", 40000, "antrieb" },
	{ "Totalschaden", 20000, "totalschaden" }
}

local function refreshOAMTGrid2(car)
	dgsGridListClear(Grid[1])
	if isElement ( aramp2 ) and getElementData ( aramp2, "owner" ) --[[and getElementData ( aramp2, "owner" ) ~= getPlayerName ( localPlayer )--]] then
		for i = 1, #oamt_tunings, 1 do
			local name, preis, data = oamt_tunings[i][1], oamt_tunings[i][2], oamt_tunings[i][3]
			local eingebaut = "-"
			if data == "sportmotor" then
				if getElementData ( aramp2, "sportmotor" ) >= i - 2 then
					eingebaut = "Ja"
				else
					eingebaut = "Nein"
				end
			elseif data == "bremse" then
				if getElementData ( aramp2, "bremse" ) >= i - 5 then
					eingebaut = "Ja"
				else
					eingebaut = "Nein"
				end
			elseif data == "antrieb" then
				local antrieb = getElementData ( aramp2, "antrieb" ) 
				if antrieb == "fwd" and name == "Frontantrieb" then 
					eingebaut = "Ja"
				elseif antrieb == "rwd" and name == "Heckantrieb" then
					eingebaut = "Ja"
				elseif antrieb == "awd" and name == "Allradantrieb" then
					eingebaut = "Ja"
				else
					eingebaut = "Nein"
				end
			elseif data == "totalschaden" then
				if getElementData ( aramp2, "totalschaden" ) == 1 then
					eingebaut = "total"
				else
					eingebaut = "Nein"
				end
			end	
			local Besitzer = getElementData (car[1], "owner")
			local model = getElementModel(car[1])
			local row = dgsGridListAddRow(Grid[1])
			dgsGridListSetItemText(Grid[1], row, 1, name, false, false)
			dgsGridListSetItemText(Grid[1], row, 2, eingebaut, false, false)
			dgsGridListSetItemText(Grid[1], row, 3, preis..""..Tables.waehrung.."", false, false)
		end	
	end
end


-- Aktualisiert die Ja/Nein-Anzeige live, sobald der Server die Tuning-Daten des
-- Fahrzeugs aendert (z.B. nach Ablauf der 5-Sekunden-Einbauzeit) - man muss dafuer
-- nicht mehr aus dem Marker raus und wieder rein laufen.
local function onOAMTVehicleDataChange(dataName)
	if dataName == "sportmotor" or dataName == "bremse" or dataName == "antrieb" or dataName == "totalschaden" then
		if isElement(Fenster[1]) and isElement(aramp2) then
			refreshOAMTGrid2({aramp2})
		end
	end
end

local function createOAMTGui2(car)
	if(GuivarMech == 1) then return end
	GuivarMech = 1
	guiSetInputMode("no_binds_when_editing")
	showCursor(true)
	setElementClicked ( true )

	local sWidth, sHeight = guiGetScreenSize()
 
    local Width,Height = 404,330
    local X = (sWidth/2) - (Width/2)
    local Y = (sHeight/2) - (Height/2)
	
	Fenster[1] = dgsCreateWindow(X, Y, Width, Height, "Mechaniker Tuningfenster",false, nil,nil,nil,nil,nil, tocolor(16,29,61,255))
	dgsBringToFront(Fenster[1])
	dgsSetProperty(Fenster[1], "image", false)
	dgsWindowSetMovable(Fenster[1], false)
	dgsWindowSetSizable(Fenster[1], false)
	Label[1] = dgsCreateLabel(11,21,384,52,"Willkommen an der Werkbank!\nHier kannst du aussuchen, was mit dem Auto in der Werkstatt\npassieren soll.",false,Fenster[1])
	dgsSetFont(Label[1],"default-bold")
	Label[2] = dgsCreateLabel(11,51,383,19,"______________________________________________________________",false,Fenster[1])
	dgsLabelSetColor(Label[2],0, 255, 0,255)
	local t1 = "N/A"
	aramp2 = nil
	if(type(car) == "table") then
		if(isElement(car[1])) then
			t1 = getVehicleNameFromModel(getElementModel(car[1]))
			aramp2 = car[1]
		end
	end

	Label[3] = dgsCreateLabel(12,79,380,34,"Werkstatt: "..t1,false,Fenster[1])
	dgsSetFont(Label[3],"default-bold")
	Grid[1] = dgsCreateGridList(15,163,226,158,false,Fenster[1])
	dgsGridListSetSelectionMode(Grid[1],1)

	dgsGridListAddColumn(Grid[1],"Aktion",0.5)

	dgsGridListAddColumn(Grid[1],"Eingebaut",0.2)

	dgsGridListAddColumn(Grid[1],"Preis",0.2)
	Knopf[1] = dgsCreateButton(250,172,138,32,"Aktion durchführen",false,Fenster[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	Knopf[2] = dgsCreateButton(252,279,138,32,"Abbrechen",false,Fenster[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	Knopf[3] = dgsCreateButton(250,207,138,32,"Aktion entfernen",false,Fenster[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetEnabled(Knopf[3], false)
	refreshOAMTGrid2(car)
	if isElement(aramp2) then
		addEventHandler("onClientElementDataChange", aramp2, onOAMTVehicleDataChange)
	end
	-- EVENT HANDLERS --

	addEventHandler("onDgsMouseClickUp", Knopf[1], function(button)
		if button ~= "left" then return end
		local selectedRow = dgsGridListGetSelectedItem(Grid[1])
		if selectedRow == -1 then return end
		local aktion, eingebaut, preis = dgsGridListGetItemText(Grid[1], selectedRow, 1), dgsGridListGetItemText(Grid[1], selectedRow, 2),  dgsGridListGetItemText(Grid[1], selectedRow, 3)
		if(aktion == "") then return end
		car = aramp2
		if(eingebaut == "Ja") then
			outputChatBox("Diese Aktion wurde bereits durchgeführt!", 200, 0, 0)
			return
		end

		triggerServerEvent("onVioOAmtCarTuning", localPlayer, car, aktion, tonumber(gettok(preis, 1, ""..Tables.waehrung.."")))
	end, false)

	-- CANCEL BUTTON --
	addEventHandler("onDgsMouseClickUp", Knopf[2], function(button)
		if button ~= "left" then return end
		GuivarMech = 0
		if isElement(aramp2) then
			removeEventHandler("onClientElementDataChange", aramp2, onOAMTVehicleDataChange)
		end
		destroyElement(Fenster[1])
		Fenster[1] = nil
		showCursor(false)
		guiSetInputMode("allow_binds")
		setElementClicked ( false )
	end, false)
end
addEventHandler("onVioOrdnungsamtTuningGuiStart2", localPlayer, createOAMTGui2)