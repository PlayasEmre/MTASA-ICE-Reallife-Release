<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	System-Check.

	Zeigt an einer Stelle, ob Panel, Datenbank und Spielserver zusammenpassen.
	Gedacht fuer genau die Fragen "warum ist die Liste leer" / "warum sehe ich
	meine Fraktion nicht" / "warum ist die Karte leer".

	Nur fuer Admins (index.php laesst Seiten mit "admin" im Namen nur fuer
	Admins zu - diese Seite heisst absichtlich anders, daher hier die eigene
	Pruefung).
*/
if (!$CP->Admin) {
	echo '<div class="alert alert-danger"><b>Diese Seite ist nur für Admins.</b></div>';
	return;
}

// Kleine Helfer fuer die Ausgabe
if (!function_exists('dgZeile')) {
	function dgZeile($name, $wert, $status = null, $hinweis = '') {
		$ampel = '';
		if ($status === true)  { $ampel = '<span style="color:#2b8a3e; font-weight:bold;">OK</span>'; }
		if ($status === false) { $ampel = '<span style="color:#c92a2a; font-weight:bold;">PROBLEM</span>'; }
		if ($status === 'warn'){ $ampel = '<span style="color:#e8590c; font-weight:bold;">HINWEIS</span>'; }

		echo '<tr>
			<td width="30%"><b>'.htmlspecialchars($name).'</b></td>
			<td width="45%">'.$wert.'</td>
			<td width="10%">'.$ampel.'</td>
			<td width="15%"><small class="text-muted">'.$hinweis.'</small></td>
		</tr>';
	}
}

// Wie viele Zeilen hat eine Tabelle?
$dbAnzahl = function($tabelle, $where = '') use ($mySQLcon) {
	$sql = "SELECT * FROM `".$tabelle."`".(($where != '') ? " WHERE ".$where : "")." LIMIT 100000";
	return cpCountRows($mySQLcon, $sql);
};
?>
<div class="row">
	<div class="col-md-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-stethoscope"></i> Webserver &amp; PHP
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table table-striped">
						<tbody>
							<?php
							dgZeile('PHP-Version', PHP_VERSION, (version_compare(PHP_VERSION, '7.4', '>=')), 'ab 7.4 getestet');

							dgZeile('mysqli', ((class_exists('mysqli')) ? 'vorhanden' : 'FEHLT'), class_exists('mysqli'), 'Pflicht');

							dgZeile('GD (Bildbibliothek)',
								((cpGdVorhanden()) ? 'vorhanden' : 'fehlt'),
								((cpGdVorhanden()) ? true : 'warn'),
								'Die Karte im Panel läuft auch ohne GD.');

							dgZeile('Zeitzone', date_default_timezone_get().' &middot; jetzt: '.date('d.m.Y, H:i'),
								true, 'in cfg.php: SERVER_TIMEZONE');

							$logDir = dirname(dirname(__FILE__)).DIRECTORY_SEPARATOR.'logs';
							$logOk = (is_dir($logDir) && is_writable($logDir));
							dgZeile('Ordner logs/ beschreibbar', (($logOk) ? 'ja' : 'nein ('.htmlspecialchars($logDir).')'), $logOk, 'für Panel-Logs');

							dgZeile('Kartenbild', ((is_file(dirname(dirname(__FILE__)).'/assets/img/map.jpg')) ? 'assets/img/map.jpg gefunden' : 'FEHLT'),
								is_file(dirname(dirname(__FILE__)).'/assets/img/map.jpg'));

							// ICE-Logordner (fuer Admin -> Logs)
							$logPfad = cpIceLogPfad();
							if ($logPfad !== false) {
								$anzahlLogs = count(glob($logPfad.DIRECTORY_SEPARATOR.'*.log'));
								dgZeile('ICE-Logordner', '<code>'.htmlspecialchars($logPfad).'</code><br>'.$anzahlLogs.' Logdateien gefunden',
									true, 'Admin → Logs liest direkt von hier');
							} else {
								dgZeile('ICE-Logordner', 'nicht gefunden', false,
									'In cfg.php bei ICE_RESOURCE_PFAD eintragen');
							}
							?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>

<div class="row">
	<div class="col-md-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-database"></i> Datenbank
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table table-striped">
						<tbody>
							<?php
							dgZeile('Verbindung', 'verbunden mit <code>'.htmlspecialchars($mySQLcon->host_info).'</code>', true);

							$serverInfo = $mySQLcon->server_info;
							dgZeile('MySQL / MariaDB', htmlspecialchars($serverInfo), true);

							// Pflichttabellen
							$pflicht = array('players', 'userdata', 'loggedin', 'vehicles', 'houses', 'fraktionen', 'statistics', 'inventar', 'bonustable', 'achievments', 'skills', 'ban', 'warns');
							$fehlend = array();
							foreach ($pflicht as $t) {
								if (!cpTableExists($mySQLcon, $t)) { $fehlend[] = $t; }
							}
							dgZeile('Wichtige Tabellen',
								((count($fehlend) == 0) ? 'alle '.count($pflicht).' vorhanden' : 'FEHLEN: <code>'.htmlspecialchars(implode(', ', $fehlend)).'</code>'),
								(count($fehlend) == 0),
								'ICE-DB.sql importiert?');

							// Optionale Tabellen
							$optional = array('logs' => 'nur für Logs in der Datenbank');
							$optText = array();
							foreach ($optional as $t => $zweck) {
								$optText[] = '<code>'.$t.'</code>: '.((cpTableExists($mySQLcon, $t)) ? 'vorhanden' : 'nicht vorhanden');
							}
							dgZeile('Optionale Tabellen', implode('<br>', $optText), 'warn', 'install/panel-erweiterungen.sql');

							$anzPlayers  = $dbAnzahl('players');
							$anzUserdata = $dbAnzahl('userdata');
							dgZeile('Accounts', '<code>players</code>: <b>'.$anzPlayers.'</b> &middot; <code>userdata</code>: <b>'.$anzUserdata.'</b>',
								($anzPlayers > 0),
								(($anzPlayers != $anzUserdata) ? 'Zahlen sollten gleich sein' : ''));

							// Fraktionen 14/15 vorhanden?
							$frakRows = $dbAnzahl('fraktionen');
							$hat1415 = ($dbAnzahl('fraktionen', "ID IN (14,15)") == 2);
							dgZeile('Tabelle fraktionen', $frakRows.' Einträge &middot; Anonymus (14) + Fahrschule (15): '.(($hat1415) ? 'vorhanden' : '<b>fehlen</b>'),
								$hat1415,
								(($hat1415) ? '' : 'install/panel-erweiterungen.sql, Abschnitt 1'));
							?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>

<div class="row">
	<div class="col-md-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-gamepad"></i> Schreibt der Spielserver in diese Datenbank?
			</div>
			<div class="panel-body">
				<p>
					Das ist die häufigste Fehlerquelle: Panel und Spiel benutzen verschiedene
					Datenbanken oder das Spielscript hat gar keine Zugangsdaten. Dann bleiben
					Online-Liste, Fraktion und Spielzeit im Panel leer.
					<br>
					Die Zugangsdaten im Spiel stehen in
					<code>ICE-Reallife\mysql\mysql_start.lua</code> (Zeilen mit
					<code>gMysqlHost</code>, <code>gMysqlUser</code>, <code>gMysqlPass</code>,
					<code>gMysqlDatabase</code>) und müssen zu <code>cfg.php</code> passen.
				</p>
				<div class="table-responsive">
					<table class="table table-striped">
						<tbody>
							<?php
							/*
								Direkte Abfrage beim Spielserver (ASE-Port).
								Braucht kein Passwort und keine Aenderung in der
								mtaserver.conf - beantwortet die Frage
								"wer ist gerade online" unabhaengig von der Datenbank.
							*/
							$srv = cpMtaAseAbfrage();
							if ($srv && !empty($srv['ok'])) {
								$namen = $srv['spieler'];
								dgZeile('Spielserver antwortet',
									'<b>'.htmlspecialchars($srv['name']).'</b> &middot; Version '.htmlspecialchars($srv['version']).'<br>'
									.'<b>'.(int)$srv['anzahl'].'</b> von '.(int)$srv['max'].' Spielern'
									.((count($namen) > 0) ? '<br><small>'.htmlspecialchars(implode(', ', $namen)).'</small>' : ''),
									true,
									'Port '.((int)MTA_PORT + 123).' (UDP)');
							} else {
								dgZeile('Spielserver antwortet',
									'nein'.((isset($srv['fehler'])) ? '<br><small>'.htmlspecialchars($srv['fehler']).'</small>' : ''),
									false,
									'Läuft der Server? MTA_IP/MTA_PORT in cfg.php richtig?');
							}

							// 1) loggedin: fuellt ICE beim Join/Login
							$lgAlle	= $dbAnzahl('loggedin');
							$lgAn	= $dbAnzahl('loggedin', "Loggedin='1'");
							dgZeile('Tabelle loggedin',
								'Einträge: <b>'.$lgAlle.'</b> &middot; davon ingame eingeloggt: <b>'.$lgAn.'</b>',
								(($lgAlle > 0) ? true : 'warn'),
								(($lgAlle == 0) ? 'leer = Server läuft nicht' : ''));

							// 2) Hat ICE jemals einen Login geschrieben?
							$mitLogin = $dbAnzahl('players', "Last_login <> '' AND Last_login IS NOT NULL");
							dgZeile('Accounts mit Login-Datum',
								'<b>'.$mitLogin.'</b> von '.$anzPlayers,
								(($mitLogin > 0) ? true : false),
								(($mitLogin == 0) ? 'ICE hat hier noch nie gespeichert' : ''));

							// 3) Gibt es ueberhaupt gespeicherte Spielzeit / Fraktionen?
							$mitZeit = $dbAnzahl('userdata', "Spielzeit > 0");
							$mitFrak = $dbAnzahl('userdata', "Fraktion > 0");
							dgZeile('Gespeicherte Spieldaten',
								'mit Spielzeit: <b>'.$mitZeit.'</b> &middot; in einer Fraktion: <b>'.$mitFrak.'</b>',
								(($mitZeit > 0 || $mitFrak > 0) ? true : 'warn'),
								'ICE speichert erst beim Ausloggen');

							// 4) Eigener Account
							$eigeneFrak = (int)$CP->UserData['userdata']['Fraktion'];
							dgZeile('Dein Account',
								'UID <b>'.(int)$CP->UID.'</b> &middot; '.htmlspecialchars($CP->Name)
								.' &middot; Adminlevel <b>'.htmlspecialchars(cpAdminRangName($CP->Adminlvl)).' ('.(int)$CP->Adminlvl.')</b>'
								.' &middot; Fraktion in der DB: <b>'.$eigeneFrak.'</b>'
								.' &middot; ingame: <b>'.(($CP->inGameLoggedin) ? 'eingeloggt' : 'offline').'</b>',
								true);
							?>
						</tbody>
					</table>
				</div>

				<?php if ($lgAlle == 0 && $mitLogin == 0) { ?>
				<div class="alert alert-danger">
					<b>Der Spielserver hat in diese Datenbank noch nie geschrieben.</b><br>
					Prüfe in <code>ICE-Reallife\mysql\mysql_start.lua</code>, ob dort
					<code>gMysqlDatabase = "ice"</code>, <code>gMysqlHost = "127.0.0.1"</code>,
					<code>gMysqlUser = "root"</code> stehen — genau wie in <code>cfg.php</code>.
					Sind die Werte leer, stoppt sich die Resource beim Start selbst
					(im Serverfenster steht dann „Verbindung zum MySQL-Server kann nicht hergestellt werden").
				</div>
				<?php } ?>
			</div>
		</div>
	</div>
</div>

<div class="row">
	<div class="col-md-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-plug"></i> Live-Adminfunktionen (MTA)
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table table-striped">
						<tbody>
							<?php
							dgZeile('MTA_WEB_FUNCTIONS', ((MTA_WEB_FUNCTIONS) ? 'true' : 'false'), (MTA_WEB_FUNCTIONS ? true : 'warn'));
							dgZeile('MTA-Zugangsdaten',
								((cpMtaBereit()) ? 'Account <code>'.htmlspecialchars(MTA_USER).'</code> eingetragen' : 'noch die Beispielwerte (<code>'.htmlspecialchars(MTA_USER).'</code>)'),
								cpMtaBereit(),
								'cfg.php: MTA_USER / MTA_PASS');

							$hatCode = (defined('MTA_HTTP_CODE') && MTA_HTTP_CODE != '');
							dgZeile('HTTP-Zugangscode',
								(($hatCode) ? 'eingetragen ('.strlen(MTA_HTTP_CODE).' Zeichen) — wird an das Passwort angehängt' : 'keiner eingetragen'),
								(($hatCode) ? true : 'warn'),
								'Nur nötig bei „not associated with authorized serial": in der Server-Konsole <code>authserial '.htmlspecialchars(MTA_USER).' httppass</code>');
							dgZeile('Ziel', '<code>'.htmlspecialchars(MTA_IP).':'.htmlspecialchars(MTA_HTTP_PORT).'</code>, Resource <code>'.htmlspecialchars(MTA_RESOURCE_NAME).'</code>', true);

							if (cpMtaBereit()) {
								$test = cpMtaCall("listAllPlayers");
								if ($test['ok']) {
									$namen = array_filter(explode('|', $test['wert']));
									dgZeile('Testaufruf listAllPlayers',
										'Antwort erhalten &middot; Spieler ingame: <b>'.count($namen).'</b>'
										.((count($namen) > 0) ? ' ('.htmlspecialchars(implode(', ', $namen)).')' : ''),
										true, 'Verbindung steht');
								} else {
									/*
										Die Meldung aus cpMtaCall enthaelt bewusst HTML
										(Hinweise mit <code>-Beispielen) und darf daher
										nicht durch htmlspecialchars laufen. Fremde Texte
										sind darin schon escaped - siehe usefull.php.
									*/
									dgZeile('Testaufruf listAllPlayers', $test['fehler'], false, '');
								}
							} else {
								dgZeile('Testaufruf', 'übersprungen', 'warn', cpMtaHinweis());
							}
							?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>
