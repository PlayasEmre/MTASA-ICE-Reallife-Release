<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Fraktion des Spielers.

	Wichtig zu wissen: ICE haelt die Spielerdaten waehrend des Spielens im
	Speicher und schreibt sie erst beim Ausloggen in die Datenbank
	(register_login_server.lua). Wer gerade erst in eine Fraktion aufgenommen
	wurde und noch online ist, steht in userdata.Fraktion daher noch mit 0 -
	darauf wird unten hingewiesen.

	Ausserdem wurde die Pruefung robuster gemacht: vorher wurde mit
	== "0" verglichen. Ist das Feld leer (z.B. weil der Datensatz fehlt),
	ist '' == '0' in PHP 8 FALSE - dann lief die Seite in den Fraktions-Zweig
	und zeigte Unsinn.
*/
$meineFraktion	= (int)$CP->UserData['userdata']['Fraktion'];
$meinRang		= (int)$CP->UserData['userdata']['FraktionsRang'];

/*
	Wer ist gerade online?

	Zuerst wird der Spielserver direkt gefragt (cpMtaAseAbfrage in
	usefull.php - braucht kein Passwort und keinen Neustart). Antwortet er
	nicht, wird die Tabelle "loggedin" benutzt.

	Gebraucht fuer "davon online", die gruenen Punkte in der
	Mitgliederliste und die Spalte "Online" bei allen Fraktionen.
*/
$onlineNamen	= array();	// Name (klein) => true
$onlineFraktion	= array();	// Fraktions-ID => Anzahl
$onlineQuelle	= "Datenbank";

$serverStatus = cpMtaAseAbfrage();

if ($serverStatus && !empty($serverStatus['ok']) && count($serverStatus['spieler']) > 0) {
	$onlineQuelle = "Spielserver";

	$namenEscaped = array();
	foreach ($serverStatus['spieler'] as $sp) {
		$onlineNamen[strtolower($sp)] = true;
		$namenEscaped[] = "'".$mySQLcon->escape_string($sp)."'";
	}

	// Fraktion zu den Namen holen (eine Abfrage fuer alle)
	$sqlOn = $mySQLcon->query("SELECT Name, Fraktion FROM userdata WHERE Name IN (".implode(',', $namenEscaped).")");
	while ($sqlOn && $rowOn = $sqlOn->fetch_assoc()) {
		$fID = (int)$rowOn['Fraktion'];
		if (!isset($onlineFraktion[$fID])) { $onlineFraktion[$fID] = 0; }
		$onlineFraktion[$fID]++;
	}

} else {
	$sqlOn = $mySQLcon->query("SELECT u.Name AS Name, u.Fraktion AS Fraktion
		FROM loggedin l JOIN userdata u ON u.UID = l.UID
		WHERE l.Loggedin='1'");
	while ($sqlOn && $rowOn = $sqlOn->fetch_assoc()) {
		$onlineNamen[strtolower($rowOn['Name'])] = true;
		$fID = (int)$rowOn['Fraktion'];
		if (!isset($onlineFraktion[$fID])) { $onlineFraktion[$fID] = 0; }
		$onlineFraktion[$fID]++;
	}
}

$meineOnline = ((isset($onlineFraktion[$meineFraktion])) ? $onlineFraktion[$meineFraktion] : 0);

/*
	Gang des Spielers.

	ICE-Gangs: gang_members (UID, Gang, Rang, Founder) verknuepft mit
	gang_basic ueber HausID (NICHT ueber ID!) - genau so macht es auch
	das Lua-Skript (gangs_mysql.lua).

	Die Abfrage steht hier oben, weil schon vor der Ausgabe feststehen
	muss, ob das Panel Inhalt hat: ein Panel mit nur einer Zeile Text
	soll nicht auf die Hoehe des Nachbarn gestreckt werden.
*/
$sql		= $mySQLcon->query("SELECT * FROM gang_members WHERE ".$CP->where());
$meineGang	= (($sql && $sql->num_rows > 0) ? $sql->fetch_assoc() : false);
$gang		= false;

if ($meineGang && $meineGang['Gang'] != 0) {
	$sql = $mySQLcon->query("SELECT * FROM gang_basic WHERE HausID='".$mySQLcon->escape_string($meineGang['Gang'])."'");
	$gang = (($sql && $sql->num_rows > 0) ? $sql->fetch_assoc() : false);
}
?>
<?php
/*
	Alle vier Panels stehen in EINER Reihe. Die Reihenfolge auf dem
	Bildschirm macht die CSS (.cp-ord1 bis .cp-ord4):

		Fraktion  |  Deine Gang
		Alle Fraktionen  |  Gangwar-Gebiete

	Dadurch stehen die eigenen Daten oben und die grossen
	Uebersichtstabellen darunter.
*/
?>
<div class="row">
	<div class="col-md-6 cp-ord1">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-flag"></i> Fraktion
			</div>
			<div class="panel-body">
				<?php if ($meineFraktion <= 0) { ?>
				<p><b>Du bist in keiner Fraktion.</b></p>
				<?php if ($CP->inGameLoggedin) { ?>
				<div class="alert alert-info" style="font-size: 12px;">
					Du bist gerade <b>ingame eingeloggt</b>. ICE speichert Fraktion, Geld und
					Spielzeit erst beim Ausloggen in die Datenbank — bist Du erst in dieser
					Sitzung in eine Fraktion aufgenommen worden, erscheint sie hier erst,
					nachdem Du das Spiel einmal verlassen hast.
				</div>
				<?php } ?>
				<?php } else { ?>
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr>
								<td width="40%">Fraktion</td>
								<td><?php
									$fName = ((isset($factions[$meineFraktion])) ? $factions[$meineFraktion]['name'] : 'Unbekannt');
									$fRGB  = ((isset($factions[$meineFraktion])) ? $factions[$meineFraktion]['rgb'] : '200,200,200');
									echo '<span style="display:inline-block; width:12px; height:12px; background:rgb('.$fRGB.'); border:1px solid #999; margin-right:5px;"></span>';
									echo '<b>'.htmlspecialchars($fName).'</b> <small class="text-muted">(ID '.$meineFraktion.')</small>';
									?></td>
							</tr>
							<tr>
								<td>Dein Rang</td>
								<td><?=$meinRang?><?=(($meinRang == (int)LEADER_RANG) ? ' <b>(Leader)</b>' : '')?></td>
							</tr>
							<?php
							$sql = $mySQLcon->query("SELECT * FROM fraktionen WHERE ID='".$meineFraktion."'");
							if ($sql && $sql->num_rows > 0) {
								$row = $sql->fetch_assoc();
								echo '<tr><td>Depot-Kasse</td><td>'.number_format($row['DepotGeld'],0,"",".").' $</td></tr>
								<tr><td>Depot-Drogen</td><td>'.number_format($row['DepotDrogen'],0,"",".").' Gramm</td></tr>
								<tr><td>Depot-Materials</td><td>'.number_format($row['DepotMaterials'],0,"",".").' Stk.</td></tr>';
							} else {
								echo '<tr><td colspan="2"><small class="text-muted">Für diese Fraktion gibt es keinen Eintrag in der Tabelle
								<code>fraktionen</code> (Depot-Werte fehlen daher).</small></td></tr>';
							}
							?>
							<tr>
								<td>Gerade online</td>
								<td>
									<span class="label label-<?=(($meineOnline > 0) ? 'success' : 'default')?>" style="font-size: 13px;">
										<?=$meineOnline?> von deiner Fraktion online
									</span>
								</td>
							</tr>
							<tr>
								<td>Mitglieder</td>
								<td><?php
								/*
									Die Liste wird erst gesammelt und dann ausgegeben.
									So steht die Zusammenfassung ("x Mitglieder insgesamt")
									UNTER dem scrollbaren Kasten und nicht darin.
								*/
								$anzahlMitglieder	= 0;
								$listeHtml			= '';

								$sql = $mySQLcon->query("SELECT Name, FraktionsRang FROM userdata WHERE Fraktion='".$meineFraktion."' ORDER BY FraktionsRang DESC, Name ASC");
								while ($sql && $row = $sql->fetch_assoc()) {
									$anzahlMitglieder++;
									$istIch = (strtolower($row['Name']) == strtolower($CP->Name));
									$istOnline = isset($onlineNamen[strtolower($row['Name'])]);

									// Gruener Punkt = gerade im Spiel
									$listeHtml .= '<span style="display:inline-block; width:8px; height:8px; border-radius:50%; margin-right:6px; background:'
										.(($istOnline) ? '#2b8a3e' : '#ccc').';" title="'.(($istOnline) ? 'online' : 'offline').'"></span>'
										.(($istIch) ? '<b>' : '').htmlspecialchars($row['Name']).(($istIch) ? '</b> <small class="text-muted">(du)</small>' : '')
										.' &ndash; Rang '.(int)$row['FraktionsRang'].'<br>';
								}

								if ($anzahlMitglieder == 0) {
									echo '<span class="text-muted">Keine Mitglieder gefunden.</span>';
								} else {
									echo '<div class="cp-liste">'.$listeHtml.'</div>'
										.'<small class="text-muted">'.$anzahlMitglieder.' Mitglieder insgesamt, '.$meineOnline.' gerade online.</small>';
								}
								?></td>
							</tr>
						</tbody>
					</table>
				</div>
				<?php } ?>
			</div>
		</div>
	</div>
	
	<div class="col-md-6 cp-ord3">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-users"></i> Alle Fraktionen
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<tr>
								<th>Fraktion</th>
								<th>Leader</th>
								<th>Mitglieder</th>
								<th>Online</th>
							</tr>
						</thead>
						<tbody>
							<?php
							/*
								Mitglieder und Leader aller Fraktionen in EINER Abfrage
								zaehlen, statt pro Fraktion einzeln zu fragen.
							*/
							$mitgliederZahl = array();
							$sqlM = $mySQLcon->query("SELECT Fraktion, COUNT(*) AS Anzahl FROM userdata WHERE Fraktion > 0 GROUP BY Fraktion");
							while ($sqlM && $rowM = $sqlM->fetch_assoc()) {
								$mitgliederZahl[(int)$rowM['Fraktion']] = (int)$rowM['Anzahl'];
							}

							$leaderName = array();
							$sqlL = $mySQLcon->query("SELECT Fraktion, Name FROM userdata WHERE FraktionsRang='".(int)LEADER_RANG."' AND Fraktion > 0");
							while ($sqlL && $rowL = $sqlL->fetch_assoc()) {
								$leaderName[(int)$rowL['Fraktion']] = $rowL['Name'];
							}

							foreach ($factions as $key => $value) {
								if ($key == 0) { continue; }

								$anzahl	= ((isset($mitgliederZahl[$key])) ? $mitgliederZahl[$key] : 0);
								$online	= ((isset($onlineFraktion[$key])) ? $onlineFraktion[$key] : 0);
								$leader	= ((isset($leaderName[$key])) ? htmlspecialchars($leaderName[$key]) : '<span class="text-muted">-</span>');
								$meine	= (($key == $meineFraktion) ? ' style="background-color: rgba(66,139,202,0.18);"' : '');

								echo '<tr'.$meine.'>
									<td>
										<span style="display:inline-block; width:10px; height:10px; background:rgb('.$value['rgb'].'); border:1px solid #999; margin-right:5px;"></span>
										'.htmlspecialchars($value['name']).'
									</td>
									<td>'.$leader.'</td>
									<td>'.$anzahl.'</td>
									<td>'.(($online > 0)
										? '<span class="label label-success">'.$online.'</span>'
										: '<span class="text-muted">0</span>').'</td>
								</tr>';
							}
							?>
						</tbody>
					</table>
				</div>
				<p><small class="text-muted">
				Die Spalte <b>Online</b> zeigt, wie viele Mitglieder dieser Fraktion gerade im Spiel sind.
				Quelle: <?=(($onlineQuelle == "Spielserver") ? 'direkte Abfrage beim Spielserver' : 'Datenbank (Tabelle loggedin)')?>.
			</small></p>
			</div>
		</div>
	</div>

	<div class="col-md-6 cp-ord2">
		<div class="panel panel-default<?=((!$gang) ? ' cp-kompakt' : '')?>">
			<div class="panel-heading">
				<i class="fa fa-shield"></i> Deine Gang
			</div>
			<div class="panel-body">
				<?php
				if (!$meineGang || $meineGang['Gang'] == 0) {
					echo '<p class="text-muted" style="margin:0;">Du bist in keiner Gang.</p>';
				} else {
					if (!$gang) {
						echo '<p>Deine Gang wurde nicht gefunden (ID '.(int)$meineGang['Gang'].').</p>';
					} else {
						$rangName = ((!empty($gang['Rang'.$meineGang['Rang']])) ? $gang['Rang'.$meineGang['Rang']] : 'Rang '.$meineGang['Rang']);

						$sqlM = $mySQLcon->query("SELECT COUNT(*) AS Anzahl FROM gang_members WHERE Gang='".$mySQLcon->escape_string($meineGang['Gang'])."'");
						$mitglieder = (($sqlM) ? $sqlM->fetch_assoc() : array("Anzahl" => 0));
						?>
						<div class="table-responsive">
							<table class="table">
								<tbody>
									<tr><td width="40%">Name</td><td><?=htmlspecialchars($gang['Name'])?></td></tr>
									<tr><td>Dein Rang</td><td><?=htmlspecialchars($rangName)?><?=(($meineGang['Founder'] == 1) ? ' (Gründer)' : '')?></td></tr>
									<tr><td>Mitglieder</td><td><?=(int)$mitglieder['Anzahl']?> / <?=(int)$gang['MaxMembers']?></td></tr>
									<tr><td>Gang-Drogen</td><td><?=number_format($gang['Drugs'],0,"",".")?> Gramm</td></tr>
									<tr><td>Gang-Materials</td><td><?=number_format($gang['Mats'],0,"",".")?> Stk.</td></tr>
									<tr><td>Nachricht des Leaders</td><td><?=htmlspecialchars($gang['LeaderMSG'])?></td></tr>
								</tbody>
							</table>
						</div>
						<p style="margin-bottom:6px;"><b>Mitglieder:</b></p>
						<div class="cp-liste">
						<?php
						$sqlL = $mySQLcon->query("SELECT u.Name AS Name, g.Rang AS Rang FROM gang_members g JOIN userdata u ON u.UID = g.UID WHERE g.Gang='".$mySQLcon->escape_string($meineGang['Gang'])."' ORDER BY g.Rang DESC");
						while ($sqlL && $m = $sqlL->fetch_assoc()) {
							$rn = ((!empty($gang['Rang'.$m['Rang']])) ? $gang['Rang'.$m['Rang']] : 'Rang '.$m['Rang']);
							echo htmlspecialchars($m['Name']).' <span class="text-muted">&ndash; '.htmlspecialchars($rn).'</span><br>';
						}
						?>
						</div>
						<?php
					}
				}
				?>
			</div>
		</div>
	</div>

	<div class="col-md-6 cp-ord4">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-map-marker"></i> Gangwar-Gebiete
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<thead>
							<tr>
								<th>Gebiet</th>
								<th>Besitzer</th>
								<th>Einnahmen</th>
							</tr>
						</thead>
						<tbody>
							<?php
							$sql = $mySQLcon->query("SELECT * FROM gangs WHERE Aktiviert='1' ORDER BY ID ASC");
							while ($sql && $row = $sql->fetch_assoc()) {
								$besitzer = ((isset($factions[$row['BesitzerFraktion']])) ? $factions[$row['BesitzerFraktion']]['name'] : '-');
								$rgb = ((isset($factions[$row['BesitzerFraktion']])) ? $factions[$row['BesitzerFraktion']]['rgb'] : '200,200,200');
								echo '<tr>
									<td>'.htmlspecialchars($row['Name']).'</td>
									<td><span style="color:rgb('.$rgb.');">'.htmlspecialchars($besitzer).'</span></td>
									<td>'.number_format($row['Einnahmen'],0,"",".").' $</td>
								</tr>';
							}
							?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>