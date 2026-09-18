--//              Project: MTA - German ICE Reallife Gamemode               \\
--||              Developers: PlayasEmre                                   ||
--||              Version: 5.0                                             ||
--\\                                                                      //

local resourceName = getResourceName(getThisResource())
local lp = localPlayer
local screenwidth, screenheight = guiGetScreenSize()

-- Globale Tabellen initialisieren, falls sie nicht schon existieren
gWindows = gWindows or {}
gButtons = gButtons or {}
gGrid = gGrid or {}
gColumn = gColumn or {}
gWindow = gWindow or {} 
gHUD = gHUD or {} 

-- HINWEIS: Setze diese Farbe auf die Hauptfarbe deines Servers (z.B. das Blau aus dem Scoreboard)
--local guimaincolor = tocolor(0, 150, 255, 255) 
local guihovorcolor = tocolor(0, 150, 255, 100) -- Helle Hover-Farbe
local guibtncolor = tocolor(40, 40, 40, 200) -- Dunkle, halbtransparente Button-Hintergrundfarbe

-- ZENTRALE DEFINITIONEN FUER POSITIONIERUNG
local MAIN_MENU_WIDTH = 300 -- BREITER
local ALL_MENUS_Y = 50 -- HÖHER VERSCHOBEN
local ANIM_HUD_WIDTH = 300 -- BREITE der Untermenues an Hauptmenü angepasst

-- HINWEIS: Diese Tabelle muss von einem anderen Skript geladen werden, damit die Animationen funktionieren!
animationCMDs = animationCMDs or {
	"dance1", "dance2", "dance3", "sit", "smoke"
}


function hideall ()
    -- Funktion fuehrt nur noch das Ausblenden der DGS/GUI-Elemente durch.
	if isElement ( gWindow["achievmentList"] ) then dgsSetVisible( gWindow["achievmentList"], false ) end
	if isElement ( gWindow["handybg"] ) then dgsSetVisible ( gWindow["handybg"], false ) end
	if isElement ( gWindow["plistadmin"] ) then dgsSetVisible ( gWindow["plistadmin"], false ) end
	if isElement ( gWindow["rtext"] ) then dgsSetVisible ( gWindow["rtext"], false ) end
	if isElement ( gWindow["bonusmenue"] ) then dgsSetVisible ( gWindow["bonusmenue"], false ) end
	if isElement ( gWindow["anrufen"] ) then dgsSetVisible ( gWindow["anrufen"], false ) end
	if isElement ( gWindow["sms"] ) then dgsSetVisible ( gWindow["sms"], false ) end
	if isElement ( gWindow["friendlistMenue"] ) then dgsSetVisible ( gWindow["friendlistMenue"], false ) end
	if isElement ( gWindow["stats"] ) then dgsSetVisible ( gWindow["stats"], false ) end
	if isElement ( gWindow["settings"] ) then dgsSetVisible ( gWindow["settings"], false ) end
	if isElement ( gWindow["selfAnimations"] ) then dgsSetVisible ( gWindow["selfAnimations"], false ) end
    if isElement ( gWindow["hudMenue"] ) then dgsSetVisible ( gWindow["hudMenue"], false ) end
	if isElement ( gWindow["suchtInfo"] ) then dgsSetVisible ( gWindow["suchtInfo"], false ) end
	if isElement ( gWindow["socialRankSelection"] ) then dgsSetVisible ( gWindow["socialRankSelection"], false ) end
	if isElement ( gWindow["spawnPointSelection"] ) then dgsSetVisible ( gWindow["spawnPointSelection"], false ) end
	
	-- Das neue Hauptmenue auch ausblenden
	if isElement(gWindows["selfclick"]) then dgsSetVisible(gWindows["selfclick"], false) end
end

function SelfAdminBtn ()
	if getElementData ( lp, "adminlvl" ) >= 2 then
		hideall ()
		if showAdminMenue then showAdminMenue () end
        dgsSetInputEnabled ( true )
		showCursor ( true )
	end
end

function SelfOptionBtn ()
	hideall ()
	if showSettingsMenue then showSettingsMenue () end
    dgsSetInputEnabled ( true )
	showCursor ( true )
end

function SelfCancelBtn ()
	hideall ()
	dgsSetInputEnabled ( false )
	showCursor(false)
	triggerServerEvent ( "cancel_gui_server", localPlayer ) 
end

function SelfStateBtn ()
	hideall ()
	if showStats then showStats() end
    dgsSetInputEnabled ( true )
	showCursor ( true )
end

-- AUF DGS AKTUALISIERT & LAYOUT OPTIMIERT (Animations-Menü)
function showEmoteList ()
	hideall ()

    -- Position: Zentriert (angepasst an neue Breite)
	local newW = ANIM_HUD_WIDTH
	local newX = screenwidth / 2 - newW / 2
	local newY = ALL_MENUS_Y 
    local newH = 201 
    
    -- Anpassung der Groessen fuer ein besseres Layout
    local gridWidth = 180 
    local buttonWidth = newW - gridWidth - 30 
    local buttonX = gridWidth + 20 
    local gridHeight = newH - 40 

	if not isElement(gWindow["selfAnimations"]) then 
		gWindow["selfAnimations"] = dgsCreateWindow(newX, newY, newW, newH,"Animationen",false,nil,nil,nil,nil, false, nil, false)
		dgsBringToFront(gWindow["selfAnimations"])
		dgsWindowSetCloseButtonEnabled(gWindow["selfAnimations"], false)
		dgsSetAlpha(gWindow["selfAnimations"],1)
		dgsWindowSetSizable(gWindow["selfAnimations"], false)             
		dgsWindowSetMovable(gWindow["selfAnimations"], false)
		
		-- Grid (Linke Seite)
		gGrid["selfAnimations"] = dgsCreateGridList(10, 10, gridWidth, gridHeight, false, gWindow["selfAnimations"]) 
		dgsGridListSetSelectionMode(gGrid["selfAnimations"],1)
		gColumn["selfAnimation"] = dgsGridListAddColumn(gGrid["selfAnimations"],"Animation",0.8)
		dgsSetAlpha(gGrid["selfAnimations"],1)
		
        -- Buttons (Rechte Seite)
		gButtons["selfStartEmote"] = dgsCreateButton(buttonX, 40, buttonWidth, 40,"Ausfuehren",false,gWindow["selfAnimations"],_,_,_,_,_,_,tocolor(46,110,255,255),tocolor(123,163,255,255),tocolor(24,74,199,255),true)
		dgsSetAlpha(gButtons["selfStartEmote"],1)

		gButtons["selfStopEmote"] = dgsCreateButton(buttonX, 90, buttonWidth, 40,"Stoppen",false,gWindow["selfAnimations"],_,_,_,_,_,_,nil,nil,nil,true)
		dgsSetAlpha(gButtons["selfStopEmote"],1)
		
		addEventHandler("onDgsMouseClickUp", gButtons["selfStartEmote"],
			function(button)
				if button == "left" then
					local row = dgsGridListGetSelectedItem(gGrid["selfAnimations"])
					if row and row >= 0 then
						local cmd = dgsGridListGetItemText(gGrid["selfAnimations"], row, gColumn["selfAnimation"])
						triggerServerEvent("executeCommandHandlerServer", localPlayer, localPlayer, cmd, "") 
					end
				end
			end, false)
		
		addEventHandler("onDgsMouseClickUp", gButtons["selfStopEmote"],
			function(button,state)
			if button == "left" then 
				triggerServerEvent ( "executeCommandHandlerServer", localPlayer, localPlayer, "stopanim", "" ) 
			end	
		end, false)
		
		addEmotesToList ( gGrid["selfAnimations"], gColumn["selfAnimation"] )
	else
		dgsSetVisible ( gWindow["selfAnimations"], true )
		dgsBringToFront ( gWindow["selfAnimations"] )
	end
	
	dgsSetInputEnabled ( true )
	showCursor ( true )
end

-- NEUE FUNKTION: HUD-Auswahlmenü (Final angepasst)
function showHUDMenue()
    hideall()
    
    local w, h = ANIM_HUD_WIDTH, 160
    -- ZENTRIERUNG: Alle Menüs starten am gleichen Punkt
    local x = screenwidth / 2 - w / 2
    local y = ALL_MENUS_Y
    
    local btnW = w - 20 
    local btnH = 32
    local currentY = 15 -- NEU: Startposition der Buttons nach oben verschoben (war 30)
    local spacing = 10
    local btnBgColor = tocolor(25, 25, 25, 180)
    local btnHoverColor = tocolor(0, 150, 255, 150)
    local btnClickColor = tocolor(0, 100, 200, 200)

    if not isElement(gWindow["hudMenue"]) then
        gWindow["hudMenue"] = dgsCreateWindow(x, y, w, h, "HUD Stil Auswahl", false, nil, nil, nil, nil, false, nil, false)
        dgsBringToFront(gWindow["hudMenue"])
        dgsWindowSetCloseButtonEnabled(gWindow["hudMenue"], false)
        dgsSetAlpha(gWindow["hudMenue"], 1)
		dgsWindowSetSizable(gWindow["hudMenue"], false)             
		dgsWindowSetMovable(gWindow["hudMenue"], false)

        for i = 1, 3 do
            local btn = dgsCreateButton(10, currentY, btnW, btnH, "HUD Stil "..i, false, gWindow["hudMenue"], _, _, _, _, _, _, nil, nil, nil, true)
            dgsSetProperty(btn, "textColor", tocolor(255, 255, 255))
            
            addEventHandler("onDgsMouseClickUp", btn,
                function(button)
                    if button == "left" then
                        triggerServerEvent("hud_trigger_" .. i, localPlayer, localPlayer)
                        hideall() -- Schliesst alle Menüs nach der Auswahl
						dgsSetInputEnabled ( false )
						showCursor(false)
						triggerServerEvent ( "cancel_gui_server", localPlayer )
                    end
                end, false)
            
            currentY = currentY + btnH + spacing
        end

        -- Fensterhöhe anpassen
        local finalHeight = currentY + 30
        dgsSetSize(gWindow["hudMenue"], w, finalHeight, false)
    else
        dgsSetVisible(gWindow["hudMenue"], true)
        dgsBringToFront(gWindow["hudMenue"])
    end

    dgsSetInputEnabled(true)
    showCursor(true)
end

function addEmotesToList ( grid, column )
	if not animationCMDs then return end -- Sicherheitsabfrage
	for key, animation in ipairs ( animationCMDs ) do
		local row = dgsGridListAddRow ( grid )
		dgsGridListSetItemText ( grid, row, column, animation, false, false )
	end
end

-- ######################################################################
-- HAUPTMENUE (FINAL ZENTRIERT UND BREITER)
-- ######################################################################

function ShowSelfClickMenue_func()
	if introCutsceneAktiv then return end -- Waehrend der Intro-Kamerafahrt gesperrt, siehe quest/intro_cutscene_client.lua
	if getElementData ( localPlayer, "loggedin" ) == 0 then
		return
	end

	-- Wenn schon offen, einfach schliessen (Umschalt-Funktion)
	if isElement(gWindows["selfclick"]) and dgsGetVisible(gWindows["selfclick"]) then
		SelfCancelBtn()
		return
	end
	
	-- Alle anderen Fenster schliessen
	hideall()

	-- Steuerung auf GUI-Interaktion einstellen
	showCursor ( true )
    dgsSetInputEnabled ( true )

	-- Falls sich der Adminstatus seit dem Erstellen des Menues geaendert hat
	-- (befoerdert/degradiert waehrend der Session), Menue verwerfen und frisch
	-- aufbauen - sonst bleibt der Admin-Button dauerhaft falsch/veraltet.
	if isElement(gWindows["selfclick"]) then
		local isAdminNow = (getElementData(lp, "adminlvl") >= 2)
		local hadAdminButton = isElement(gButtons["selfadmin"])
		if isAdminNow ~= hadAdminButton then
			destroyElement(gWindows["selfclick"])
			gButtons["selfadmin"] = nil
		end
	end

	if not isElement(gWindows["selfclick"]) then
		-- Ein sauberes DGS-Fenster erstellen
		local w, h = MAIN_MENU_WIDTH, 330 
        -- POSITION: Zentriert
		local x = screenwidth / 2 - w / 2
		local y = ALL_MENUS_Y

		gWindows["selfclick"] = dgsCreateWindow(x, y, w, h, "Spieler-Menue (F4)", false, nil, nil, nil, nil, false, nil, false)
		dgsBringToFront(gWindows["selfclick"])
		dgsWindowSetCloseButtonEnabled(gWindows["selfclick"], false)
		dgsSetAlpha(gWindows["selfclick"],1)
		dgsWindowSetSizable(gWindows["selfclick"], false)             
		dgsWindowSetMovable(gWindows["selfclick"], false)

		-- Buttons erstellen
		local btnW = w - 20 -- Nutzt die neue Fensterbreite
		local btnH = 32 
		local currentY = 15 
		local spacing = 10 
		local iconSize = { 20, 20 } 
        local btnBgColor = tocolor(25, 25, 25, 180) 
        local btnHoverColor = tocolor(0, 150, 255, 150) 
        local btnClickColor = tocolor(0, 100, 200, 200) 

		-- 1. Status
		gButtons["selfstatus"] = dgsCreateButton(10, currentY, btnW, btnH, "Status", false, gWindows["selfclick"], _, _, _, _, _, _, nil, nil, nil, true)
		dgsSetProperty(gButtons["selfstatus"], "image", ":"..resourceName.."/images/self/status.png")
		dgsSetProperty(gButtons["selfstatus"], "imageSize", iconSize)
		dgsSetProperty(gButtons["selfstatus"], "imageSide", "left")
		dgsSetProperty(gButtons["selfstatus"], "textColor", tocolor(255, 255, 255))
		addEventHandler("onDgsMouseClickUp", gButtons["selfstatus"], function(btn) if btn == "left" then SelfStateBtn() end end, false)
		currentY = currentY + btnH + spacing

		-- 2. Einstellungen
		gButtons["selfoptions"] = dgsCreateButton(10, currentY, btnW, btnH, "Einstellungen", false, gWindows["selfclick"], _, _, _, _, _, _, nil, nil, nil, true)
		dgsSetProperty(gButtons["selfoptions"], "image", ":"..resourceName.."/images/self/settings.png")
		dgsSetProperty(gButtons["selfoptions"], "imageSize", iconSize)
		dgsSetProperty(gButtons["selfoptions"], "imageSide", "left")
        dgsSetProperty(gButtons["selfoptions"], "textColor", tocolor(255, 255, 255))
		addEventHandler("onDgsMouseClickUp", gButtons["selfoptions"], function(btn) if btn == "left" then SelfOptionBtn() end end, false)
		currentY = currentY + btnH + spacing

		-- 3. Animationen
		gButtons["selfemotes"] = dgsCreateButton(10, currentY, btnW, btnH, "Animationen", false, gWindows["selfclick"], _, _, _, _, _, _, nil, nil, nil, true)
		dgsSetProperty(gButtons["selfemotes"], "image", ":"..resourceName.."/images/self/emotes.png")
		dgsSetProperty(gButtons["selfemotes"], "imageSize", iconSize)
		dgsSetProperty(gButtons["selfemotes"], "imageSide", "left")
        dgsSetProperty(gButtons["selfemotes"], "textColor", tocolor(255, 255, 255))
		addEventHandler("onDgsMouseClickUp", gButtons["selfemotes"], function(btn) if btn == "left" then showEmoteList() end end, false)
		currentY = currentY + btnH + spacing
		
        -- 4. HUD STIL AUSWAHL (NEU)
		gButtons["selfhud"] = dgsCreateButton(10, currentY, btnW, btnH, "HUD Stil", false, gWindows["selfclick"], _, _, _, _, _, _, nil, nil, nil, true)
		dgsSetProperty(gButtons["selfhud"], "image", ":"..resourceName.."/images/self/settings.png") -- Platzhalter Icon
		dgsSetProperty(gButtons["selfhud"], "imageSize", iconSize)
		dgsSetProperty(gButtons["selfhud"], "imageSide", "left")
        dgsSetProperty(gButtons["selfhud"], "textColor", tocolor(255, 255, 255))
		addEventHandler("onDgsMouseClickUp", gButtons["selfhud"], function(btn) if btn == "left" then showHUDMenue() end end, false)
		currentY = currentY + btnH + spacing
		
		-- 5. Handy
		gButtons["selfhandy"] = dgsCreateButton(10, currentY, btnW, btnH, "Handy", false, gWindows["selfclick"], _, _, _, _, _, _, nil, nil, nil, true)
		dgsSetProperty(gButtons["selfhandy"], "image", ":"..resourceName.."/images/self/handy.png")
		dgsSetProperty(gButtons["selfhandy"], "imageSize", iconSize)
		dgsSetProperty(gButtons["selfhandy"], "imageSide", "left")
        dgsSetProperty(gButtons["selfhandy"], "textColor", tocolor(255, 255, 255))
		addEventHandler("onDgsMouseClickUp", gButtons["selfhandy"], 
			function(btn) 
				if btn == "left" then 
					hideall ()
					if showHandy then showHandy() end
				end 
			end, false)
		currentY = currentY + btnH + spacing

		-- 6. Freundesliste
		gButtons["selffriendlist"] = dgsCreateButton(10, currentY, btnW, btnH, "Freundesliste", false, gWindows["selfclick"], _, _, _, _, _, _, nil, nil, nil, true)
		dgsSetProperty(gButtons["selffriendlist"], "image", ":"..resourceName.."/images/self/friendlist.png")
		dgsSetProperty(gButtons["selffriendlist"], "imageSize", iconSize)
		dgsSetProperty(gButtons["selffriendlist"], "imageSide", "left")
        dgsSetProperty(gButtons["selffriendlist"], "textColor", tocolor(255, 255, 255))
		addEventHandler("onDgsMouseClickUp", gButtons["selffriendlist"], 
			function(btn) 
				if btn == "left" then 
					hideall ()
					if showFriendlistSelf then showFriendlistSelf() end
				end 
			end, false)
		currentY = currentY + btnH + spacing

		-- 7. Admin (Nur anzeigen, wenn Admin)
		if getElementData(lp, "adminlvl") >= 2 then
			gButtons["selfadmin"] = dgsCreateButton(10, currentY, btnW, btnH, "Admin-Menue", false, gWindows["selfclick"], _, _, _, _, _, _, nil, nil, nil, true)
			dgsSetProperty(gButtons["selfadmin"], "image", ":"..resourceName.."/images/self/admin.png")
			dgsSetProperty(gButtons["selfadmin"], "imageSize", iconSize)
			dgsSetProperty(gButtons["selfadmin"], "imageSide", "left")
			dgsSetProperty(gButtons["selfadmin"], "textColor", tocolor(255, 100, 100)) -- Rote Schrift fuer Admin
			addEventHandler("onDgsMouseClickUp", gButtons["selfadmin"], function(btn) if btn == "left" then SelfAdminBtn() end end, false)
			currentY = currentY + btnH + spacing
		end

		-- 8. Schliessen
		gButtons["selfcancel"] = dgsCreateButton(10, currentY, btnW, btnH, "Schliessen", false, gWindows["selfclick"], _, _, _, _, _, _, nil, nil, nil, true)
		dgsSetProperty(gButtons["selfcancel"], "image", ":"..resourceName.."/images/self/close.png")
		dgsSetProperty(gButtons["selfcancel"], "imageSize", iconSize)
		dgsSetProperty(gButtons["selfcancel"], "imageSide", "left")
        dgsSetProperty(gButtons["selfcancel"], "textColor", tocolor(255, 255, 255))
		addEventHandler("onDgsMouseClickUp", gButtons["selfcancel"], function(btn) if btn == "left" then SelfCancelBtn() end end, false)
		
		-- Hoehe des Fensters an die Anzahl der Buttons anpassen
		local finalHeight = currentY + btnH + 30 -- Puffer am Ende vergroessert
		dgsSetSize(gWindows["selfclick"], w, finalHeight, false)
		
	else
		dgsSetVisible ( gWindows["selfclick"], true )
		dgsBringToFront ( gWindows["selfclick"] )
	end
end

removeEventHandler ( "ShowSelfClickMenue", localPlayer, ShowSelfClickMenue_func)
unbindKey ("F4", "down", ShowSelfClickMenue_func )

-- Neue Handler hinzufuegen
addEvent ( "ShowSelfClickMenue", true)
addEventHandler ( "ShowSelfClickMenue", localPlayer, ShowSelfClickMenue_func)
bindKey ("F4", "down", ShowSelfClickMenue_func )