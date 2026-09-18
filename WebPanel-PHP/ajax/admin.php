<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Live-Adminfunktionen (Spielerliste, Kick, Ban, Screenshot, Nachricht).

	Gegenstueck im Spiel: ICE-Reallife/webpanel/webpanel_server.lua
	(in der meta.xml mit http="true" exportiert).

	Alle Aufrufe laufen ueber cpMtaCall() - das faengt Verbindungsfehler und
	falsche Zugangsdaten ab. Vorher gab es dabei einen Fatal Error, weil das
	MTA-SDK eine Exception wirft.
*/
include("../cfg.php");

header("Content-Type: text/plain; charset=utf-8");

$CP = new CP($mySQLcon);

if (!$CP->Loggedin || !$CP->Admin) {
	die("Kein Zugriff.");
}

if ($CP->Banned) {
	die("Gebannte Accounts können keine Adminfunktionen nutzen.");
}

if (!cpMtaBereit()) {
	die("Die Live-Adminfunktionen sind nicht eingerichtet (siehe Hinweis auf der Admin-Übersicht).");
}

/*
	Formular-Schluessel pruefen.

	Ohne diese Pruefung koennte eine fremde Webseite einen angemeldeten Admin
	dazu bringen, diese Adresse aufzurufen (z.B. ueber einen praeparierten
	Link) und damit Spieler kicken oder bannen. Den Schluessel kann nur
	berechnen, wer den Anmelde-Cookie kennt.
*/
if (!cpCsrfOk()) {
	die("Sicherheitsschlüssel fehlt oder ist falsch. Bitte die Admin-Seite neu laden.");
}

if (!isset($_GET['action'])) {
	die("Keine Aktion angegeben.");
}

$aktion = $_GET['action'];
$player = ((isset($_GET['player'])) ? $_GET['player'] : '');
$reason = ((isset($_GET['reason'])) ? $_GET['reason'] : '');
$zeit   = ((isset($_GET['time'])) ? $_GET['time'] : '0');
$text   = ((isset($_GET['msg'])) ? $_GET['msg'] : '');

$ergebnis = false;

switch ($aktion) {
	case 'kick':
		$ergebnis = cpMtaCall("kickPlayerWeb", array($CP->Name, $player, $reason));
		break;

	case 'permaban':
		if ($CP->Adminlvl < 2) { die("Nicht genügend Rechte (Adminlevel 2 / ".cpAdminRangName(2)." nötig)."); }
		$ergebnis = cpMtaCall("permaBanWeb", array($CP->Name, $player, $reason));
		break;

	case 'timeban':
		if ($CP->Adminlvl < 2) { die("Nicht genügend Rechte (Adminlevel 2 / ".cpAdminRangName(2)." nötig)."); }
		$ergebnis = cpMtaCall("timeBanWeb", array($CP->Name, $player, $zeit, $reason));
		break;

	case 'unban':
		if ($CP->Adminlvl < 3) { die("Nicht genügend Rechte (Adminlevel 3 / ".cpAdminRangName(3)." nötig)."); }
		$ergebnis = cpMtaCall("unbanWeb", array($CP->Name, $player));
		break;

	case 'msg':
		$ergebnis = cpMtaCall("sendMsgToPlayer", array($CP->Name, $player, $text));
		break;

	case 'playerlist':
		$ergebnis = cpMtaCall("listAllPlayers");
		// Die Liste wird unverändert durchgegeben ("Name1|Name2|").
		echo (($ergebnis['ok']) ? $ergebnis['wert'] : '');
		exit;

	case 'screen':
		$ergebnis = cpMtaCall("makePlayerScreenshot", array($player));
		break;

	case 'screen-result':
		$ergebnis = cpMtaCall("getScreenResult");
		echo (($ergebnis['ok']) ? $ergebnis['wert'] : '');
		exit;

	case 'betacode':
		if ($CP->Adminlvl < 3) { die("Nicht genügend Rechte (Adminlevel 3 / ".cpAdminRangName(3)." nötig)."); }
		$ergebnis = cpMtaCall("createBetaCodeWeb", array($CP->Name));
		if (!$ergebnis['ok']) {
			echo $ergebnis['fehler'];
		} else if (strpos($ergebnis['wert'], 'true|') === 0) {
			$code = substr($ergebnis['wert'], 5);
			echo "Neuer Beta-Code: <b>".htmlspecialchars($code)."</b> (einmal einlösbar, ohne Ablaufdatum)";
			cpWriteLog("admin.log", $CP->Name." -> betacode -> ".$code);
		} else {
			echo $ergebnis['wert'];
		}
		exit;

	default:
		die("Unbekannte Aktion.");
}

if (!$ergebnis['ok']) {
	echo $ergebnis['fehler'];
} else if ($ergebnis['wert'] == "true") {
	echo "Aktion erfolgreich ausgeführt.";
	cpWriteLog("admin.log", $CP->Name." -> ".$aktion." (".$player.") ".$reason.$text);
} else {
	// Fehlermeldung direkt aus dem Lua-Script (z.B. "Dieser Spieler ist nicht online.")
	echo $ergebnis['wert'];
}
?>
