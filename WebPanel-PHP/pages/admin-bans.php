<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Bans arbeiten bei ICE komplett ueber die Datenbank:

	- Ban   : INSERT INTO ban (UID, AdminUID, Grund, Datum, IP, Serial, STime)
	          (anticheat/ban.lua, admin/admincmds.lua)
	- Unban : DELETE FROM ban WHERE UID=?   (admin/admincmds.lua Z. 1255)
	- STime : 0 = permanent, sonst getSecTime(Stunden) - dieselbe Rechnung
	          wie in usefull/utility.lua (getSecTime)
	- Beim Login prueft ICE die Tabelle und loescht abgelaufene Timebans
	  (register_login/register_login_server.lua Z. 23-49)

	Deshalb braucht das Panel hier KEINE MTA-Web-Funktionen.
	Ein bereits eingeloggter Spieler wird allerdings nicht sofort gekickt -
	der Ban greift beim naechsten Login-Versuch.
*/

$meldung = "";

// Spieler suchen (Name -> UID + Serial + IP aus "players")
if (!function_exists('banFindePlayer')) {
	function banFindePlayer($con, $name) {
		$sql = $con->query("SELECT UID, Name, Serial, IP FROM players WHERE Name='".$con->escape_string($name)."'");
		if ($sql && $sql->num_rows > 0) { return $sql->fetch_assoc(); }
		return false;
	}
}

/*
	Entbannen
*/
if (isset($_POST['unbanPlayer']) && cpCsrfPruefen()) {
	if ($CP->Adminlvl < 3) {
		$meldung = '<div class="alert alert-danger"><b>Zum Entbannen brauchst du mindestens Adminlevel 3 ('.cpAdminRangName(3).').</b></div>';
	} else {
		$uid = ((isset($_POST['uid'])) ? (int)$_POST['uid'] : 0);
		$pName = $CP->getNameFromUID($uid);

		$mySQLcon->query("DELETE FROM ban WHERE UID='".$uid."'");
		if ($mySQLcon->affected_rows > 0) {
			$meldung = '<div class="alert alert-info"><b>'.htmlspecialchars($pName).'</b> wurde entbannt.</div>';
			cpWriteLog("admin.log", $CP->Name." hat ".$pName." (UID ".$uid.") entbannt.");
			cpWriteLog("bans.log", "UNBAN: ".$pName." (UID ".$uid.") von ".$CP->Name);
		} else {
			$meldung = '<div class="alert alert-danger"><b>Für diesen Spieler lag kein Ban vor.</b></div>';
		}
	}
}

/*
	Bannen (offline, direkt in der Datenbank)
*/
if (isset($_POST['banPlayer']) && cpCsrfPruefen()) {
	if ($CP->Adminlvl < 2) {
		$meldung = '<div class="alert alert-danger"><b>Zum Bannen brauchst du mindestens Adminlevel 2 ('.cpAdminRangName(2).').</b></div>';
	} else {
		$nick	= ((isset($_POST['nick'])) ? trim($_POST['nick']) : '');
		$grund	= ((isset($_POST['grund'])) ? trim($_POST['grund']) : '');
		$stunden = ((isset($_POST['stunden'])) ? (float)str_replace(',', '.', $_POST['stunden']) : 0);

		$ziel = banFindePlayer($mySQLcon, $nick);

		if (empty($nick) || empty($grund)) {
			$meldung = '<div class="alert alert-danger"><b>Bitte Spielername und Grund angeben.</b></div>';
		} else if (!$ziel) {
			$meldung = '<div class="alert alert-danger"><b>Diesen Spieler gibt es nicht.</b></div>';
		} else if ((int)$ziel['UID'] == (int)$CP->UID) {
			$meldung = '<div class="alert alert-danger"><b>Du kannst dich nicht selbst bannen.</b></div>';
		} else {
			// Adminlevel des Ziels pruefen - kein Ban gegen hoehere/gleiche Ranege.
			$zielLvl = 0;
			$sqlL = $mySQLcon->query("SELECT Adminlevel FROM userdata WHERE UID='".(int)$ziel['UID']."'");
			if ($sqlL && $sqlL->num_rows > 0) {
				$rowL = $sqlL->fetch_assoc();
				$zielLvl = (int)$rowL['Adminlevel'];
			}

			if ($zielLvl >= $CP->Adminlvl) {
				$meldung = '<div class="alert alert-danger"><b>Dieser Spieler hat ein gleich hohes oder höheres Adminlevel.</b></div>';
			} else {
				// STime: 0 = permanent, sonst Zeitpunkt in Minuten seit 1900 (wie ICE)
				$sTime = (($stunden > 0) ? getSecTime($stunden) : 0);
				$grund = substr($grund, 0, 100); // Spalte ist varchar(100)

				// ban.UID ist PRIMARY KEY -> vorhandenen Eintrag ueberschreiben.
				$mySQLcon->query("INSERT INTO ban (UID, AdminUID, Grund, Datum, IP, Serial, STime) VALUES (
					'".(int)$ziel['UID']."',
					'".(int)$CP->UID."',
					'".$mySQLcon->escape_string($grund)."',
					'".$mySQLcon->escape_string(date("j.n.Y, G:i"))."',
					'".$mySQLcon->escape_string($ziel['IP'])."',
					'".$mySQLcon->escape_string($ziel['Serial'])."',
					'".(int)$sTime."'
				) ON DUPLICATE KEY UPDATE AdminUID=VALUES(AdminUID), Grund=VALUES(Grund), Datum=VALUES(Datum), IP=VALUES(IP), Serial=VALUES(Serial), STime=VALUES(STime)");

				if ($mySQLcon->errno) {
					$meldung = '<div class="alert alert-danger"><b>Datenbankfehler:</b> '.htmlspecialchars($mySQLcon->error).'</div>';
				} else {
					$art = (($sTime == 0) ? 'permanent' : 'für '.$stunden.' Stunden');
					$meldung = '<div class="alert alert-info"><b>'.htmlspecialchars($ziel['Name']).'</b> wurde '.$art.' gebannt.<br>
					Ein aktuell eingeloggter Spieler wird erst beim nächsten Login-Versuch abgewiesen.</div>';
					cpWriteLog("admin.log", $CP->Name." hat ".$ziel['Name']." (UID ".$ziel['UID'].") ".$art." gebannt. Grund: ".$grund);
					cpWriteLog("bans.log", "BAN: ".$ziel['Name']." (UID ".$ziel['UID'].") ".$art." von ".$CP->Name." - ".$grund);
				}
			}
		}
	}
}
?>
<?=$meldung?>
<div class="row">
	<div class="col-md-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				Gebannte Spieler
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<thead>
							<tr>
								<th>Name</th>
								<th>Gebannt von</th>
								<th>Gebannt am</th>
								<th>Grund</th>
								<th>Zeit</th>
								<th>Aktion</th>
							</tr>
						</thead>
						<tbody>
							<?php
							$jetzt = getSecTime(0);
							$anzahlBans = 0;

							$sql = $mySQLcon->query("SELECT * FROM ban ORDER BY UID ASC");
							while ($sql && $row = $sql->fetch_assoc()) {
								$anzahlBans++;

								$name	= ((UID_BASED) ? $CP->getNameFromUID($row['UID']) : $row['Name']);
								$admin	= ((UID_BASED) ? (((int)$row['AdminUID'] == 0) ? 'System / Anticheat' : $CP->getNameFromUID($row['AdminUID'])) : $row['Admin']);
								$sTime	= (int)$row['STime'];

								if ($sTime == 0) {
									$zeit = 'Permanent';
								} else {
									$restStunden = round((($sTime - $jetzt) / 60), 2);
									$zeit = (($restStunden > 0) ? 'noch '.$restStunden.' Std.' : '<i>abgelaufen (wird beim Login gelöscht)</i>');
								}

								echo '<tr>
									<td>'.htmlspecialchars($name).'</td>
									<td>'.htmlspecialchars($admin).'</td>
									<td>'.htmlspecialchars($row['Datum']).'</td>
									<td>'.htmlspecialchars($row['Grund']).'</td>
									<td>'.$zeit.'</td>
									<td>
										<form method="post" action="?page=admin-bans" onsubmit="return confirm(\''.htmlspecialchars(addslashes($name)).' entbannen?\');" style="margin:0;">
											'.cpCsrfFeld().'
											<input type="hidden" name="uid" value="'.(int)$row['UID'].'" />
											<button type="submit" class="btn btn-xs btn-danger" name="unbanPlayer">Entbannen</button>
										</form>
									</td>
								</tr>';
							}

							if ($anzahlBans == 0) {
								echo '<tr><td colspan="6">Derzeit ist kein Spieler gebannt.</td></tr>';
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
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				Spieler bannen
			</div>
			<div class="panel-body">
				<?php if ($CP->Adminlvl >= 2) { ?>
				<p>
					Der Ban wird direkt in die Tabelle <code>ban</code> geschrieben - genau wie ein Ban ingame.<br>
					<b>Zeit leer oder 0</b> = permanenter Ban.
				</p>
				<form method="post" action="?page=admin-bans">
					<?=cpCsrfFeld()?>
					<div class="form-group">
						<label>Spielername</label>
						<input class="form-control" type="text" name="nick" />
					</div>
					<div class="form-group">
						<label>Grund (max. 100 Zeichen)</label>
						<input class="form-control" type="text" name="grund" maxlength="100" />
					</div>
					<div class="form-group">
						<label>Zeit in Stunden (z.B. 0.5 = 30 Minuten)</label>
						<input class="form-control" type="text" name="stunden" value="0" />
					</div>
					<button type="submit" class="btn btn-danger" name="banPlayer">Bannen</button>
				</form>
				<?php } else { ?>
				<div class="alert alert-danger"><b>Zum Bannen brauchst du mindestens Adminlevel 2 (<?=cpAdminRangName(2)?>).</b></div>
				<?php } ?>
			</div>
		</div>
	</div>
</div>
