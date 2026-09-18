<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Admin-Uebersicht.

	Die Spielerliste kommt immer aus der Tabelle "loggedin", die ICE selbst
	pflegt (register_login/loggedin_mysql.lua) - die funktioniert also auch
	ohne MTA-Verbindung.

	Sind die Live-Funktionen eingerichtet (cfg.php: MTA_WEB_FUNCTIONS +
	MTA_USER/MTA_PASS, Lua-Seite: webpanel/webpanel_server.lua), kommen bei
	jedem Spieler zusaetzlich Kick / Timeban / Permaban / Screenshot /
	Nachricht dazu.
*/
$mtaAktiv = cpMtaBereit();
?>
<?php if (!$mtaAktiv) { ?>
<div class="alert alert-warning">
	<b>Die Live-Funktionen (Kick, Screenshot, Nachricht) sind noch nicht einsatzbereit.</b><br>
	<?=cpMtaHinweis()?><br><br>
	Ohne sie funktioniert trotzdem alles, was über die Datenbank läuft:
	Spielerliste, <a href="?page=admin-bans">Bans</a>, Coins, Spielerdaten und Massenaktionen.
</div>
<?php } ?>

<?php
/*
	Tabs statt einer langen Liste von Kaesten untereinander - sonst wird
	die Seite mit Spielerliste, Aktionen, Coins, Namensaenderung,
	Massenaktionen und Multi-Accounts schnell unuebersichtlich.

	Nach einem Formular-Submit (POST) bleibt der passende Tab aktiv,
	damit die Erfolgs-/Fehlermeldung sichtbar bleibt statt hinter Tab 1
	zu verschwinden.
*/
$activeTab = 'spieler';
if (isset($_POST['giveCoins']) || isset($_POST['adminRename'])) { $activeTab = 'coins'; }
else if (isset($_POST['maction'])) { $activeTab = 'massen'; }
?>
<ul class="nav nav-tabs" role="tablist">
	<li role="presentation" class="<?=(($activeTab == 'spieler') ? 'active' : '')?>"><a href="#tab-spieler" aria-controls="tab-spieler" role="tab" data-toggle="tab"><i class="fa fa-users"></i> Spieler</a></li>
	<li role="presentation" class="<?=(($activeTab == 'coins') ? 'active' : '')?>"><a href="#tab-coins" aria-controls="tab-coins" role="tab" data-toggle="tab"><i class="fa fa-heart"></i> Coins &amp; Name</a></li>
	<li role="presentation" class="<?=(($activeTab == 'massen') ? 'active' : '')?>"><a href="#tab-massen" aria-controls="tab-massen" role="tab" data-toggle="tab"><i class="fa fa-exclamation-triangle"></i> Massenaktionen</a></li>
</ul>
<div class="tab-content">
<div role="tabpanel" class="tab-pane <?=(($activeTab == 'spieler') ? 'active' : '')?>" id="tab-spieler" style="padding-top: 15px;">
<div class="row">
	<div class="col-md-<?=(($mtaAktiv) ? '7' : '12')?>">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-users"></i> Spieler inGame
			</div>
			<div class="panel-body">
				<div id="AjaxResult"></div>
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<tr>
								<th>Name</th>
								<th>Fraktion</th>
								<th>Level</th>
								<th>Admin</th>
								<th>Aktionen</th>
							</tr>
						</thead>
						<tbody>
							<?php
							$onlineAnzahl = 0;
							$sql = $mySQLcon->query("SELECT u.Name AS Name, u.Fraktion AS Fraktion, u.level AS Lvl, u.Adminlevel AS Adminlevel
								FROM loggedin l JOIN userdata u ON u.UID = l.UID
								WHERE l.Loggedin='1' ORDER BY u.Name ASC");
							while ($sql && $row = $sql->fetch_assoc()) {
								$onlineAnzahl++;
								$fID = (int)$row['Fraktion'];
								$fName = ((isset($factions[$fID])) ? $factions[$fID]['name'] : 'Unbekannt ('.$fID.')');
								$fRGB = ((isset($factions[$fID])) ? $factions[$fID]['rgb'] : '200,200,200');
								$pName = $row['Name'];
								$jsName = htmlspecialchars(addslashes($pName));

								/*
									Kick/Ban/Nachricht/Screenshot stehen rechts im Panel
									"Aktion fuer einen Spieler" - hier waeren sie doppelt.
									Der Button uebernimmt den Namen einfach dorthin.
								*/
								$aktionen = '<a href="?page=admin-checkplayer&nick='.urlencode($pName).'">Überprüfen</a>';
								if ($mtaAktiv) {
									$aktionen .= ' &middot; <a href="#" onclick="nameUebernehmen(\''.$jsName.'\'); return false;">Aktion wählen</a>';
								}

								echo '<tr>
									<td><b>'.htmlspecialchars($pName).'</b></td>
									<td><span style="color:rgb('.$fRGB.');">'.htmlspecialchars($fName).'</span></td>
									<td>'.(int)$row['Lvl'].'</td>
									<td>'.(((int)$row['Adminlevel'] > 0) ? htmlspecialchars(cpAdminRangName($row['Adminlevel'])) : '-').'</td>
									<td>'.$aktionen.'</td>
								</tr>';
							}

							if ($onlineAnzahl == 0) {
								echo '<tr><td colspan="5">Derzeit ist kein Spieler eingeloggt.</td></tr>';
							}
							?>
						</tbody>
					</table>
				</div>
				<p>
					<b><?=$onlineAnzahl?></b> <?=(($onlineAnzahl == 1) ? 'Spieler' : 'Spieler')?> eingeloggt.
					<a href="?page=admin-players" class="btn btn-xs btn-default">Aktualisieren</a>
				</p>
			</div>
		</div>
	</div>

	<?php if ($mtaAktiv) { ?>
	<div class="col-md-5">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-bolt"></i> Aktion für einen Spieler
			</div>
			<div class="panel-body">
				<p>
					Funktioniert auch, wenn der Spieler oben nicht in der Liste steht —
					einfach den Namen eintippen. Der Spieler muss im Spiel sein.
				</p>
				<div class="form-group">
					<label>Spielername</label>
					<input class="form-control" type="text" id="aktionName" placeholder="genau wie im Spiel" />
				</div>
				<div class="form-group">
					<label>Grund <small class="text-muted">(bei Kick und Ban)</small></label>
					<input class="form-control" type="text" id="aktionGrund" />
				</div>
				<div class="form-group">
					<label>Zeit in Stunden <small class="text-muted">(nur Timeban, 0.5 = 30 Minuten)</small></label>
					<input class="form-control" type="text" id="aktionZeit" value="1" />
				</div>

				<button class="btn btn-warning" onclick="aktionAusfuehren('kick'); return false;">Kicken</button>
				<button class="btn btn-danger" onclick="aktionAusfuehren('timeban'); return false;">Timeban</button>
				<button class="btn btn-danger" onclick="aktionAusfuehren('permaban'); return false;">Permaban</button>
				<br><br>
				<button class="btn btn-default" onclick="aktionAusfuehren('msg'); return false;">Nachricht schicken</button>
				<button class="btn btn-default" onclick="aktionAusfuehren('screen'); return false;">Screenshot</button>

				<p style="margin-top: 10px;">
					<small class="text-muted">
						Kick und Ban brauchen mindestens Adminlevel 2 (<?=cpAdminRangName(2)?>), Entbannen 3 (<?=cpAdminRangName(3)?>).
						Ein Ban ohne laufenden Server geht über <a href="?page=admin-bans">Bans verwalten</a>.
					</small>
				</p>
			</div>
		</div>

		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-camera"></i> Screenshot
			</div>
			<div class="panel-body">
				<div id="AjaxResultScreen"></div>
				<img alt="" id="screen" width="100%" />
			</div>
		</div>

		<?php if ($CP->Adminlvl >= 3) { ?>
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-ticket"></i> Beta-Zugang
			</div>
			<div class="panel-body">
				<p>
					Erstellt einen neuen Beta-Zugangscode (einmal einlösbar, ohne Ablaufdatum) -
					auch nutzbar, wenn gerade niemand am MTA-Server sitzt und ein Tester
					wartet. Wirkt nur, solange die Beta im Spiel aktiv ist.
				</p>
				<div id="AjaxResultBeta"></div>
				<button class="btn btn-default" onclick="betaCodeErstellen(); return false;">Beta-Code erstellen</button>
			</div>
		</div>
		<?php } ?>
	</div>
	<?php } ?>
</div>
</div>
<!-- /. TAB SPIELER -->

<div role="tabpanel" class="tab-pane <?=(($activeTab == 'coins') ? 'active' : '')?>" id="tab-coins" style="padding-top: 15px;">
<div class="row">
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-heart"></i> Coins gutschreiben
			</div>
			<div class="panel-body">
				<?php
				/*
					ICE hat keine "coins"-Tabelle: Coins stehen direkt in
					userdata.Coins und werden hier manuell gutgeschrieben.
				*/
				if ($CP->Adminlvl >= 5) {
					if (isset($_POST['giveCoins']) && cpCsrfPruefen()) {
						$count = ((isset($_POST['count'])) ? $_POST['count'] : 0);
						$pname = ((isset($_POST['pname'])) ? trim($_POST['pname']) : '');

						if (!is_numeric($count) || $count <= 0) {
							echo '<div class="alert alert-danger"><b>Bitte gib eine gültige Anzahl ein.</b></div>';
						} else if ($pname == "") {
							echo '<div class="alert alert-danger"><b>Bitte gib einen Spielernamen ein.</b></div>';
						} else if (cpSpielerIstOnline($mySQLcon, $pname)) {
							/*
								ICE schreibt die Coins beim Ausloggen aus dem Speicher
								zurueck - eine Gutschrift waere dann wieder weg.
							*/
							echo '<div class="alert alert-danger"><b>'.htmlspecialchars($pname).' ist gerade ingame eingeloggt.</b><br>
							Die Coins würden beim Ausloggen überschrieben. Bitte warte, bis der Spieler offline ist.</div>';
						} else if ($CP->givePlayerCoins($pname, (int)$count, "Coin-Gutschrift (Admin: ".$CP->Name." Spieler: ".$pname.")")) {
							echo '<div class="alert alert-info">'.(int)$count.' Coins an <b>'.htmlspecialchars($pname).'</b> gutgeschrieben.</div>';
							cpWriteLog("admin.log", $CP->Name." hat ".$pname." ".(int)$count." Coins gutgeschrieben.");
						} else {
							echo '<div class="alert alert-danger"><b>Der Spieler wurde nicht gefunden.</b></div>';
						}
					}
				?>
				<p>Coins werden direkt in <code>userdata.Coins</code> gutgeschrieben.</p>
				<form method="post" action="?page=admin-players">
					<?=cpCsrfFeld()?>
					<div class="form-group">
						<label>Spielername</label>
						<input class="form-control" type="text" name="pname" />
					</div>
					<div class="form-group">
						<label>Anzahl Coins</label>
						<input class="form-control" type="text" name="count" />
					</div>
					<button type="submit" class="btn btn-default" name="giveCoins">Gutschreiben</button>
				</form>
				<?php
				} else {
					echo '<div class="alert alert-danger"><b>Du brauchst mindestens Adminlevel 5 ('.cpAdminRangName(5).').</b></div>';
				}
				?>
			</div>
		</div>
	</div>

	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-id-card"></i> Namen ändern (Admin)
			</div>
			<div class="panel-body">
				<?php
				/*
					Direkte Namensaenderung ohne Coins - fuer Sonderfaelle
					(Beleidigungen, Rechtschreibfehler, Support-Faelle).
					Adminlevel 5, damit es zur Sperre in admin-userdata.php passt
					(dort ist "Name" fuer alle unter Level 5 gesperrt).
				*/
				if ($CP->Adminlvl >= 5) {
					if (isset($_POST['adminRename']) && cpCsrfPruefen()) {
						$alt = ((isset($_POST['altname'])) ? trim($_POST['altname']) : '');
						$neu = ((isset($_POST['neuname'])) ? trim($_POST['neuname']) : '');
						$len = strlen($neu);
						$verboten = array("none", "admin", "mtasa", "mta");
						// Gleiche Regeln wie bei der Coins-Namensaenderung (pages/coins.php).
						$zeichenOk = ($len > 0 && preg_match('/^[A-Za-z0-9\-_\[\]~.|!#@]+$/', $neu) === 1);

						$sqlAlt = $mySQLcon->query("SELECT UID, Adminlevel FROM userdata WHERE Name='".$mySQLcon->escape_string($alt)."'");
						$rowAlt = (($sqlAlt && $sqlAlt->num_rows > 0) ? $sqlAlt->fetch_assoc() : false);

						if (!$rowAlt) {
							echo '<div class="alert alert-danger"><b>Es gibt keinen Spieler mit dem Namen "'.htmlspecialchars($alt).'".</b></div>';

						// Rangordnung: siehe admin-userdata.php - kein Bearbeiten von gleich-/hoehergestellten Admins.
						} else if ((int)$rowAlt['UID'] != (int)$CP->UID && (int)$rowAlt['Adminlevel'] >= $CP->Adminlvl) {
							echo '<div class="alert alert-danger"><b>'.htmlspecialchars($alt).' hat ein gleich hohes oder höheres Adminlevel.</b><br>
							Dessen Namen kannst Du nicht ändern.</div>';

						} else if (!$zeichenOk || $len < 3 || $len > 20 || in_array(strtolower($neu), $verboten)) {
							echo '<div class="alert alert-danger"><b>Der neue Name ist ungültig.</b><br>
							Erlaubt sind 3 bis 20 Zeichen: Buchstaben, Zahlen und - _ [ ] ~ . | ! # @</div>';

						} else if (strtolower($alt) == strtolower($neu)) {
							echo '<div class="alert alert-info">Das ist bereits der aktuelle Name.</div>';

						} else if (cpSpielerIstOnline($mySQLcon, $alt)) {
							echo '<div class="alert alert-danger"><b>'.htmlspecialchars($alt).' ist gerade ingame eingeloggt.</b><br>
							ICE würde den Namen beim Ausloggen wieder überschreiben. Bitte warte, bis der Spieler offline ist.</div>';

						} else {
							$sqlNeu = $mySQLcon->query("SELECT UID FROM userdata WHERE Name='".$mySQLcon->escape_string($neu)."'");
							if ($sqlNeu && $sqlNeu->num_rows > 0) {
								echo '<div class="alert alert-danger"><b>Diesen Namen gibt es schon.</b></div>';
							} else {
								$CP->adminRenamePlayer($alt, $neu);
								echo '<div class="alert alert-info"><b>'.htmlspecialchars($alt).'</b> heißt jetzt <b>'.htmlspecialchars($neu).'</b>.</div>';
								cpWriteLog("admin.log", $CP->Name." hat ".$alt." in ".$neu." umbenannt.");
							}
						}
					}
				?>
				<p>Ändert den Namen eines Spielers direkt - ohne Coins. Der Spieler muss ingame offline sein.</p>
				<form method="post" action="?page=admin-players">
					<?=cpCsrfFeld()?>
					<div class="form-group">
						<label>Aktueller Name</label>
						<input class="form-control" type="text" name="altname" />
					</div>
					<div class="form-group">
						<label>Neuer Name</label>
						<input class="form-control" type="text" name="neuname" maxlength="20" />
					</div>
					<button type="submit" class="btn btn-default" name="adminRename">Umbenennen</button>
				</form>
				<?php
				} else {
					echo '<div class="alert alert-danger"><b>Du brauchst mindestens Adminlevel 5 ('.cpAdminRangName(5).').</b></div>';
				}
				?>
			</div>
		</div>
	</div>
</div>
</div>
<!-- /. TAB COINS -->

<div role="tabpanel" class="tab-pane <?=(($activeTab == 'massen') ? 'active' : '')?>" id="tab-massen" style="padding-top: 15px;">
<div class="row">
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-exclamation-triangle"></i> Massenaktionen
			</div>
			<div class="panel-body">
				<?php
				if (isset($_POST['maction']) && cpCsrfPruefen()) {
					if ($CP->Adminlvl >= 4) {
						$aktion = ((isset($_POST['action'])) ? $_POST['action'] : '');
						$ok = true;

						switch ($aktion) {
							case 'bans':
								$mySQLcon->query("TRUNCATE ban");
							break;
							case 'warns':
								$mySQLcon->query("TRUNCATE warns");
								$mySQLcon->query("UPDATE userdata SET Warns='0'");
							break;
							case 'kickFaction':
								$mySQLcon->query("UPDATE userdata SET Fraktion='0', FraktionsRang='0'");
							break;
							case 'blacklist':
								$mySQLcon->query("TRUNCATE blacklist");
							break;
							case 'wanteds':
								$mySQLcon->query("UPDATE userdata SET Wanteds='0'");
							break;
							case 'stvo':
								$mySQLcon->query("UPDATE userdata SET StvoPunkte='0'");
							break;
							default:
								$ok = false;
						}

						if ($ok == false) {
							echo '<div class="alert alert-danger"><b>Unbekannte Aktion.</b></div>';
						} else if ($mySQLcon->errno) {
							echo '<div class="alert alert-danger"><b>Datenbankfehler:</b> '.htmlspecialchars($mySQLcon->error).'</div>';
						} else {
							echo '<div class="alert alert-info">Aktion ausgeführt.</div>';
							cpWriteLog("admin.log", $CP->Name." hat die Massenaktion \"".$aktion."\" ausgefuehrt.");
						}
					} else {
						echo '<div class="alert alert-danger">Du benötigst mindestens Adminlevel 4 ('.cpAdminRangName(4).').</div>';
					}
				}
				?>
				<p><b>Achtung:</b> Diese Aktionen betreffen ALLE Spieler und lassen sich nicht rückgängig machen.
				Spieler, die gerade online sind, überschreiben ihre Werte beim Ausloggen ggf. wieder.</p>
				<form method="post" action="?page=admin-players" onsubmit="return confirm('Diese Aktion betrifft alle Spieler. Wirklich ausführen?');">
					<?=cpCsrfFeld()?>
					<div class="form-group">
						<label>Aktion</label>
						<select name="action" class="form-control">
							<option value="bans">Alle Spieler entbannen</option>
							<option value="warns">Alle Warns löschen</option>
							<option value="kickFaction">Alle Spieler aus den Fraktionen werfen</option>
							<option value="blacklist">Fraktions-Blacklist leeren</option>
							<option value="wanteds">Alle Wanteds zurücksetzen</option>
							<option value="stvo">Alle STVO-Punkte zurücksetzen</option>
						</select>
					</div>
					<button type="submit" class="btn btn-default" name="maction">Aktion Ausführen</button>
				</form>
			</div>
		</div>
	</div>
</div>
<div class="row">
	<div class="col-md-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-clone"></i> Multi Accounts (gleiche Serial)
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<tr>
								<th>Account-Namen</th>
								<th>Anzahl</th>
								<th>Serial</th>
							</tr>
						</thead>
						<tbody>
							<?php
							/*
								Vorher wurden alle Spieler einzeln durchlaufen und jede
								doppelte Serial mehrfach in die Liste gelegt - bei drei
								Accounts erschien dieselbe Zeile also zweimal.
								Das macht jetzt die Datenbank in einer Abfrage.
							*/
							$multiAnzahl = 0;
							$sql = $mySQLcon->query("SELECT Serial, COUNT(*) AS Anzahl, GROUP_CONCAT(Name ORDER BY Name SEPARATOR ', ') AS Namen
								FROM players
								WHERE Serial <> '' GROUP BY Serial HAVING COUNT(*) > 1 ORDER BY Anzahl DESC");
							while ($sql && $row = $sql->fetch_assoc()) {
								$multiAnzahl++;
								echo '<tr>
									<td>'.htmlspecialchars($row['Namen']).'</td>
									<td>'.(int)$row['Anzahl'].'</td>
									<td>'.htmlspecialchars($row['Serial']).'</td>
								</tr>';
							}

							if ($multiAnzahl == 0) {
								echo '<tr><td colspan="3">Keine doppelten Serials gefunden.</td></tr>';
							}
							?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>
</div>
<!-- /. TAB MASSENAKTIONEN -->
</div>
<!-- /. TAB CONTENT -->

<?php if ($mtaAktiv) { ?>
<script>
	// Sicherheitsschlüssel für die AJAX-Aufrufe (siehe usefull.php, cpCsrfToken)
	var cpToken = "<?=cpCsrfToken()?>";

	/*
		Aktion über die Eingabefelder ausführen.
		Praktisch, wenn der Spieler nicht in der Liste oben steht.
	*/
	function aktionAusfuehren(action) {
		var name = $.trim($("#aktionName").val());
		if (name === "") {
			alert("Bitte einen Spielernamen eintragen.");
			$("#aktionName").focus();
			return false;
		}

		if (action === "screen") { return takeScreen(name); }

		var grund = $.trim($("#aktionGrund").val());
		var zeit  = $.trim($("#aktionZeit").val());
		var text  = "";

		if (action === "kick" || action === "timeban" || action === "permaban") {
			if (grund === "") {
				alert("Bitte einen Grund angeben.");
				$("#aktionGrund").focus();
				return false;
			}
		}

		if (action === "msg") {
			text = prompt("Nachricht an " + name + ":", "");
			if (!text) { return false; }
		}

		if (action === "permaban" && !confirm(name + " permanent bannen?")) { return false; }

		$("#AjaxResult").html('<div class="alert alert-info">Bitte warten...</div>');
		$.get("ajax/admin.php", {
			action: action,
			player: name,
			reason: grund,
			time: zeit,
			msg: text,
			cptoken: cpToken
		}, function(data) {
			$("#AjaxResult").html('<div class="alert alert-info">' + data + '</div>');
		}).fail(function() {
			$("#AjaxResult").html('<div class="alert alert-danger">Die Anfrage ist fehlgeschlagen.</div>');
		});
		return false;
	}

	/*
		Traegt den Namen aus der Tabelle rechts in das Aktions-Panel ein,
		damit man ihn nicht abtippen muss.
	*/
	function nameUebernehmen(playername) {
		$("#aktionName").val(playername);
		$("#aktionGrund").focus();
		return false;
	}

	function betaCodeErstellen() {
		$("#AjaxResultBeta").html('<div class="alert alert-info">Bitte warten...</div>');
		$.get("ajax/admin.php", { action: "betacode", cptoken: cpToken }, function(data) {
			$("#AjaxResultBeta").html('<div class="alert alert-info">' + data + '</div>');
		}).fail(function() {
			$("#AjaxResultBeta").html('<div class="alert alert-danger">Die Anfrage ist fehlgeschlagen.</div>');
		});
		return false;
	}

	function takeScreen(nick) {
		$("#screen").attr("src", "");
		$("#AjaxResultScreen").html('<div class="alert alert-info">Screenshot wird angefordert...</div>');

		$.get("ajax/admin.php", { action: "screen", player: nick, cptoken: cpToken }, function(data) {
			$("#AjaxResultScreen").html('<div class="alert alert-info">' + data + '</div>');

			if (data.indexOf("Einen moment") === 0) {
				var versuche = 0;

				var pruefe = function() {
					versuche = versuche + 1;

					$.get("ajax/admin.php", { action: "screen-result", cptoken: cpToken }, function(data) {
						if (data != "") {
							var res = data.split("|");
							if (res[0] == "err") {
								$("#AjaxResultScreen").html('<div class="alert alert-danger">' + res[1] + '</div>');
								return;
							} else if (res[0] == "img") {
								$("#AjaxResultScreen").html('');
								$("#screen").attr("src", "data:image/jpeg;base64," + res[1]);
								return;
							}
						}

						if (versuche <= 6) {
							setTimeout(pruefe, 2500);
						} else {
							$("#AjaxResultScreen").html('<div class="alert alert-danger">Es konnte kein Screenshot erstellt werden (keine Antwort vom Spieler).</div>');
						}
					});
				};

				setTimeout(pruefe, 2500);
			}
		});
		return false;
	}
</script>
<?php } ?>
