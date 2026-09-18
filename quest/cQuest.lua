--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Ein-/Ausblenden der Quest-Aufgabe-Box per /quest, mit kurzer Ausfahr-Animation
-- (die Box faehrt seitlich raus/rein statt einfach zu verschwinden).
local QUEST_BOX_WIDTH = 280
local QUEST_SLIDE_MS = 300

local questBoxVisible = true
local questSlideStart = 0
local questSlideFrom = 0
local questSlideTo = 0
local questHintShown = false

local function toggleQuestBox ()
	questBoxVisible = not questBoxVisible
	local now = getTickCount ()
	local elapsed = now - questSlideStart
	local progress = math.min ( ( elapsed / QUEST_SLIDE_MS ), 1 )
	local currentOffset = questSlideFrom + ( questSlideTo - questSlideFrom ) * progress

	questSlideStart = now
	questSlideFrom = currentOffset
	questSlideTo = questBoxVisible and 0 or QUEST_BOX_WIDTH
end
addCommandHandler ( "quest", toggleQuestBox )

local function getQuestBoxOffset ()
	local elapsed = getTickCount () - questSlideStart
	local progress = math.min ( ( elapsed / QUEST_SLIDE_MS ), 1 )
	return questSlideFrom + ( questSlideTo - questSlideFrom ) * progress
end

-- Farben einmal berechnen statt bei jedem Zeichenaufruf.
local FARBE_BOX   = tocolor ( 0, 0, 0, 140 )
local FARBE_WEISS = tocolor ( 255, 255, 255, 255 )

-- Der Fortschrittstext ( "3/12" ) wurde in jedem Frame neu zusammengesetzt,
-- obwohl er sich nur beim Wechsel der Aufgabe aendert.
local fortschrittWert, fortschrittText = nil, ""

-- Guard Clauses statt sechsfach verschachtelter ifs: sobald eine Bedingung
-- nicht passt, ist der Frame sofort fertig.
addEventHandler("onClientRender",root,function()
	if introCutsceneAktiv then return end -- Waehrend der Intro-Kamerafahrt gesperrt, siehe quest/intro_cutscene_client.lua
	if getElementData ( localPlayer, "loggedin" ) ~= 1 then return end
	if getElementData ( localPlayer, "ElementClicked" ) ~= false then return end
	if isPedDead ( localPlayer ) then return end
	if isPlayerMapVisible ( localPlayer ) ~= false then return end
	if not cdn:getReady() then return end

	local introtask = tonumber ( vioClientGetElementData ( "Introtask" ) )
	if not introtask then return end

	local aufgaben = globalTables["Tasks"]
	local anzahl = aufgaben and #aufgaben or 0
	if introtask > anzahl then return end

	if not questHintShown then
		questHintShown = true
		outputChatBox ( "Tipp: Mit /quest kannst du die Quest-Aufgabe-Anzeige ein- und ausblenden.", 255, 200, 0 )
	end

	local offset = getQuestBoxOffset ()
	if offset >= QUEST_BOX_WIDTH then return end

	if introtask ~= fortschrittWert then
		fortschrittWert = introtask
		fortschrittText = introtask.."/"..anzahl
	end

	dxDrawRectangle(1625*Gsx+offset*Gsx,510*Gsy,280*Gsx,120*Gsy,FARBE_BOX,false)
	dxDrawRectangle(1645*Gsx+offset*Gsx,545*Gsy,240*Gsx,2*Gsy,FARBE_WEISS,false)
	dxDrawText("Quest-Aufgabe:",3325*Gsx+offset*Gsx,515*Gsy,200*Gsx+offset*Gsx,922*Gsy,FARBE_WEISS,1.00*Gsx,dxFONT,"center",nil,nil,nil,false,nil)
	dxDrawText(aufgaben[introtask],3325*Gsx+offset*Gsx,560*Gsy,200*Gsx+offset*Gsx,922*Gsy,FARBE_WEISS,1.00*Gsx,dxFONT2,"center",nil,nil,nil,false,nil)
	dxDrawText(fortschrittText,3560*Gsx+offset*Gsx,605*Gsy,200*Gsx+offset*Gsx,922*Gsy,FARBE_WEISS,0.95*Gsx,dxFONT2,"center",nil,nil,nil,false,nil)
end)
