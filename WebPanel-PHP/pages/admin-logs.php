<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Logs anzeigen.

	ICE schreibt seine Logs als DATEIEN nach
	ICE-Reallife/vio_stored_files/logs/<name>.log (admin/allround_log.lua) -
	nicht in die Datenbank. Vorher hat diese Seite eine Tabelle "logs"
	erwartet, die ICE nie anlegt, und deshalb nur einen Hinweis gezeigt.

	Jetzt wird der Inhalt ueber die Lua-Funktion getLogContent geholt
	(webpanel/webpanel_server.lua, in der meta.xml mit http="true" exportiert).
	Existiert zusaetzlich eine Tabelle "logs", wird auch die angezeigt.
*/
$logKey  = ((isset($_GET['log']) && is_string($_GET['log'])) ? $_GET['log'] : '');
$logName = ((isset($LogNames[$logKey])) ? $LogNames[$logKey] : $logKey);

// Nur Logs aus der Liste zulassen (kein ../ und keine fremden Dateien).
$logErlaubt = isset($LogNames[$logKey]);
?>
<div class="row">
	<div class="col-md-3">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-list"></i> Logdateien
			</div>
			<div class="panel-body" style="max-height: 600px; overflow-y: auto;">
				<div class="list-group">
					<?php
					foreach ($LogNames as $key => $name) {
						$aktiv = (($key == $logKey) ? ' active' : '');
						echo '<a class="list-group-item'.$aktiv.'" href="?page=admin-logs&log='.urlencode($key).'">'.htmlspecialchars($name).'</a>';
					}
					?>
				</div>
			</div>
		</div>
	</div>

	<div class="col-md-9">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-file-text-o"></i> <?=(($logKey == '') ? 'Log auswählen' : 'Log: '.htmlspecialchars($logName))?>
			</div>
			<div class="panel-body">
				<?php
				if ($logKey == '') {
					echo '<p>Wähle links eine Logdatei aus. Die neuesten Einträge stehen jeweils oben.</p>';
				} else if (!$logErlaubt) {
					echo '<div class="alert alert-danger"><b>Unbekanntes Log.</b><br>
					Erlaubt sind nur die Logs aus der Liste (Array <code>$LogNames</code> in <code>cfg.php</code>).</div>';
				} else {

					$inhalt		= "";
					$quelle		= "";
					$fehler		= "";

					/*
						1) Logdatei direkt von der Festplatte lesen.
						   Klappt, wenn das Panel auf demselben Rechner wie der
						   MTA-Server liegt - dafuer braucht es keine
						   MTA-Verbindung und keine Zugangsdaten.
					*/
					$datei = cpLeseLogDatei($logKey);
					if ($datei !== false) {
						if ($datei === '') {
							$fehler = 'Die Logdatei <code>'.htmlspecialchars($logKey).'.log</code> ist leer.';
						} else {
							$inhalt = $datei;
							$quelle = 'Logdatei auf diesem Server (<code>'.htmlspecialchars(cpIceLogPfad()).'</code>)';
						}
					} else if (cpIceLogPfad() === false) {
						$fehler = 'Der ICE-Ordner wurde auf diesem Server nicht gefunden.
						Trage ihn in <code>cfg.php</code> bei <code>ICE_RESOURCE_PFAD</code> ein
						(siehe <a href="?page=diagnose">System-Check</a>).';
					} else {
						$fehler = 'Für <code>'.htmlspecialchars($logKey).'</code> gibt es noch keine Logdatei
						- ICE legt sie erst an, wenn das erste Mal etwas passiert.';
					}

					// 2) Sonst ueber den MTA-Server versuchen
					if ($inhalt == "" && cpMtaBereit()) {
						$antwort = cpMtaCall("getLogContent", array($logKey));
						if ($antwort['ok'] && $antwort['wert'] != '' && strpos($antwort['wert'], 'existiert noch keine') === false) {
							$inhalt = $antwort['wert'];
							$quelle = 'Logdatei über den MTA-Server geholt';
							$fehler = "";
						}
					}

					// 3) Falls es zusaetzlich eine Tabelle "logs" gibt, diese benutzen
					if ($inhalt == "" && cpTableExists($mySQLcon, 'logs')) {
						$zeilen = array();
						$sql = $mySQLcon->query("SELECT Text FROM logs WHERE Typ='".$mySQLcon->escape_string($logKey)."' ORDER BY Timestamp DESC LIMIT 1000");
						while ($sql && $row = $sql->fetch_assoc()) {
							$zeilen[] = $row['Text'];
						}
						if (count($zeilen) > 0) {
							$inhalt = implode("\n", $zeilen);
							$quelle = 'Tabelle <code>logs</code> in der Datenbank';
							$fehler = "";
						}
					}

					if ($inhalt == "") {
						echo '<div class="alert alert-warning"><b>Dieses Log konnte nicht gelesen werden.</b><br>'.$fehler.'</div>';
					} else {
						echo '<p><small>Quelle: '.$quelle.'</small></p>';
						echo '<textarea class="form-control" rows="28" readonly style="font-family: monospace; font-size: 12px; white-space: pre;">'.htmlspecialchars($inhalt).'</textarea>';
					}
				}
				?>
			</div>
		</div>
	</div>
</div>
