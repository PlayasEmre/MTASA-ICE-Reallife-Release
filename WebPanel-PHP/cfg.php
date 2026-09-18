<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/***
Version: 2.4 - angepasst fuer ICE-Reallife (PlayasEmre)
***/

/*
	Allgemeine Einstellungen
*/
define('WEBSITE_TITLE',			'ICE-Reallife User Panel'); // Wird im Titel des Browserfensters angezigt.
define('SERVER_NAME',			'ICE-Reallife'); // Wird im CP oben Links angezeigt.
define('DEBUG',					true); // PHP Fehler anzeigen
define('SCRIPT_TYPE',			'ICE'); // lite, extended, thc, ultimate, Addiction, ICE
define('UID_BASED',				true); // ICE speichert alles ueber die UID (nicht ueber den Namen). NICHT aendern!
define('IMPRINT_LINK',			''); // Link zum Impressum

/*
	Zeitzone

	Ban-Zeiten (Tabelle "ban", Spalte STime) werden von ICE aus der LOKALEN
	Zeit des Spielservers berechnet (usefull/utility.lua -> getSecTime).
	Das Panel muss dieselbe Zeit benutzen, sonst sind Timebans um die
	Zeitverschiebung falsch - XAMPP laeuft ohne Eintrag in der php.ini
	naemlich auf UTC.

	Hier also die Zeitzone eintragen, in der Dein MTA-Server laeuft.
*/
define('SERVER_TIMEZONE',		'Europe/Berlin');
date_default_timezone_set(SERVER_TIMEZONE);
$bannedAllowedPages = array("settings", "403", "404", "logout"); // Seiten welche gebannte Spieler aufrufen dürfen.
$publicPages = array("login", "403", "404"); // Seiten, die OHNE Login aufrufbar sein müssen.


/*
	Coin Settings
	Hinweis: ICE hat keine eigene "coins"-Tabelle. Die Coins liegen in userdata.Coins.
*/
define('USE_COINS',				true); // Hauptschalter: Coin-Bereich im Panel an/aus.

/*
	Es gibt KEINE Online-Bezahlung im Panel.

	Entfernt wurden:
	  * PayPal        (Ordner paypal/ mit ipn.php, die Tabelle "coins")
	  * Paysafecard   (Datei pscCheck.php)

	Coins vergibt ein Admin im Panel unter
	"Admin -> Übersicht -> Coins gutschreiben".
	Alternativ ingame als Belohnung fuer Events, Aufgaben usw.
*/

/*
	==========================================================
	Welche Coin-Funktionen soll es geben?  (An/Aus-Schalter)
	==========================================================

	true  = die Funktion erscheint im Panel
	false = die Funktion ist komplett aus (auch nicht ueber die URL
	        erreichbar - sie wird nicht nur versteckt)

	"premium"     = die Premium-Mitgliedschaft kaufen
	"tel"         = Telefonnummer aendern
	"nick"        = Spielernamen aendern
	"state"       = Sozialen Status aendern
	"giveaway"    = Coins an andere Spieler verschenken
	"tacticreset" = Tactic Kills/Tode zuruecksetzen

	Entfernt, weil es das ingame schon gibt:
	  * Premiumfahrzeug kaufen  -> ingame mit /pcar
	  * Skin kaufen             -> ingame moeglich
	  * inGame-Geld kaufen      -> soll es nicht geben
*/
$coinFunktionen = array(
	"premium"		=> true,
	"tel"			=> true,
	"nick"			=> true,
	"state"			=> true,
	"giveaway"		=> true,
	"tacticreset"	=> true,
);

/*
	Muessen Spieler aktives Premium haben, um die Coin-Funktionen
	(Telefonnummer, Name, Status) zu benutzen?

	true  = nur Premium-Mitglieder duerfen diese Funktionen nutzen
	        (welcher Rang, ist egal - Premium muss nur aktiv sein)
	false = jeder mit genug Coins darf

	Die Premium-Mitgliedschaft selbst und das Verschenken von Coins
	sind davon nie betroffen - sonst koennte man nie anfangen.
*/
define('COINS_NUR_MIT_PREMIUM', true);

/*
	==========================================================
	Premium-Pakete
	==========================================================

	Jede Zeile ist ein Angebot, das der Spieler im Panel auswaehlen kann:

	"rang"  = Premium-Rang wie ingame (siehe $premiumPakete weiter unten
	          und ICE-Reallife/register_login/premium.lua):
	          1 Bronze, 2 Silber, 3 Gold, 4 Platin, 5 TOP DONATOR
	"tage"  = Laufzeit in Tagen. 0 bedeutet UNBEGRENZT (laeuft nie ab).
	"coins" = Preis in Coins

	Du kannst beliebig viele Zeilen haben - auch mehrere Laufzeiten fuer
	denselben Rang. Beispiel, wenn es Gold auch fuer 30 Tage geben soll:

		array("rang" => 3, "tage" => 30, "coins" => 400),

	Reihenfolge in der Liste = Reihenfolge im Panel.

	Gekauft wird immer genau ein Angebot. Solange die Mitgliedschaft laeuft,
	kann nichts Neues gekauft werden - erst wenn sie abgelaufen ist.
*/
$premiumAngebote = array(
	array("rang" => 1,	"tage" => 7,	"coins" => 150),	// Bronze
	array("rang" => 2,	"tage" => 30,	"coins" => 350),	// Silber
	array("rang" => 3,	"tage" => 180,	"coins" => 650),	// Gold
	array("rang" => 4,	"tage" => 365,	"coins" => 850),	// Platin
	array("rang" => 5,	"tage" => 0,	"coins" => 2000),	// TOP DONATOR (unbegrenzt)
);

/*
	Vorteile je Rang - nur Text fuer die Anzeige im Panel.
	Die Werte kommen aus premium.lua (vipPackageSocialTime, vipPackageTeleTime,
	vipPackagePremCarGive, vipPayDayExtra) und koennen dort angepasst werden.
*/
/*
	Status/Nummer/Name aendern sind KEINE Rang-Perks mehr - die gehen mit
	jedem Premium-Rang gleich, kosten aber Coins (siehe pages/coins.php,
	COINS_NUR_MIT_PREMIUM). Frueher gab es das ingame kostenlos per
	Cooldown (/premstatus, /tele) - das wurde in premium.lua entfernt.
*/
$premiumVorteile = array(
	1 => array("Telefonnummer, Name und Status im Webpanel aenderbar (mit Coins)", "+50% unversteuerte Payday-Einnahmen"),
	2 => array("Telefonnummer, Name und Status im Webpanel aenderbar (mit Coins)", "+100% unversteuerte Payday-Einnahmen"),
	3 => array("Telefonnummer, Name und Status im Webpanel aenderbar (mit Coins)", "+150% unversteuerte Payday-Einnahmen"),
	4 => array("Telefonnummer, Name und Status im Webpanel aenderbar (mit Coins)", "Alle 7 Tage ein gratis Premium-Fahrzeug", "+200% unversteuerte Payday-Einnahmen"),
	5 => array("Telefonnummer, Name und Status im Webpanel aenderbar (mit Coins)", "Alle 3,5 Tage ein gratis Premium-Fahrzeug", "+300% unversteuerte Payday-Einnahmen", "Laeuft nie ab"),
);

/*
	Hinweis: Der frueher hier stehende $coinSkins-Bereich ("Skin kaufen")
	ist entfernt - Skins kann man sich ingame geben. Die Skin-Bilder in
	assets/img/skins/ bleiben, sie werden fuer die Uebersichtsseite
	gebraucht (dort wird der eigene Skin angezeigt).
*/


/*
	Fraktionen
	Uebernommen aus der ICE-DB (Tabelle "fraktionen").
*/
/*
	Namen wie ingame in der Spielerliste
	(ICE-Reallife/client/playerlist_client.lua, Zeile 100).

	"art" wird fuer die Zaehlung auf der Startseite benutzt:
	staat = Staatsfraktion, illegal = illegale Fraktion, neutral = alles andere.
*/
$factions = array(
0  => array("name" => "Zivilist",			"rgb" => "200,200,200",	"art" => "neutral"),
1  => array("name" => "S.F.P.D",			"rgb" => "0,200,0",		"art" => "staat"),
2  => array("name" => "Mafia",				"rgb" => "100,100,100",	"art" => "illegal"),
3  => array("name" => "Triaden",			"rgb" => "1,0,248",		"art" => "illegal"),
4  => array("name" => "Terroristen",		"rgb" => "125,0,0",		"art" => "illegal"),
5  => array("name" => "San News",			"rgb" => "180,130,0",	"art" => "neutral"),
6  => array("name" => "F.B.I",				"rgb" => "125,125,200",	"art" => "staat"),
7  => array("name" => "Los Aztecas",		"rgb" => "230,230,0",	"art" => "illegal"),
8  => array("name" => "Bundeswehr",			"rgb" => "0,100,0",		"art" => "staat"),
9  => array("name" => "Angels of Death",	"rgb" => "100,50,50",	"art" => "illegal"),
10 => array("name" => "Medic",				"rgb" => "255,51,51",	"art" => "neutral"),
11 => array("name" => "Mechaniker",			"rgb" => "150,150,27",	"art" => "neutral"),
12 => array("name" => "Ballas",				"rgb" => "138,43,226",	"art" => "illegal"),
13 => array("name" => "Grove",				"rgb" => "0,238,0",		"art" => "illegal"),
14 => array("name" => "Anonymus",			"rgb" => "255,140,0",	"art" => "illegal"),
15 => array("name" => "Fahrschule",			"rgb" => "0,180,255",	"art" => "neutral"),
);

/*
	Premium-Pakete von ICE (playerlist_client.lua, Zeile 101).
	Steht in userdata.PremiumPaket.
*/
$premiumPakete = array(
1 => "Bronze",
2 => "Silber",
3 => "Gold",
4 => "Platin",
5 => "TOP DONATOR"
);


/*
	Logs

	ICE schreibt seine Logs als Dateien nach
	ICE-Reallife/vio_stored_files/logs/<name>.log  (admin/allround_log.lua).
	Der Schluessel muss genau dem Dateinamen ohne ".log" entsprechen.

	Ausgelesen werden sie ueber die Lua-Funktion getLogContent
	(webpanel/webpanel_server.lua).
*/
$LogNames			= array(
	"admin"			=> "Adminaktionen",
	"Adminsystem"	=> "Adminsystem",
	"aktion"		=> "Aktionen",
	"autodelete"	=> "Autodelete",
	"abgeschleppt"	=> "Abgeschleppte Fahrzeuge",
	"b-Chat"		=> "B-Chat",
	"casino"		=> "Casino",
	"Chat"			=> "Chat",
	"death"			=> "Tode",
	"dmg"			=> "Schaden",
	"drogen"		=> "Drogen",
	"explodecar"	=> "Explodierte Fahrzeuge",
	"fguns"			=> "Fraktionswaffen",
	"fkasse"		=> "Fraktionskasse",
	"gangwar"		=> "Gangwar",
	"Geld"			=> "Geld",
	"Heilung"		=> "Heilungen",
	"house"			=> "Häuser",
	"kill"			=> "Kills",
	"pwchange"		=> "Passwortänderungen",
	"registerbonus"	=> "Registrierbonus",
	"Reportsystem"	=> "Reports",
	"Robs"			=> "Überfälle",
	"Team-Chat"		=> "Team-Chat",
	"vehicle"		=> "Fahrzeuge",
	"weed"			=> "Weed",
	"werbung"		=> "Werbung",
);

/*
	Hinweis: Die alten Arrays $LogNamesAddiction und $LogNamesUltimate
	(fuer andere Reallife-Scripts) wurden entfernt - fuer ICE zaehlt nur
	die Liste oben.
*/


/*
	Pfad zum ICE-Resourcenordner auf DIESEM Server.

	Wird gebraucht, um a) die Logdateien zu lesen
	(ICE schreibt sie nach <Resource>/vio_stored_files/logs/*.log) und
	b) die MySQL-Zugangsdaten weiter unten automatisch aus
	<Resource>/mysql/mysql_start.lua zu uebernehmen - dann muss man sie nur
	noch an EINER Stelle eintragen, nicht doppelt hier und in der Resource.

	Leer lassen = das Panel sucht die Logs selbst an den ueblichen Stellen,
	die MySQL-Zugangsdaten muessen dann unten manuell eingetragen werden.
	Beispiele:
	define('ICE_RESOURCE_PFAD', 'C:\\MTA San Andreas 1.6\\server\\mods\\deathmatch\\resources\\ICE');
	define('ICE_RESOURCE_PFAD', 'C:\\Users\\emres\\Desktop\\ICE-Reallife');
*/
define('ICE_RESOURCE_PFAD', 'C:\Program Files (x86)\MTA San Andreas 1.6\server\mods\deathmatch\resources\ICE');

/*
	MySQL Daten des Reallife Script

	Werden automatisch aus ICE_RESOURCE_PFAD/mysql/mysql_start.lua gelesen
	(gMysqlHost/gMysqlUser/gMysqlPass/gMysqlDatabase) - dadurch muss beim
	Einrichten nur noch DIESE eine Lua-Datei mit den echten Zugangsdaten
	gepflegt werden, nicht zusaetzlich diese cfg.php.

	Klappt das Auslesen nicht (ICE_RESOURCE_PFAD leer/falsch, Datei nicht
	lesbar, o.ae.), greifen die Fallback-Werte weiter unten in
	iceStandardMysqlZugangsdaten() - dann bitte dort von Hand eintragen.
*/
function iceStandardMysqlZugangsdaten() {
	// Fallback, falls mysql_start.lua nicht automatisch gelesen werden kann.
	return array("127.0.0.1", "root", "", "reallife", 3306);
}

function iceLiesMysqlZugangsdaten() {
	$standard = iceStandardMysqlZugangsdaten();
	if (!defined('ICE_RESOURCE_PFAD') || ICE_RESOURCE_PFAD === '') {
		return $standard;
	}

	$pfad = rtrim(ICE_RESOURCE_PFAD, '\\/') . DIRECTORY_SEPARATOR . 'mysql' . DIRECTORY_SEPARATOR . 'mysql_start.lua';
	if (!is_readable($pfad)) {
		return $standard;
	}

	$inhalt = @file_get_contents($pfad, false, null, 0, 8192); // Zugangsdaten stehen ganz am Dateianfang.
	if ($inhalt === false) {
		return $standard;
	}

	$lies = function ($variable, $default) use ($inhalt) {
		if (preg_match('/\b' . preg_quote($variable, '/') . '\s*=\s*"([^"]*)"/', $inhalt, $treffer)) {
			return $treffer[1];
		}
		return $default;
	};

	return array(
		$lies('gMysqlHost', $standard[0]),
		$lies('gMysqlUser', $standard[1]),
		$lies('gMysqlPass', $standard[2]),
		$lies('gMysqlDatabase', $standard[3]),
		$standard[4], // Port steht nicht in mysql_start.lua, MTA nutzt hier immer den Standardport.
	);
}

/*
	WICHTIG (PHP 8):
	Seit PHP 8.1 wirft mysqli bei jedem Fehler eine Exception, statt false
	zurueckzugeben. Das gesamte Panel prueft aber auf false / connect_errno.
	Ohne die naechste Zeile gaebe es bei jedem Fehler (falsches Passwort,
	fehlende Tabelle, ...) eine weisse Seite mit "Uncaught mysqli_sql_exception"
	statt der verstaendlichen Fehlermeldung.
*/
if (function_exists('mysqli_report')) { mysqli_report(MYSQLI_REPORT_OFF); }

list($iceDbHost, $iceDbUser, $iceDbPass, $iceDbName, $iceDbPort) = iceLiesMysqlZugangsdaten();
$mySQLcon = @new mysqli($iceDbHost, $iceDbUser, $iceDbPass, $iceDbName, $iceDbPort);
if (!$mySQLcon->connect_errno) {
	// ICE-Tabellen sind latin1, die Seite ist UTF-8: MySQL konvertiert dann automatisch.
	@$mySQLcon->set_charset("utf8");
}

/*
	MTA-SERVER

	WICHTIG:
	Folgende Änderung in der mtaserver.conf vornehmen:
    Bei http_dos_exclude und auth_serial_http_ip_exceptions die IP-Adresse des Webservers eintragen.
	Bsp.: <http_dos_exclude>8.8.8.8</http_dos_exclude> <auth_serial_http_ip_exceptions>8.8.8.8</auth_serial_http_ip_exceptions>
*/
define('MTA_IP',			'127.0.0.1');
define('MTA_PORT',			'22003');
define('MTA_HTTP_PORT',		'22005');
define('MTA_USER',			'Emre192'); // Account benötigt Admin-Rechte!
define('MTA_PASS',			'emre1234');

/*
	Zugangscode für die HTTP-Schnittstelle (7 Ziffern) - meist NICHT nötig.

	Nötig ist er nur, wenn der Account durch MTAs "Authorized Serial Account
	Protection" geschützt ist (alle Accounts in den Gruppen aus
	auth_serial_groups, Standard: Admin). Dann lehnt der Server jede
	HTTP-Anmeldung ab, die nicht von einer ingame benutzten IP kommt:

		HTTP: Failed login for user '...' because 127.0.0.1 not
		associated with authorized serial

	Code holen - in der Server-Konsole eingeben:

		authserial Emre192 httppass

	Der Server zeigt dann 7 Ziffern an. Die hier eintragen:

		define('MTA_HTTP_CODE', '1234567');

	Das Panel hängt den Code automatisch an das Passwort an - Du musst
	MTA_PASS also NICHT ändern. Und es ist kein Server-Neustart nötig.

	Quelle: wiki.multitheftauto.com/wiki/Authorized_Serial_Account_Protection
*/
/*
	ACHTUNG: Nur ausfuellen, wenn wirklich die Serial-Meldung kommt!

	Am 27.07.2026 getestet: mit dem normalen Passwort antwortet der Server
	mit 200 (Anmeldung in Ordnung), mit angehaengtem Code dagegen mit 401 -
	weil die IP 127.0.0.1 bereits in auth_serial_http_ip_exceptions steht
	und der Code das Passwort dann nur verfaelscht. Deshalb wieder leer.
*/
define('MTA_HTTP_CODE',		'');
define('MTA_RESOURCE_NAME', 'ICE'); // Name der Reallife resource (muss = Tables.servername in settings/settings.lua sein!)

/*
	Live-Adminfunktionen (Spielerliste, Kick, Ban, Screenshot, Nachricht, Logs)
	laufen ueber HTTP direkt gegen den MTA-Server.

	Die dafuer noetigen Funktionen liegen jetzt im Spielscript:
		ICE-Reallife/webpanel/webpanel_server.lua
	und sind in der meta.xml mit http="true" exportiert:
		listAllPlayers, kickPlayerWeb, permaBanWeb, timeBanWeb, unbanWeb,
		makePlayerScreenshot, getScreenResult, sendMsgToAdmins,
		sendMsgToPlayer, getLogContent

	Damit es losgeht, fehlen nur noch zwei Dinge:

	1) Oben MTA_USER / MTA_PASS auf einen echten MTA-Account setzen, der die
	   Funktionen der Resource aufrufen darf (Admin-Gruppe in der ACL).
	2) In der mtaserver.conf die IP des Webservers eintragen:
	       <http_dos_exclude>127.0.0.1</http_dos_exclude>
	       <auth_serial_http_ip_exceptions>127.0.0.1</auth_serial_http_ip_exceptions>

	Solange dort die Beispielwerte stehen, zeigt das Panel statt Fehlermeldungen
	einen Hinweis an und benutzt die Datenbank (Spielerliste, Bans gehen auch so).
*/
define('MTA_WEB_FUNCTIONS', true);



/*
	Die Teamspeak-Synchronisation wurde komplett entfernt
	(Ordner ts3php/, der TS3-Block in pages/settings.php und cronjob.php).
	ICE hat dafuer keine Spalte in der Datenbank und gebraucht wurde sie nicht.
*/

define('LEADER_RANG', '5'); // Fraktionsrang des Leaders (fuer die Leader-Liste)




/*
	Seitentitel
*/
$pagetitles = Array();
$pagetitles["login"]				= "Login";
$pagetitles["home"]					= "Übersicht";
$pagetitles["vehicles"]				= "Fahrzeuge";
$pagetitles["faction"]				= "Fraktion";
$pagetitles["inventory"]			= "Inventar / Waffenbox";
$pagetitles["house"]				= "Haus";
$pagetitles["rang"]					= "Ranglisten";
$pagetitles["coins"]				= "Coins";
$pagetitles["settings"]				= "Einstellungen";
$pagetitles["kaufen"]				= "Autohäuser & Geschäfte";
$pagetitles["statistik"]			= "Statistik";
$pagetitles["banned"]				= "Gebannt";
$pagetitles["403"]					= "Kein Zugriff";
$pagetitles["404"]					= "Nicht gefunden";
$pagetitles["admin-bans"]			= "Admin: Bans";
$pagetitles["admin-checkplayer"]	= "Admin: Spieler Checken";
$pagetitles["admin-logs"]			= "Admin: Logs";
$pagetitles["admin-players"]		= "Admin: Spieler";
$pagetitles["admin-userdata"]		= "Admin: Userdaten bearbeiten";
$pagetitles["diagnose"]				= "System-Check";




/*
	Includes
*/
include("usefull.php");
include("mta_sdk.php");
include("cp.class.php");
?>
