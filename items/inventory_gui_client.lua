--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Neues DGS-basiertes Inventarfenster. Liest die Item-Mengen weiterhin ueber
-- die bestehenden elementData-Schluessel (via itemDefs / getDynamicInventoryRows /
-- getPlaceableInventoryRow aus items/item_defs.lua), damit alle Systeme, die
-- Items vergeben, unveraendert weiterlaufen. Aktionen laufen ueber die
-- bestehenden Server-Events "executeCommand" / "throw" (items/items_server.lua).

local IGUI = { Window = {}, Button = {}, Label = {}, Image = {}, ScrollPane = {}, Slot = {}, SlotBg = {}, SlotName = {}, SlotCount = {}, Header = {} }
local ICON_PATH = "images/inventory/"

local WIN_W, WIN_H = 620, 460
local PANE_X, PANE_Y, PANE_W, PANE_H = 15, 45, 300, 350
local SLOT_SIZE, CELL_W, CELL_H, GRID_GAP, PER_ROW = 56, 70, 78, 8, 3
local DETAIL_X = PANE_X + PANE_W + 20

local slotBounds = {}
local currentRows = {}
local selectedIndex = nil

local function iconPath(icon)
	return ":" .. getResourceName(getThisResource()) .. "/" .. ICON_PATH .. icon
end

local function buildRowList()

	local rows = {}

	for _, id in ipairs(itemDefsOrder) do
		local def = itemDefs[id]
		if not def.requires or vioClientGetElementData(def.requires) then
			local raw = vioClientGetElementData(def.elementDataKey)
			local present, countText
			if def.valueKind == "count" then
				local value = tonumber(raw) or 0
				present = value >= 1
				countText = present and (tostring(value) .. (def.suffix or "")) or ""
			else
				present = raw and raw ~= 0 and raw ~= "" or false
				countText = ""
			end
			if present then
				rows[#rows + 1] = {
					key = id, displayName = def.displayName, icon = def.icon,
					description = def.description, count = countText,
					command = def.command, throwType = def.throwType,
					category = def.category or "Sonstiges",
				}
			end
		end
	end

	for _, row in ipairs(getDynamicInventoryRows()) do
		rows[#rows + 1] = row
	end

	local placeable = getPlaceableInventoryRow()
	if placeable then
		rows[#rows + 1] = placeable
	end

	return rows
end

-- Gruppiert eine flache Zeilen-Liste nach Kategorie, in fester Reihenfolge
-- (categoryOrder aus item_defs.lua). Leere Kategorien werden ausgelassen.
local function groupByCategory(rows)

	local buckets = {}
	for _, row in ipairs(rows) do
		local cat = row.category or "Sonstiges"
		buckets[cat] = buckets[cat] or {}
		buckets[cat][#buckets[cat] + 1] = row
	end

	local groups = {}
	for _, cat in ipairs(categoryOrder) do
		if buckets[cat] and #buckets[cat] > 0 then
			groups[#groups + 1] = { name = cat, label = categoryLabels[cat] or cat, rows = buckets[cat] }
		end
	end
	return groups
end

local function clearGrid()
	for _, el in ipairs(IGUI.Slot) do if isElement(el) then destroyElement(el) end end
	for _, el in ipairs(IGUI.SlotBg) do if isElement(el) then destroyElement(el) end end
	for _, el in ipairs(IGUI.SlotName) do if isElement(el) then destroyElement(el) end end
	for _, el in ipairs(IGUI.SlotCount) do if isElement(el) then destroyElement(el) end end
	for _, el in ipairs(IGUI.Header) do if isElement(el) then destroyElement(el) end end
	IGUI.Slot, IGUI.SlotBg, IGUI.SlotName, IGUI.SlotCount, IGUI.Header = {}, {}, {}, {}, {}
	slotBounds = {}
end

local function showDetail(row)

	if row then
		if IGUI.Image["item"] then destroyElement(IGUI.Image["item"]) end
		IGUI.Image["item"] = dgsCreateImage(DETAIL_X + 8, 50, 72, 72, iconPath(row.icon), false, IGUI.Window[1])
		dgsSetText(IGUI.Label["name"], row.displayName)
		dgsSetText(IGUI.Label["count"], row.count and row.count ~= "" and ("Anzahl: " .. row.count) or "")
		dgsSetText(IGUI.Label["desc"], row.description or "")

		local canUse = (row.command ~= nil) or row.isPlaceable
		local canThrow = row.throwType ~= nil or row.isPlaceable
		dgsSetVisible(IGUI.Button["use"], canUse)
		dgsSetVisible(IGUI.Button["throw"], canThrow)

		local bounds = selectedIndex and slotBounds[selectedIndex]
		if bounds then
			dgsSetPosition(IGUI.Image["highlight"], bounds.x - 4, bounds.y - 4, false)
			dgsSetSize(IGUI.Image["highlight"], bounds.w + 8, bounds.h + 8, false)
			dgsSetVisible(IGUI.Image["highlight"], true)
		end
	else
		if IGUI.Image["item"] then
			destroyElement(IGUI.Image["item"])
			IGUI.Image["item"] = nil
		end
		dgsSetText(IGUI.Label["name"], "")
		dgsSetText(IGUI.Label["count"], "")
		dgsSetText(IGUI.Label["desc"], "\n\nBitte waehle ein Item\naus dem Inventar aus!")
		dgsSetVisible(IGUI.Button["use"], false)
		dgsSetVisible(IGUI.Button["throw"], false)
		if IGUI.Image["highlight"] then
			dgsSetVisible(IGUI.Image["highlight"], false)
		end
	end
end

local function selectSlot(index)
	selectedIndex = index
	showDetail(currentRows[index])
end

local function fillInventoryGrid()

	clearGrid()
	currentRows = buildRowList()
	selectedIndex = nil
	showDetail(nil)

	local groups = groupByCategory(currentRows)
	local flatIndex = 0
	local y = GRID_GAP

	for _, group in ipairs(groups) do

		local header = dgsCreateLabel(GRID_GAP, y, PANE_W - 2 * GRID_GAP, 16, group.label, false,
			IGUI.ScrollPane[1], tocolor(63, 160, 224, 255))
		dgsSetFont(header, "default-bold")
		IGUI.Header[#IGUI.Header + 1] = header
		y = y + 20

		for i, row in ipairs(group.rows) do
			flatIndex = flatIndex + 1
			currentRows[flatIndex] = row

			local col = (i - 1) % PER_ROW
			local line = math.floor((i - 1) / PER_ROW)
			local x = GRID_GAP + col * (CELL_W + GRID_GAP)
			local sy = y + line * (CELL_H + GRID_GAP)

			local bg = dgsCreateImage(x, sy, SLOT_SIZE, SLOT_SIZE, "images/black.bmp", false,
				IGUI.ScrollPane[1], tocolor(0, 0, 0, 130))
			IGUI.SlotBg[#IGUI.SlotBg + 1] = bg

			-- normalColor/hoveringColor/clickedColor MUESSEN explizit weiss
			-- gesetzt werden: ohne das faerbt DGS jedes Icon mit der dunklen
			-- Theme-Standardfarbe des Buttons ein (macht sie schwarz/grau).
			local btn = dgsCreateButton(x, sy, SLOT_SIZE, SLOT_SIZE, "", false, IGUI.ScrollPane[1],
				nil, nil, nil, iconPath(row.icon), iconPath(row.icon), iconPath(row.icon),
				tocolor(255, 255, 255, 255), tocolor(230, 240, 250, 255), tocolor(200, 220, 240, 255))
			IGUI.Slot[#IGUI.Slot + 1] = btn
			slotBounds[flatIndex] = { x = x, y = sy, w = SLOT_SIZE, h = SLOT_SIZE }

			if row.count and row.count ~= "" then
				local badge = dgsCreateLabel(x, sy - 2, SLOT_SIZE - 2, 12, row.count, false,
					IGUI.ScrollPane[1], tocolor(255, 230, 130, 255))
				dgsSetFont(badge, "default-bold")
				dgsLabelSetHorizontalAlign(badge, "right")
				IGUI.SlotCount[#IGUI.SlotCount + 1] = badge
			end

			local nameLbl = dgsCreateLabel(x - 3, sy + SLOT_SIZE + 2, CELL_W, 16, row.displayName, false,
				IGUI.ScrollPane[1], tocolor(220, 220, 220, 255))
			dgsSetFont(nameLbl, "default")
			dgsLabelSetHorizontalAlign(nameLbl, "center")
			IGUI.SlotName[#IGUI.SlotName + 1] = nameLbl

			local capturedIndex = flatIndex
			addEventHandler("onDgsMouseClickUp", btn, function(btnName)
				if btnName == "left" then
					selectSlot(capturedIndex)
				end
			end, false)
		end

		local rowsUsed = math.ceil(#group.rows / PER_ROW)
		y = y + rowsUsed * (CELL_H + GRID_GAP) + 10
	end

	if #currentRows == 0 then
		local empty = dgsCreateLabel(GRID_GAP, y, PANE_W - 2 * GRID_GAP, 20, "Dein Inventar ist leer.", false,
			IGUI.ScrollPane[1], tocolor(180, 180, 180, 255))
		IGUI.Header[#IGUI.Header + 1] = empty
	end
end
addEvent("refreshItems", true)
addEventHandler("refreshItems", getRootElement(), function()
	if IGUI.Window[1] and isElement(IGUI.Window[1]) and dgsGetVisible(IGUI.Window[1]) then
		fillInventoryGrid()
	end
end)

local function useSelectedItem()

	local row = currentRows[selectedIndex]
	if not row then return end

	if row.isPlaceable then
		hideInventory()
		if row.displayName == "Stereoanlage" then
			setTimer(placeRadio, 500, 1)
		else
			setTimer(startObjectDrop, 500, 1)
		end
	elseif row.command == "eat" then
		triggerServerEvent("executeCommand", getRootElement(), lp, "eat", row.commandArg)
	elseif row.command == "fish" or row.command == "fglass" or row.command == "halloween" or row.command == "gluecksradticket" then
		hideInventory()
		setTimer(executeCommandHandler, 200, 1, row.command)
	elseif row.command then
		triggerServerEvent("executeCommand", getRootElement(), lp, row.command)
	end
end

local function throwSelectedItem()

	local row = currentRows[selectedIndex]
	if not row then return end

	if row.isPlaceable then
		triggerServerEvent("throw", getRootElement(), lp, "", "object")
	elseif row.throwType == "food" then
		triggerServerEvent("throw", getRootElement(), lp, "", "food", row.throwArg)
	elseif row.throwType then
		triggerServerEvent("throw", getRootElement(), lp, "", row.throwType)
	end
end

function hideInventory()
	setElementClicked(false)
	if IGUI.Window[1] and isElement(IGUI.Window[1]) then
		dgsSetVisible(IGUI.Window[1], false)
	end
	showCursor(false)
end

local function isInventoryOpen()
	return IGUI.Window[1] and isElement(IGUI.Window[1]) and dgsGetVisible(IGUI.Window[1])
end

function showInventory_func()

	if isPedDead(lp) then
		return
	end

	if introCutsceneAktiv or tutorial then
		return
	end

	if isInventoryOpen() then
		hideInventory()
		return
	end

	if getElementClicked() and not isCursorShowing() then
		setElementClicked(false)
	end

	if isCursorShowing() or getElementClicked() then
		outputChatBox("Schliesse zuerst das offene Fenster, bevor du das Inventar oeffnest.", 200, 200, 0)
		return
	end

	setElementClicked(true)
	showCursor(true)

	if IGUI.Window[1] and isElement(IGUI.Window[1]) then
		dgsSetVisible(IGUI.Window[1], true)
		fillInventoryGrid()
		return
	end

	IGUI.Window[1] = dgsCreateWindow(screenwidth / 2 - WIN_W / 2, screenheight / 2 - WIN_H / 2, WIN_W, WIN_H,
		"Inventar", false)
	dgsWindowSetCloseButtonEnabled(IGUI.Window[1], false)
	dgsWindowSetSizable(IGUI.Window[1], false)
	dgsWindowSetMovable(IGUI.Window[1], false)

	IGUI.ScrollPane[1] = dgsCreateScrollPane(PANE_X, PANE_Y, PANE_W, PANE_H, false, IGUI.Window[1])

	-- dezenter Auswahlrahmen um den aktuell gewaehlten Slot (anfangs versteckt)
	IGUI.Image["highlight"] = dgsCreateImage(0, 0, SLOT_SIZE + 8, SLOT_SIZE + 8, "images/white.bmp", false,
		IGUI.ScrollPane[1], tocolor(255, 200, 60, 160))
	dgsSetVisible(IGUI.Image["highlight"], false)

	-- Trennlinie zwischen Item-Liste und Detail-Panel
	IGUI.Image["divider"] = dgsCreateImage(PANE_X + PANE_W + 8, PANE_Y, 2, PANE_H, "images/white.bmp", false,
		IGUI.Window[1], tocolor(255, 255, 255, 60))

	IGUI.Image["item"] = nil

	IGUI.Label["name"] = dgsCreateLabel(DETAIL_X + 90, 58, WIN_W - DETAIL_X - 100, 22, "", false,
		IGUI.Window[1], tocolor(255, 255, 255, 255))
	dgsSetFont(IGUI.Label["name"], "default-bold")

	IGUI.Label["count"] = dgsCreateLabel(DETAIL_X + 90, 82, WIN_W - DETAIL_X - 100, 18, "", false,
		IGUI.Window[1], tocolor(255, 205, 100, 255))

	IGUI.Image["descBg"] = dgsCreateImage(DETAIL_X, 135, WIN_W - DETAIL_X - 20, 175, "images/black.bmp", false,
		IGUI.Window[1], tocolor(0, 0, 0, 90))
	IGUI.Label["desc"] = dgsCreateMemo(DETAIL_X + 8, 143, WIN_W - DETAIL_X - 36, 160,
		"\n\nBitte waehle ein Item\naus dem Inventar aus!", false, IGUI.Window[1], tocolor(210, 210, 210, 255))
	dgsMemoSetReadOnly(IGUI.Label["desc"], true)

	local btnW, btnH, btnGap = (WIN_W - DETAIL_X - 20 - 10) / 2, 34, 10
	local btnRow1Y, btnRow2Y = 325, 368

	IGUI.Button["use"] = dgsCreateButton(DETAIL_X, btnRow1Y, btnW, btnH, "Benutzen", false, IGUI.Window[1],
		nil, nil, nil, nil, nil, nil, tocolor(63, 160, 224, 255), tocolor(100, 190, 240, 255), tocolor(44, 120, 170, 255))
	IGUI.Button["throw"] = dgsCreateButton(DETAIL_X + btnW + btnGap, btnRow1Y, btnW, btnH, "Wegwerfen", false, IGUI.Window[1],
		nil, nil, nil, nil, nil, nil, nil, nil, nil)
	IGUI.Button["give"] = dgsCreateButton(DETAIL_X, btnRow2Y, btnW, btnH, "Geben", false, IGUI.Window[1],
		nil, nil, nil, nil, nil, nil, nil, nil, nil)
	IGUI.Button["close"] = dgsCreateButton(DETAIL_X + btnW + btnGap, btnRow2Y, btnW, btnH, "Schliessen", false, IGUI.Window[1],
		nil, nil, nil, nil, nil, nil, nil, nil, nil)

	addEventHandler("onDgsMouseClickUp", IGUI.Button["use"], function(btn)
		if btn == "left" then useSelectedItem() end
	end, false)
	addEventHandler("onDgsMouseClickUp", IGUI.Button["throw"], function(btn)
		if btn == "left" then throwSelectedItem() end
	end, false)
	addEventHandler("onDgsMouseClickUp", IGUI.Button["give"], function(btn)
		if btn == "left" then
			local target = vioClientGetElementData("curclicked")
			if type(target) == "string" and isElement(getPlayerFromName(target)) then
				showItemGiveList()
			else
				outputChatBox("Rechtsklicke zuerst einen Spieler an, um ihm etwas zu geben!", 125, 0, 0)
			end
		end
	end, false)
	addEventHandler("onDgsMouseClickUp", IGUI.Button["close"], function(btn)
		if btn == "left" then hideInventory() end
	end, false)

	fillInventoryGrid()
end
bindKey("i", "down", showInventory_func)
