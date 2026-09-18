<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Coin-Seite.

	Umgebaut fuer ICE:

	1. "Premiumfahrzeug kaufen" und "inGame-Geld kaufen" sind entfernt.
	   Premium-Fahrzeuge gibt es ingame mit /pcar, Geld soll es nicht geben.

	2. Premium-Mitgliedschaft: der Spieler waehlt einen der fuenf ICE-Raenge
	   (Bronze bis TOP DONATOR) mit Laufzeit und Preis aus cfg.php
	   ($premiumAngebote). Solange die Mitgliedschaft laeuft, kann nichts
	   Neues gekauft werden.

	3. Telefonnummer, Name, Status und Skin brauchen aktives Premium
	   (cfg.php: COINS_NUR_MIT_PREMIUM).

	4. Jede Funktion laesst sich in cfg.php ein- und ausschalten
	   ($coinFunktionen) - ausgeschaltete Funktionen sind auch ueber die
	   URL nicht erreichbar.

	Wichtig: Alle Aktionen, die etwas in "userdata" schreiben, gehen nur,
	wenn der Spieler ingame OFFLINE ist. Grund: ICE haelt die Werte
	waehrend des Spielens im Speicher und schreibt sie zurueck - eine
	Aenderung ueber das Panel waere sonst gleich wieder weg.
*/

if (!USE_COINS) {
	header("Location: ?page=home");
	exit;
}

// -------------------------------------------------------------------
// Grunddaten
// -------------------------------------------------------------------
$act = ((isset($_GET['act']) && is_string($_GET['act'])) ? $_GET['act'] : '');

/*
	Es gibt keine Online-Bezahlung mehr (PayPal und Paysafecard sind
	entfernt). Coins vergibt ein Admin - siehe cfg.php.
*/

// Ist eine Funktion in cfg.php eingeschaltet?
if (!function_exists('coinFunktionAn')) {
	function coinFunktionAn($name) {
		global $coinFunktionen;
		return (isset($coinFunktionen[$name]) && $coinFunktionen[$name] == true);
	}
}

// Premium aktiv?  (LeftVIPDays kommt aus cp.class.php -> userdata.PremiumData)
$premiumAktiv		= ($CP->LeftVIPDays > 0);
$premiumUnbegrenzt	= ($CP->LeftVIPDays >= 1000);
$premiumPaketID		= (int)$CP->UserData['userdata']['PremiumPaket'];
$premiumPaketName	= ((isset($premiumPakete[$premiumPaketID])) ? $premiumPakete[$premiumPaketID] : 'unbekannt');

// Braucht diese Funktion Premium?
$premiumPflicht = array("tel", "nick", "state");

/*
	Alle Aktionen schreiben in die Datenbank - deshalb muss der Spieler
	ingame ausgeloggt sein (ICE ueberschreibt sonst beim Ausloggen).
*/
$brauchtOffline = array("premium", "tel", "nick", "state", "giveaway", "tacticreset");

// Darf der Spieler die gewaehlte Aktion ueberhaupt benutzen?
$sperre = "";
if ($act != "") {
	if (!coinFunktionAn($act)) {
		$sperre = 'Diese Funktion ist derzeit abgeschaltet.';

	} else if (COINS_NUR_MIT_PREMIUM && in_array($act, $premiumPflicht) && !$premiumAktiv) {
		$sperre = 'Diese Funktion ist nur für <b>Premium-Mitglieder</b>.';

	} else if (in_array($act, $brauchtOffline) && $CP->inGameLoggedin) {
		$sperre = '<b>Du bist gerade im Spiel eingeloggt.</b><br>
		Logge dich im Spiel aus und lade diese Seite neu — sonst würde der Server
		die Änderung beim Ausloggen wieder überschreiben.';
	}
}
?>
<div class="row">
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-heart"></i> Deine Coins
			</div>
			<div class="panel-body">
				<p style="font-size: 26px; margin: 0 0 10px 0;">
					<b><?=number_format((int)$CP->Coins,0,"",".")?></b>
					<small class="text-muted">Coins</small>
				</p>

				<p>
					<b>Premium-Status:</b>
					<?php
					if ($premiumUnbegrenzt) {
						echo '<span class="label label-warning">'.htmlspecialchars($premiumPaketName).' &middot; unbegrenzt</span>';
					} else if ($premiumAktiv) {
						echo '<span class="label label-success">'.htmlspecialchars($premiumPaketName).' &middot; noch '.(int)$CP->LeftVIPDays.' Tage</span>';
					} else {
						echo '<span class="label label-default">nicht aktiv</span>';
					}
					?>
				</p>

				<hr>
				<p>
					Coins bekommst Du von einem Administrator. Damit kannst Du:
				</p>
				<ul>
					<?php if (coinFunktionAn('premium')) { ?><li>eine <b>Premium-Mitgliedschaft</b> kaufen</li><?php } ?>
					<?php if (coinFunktionAn('tel')) { ?><li>deine Telefonnummer ändern</li><?php } ?>
					<?php if (coinFunktionAn('nick')) { ?><li>deinen Namen ändern</li><?php } ?>
					<?php if (coinFunktionAn('state')) { ?><li>deinen sozialen Status ändern</li><?php } ?>
					<?php if (coinFunktionAn('giveaway')) { ?><li>Coins an andere Spieler verschenken</li><?php } ?>
					<?php if (coinFunktionAn('tacticreset')) { ?><li>deine Tactic Kills/Tode zurücksetzen</li><?php } ?>
				</ul>

				<?php if (COINS_NUR_MIT_PREMIUM) { ?>
				<div class="alert alert-info" style="font-size: 12px;">
					Telefonnummer, Name und Status sind für <b>Premium-Mitglieder</b>.
					Die Mitgliedschaft selbst und das Verschenken von Coins gehen immer.
				</div>
				<?php } ?>

				<?php
				/*
					Offline-Hinweis - und zwar VORHER, nicht erst nach dem Klick.
					Grund: ICE haelt die Werte waehrend des Spielens im Speicher
					und schreibt sie beim Ausloggen zurueck. Eine Aenderung ueber
					das Panel waere sonst wieder weg.
				*/
				if ($CP->inGameLoggedin) {
					echo '<div class="alert alert-warning" style="margin-bottom: 0;">
						<b>Du bist gerade im Spiel eingeloggt.</b><br>
						Solange Du ingame online bist, kann das Panel nichts an deinem Account ändern —
						der Server würde es beim Ausloggen überschreiben.<br><br>
						<b>Also:</b> im Spiel ausloggen, dann diese Seite neu laden. Danach geht alles.
					</div>';
				} else {
					echo '<div class="alert alert-success" style="margin-bottom: 0;">
						<b>Du bist ingame offline</b> — alle Coin-Funktionen sind jetzt benutzbar.
					</div>';
				}
				?>
			</div>
		</div>

		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-question-circle"></i> Wie bekomme ich Coins?
			</div>
			<div class="panel-body">
				<p>
					Coins gibt es <b>nicht gegen Geld</b>. Eine Online-Bezahlung ist im Panel
					nicht eingebaut.
				</p>
				<p>
					Du bekommst Coins von einem <b>Administrator</b> — zum Beispiel als
					Belohnung für Events, Aufgaben oder als Dankeschön fürs Mithelfen.
					Frag am besten im Spiel oder im Forum nach.
				</p>
			</div>
		</div>
	</div>

	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-list"></i> <?=(($act == '') ? 'Was möchtest Du machen?' : 'Aktion')?>
			</div>
			<div class="panel-body">
				<?php
				// ---------------------------------------------------------
				// Gesperrt? Dann hier raus.
				// ---------------------------------------------------------
				if ($sperre != "") {
					echo '<div class="alert alert-danger">'.$sperre.'</div>';
					if (COINS_NUR_MIT_PREMIUM && in_array($act, $premiumPflicht) && !$premiumAktiv && coinFunktionAn('premium')) {
						echo '<p><a href="?page=coins&act=premium" class="btn btn-warning">Premium-Mitgliedschaft ansehen</a></p>';
					}
					echo '<p><a href="?page=coins">Zurück zur Übersicht</a></p>';
					$act = 'gesperrt';
				}

				switch ($act) {

				// =========================================================
				// Premium-Mitgliedschaft kaufen
				// =========================================================
				case 'premium':

					if (isset($_POST['buyPrem']) && cpCsrfPruefen()) {
						// Gewaehlt wird die Zeilennummer aus $premiumAngebote (cfg.php).
						$auswahl	= ((isset($_POST['angebot'])) ? $_POST['angebot'] : '');
						$angebot	= ((isset($premiumAngebote[$auswahl])) ? $premiumAngebote[$auswahl] : false);
						$rang		= (($angebot) ? (int)$angebot['rang'] : 0);

						if (!$angebot || !isset($premiumPakete[$rang])) {
							echo '<div class="alert alert-danger"><b>Bitte wähle ein Paket aus.</b></div>';

						} else if ($premiumAktiv) {
							// Doppelt gesichert: auch wenn jemand das Formular direkt abschickt.
							echo '<div class="alert alert-danger"><b>Du hast noch eine laufende Mitgliedschaft.</b><br>
							Ein neues Paket kannst Du erst kaufen, wenn sie abgelaufen ist.</div>';

						} else if ($CP->Coins < (int)$angebot['coins']) {
							echo '<div class="alert alert-danger"><b>Du hast nicht genug Coins.</b><br>
							Das Paket kostet '.(int)$angebot['coins'].' Coins, Du hast '.(int)$CP->Coins.'.</div>';

						} else if ($CP->inGameLoggedin == true) {
							echo '<div class="alert alert-danger"><b>Du bist gerade ingame eingeloggt.</b><br>
							Melde dich im Spiel ab und lade die Seite neu — sonst überschreibt der Server den Kauf.</div>';

						} else {
							/*
								ICE speichert das Premium-Ende als DATETIME in
								userdata.PremiumData und den Rang in userdata.PremiumPaket
								(siehe register_login/premium.lua -> setPremiumData).

								tage = 0 bedeutet unbegrenzt. FROM_UNIXTIME kann nur bis
								19.01.2038 rechnen, deshalb wird dort gedeckelt.
							*/
							$tage = (int)$angebot['tage'];
							if ($tage <= 0) {
								$premUntil = 2147483647;
							} else {
								$premUntil = time() + (86400 * $tage);
								if ($premUntil > 2147483647) { $premUntil = 2147483647; }
							}

							$rangName = ((isset($premiumPakete[$rang])) ? $premiumPakete[$rang] : 'Paket '.$rang);

							/*
								ERST bezahlen, DANN freischalten.
								takePlayerCoins bucht in der Datenbank ab und liefert
								false, wenn nicht genug Coins da sind - so kann man auch
								mit zwei schnellen Klicks nicht zweimal kaufen.
							*/
							if (!$CP->takePlayerCoins((int)$angebot['coins'], "Spieler: ".$CP->Name." ; Premium ".$rangName." (".$tage." Tage)")) {
								echo '<div class="alert alert-danger"><b>Die Coins konnten nicht abgebucht werden.</b><br>
								Vermutlich hast Du sie zwischenzeitlich ausgegeben. Lade die Seite neu.</div>';

							} else {
								// PremiumData ist DATETIME - FROM_UNIXTIME wandelt den
								// berechneten Zeitstempel in das Spaltenformat um.
								$mySQLcon->query("UPDATE userdata SET PremiumPaket='".$rang."', PremiumData=FROM_UNIXTIME(".(int)$premUntil.") WHERE ".$CP->where());

								if ($mySQLcon->errno) {
									// Freischalten ging schief -> Coins zurueckgeben.
									$CP->givePlayerCoins($CP->Name, (int)$angebot['coins'], "Rueckbuchung: Premium-Kauf fehlgeschlagen");
									echo '<div class="alert alert-danger"><b>Datenbankfehler:</b> '.htmlspecialchars($mySQLcon->error).'<br>
									Die Coins wurden Dir zurückgegeben.</div>';
								} else {
									echo '<div class="alert alert-success">
										<b>'.htmlspecialchars($rangName).' aktiviert!</b><br>
										'.(($tage <= 0) ? 'Deine Mitgliedschaft läuft <b>unbegrenzt</b>.' : 'Läuft bis zum <b>'.date("d.m.Y", $premUntil).'</b> ('.$tage.' Tage).').'<br>
										Beim nächsten Login im Spiel ist sie aktiv.
									</div>';

									// Anzeige aktualisieren
									$premiumAktiv		= true;
									$premiumUnbegrenzt	= ($tage <= 0);
									$premiumPaketID		= $rang;
									$premiumPaketName	= $rangName;
									$CP->LeftVIPDays	= (($tage <= 0) ? 9999 : $tage);
								}
							}
						}
					}

					if ($premiumAktiv) {
						echo '<div class="alert alert-info">
							<b>Du hast schon eine Premium-Mitgliedschaft:</b> '.htmlspecialchars($premiumPaketName).'<br>'
							.(($premiumUnbegrenzt)
								? 'Sie läuft <b>unbegrenzt</b> — Du brauchst nichts mehr zu kaufen.'
								: 'Restlaufzeit: <b>'.(int)$CP->LeftVIPDays.' Tage</b>. Ein neues Paket kannst Du kaufen, sobald sie abgelaufen ist.')
							.'</div>';
					}

					echo '<p>Wähle deinen Premium-Rang. Bezahlt wird mit Coins, freigeschaltet wird sofort.</p>';
					echo '<form method="post" action="?page=coins&act=premium">'.cpCsrfFeld();
					echo '<div class="table-responsive"><table class="table table-striped">
						<thead><tr><th></th><th>Rang</th><th>Laufzeit</th><th>Preis</th><th>Vorteile</th></tr></thead><tbody>';

					foreach ($premiumAngebote as $nr => $angebot) {
						$rangID		= (int)$angebot['rang'];
						$rangName	= ((isset($premiumPakete[$rangID])) ? $premiumPakete[$rangID] : 'Paket '.$rangID);
						$tage		= (int)$angebot['tage'];
						$preis		= (int)$angebot['coins'];
						$bezahlbar	= ($CP->Coins >= $preis);

						$vorteile = '';
						if (isset($premiumVorteile[$rangID])) {
							$vorteile = '<small>&bull; '.implode('<br>&bull; ', array_map('htmlspecialchars', $premiumVorteile[$rangID])).'</small>';
						}

						$radio = '<input type="radio" name="angebot" value="'.htmlspecialchars($nr).'"'
							.((!$bezahlbar || $premiumAktiv) ? ' disabled' : '').' />';

						echo '<tr'.((!$bezahlbar) ? ' class="text-muted"' : '').'>
							<td>'.$radio.'</td>
							<td><b>'.htmlspecialchars($rangName).'</b></td>
							<td>'.(($tage <= 0) ? '<b>unbegrenzt</b>' : $tage.' Tage').'</td>
							<td>'.number_format($preis,0,"",".").' Coins'.((!$bezahlbar) ? '<br><small>zu teuer</small>' : '').'</td>
							<td>'.$vorteile.'</td>
						</tr>';
					}

					echo '</tbody></table></div>';

					if ($premiumAktiv) {
						echo '<button type="submit" class="btn btn-default" disabled>Kaufen (läuft noch)</button>';
					} else {
						echo '<button type="submit" class="btn btn-warning" name="buyPrem"
							onclick="return confirm(\'Paket jetzt kaufen? Die Coins werden sofort abgezogen.\');">Jetzt kaufen</button>';
					}
					echo '</form>';
					break;

				// =========================================================
				// Telefonnummer aendern
				// =========================================================
				case 'tel':

					if (isset($_POST['changeTel']) && cpCsrfPruefen()) {
						$neu = ((isset($_POST['newTel'])) ? trim($_POST['newTel']) : '');
						$len = strlen($neu);
						$verboten = array("110", "911", "666666", "333", "400");

						// Fester Preis, egal wie lang die Nummer ist.
						$price = 600;

						if ($len < 3 || $len > 12 || !ctype_digit($neu) || in_array($neu, $verboten)) {
							echo '<div class="alert alert-danger"><b>Diese Telefonnummer ist ungültig.</b><br>
							Erlaubt sind 3 bis 12 Ziffern. Notrufnummern sind gesperrt.</div>';

						} else if ($price <= 0 || $CP->Coins < $price) {
							echo '<div class="alert alert-danger"><b>Du hast nicht genug Coins.</b></div>';

						} else if ($CP->inGameLoggedin == true) {
							echo '<div class="alert alert-danger"><b>Du musst ingame offline sein.</b></div>';

						} else {
							$sql = $mySQLcon->query("SELECT UID FROM userdata WHERE Telefonnr='".$mySQLcon->escape_string($neu)."'");
							if ($sql && $sql->num_rows > 0) {
								echo '<div class="alert alert-danger"><b>Diese Telefonnummer ist bereits vergeben.</b></div>';

							// Erst bezahlen, dann aendern.
							} else if (!$CP->takePlayerCoins($price, "Spieler: ".$CP->Name." ; Telefonnummer (".$neu.")")) {
								echo '<div class="alert alert-danger"><b>Die Coins konnten nicht abgebucht werden.</b> Lade die Seite neu.</div>';

							} else {
								$mySQLcon->query("UPDATE userdata SET Telefonnr='".$mySQLcon->escape_string($neu)."' WHERE ".$CP->where());
								echo '<div class="alert alert-success">Deine neue Telefonnummer ist <b>'.htmlspecialchars($neu).'</b>.</div>';
							}
						}
					}

					echo '<p>Deine Telefonnummer darf 3 bis 12 Ziffern haben. Kostet pauschal <b>600 Coins</b>.</p>
					<p><small class="text-muted">Aktuell: '.htmlspecialchars($CP->UserData['userdata']['Telefonnr']).'</small></p>
					<form role="form" method="post" action="?page=coins&act=tel">
						'.cpCsrfFeld().'
						<div class="form-group">
							<label>Neue Telefonnummer</label>
							<input class="form-control" type="text" name="newTel" maxlength="12" />
						</div>
						<button type="submit" class="btn btn-default" name="changeTel">Ändern</button>
					</form>';
					break;

				// =========================================================
				// Namen aendern
				// =========================================================
				case 'nick':

					if (isset($_POST['changeNick']) && cpCsrfPruefen()) {
						$neu = ((isset($_POST['newNick'])) ? trim($_POST['newNick']) : '');
						$len = strlen($neu);
						$verboten = array("none", "admin", "mtasa", "mta");

						/*
							Erlaubt: Buchstaben, Zahlen und  - _ [ ] ~ . | ! # @
							(ICE verbietet zusaetzlich das ' - siehe
							register_login_server.lua Zeile 19)
						*/
						$zeichenOk = ($len > 0 && preg_match('/^[A-Za-z0-9\-_\[\]~.|!#@]+$/', $neu) === 1);

						// Fester Preis, egal wie lang der Name ist.
						$price = 800;

						if (!$zeichenOk || in_array(strtolower($neu), $verboten)) {
							echo '<div class="alert alert-danger"><b>Dieser Name ist nicht erlaubt.</b><br>
							Erlaubt sind Buchstaben, Zahlen und - _ [ ] ~ . | ! # @</div>';

						} else if ($len < 3 || $len > 20) {
							echo '<div class="alert alert-danger"><b>Der Name muss 3 bis 20 Zeichen lang sein.</b></div>';

						} else if ($CP->Coins < $price) {
							echo '<div class="alert alert-danger"><b>Du hast nicht genug Coins.</b> Dieser Name kostet '.$price.' Coins.</div>';

						} else if ($CP->inGameLoggedin == true) {
							echo '<div class="alert alert-danger"><b>Du musst ingame offline sein, um deinen Namen zu ändern.</b></div>';

						} else {
							$sql = $mySQLcon->query("SELECT UID FROM userdata WHERE Name='".$mySQLcon->escape_string($neu)."'");
							if ($sql && $sql->num_rows > 0) {
								echo '<div class="alert alert-danger"><b>Diesen Namen gibt es schon.</b></div>';
							} else {
								$alt = $CP->Name;

								// Erst bezahlen, dann umbenennen.
								if (!$CP->takePlayerCoins($price, "Spieler: ".$alt." ; Namensaenderung zu ".$neu)) {
									echo '<div class="alert alert-danger"><b>Die Coins konnten nicht abgebucht werden.</b> Lade die Seite neu.</div>';

								} else if ($CP->changePlayerName($alt, $neu)) {
									echo '<div class="alert alert-success">Du heißt jetzt <b>'.htmlspecialchars($neu).'</b>.<br>
									<b>Wichtig:</b> Melde dich im Panel neu an und benutze ingame ab jetzt den neuen Namen.</div>';

								} else {
									// Umbenennen ging schief -> Coins zurueck.
									$CP->givePlayerCoins($alt, $price, "Rueckbuchung: Namensaenderung fehlgeschlagen");
									echo '<div class="alert alert-danger"><b>Die Änderung hat nicht funktioniert.</b><br>
									Die Coins wurden Dir zurückgegeben. Wende dich an einen Admin.</div>';
								}
							}
						}
					}

					echo '<p>Dein Name darf 3 bis 20 Zeichen haben. Kostet pauschal <b>800 Coins</b>.</p>
					<p><small class="text-muted">Aktuell: '.htmlspecialchars($CP->Name).'</small></p>
					<form role="form" method="post" action="?page=coins&act=nick">
						'.cpCsrfFeld().'
						<div class="form-group">
							<label>Neuer Name</label>
							<input class="form-control" type="text" name="newNick" maxlength="20" />
						</div>
						<button type="submit" class="btn btn-default" name="changeNick">Ändern</button>
					</form>';
					break;

				// =========================================================
				// Sozialen Status aendern
				// =========================================================
				case 'state':

					if (isset($_POST['changeState']) && cpCsrfPruefen()) {
						$neu = ((isset($_POST['newState'])) ? trim(strip_tags($_POST['newState'])) : '');
						$len = strlen($neu);

						// Fester Preis, egal wie lang der Status ist.
						$price = 100;

						if ($len < 3 || $len > 30) {
							echo '<div class="alert alert-danger"><b>Dein Status muss 3 bis 30 Zeichen lang sein.</b></div>';

						} else if ($CP->Coins < $price) {
							echo '<div class="alert alert-danger"><b>Du hast nicht genug Coins.</b></div>';

						} else if ($CP->inGameLoggedin == true) {
							echo '<div class="alert alert-danger"><b>Du musst ingame offline sein.</b></div>';

						// Erst bezahlen, dann aendern.
						} else if (!$CP->takePlayerCoins($price, "Spieler: ".$CP->Name." ; Status (".$neu.")")) {
							echo '<div class="alert alert-danger"><b>Die Coins konnten nicht abgebucht werden.</b> Lade die Seite neu.</div>';

						} else {
							$mySQLcon->query("UPDATE userdata SET SocialState='".$mySQLcon->escape_string($neu)."' WHERE ".$CP->where());
							echo '<div class="alert alert-success">Dein Status ist jetzt: <b>'.htmlspecialchars($neu).'</b></div>';
						}
					}

					echo '<p>Dein Status steht ingame über deinem Namen. 3 bis 30 Zeichen. Kostet pauschal <b>100 Coins</b>.</p>
					<p><small class="text-muted">Aktuell: '.htmlspecialchars($CP->UserData['userdata']['SocialState']).'</small></p>
					<form role="form" method="post" action="?page=coins&act=state">
						'.cpCsrfFeld().'
						<div class="form-group">
							<label>Neuer Status</label>
							<input class="form-control" type="text" name="newState" maxlength="30" />
						</div>
						<button type="submit" class="btn btn-default" name="changeState">Ändern</button>
					</form>';
					break;

				// =========================================================
				// Coins verschenken
				// =========================================================
				case 'giveaway':

					if (isset($_POST['give']) && cpCsrfPruefen()) {
						$pname	= ((isset($_POST['pname'])) ? trim($_POST['pname']) : '');
						$anzahl	= ((isset($_POST['count'])) ? $_POST['count'] : 0);

						if (!is_numeric($anzahl) || (int)$anzahl <= 0) {
							echo '<div class="alert alert-danger"><b>Bitte gib eine gültige Anzahl an.</b></div>';

						} else if ($CP->Coins < (int)$anzahl) {
							echo '<div class="alert alert-danger"><b>Du hast nicht genug Coins.</b></div>';

						} else if (strtolower($pname) == strtolower($CP->Name)) {
							echo '<div class="alert alert-danger"><b>Dir selbst kannst Du nichts schenken.</b></div>';

						} else if ($CP->inGameLoggedin == true) {
							echo '<div class="alert alert-danger"><b>Du musst ingame offline sein.</b></div>';

						} else if (cpSpielerIstOnline($mySQLcon, $pname)) {
							echo '<div class="alert alert-danger"><b>'.htmlspecialchars($pname).' ist gerade ingame eingeloggt.</b><br>
							Der Server würde die Coins beim Ausloggen überschreiben. Bitte warte, bis der Spieler offline ist.</div>';

						} else {
							/*
								Reihenfolge: erst pruefen, ob es den Spieler gibt,
								dann abbuchen, dann gutschreiben.
								Sonst koennte man Coins abbuchen ohne Empfaenger -
								oder gutschreiben ohne zu bezahlen.
							*/
							$sqlE = $mySQLcon->query("SELECT UID FROM userdata WHERE Name='".$mySQLcon->escape_string($pname)."'");
							$gibtEs = ($sqlE && $sqlE->num_rows > 0);

							if (!$gibtEs) {
								echo '<div class="alert alert-danger"><b>Diesen Spieler gibt es nicht.</b></div>';

							} else if (!$CP->takePlayerCoins((int)$anzahl, "Spieler: ".$CP->Name." ; Coin-Transfer (".(int)$anzahl." an ".$pname.")")) {
								echo '<div class="alert alert-danger"><b>Die Coins konnten nicht abgebucht werden.</b> Lade die Seite neu.</div>';

							} else if ($CP->givePlayerCoins($pname, (int)$anzahl, "Coin-Transfer (".(int)$anzahl." von ".$CP->Name." an ".$pname.")")) {
								echo '<div class="alert alert-success"><b>'.(int)$anzahl.' Coins</b> an <b>'.htmlspecialchars($pname).'</b> verschenkt.</div>';

							} else {
								// Gutschreiben ging schief -> zurueckbuchen.
								$CP->givePlayerCoins($CP->Name, (int)$anzahl, "Rueckbuchung: Coin-Transfer fehlgeschlagen");
								echo '<div class="alert alert-danger"><b>Der Transfer hat nicht funktioniert.</b><br>
								Die Coins wurden Dir zurückgegeben.</div>';
							}
						}
					}

					echo '<p>Verschenke Coins an einen anderen Spieler. Der Spieler muss ingame offline sein.</p>
					<form method="post" action="?page=coins&act=giveaway">
						'.cpCsrfFeld().'
						<div class="form-group">
							<label>Spielername</label>
							<input class="form-control" type="text" name="pname" />
						</div>
						<div class="form-group">
							<label>Anzahl Coins</label>
							<input class="form-control" type="text" name="count" />
						</div>
						<button type="submit" class="btn btn-default" name="give">Verschenken</button>
					</form>';
					break;

				// =========================================================
				// Tactic Kills/Tode zuruecksetzen
				// =========================================================
				case 'tacticreset':

					if (isset($_POST['doReset']) && cpCsrfPruefen()) {
						// Fester Preis, wie zuvor ingame im Coin-Shop.
						$price = 250;

						if ($CP->Coins < $price) {
							echo '<div class="alert alert-danger"><b>Du hast nicht genug Coins.</b></div>';

						} else if ($CP->inGameLoggedin == true) {
							echo '<div class="alert alert-danger"><b>Du musst ingame offline sein.</b></div>';

						// Erst bezahlen, dann zuruecksetzen.
						} else if (!$CP->takePlayerCoins($price, "Spieler: ".$CP->Name." ; Tactic K/D Reset")) {
							echo '<div class="alert alert-danger"><b>Die Coins konnten nicht abgebucht werden.</b> Lade die Seite neu.</div>';

						} else {
							$mySQLcon->query("UPDATE userdata SET TacticKills=0, TacticTode=0 WHERE ".$CP->where());
							echo '<div class="alert alert-success">Deine Tactic Kills/Tode wurden zurückgesetzt.</div>';
						}
					}

					echo '<p>Setzt deine Kills und Tode im Tactic-Modus auf 0 zurück. Kostet pauschal <b>250 Coins</b>.</p>
					<form role="form" method="post" action="?page=coins&act=tacticreset">
						'.cpCsrfFeld().'
						<button type="submit" class="btn btn-default" name="doReset"
							onclick="return confirm(\'Tactic Kills/Tode wirklich zurücksetzen? Kostet 250 Coins.\');">Zurücksetzen</button>
					</form>';
					break;

				// =========================================================
				// Uebersicht (Startzustand)
				// =========================================================
				case 'gesperrt':
					// Meldung wurde oben schon ausgegeben.
					break;

				default:
					$eintraege = array(
						"premium"	=> array("Premium-Mitgliedschaft", "fa-star", "Rang und Laufzeit selbst wählen", false),
						"tel"		=> array("Telefonnummer ändern", "fa-phone", "600 Coins", true),
						"nick"		=> array("Namen ändern", "fa-user", "800 Coins", true),
						"state"		=> array("Status ändern", "fa-comment", "100 Coins", true),
						"giveaway"	=> array("Coins verschenken", "fa-gift", "an andere Spieler", false),
						"tacticreset"	=> array("Tactic K/D zurücksetzen", "fa-refresh", "250 Coins", false),
					);

					echo '<div class="list-group">';
					$anzahlAn = 0;
					foreach ($eintraege as $key => $info) {
						if (!coinFunktionAn($key)) { continue; }
						$anzahlAn++;

						$brauchtPremium = ($info[3] && COINS_NUR_MIT_PREMIUM);
						$gesperrt = ($brauchtPremium && !$premiumAktiv);

						$hinweis = $info[2];
						if ($gesperrt) { $hinweis = '<span class="text-danger">nur für Premium-Mitglieder</span>'; }
						else if ($brauchtPremium) { $hinweis .= ' &middot; <span class="text-success">Premium aktiv</span>'; }

						// Zusaetzlicher Hinweis, wenn der Spieler gerade ingame ist
						if (!$gesperrt && $CP->inGameLoggedin) {
							$hinweis .= ' &middot; <span class="text-warning">erst ingame ausloggen</span>';
						}

						echo '<a class="list-group-item'.(($gesperrt) ? ' disabled' : '').'" href="?page=coins&act='.$key.'">
							<i class="fa '.$info[1].'"></i> <b>'.htmlspecialchars($info[0]).'</b>
							<span class="pull-right"><small>'.$hinweis.'</small></span>
						</a>';
					}
					echo '</div>';

					if ($anzahlAn == 0) {
						echo '<div class="alert alert-info">Es ist derzeit keine Coin-Funktion freigeschaltet.</div>';
					}
				}

				if ($act != '' && $act != 'gesperrt') {
					echo '<hr><p><a href="?page=coins">&laquo; Zurück zur Übersicht</a></p>';
				}
				?>
			</div>
		</div>
	</div>
</div>
