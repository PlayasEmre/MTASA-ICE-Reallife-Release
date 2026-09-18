--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Geldautomaten - Hoehenausgleich                ||
--\\                                                  //

--[[
	Das neue Automatenmodell ( texturensystem/atm.dff, ersetzt Modell 2942 )
	sitzt anders im Ursprung als das Originalmodell. Dadurch schweben die
	Automaten oder stecken in der Wand.

	Die Automaten stehen in Map-Dateien - allein maps/else/cashpoints.map
	enthaelt 62 Stueck, dazu Bahnhof, Rathaus, Mafia, Triaden und Mechaniker.
	Ueber siebzig Eintraege von Hand zu aendern waere muehsam und schwer
	rueckgaengig zu machen, deshalb der Ausgleich hier an einer Stelle.

	Negativ = tiefer, positiv = hoeher. Ein Neustart der Ressource setzt die
	Objekte aus der Map neu, der Versatz wirkt also immer vom Original aus -
	er summiert sich nicht auf.
]]
local ATM_MODELL  = 2942
local ATM_VERSATZ = -0.5

addEventHandler ( "onResourceStart", resourceRoot, function ()
	-- Kurz warten: Objekte aus den Map-Dateien sind zwar in der Regel schon
	-- da, aber nicht jede Karte wird gleich frueh geladen.
	setTimer ( function ()
		if ATM_VERSATZ == 0 then
			return
		end

		local anzahl = 0

		for _, obj in ipairs ( getElementsByType ( "object" ) ) do
			if getElementModel ( obj ) == ATM_MODELL then
				local x, y, z = getElementPosition ( obj )
				setElementPosition ( obj, x, y, z + ATM_VERSATZ )
				anzahl = anzahl + 1
			end
		end

		outputDebugString ( "[Geldautomaten] "..anzahl.." Objekte um "..ATM_VERSATZ.." verschoben." )
	end, 2000, 1 )
end )

--[[
	Frueher wurden hier drei Automaten selbst gesetzt. Sie stehen inzwischen
	in den Map-Dateien, der Block ist deshalb stillgelegt.

function bankautomaten_creation ()
	SFBanhofGeldautomat = createObject ( 2942, -1980.5427246094, 145.16845703125, 27.32200050354, 0, 0, 270 )
	SFSpawnGeldautomat = createObject ( 2942, -2765.4018554688, 372.29138183594, 5.9826860427856, 0, 0, 90 )
	SFRathausGeldautomat = createObject ( 2942, -2456.9841308594, 783.24542236328, 34.81477355957, 0, 0, 270 )
end
addEventHandler ("onResourceStart", getResourceRootElement(getThisResource()), bankautomaten_creation )
]]
