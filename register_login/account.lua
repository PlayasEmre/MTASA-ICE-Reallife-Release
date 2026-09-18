--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function isRegistered ( pname )
	if playerUID[pname] then
		return true
	else
		local result = dbPoll ( dbQuery ( handler, "SELECT ?? FROM ?? WHERE ?? LIKE ?", "Erlaubnis", "players", "Serial", getPlayerSerial ( getPlayerFromName ( pname ) ) ), -1 )
		if result and result[1] then
			local erlaubnis = tonumber ( result[1]["Erlaubnis"] )
			if erlaubnis == 0 then
				return true
			end
		end
	end
	return false
end

-- Autologin an/aus ( Selbstklick-Menue -> Einstellungen ). Das Recht liegt
-- ausschliesslich beim eingeloggten Spieler selbst ueber sein eigenes Konto,
-- deshalb reicht ein einfacher Toggle ohne weitere Bestaetigung.
addEvent ( "toggleAutologin", true )
addEventHandler ( "toggleAutologin", getRootElement(), function ()
	local player = client
	if not isElement ( player ) then return end
	if MtxGetElementData ( player, "loggedin" ) ~= 1 then return end

	local pname = getPlayerName ( player )
	local uid = playerUID[pname]
	if not uid then return end

	local neuAus = not ( MtxGetElementData ( player, "autologinAus" ) == true )
	-- AutologinAus=1 bedeutet "Autologin AN" (siehe register_login_server.lua) -
	-- also umgekehrt zum Spaltennamen: hier wird bei neuAus=true (Autologin
	-- ausgeschaltet) eine 0 gespeichert, bei neuAus=false (eingeschaltet) eine 1.
	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "players", "AutologinAus", neuAus and 0 or 1, "UID", uid )
	MtxSetElementData ( player, "autologinAus", neuAus )

	if neuAus then
		outputChatBox ( "Autologin deaktiviert - du musst dich ab jetzt wieder mit Passwort einloggen.", player, 200, 125, 0 )
	else
		outputChatBox ( "Autologin aktiviert - auf diesem Computer wirst du kuenftig automatisch eingeloggt.", player, 0, 125, 0 )
	end
end )

function newpw_func ( player, cmd, newPW, newPWCheck )
	local pname = getPlayerName ( player )
	if MtxGetElementData ( player, "loggedin" ) == 1 then
		if newPW and newPWCheck then
			if newPWCheck == newPW then
				if #newPW < 6 then
					outputChatBox ( "Fehler: Das Passwort muss mindestens 6 Zeichen lang sein!", player, 125, 0, 0 )
				else
					-- Dasselbe Format wie bei Registrierung und Login: gesalzen
					-- ueber icePasswortErzeugen ( register_login_server.lua ).
					-- Der innere sha512 entspricht dem, was sonst der Client
					-- schickt - hier kommt das Kennwort im Klartext an.
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "players", "Passwort",
							 icePasswortErzeugen ( hash ( "sha512", newPW ), pname ), "UID", playerUID[pname] )
					outputChatBox ( "Passwort geändert!", player, 0, 125, 0 )
					outputLog ( getPlayerName ( player ).." ( IP: "..getPlayerIP ( player )..", Serial: "..getPlayerSerial ( player ).." ) hat sein Passwort geändert.", "pwchange" )
				end
			else
				outputChatBox ( "Die beiden Passwörter muessen identisch sein!", player, 125, 0, 0 )
			end
		else
			outputChatBox ( "Fehler: Ungültige Eingabe, bitte verwende folgendes: /newpw [Neues Password] [Neues Password]", player, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "newpw", newpw_func )