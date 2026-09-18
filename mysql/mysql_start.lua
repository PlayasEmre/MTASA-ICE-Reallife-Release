--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


gMysqlHost = ""
gMysqlUser = ""
gMysqlPass = ""
gMysqlDatabase = ""
 
playerUID = {}
playerUIDName = {}

handler = nil

local function tabelleExistiert ( tabelle )
	local ergebnis = dbPoll ( dbQuery ( handler, "SHOW TABLES LIKE ?", tabelle ), -1 )
	return ergebnis and ergebnis[1] and true or false
end

local function fuehreDatenbankAufbauAus ()
	if not dbSchemaSQL then
		outputDebugString ( "[DB-Setup] dbSchemaSQL (db_schema.lua) nicht gefunden!", 1 )
		return false
	end
	local inhalt = dbSchemaSQL

	inhalt = inhalt:gsub ( "%-%-[^\n]*\n", "\n" )
	inhalt = inhalt:gsub ( "/%*!.-%*/;?", "" )

	local frischErstellt = {} -- [tabellenname] = true, wenn in diesem Durchlauf neu angelegt
	local angelegt, eingefuegt, uebersprungen, fehler = 0, 0, 0, 0

	for statement in ( inhalt.."\n" ):gmatch ( "(.-;)\r?\n" ) do
		statement = statement:gsub ( "^%s+", "" ):gsub ( "%s+$", "" )
		if #statement > 1 then
			local createTabelle = statement:match ( "^CREATE TABLE `([^`]+)`" )
			local insertTabelle = statement:match ( "^INSERT INTO `([^`]+)`" )
			local alterTabelle = statement:match ( "^ALTER TABLE `([^`]+)`" )

			if createTabelle then
				if tabelleExistiert ( createTabelle ) then
					uebersprungen = uebersprungen + 1
				elseif dbExec ( handler, statement ) then
					angelegt = angelegt + 1
					frischErstellt[createTabelle] = true
				else
					fehler = fehler + 1
					outputDebugString ( "[DB-Setup] Fehler beim Anlegen von `"..createTabelle.."`", 2 )
				end
			elseif insertTabelle or alterTabelle then
				local tabelle = insertTabelle or alterTabelle
				if frischErstellt[tabelle] then
					if dbExec ( handler, statement ) then
						eingefuegt = eingefuegt + 1
					else
						fehler = fehler + 1
						outputDebugString ( "[DB-Setup] Fehler bei Anweisung fuer `"..tabelle.."`", 2 )
					end
				else
					uebersprungen = uebersprungen + 1
				end
			else
				dbExec ( handler, statement )
			end
		end
	end
	outputDebugString ( "[DB-Setup] "..angelegt.." Tabelle(n) angelegt, "..eingefuegt.." Startdaten-Anweisung(en), "..uebersprungen.." bereits vorhanden uebersprungen, "..fehler.." Fehler.", 3 )
	return true
end

local function indexExistiert ( tabelle, indexname )
	local ergebnis = dbPoll ( dbQuery ( handler, "SHOW INDEX FROM `"..tabelle.."` WHERE Key_name = ?", indexname ), -1 )
	return ergebnis and ergebnis[1] and true or false
end

-- Spalten, auf die der Code einschraenkt, die in der gewachsenen Datenbank aber
-- keinen Index haben. Ohne sie laeuft z.B. jede Fahrzeugabfrage als vollstaendiger
-- Tabellendurchlauf. Der Datenbank-Aufbau oben fasst bestehende Tabellen nicht an,
-- deshalb steht das hier eigenstaendig und laeuft bei jedem Start (idempotent).
-- "ADD INDEX IF NOT EXISTS" wird ( wie bei legeFehlendeSpaltenAn unten )
-- nicht von jeder MySQL/MariaDB-Version unterstuetzt - deshalb hier ebenfalls
-- erst per SHOW INDEX pruefen und nur bei Bedarf anlegen.
local function legeFehlendeIndizesAn ()
	local indizes = {
		{ "userdata", "idx_userdata_uid",      "UID"       }, { "vehicles", "idx_vehicles_uid_slot", "UID, Slot" },
		{ "players",  "idx_players_serial",    "Serial"    }, { "players",  "idx_players_name",      "Name"      },
		{ "warns",    "idx_warns_uid",         "UID"       }, { "object",   "idx_object_uid",        "UID"       },
		{ "email",    "idx_email_empfaenger",  "EmpfaengerUID" }, { "pm",   "idx_pm_empfaenger",     "EmpfaengerUID" },
		{ "prestige", "idx_prestige_uid",      "UID"       }, { "marry",    "idx_marry_pl2",         "pl2"       },
		{ "houses",   "idx_houses_uid",        "UID"       }, { "biz",      "idx_biz_uid",           "UID"       },
	}
	for i = 1, #indizes do
		local t = indizes[i]
		if not indexExistiert ( t[1], t[2] ) then
			dbExec ( handler, "ALTER TABLE `"..t[1].."` ADD INDEX `"..t[2].."` ("..t[3]..")" )
		end
	end
end

local function spalteExistiert ( tabelle, spalte )
	local ergebnis = dbPoll ( dbQuery ( handler, "SHOW COLUMNS FROM `"..tabelle.."` LIKE ?", spalte ), -1 )
	return ergebnis and ergebnis[1] and true or false
end

-- Gleiches Prinzip wie legeFehlendeIndizesAn: laeuft bei jedem Start, fasst
-- bestehende Spalten nicht an, legt nur fehlende neu an. Fuer das Autologin-
-- Feature ( register_login_server.lua / options_click.lua ) - Standard 0
-- (Autologin an), damit bestehende Accounts sich nicht veraendert anfuehlen.
-- WICHTIG: "ADD COLUMN IF NOT EXISTS" wird nicht von jeder MySQL/MariaDB-
-- Version unterstuetzt (schlug bei einem Hoster fehl, wo die Spalte dadurch
-- nie angelegt wurde) - deshalb hier erst manuell per SHOW COLUMNS pruefen
-- und nur bei Bedarf ein ganz normales ADD COLUMN ohne IF NOT EXISTS.
local function legeFehlendeSpaltenAn ()
	if not spalteExistiert ( "players", "AutologinAus" ) then
		dbExec ( handler, "ALTER TABLE `players` ADD COLUMN `AutologinAus` TINYINT NOT NULL DEFAULT 0" )
	end
end

function MySQL_Startup ( )
	handler = dbConnect ( "mysql", "dbname=".. gMysqlDatabase .. ";host="..gMysqlHost..";port=3306", gMysqlUser, gMysqlPass )
	if not handler then
		outputDebugString("[MySQL_Startup] Abfrage konnte nicht ausgeführt werden: Verbindung zum MySQL-Server kann nicht hergestellt werden!",3)
		outputDebugString("[MySQL_Startup] Bitte fahren Sie den Server herunter und starten Sie den MySQL-Server!",3)
		getThisResource():stop()
		return
	end

	fuehreDatenbankAufbauAus ()
	legeFehlendeIndizesAn ()
	legeFehlendeSpaltenAn ()

	local result = dbPoll ( dbQuery ( handler, "SELECT ??,?? FROM ??", "UID", "Name", "players" ), -1 )
	for i=1, #result do
		local id = tonumber ( result[i]["UID"] )
		local name = result[i]["Name"]
		playerUID[name] = id
		playerUIDName[id] = name
	end
	playerUIDName[0] = "none"
	playerUID["none"] = 0
end
MySQL_Startup()


function dbQueryCoro ( query, ... )
	local co = coroutine.running ()
	if not co then
		return dbPoll ( dbQuery ( handler, query, ... ), -1 )
	end
	dbQuery ( function ( qh )
		local result = dbPoll ( qh, 0 )
		local ok, err = coroutine.resume ( co, result )
		if not ok then
			outputDebugString ( "[dbQueryCoro] Coroutine-Fehler: " .. tostring ( err ), 1 )
		end
	end, handler, query, ... )
	return coroutine.yield ()
end


function runAsync ( fn, ... )
	local co = coroutine.create ( fn )
	local ok, err = coroutine.resume ( co, ... )
	if not ok then
		outputDebugString ( "[runAsync] Coroutine-Fehler: " .. tostring ( err ), 1 )
	end
	return co
end

function saveEverythingForScriptStop ( )
	saveDepotInDB()
	updateBizKasse()
end
addEventHandler ( "onResourceStop", resourceRoot, saveEverythingForScriptStop )

function getPlayerData(from,where,name,data)
	local rows = dbQueryCoro("SELECT * FROM ?? WHERE ??=?", from, where, name);
	if(rows)then
		for _,v in pairs(rows)do
			return v[data];
		end
	end
end

local whitelist = false

--//Whitelist Func
local function whitelists ( player )
	if ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 6 then
		if whitelist == true then
			whitelist = false
			outputChatBox ("Die Whitelist wurde deaktiviert!",root,255,120,0)
		else
			whitelist = true
			outputChatBox ("Die Whitelist wurde aktiviert!",root,255,0,0)
		end
	end
end
addCommandHandler("wh",whitelists)

addEventHandler("onPlayerConnect",root,
function(ni,ip,uni,se,ver)
if (whitelist == true) then
		local result=dbPoll(dbQuery(handler,"SELECT * FROM ?? WHERE ??=?","whitelist","Serial",se),-1)
		if(result and result[1])then
			if(result[1]["Access"]~="Yes")then
				cancelEvent(true,"Du bist auf der Whitelist, jedoch ohne Zugriff!")
				return false
			end
		else
			cancelEvent(true,"Du stehst nicht auf der Whitelist! Teamspeak-IP: "..Tables.tsip.."")
			return false
		end
	end
end)



addCommandHandler("addwhitelist",
function(player,cmd,name,serial)
	if ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 6 then
		if (name) and (serial) then
			dbExec(handler,"INSERT INTO whitelist (Name,Serial) VALUES (?,?)",name,serial)
			outputChatBox("Hinzugefügt "..name.." "..serial.." zu whitelist",player,0,255,0)
		else
			outputChatBox("Der korrekte Befehl lautet: /addwhitelist Name Serial",player,255,0,0)
		end
	end
end)
