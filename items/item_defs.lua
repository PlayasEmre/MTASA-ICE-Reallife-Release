--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Zentrale Item-Registry: ersetzt die alten Tabellen validItems/itemTexts/
-- itemNames/itemImage/itemCommand/itemType. Ein Eintrag = ein Item.
-- valueKind "count"    -> Menge wird aus elementDataKey gelesen und angezeigt
-- valueKind "presence" -> Item ist vorhanden/nicht vorhanden, keine Mengenanzeige
-- requires             -> optionaler zweiter elementDataKey, der > 0 sein muss,
--                         damit das Item ueberhaupt angezeigt wird

-- category dient nur der Gruppierung im GUI (Ueberschriften), hat keinen
-- Einfluss auf Datenhaltung/Kompatibilitaet mit den restlichen Systemen.
itemDefs = {
	["Zeitung"] = {
		displayName = "Zeitung", elementDataKey = "newspaper", valueKind = "presence",
		icon = "liberty_tree.bmp", command = "readnewspaper", category = "Sonstiges",
		description = "Eine neue Ausgabe\ndes \"Liberty Tree\"-\nThe Truth is, was\ndu draus machst!",
	},
	["Kanister"] = {
		displayName = "Benzinkannister", elementDataKey = "benzinkannister", valueKind = "count",
		icon = "benzin.bmp", command = "fill", throwType = "fuel", category = "Verbrauchsgueter",
		description = "Ein Kanister erlaubt\nes dir, mit /fill ein beliebi-\nges Fahrzeug mit 15 \nLitern Benzin zu fuellen.",
	},
	["Drogen"] = {
		displayName = "Drogen", elementDataKey = "drugs", valueKind = "count", suffix = " g",
		icon = "drugs.bmp", command = "usedrugs", throwType = "drugs", category = "Verbrauchsgueter",
		description = "Drogen regenieren einen\nTeil deiner Gesundheit,\njedoch nicht ohne Neben-\neffekte. Ausserdem ist\nder Besitz von Drogen\nstrafbar! Befehle:\n/usedrugs, /selldrugs",
	},
	["Materialien"] = {
		displayName = "Materialien", elementDataKey = "mats", valueKind = "count",
		icon = "mats.bmp", command = "mats", throwType = "mats", category = "Verbrauchsgueter",
		description = "Materialien bilden den\nGrundstoff fuer Waffen,\nsie sind - ebenso wie\nDrogen - illegal.\n\nBefehl: /sellgun",
	},
	["Wuerfel"] = {
		displayName = "Wuerfel", elementDataKey = "dice", valueKind = "presence",
		icon = "dice.bmp", command = "dice", throwType = "dice", category = "Sonstiges",
		description = "Mit einem Wuerfel kannst\neine beliebige Zahl\nzwischen 1 und 6\nerzeugen.\n\nBefehl:\n/dice",
	},
	["Zigaretten"] = {
		displayName = "Zigaretten", elementDataKey = "zigaretten", valueKind = "count",
		icon = "cigaretts.bmp", command = "smoke", throwType = "zigaretten", category = "Verbrauchsgueter",
		description = "\nZigaretten kannst du mit\n/smoke rauchen.",
	},
	["Hanfsamen"] = {
		displayName = "Hanfsamen", elementDataKey = "flowerseeds", valueKind = "count",
		icon = "drugs.bmp", command = "grow", throwType = "flowerseeds", category = "Verbrauchsgueter",
		description = "Drogen zum selber\nanbauen fuer den\nHobbygaertner, je nach\nWachstumszeit mehr\nErtrag!\nBefehle: /grow weed",
	},
	["Notebook"] = {
		displayName = "Notebook", elementDataKey = "fruitNotebook", valueKind = "count",
		icon = "fruit.bmp", command = "internet", category = "Ausruestung",
		description = "Ein brandneues Notebook\nder Firma \"Fruit\"- mit\nW-Lan und Internet-\nzugang!",
	},
	["Chips"] = {
		displayName = "Chips", elementDataKey = "casinoChips", valueKind = "count",
		icon = "chip.png", command = "chips", category = "Wertsachen",
		description = "Chips aus einem\nder Casinos.\nJe einen Dollar wert.",
	},
	["Hufeisen"] = {
		displayName = "Hufeisen", elementDataKey = "totalHorseShoes", valueKind = "count",
		icon = "horseshoe.png", category = "Wertsachen",
		description = "Hufeisen sind in ganz\nLas Venturas versteckt.\nFinde alle 25 fuer eine\nspezielle Belohnung...",
	},
	["Geschenk"] = {
		displayName = "Geschenk", elementDataKey = "presents", valueKind = "count",
		icon = "present.bmp", command = "presents", category = "Wertsachen",
		description = "Dieses Paeckchen enthaelt\netwas zufaelliges -\nvon Geld bis zu\nAutos ist alles\ndabei!",
	},
	["Gluecksrad-Ticket"] = {
		displayName = "Gluecksrad-Ticket", elementDataKey = "gluecksradTickets", valueKind = "count",
		icon = "ticket.png", command = "gluecksradticket", category = "Wertsachen",
		description = "Ein Ticket fuer eine\nDrehung am Gluecksrad.\nStell dich ans Rad und\nbenutze es von hier aus.",
	},
	["Fernglas"] = {
		displayName = "Fernglas", elementDataKey = "fglass", valueKind = "presence",
		icon = "binoculars.png", command = "fglass", category = "Ausruestung",
		description = "/fglass zur schnelleren\nBenutzung.",
	},
	["Kuerbis"] = {
		displayName = "Kuerbis", elementDataKey = "kuerbisse", valueKind = "count",
		icon = "easteregg.bmp", command = "halloween", category = "Wertsachen",
		description = "Kann mit /halloween\nzum Einloesen fuer\nBoni verwendet werden.",
	},
	["Medikits"] = {
		displayName = "Medikits", elementDataKey = "medikits", valueKind = "count",
		icon = "aid.bmp", category = "Ausruestung",
		description = "Kann von einem Sanitaeter\nverwendet werden, um dich\nzu heilen.",
	},
	["Repairkits"] = {
		displayName = "Repairkits", elementDataKey = "repairkits", valueKind = "count",
		icon = "special_ammo.bmp", category = "Ausruestung",
		description = "Kann von einem Mechaniker\nverwendet werden, um dein\nFahrzeug zu reparieren.",
	},
	["Angel"] = {
		displayName = "Angel", elementDataKey = "fishingPole", valueKind = "presence",
		icon = "fishing/pole.png", category = "Angelausruestung",
		description = "Mit einer Angel kannst\ndu Fische oder anderes\naus dem Meer fangen.\nJe nach Skill hast\ndu unterschiedliche\nChancen.\nAlternativ: /fish",
	},
	["Haken"] = {
		displayName = "Haken", elementDataKey = "fishingHooks", valueKind = "count", requires = "fishingPole",
		icon = "fishing/hook.png", category = "Angelausruestung",
		description = "Zum Angeln brauchst\ndu Haken.",
	},
	["Koeder"] = {
		displayName = "Koeder", elementDataKey = "fishingWorms", valueKind = "count", requires = "fishingPole",
		icon = "fishing/worm.png", category = "Angelausruestung",
		description = "Ohne Koeder kannst\ndu keine Fische\nfangen.",
	},
}

-- Feste Reihenfolge der Kategorien im GUI. Kategorien ohne aktuell
-- vorhandene Items werden beim Aufbau einfach uebersprungen.
categoryOrder = {
	"Verbrauchsgueter", "Ausruestung", "Wertsachen", "Angelausruestung", "Auszeichnungen", "Sonstiges",
}

categoryLabels = {
	["Verbrauchsgueter"] = "Verbrauchsgüter",
	["Ausruestung"] = "Ausrüstung",
	["Wertsachen"] = "Wertsachen",
	["Angelausruestung"] = "Angel-Ausrüstung",
	["Auszeichnungen"] = "Auszeichnungen",
	["Sonstiges"] = "Sonstiges",
}

itemDefsOrder = {
	"Zeitung", "Kanister", "Drogen", "Materialien", "Wuerfel", "Zigaretten", "Hanfsamen",
	"Notebook", "Chips", "Hufeisen", "Geschenk", "Gluecksrad-Ticket", "Fernglas", "Kuerbis", "Medikits", "Repairkits",
	"Angel", "Haken", "Koeder",
}

-- Platzierbare Objekte (eigener Sonderfall, unabhaengig von itemDefs) --
placeAbleObjects = {
	["Objekt"] = true, ["Fackel"] = true, ["Basketball"] = true, ["Strandball"] = true,
	["Lagerfeuer"] = true, ["Grill"] = true, ["Liege"] = true, ["Handtuch"] = true,
	["Rampe"] = true, ["Tigerfell"] = true, ["Dixiklo"] = true, ["Stereoanlage"] = true,
}

placeAbleObjectIMGs = {
	["Fackel"] = "placeable/torch.png",
	["Basketball"] = "placeable/ball_a.png",
	["Strandball"] = "placeable/ball_b.png",
	["Lagerfeuer"] = "placeable/campfire.png",
	["Grill"] = "placeable/grill.png",
	["Liege"] = "placeable/liege.png",
	["Handtuch"] = "placeable/towel.png",
	["Stereoanlage"] = "placeable/hi_fi.png",
}

placeAbleObjectNames = {
	[3461] = "Fackel", [1946] = "Basketball", [1598] = "Strandball",
	[841] = "Lagerfeuer", [842] = "Lagerfeuer", [1481] = "Grill", [1255] = "Liege",
	[1640] = "Handtuch", [1641] = "Handtuch", [1642] = "Handtuch", [1643] = "Handtuch",
	[13593] = "Rampe", [1828] = "Tigerfell", [2984] = "Dixiklo", [2103] = "Stereoanlage",
}

placeAbleObjectDesc = {
	[1640] = "Farbe: Gruen\n\n", [1641] = "Farbe: Lila\n\n",
	[1642] = "Farbe: Rot\n\n", [1643] = "Farbe: Gelb\n\n",
}

-- Fisch-Faenge werden dynamisch aus fishNames (hobby/fishing/fishing_client.lua) erzeugt.
fishItemDefs = {}
for key, index in pairs(fishNames or {}) do
	fishItemDefs[index] = {
		displayName = index, icon = "fishing/cought.png",
		description = "Das hast du beim\nAngeln gefangen!\nVerkaufe es mit\n/sellfish",
	}
end

-- Dynamische Kategorien, die nicht in das 1-Item-pro-elementDataKey-Schema passen:
-- Essensslots (1-3), Orden, gefangene Fische. Liefert eine Liste von
-- Pseudo-Item-Zeilen { key, displayName, icon, description, count(optional), path(optional) }.
function getDynamicInventoryRows()

	local rows = {}

	-- Essensslots --
	for i = 1, 3 do
		local food = tonumber(vioClientGetElementData("food" .. i))
		if food and food >= 1 then
			rows[#rows + 1] = {
				key = "food" .. i,
				displayName = foodName[food],
				icon = (foodImages[food] or "present") .. ".bmp",
				description = "Heilt "..(foodHeal[food] or 0).."% Gesundheit.\nStillt "..(foodHunger[food] or 0).."% Hunger.\nBefehl: /eat "..i,
				command = "eat", commandArg = i,
				throwType = "food", throwArg = i,
				category = "Verbrauchsgueter",
			}
		end
	end

	-- Orden --
	local orden = {
		{ key = "armyperm7", displayName = "Ehre", icon = "orden_1.bmp", description = "Verliehen als\nZeichen besonderer\nEhre." },
		{ key = "armyperm8", displayName = "Luftwaffe", icon = "orden_2.bmp", description = "Verliehen fuer\nbesondere Verdienste\nim Bereich\nLuftwaffe." },
		{ key = "armyperm9", displayName = "Verdienst", icon = "orden_3.bmp", description = "Verliehen fuer\nbesondere Verdienste." },
	}
	for _, entry in ipairs(orden) do
		if tonumber(vioClientGetElementData(entry.key) or 0) >= 1 then
			rows[#rows + 1] = { key = entry.key, displayName = entry.displayName, icon = entry.icon,
				description = entry.description, category = "Auszeichnungen" }
		end
	end

	-- Gefangene Fische --
	if vioClientGetElementData("fishingPole") then
		for _, typ in ipairs({ "A", "B", "C" }) do
			local name = tonumber(vioClientGetElementData("fishingFish" .. typ .. "Typ"))
			if name and name >= 1 and fishNames[name] then
				local weight = vioClientGetElementData("fishingFish" .. typ .. "Weight")
				local def = fishItemDefs[fishNames[name]]
				rows[#rows + 1] = {
					key = "fishingFish" .. typ,
					displayName = fishNames[name],
					icon = def and def.icon or "fishing/cought.png",
					description = def and def.description or "Das hast du beim\nAngeln gefangen!",
					count = tostring(math.floor(weight / 10) / 100) .. " kg",
					category = "Angelausruestung",
				}
			end
		end
	end

	return rows
end

-- Aktuell platziertes/mitgefuehrtes Objekt als Pseudo-Item-Zeile, falls vorhanden.
function getPlaceableInventoryRow()

	local model = tonumber(vioClientGetElementData("object")) or 0
	if model <= 0 then return nil end

	local objectName = placeAbleObjectNames[model] or "Objekt"
	local addtext = placeAbleObjectDesc[model] or ""
	local img = placeAbleObjectIMGs[objectName] or "present.bmp"
	local description
	if objectName == "Stereoanlage" then
		description = addtext .. "Dieses Objekt kannst\ndu benutzen, um es\nzu platzieren."
	else
		description = addtext .. "Dieses Objekt kannst\ndu benutzen, um es\nzu platzieren und\nMusik spielen zu\nlassen."
	end

	return {
		key = "object", displayName = objectName, icon = img, description = description,
		isPlaceable = true, category = "Sonstiges",
	}
end

-- Fuellt die DGS-GridList des "Item geben"-Fensters (items/items_geben_click.lua)
-- anhand derselben Datenquelle wie das neue DGS-Inventar. Ersetzt die alte,
-- hart codierte fillWithItems-Funktion.
function fillWithItems(grid, columnName, columnCount)

	dgsGridListClear(grid)

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
				local row = dgsGridListAddRow(grid)
				dgsGridListSetItemText(grid, row, columnName, id, false, false)
				dgsGridListSetItemText(grid, row, columnCount, countText, false, false)
			end
		end
	end

	for _, drow in ipairs(getDynamicInventoryRows()) do
		local row = dgsGridListAddRow(grid)
		dgsGridListSetItemText(grid, row, columnName, drow.displayName, false, false)
		dgsGridListSetItemText(grid, row, columnCount, drow.count or "", false, false)
	end

	local placeable = getPlaceableInventoryRow()
	if placeable then
		local row = dgsGridListAddRow(grid)
		dgsGridListSetItemText(grid, row, columnName, placeable.displayName, false, false)
		dgsGridListSetItemText(grid, row, columnCount, "", false, false)
	end
end
