<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Ersetzt die alte Auktionsseite (buyit.com).

	Zeigt, was man ingame kaufen kann - alles aus echten ICE-Tabellen:
	  carhouses_icons     -> Autohaeuser (Name + Position)
	  carhouses_vehicles  -> Fahrzeuge im jeweiligen Autohaus (Typ, Preis)
	  biz                 -> Geschaefte (Besitzer, Preis, Kasse)
	  prestige            -> Prestige-Objekte
*/

// ---------------------------------------------------------------
// Autohäuser einlesen
// ---------------------------------------------------------------
$autohaeuser = array();
$sql = $mySQLcon->query("SELECT * FROM carhouses_icons ORDER BY ID ASC");
while ($sql && $row = $sql->fetch_assoc()) {
	// Die Namen enthalten in der DB \n als Zeilenumbruch.
	$name = str_replace(array('\\n', "\n", "\r"), ' ', $row['Name']);
	$autohaeuser[(int)$row['ID']] = array(
		"name"		=> trim($name),
		"x"			=> (float)$row['X'],
		"y"			=> (float)$row['Y'],
		"fahrzeuge"	=> array()
	);
}

$sql = $mySQLcon->query("SELECT * FROM carhouses_vehicles ORDER BY AutohausID ASC, Preis ASC");
while ($sql && $row = $sql->fetch_assoc()) {
	$id = (int)$row['AutohausID'];
	if (!isset($autohaeuser[$id])) { continue; }
	$autohaeuser[$id]["fahrzeuge"][] = $row;
}

// Punkte fuer die Karte (ohne GD, siehe cpKarte in usefull.php)
$ahPunkte = array();
$ahNr = 0;
foreach ($autohaeuser as $ah) {
	$ahNr++;
	$ahPunkte[] = array("x" => $ah['x'], "y" => $ah['y'], "titel" => $ahNr.'. '.$ah['name']);
}

// Sichere JavaScript-Liste (siehe cpPunkteJs in usefull.php)
$jsAutohaeuser = cpPunkteJs($ahPunkte);

$gewaehlt = ((isset($_GET['ah'])) ? (int)$_GET['ah'] : 0);
?>
<div class="row">
	<div class="col-md-7">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-car"></i> Autohäuser
			</div>
			<div class="panel-body">
				<?php if (count($autohaeuser) == 0) { ?>
				<p>In der Datenbank sind keine Autohäuser eingetragen (Tabelle <code>carhouses_icons</code>).</p>
				<?php } else { ?>
				<p>Klick auf ein Autohaus, um die Fahrzeuge und den Standort zu sehen.</p>
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<tr>
								<th>#</th>
								<th>Autohaus</th>
								<th>Ort</th>
								<th>Fahrzeuge</th>
								<th>ab</th>
							</tr>
						</thead>
						<tbody>
							<?php
							$nr = 0;
							foreach ($autohaeuser as $id => $ah) {
								$nr++;

								$guenstigster = 0;
								foreach ($ah['fahrzeuge'] as $veh) {
									if ($guenstigster == 0 || (int)$veh['Preis'] < $guenstigster) {
										$guenstigster = (int)$veh['Preis'];
									}
								}

								$aktiv = (($gewaehlt == $id) ? ' style="background-color: rgba(66,139,202,0.15);"' : '');
								echo '<tr'.$aktiv.'>
									<td><b>'.$nr.'</b></td>
									<td><a href="?page=kaufen&ah='.$id.'">'.htmlspecialchars($ah['name']).'</a></td>
									<td>'.htmlspecialchars(getZoneName($ah['x'], $ah['y'], 0, true)).'<br>
										<a href="#" onclick="zeigePunkt('.($nr - 1).'); return false;"><small>auf der Karte zeigen</small></a></td>
									<td>'.count($ah['fahrzeuge']).'</td>
									<td>'.(($guenstigster > 0) ? number_format($guenstigster,0,"",".").' $' : '-').'</td>
								</tr>';
							}
							?>
						</tbody>
					</table>
				</div>
				<?php } ?>
			</div>
		</div>

		<?php if ($gewaehlt > 0 && isset($autohaeuser[$gewaehlt])) { ?>
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-list"></i> Fahrzeuge: <?=htmlspecialchars($autohaeuser[$gewaehlt]['name'])?>
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<tr>
								<th>Fahrzeug</th>
								<th>Preis</th>
								<th>Info</th>
							</tr>
						</thead>
						<tbody>
							<?php
							if (count($autohaeuser[$gewaehlt]['fahrzeuge']) == 0) {
								echo '<tr><td colspan="3">In diesem Autohaus steht derzeit kein Fahrzeug.</td></tr>';
							}
							foreach ($autohaeuser[$gewaehlt]['fahrzeuge'] as $veh) {
								$typ = (int)$veh['Typ'];
								$vName = ((isset($vehname[$typ])) ? $vehname[$typ] : 'Modell #'.$typ);

								$info = trim((string)$veh['Info']);
								$kommentar = trim((string)$veh['Comment']);
								if ($kommentar != "" && $kommentar != $info) {
									$info = trim($info." ".$kommentar);
								}

								$bezahlbar = '';
								$preis = (int)$veh['Preis'];
								$eigenes = (float)$CP->UserData['userdata']['Geld'] + (float)$CP->UserData['userdata']['Bankgeld'];
								if ($preis > 0 && $eigenes >= $preis) {
									$bezahlbar = ' <span class="text-success" title="Du kannst dir das leisten">&#10004;</span>';
								}

								echo '<tr>
									<td><b>'.htmlspecialchars($vName).'</b> <small>(ID '.$typ.')</small></td>
									<td>'.number_format($preis,0,"",".").' $'.$bezahlbar.'</td>
									<td><small>'.htmlspecialchars($info).'</small></td>
								</tr>';
							}
							?>
						</tbody>
					</table>
				</div>
				<p><small>
					Dein Geld: <b><?=number_format((float)$CP->UserData['userdata']['Geld'] + (float)$CP->UserData['userdata']['Bankgeld'],0,"",".")?> $</b>
					&middot; Freie Fahrzeug-Slots:
					<b><?=max(0, (int)$CP->UserData['userdata']['MaximumCars'] - (int)$CP->UserData['userdata']['CurrentCars'])?></b>
				</small></p>
			</div>
		</div>
		<?php } ?>
	</div>

	<div class="col-md-5">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-map-marker"></i> Karte
			</div>
			<div class="panel-body">
				<p><a href="#" onclick="alleAutohaeuser(); return false;">Alle Autohäuser anzeigen</a></p>
				<?php cpKarte('karteKaufen', $ahPunkte, true); ?>
			</div>
		</div>

		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-building"></i> Geschäfte
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<tr>
								<th>Geschäft</th>
								<th>Besitzer</th>
								<th>Preis</th>
							</tr>
						</thead>
						<tbody>
							<?php
							$anzahlBiz = 0;
							$sql = $mySQLcon->query("SELECT * FROM biz ORDER BY Preis ASC");
							while ($sql && $row = $sql->fetch_assoc()) {
								$anzahlBiz++;
								$besitzerUID = (int)$row['UID'];
								if ($besitzerUID == 0) {
									$besitzer = '<span class="text-success">Zu verkaufen</span>';
								} else {
									$besitzer = htmlspecialchars($CP->getNameFromUID($besitzerUID));
									if ($besitzerUID == (int)$CP->UID) {
										$besitzer = '<b>Du</b>';
									}
								}

								echo '<tr>
									<td>'.htmlspecialchars($row['Name']).'</td>
									<td>'.$besitzer.'</td>
									<td>'.number_format($row['Preis'],0,"",".").' $</td>
								</tr>';
							}

							if ($anzahlBiz == 0) {
								echo '<tr><td colspan="3">Keine Geschäfte in der Datenbank.</td></tr>';
							}
							?>
						</tbody>
					</table>
				</div>
			</div>
		</div>

		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-star"></i> Prestige-Objekte
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<tr>
								<th>Objekt</th>
								<th>Besitzer</th>
								<th>Preis</th>
							</tr>
						</thead>
						<tbody>
							<?php
							$anzahlPrestige = 0;
							$prestigePunkte = array();

							$sql = $mySQLcon->query("SELECT * FROM prestige ORDER BY Preis ASC");
							while ($sql && $row = $sql->fetch_assoc()) {
								$pUID = (int)$row['UID'];
								if ($pUID == 0) {
									$besitzer = '<span class="text-success">Frei</span>';
								} else {
									$besitzer = htmlspecialchars($CP->getNameFromUID($pUID));
									if ($pUID == (int)$CP->UID) { $besitzer = '<b>Du</b>'; }
								}

								/*
									Der Text kommt NICHT ins onclick, sondern in eine
									JavaScript-Liste (unten). Im onclick steht nur die
									Nummer - so kann kein Text aus dem JavaScript
									ausbrechen.
								*/
								$prestigePunkte[] = array(
									"x" => (float)$row['X'],
									"y" => (float)$row['Y'],
									"titel" => $row['Beschreibung']
								);

								echo '<tr>
									<td>'.htmlspecialchars($row['Beschreibung']).'<br>
										<a href="#" onclick="zeigePrestige('.$anzahlPrestige.'); return false;"><small>auf der Karte zeigen</small></a></td>
									<td>'.$besitzer.'</td>
									<td>'.number_format($row['Preis'],0,"",".").' $</td>
								</tr>';

								$anzahlPrestige++;
							}

							if ($anzahlPrestige == 0) {
								echo '<tr><td colspan="3">Keine Prestige-Objekte in der Datenbank.</td></tr>';
							}
							?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>
<script>
	var autohausPunkte = <?=$jsAutohaeuser?>;
	var prestigePunkte = <?=cpPunkteJs($prestigePunkte)?>;

	function alleAutohaeuser() {
		cpMarker('karteKaufen', autohausPunkte, true);
	}

	// Ein einzelnes Autohaus zeigen (Nummer aus der Tabelle)
	function zeigePunkt(nr) {
		if (!autohausPunkte[nr]) { return; }
		cpMarker('karteKaufen', [autohausPunkte[nr]], false);
	}

	// Ein einzelnes Prestige-Objekt zeigen
	function zeigePrestige(nr) {
		if (!prestigePunkte[nr]) { return; }
		cpMarker('karteKaufen', [prestigePunkte[nr]], false);
	}
</script>
