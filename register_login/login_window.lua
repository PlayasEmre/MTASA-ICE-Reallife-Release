--//                                                                 \\
--||  Project: MTA - German ICE Reallife Gamemode                    ||
--||  Developers: PlayasEmre                                         ||
--||  Version: 5.0                                                   ||
--\\                                                                 //

addEvent('ShowLoginWindow', true )
addEvent ( "aktualisiereMemberTabelle", true )


local LOGIN_W, LOGIN_H = guiGetScreenSize()
local LOGIN_BILD     = ":"..getResourceName(getThisResource()).."/register_login/login_register.png"
local HALLOWEEN_BILD = ":"..getResourceName(getThisResource()).."/images/halloween.jpg"

addEventHandler ( "onClientRestore", root, function ()
	LOGIN_W, LOGIN_H = guiGetScreenSize()
end )

function Login()
	if event.islogin then
		dxDrawImage(0, 0, LOGIN_W, LOGIN_H, LOGIN_BILD, 0, 0, 0, tocolor(255, 255, 255, 255), false)
	elseif event.isHalloween then
		dxDrawImage(0, 0, LOGIN_W, LOGIN_H, HALLOWEEN_BILD, 0, 0, 0, tocolor(255, 255, 255, 255), false)
	end
end

addEvent("cdn:onClientReady",true)
addEventHandler("cdn:onClientReady",root,function()
	if event.islogin then
		joinmusik = playSound (":"..getResourceName(getThisResource()).."/register_login/Loginmusic.mp3")
		setSoundVolume(joinmusik, 0.5)
	elseif event.isHalloween then
		halloweenmusik = playSound( ":"..getResourceName(getThisResource()).."/sounds/bell.ogg")
		setSoundVolume(halloweenmusik, 0.3)
		setAmbientSoundEnabled( "gunfire", false )
	end
end)

function stopjoinmusik()
	if isElement(joinmusik) then
		destroyElement( joinmusik )
		joinmusik = nil
	end
	if isElement(halloweenmusik) then
		destroyElement( halloweenmusik )
		halloweenmusik = nil
	end
end


function isWithinNightTime ()
    local time = getRealTime()
    local hour = time.hour
    if hour >= 20 or hour <= 8 then
        return true
    else
        return false
    end
end


function startjoinmusik()
	if isElement ( joinmusik ) then
		return
	end

	if event and event.isHalloween then
		if not isElement ( halloweenmusik ) then
			halloweenmusik = playSound ( ":"..getResourceName(getThisResource()).."/sounds/bell.ogg" )
			if halloweenmusik then setSoundVolume ( halloweenmusik, 0.3 ) end
			setAmbientSoundEnabled ( "gunfire", false )
		end
		return
	end

	joinmusik = playSound ( ":"..getResourceName(getThisResource()).."/register_login/Loginmusic.mp3" )
	if joinmusik then
		setSoundVolume ( joinmusik, 0.5 )
	end
end


local PLATZHALTER = "**********"
local gespeicherterHash = nil


local function istHash ( wert )
	return type ( wert ) == "string" and #wert == 128 and wert:match ( "^%x+$" ) ~= nil
end

function _CreateLoginWindow()
    removeEventHandler ( "onClientRender", root, Login)


	if isElement ( login ) then
		destroyElement ( login )
		login = nil
	end

	showCursor(true)
	startjoinmusik()
    login = dgsCreateWindow(0.42, 0.40, 0.19, 0.25,"Anmelden",true)
    dgsWindowSetCloseButtonEnabled(login, false)
    dgsWindowSetSizable(login,false)
    dgsWindowSetMovable(login,false)


    local nameLabel = dgsCreateLabel(0.05, 0.08, 0.90, 0.10, "Willkommen, "..getPlayerName(localPlayer), true, login)
    dgsLabelSetHorizontalAlign(nameLabel, "center", false)
    dgsSetFont(nameLabel, "default-bold")

    dgsCreateLabel(0.05, 0.22, 0.30, 0.10,"Kennwort:",true,login)
    pw = dgsCreateEdit( 0.05, 0.32, 0.90, 0.12, "", true,login)
	dgsEditSetMasked(pw,true)
    dgsCreateLabel(0.05, 0.48, 0.65, 0.10, "Kennwort speichern",true,login)
    loginButton = dgsCreateButton(0.25, 0.74, 0.50, 0.14, "Einloggen", true, login, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
    pwSafeYes = dgsCreateRadioButton(0.05, 0.60, 0.40, 0.08, "Ja",true, login)
    pwSafeNo = dgsCreateRadioButton(0.55, 0.60, 0.40, 0.08, "Nein",true, login)
    addEventHandler ( "onDgsMouseClickUp", loginButton, SubmitEinloggenBtn, false )

    bindKey ( "enter", "down", loginPerEnter )
    bindKey ( "num_enter", "down", loginPerEnter )


    dgsFocus ( pw )
	addEventHandler ( "onClientRender", root, Login)
	local pwfile = xmlLoadFile ( ":"..Tables.servername.."/pw.xml" )
	local psafe
	if not pwfile then
		pwfile = xmlCreateFile ( ":"..Tables.servername.."/pw.xml", "PW" )
		psafe = pwfile and xmlCreateChild ( pwfile, "pw" )
		if pwfile then xmlSaveFile ( pwfile ) end
	else
		psafe = xmlFindChild ( pwfile, "pw", 0 )
	end
	gespeicherterHash = nil

	if psafe then
		local gespeichert = xmlNodeGetValue ( psafe )

		if gespeichert and gespeichert ~= "" then
			if istHash ( gespeichert ) then
				gespeicherterHash = gespeichert
			else
				gespeicherterHash = hash ( "sha512", gespeichert )
				xmlNodeSetValue ( psafe, gespeicherterHash )
				xmlSaveFile ( pwfile )
			end

			dgsSetText(pw, PLATZHALTER)
			dgsRadioButtonSetSelected(pwSafeYes, true)
		else
			dgsRadioButtonSetSelected(pwSafeNo, true)
		end
	else
		dgsRadioButtonSetSelected(pwSafeNo, true)
	end

	dgsEditSetMasked(pw,true)

	if pwfile then
		xmlUnloadFile ( pwfile )
	end
end


local sendetGerade = false

function loginPerEnter ()
	if isElement ( login ) then
		SubmitEinloggenBtn ( "left" )
	end
end

function SubmitEinloggenBtn(button)
	if button == "left" then
		if sendetGerade then
			return
		end

		local name = getPlayerName(localPlayer)
		local passwort = dgsGetText(pw)
		if not passwort or passwort == "" then
			outputChatBox ( "Bitte gib dein Passwort ein!", 255, 0, 0 )
			return
		end

		sendetGerade = true
		if isElement ( loginButton ) then
			dgsSetText ( loginButton, "Pruefe..." )
			dgsSetEnabled ( loginButton, false )
		end

		setTimer ( function ()
			sendetGerade = false
			if isElement ( loginButton ) then
				dgsSetText ( loginButton, "Einloggen" )
				dgsSetEnabled ( loginButton, true )
			end
		end, 2000, 1 )
		
		local pwHash
		if passwort == PLATZHALTER and gespeicherterHash then
			pwHash = gespeicherterHash
		else
			pwHash = hash ( "sha512", passwort )
		end

		local file = xmlLoadFile ( ":"..Tables.servername.."/pw.xml" )
		if file then
			local psafe = xmlFindChild ( file, "pw", 0 )
			if psafe then
				if dgsRadioButtonGetSelected(pwSafeYes) then
					xmlNodeSetValue(psafe, pwHash)
					gespeicherterHash = pwHash
				elseif dgsRadioButtonGetSelected(pwSafeNo) then
					xmlNodeSetValue(psafe, "")
					gespeicherterHash = nil
				end
				xmlSaveFile(file)
			end
			xmlUnloadFile ( file )
		end
		triggerServerEvent ("einloggen",localPlayer,localPlayer,pwHash)
	end
end

function GUI_ShowLoginWindow()
	_CreateLoginWindow()
end
addEventHandler ( "ShowLoginWindow", getRootElement(), GUI_ShowLoginWindow)


function GUI_DisableLoginWindow()
    unbindKey ( "enter", "down", loginPerEnter )
    unbindKey ( "num_enter", "down", loginPerEnter )

    if login and isElement(login) then
        destroyElement(login)
        login = nil
    end
	stopjoinmusik()
    showCursor(false)
    setTimer ( checkForSocialStateChanges, 10000, 0 )
    setTimer ( getPlayerSocialAvailableStates, 1000, 1 )
    if isTimer ( LVCamFlightTimer ) then
        killTimer ( LVCamFlightTimer )
    end
    setElementClicked ( false )
	removeEventHandler ( "onClientRender", root, Login)
	local hud = tonumber(getElementData(localPlayer,"hud"))
	triggerEvent( "showhudclient", localPlayer, hud)
end
addEvent ( "DisableLoginWindow", true )
addEventHandler ( "DisableLoginWindow", getRootElement(), GUI_DisableLoginWindow)

function check()
	local player = localPlayer
	triggerServerEvent ( "regcheck", localPlayer, player )
end
addEventHandler('cdn:onClientReady', root, check)