<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Angepasst fuer ICE:
	- der Spielername wurde ungefiltert ins Formular geschrieben (XSS)
	- gab es den Spieler nicht, lief foreach() auf null (PHP-8-Warnung
	  "foreach() argument must be of type array|object")
	- Suche mit "=" statt LIKE (Platzhalter % _ trafen fremde Accounts)
	- gespeichert wird jetzt ueber die UID und in EINER Abfrage

	Gesperrte Spalten: UID verknuepft alle Tabellen, ID ist der Zaehler von
	userdata, Name wird ueber "Coins -> Namen aendern" geaendert (dort werden
	alle anderen Tabellen mitgezogen).
*/
$gesperrteSpalten = array("UID", "ID", "Name");

/*
	SICHERHEIT: Adminlevel

	Vorher konnte jeder Admin ab Level 3 hier jede Spalte aendern - auch
	"Adminlevel", und auch bei sich selbst. Ein Admin mit Level 3 haette sich
	also selbst auf Level 5 setzen und damit alle Rechte nehmen koennen.

	Neue Regel:
	- Adminlevel darf nur ab Level 5 vergeben werden
	- niemals hoeher als das eigene Level
	- niemals beim eigenen Account
*/
$darfAdminlevel = ($CP->Adminlvl >= 5);
if (!$darfAdminlevel) {
	$gesperrteSpalten[] = "Adminlevel";
}

$nick	= ((isset($_POST['nick'])) ? trim($_POST['nick']) : '');
$row	= false;

// Nur ab Adminlevel 5 (Administrator) und höher darf hier ueberhaupt gesucht/bearbeitet werden.
if ($nick != "" && $CP->Adminlvl >= 5) {
	$sql = $mySQLcon->query("SELECT * FROM userdata WHERE Name='".$mySQLcon->escape_string($nick)."'");
	$row = (($sql && $sql->num_rows > 0) ? $sql->fetch_assoc() : false);

	/*
		Rangordnung: Wer ein hoeheres oder gleiches Adminlevel hat, darf nicht
		bearbeitet werden. Sonst koennte ein Admin mit Level 3 die Daten eines
		Level-5-Admins veraendern (Geld, Coins, Fraktion ...).
		Der eigene Account bleibt erlaubt.
	*/
	if ($row && (int)$row['UID'] != (int)$CP->UID
		&& (int)$row['Adminlevel'] >= $CP->Adminlvl) {

		echo '<div class="alert alert-danger">
			<b>'.htmlspecialchars($row['Name']).' hat ein gleich hohes oder höheres Adminlevel ('.cpAdminRangName($row['Adminlevel']).', Stufe '.(int)$row['Adminlevel'].').</b><br>
			Dessen Daten kannst Du nicht bearbeiten.
		</div>';
		cpWriteLog("admin.log", $CP->Name." (Level ".$CP->Adminlvl.") wollte Daten von ".$row['Name']." (Level ".(int)$row['Adminlevel'].") bearbeiten - abgelehnt.");
		$row = false;
		$nick = "";
	}
}
?>
<div class="row">
	<div class="col-md-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				Spielerdaten bearbeiten
			</div>
			<div class="panel-body">
				<?php
				if ($CP->Adminlvl < 5) {
					echo '<p>Du benötigst mindestens Adminlevel 5 ('.cpAdminRangName(5).').</p>';
				} else if ($nick == "") {
				?>
				<p>Bitte gib einen Spielernamen ein.</p>
				<form role="form" action="?page=admin-userdata" method="post">
					<div class="form-group">
						<label>Spielername</label>
						<input class="form-control" type="text" name="nick" />
					</div>
					<button type="submit" class="btn btn-default" name="search">Daten bearbeiten</button>
				</form>
				<?php
				} else if (!$row) {
				?>
				<div class="alert alert-danger"><b>Es gibt keinen Spieler mit dem Namen "<?=htmlspecialchars($nick)?>".</b></div>
				<form role="form" action="?page=admin-userdata" method="post">
					<div class="form-group">
						<label>Spielername</label>
						<input class="form-control" type="text" name="nick" value="<?=htmlspecialchars($nick)?>" />
					</div>
					<button type="submit" class="btn btn-default" name="search">Daten bearbeiten</button>
				</form>
				<?php
				} else {

					// Speichern (nur mit gueltigem Formular-Schluessel)
					if (isset($_POST['edit']) && cpCsrfPruefen()) {
						$sets = array();
						$geaendert = array();

						foreach ($row as $key => $val) {
							if (in_array($key, $gesperrteSpalten)) { continue; }
							if (!isset($_POST[$key]) || $_POST[$key] == $val) { continue; }

							$neuerWert = $_POST[$key];

							// Adminlevel: nie hoeher als das eigene, nie beim eigenen Account
							if ($key == "Adminlevel") {
								if ((int)$row['UID'] == (int)$CP->UID) {
									echo '<div class="alert alert-danger"><b>Dein eigenes Adminlevel kannst Du hier nicht ändern.</b></div>';
									continue;
								}
								if ((int)$neuerWert > (int)$CP->Adminlvl) {
									echo '<div class="alert alert-danger"><b>Du kannst kein Adminlevel über deinem eigenen ('.cpAdminRangName($CP->Adminlvl).', Stufe '.(int)$CP->Adminlvl.') vergeben.</b></div>';
									continue;
								}
								$neuerWert = (int)$neuerWert;
								cpWriteLog("admin.log", $CP->Name." setzt Adminlevel von ".$row['Name']." auf ".$neuerWert);
							}

							$sets[] = "`".$key."`='".$mySQLcon->escape_string($neuerWert)."'";
							$geaendert[] = $key;
						}

						if (count($sets) == 0) {
							echo '<div class="alert alert-info">Es wurde nichts geändert.</div>';
						} else {
							$mySQLcon->query("UPDATE userdata SET ".implode(', ', $sets)." WHERE UID='".(int)$row['UID']."'");

							if ($mySQLcon->errno) {
								echo '<div class="alert alert-danger"><b>Datenbankfehler:</b> '.htmlspecialchars($mySQLcon->error).'</div>';
							} else {
								echo '<div class="alert alert-info">Änderung erfolgreich ('.count($geaendert).' Feld(er): '.htmlspecialchars(implode(', ', $geaendert)).').</div>';
								cpWriteLog("admin.log", $CP->Name." hat bei ".$row['Name']." (UID ".$row['UID'].") geaendert: ".implode(', ', $geaendert));

								// Daten neu laden, damit das Formular die neuen Werte zeigt.
								$sql = $mySQLcon->query("SELECT * FROM userdata WHERE UID='".(int)$row['UID']."'");
								if ($sql && $sql->num_rows > 0) { $row = $sql->fetch_assoc(); }
							}
						}
					}

					// Ist der bearbeitete Spieler gerade ingame?
					$sqlOn = $mySQLcon->query("SELECT Loggedin FROM loggedin WHERE UID='".(int)$row['UID']."'");
					$rowOn = (($sqlOn && $sqlOn->num_rows > 0) ? $sqlOn->fetch_assoc() : false);
					if ($rowOn && $rowOn['Loggedin'] == "1") {
						echo '<div class="alert alert-danger"><b>Achtung:</b> Dieser Spieler ist gerade eingeloggt.
						ICE schreibt seine Werte beim Ausloggen aus dem Speicher zurück - Änderungen hier gehen dann verloren.</div>';
					}
				?>
				<form method="post" action="?page=admin-userdata">
					<?=cpCsrfFeld()?>
					<div class="table-responsive">
						<table class="table">
							<thead>
								<tr>
									<th>Name</th>
									<th>Wert</th>
								</tr>
							</thead>
							<tbody>
								<?php
								foreach ($row as $key => $val) {
									if (in_array($key, $gesperrteSpalten)) {
										echo '<tr>
											<th>'.htmlspecialchars($key).'</th>
											<th>'.htmlspecialchars($val).' <small>(gesperrt)</small></th>
										</tr>';
										continue;
									}
									echo '<tr>
										<th>'.htmlspecialchars($key).'</th>
										<th><input type="text" class="form-control" value="'.htmlspecialchars($val).'" name="'.htmlspecialchars($key).'" /></th>
									</tr>';
								}
								?>
							</tbody>
						</table>
					</div>
					<input type="hidden" name="nick" value="<?=htmlspecialchars($row['Name'])?>" />
					<button type="submit" class="btn btn-default" name="edit">Speichern</button>
				</form>
				<?php } ?>
			</div>
		</div>
	</div>
</div>
