--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

--[[
	Geldautomat: Modell 2942.

	Die Automaten stehen nicht auf der Originalkarte, sondern werden vom
	Skript gesetzt - places/outdoor/bankautomaten.lua legt sie mit
	createObject(2942,...) an. clicksys/clicksys_server.lua Z. 114 oeffnet
	bei genau diesem Modell das Geldautomaten-Fenster.

	Deshalb schlug 19324 fehl: Das ist ein Objekt der Originalkarte, das MTA
	nicht ersetzen laesst - und ein Automat, den euer Skript gar nicht nutzt.

	Nicht 1907 nehmen: das ist in casino/chips_client.lua Z. 29 der
	Casino-Chip. engineReplaceModel wirkt auf ALLE Objekte einer ID.

	Hinweis: casino/roulett/roulett_server.lua setzt ebenfalls zwei Objekte
	mit 2942 - die bekommen das neue Modell also auch.
]]
local ATM_MODELL = 2942

local modsTable={
{txdpfad="texturensystem/BLITZER.txd",dffpfad="texturensystem/BLITZER.dff",colpfad="texturensystem/BLITZER.col",modelid=3890},
{txdpfad="texturensystem/sfsroads.txd",modelid=10983},
{txdpfad="texturensystem/silenced.txd",dffpfad="texturensystem/silenced.dff",modelid=347},
{txdpfad="texturensystem/atm.txd",dffpfad="texturensystem/atm.dff",colpfad="texturensystem/atm.col",modelid=ATM_MODELL},
};

addEventHandler("onClientResourceStart",resourceRoot,function()
	for i=1,#modsTable do
		local eintrag = modsTable[i]
		local modelid = eintrag.modelid

		--[[
			Zuerst pruefen, ob MTA die Modell-ID ueberhaupt kennt.

			engineGetModelNameFromID liefert den internen Namen ( z.B.
			"kmb_atm1_2" ) - oder nichts, wenn die ID kein ersetzbares Modell
			ist. Ohne diese Pruefung melden engineImportTXD, engineReplaceModel
			und engineReplaceCOL nacheinander drei kryptische Fehler, die alle
			dieselbe Ursache haben.
		]]
		local modellname = engineGetModelNameFromID and engineGetModelNameFromID(modelid)
		if not modellname then
			outputDebugString("[Texturensystem] Modell-ID "..tostring(modelid)..
							  " ist kein ersetzbares Modell - Eintrag wird uebersprungen.",2)
		else

		--[[
			Vor dem Laden pruefen, ob die Datei ueberhaupt da ist.

			Ohne diese Pruefung meldet MTA fuer jede fehlende Datei einen
			Fehler im Debugscript - und wer eine Modelldatei noch nicht
			hinterlegt hat, sucht den Grund dann an der falschen Stelle.
			Vorhandene Modelle laden dadurch unbeeindruckt weiter.
		]]
		if eintrag.txdpfad and fileExists(eintrag.txdpfad) then
			local txd = engineLoadTXD(eintrag.txdpfad)
			if txd then engineImportTXD(txd,modelid) end
		end

		if eintrag.dffpfad and fileExists(eintrag.dffpfad) then
			local dff = engineLoadDFF(eintrag.dffpfad)
			if dff then engineReplaceModel(dff,modelid) end
		end

		if eintrag.colpfad and fileExists(eintrag.colpfad) then
			local col = engineLoadCOL(eintrag.colpfad)
			if col then engineReplaceCOL(col,modelid) end
		end
		end
	end
end)



--//Renderdistance\\--
local loadDistanceTable={
{3890,450},          -- Blitzer
{ATM_MODELL,300}     -- Geldautomat ( steht an Waenden, 300 reicht )
}

addEventHandler("onClientResourceStart",resourceRoot,function()
	for _,v in pairs(loadDistanceTable)do
		engineSetModelLODDistance(v[1],v[2])
	end
end)



--[[
	Hilfsbefehl zum Einmessen: /modellid

	Schau ein Objekt der Originalkarte an und tippe /modellid - der Befehl
	schiesst einen Strahl aus der Kamera und meldet die Modell-ID dessen, was
	er trifft.

	Damit findest du die ID des Original-Geldautomaten, ohne raten zu muessen.
	Raten ist hier gefaehrlich: engineReplaceModel wirkt auf ALLE Objekte
	dieser ID im ganzen Spiel.

	Der Block ist reines Werkzeug und kann geloescht werden, sobald die
	Modelle feststehen.
]]
addCommandHandler("modellid",function()
	local kx,ky,kz,zx,zy,zz = getCameraMatrix()
	if not kx then return end

	-- Blickrichtung verlaengern, damit auch entferntere Objekte getroffen werden.
	local rx = kx + (zx-kx)*80
	local ry = ky + (zy-ky)*80
	local rz = kz + (zz-kz)*80

	-- Der letzte Parameter schaltet die Angaben zu Kartenobjekten ein,
	-- sonst bekommt man nur Elemente aus dem Skript.
	local treffer,tx,ty,tz,element,_,_,_,_,_,_,weltmodell,wx,wy,wz =
		processLineOfSight(kx,ky,kz,rx,ry,rz,true,true,true,true,true,false,false,false,localPlayer,true)

	if not treffer then
		outputChatBox("Modell-ID: nichts getroffen - naeher herangehen und genau hinschauen.",200,200,0)
		return
	end

	if isElement(element) then
		outputChatBox("Getroffen: Skript-Element ("..getElementType(element)..
					  "), Modell "..tostring(getElementModel(element)),0,200,0)
		return
	end

	if weltmodell then
		local name = engineGetModelNameFromID and engineGetModelNameFromID(weltmodell)

		outputChatBox("Kartenobjekt - Modell-ID: "..tostring(weltmodell)..
					  ( name and ( "  ( "..name.." )" ) or "" ),0,200,0)
		outputChatBox(string.format("Position: %.2f, %.2f, %.2f",wx or tx,wy or ty,wz or tz),200,200,200)

		-- Nur was hier als ersetzbar gemeldet wird, laesst sich auch mit
		-- engineReplaceModel austauschen.
		if name then
			outputChatBox("Ersetzbar: ja",0,200,0)
		else
			outputChatBox("Ersetzbar: NEIN - diese ID nimmt engineReplaceModel nicht an.",200,120,0)
		end
		return
	end

	outputChatBox("Getroffen, aber keine Modell-ID ermittelbar ( vermutlich Gelaende ).",200,200,0)
end)
