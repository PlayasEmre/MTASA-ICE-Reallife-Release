<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
?>
<div class="row">
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				Passwort ändern
			</div>
			<div class="panel-body">
				<?php
				/*
					Passwort aendern.

					Zwei Sicherheitspruefungen wurden ergaenzt:

					1. Das AKTUELLE Passwort muss mit eingegeben werden.
					   Vorher konnte jeder, der den Anmelde-Cookie hatte
					   (fremder PC, gestohlener Cookie), das Passwort einfach
					   aendern und damit den Account uebernehmen.

					2. Der Formular-Schluessel (CSRF) wird geprueft, damit eine
					   fremde Webseite das Formular nicht heimlich abschicken kann.
				*/
				if (isset($_POST['pwchange']) && cpCsrfPruefen())  {

					// Aktuelles Passwort pruefen
					$altOk		= false;
					$altEingabe	= ((isset($_POST['pwalt'])) ? $_POST['pwalt'] : '');

					$sqlPW = $mySQLcon->query("SELECT Passwort FROM players WHERE ".$CP->where());
					if ($sqlPW && $sqlPW->num_rows > 0) {
						$rowPW = $sqlPW->fetch_assoc();
						$aktuell = (string)$rowPW['Passwort'];

						// Dieselben Varianten wie beim Login (ICE: doppeltes sha512)
						$moeglich = array(
							hash('sha512', hash('sha512', $altEingabe)),
							hash('md5', $altEingabe),
							hash('sha256', $altEingabe)
						);
						foreach ($moeglich as $versuch) {
							if (hash_equals(strtoupper($aktuell), strtoupper($versuch))) { $altOk = true; break; }
						}
					}

					if (!$altOk) {
						echo '<div class="alert alert-danger"><b>Dein aktuelles Passwort ist falsch.</b><br>
						Zur Sicherheit musst Du es mit eingeben, damit niemand anderes Dein Passwort ändern kann.</div>';

					} else if (!empty($_POST['pw1'])) {
						if (strlen($_POST['pw1']) >= 6) {
							if (preg_match('/^(?=.*\d)(?=.*[A-Za-z])[0-9A-Za-z]{6,30}$/', $_POST['pw1'])) {
								if (isset($_POST['pw2']) && $_POST['pw1'] == $_POST['pw2']) {
									
									$salz = uniqid();
									$gesalzen = "";
									if (SCRIPT_TYPE == "lite") {
										$gesalzen = strtoupper(hash('md5', $_POST['pw1']));
										$salz = false;
									} else if (SCRIPT_TYPE == "extended") {
										$gesalzen = strtoupper(hash('md5', $_POST['pw1'].$salz));
									} else if (SCRIPT_TYPE == "thc") {
										$gesalzen = strtoupper(hash('sha256', $_POST['pw1'].$salz));
									} else if (SCRIPT_TYPE == "Addiction") {
										$gesalzen = strtolower(hash('sha512', strtolower(hash('sha512', $_POST['pw1']))));
										$salz = false;
									} else if (SCRIPT_TYPE == "ICE") {
										/*
											ICE hasht ZWEIMAL mit sha512:
											Der Client sendet hash("sha512", pw), der Server hasht
											erneut (register_login_server.lua Z. 151 / 442,
											account.lua Z. 30). Wird hier nur einmal gehasht,
											kommt der Spieler ingame nicht mehr in seinen Account!
										*/
										$gesalzen = strtolower(hash('sha512', hash('sha512', $_POST['pw1'])));
										$salz = false;
									}


									/*
										Sicherheitsnetz: Bei einem unbekannten SCRIPT_TYPE bliebe
										$gesalzen leer - das Passwort waere dann geloescht und der
										Account nicht mehr benutzbar.
									*/
									if ($gesalzen == "") {
										echo '<div class="alert alert-danger"><b>SCRIPT_TYPE "'.htmlspecialchars(SCRIPT_TYPE).'" ist unbekannt.</b><br>
										Das Passwort wurde NICHT geändert. Bitte in cfg.php SCRIPT_TYPE auf "ICE" setzen.</div>';
									} else {
										$FIX = "";
										if ($salz != false) { $FIX = ", Salt='".$mySQLcon->escape_string($salz)."'"; }
										$mySQLcon->query("UPDATE players SET Passwort='".$mySQLcon->escape_string($gesalzen)."'".$FIX." WHERE ".$CP->where());

										echo '<div class="alert alert-info">Dein Passwort wurde erfolgreich geändert.<br>
										Du kannst dich damit ab jetzt auch ingame anmelden.</div>';
										cpWriteLog("pwchange.log", $CP->Name." hat sein Passwort ueber das Panel geaendert.");
									}
								} else {
									echo '<div class="alert alert-danger"><b>Die Passwörter stimmen nicht überein.</b></div>';
								}
							} else {
								echo '<div class="alert alert-danger"><b>Dein Passwort muss 6 bis 30 Zeichen lang sein und mindestens einen Buchstaben und eine Zahl enthalten (nur Buchstaben und Zahlen, keine Sonderzeichen).</b></div>';
							}
						} else {
							echo '<div class="alert alert-danger"><b>Dein Passwort muss mindestens 6 Zeichen enthalten.</b></div>';
						}
					} else {
						echo '<div class="alert alert-danger"><b>Du hast kein Passwort angegeben.</b></div>';
					}
				}
				?>
				<p>
					Dein Passwort muss 6 bis 30 Zeichen lang sein und mindestens einen Buchstaben und eine Zahl enthalten (nur Buchstaben und Zahlen, keine Sonderzeichen).
				</p>
				<br>
				<form role="form" method="post" action="?page=settings" autocomplete="off">
					<?=cpCsrfFeld()?>
					<div class="form-group">
						<label>Aktuelles Passwort</label>
						<input class="form-control" type="password" name="pwalt" autocomplete="current-password" />
						<small class="text-muted">Zur Sicherheit — damit niemand mit einem fremden Gerät Dein Passwort ändern kann.</small>
					</div>
					<hr>
					<div class="form-group">
						<label>Neues Passwort</label>
						<input class="form-control" type="password" name="pw1" autocomplete="new-password" />
					</div>
					<div class="form-group">
						<label>Neues Passwort (Wiederholung)</label>
						<input class="form-control" type="password" name="pw2" autocomplete="new-password" />
					</div>
					<button type="submit" class="btn btn-default" name="pwchange">Passwort ändern</button>
				</form>
			</div>
		</div>
	</div>
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-shield"></i> Account &amp; Sicherheit
			</div>
			<div class="panel-body">
				<?php
				// Letzter Login, IP und Serial - damit man einen fremden Zugriff erkennt.
				$sqlA = $mySQLcon->query("SELECT * FROM players WHERE ".$CP->where());
				$acc  = (($sqlA && $sqlA->num_rows > 0) ? $sqlA->fetch_assoc() : array());

				/*
					Kleine Hilfsfunktion: leere Felder als "-" anzeigen.
					ICE fuellt Last_login und RegisterDatum erst beim naechsten
					Login/Registrieren - bei alten Accounts koennen sie leer sein.
				*/
				if (!function_exists('accWert')) {
					function accWert($arr, $key) {
						if (!isset($arr[$key])) { return '<span class="text-muted">-</span>'; }
						$wert = trim((string)$arr[$key]);
						if ($wert === '' || $wert === '0') { return '<span class="text-muted">-</span>'; }
						return htmlspecialchars($wert);
					}
				}

				/*
					Letzter Login:
					players.Last_login ist Text (z.B. "26.7.2026, 14:5").
					Ist er leer, wird players.LastLogin (Zahl, siehe getSecTime)
					in ein Datum zurueckgerechnet.
				*/
				$letzterLogin = accWert($acc, 'Last_login');
				if (strpos($letzterLogin, '-</span>') !== false && isset($acc['LastLogin'])) {
					$ausZahl = cpSecTimeZuDatum($acc['LastLogin']);
					if ($ausZahl !== false) {
						$letzterLogin = htmlspecialchars($ausZahl).' <small class="text-muted">(errechnet)</small>';
					}
				}
				?>
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr>
								<td width="45%"><b>Spielername</b></td>
								<td><?=htmlspecialchars($CP->Name)?></td>
							</tr>
							<tr>
								<td><b>Deine UID</b></td>
								<td><?=(int)$CP->UID?></td>
							</tr>
							<tr>
								<td><b>Status im Spiel</b></td>
								<td><?php
								if ($CP->inGameLoggedin) {
									echo '<span style="color:green;"><b>Du bist gerade im Spiel</b></span>';
								} else {
									echo '<b>Offline</b> <small class="text-muted">(nicht im Spiel)</small>';
								}
								echo '<br><small class="text-muted">Ermittelt über: '.htmlspecialchars($CP->InGameQuelle).'</small>';
								?></td>
							</tr>
							<tr>
								<td><b>Spielserver</b></td>
								<td><?php
								$srv = cpMtaAseAbfrage();
								if ($srv && !empty($srv['ok'])) {
									echo '<span style="color:green;">&#9679;</span> <b>'.htmlspecialchars($srv['name']).'</b> ist online<br>
									<small class="text-muted">'.(int)$srv['anzahl'].' von '.(int)$srv['max'].' Spielern
									&middot; '.htmlspecialchars(MTA_IP).':'.(int)MTA_PORT.'</small>';
								} else {
									echo '<span style="color:#c92a2a;">&#9679;</span> nicht erreichbar<br>
									<small class="text-muted">'.htmlspecialchars(MTA_IP).':'.(int)MTA_PORT.'</small>';
								}
								?></td>
							</tr>
							<tr>
								<td><b>Letzter Login ingame</b></td>
								<td><?=$letzterLogin?></td>
							</tr>
							<tr>
								<td><b>Registriert am</b></td>
								<td><?=accWert($acc, 'RegisterDatum')?></td>
							</tr>
							<tr>
								<td><b>Letzte IP</b></td>
								<td><?=accWert($acc, 'IP')?></td>
							</tr>
							<tr>
								<td><b>Serial (PC-Kennung)</b></td>
								<td><small><?=accWert($acc, 'Serial')?></small></td>
							</tr>
							<tr>
								<td><b>Spielzeit</b></td>
								<td><?php
								$sz = (int)$CP->UserData['userdata']['Spielzeit'];
								echo floor($sz / 60).':'.str_pad($sz % 60, 2, "0", STR_PAD_LEFT).' Std.';
								?></td>
							</tr>
							<tr>
								<td><b>Premium</b></td>
								<td><?php
								$pID = (int)$CP->UserData['userdata']['PremiumPaket'];
								if ($CP->LeftVIPDays >= 1000) {
									echo '<b>Lifetime</b>';
								} else if ($CP->LeftVIPDays > 0) {
									echo 'noch <b>'.$CP->LeftVIPDays.'</b> Tage'.((isset($premiumPakete[$pID])) ? ' ('.htmlspecialchars($premiumPakete[$pID]).')' : '');
								} else {
									echo '<span class="text-muted">Inaktiv</span>';
								}
								?></td>
							</tr>
						</tbody>
					</table>
				</div>

				<p>
					<b>Gut zu wissen:</b><br>
					&bull; Dein Passwort gilt für Spiel und Panel gleichzeitig — änderst Du es hier,
					meldest Du dich ingame ab jetzt mit dem neuen Passwort an.<br>
					&bull; Deine Anmeldung im Panel ist an Deine IP-Adresse gebunden. Wechselt sie
					(z.B. neuer Router-Neustart oder Handynetz), wirst Du automatisch abgemeldet —
					das ist Absicht und schützt Deinen Account.<br>
					&bull; Steht oben eine IP oder ein Login-Zeitpunkt, den Du nicht kennst, ändere
					sofort Dein Passwort und melde es einem Admin.
				</p>
				<a href="?page=logout" class="btn btn-danger">Jetzt abmelden</a>
			</div>
		</div>
	</div>
</div>