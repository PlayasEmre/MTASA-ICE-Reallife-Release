<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/

$intern = false;
?>
<div class="row">
	<div class="col-md-12">
		<?php
		if ($CP->Loggedin) {
			header("Location: ?page=home");
			exit;
		}

		/*
			Bremse gegen Passwort-Raten: nach mehreren Fehlversuchen ist die
			IP-Adresse eine Weile gesperrt (Einstellungen in usefull.php).
		*/
		$gesperrtSek = cpLoginGesperrt();

		if (isset($_POST['login']) && $gesperrtSek > 0) {
			echo '<div class="alert alert-danger">
				<b>Zu viele Fehlversuche.</b><br>
				Aus Sicherheitsgründen ist der Login von dieser IP-Adresse kurz gesperrt.
				Bitte warte '.ceil($gesperrtSek / 60).' Minute(n).
			</div>';

		} else if (isset($_POST['login'])) {
			$uname		= ((isset($_POST['uname'])) ? $_POST['uname'] : '');
			$password	= ((isset($_POST['password'])) ? $_POST['password'] : '');

			$sql = $mySQLcon->query("SELECT * FROM players WHERE Name='".$mySQLcon->escape_string($uname)."'");
			if ($sql && $sql->num_rows > 0) {
				while ($row = $sql->fetch_assoc()) {
					$id					= ((isset($row['id']) && !empty($row['id'])) ? $row['id'] : $row['UID']);
					$name				= $row['Name'];
					$pw					= $row['Passwort'];
					$salt				= ((isset($row['Salt']) && !empty($row['Salt'])) ? $row['Salt'] : '');

					$passVioLite		= hash('md5', $password);
					$passVioExtendet	= hash('md5', $password.$salt);
					$passTHC			= hash('sha256', $password.$salt);
					/*
						ICE speichert das Passwort DOPPELT gehasht:
						- login_window.lua (Z. 99) / register_window.lua (Z. 55) senden hash("sha512", pw)
						- register_login_server.lua hasht den empfangenen Wert erneut (Z. 151 / 442)
						- /newpw (account.lua Z. 30) schreibt hash("sha512", hash("sha512", pw))
						=> players.Passwort = sha512(sha512(Klartext))
					*/
					$passICE			= hash('sha512', hash('sha512', $password));

					/*
						WICHTIG - alte Panel-Version:
						Eine frühere Version dieses Panels hat beim Passwort ändern
						nur EINMAL sha512 gerechnet. Wer sein Passwort damals hier
						geändert hat, hat seitdem einen einfachen Hash in der
						Datenbank und kommt weder ins Panel noch ins Spiel.

						Dieser Hash wird deshalb auch akzeptiert - und beim
						erfolgreichen Login gleich auf den richtigen doppelten
						Hash umgeschrieben (siehe unten). Danach passt der Account
						wieder zu beidem.
					*/
					$passICEalt			= hash('sha512', $password);

					/*
						hash_equals vergleicht zeitkonstant. Bei == koennte man
						aus der Antwortzeit ablesen, wie viele Zeichen des Hashes
						stimmen (Timing-Angriff).
					*/
					/*
						Neues gesalzenes Format aus dem Spiel:
							s2$<Salt>$<sha512( Salt . sha512(Klartext) )>

						Das Salt steckt im Wert selbst, deshalb braucht es hier
						keine eigene Spalte. Erzeugt wird es in
						register_login/register_login_server.lua
						( icePasswortErzeugen / icePasswortPasst ).
					*/
					$gesalzen = false;
					$passtGesalzen = false;

					if (!empty($pw) && preg_match('/^s2\$([0-9a-fA-F]+)\$([0-9a-fA-F]+)$/', $pw, $teile)) {
						$gesalzen = true;
						$erwartet = hash('sha512', $teile[1].hash('sha512', $password));
						$passtGesalzen = hash_equals(strtolower($teile[2]), strtolower($erwartet));
					}

					$altesFormat = (!$gesalzen && !empty($pw) && hash_equals(strtoupper($pw), strtoupper($passICEalt)));

					if ($gesalzen) {
						// Beim neuen Format zaehlt nur dieser eine Vergleich.
						$passtNicht = !$passtGesalzen;
					} else {
						$passtNicht = (empty($pw)
							|| !(hash_equals(strtoupper($pw), strtoupper($passVioLite))
							|| hash_equals(strtoupper($pw), strtoupper($passVioExtendet))
							|| hash_equals(strtoupper($pw), strtoupper($passTHC))
							|| hash_equals(strtoupper($pw), strtoupper($passICE))
							|| $altesFormat));
					}

					if (!$passtNicht) {

						/*
							Alten Hash automatisch reparieren, damit der Login
							ingame wieder funktioniert.
						*/
						/*
							Jedes noch ungesalzene Kennwort wird beim erfolgreichen
							Login auf das neue Format gehoben - egal aus welchem
							alten Format es stammt. Der Spieler merkt nichts davon
							und muss sein Kennwort nicht aendern.
						*/
						if (!$gesalzen) {
							$salt  = bin2hex(random_bytes(16));
							$neuPW = 's2$'.$salt.'$'.hash('sha512', $salt.hash('sha512', $password));

							$mySQLcon->query("UPDATE players SET Passwort='".$mySQLcon->escape_string($neuPW)."'
								WHERE UID='".(int)$row['UID']."'");
							cpWriteLog("pwchange.log", "Passwort von ".$name." auf das gesalzene Format umgestellt (Login im Panel).");

							// Ab jetzt gilt der neue Wert - auch fuer den Cookie unten.
							$pw = $neuPW;
						}

						$IPb = cpIpPrefix();

						$auth = hash('sha256', $pw.$name.$salt.$IPb);

						// Reste einer aelteren Panel-Version entfernen (Pfad "/")
						cpAlteCookiesAufraeumen();

						// Cookies mit HttpOnly + SameSite (siehe usefull.php).
						// Session-Cookies (null): Login gilt nur bis der Browser
						// geschlossen wird, danach ist immer ein neuer Login noetig.
						cpSetzeCookie("cpauth", $auth, null);
						cpSetzeCookie("cpuser", $id, null);

						cpLoginErfolg();
						cpWriteLog("login.log", "Login von ".$name." (IP ".((isset($_SERVER['REMOTE_ADDR'])) ? $_SERVER['REMOTE_ADDR'] : '?').")");

						header("Location: ?page=home");
						exit;
					}
				}
			}

			// Bis hier gekommen = Anmeldung fehlgeschlagen.
			cpLoginFehlversuch();

			$offen = CP_LOGIN_MAX_VERSUCHE - (int)cpLoginVersucheAnzahl();
			echo '<div class="alert alert-danger"><b>Username oder Passwort falsch.</b>'
				.(($offen > 0 && $offen <= 3) ? '<br><small>Noch '.$offen.' Versuch(e), danach wird der Login kurz gesperrt.</small>' : '')
				.'</div>';
		} else {
			echo '<div class="alert alert-info">Bitte logge dich mit deinen inGame-Daten ein, um Zugang zum Control-Panel zu erhalten.</div>';
		}
		?>
		<form role="form" method="post" action="?page=login" class="form-horizontal" accept-charset="UTF-8" enctype="multipart/form-data">
			<div class="form-group">
				<label class="col-sm-2 control-label">Username:</label>
				<div class="col-sm-6">
					<input class="form-control" type="text" name="uname" placeholder="Username" required>
				</div>
			</div>
			<div class="form-group">
				<label class="col-sm-2 control-label">Passwort:</label>
				<div class="col-sm-6">
					<input class="form-control" type="password" name="password" placeholder="Passwort" required>
				</div>
			</div>
			<div class="form-group">
				<div class="col-sm-offset-2 col-sm-6">
					<button type="submit" class="btn btn-primary btn-sm btn-block" name="login">Login</button>
				</div>
			</div>
		</form>
		<br>
		<a href="mtasa://<?=MTA_IP?>:<?=MTA_PORT?>/">Noch keinen Account?</a>
	</div>
</div>