--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

_G["Clantag"] = "no"
setGlitchEnabled ( "fastsprint", true )

-- Kennwoerter in players.Passwort: "s2$<Salt>$<sha512(Salt..clientHash)>".
-- Das Salt steht im Wert selbst (keine extra Spalte) und ist je Konto anders,
-- damit gleiche Kennwoerter verschieden aussehen und nicht ueber vorberechnete
-- Listen nachschlagbar sind. Der Client schickt unveraendert sha512(Klartext).

-- Salt muss nicht geheim sein, nur je Konto verschieden.
local function neuesSalt ( pname )
	return hash ( "md5", tostring ( getTickCount () )..tostring ( math.random ( 1, 1000000000 ) )..
						 tostring ( getRealTime ().timestamp )..tostring ( pname or "" ) )
end

-- Erzeugt den Datenbankwert aus dem, was der Client geschickt hat.
function icePasswortErzeugen ( clientHash, pname )
	local salt = neuesSalt ( pname )
	return "s2$"..salt.."$"..hash ( "sha512", salt..clientHash )
end

-- Prueft ein Kennwort. Zweiter Rueckgabewert sagt, ob der Eintrag noch im
-- alten Format vorliegt und beim naechsten Erfolg umgestellt werden sollte.
function icePasswortPasst ( gespeichert, clientHash )
	if type ( gespeichert ) ~= "string" or gespeichert == "" or type ( clientHash ) ~= "string" then
		return false, false
	end

	local salt, wert = gespeichert:match ( "^s2%$(%x+)%$(%x+)$" )
	if salt then
		return hash ( "sha512", salt..clientHash ) == wert, false
	end

	-- Altbestand ohne Salt.
	return gespeichert == hash ( "sha512", clientHash ), true
end

clanMembers = {}
ticketPermitted = {}

addEventHandler ( "onPlayerConnect", getRootElement(), function ( nick, ip, uname, serial )
	if nick == "Player" then
		cancelEvent ( true, "Bitte wähle einen Nickname ( Unter \"Settings\" )" )
	elseif string.find ( nick, "mtasa" ) then
		cancelEvent ( true, "Fuck you!" )
	elseif string.find ( nick, "'" ) then
		cancelEvent ( true, "Bitte kein ' benutzen!" )
	else
		local result = nil
		if playerUID[nick] then 
			result = dbPoll ( dbQuery ( handler, "SELECT STime, Grund, AdminUID FROM ?? WHERE UID=? OR ??=?", "ban", playerUID[nick], "Serial", serial ), -1 )
		else
			result = dbPoll ( dbQuery ( handler, "SELECT STime, Grund, AdminUID FROM ?? WHERE ??=?", "ban", "Serial", serial ), -1 )
		end
		local deleteit = false
		if result and result[1] then
			for i=1, #result do
				if result[i]["STime"] ~= 0 and ( result[i]["STime"] - getTBanSecTime ( 0 ) ) <= 0 then
					deleteit = true
				else
					local reason = result[i]["Grund"]
					local admin = playerUIDName[tonumber ( result[i]["AdminUID"] )]
					local diff = math.floor ( ( ( result[i]["STime"] - getTBanSecTime ( 0 ) ) / 60 ) * 100 ) / 100
					if diff >= 0 then
						cancelEvent ( true, "Du bist noch "..diff.." Stunden von "..tostring(admin).." gesperrt, Grund: "..tostring(reason) )
					else
						cancelEvent ( true, "Du wurdest permanent von "..tostring(admin).." gesperrt, Grund: "..tostring(reason) )
					end
					return
				end
			end
			if deleteit then
				if playerUID[nick] then
					dbExec ( handler, "DELETE FROM ?? WHERE ( UID=? OR Serial=? ) AND STime<>0 AND STime<=?", "ban", playerUID[nick], serial, getTBanSecTime ( 0 ) )
				else
					dbExec ( handler, "DELETE FROM ?? WHERE Serial=? AND STime<>0 AND STime<=?", "ban", serial, getTBanSecTime ( 0 ) )
				end
			end
		elseif getPlayerWarnCount ( nick ) >= 3 then
			cancelEvent ( true, "Du hast 3 Warns! Ablaufdatum des nächsten Warns: "..getLowestWarnExtensionTime ( nick ) )
		end
	end
end )



function regcheck_func ( player )

	setPedStat ( player, 22, 50 )
	setElementFrozen ( player, true )
	MtxSetElementData  ( player, "loggedin", 0 )
	
	local pname = getPlayerName ( player )
	toggleAllControls ( player, false )
	if player == client then
		if isSerialValid ( getPlayerSerial(player) ) or isRegistered ( pname ) then
			if ( hasInvalidChar ( player ) or string.find ( pname, "'" ) ) and not isRegistered ( pname ) then
				kickPlayer ( player, "Dein Name enthält ungültige Zeichen!" )
			else
				if pname ~= "player" then
					if isRegistered ( pname ) then
						local serial = getPlayerSerial ( player )
						local thename = ""
						local haterlaubnis = false
						local result = dbQueryCoro ( "SELECT Name, Erlaubnis, AutologinAus FROM players WHERE ?? LIKE ?", "Serial", serial )
						if result and result[1] then
							thename = result[1]["Name"]
							if tonumber ( result[1]["Erlaubnis"] ) == 1 then
								thename = pname 
								haterlaubnis = true
							end
						else
							thename = pname
						end
					if string.lower(thename) ~= string.lower(pname) then
						if thename ~= getPlayerName(player) then
							if not haterlaubnis then
								kickPlayer ( player, "Du hast schon ein Account mit einem anderen Namen ("..thename..")" )
								return false
							end
						end
					end
						-- Autologin: der gerade verbundene Serial ist bereits fest mit
						-- GENAU diesem Account verknuepft (nicht "haterlaubnis" - das
						-- waere ein geteilter PC mit mehreren Accounts, dort bleibt das
						-- Passwort weiterhin Pflicht) UND der Spieler hat es sich selbst
						-- im Optionsmenü eingeschaltet ( AutologinAus = 1 ).
						-- ACHTUNG trotz Spaltenname: AutologinAus=1 bedeutet hier "Autologin
						-- AN", =0 (Standard, bestehende Accounts) bedeutet "aus/normales
						-- Passwort-Login" - bewusst so gewaehlt, Spaltenname nicht mehr
						-- passend, aber eine Umbenennung braeuchte eine weitere Migration.
						local autologinAktiviert = result and result[1] and tonumber ( result[1]["AutologinAus"] ) == 1
						if result and result[1] and not haterlaubnis and autologinAktiviert
						   and string.lower ( thename ) == string.lower ( pname ) then
							runAsync ( login_func, player, nil, true )
						else
							triggerClientEvent ( player, "ShowLoginWindow", getRootElement(), thename, true )
						end
					else
						local clantag = gettok ( pname, 1, string.byte(']') )
						if testmode == true then
							triggerClientEvent ( player, "ShowRegisterGui", getRootElement() )
						else
							local serial = getPlayerSerial ( player )
							if string.upper ( clantag ) == "[VNX" then
								kickPlayer (player, "Du bist kein Mitglied des Clans!")
							elseif string.upper ( clantag ) == "[NOVA" or string.upper ( clantag ) == "[VIO" or string.upper ( clantag ) == "[EXO" or string.upper ( clantag ) == "[XTM" or string.upper ( clantag ) == "[GRS" or string.upper ( clantag ) == "[COA" or string.upper ( clantag ) == "[VITA" or string.upper ( clantag ) == "[UTM" or string.upper ( clantag ) == "[UL" then
								kickPlayer (player, "Dieses Clantag ist nicht erlaubt!")
							elseif #pname < 3 or #pname > 20 then
								kickPlayer ( player, "Bitte mindestens 3 und maximal 20 Zeichen als Nickname!" )
							elseif hasInvalidChar ( player ) or string.find ( pname, "'" ) then
								kickPlayer ( player, "Bitte nimm einen Nickname ohne ueberfluessige Zeichen!" )
							elseif string.lower (pname) == "niemand" or string.lower (pname) == "versteigerung" or string.lower (pname) == "none" then
								kickPlayer ( player, "Ungültiger Name!" )
							else
								triggerClientEvent ( player, "ShowRegisterGui", getRootElement() )
							end
						end
					end
				else
					kickPlayer ( player, "Bitte ändere deinen Nickname!" )
				end
			end
		else
			kickPlayer ( player, "Dein MTA verwendet einen ungültigen Serial. Bitte neu installieren!" )
		end
	end
end
addEvent ( "regcheck", true )
addEventHandler ("regcheck", getRootElement(), function ( player )
	-- Das globale "client" muss VOR dem coroutine.yield in pruefeBetaSperre
	-- gesichert werden: sobald hatBetaZugang ( beta/beta_server.lua ) per
	-- dbQueryCoro einmal asynchron yieldet und spaeter ueber den DB-Callback
	-- fortgesetzt wird, ist "client" nicht mehr zuverlaessig gesetzt - der
	-- "player == client"-Check ganz am Anfang von regcheck_func schlaegt dann
	-- lautlos fehl und das Login-/Register-Fenster erscheint nie. Deshalb wird
	-- "client" hier gesichert und direkt vor regcheck_func wiederhergestellt.
	local gesichertesClient = client
	runAsync ( function ()
		-- beta/beta_server.lua: haelt hier an und zeigt das Code-Fenster, wenn
		-- die Beta aktiv ist und dieser Serial noch keinen Zugang hat. Ohne
		-- Beta ( oder mit vorhandenem Zugang ) laeuft es normal weiter.
		if pruefeBetaSperre and pruefeBetaSperre ( player ) then return end
		client = gesichertesClient
		regcheck_func ( player )
	end )
end )

function register_func ( player, passwort, bday, bmon, byear, geschlecht,promocode)
			local player = client
			if not isElement ( player ) then return end

			-- Beta-Sperre auch hier: "register" ist client-ausloesbar und laesst
			-- sich damit an regcheck vorbei aufrufen.
			if event.isBeta and hatBetaZugang and not hatBetaZugang ( getPlayerSerial ( player ) ) then
				return
			end

			local pname = getPlayerName ( player )
			-- Das fruehere "and player == client" am Ende dieser Bedingung wurde
			-- erst NACH isRegistered ( yieldet per DB ) ausgewertet, wo "client"
			-- nicht mehr verlaesslich ist. player ist oben bereits client.
			if MtxGetElementData ( player, "loggedin" ) == 0 and not isRegistered ( pname ) then
				setPlayerLoggedIn ( pname )
				
				toggleAllControls ( player, true )
				MtxSetElementData ( player, "loggedin", 1 )

				local ip = getPlayerIP ( player )
				
				local regtime = getRealTime()
				local year = regtime.year + 1900
				local month = regtime.month + 1
				local day = regtime.monthday
				local hour = regtime.hour
				local minute = regtime.minute
				
				
				local registerdatum = tostring(day.."."..month.."."..year..", "..hour..":"..minute)
				local lastlogin = registerdatum
				
				-- Neuanmeldungen bekommen sofort das gesalzene Format.
				passwort = icePasswortErzeugen ( passwort, pname )
				local lastLoginInt = getSecTime ( 0 )
				
				local id = tonumber ( dbQueryCoro ( "SELECT ?? FROM ?? WHERE id=id", "id", "idcounter" )[1]["id"] )
				dbExec ( handler, "UPDATE ?? SET ?? = ?", "idcounter", "id", id+1 )
				
				local result = dbExec ( handler, "INSERT INTO players ( UID, Name, Serial, IP, Last_login, Geburtsdatum_Tag, Geburtsdatum_Monat, Geburtsdatum_Jahr, Passwort, Geschlecht, RegisterDatum, LastLogin) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", id, pname, getPlayerSerial(player), getPlayerIP ( player ), lastlogin, tonumber ( bday), tonumber ( bmon), tonumber ( byear), passwort, geschlecht, registerdatum, lastLoginInt )
				if not result then
					outputDebugString ( "[players] Fehler beim Ausführen der Abfrage")
				else
					triggerClientEvent ( player, "infobox_start", player, "Du hast dich\nerfolgreich registriert!\n\nDeine Daten werden\nnun gespeichert!", 7500, 0, 255, 0 )
					playerUID[pname] = id
					playerUIDName[id] = pname
				end
				
				local result = dbExec ( handler, "INSERT INTO achievments (UID) VALUES (?)", id )
				if not result then
					outputDebugString ( "[achievments] Fehler beim Ausführen der Abfrage")
				end
				
				local result = dbExec ( handler, "INSERT INTO inventar (UID) VALUES (?)", id )
				if not result then
					outputDebugString ( "[inventar] Fehler beim Ausführen der Abfrage")
				end
				
				local result = dbExec ( handler, "INSERT INTO packages (UID, Paket1, Paket2, Paket3, Paket4, Paket5, Paket6, Paket7, Paket8, Paket9, Paket10, Paket11, Paket12, Paket13, Paket14, Paket15, Paket16, Paket17, Paket18, Paket19, Paket20, Paket21, Paket22, Paket23, Paket24, Paket25) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", id,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0' )
				if not result then
					outputDebugString ( "[packages] Fehler beim Ausführen der Abfrage")
				end
				
				local result = dbExec ( handler, "INSERT INTO bonustable (UID, Lungenvolumen, Muskeln, Kondition, Boxen, KungFu, Streetfighting, CurStyle, PistolenSkill, DeagleSkill, ShotgunSkill, AssaultSkill) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", id, 'none', 'none', 'none', 'none', 'none', 'none', '4', 'none', 'none', 'none', 'none' )
				if not result then
					outputDebugString ( "[bonustable] Fehler beim Ausführen der Abfrage")
				end
				
				local result = dbExec ( handler, "INSERT INTO statistics ( UID ) VALUES (?)", id )
				if not result then
					outputDebugString ( "[statistics] Fehler beim Ausführen der Abfrage")
				end
				
				local result = dbExec ( handler, "INSERT INTO skills ( UID ) VALUES (?)", id )
				if not result then
					outputDebugString ( "[skills] Fehler beim Ausführen der Abfrage")
				end
				
				local result = dbExec(handler,"INSERT INTO clothes (Name,shirt1,shirt2,hair1,hair2,hose1,hose2,schuhe1,schuhe2,Hut1,Hut2,Bandana1,Bandana2) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",pname,'none','none','none','none','none','none','none','none','none','none','none','none')
				if not result then
					outputDebugString ( "[clothes] Fehler beim Ausführen der Abfrage")
				end
				
				local result = dbExec(handler,"INSERT INTO promotion (Username,Promo0) VALUES (?,?)", pname, '0')
				if not result then
					outputDebugString ( "[promotion] Fehler beim Ausführen der Abfrage")
				end
				
				if geschlecht == nil then
					geschlecht = 1
				end			
				
				MtxSetElementData ( player, "money", 1000 )
				MtxSetElementData ( player, "points", 0 )
				MtxSetElementData ( player, "packages", "0" )
				local Spawnpos_X = 1968.765
				MtxSetElementData ( player, "spawnpos_x", Spawnpos_X )
				local Spawnpos_Y = 119.178
				MtxSetElementData ( player, "spawnpos_y", Spawnpos_Y )
				local Spawnpos_Z = 27.688
				MtxSetElementData ( player, "spawnpos_z", Spawnpos_Z )
				local Spawnrot_X = 356.2
				MtxSetElementData ( player, "spawnrot_x", Spawnrot_X )
				local SpawnInterior = 0
				MtxSetElementData ( player, "spawnint", SpawnInterior )
				local SpawnDimension = 0
				MtxSetElementData ( player, "spawndim", SpawnDimension )
				MtxSetElementData ( player, "fraktion", 0 )
				MtxSetElementData ( player, "rang", 0 )
				MtxSetElementData ( player, "adminlvl", 0 )
				MtxSetElementData ( player, "playingtime", 0 )
				MtxSetElementData ( player, "curcars", 0 )
				MtxSetElementData ( player, "maxcars", 5 )
				for i=1, 20 do
					MtxSetElementData ( player, "carslot"..i, 0 )
				end
				MtxSetElementData ( player, "deaths", 0 )
				MtxSetElementData ( player, "kills", 0 )
				setElementData ( player, "TacticKills", 0 )
				setElementData ( player, "TacticTode", 0 )
				MtxSetElementData ( player, "gangwarwins", 0 )
				MtxSetElementData ( player, "gangwarlosses", 0 )
				MtxSetElementData ( player, "jailtime", 0 )
				MtxSetElementData ( player, "prison", 0 )
				MtxSetElementData ( player, "bail", 0 )
				MtxSetElementData ( player, "heaventime", 0 )
				MtxSetElementData ( player, "housekey", 0 )
				MtxSetElementData ( player, "bizkey", 0 )
				MtxSetElementData ( player, "bankmoney", 7000 )
				MtxSetElementData ( player, "drugs", 0 )
				local Skinid = getRandomRegisterSkin ( player, geschlecht )
				MtxSetElementData ( player, "skinid", Skinid )
				MtxSetElementData ( player, "carlicense", 0 )
				MtxSetElementData ( player, "bikelicense", 0 )
				MtxSetElementData ( player, "lkwlicense", 0 )
				MtxSetElementData ( player, "helilicense", 0 )
				MtxSetElementData ( player, "planelicensea", 0 )
				MtxSetElementData ( player, "planelicenseb", 0 )
				MtxSetElementData ( player, "motorbootlicense", 0 )
				MtxSetElementData ( player, "segellicense", 0)
				MtxSetElementData ( player, "fishinglicense", 0)
				MtxSetElementData ( player, "wanteds", 0 )
				MtxSetElementData ( player, "stvo_punkte", 0 )
				MtxSetElementData ( player, "gunlicense", 0 )
				MtxSetElementData ( player, "perso", 0 )
				MtxSetElementData ( player, "boni", 1000 )
				MtxSetElementData ( player, "pdayincome", 0 )
				MtxSetElementData ( player, "hitglocke", 0 )
				MtxSetElementData ( player, "medikits", 0 )
				MtxSetElementData ( player, "repairkits", 0 )
				MtxSetElementData ( player, "busroute", 0 )
				MtxSetElementData ( player, "premium", false )
				MtxSetElementData ( player, "Paket", 0 )
				MtxSetElementData ( player, "PremiumData", 0 )
				MtxSetElementData ( player, "PremiumCars", 0 )
				MtxSetElementData ( player, "lastSocialChange", 0 )
				MtxSetElementData ( player, "lastNumberChange", 0 )
				MtxSetElementData ( player, "lastPremCarGive", 0 )
				local Telefonnr
				local run = 1
				while true do
					if run >= 20 then
						break
					else
						run = run + 1
					end
					local tnr = math.random ( 1000, 9999999 )
					local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Telefonnr", "userdata", "Telefonnr", tnr )
					if not result or not result[1] then
						if tonumber ( tnr ) ~= 911 and tonumber ( tnr ) ~= 333 and tonumber ( tnr ) ~= 400 and tonumber (tnr ) ~= 666666 then
							Telefonnr = tnr
							break
						end
					end
				end
				if Telefonnr == nil then
					Telefonnr = math.random ( 1000, 9999999 )
				end
				MtxSetElementData ( player, "telenr", Telefonnr )
				MtxSetElementData ( player, "warns", 0 )
				MtxSetElementData ( player, "gunboxa", "0|0" )
				MtxSetElementData ( player, "gunboxb", "0|0" )
				MtxSetElementData ( player, "gunboxc", "0|0" )
				MtxSetElementData ( player, "job", "none" )
				MtxSetElementData ( player, "jobtime", 0 )
				MtxSetElementData ( player, "club", "none" )
				MtxSetElementData ( player, "bonuspoints", 100 )
				MtxSetElementData ( player, "truckerlvl", 0 )
				MtxSetElementData ( player, "airportlvl", 0 )
				MtxSetElementData ( player, "bauarbeiterLVL", 0 )
				MtxSetElementData ( player, "farmerLVL", 0 )
				MtxSetElementData ( player, "contract", 0 )
				MtxSetElementData ( player, "socialState", "Neu auf "..Tables.servername.."" )
				MtxSetElementData ( player, "streetCleanPoints", 0 )
				MtxSetElementData ( player, "handyType", 1 )
				MtxSetElementData ( player, "handyCosts", 0 )
				MtxSetElementData ( player, "married", 0)
				MtxSetElementData ( player, "marwith", "none")
				
				_G[pname.."paydaytime"] = setTimer ( function ( p ) runAsync ( playingtime, p ) end, 60000, 0, player )
				
				MtxSetElementData ( player, "loggedin", 1 )
				MtxSetElementData ( player, "muted", 0 )
				MtxSetElementData ( player, "curplayingtime", 0 )
				MtxSetElementData ( player, "housex", 0 )
				MtxSetElementData ( player, "housey", 0 )
				MtxSetElementData ( player, "housez", 0 )
				MtxSetElementData ( player, "house", "none" )
				MtxSetElementData ( player, "handystate", "on" )
				MtxSetElementData ( player, "object", 0 )
				MtxSetElementData ( player, "ammoTyp", 0 )
				MtxSetElementData ( player, "curAmmoTyp", 0 )
				MtxSetElementData ( player, "nodmzone", 1 )
				MtxSetElementData ( player, "coins", 0 )
				MtxSetElementData ( player, "exp", 0 )
				MtxSetElementData ( player, "level", 0 )
				MtxSetElementData ( player, "Introtask", 1 )
				setElementData ( player,"inTactic",false)
				setElementData ( player, "hud", 1 )
				MtxSetElementData ( player, "Promo0" ,0 )
				MtxSetElementData ( player, "levelshop1", 0 )
				MtxSetElementData ( player, "levelshop2", 0 )
				MtxSetElementData ( player, "levelshop3", 0 )
				MtxSetElementData ( player, "levelshop4", 0 )
				MtxSetElementData ( player,"fahrschulonduty",false )
				MtxSetElementData ( player,"infahrpruefung",false )
				MtxSetElementData ( player,"inpruefung",false )
				MtxSetElementData ( player, "hatTheorieBestanden", false )
				
				if getElementData(player,"hud") then
					triggerClientEvent ( player, "showhudclient", player, "hud" )
				end

				bindKey ( player, "r", "down", reload )
				setPlayerWantedLevel ( player, 0 )
				MtxSetElementData ( player, "call", false )
				
				packageLoad ( player )
				achievload ( player )
				inventoryload ( player )
				elementDataSettings ( player )
				bonusLoad ( player )
				skillDataLoad ( player )
				createPlayerAFK ( player )
				loadPlayerStatisticsMySQL ( player )
				if not allPrivateCars[pname] then
					allPrivateCars[pname] = {}
				end

				local result = dbExec ( handler, "INSERT INTO userdata ( UID,Name,Skinid,Telefonnr,hud,Introtask,levelshop1,levelshop2,levelshop3,levelshop4,TacticKills,TacticTode) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)", id, pname, Skinid, Telefonnr,"1","1","0","0","0","0","0","0")
				if not result then
					outputDebugString ( "[userdata] Fehler beim Ausführen der Abfrage")
				else
					outputDebugString ("Daten für Spieler "..pname.." wurden angelegt!")
				end
				outputChatBox ( "Drücke F1, um das Hilfemenü zu öffnen!", player, 200, 200, 0 )
				
				local codeToCheck = promocode or "" 
                if codeToCheck == "ICE2025" then
                    MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + 1500 )
                    MtxSetElementData ( player, "bonuspoints", MtxGetElementData ( player, "bonuspoints" ) + 1700 )
                    setPremiumData (player, 7, 5)
                    MtxSetElementData ( player,"Promo0", 1 ) 
                    dbExec(handler, "UPDATE promotion SET Promo0=? WHERE Username=?", 1, pname)
                    outputChatBox("[Starterpaket Code] : Sie haben den Promocode eingegeben und erhalten 1500€ und 1700 Bonuspunkte dazu gibt es noch eine Woche Premium :)", player, 0, 255, 0)
                elseif #codeToCheck > 0 then
                    outputChatBox("FEHLER: Der eingegebene Promocode ist unbekannt.", player, 255, 128, 0)
                end
						
				loadAddictionsForPlayer ( player )
				spawnchange_func (player,"","noobspawn","")
				triggerJoinedPlayerTheTrams ( player )
				syncInvulnerablePedsWithPlayer ( player )
				playerLoginGangMembers ( player )
				spawnPlayer ( player, Spawnpos_X, Spawnpos_Y, Spawnpos_Z, Spawnrot_X, Skinid, SpawnInterior, 0 )
				setCameraTarget ( player, player )
				setElementFrozen ( player, false )
				toggleAllControls ( player, true )

				-- Intro-Kamerafahrt: einmalig direkt nach der Registrierung, zeigt
				-- per Kamera wichtige Orte der Stadt. Spieler waehrend der Fahrt
				-- einfrieren (siehe quest/intro_cutscene_client.lua fuer den Ablauf
				-- und "introCutsceneFinished" weiter unten fuers Auftauen).
				setElementFrozen ( player, true )
				triggerClientEvent ( player, "startIntroCutscene", player )
				setTimer ( function ( frozenPlayer )
					if isElement ( frozenPlayer ) and isElementFrozen ( frozenPlayer ) then
						setElementFrozen ( frozenPlayer, false )
						toggleAllControls ( frozenPlayer, true )
						triggerClientEvent ( frozenPlayer, "introCutsceneAbort", frozenPlayer )
						outputDebugString ( "[Intro] Wachhund hat "..getPlayerName ( frozenPlayer ).." aufgetaut.", 2 )
					end
				end, 360000, 1, player )
	end
end

addEvent ( "introCutsceneFinished", true )
addEventHandler ( "introCutsceneFinished", getRootElement(), function ()
	if isElement ( client ) then
		setElementFrozen ( client, false )
	end
end )

addEvent ( "register", true )
addEventHandler ( "register", getRootElement(), function ( player, passwort, bday, bmon, byear, geschlecht, promocode )
	runAsync ( register_func, player, passwort, bday, bmon, byear, geschlecht, promocode )
end )

local maleSkins = {0,1, 2, 7, 14, 15, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61, 62, 66, 67, 68, 71, 72, 73, 78, 79, 80, 81, 82, 83, 84, 94, 95, 96, 97, 98, 99, 100, 101, 108, 109, 110, 122, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146, 147, 153, 154, 155, 156, 158, 159, 160, 161, 162, 167, 168, 170, 171, 176, 177, 179, 180, 182, 183, 184, 185, 187, 189, 200, 202, 203, 204, 206, 209, 210, 212, 213, 217, 220, 221, 222, 223, 227, 228, 229, 230, 234, 235, 236, 239, 240, 241, 242, 249, 250, 252, 253, 255, 258, 259, 261, 262, 264, 269, 270, 271, 291, 302, 303, 306, 307, 310}
local femaleSkins = {9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 218, 219, 225, 226, 231, 232, 233, 238, 243, 244, 245, 246, 251, 256, 257, 263 }


function getRandomRegisterSkin ( player, sex )
	local testped = createPed ( 0, 9999, 9999, 9999 )
	if sex == 1 then
		local rnd = math.random ( 1, #femaleSkins )
		if setElementModel ( testped, femaleSkins[rnd] ) then
			destroyElement ( testped )
			return femaleSkins[rnd]
		else
			destroyElement ( testped )
			return getRandomRegisterSkin ( player, sex )
		end	
	else
		local rnd = math.random ( 1, #maleSkins )
		if setElementModel ( testped, maleSkins[rnd] ) then
			destroyElement ( testped )
			return maleSkins[rnd]
		else
			destroyElement ( testped )
			return getRandomRegisterSkin ( player, sex )
		end
	end
end


-- autologin: nur von regcheck_func gesetzt, wenn der Serial bereits fest mit
-- genau diesem Account verknuepft ist (siehe dort) - niemals von einem
-- Client-Event aus erreichbar, das "einloggen"-Event uebergibt diesen
-- Parameter nie mit.
function login_func ( player, passwort, autologin )
	if player == client then
		-- Beta-Sperre auch hier: "einloggen" ist client-ausloesbar und laesst
		-- sich damit an regcheck vorbei aufrufen. Steht NACH dem player==client
		-- Vergleich, weil hatBetaZugang per dbQueryCoro yieldet und "client"
		-- danach nicht mehr zuverlaessig ist.
		if event.isBeta and hatBetaZugang and not hatBetaZugang ( getPlayerSerial ( player ) ) then
			return
		end
		if MtxGetElementData ( player, "loggedin" ) == 0 then
			local pname = getPlayerName ( player )
		    local passwort = passwort

			local pwresult = dbQueryCoro ( "SELECT Passwort, AutologinAus FROM players WHERE UID=?", playerUID[pname] )
			if pwresult and pwresult[1] then
				-- AutologinAus=1 bedeutet "Autologin AN" (siehe regcheck_func) -
				-- der Client-Status "autologinAus" (fuer die Menue-Anzeige) ist
				-- also das Gegenteil davon: true nur, wenn Autologin AUS ist.
				local autologinAus = tonumber ( pwresult[1]["AutologinAus"] ) ~= 1
				pwresult = pwresult[1]["Passwort"]

				local passt, altesFormat
				if autologin then
					-- Serial wurde bereits in regcheck_func gegen genau diesen
					-- Account geprueft - kein Passwortvergleich noetig/moeglich
					-- (es wurde ja keins mitgeschickt).
					passt, altesFormat = true, false
				else
					passt, altesFormat = icePasswortPasst ( pwresult, passwort )
				end

				-- Stimmt das Kennwort und liegt es noch ungesalzen vor, wird es
				-- hier still auf das neue Format gehoben. Niemand muss dafuer
				-- sein Kennwort aendern.
				if passt and altesFormat then
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "players", "Passwort",
							 icePasswortErzeugen ( passwort, pname ), "UID", playerUID[pname] )
					outputLog ( pname.." - Kennwort auf das gesalzene Format umgestellt.", "pwchange" )
				end

				if passt then
									
					setPlayerLoggedIn ( pname )
				
					toggleAllControls ( player, true )

					MtxSetElementData ( player, "loggedin", 1 )
					MtxSetElementData ( player, "nodmzone", 0 )
					MtxSetElementData ( player, "autologinAus", autologinAus )
				
					local logtime = getRealTime()
					local year = logtime.year + 1900
					local month = logtime.month + 1
					local day = logtime.monthday
					local hour = logtime.hour
					local minute = logtime.minute
					
					local lastLoginInt = getSecTime ( 0 )
					local lastlogin = tostring(day.."."..month.."."..year..", "..hour..":"..minute)

					-- PremiumData ist eine DATETIME-Spalte; im Spiel wird weiterhin mit
					-- einem Unix-Zeitstempel gerechnet, daher hier direkt umrechnen.
					-- PremiumData und lastPremCarGive sind DATETIME-Spalten; im Spiel
					-- wird weiterhin mit Unix-Zeitstempeln gerechnet, daher hier direkt
					-- umrechnen.
					local result = dbQueryCoro ( "SELECT *, UNIX_TIMESTAMP(PremiumData) AS PremiumDataTS, UNIX_TIMESTAMP(lastPremCarGive) AS lastPremCarGiveTS from userdata WHERE UID = ?", playerUID[pname] )
					if not isElement ( player ) then return end
					if result then
						if result[1] then
							local dsatz = result[1]
							beginElementDataBatch ( player )
							local money = tonumber ( dsatz["Geld"] )
							MtxSetElementData ( player, "money", money )
							local fraktion = tonumber ( dsatz["Fraktion"] )
							MtxSetElementData ( player, "fraktion", fraktion )
							if fraktion > 0 then
								fraktionMembers[fraktion][player] = fraktion
								bindKey ( player, "y", "down", "chatbox", "t" )
								local f_player = player 
								local f_fraktion = fraktion
								setTimer(function()
									if isElement(f_player) and MtxGetElementData(f_player, "loggedin") == 1 then
										triggerClientEvent ( f_player, "syncPlayerList", f_player, fraktionMemberList[f_fraktion], fraktionMemberListInvite[f_fraktion] )
									end
								end, 2000, 1)
							end
							MtxSetElementData ( player, "busroute", 0 )
							local rang = tonumber ( dsatz["FraktionsRang"] )
							MtxSetElementData ( player, "rang", rang )					
							local admnlvl = tonumber ( dsatz["Adminlevel"] )
							MtxSetElementData ( player, "adminlvl", admnlvl )
							if admnlvl >= 1 then
								adminsIngame[player] = admnlvl
							end
							-- Unbedingt anlegen: an dieser Stelle ist "premium" noch gar
							-- nicht gesetzt (das macht erst checkPremium weiter unten),
							-- die Abfrage schlug also immer fehl und /mutedonator lief
							-- danach auf eine nil-Tabelle. Eine leere Tabelle je Spieler
							-- kostet nichts.
							donatorMute[player] = {}
							
							bindKey(player, "c", "down", Jump)
							bindKey(player, "lshift", "down", speedup)
							
							MtxSetElementData ( player, "lastSocialChange", tonumber ( dsatz["lastSocialChange"] ) )
							MtxSetElementData ( player, "lastNumberChange", tonumber ( dsatz["lastNumberChange"] ) )
							MtxSetElementData ( player, "lastPremCarGive", tonumber ( dsatz["lastPremCarGiveTS"] ) or 0 )
							MtxSetElementData ( player, "PremiumCars", tonumber ( dsatz["PremiumCars"] ) )
							MtxSetElementData ( player, "spawnpos_x", tonumber ( dsatz["Spawnpos_X"] ) )
							MtxSetElementData ( player, "spawnpos_y", tonumber ( dsatz["Spawnpos_Y"] ) )
							MtxSetElementData ( player, "spawnpos_z", tonumber ( dsatz["Spawnpos_Z"] ) )
							MtxSetElementData ( player, "spawnrot_x", tonumber ( dsatz["Spawnrot_X"] ) )
							MtxSetElementData ( player, "spawnint", tonumber ( dsatz["SpawnInterior"] ) )
							MtxSetElementData ( player, "spawndim", tonumber ( dsatz["SpawnDimension"] ) )
							MtxSetElementData ( player, "playingtime", tonumber ( dsatz["Spielzeit"] ) )
							MtxSetElementData ( player, "curcars", tonumber ( dsatz["CurrentCars"] ) )
							local maximumcars = tonumber ( dsatz["MaximumCars"] )
							MtxSetElementData ( player, "maxcars",maximumcars  )
							local curcars = 0
							local offerOnCar = false
							local vehresult = dbQueryCoro ( "SELECT ??, ?? FROM ?? WHERE ??=?", "Special", "Slot", "vehicles", "UID", playerUID[pname] )
							for i=1, maximumcars do
								MtxSetElementData ( player, "carslot"..i, 0 )
							end
							if vehresult and vehresult[1] then
								for i = 1, #vehresult do
									local id = tonumber ( vehresult[i]["Slot"] )
									local carvalue = tonumber ( vehresult[i]["Special"] )
									if carvalue == 2 then
										MtxSetElementData ( player, "yachtImBesitz", true )
									end
									if not carvalue then
									
										carvalue = 0
									else
										if carvalue == 2 then
											carvalue = 2
										else
											carvalue = 1
										end
										curcars = curcars + 1
									end
									MtxSetElementData ( player, "carslot"..id, carvalue )
								end
							end
							MtxSetElementData ( player, "curcars", curcars )
							
							MtxSetElementData ( player, "deaths", tonumber ( dsatz["Tode"] ) )
							MtxSetElementData ( player, "kills", tonumber ( dsatz["Kills"] ) )
							setElementData ( player, "TacticKills", tonumber ( dsatz["TacticKills"] ) )
							setElementData ( player, "TacticTode", tonumber ( dsatz["TacticTode"] ) )
							MtxSetElementData ( player, "gangwarlosses", tonumber ( dsatz["GangwarVerloren"] ) )
							MtxSetElementData ( player, "gangwarwins", tonumber ( dsatz["GangwarGewonnen"] ) )
							MtxSetElementData ( player, "jailtime", tonumber ( dsatz["Knastzeit"] ) )
							MtxSetElementData ( player, "prison", tonumber ( dsatz["Prison"] ) )
							MtxSetElementData ( player, "bail", tonumber ( dsatz["Kaution"] )  )
							MtxSetElementData ( player, "heaventime", tonumber ( dsatz["Himmelszeit"] ) )
						    MtxSetElementData ( player, "Promo0",getPlayerData("promotion","Username",pname,"Promo0"))
							setElementData ( player, "hud", tonumber ( dsatz["hud"] ) )
							MtxSetElementData ( player, "exp", tonumber ( dsatz["exp"] ) )
							MtxSetElementData ( player, "level", tonumber ( dsatz["level"] ) )
							MtxSetElementData ( player, "Introtask", tonumber ( dsatz["Introtask"] ) )
							MtxSetElementData ( player, "levelshop1", tonumber ( dsatz["levelshop1"] ) )
							MtxSetElementData ( player, "levelshop2", tonumber ( dsatz["levelshop2"] ) )
							MtxSetElementData ( player, "levelshop3", tonumber ( dsatz["levelshop3"] ) )
							MtxSetElementData ( player, "levelshop4", tonumber ( dsatz["levelshop4"] ) )
							MtxSetElementData(player,"fahrschulonduty",false)
							MtxSetElementData(player,"infahrpruefung",false)
							MtxSetElementData(player,"inpruefung",false)
							-- War bisher nicht dabei: wurde beim Login zwar auf false
							-- zurueckgesetzt (siehe oben), aber nie aus der DB neu geladen -
							-- die Theorie-Pruefung ging dadurch bei jedem Login verloren.
							MtxSetElementData(player,"hatTheorieBestanden", tonumber(dsatz["hatTheorieBestanden"]) == 1)

							local resulthouse = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "ID", "houses", "UID", playerUID[pname] )
							local Hausschluessel = resulthouse[1] and resulthouse[1]["ID"] or false
							local key = tonumber ( dsatz["Hausschluessel"] )
							if Hausschluessel then
								MtxSetElementData ( player, "housekey", tonumber ( Hausschluessel ) )
							elseif key <= 0 then
								MtxSetElementData ( player, "housekey", key )
							else
								MtxSetElementData ( player, "housekey", 0 )
							end
							
							if getPedSkin(player) == 0 then
								local clothesRes = dbQueryCoro ( "SELECT * FROM clothes WHERE Name = ?", pname )
								local c = clothesRes and clothesRes[1]
								if c then
									if c["shirt1"] ~= "none" and c["shirt2"] ~= "none" then
										addPedClothes ( player, c["shirt1"], c["shirt2"], 0 )
									end
									if c["hair1"] ~= "none" and c["hair2"] ~= "none" then
										addPedClothes ( player, c["hair1"], c["hair2"], 1 )
									end
									if c["hose1"] ~= "none" and c["hose2"] ~= "none" then
										addPedClothes ( player, c["hose1"], c["hose2"], 2 )
									end
									if c["schuhe1"] ~= "none" and c["schuhe2"] ~= "none" then
										addPedClothes ( player, c["schuhe1"], c["schuhe2"], 3 )
									end
									if c["Hut1"] ~= "none" and c["Hut2"] ~= "none" then
										addPedClothes ( player, c["Hut1"], c["Hut2"], 16 )
									end
									if c["Bandana1"] ~= "none" and c["Bandana2"] ~= "none" then
										addPedClothes ( player, c["Bandana1"], c["Bandana2"], 15 )
									end
								end
							end
								
							local marRes = dbQueryCoro ( "SELECT pl1, pl2, nachname, trauzeuge FROM marry WHERE pl1=? OR pl2=?", pname, pname )
							local m = marRes and marRes[1]
							if m and m["pl1"] == pname then
								MtxSetElementData(player,"married",1)
								MtxSetElementData(player,"marwith", m["pl2"])
								MtxSetElementData(player,"nachname", m["nachname"])
								MtxSetElementData(player,"trauzeuge", m["trauzeuge"] or "")
							elseif m and m["pl2"] == pname then
								MtxSetElementData(player,"married",1)
								MtxSetElementData(player, "marwith", m["pl1"])
								-- Hier stand frueher m["pl1"] - der zweite Partner bekam also den
								-- NAMEN des Partners als Nachnamen statt des gemeinsamen Nachnamens.
								MtxSetElementData(player, "nachname", m["nachname"])
								MtxSetElementData(player, "trauzeuge", m["trauzeuge"] or "")
							else
								MtxSetElementData(player,"married",0)
								MtxSetElementData(player,"marwith","none")
								MtxSetElementData(player, "nachname","none")
								MtxSetElementData(player, "trauzeuge","")
							end
							
							-- Adminduty die beim einloggen auf false gesetzt werden
							if MtxGetElementData(player,"adminduty") == true then
								MtxSetElementData(player,"adminduty",false)
							end
							
				
							MtxSetElementData ( player, "hitglocke", tonumber ( dsatz["Hitglocke"] ) )
							MtxSetElementData ( player, "bizkey", tonumber ( dsatz["Bizschluessel"] ) )
							MtxSetElementData ( player, "bankmoney", tonumber ( dsatz["Bankgeld"] ) )
							MtxSetElementData ( player, "drugs", tonumber ( dsatz["Drogen"] ) )
							MtxSetElementData ( player, "skinid", tonumber ( dsatz["Skinid"] ) )
							MtxSetElementData ( player, "carlicense", tonumber ( dsatz["Autofuehrerschein"] ) )
							MtxSetElementData ( player, "bikelicense", tonumber ( dsatz["Motorradtfuehrerschein"] ) )
							MtxSetElementData ( player, "lkwlicense", tonumber ( dsatz["LKWfuehrerschein"] ) )
							MtxSetElementData ( player, "helilicense", tonumber ( dsatz["Helikopterfuehrerschein"] ) )
							MtxSetElementData ( player, "planelicensea", tonumber ( dsatz["FlugscheinKlasseA"] ) )
							MtxSetElementData ( player, "planelicenseb", tonumber ( dsatz["FlugscheinKlasseB"] ) )
							MtxSetElementData ( player, "motorbootlicense", tonumber ( dsatz["Motorbootschein"] ) )
							MtxSetElementData ( player, "segellicense", tonumber ( dsatz["Segelschein"] ) )
							MtxSetElementData ( player, "fishinglicense", tonumber ( dsatz["Angelschein"] ) )
							MtxSetElementData ( player, "wanteds", tonumber ( dsatz["Wanteds"] ) )
							MtxSetElementData ( player, "stvo_punkte", tonumber ( dsatz["StvoPunkte"] ) )
							MtxSetElementData ( player, "gunlicense", tonumber ( dsatz["Waffenschein"] ) )
							MtxSetElementData ( player, "perso", tonumber ( dsatz["Perso"] ) )
							MtxSetElementData ( player, "boni", tonumber ( dsatz["Boni"] ) )
							MtxSetElementData ( player, "pdayincome", tonumber ( dsatz["PdayIncome"] ) )
							MtxSetElementData ( player, "telenr", tonumber ( dsatz["Telefonnr"] ) )
							MtxSetElementData ( player, "warns", getPlayerWarnCount ( pname ) )
							MtxSetElementData ( player, "gunboxa", dsatz["Gunbox1"] )
							MtxSetElementData ( player, "gunboxb", dsatz["Gunbox2"] )
							MtxSetElementData ( player, "gunboxc", dsatz["Gunbox3"] )
							MtxSetElementData ( player, "job", dsatz["Job"] )
							MtxSetElementData ( player, "jobtime", dsatz["Jobtime"] )
							MtxSetElementData ( player, "club", dsatz["Club"] )
							MtxSetElementData ( player, "bonuspoints", tonumber ( dsatz["Bonuspunkte"] ) )
							MtxSetElementData ( player, "kuerbisse", tonumber ( dsatz["kuerbisse"] ) )
							local skill = tonumber ( dsatz["Truckerskill"] )
							if not skill then
								skill = 0
							end
							local ArmyPermissions = dsatz["ArmyPermissions"]
							for i = 1, 10 do
								MtxSetElementData ( player, "armyperm"..i, tonumber ( gettok ( ArmyPermissions, i, string.byte( '|' ) ) ) )
							end
							MtxSetElementData ( player, "truckerlvl", skill )
							MtxSetElementData ( player, "coins", tonumber ( dsatz["Coins"] ) )
							MtxSetElementData ( player, "airportlvl", tonumber ( dsatz["AirportLevel"] ) )
							MtxSetElementData ( player, "farmerLVL", tonumber ( dsatz["farmerLVL"] ) )
							MtxSetElementData ( player, "bauarbeiterLVL", tonumber ( dsatz["bauarbeiterLVL"] ) )
							MtxSetElementData ( player, "contract", tonumber ( dsatz["Contract"] ) )
							MtxSetElementData ( player, "Paket", tonumber ( dsatz["PremiumPaket"] ) )
							-- PremiumDataTS ist UNIX_TIMESTAMP(PremiumData) aus der Abfrage
							-- oben; NULL (kein Premium) wird zu 0.
							MtxSetElementData ( player, "PremiumData", tonumber ( dsatz["PremiumDataTS"] ) or 0 )
							MtxSetElementData ( player, "socialState", dsatz["SocialState"] )
							if tonumber ( dsatz["SocialState"] ) then
								if tonumber ( dsatz["SocialState"] ) == 0 then
									MtxSetElementData ( player, "socialState", "Neu auf "..Tables.servername.."" )
								end
							end
							MtxSetElementData ( player, "streetCleanPoints", tonumber ( dsatz["StreetCleanPoints"] ) )
							
							local handyString = dsatz["Handy"] 
							local v1, v2
							v1 = tonumber ( gettok ( handyString, 1, string.byte ( '|' ) ) )
							v2 = tonumber ( gettok ( handyString, 2, string.byte ( '|' ) ) )
							MtxSetElementData ( player, "handyType", v1 )
							MtxSetElementData ( player, "handyCosts", v2 )
						

							loadAddictionsForPlayer ( player )
							
							
							MtxSetElementData ( player, "housex", 0 )
							MtxSetElementData ( player, "housey", 0 )
							MtxSetElementData ( player, "housez", 0 )
							MtxSetElementData ( player, "house", "none" )
							MtxSetElementData ( player, "curplayingtime", 0 )
							MtxSetElementData ( player, "handystate", "on" )
							MtxSetElementData ( player, "call", false )
							setElementData(player,"inTactic",false)
							
					  setTimer(function()
						runAsync(function()
							if not isElement(player) then return end
							packageLoad ( player )
							achievload ( player )
							inventoryload ( player )
							elementDataSettings ( player )
							bonusLoad ( player )
							skillDataLoad ( player )
							createPlayerAFK ( player )
							loadPlayerStatisticsMySQL ( player )
							setMaximumCarsForPlayer ( player )
							if not allPrivateCars[pname] then
								allPrivateCars[pname] = {}
							end
							
							_G[pname.."paydaytime"] = setTimer ( function ( p ) runAsync ( playingtime, p ) end, 60000, 0, player )

							flushElementDataBatch ( player )

							RemoteSpawnPlayer ( player )
							MtxSetElementData ( player, "muted", 0 )
							triggerClientEvent ( player, "DisableLoginWindow", getRootElement() )
							triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast dich\nerfolgreich eingeloggt!\nDrücke F1, um das\nHilfemenü zu\nöffnen!", 5000, 0, 255, 0 )
							outputDebugString ("Spieler "..pname.." wurde eingeloggt, IP: "..getPlayerIP(player))
							MtxSetElementData ( player, "loggedin", 1 )
							triggerJoinedPlayerTheTrams ( player )

							if MtxGetElementData ( player, "stvo_punkte" ) >= 15 then			-- SearchSTVO
								MtxSetElementData ( player, "carlicense", 0 )
								MtxSetElementData ( player, "stvo_punkte", 0 )
								dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Autofuehrerschein", 0, "UID", playerUID[pname] )
								outputChatBox ( "Wegen deines schlechten Fahrverhaltens wurde dir dein Führerschein abgenommen!", player, 125, 0, 0 )
							end
							
							local objektResult = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Objekt", "inventar", "UID", playerUID[pname] )
							MtxSetElementData ( player, "object", objektResult and objektResult[1] and tonumber ( objektResult[1]["Objekt"] ) )

							checkmsgs ( player )

							blacklistLogin ( pname )
							
							if MtxGetElementData(player,"Introtask") ~= 7 then
								outputChatBox("Folgen Sie dem Aufgabensystem, um Geschenke zu erhalten. Kaufen Sie keinen Artikel, bevor Sie das Aufgabensystem abgeschlossen haben!",player,255,255,255)
							end
							
							if isElement ( houses["pickup"][getPlayerName(player)] ) then
								local x, y, z = getElementPosition (houses["pickup"][getPlayerName(player)])
								createBlip ( x, y, z, 31, 2, 255, 0, 0, 255, 0, 99999, player )
							end
							
							local serial = getPlayerSerial ( player )
							
							dbExec ( handler, "UPDATE ?? SET ??=?, ??=?, ??=? WHERE ??=?", "players", "Last_login", lastlogin, "LastLogin", lastLoginInt, "Serial", serial, "UID", playerUID[pname] )
					
							local resultlogout = dbQueryCoro ( "SELECT ??, ?? FROM ?? WHERE ??=?", "Position", "Waffen", "logout", "UID", playerUID[pname] )
							if resultlogout and resultlogout[1] then
								local position = resultlogout[1]["Position"]
								if position then
									local weapons = resultlogout[1]["Waffen"]
									dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "logout", "UID", playerUID[pname] )
									for i = 1, 12 do
										local wstring = gettok ( weapons, i, string.byte( '|' ) )
										if wstring then
											if wstring then
												if #wstring >= 3 then
													local weapon = tonumber ( gettok ( wstring, 1, string.byte( ',' ) ) )
													local ammo = tonumber ( gettok ( wstring, 2, string.byte( ',' ) ) )
													giveWeapon ( player, weapon, ammo, true )
												end
											end
										end
									end
									if position ~= "false" then
										local x = tonumber ( gettok ( position, 1, string.byte( '|' ) ) )
										local y = tonumber ( gettok ( position, 2, string.byte( '|' ) ) )
										local z = tonumber ( gettok ( position, 3, string.byte( '|' ) ) )
										local int = tonumber ( gettok ( position, 4, string.byte( '|' ) ) )
										local dim = tonumber ( gettok ( position, 5, string.byte( '|' ) ) )
										setTimer ( setElementInterior, 1000, 1, player, int )
										setTimer ( setElementDimension, 1000, 1, player, dim )
										setTimer ( setElementPosition, 1000, 1, player, x, y, z )
									end
								end
							end
							getMailsForClient_func ( pname )
							playerLoginGangMembers ( player )
							syncInvulnerablePedsWithPlayer ( player )
							-- REIHENFOLGE IST WICHTIG: checkPremium setzt erst die
							-- Elementdata "premium". giveFreePremiumCar prueft genau
							-- die und tat vorher (davor aufgerufen) nie etwas.
							checkPremium ( player )
							giveFreePremiumCar ( player )
						end)
						end, 50, 1)
						else
							triggerClientEvent ( player, "infobox_start", getRootElement(), "Der Spieler\nexistiert nicht!", 5000, 255, 0, 0 )	
						end
					else
						outputDebugString ( "Einloggen klappt nicht!" )
					end		
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "Ungueltiges Passwort -\nüberpruefe\ndeine Eingabe\noder melde dich\nim Forum.", 5000, 255, 0, 0 )	
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "Der Spieler\nexistiert nicht!", 5000, 255, 0, 0 )	
			end
			if player and isElement ( player ) then
				bindKey ( player, "r", "down", reload )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "Der Spieler\nist einloggt!", 5000, 255, 0, 0 )	
		end
    end
end

addEvent ( "einloggen", true )
addEventHandler ( "einloggen", getRootElement(), function ( player, passwort )
	runAsync ( login_func, player, passwort )
end )

function achievload ( player )

	local pname = getPlayerName ( player )
	local result = dbQueryCoro ( "SELECT * from achievments WHERE UID = ?", playerUID[pname] )
	local dsatz = nil
	if result then
		if result[1] then
			dsatz = result[1]
		else
			outputDebugString ( "Spieler in Achievment-Datenbank nicht gefunden!" )
			return false
		end
	end
	MtxSetElementData ( player, "schlaflosinsa", dsatz["SchlaflosInSA"] )
	MtxSetElementData ( player, "gunloads", dsatz["Waffenschieber"] )
	MtxSetElementData ( player, "angler_achiev", dsatz["Angler"] )
	MtxSetElementData ( player, "licenses_achiev", dsatz["Lizensen"] )
	MtxSetElementData ( player, "carwahn_achiev", dsatz["Fahrzeugwahn"] )
	MtxSetElementData ( player, "collectr_achiev", dsatz["DerSammler"] )
	MtxSetElementData ( player, "rl_achiev", dsatz["ReallifeWTF"] )
	MtxSetElementData ( player, "own_foots", dsatz["EigeneFuesse"] )
	MtxSetElementData ( player, "kingofthehill_achiev", dsatz["KingOfTheHill"] )
	MtxSetElementData ( player, "thetruthisoutthere_achiev", dsatz["TheTruthIsOutThere"] )
	MtxSetElementData ( player, "silentassasin_achiev", dsatz["SilentAssasin"] )
	MtxSetElementData ( player, "highwaytohell_achiev", dsatz["HighwayToHell"] )
	
	MtxSetElementData ( player, "revolverheld_achiev", tonumber ( dsatz["Revolverheld"] ) )
	MtxSetElementData ( player, "chickendinner_achiev", tonumber ( dsatz["ChickenDinner"] ) )
	MtxSetElementData ( player, "nichtsgehtmehr_achiev", tonumber ( dsatz["NichtGehtMehr"] ) )
	MtxSetElementData ( player, "highscore_achiev", tonumber ( dsatz["highscore"] ) == 1 )
	MtxSetElementData ( player, "TactickillCoin", tonumber ( dsatz["TactickillCoin"] ) == 1 )
	
	local dstring = dsatz["LookoutsA"]
	triggerClientEvent ( player, "hideLookoutMarkers", player, dstring )
	local count = 0
	for i = 1, 10 do
		if tonumber ( gettok ( dstring, i, string.byte ( '|' ) ) ) == 1 then
			count = count + 1
		end
	end
	MtxSetElementData ( player, "viewpoints", count )
	loadHorseShoesFound ( player, pname )
	loadPlayingTimeForSleeplessAchiev ( player, pname )
end


function inventoryload ( player )

	local pname = getPlayerName ( player )
	MtxSetElementData ( player, "playerid", playerUID[pname] )

	local dsatz
	local result = dbQueryCoro ( "SELECT * from inventar WHERE UID = ?", playerUID[pname] )
	if not result or not result[1] then
		dbExec ( handler, "INSERT INTO inventar (UID) VALUES (?)", playerUID[pname] )
		result = dbQueryCoro ( "SELECT * from inventar WHERE UID = ?", playerUID[pname] )
	end
	dsatz = result[1]
	if dsatz["Wuerfel"] then
		MtxSetElementData ( player, "dice", tonumber ( dsatz["Wuerfel"] ) )
	else
		MtxSetElementData ( player, "dice", 0 )
	end
	MtxSetElementData ( player, "flowerseeds", tonumber ( dsatz["Blumensamen"] ) )
	MtxSetElementData ( player, "food1", tonumber ( dsatz["Essensslot1"] ) )
	MtxSetElementData ( player, "food2", tonumber ( dsatz["Essensslot2"] ) )
	MtxSetElementData ( player, "food3", tonumber ( dsatz["Essensslot3"] ) )
	MtxSetElementData ( player, "zigaretten", tonumber ( dsatz["Zigaretten"] ) )
	MtxSetElementData ( player, "mats", tonumber ( dsatz["Materials"] ) )
	MtxSetElementData ( player, "benzinkannister", tonumber ( dsatz["Benzinkanister"] ) )
	MtxSetElementData ( player, "fruitNotebook", tonumber ( dsatz["FruitNotebook"] ) )
	MtxSetElementData ( player, "casinoChips", tonumber ( dsatz["Chips"] ) )
	MtxSetElementData ( player, "medikits", tonumber ( dsatz["Medikit"] ) )
	MtxSetElementData ( player, "repairkits", tonumber ( dsatz["Repairkit"] )	)
	MtxSetElementData ( player, "kuerbisse", tonumber ( dsatz["kuerbisse"] ) )
	-- X-MAS --
    MtxSetElementData ( player, "presents", tonumber ( dsatz["Geschenke"] ) )
	-- X-MAS --
end


	
function datasave (  quitReason, reason )

	if clanMembers[source] then
		clanMembers[source] = nil
	end
	if ticketPermitted[source] then
		ticketPermitted[source] = nil
	end
	local pname = getPlayerName ( source )
	removePlayerFromLoggedIn ( pname )
	if MtxGetElementData ( source, "loggedin" ) == 1 then
		playerDisconnectGangMembers ( source )
		pname = getPlayerName ( source )
		local frak = MtxGetElementData(source,"fraktion")
		if fraktionMembers[frak] then
			fraktionMembers[frak][source] = nil
		end
		adminsIngame[source] = nil
		if MtxGetElementData ( source, "shootingRanchGun" ) then
		elseif quitReason and reason ~= "Ausgeloggt." then
			if MtxGetElementData ( source, "wanteds" ) >= 1 and MtxGetElementData ( source, "jailtime" ) == 0 and MtxGetElementData ( source, "prison" ) == 0 then
				local x, y, z = getElementPosition ( source )
				local copShape = createColSphere ( x, y, z, 20 )
				local elementsInCopSphere = getElementsWithinColShape ( copShape, "player" )
				destroyElement ( copShape )
				for i=1, #elementsInCopSphere do
					local cPlayer = elementsInCopSphere[i]
					if ( isOnDuty ( cPlayer ) or isArmy ( cPlayer ) ) and cPlayer ~= source then
						local wanteds = MtxGetElementData ( source, "wanteds" )
						MtxSetElementData ( source, "wanteds", 0 )
						MtxSetElementData ( source, "jailtime", wanteds * math.ceil(jailtimeperwanted*1.4) + MtxGetElementData ( source, "jailtime" ) )
						local wantedCost = 100*wanteds*(wanteds*.5)
						MtxSetElementData ( source, "money", MtxGetElementData ( source, "money" ) - wantedCost )
						if MtxGetElementData ( source, "money" ) < 0 then
							MtxSetElementData ( source, "money", 0 )
						end
						outputChatBox ( "Der Gesuchte "..getPlayerName ( source ).." ist offline gegangen - er wird beim nächsten Einloggen im Knast sein.", cPlayer, 0, 125, 0 )
						MtxSetElementData ( cPlayer, "AnzahlEingeknastet", MtxGetElementData ( cPlayer, "AnzahlEingeknastet" ) + 1 )
						MtxSetElementData ( source, "AnzahlImKnast", MtxGetElementData ( source, "AnzahlImKnast" ) + 1 )
						offlinemsg ( "Du bist für "..(wanteds * math.ceil(jailtimeperwanted*1.2)).." Minuten im Gefängnis (Offlineflucht?)", "Server", getPlayerName(source) )
						break
					end
				end
			end
			if shootingRanchGun[source] then
				takeWeapon ( source, shootingRanchGun[source] )
			end
			shootingRanchGun[source] = {}
			local curWeaponsForSave = "|"
			for i = 1, 12 do
				if i ~= 10 and i ~= 12 then
					local weapon = getPedWeapon ( source, i )
					local ammo = getPedTotalAmmo ( source, i )
					if weapon and ammo then
						if weapon > 0 and ammo > 0 then
							if #curWeaponsForSave <= 40 then
								curWeaponsForSave = curWeaponsForSave..weapon..","..ammo.."|"
							end
						end
					end
				end
			end
			if #curWeaponsForSave > 1 then
				dbExec ( handler, "DELETE FROM logout WHERE UID = ?", playerUID[pname] )
				dbExec ( handler, "INSERT INTO logout (Position, Waffen, UID) VALUES (?,?,?)", 'false', curWeaponsForSave, playerUID[pname]) 
			end
		end
		hangup ( source )
		datasave_remote ( source )
		if MtxGetElementData ( source, "isInArea51Mission" ) then
			removeArea51Bots ( pname )
		end
		local veh = getPedOccupiedVehicle ( source )
		if veh then
			if isElement ( veh ) then
				if getElementModel(veh) == 502 then
					destroyElement ( veh )
				end
			end
		end
		if isTimer ( _G[pname.."paydaytime"] ) then killTimer ( _G[pname.."paydaytime"] ) end
		clearDataSettings ( source )
	end
end
addEventHandler ("onPlayerQuit", getRootElement(), datasave )

function elementDataSettings ( player )

	local pname = getPlayerName ( player )
	MtxSetElementData ( player, "objectToPlace", false )
	MtxSetElementData ( player, "growing", false )
	MtxSetElementData ( player, "isInRace", false )
	MtxSetElementData ( player, "callswithpolice", false )
	MtxSetElementData ( player, "callswithmedic", false )
	MtxSetElementData ( player, "callswithmechaniker", false )
	MtxSetElementData ( player, "isLive", false )
	MtxSetElementData ( player, "isInArea51Mission", false )
	MtxSetElementData ( player, "armingBomb", false )
	MtxSetElementData ( player, "tied", true )
	MtxSetElementData ( player, "hasBomb", false )
	MtxSetElementData ( player, "wanzen", false )
	------------------
	
	local Weapon_Settings = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Spezial", "inventar", "UID", playerUID[pname] )
	local shads = {}
	
	if not Weapon_Settings or not Weapon_Settings[1] then
		for i = 1, 6 do
			shads[i] = 0
		end
	else
		for i = 1, 6 do
			shads[i] = tonumber ( gettok ( Weapon_Settings[1]["Spezial"], i, string.byte( '|' ) ) )
		end
	end
	
		
	----------------	
	local ArmyPermissions = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "ArmyPermissions", "userdata", "UID", playerUID[pname] )
	if ArmyPermissions and ArmyPermissions[1] then
		ArmyPermissions = ArmyPermissions[1]["ArmyPermissions"]
		for i = 1, 10 do
			local int = tonumber ( gettok ( ArmyPermissions, i, string.byte( '|' ) ) )
			if int then
				MtxSetElementData ( player, "armyperm"..i, int )
			else
				MtxSetElementData ( player, "armyperm"..i, 0 )
			end
		end
	else
		for i = 1, 10 do
			MtxSetElementData ( player, "armyperm"..i, 0 )
		end
	end
end

function saveArmyPermissions ( player )

	local pname = getPlayerName ( player )
	local empty = ""
	for i = 1, 10 do
		empty = empty.."|"..MtxGetElementData ( player, "armyperm"..i )
	end
	empty = empty.."|"
	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "ArmyPermissions", empty, "UID", playerUID[pname] )
end


function SaveCarData ( player )

	local pname = getPlayerName ( player )
	dbExec ( handler, "UPDATE ?? SET ??=?, ??=?, ??=? WHERE ??=?", "userdata", "Geld", MtxGetElementData ( player, "money" ), "CurrentCars", MtxGetElementData ( player, "curcars" ), "MaximumCars", MtxGetElementData ( player, "maxcars" ), "UID", playerUID[pname] )
end

function datasave_remote ( player )

	local source = player
	if tonumber ( MtxGetElementData ( source, "loggedin" )) == 1 then
		local pname = getPlayerName ( source )
		local fields = "SET"
		local params = {}
		fields = fields.." Geld = ?"
		params[#params+1] = math.abs ( math.floor ( MtxGetElementData ( source, "money" ) ) )
		fields = fields..", Fraktion = ?"
		params[#params+1] = math.abs ( math.floor ( MtxGetElementData ( source, "fraktion") ) )
		fields = fields..", FraktionsRang = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "rang" ) )
		fields = fields..", Spielzeit = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "playingtime" ) )
		fields = fields..", Adminlevel = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "adminlvl" ) )
		fields = fields..", Hitglocke = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "hitglocke" ) )
		fields = fields..", CurrentCars = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "curcars" ) )
		fields = fields..", MaximumCars = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "maxcars" ) )
		fields = fields..", Knastzeit = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "jailtime" ) )
		fields = fields..", Prison = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "prison" ) )
		fields = fields..", Kaution = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "bail" ) )
		fields = fields..", Himmelszeit = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "heaventime" ) )
		fields = fields..", Hausschluessel = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "housekey" ) )
		fields = fields..", Bankgeld = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "bankmoney" ) )
		fields = fields..", Drogen = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "drugs" ) )
		fields = fields..", Skinid = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "skinid" ) )
		fields = fields..", Wanteds = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "wanteds" ) )
		fields = fields..", StvoPunkte = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "stvo_punkte" ) )
		fields = fields..", Boni = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "boni" ) )
		fields = fields..", PdayIncome = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "pdayincome" ) )
		fields = fields..", Warns = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "warns" ) )
		fields = fields..", Gunbox1 = ?"
		params[#params+1] = MtxGetElementData ( source, "gunboxa" )
		fields = fields..", Gunbox2 = ?"
		params[#params+1] = MtxGetElementData ( source, "gunboxb" )
		fields = fields..", Gunbox3 = ?"
		params[#params+1] = MtxGetElementData ( source, "gunboxc" )
		fields = fields..", Job = ?"
		params[#params+1] = MtxGetElementData ( source, "job" )
		fields = fields..", Jobtime = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "jobtime" ) )
		fields = fields..", Club = ?"
		params[#params+1] = MtxGetElementData ( source, "club" )
		fields = fields..", Bonuspunkte = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "bonuspoints" ) )
		local skill = tonumber ( MtxGetElementData ( source, "truckerlvl" ) ) or 0
		fields = fields.." ,Coins = ?"
		params[#params+1] = MtxGetElementData ( source, "coins" )
		fields = fields..", Truckerskill = ?"
		params[#params+1] = skill
		fields = fields..", farmerLVL = ?"
		params[#params+1] = MtxGetElementData ( source, "farmerLVL" )
		fields = fields..", bauarbeiterLVL = ?"
		params[#params+1] = MtxGetElementData ( source, "bauarbeiterLVL" )
		fields = fields..", AirportLevel = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "airportlvl" ) )
		fields = fields..", Contract = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "contract" ) )
		fields = fields..", SocialState = ?"
		params[#params+1] = MtxGetElementData ( source, "socialState")
		fields = fields..", StreetCleanPoints = ?"
		params[#params+1] = math.floor ( MtxGetElementData ( source, "streetCleanPoints" ) )
		fields = fields..", hud = ?"
		params[#params+1] = math.floor ( getElementData ( source, "hud" ) )
		fields = fields..", PremiumPaket = ?"
		params[#params+1] = MtxGetElementData ( source, "Paket" )
		-- DATETIME-Spalte: 0 (kein Premium) muss als NULL landen, sonst stuende
		-- dort 1970-01-01. NULLIF macht aus der 0 ein NULL, FROM_UNIXTIME(NULL)
		-- ist ebenfalls NULL.
		fields = fields..", PremiumData = FROM_UNIXTIME(NULLIF(?,0))"
		params[#params+1] = MtxGetElementData ( source, "PremiumData" )
		fields = fields..", lastSocialChange = ?"
		params[#params+1] = MtxGetElementData ( source, "lastSocialChange" )
		fields = fields..", lastNumberChange = ?"
		params[#params+1] = MtxGetElementData ( source, "lastNumberChange" )
		-- Ebenfalls DATETIME - siehe PremiumData weiter oben.
		fields = fields..", lastPremCarGive = FROM_UNIXTIME(NULLIF(?,0))"
		params[#params+1] = MtxGetElementData ( source, "lastPremCarGive" )
		fields = fields..", PremiumCars = ?"
		params[#params+1] = MtxGetElementData ( source, "PremiumCars" )
		fields = fields..", exp = ?"
		params[#params+1] = MtxGetElementData ( source, "exp" )
		fields = fields..", level = ?"
		params[#params+1] = MtxGetElementData ( source, "level" )
		fields = fields..", Introtask = ?"
		params[#params+1] = MtxGetElementData ( source, "Introtask" )
		fields = fields..", levelshop1 = ?"
		params[#params+1] = MtxGetElementData ( source, "levelshop1" )
		fields = fields..", levelshop2 = ?"
		params[#params+1] = MtxGetElementData ( source, "levelshop2" )
		fields = fields..", levelshop3 = ?"
		params[#params+1] = MtxGetElementData ( source, "levelshop3" )
		fields = fields..", levelshop4 = ?"
		params[#params+1] = MtxGetElementData ( source, "levelshop4" )
		fields = fields..", TacticKills = ?"
		params[#params+1] = getElementData ( source, "TacticKills" )
		fields = fields..", TacticTode = ?"
		params[#params+1] = getElementData ( source, "TacticTode" )
		local v1 = "|"..MtxGetElementData ( source, "handyType" ).."|"
		local v2 = MtxGetElementData ( source, "handyCosts" ).."|"
		local v3 = v1..v2
		fields = fields..", Handy = ?"
		params[#params+1] = v3
		params[#params+1] = playerUID[pname]
		dbExec ( handler, "UPDATE userdata "..fields.." WHERE UID=?", unpack ( params ) )
		
		saveAddictionsForPlayer ( source )
		achievsave(source)
		inventorysave(source)
		skillDataSave ( player )
		saveArmyPermissions ( player )
		saveStatisticsMySQL ( player )
		outputDebugString ("Daten für Spieler "..pname.." wurden gesichert!")
	end
end

function achievsave ( player )

	local pname = getPlayerName ( player )
	saveHorseShoesFound ( player, pname )
	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "Waffenschieber", MtxGetElementData ( player, "gunloads"), "UID", playerUID[pname] )
	savePlayingTimeForSleeplessAchiev ( player, pname )
end



function inventorysave ( player )
	local pname = getPlayerName ( player )
	dbExec ( handler, "UPDATE ?? SET ??=?, ??=?, ??=?, ??=?, ??=?, ??=?, ??=?, ??=?, ??=?, ??=?, ??=?, ??=?, ??=? WHERE ??=?", "inventar", "Blumensamen", MtxGetElementData ( player, "flowerseeds" ), "Essensslot1", MtxGetElementData ( player, "food1" ), "Essensslot2", MtxGetElementData ( player, "food2" ), "Essensslot3", MtxGetElementData ( player, "food3" ), "Zigaretten", MtxGetElementData ( player, "zigaretten" ), "Materials", MtxGetElementData ( player, "mats" ), "Benzinkanister", MtxGetElementData ( player, "benzinkannister" ), "Objekt", MtxGetElementData ( player, "object" ), "Chips", MtxGetElementData ( player, "casinoChips" ), "Medikit", MtxGetElementData ( player, "medikits" ), "Repairkit", MtxGetElementData ( player, "repairkits" ), "kuerbisse", MtxGetElementData ( player, "kuerbisse" ), "Geschenke", MtxGetElementData ( player, "presents" ), "UID", playerUID[pname] )
end

function casinoMoneySave ( player )

	if MtxGetElementData ( player, "loggedin" ) == 1 then
		local name = getPlayerName ( player )
		local chips = math.abs ( math.floor ( MtxGetElementData ( player, "casinoChips" ) ) )
		local money = math.floor ( MtxGetElementData ( player, "money" ) )
		local bankMoney = math.floor ( MtxGetElementData ( player, "bankmoney" ) )
		dbExec ( handler,"UPDATE userdata SET ??=?, ??=? WHERE UID=?", "Geld", money, "Bankgeld", bankMoney, playerUID[name] )
		dbExec ( handler, "UPDATE inventar SET Chips=? WHERE UID=?", chips, playerUID[name] )
	end
end



-- Info: Angabe von Last_Login in Tagen seit Jahresanfang, Angabe von Geschlecht in 1 u. 0 - 1 = Weiblich, 0 = männlich
-- Anreise in 1 u. 0, 0 = Schiff, 1 = Flugzeug
-- Scheine: 0 = nicht vorhanden, 1 = vorhanden

function logoutPlayer_func(player, x, y, z, int, dim)

    local client = player
    if MtxGetElementData(client, "shootingRanchGun") then
    else
        local pname = getPlayerName(client)
        local int = tonumber(int)
        local dim = tonumber(dim)
        local curWeaponsForSave = "|"
        if shootingRanchGun[client] then
            takeWeapon(client, shootingRanchGun[client])
        end
        for i = 1, 11 do
            if i ~= 10 then
                local weapon = getPedWeapon(client, i)
                local ammo = getPedTotalAmmo(client, i)
                if weapon and ammo then
                    if weapon > 0 and ammo > 0 then
                        if #curWeaponsForSave <= 40 then
                            curWeaponsForSave = curWeaponsForSave .. weapon .. "," .. ammo .. "|"
                        end
                    end
                end
            end
        end
        local pos = "|" .. (math.floor(x * 100) / 100) .. "|" .. (math.floor(y * 100) / 100) .. "|" .. (math.floor(z * 100) / 100) .. "|" .. int .. "|" .. dim .. "|"
        if #curWeaponsForSave < 5 then
            curWeaponsForSave = ""
        end
        local result = dbExec(handler, "INSERT INTO logout (Position, Waffen, UID) VALUES (?,?,?)", pos, curWeaponsForSave, playerUID[pname])
        kickPlayer(client, "Ausgeloggt.")
    end
end
addEvent("logoutPlayer", true)
addEventHandler("logoutPlayer", getRootElement(), logoutPlayer_func)
