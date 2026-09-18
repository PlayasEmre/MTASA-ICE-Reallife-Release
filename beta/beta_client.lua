--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--\\                                                  //

local betaWindow, betaEdit, betaButton, betaLabel, betaError
local sendetGerade = false

-- Kamera waehrend des Fensters festhalten: setElementFrozen ( server, s.
-- beta_server.lua ) haelt nur die POSITION fest, nicht die Kamera - Mausbewegen
-- dreht sonst trotz Fenster weiter die Ansicht ( wie bei Login/Register auch,
-- dort faellt es nur seltener auf ). Bei jedem Frame wird deshalb dieselbe
-- Kameramatrix erneut gesetzt, solange das Fenster offen ist.
local kameraFest = false
local kx, ky, kz, klx, kly, klz

local function haltKamera ()
	if kameraFest then
		setCameraMatrix ( kx, ky, kz, klx, kly, klz )
	end
end
addEventHandler ( "onClientPreRender", root, haltKamera )

local function sendeCode ()
	if isElement ( betaWindow ) and not sendetGerade then
		local eingabe = dgsGetText ( betaEdit )
		if not eingabe or eingabe == "" then
			if betaError and isElement ( betaError ) then
				dgsSetText ( betaError, "Bitte einen Code eingeben." )
			end
			return
		end

		-- Knopf kurz sperren, damit ein Doppelklick/Doppel-Enter nicht zwei
		-- Anfragen gleichzeitig verschickt, waehrend der Server noch antwortet.
		sendetGerade = true
		if isElement ( betaButton ) then
			dgsSetText ( betaButton, "Prüfe..." )
			dgsSetEnabled ( betaButton, false )
		end
		setTimer ( function ()
			sendetGerade = false
			if isElement ( betaButton ) then
				dgsSetText ( betaButton, "Code einlösen" )
				dgsSetEnabled ( betaButton, true )
			end
		end, 2000, 1 )

		triggerServerEvent ( "betaCodeEinloesen", localPlayer, eingabe )
	end
end

function showBetaCodeWindow_func ()
	if betaWindow and isElement ( betaWindow ) then return end

	showCursor ( true )
	showChat ( false )

	kx, ky, kz, klx, kly, klz = getCameraMatrix ()
	kameraFest = true

	local sx, sy = guiGetScreenSize ()
	local w, h = 0.26, 0.30

	betaWindow = dgsCreateWindow ( sx/2 - ( sx*w )/2, sy/2 - ( sy*h )/2, sx*w, sy*h, "Beta-Zugang", false )
	dgsWindowSetCloseButtonEnabled ( betaWindow, false )
	dgsWindowSetSizable ( betaWindow, false )
	dgsWindowSetMovable ( betaWindow, false )

	dgsCreateLabel ( 0.06, 0.06, 0.88, 0.22, "Der Server befindet sich in der Beta-Phase.\nBitte gib deinen Zugangscode ein:", true, betaWindow )

	betaEdit = dgsCreateEdit ( 0.06, 0.32, 0.88, 0.14, "", true, betaWindow )

	betaError = dgsCreateLabel ( 0.06, 0.48, 0.88, 0.12, "", true, betaWindow )
	dgsLabelSetColor ( betaError, tocolor ( 255, 80, 80, 255 ) )

	betaButton = dgsCreateButton ( 0.06, 0.66, 0.88, 0.16, "Code einlösen", true, betaWindow )
	addEventHandler ( "onDgsMouseClickUp", betaButton, function ( btn )
		if btn == "left" then sendeCode () end
	end, false )

	local hinweis = dgsCreateLabel ( 0.06, 0.86, 0.88, 0.12, "Keinen Code? Kontaktiere den Inhaber auf Discord: EmreAbi", true, betaWindow )
	dgsLabelSetColor ( hinweis, tocolor ( 170, 170, 170, 255 ) )
	dgsLabelSetHorizontalAlign ( hinweis, "center", false )

	-- Mit Enter einloesen, ohne zum Knopf greifen zu muessen ( wie beim
	-- normalen Login, register_login/login_window.lua ).
	bindKey ( "enter", "down", sendeCode )
	bindKey ( "num_enter", "down", sendeCode )

	dgsFocus ( betaEdit )
end
addEvent ( "ShowBetaCodeWindow", true )
addEventHandler ( "ShowBetaCodeWindow", getRootElement(), showBetaCodeWindow_func )

addEvent ( "BetaCodeFehler", true )
addEventHandler ( "BetaCodeFehler", getRootElement(), function ( text )
	sendetGerade = false
	if isElement ( betaButton ) then
		dgsSetText ( betaButton, "Code einlösen" )
		dgsSetEnabled ( betaButton, true )
	end
	if betaError and isElement ( betaError ) then
		dgsSetText ( betaError, text )
	end
end )

addEvent ( "DisableBetaCodeWindow", true )
addEventHandler ( "DisableBetaCodeWindow", getRootElement(), function ()
	unbindKey ( "enter", "down", sendeCode )
	unbindKey ( "num_enter", "down", sendeCode )

	if betaWindow and isElement ( betaWindow ) then
		destroyElement ( betaWindow )
		betaWindow = nil
	end
	kameraFest = false
	showCursor ( false )
	showChat ( true )

	-- Denselben Weg wie beim ersten Verbinden erneut anstossen ( login_window.lua,
	-- "cdn:onClientReady" ), statt der Server serverseitig einen abweichenden
	-- Weg zum Anzeigen des Login-/Register-Fensters benutzt - dieser Weg ist
	-- erwiesenermassen zuverlaessig, der andere liess das Fenster manchmal
	-- ausbleiben.
	triggerServerEvent ( "regcheck", localPlayer, localPlayer )
end )
