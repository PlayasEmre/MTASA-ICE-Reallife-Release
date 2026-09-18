<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/

ob_start();
include("cfg.php");

/*
	Fehleranzeige.

	Vorher wurden bei DEBUG=true alle PHP-Fehler JEDEM Besucher angezeigt -
	inklusive Serverpfaden, Dateinamen und teilweise SQL-Abfragen. Das ist
	genau die Information, die ein Angreifer sucht.

	Jetzt gilt:
	- Fehler landen immer in logs/php-fehler.log
	- angezeigt werden sie nur Admins (und nur wenn DEBUG=true)
*/
error_reporting(E_ALL ^ E_NOTICE ^ E_DEPRECATED);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

$fehlerLog = dirname(__FILE__).DIRECTORY_SEPARATOR.'logs';
if (!is_dir($fehlerLog)) { @mkdir($fehlerLog, 0777, true); }
ini_set('error_log', $fehlerLog.DIRECTORY_SEPARATOR.'php-fehler.log');

header("Cache-Control: no-cache");

// Sicherheits-Header auch ohne Apache-Modul (siehe .htaccess)
header("X-Frame-Options: SAMEORIGIN");
header("X-Content-Type-Options: nosniff");
header("Referrer-Policy: strict-origin-when-cross-origin");

$CP = new CP($mySQLcon);

// Ab hier ist bekannt, ob es ein Admin ist.
if (DEBUG && $CP->Admin) {
	ini_set('display_errors', 1);
}

/*
	Seitenname absichern:
	- ?page[]=x wuerde in PHP 8 sonst einen Fatal Error werfen (Array an file_exists)
	- erlaubt sind nur Buchstaben, Zahlen, Bindestrich und Unterstrich
	  (verhindert ../ und andere Pfad-Tricks)
*/
if (isset($_GET['page'])) {
	if (!is_string($_GET['page']) || !preg_match('/^[a-zA-Z0-9_-]+$/', $_GET['page'])) {
		$_GET['page'] = '404';
	}
}

if (!isset($_GET['page']) || empty($_GET['page'])) {
	if ($CP->Loggedin) {
		header("Location: ?page=home");
	} else {
		header("Location: ?page=login");
	}
	exit();
}

include("templates/header.php");

if (!$mySQLcon->connect_errno) {
	/*
		Hier stand eine CHMOD-Pruefung fuer drei Dateien, die es inzwischen
		gar nicht mehr gibt (cronjob.php war fuer Teamspeak, paypal/ipn.php
		fuer PayPal). fileperms() auf eine fehlende Datei haette unter Linux
		das ganze Panel blockiert. Die Pruefung hatte ausserdem keinen
		Nutzen und wurde daher entfernt.
	*/
	$page = false;
	$intern = true;

	if (isset($_GET['page']) && !empty($_GET['page'])) {
		if (file_exists('pages/'.$_GET["page"].'.php')) {
			$page = $_GET["page"];
		}
	}

	if ((strpos($_GET['page'], 'admin') !== false && $CP->Admin == false) || (strpos($_GET['page'], '..') !== false)) {
		$page = "403";
	}

	if ($page != false) {
		if ($CP->Banned != false && in_array($_GET['page'], $bannedAllowedPages) == false) {
			$page = "banned";
		}
	} else {
		$page = "404";
	}

	/*
		Login-Pruefung VOR dem include.

		Vorher wurde erst die Seite eingebunden (z.B. home.php, das ungeprueft
		auf $CP->UserData[...] zugreift) und ERST DANACH auf Login geprueft.
		$CP->UserData ist aber nur bei $CP->Loggedin gesetzt (siehe
		cp.class.php) - ein Aufruf ohne Login fuehrte so bei jeder geschuetzten
		Seite zu "Trying to access array offset on value of type null".
		Oeffentliche Seiten (Login, 403, 404) muessen weiterhin ohne Login
		erreichbar sein, siehe $publicPages in cfg.php.
	*/
	if ($page != false && $CP->Loggedin == false && !in_array($page, $publicPages)) {
		header("Location: ?page=login");
		exit;
	}

	include("pages/".$page.".php");

	if ($intern == true && $CP->Loggedin == false) {
		header("Location: ?page=login");
		exit;
	}
	$mySQLcon->close();
} else {
	echo '<div class="alert alert-danger"><b>Es konnte keine Verbindung zur Datenbank hergestellt werden.<br>Bitte wende dich an einen Administrator.</b><br><br>MySQL Fehlermeldung: '.$mySQLcon->connect_error.' (#'.$mySQLcon->connect_errno.')</div>';
}

include("templates/footer.php");

ob_end_flush();
?>