--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

Infobox = {}
local sx, sy = guiGetScreenSize()

local BODY_FONT  = "default-bold"
local BODY_SCALE = 1
local TITLE_SCALE = 1.05
local TEXT_PADDING = 24 -- links/rechts insgesamt (Akzentbalken + Luft)

local CORNER_RADIUS = 10
local STUB_WIDTH = 40 -- Breite des abgetrennten "Ticket-Stub"-Bereichs rechts
local PERFORATION_GAP = 9 -- Abstand zwischen den Strichen der Perforationslinie

--======================================================================
-- Verlauf/Rundung-Zeichenhelfer fuer den "Holo-Ticket"-Look. Reine
-- dxDraw-Helfer, ohne Bezug zu DGS oder irgendeinem GUI-Widget-System.
--======================================================================
local GRADIENT_BANDS = 10

-- Lineare Interpolation zwischen zwei {r,g,b,a}-Farben
local function lerpColor(c1, c2, t)
	return {
		c1[1] + (c2[1] - c1[1]) * t,
		c1[2] + (c2[2] - c1[2]) * t,
		c1[3] + (c2[3] - c1[3]) * t,
		c1[4] + (c2[4] - c1[4]) * t,
	}
end

-- Vertikaler Farbverlauf ueber ein Rechteck, angenaehert durch mehrere
-- schmale Baender mit interpolierter Farbe.
local function drawGradientRect(x, y, w, h, topColor, bottomColor, postGUI)
	if h <= 0 or w <= 0 then return end
	local bandHeight = h / GRADIENT_BANDS
	for i = 0, GRADIENT_BANDS - 1 do
		local t = (i + 0.5) / GRADIENT_BANDS
		local c = lerpColor(topColor, bottomColor, t)
		dxDrawRectangle(x, y + i * bandHeight, w, bandHeight + 1,
			tocolor(c[1], c[2], c[3], c[4]), postGUI)
	end
end

-- Liefert fuer eine Eckzeile i (0 = aeusserste Zeile) den exakten
-- (Kommazahl-)Einzug per Kreisgleichung, plus den ganzzahligen Anteil und
-- den Bruchteil - Grundlage fuer die Kantenglaettung unten.
local function circleInset(radius, i)
	local dy = radius - i
	local dx = math.sqrt(math.max(0, radius * radius - dy * dy))
	local exact = radius - dx
	local floor = math.floor(exact)
	return floor, exact - floor
end

-- Zeichnet ein gefuelltes, "rundlich" wirkendes Rechteck: die Ecken werden
-- stufenweise (pro Zeile schmaler werdend) eingezogen, was optisch wie eine
-- weiche Rundung wirkt, technisch aber nur aus einzelnen dxDrawRectangle-
-- Zeilen besteht. roundLeft/roundRight (Default true) steuern, welche
-- Seite gerundet wird.
local function fillRoundedRect(x, y, w, h, radius, topColor, bottomColor, postGUI, roundLeft, roundRight)
	if roundLeft == nil then roundLeft = true end
	if roundRight == nil then roundRight = true end
	radius = math.min(radius, math.floor(h / 2), math.floor(w / 2))

	drawGradientRect(x, y + radius, w, h - radius * 2, topColor, bottomColor, postGUI)

	for i = 0, radius - 1 do
		local insetFloor, frac = circleInset(radius, i)
		local leftInset = roundLeft and (insetFloor + 1) or 0
		local rightInset = roundRight and (insetFloor + 1) or 0
		local rowW = w - leftInset - rightInset

		local topColorAtRow = lerpColor(topColor, bottomColor, i / h)
		local tr, tg, tb, ta = topColorAtRow[1], topColorAtRow[2], topColorAtRow[3], topColorAtRow[4]
		dxDrawRectangle(x + leftInset, y + i, rowW, 1, tocolor(tr, tg, tb, ta), postGUI)
		if roundLeft then dxDrawRectangle(x + insetFloor, y + i, 1, 1, tocolor(tr, tg, tb, ta * (1 - frac)), postGUI) end
		if roundRight then dxDrawRectangle(x + w - 1 - insetFloor, y + i, 1, 1, tocolor(tr, tg, tb, ta * (1 - frac)), postGUI) end

		local bottomRow = y + h - 1 - i
		local bottomColorAtRow = lerpColor(topColor, bottomColor, (h - i) / h)
		local br, bg, bb, ba = bottomColorAtRow[1], bottomColorAtRow[2], bottomColorAtRow[3], bottomColorAtRow[4]
		dxDrawRectangle(x + leftInset, bottomRow, rowW, 1, tocolor(br, bg, bb, ba), postGUI)
		if roundLeft then dxDrawRectangle(x + insetFloor, bottomRow, 1, 1, tocolor(br, bg, bb, ba * (1 - frac)), postGUI) end
		if roundRight then dxDrawRectangle(x + w - 1 - insetFloor, bottomRow, 1, 1, tocolor(br, bg, bb, ba * (1 - frac)), postGUI) end
	end
end

-- Umriss desselben "rundlichen" Rechtecks.
local function strokeRoundedRect(x, y, w, h, radius, color, postGUI, roundLeft, roundRight)
	if roundLeft == nil then roundLeft = true end
	if roundRight == nil then roundRight = true end
	radius = math.min(radius, math.floor(h / 2), math.floor(w / 2))
	local leftR = roundLeft and radius or 0
	local rightR = roundRight and radius or 0

	dxDrawRectangle(x, y + leftR, 1, h - leftR * 2, color, postGUI)
	dxDrawRectangle(x + w - 1, y + rightR, 1, h - rightR * 2, color, postGUI)
	dxDrawRectangle(x + leftR, y, w - leftR - rightR, 1, color, postGUI)
	dxDrawRectangle(x + leftR, y + h - 1, w - leftR - rightR, 1, color, postGUI)

	for i = 0, radius - 1 do
		local insetFloor, frac = circleInset(radius, i)
		if roundLeft then
			dxDrawRectangle(x + insetFloor, y + i, 1, 1, color, postGUI)
			dxDrawRectangle(x + insetFloor, y + h - 1 - i, 1, 1, color, postGUI)
		end
		if roundRight then
			dxDrawRectangle(x + w - 1 - insetFloor, y + i, 1, 1, color, postGUI)
			dxDrawRectangle(x + w - 1 - insetFloor, y + h - 1 - i, 1, 1, color, postGUI)
		end
	end
end

-- Der "Holo"-Verlauf (tuerkis oben, violett unten), leicht von einer
-- Akzentfarbe eingefaerbt. alphaMul skaliert beide Alpha-Werte (0..1).
local function holoColors(accentR, accentG, accentB, alphaMul)
	local top = {
		math.min(255, 18 + accentR * 0.15),
		math.min(255, 40 + accentG * 0.15),
		math.min(255, 46 + accentB * 0.25),
		215 * alphaMul
	}
	local bottom = {
		math.min(255, 40 + accentR * 0.15),
		math.min(255, 22 + accentG * 0.08),
		math.min(255, 55 + accentB * 0.25),
		230 * alphaMul
	}
	return top, bottom
end

-- Zaehlt, wie viele Zeilen ein Text braucht (harte \n UND automatischer Umbruch
-- durch die Boxbreite), damit die Boxhoehe vorher exakt berechnet werden kann.
local function countWrappedLines(text, maxWidth, scale, font)
    local lines = 0
    for line in (text.."\n"):gmatch("(.-)\n") do
        if line == "" then
            lines = lines + 1
        else
            local current = ""
            for word in line:gmatch("%S+") do
                local test = (current == "") and word or (current.." "..word)
                if current ~= "" and dxGetTextWidth(test, scale, font) > maxWidth then
                    lines = lines + 1
                    current = word
                else
                    current = test
                end
            end
            lines = lines + 1
        end
    end
    return math.max(lines, 1)
end

function Infobox.new(...)
    -- Create class instance
    local o = setmetatable({}, {__index = Infobox})

    -- Call constructor
    if o.constructor then
        o:constructor(...)
    end

    -- Return valid instance
    return o
end

function Infobox:constructor()
    -- Drawing
    self.m_fDraw = function(...) self:draw(...) end
    self.m_IsDrawing = false


    -- All infoboxes
    self.m_Boxs = {}

    -- Propertions
    self.m_Width = 340
    self.m_Height2 = 25 -- Titelleiste, fix
    self.m_PosX = sx - 5 - self.m_Width
    self.m_PosY = 300
    self.m_Alpha = 255

    -- add events
    addEvent("infobox_start", true)
    addEventHandler("infobox_start", root, function(...) self:create(...) end)
end

function Infobox:getProgress(idx)
	return (getTickCount() - self.m_Boxs[idx].startTime)/(self.m_Boxs[idx].endTime - self.m_Boxs[idx].startTime)
end


function Infobox:create(msg, time, r, g, b, title)
    -- Insert informations
    local now = getTickCount()
    msg = msg or ""

    -- Der Aufrufer meint mit "time" die gesamte sichtbare Dauer (inkl. Ein-/Ausblenden).
    -- Untergrenze, damit auch kurze Texte lesbar bleiben.
    local totalTime = tonumber(time) or 5000
    if totalTime < 5000 then totalTime = 5000 end
    local holdTime = totalTime - 1500
    if holdTime < 1500 then holdTime = 1500 end

    -- Akzentfarbe aus r,g,b - faellt auf ein dezentes Blau zurueck, wenn nichts uebergeben wurde.
    local accentR = tonumber(r) or 0
    local accentG = tonumber(g) or 150
    local accentB = tonumber(b) or 220

    -- Boxhoehe an den tatsaechlichen Text anpassen, damit auch laengere/mehrzeilige
    -- Texte (davon gibt's im Skript einige) sauber reinpassen statt ueberzulaufen.
    local maxTextWidth = self.m_Width - STUB_WIDTH - TEXT_PADDING
    local lineHeight = dxGetFontHeight(BODY_SCALE, BODY_FONT)
    local lineCount = countWrappedLines(msg, maxTextWidth, BODY_SCALE, BODY_FONT)
    local bodyHeight = math.max(75, lineCount * lineHeight + 22)
    local totalHeight = self.m_Height2 + bodyHeight

    -- Neue Box unter allen aktuell verfolgten Boxen stapeln (variable Hoehen!).
    local stackY = self.m_PosY
    for _, existingBox in ipairs(self.m_Boxs) do
        stackY = stackY + existingBox.totalHeight + 10
    end

    table.insert(self.m_Boxs, {
        -- Content
        title = title or "German "..Tables.servername.." Reallife",
        msg   = msg,
        accentR = accentR,
        accentG = accentG,
        accentB = accentB,
        holdTime = holdTime,
        bodyHeight = bodyHeight,
        totalHeight = totalHeight,

        -- Position
        posX = sx + 5,
        posY = stackY,
        alpha = 0,

        -- Animation
        startTime = now,
        endTime   = now + 750,
        stage = 1
    })

	sound = playSound(":"..getResourceName(getThisResource()).."/anzeigen/info.mp3",false)
	setSoundVolume(sound, 0.5)

    -- Enable drawing
    if not self.m_IsDrawing then
        self.m_IsDrawing = true
        addEventHandler("onClientRender", root, self.m_fDraw)
    end
end

-- Zeichnet die Box im "Holo-Ticket"-Look: links der Hauptteil (Titel + Text)
-- mit Holo-Farbverlauf, rechts ein abgetrennter, schmaler "Stub"-Bereich in
-- der Akzentfarbe (wie der Kontrollabschnitt eines echten Tickets), dazwischen
-- eine gestrichelte Perforationslinie. Nur links gerundete Ecken am
-- Hauptteil, nur rechts gerundete Ecken am Stub - macht die Trennung sichtbar.
-- Wird von allen drei Phasen (Einblenden/Halten/Ausblenden) gemeinsam genutzt.
function Infobox:drawBoxBody(posX, posY, alpha, box)
    local a = alpha / 255
    local totalHeight = box.totalHeight
    local bodyHeight = box.bodyHeight
    local bodyWidth = self.m_Width - STUB_WIDTH
    local stubX = posX + bodyWidth

    local accent = { box.accentR, box.accentG, box.accentB, 255 }
    local holoTop, holoBottom = holoColors(box.accentR, box.accentG, box.accentB, a)

    -- Dezenter Schlagschatten fuer etwas Tiefe (unter der ganzen Ticketform)
    fillRoundedRect(posX + 3, posY + 4, self.m_Width, totalHeight, CORNER_RADIUS,
        { 0, 0, 0, 90 * a }, { 0, 0, 0, 60 * a }, false)

    -- Hauptteil: Holo-Farbverlauf, nur links gerundet
    fillRoundedRect(posX, posY, bodyWidth, totalHeight, CORNER_RADIUS, holoTop, holoBottom, false, true, false)
    strokeRoundedRect(posX, posY, bodyWidth, totalHeight, CORNER_RADIUS, tocolor(accent[1], accent[2], accent[3], alpha), false, true, false)

    -- Stub: satte Akzentfarbe, nur rechts gerundet (wie der Kontrollabschnitt eines Tickets)
    fillRoundedRect(stubX, posY, STUB_WIDTH, totalHeight, CORNER_RADIUS,
        { accent[1] * 0.55, accent[2] * 0.55, accent[3] * 0.55, 235 * a },
        { accent[1] * 0.35, accent[2] * 0.35, accent[3] * 0.35, 235 * a },
        false, false, true)
    strokeRoundedRect(stubX, posY, STUB_WIDTH, totalHeight, CORNER_RADIUS, tocolor(accent[1], accent[2], accent[3], alpha), false, false, true)

    -- Perforationslinie zwischen Hauptteil und Stub
    local dashY = posY + 6
    while dashY < posY + totalHeight - 6 do
        dxDrawRectangle(stubX - 1, dashY, 2, PERFORATION_GAP * 0.55, tocolor(0, 0, 0, 90 * a))
        dashY = dashY + PERFORATION_GAP
    end

    -- Kleines Akzent-Symbol im Stub (rundes "Siegel"), zentriert
    local sealSize = math.min(STUB_WIDTH - 16, 26)
    local sealX = stubX + (STUB_WIDTH - sealSize) / 2
    local sealY = posY + totalHeight / 2 - sealSize / 2
    fillRoundedRect(sealX, sealY, sealSize, sealSize, sealSize / 2,
        { 255, 255, 255, 235 * a }, { 255, 255, 255, 200 * a }, false)
    dxDrawText("i", sealX, sealY - 1, sealX + sealSize, sealY + sealSize, tocolor(accent[1] * 0.6, accent[2] * 0.6, accent[3] * 0.6, alpha), 1, "default-bold", "center", "center")

    -- Text mit dezentem Schatten fuer bessere Lesbarkeit
    local shadow = tocolor(0, 0, 0, alpha)
    local white  = tocolor(255, 255, 255, alpha)

    dxDrawText(box.title, posX + 1, posY + 1, posX + bodyWidth + 1, posY + self.m_Height2 + 1, shadow, TITLE_SCALE, "default-bold", "center", "center")
    dxDrawText(box.title, posX, posY, posX + bodyWidth, posY + self.m_Height2, white, TITLE_SCALE, "default-bold", "center", "center")

    local bodyTop = posY + self.m_Height2
    local bodyBottom = bodyTop + bodyHeight
    dxDrawText(box.msg, posX + 1 + 8, bodyTop + 1, posX + bodyWidth + 1 - 8, bodyBottom + 1, shadow, BODY_SCALE, BODY_FONT, "center", "center", false, true)
    dxDrawText(box.msg, posX + 8, bodyTop, posX + bodyWidth - 8, bodyBottom, white, BODY_SCALE, BODY_FONT, "center", "center", false, true)
end

function Infobox:draw()
    -- Performance checks
    if #self.m_Boxs == 0 then
        self.m_IsDrawing = false
        removeEventHandler("onClientRender", root, self.m_fDraw)
    end


    -- Draw info boxes
    for idx, box in ipairs(self.m_Boxs) do
        -- Fade In
        if box.stage == 1 then
            -- Animation
            local alpha, posX, _ = interpolateBetween(box.alpha, box.posX, 0, self.m_Alpha, self.m_PosX, 0, self:getProgress(idx), "Linear")

            self:drawBoxBody(posX, box.posY, alpha, box)

            -- Next state?
            if getTickCount() >= box.endTime then
                -- Update position
                box.posX = self.m_PosX
                box.alpha = self.m_Alpha

                -- Update times
                box.startTime = getTickCount()
                box.endTime = box.startTime + box.holdTime

                -- Update stage
                box.stage = 2
            end
        end

        -- Idle
        if box.stage == 2 then
            self:drawBoxBody(box.posX, box.posY, box.alpha, box)

            -- Next level?
            if getTickCount() >= box.endTime then
                -- Update times
                box.startTime = getTickCount()
                box.endTime = box.startTime + 750

                -- Update stage
                box.stage = 3
            end
        end

        -- Fade Outline
        if box.stage == 3 then
             -- Animation
            local alpha, posY, _ = interpolateBetween(box.alpha, box.posY, 0, 0, -box.totalHeight - 5, 0, self:getProgress(idx), "Linear")

            self:drawBoxBody(box.posX, posY, alpha, box)

            if getTickCount() >= box.endTime then
                table.remove(self.m_Boxs, idx)
            end
        end
    end
end

addEvent("cdn:onClientReady", true)
addEventHandler("cdn:onClientReady", resourceRoot,
    function()
        g_InfoBox = Infobox.new()

        -- Vio FIX
        function infobox_start_func(...)
            g_InfoBox:create(...)
        end
    end
)
