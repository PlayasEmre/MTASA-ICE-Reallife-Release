<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Fahrzeuge des Spielers.

	Neu: Alle eigenen Fahrzeuge sind sofort auf der Karte markiert und
	durchnummeriert - die Nummer in der Tabelle entspricht der Nummer auf
	der Karte. Vorher zeigte die Karte gar nichts, bis man einen Link
	angeklickt hat (und der Aufruf lief mit den Platzhalter-Koordinaten
	999999 ins Leere).
*/
$whereFIX = ((UID_BASED) ? "UID='".$mySQLcon->escape_string($CP->UID)."'" : "Besitzer='".$mySQLcon->escape_string($CP->Name)."'");

// Fahrzeuge einmal einlesen, damit Tabelle und Karte dieselbe Reihenfolge haben.
$meineFahrzeuge = array();
$sql = $mySQLcon->query("SELECT * FROM vehicles WHERE ".$whereFIX." ORDER BY Slot ASC");
while ($sql && $row = $sql->fetch_assoc()) {
	$meineFahrzeuge[] = $row;
}

/*
	Punkte fuer die Karte. Gezeichnet wird ohne die PHP-Erweiterung GD
	(siehe cpKarte in usefull.php) - vorher kam das Bild von ajax/map.php
	und blieb ohne GD komplett leer.
*/
$mapPunkte = array();
$nrTmp = 0;
foreach ($meineFahrzeuge as $veh) {
	$nrTmp++;
	$vTitel = $nrTmp.'. '.((isset($vehname[$veh['Typ']])) ? $vehname[$veh['Typ']] : 'Modell #'.(int)$veh['Typ']).' (Slot '.(int)$veh['Slot'].')';

	$mapPunkte[] = array(
		"x" => (float)$veh['Spawnpos_X'],
		"y" => (float)$veh['Spawnpos_Y'],
		"titel" => $vTitel
	);
}

// Sichere JavaScript-Liste (siehe cpPunkteJs in usefull.php)
$jsAlle = cpPunkteJs($mapPunkte);
?>
<div class="row">
	<div class="col-md-7">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-truck"></i> Deine Fahrzeuge
				(<?=count($meineFahrzeuge)?> / <?=(int)$CP->UserData['userdata']['MaximumCars']?> Slots)
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<tr>
								<th>#</th>
								<th>Fahrzeug</th>
								<th>Standort</th>
								<th>Tunings</th>
								<th>Kofferraum</th>
							</tr>
						</thead>
						<tbody>
							<?php
							$nr = 0;
							foreach ($meineFahrzeuge as $row) {
								$nr++;

								// Fehlende Teilwerte auffuellen (STuning/Kofferraum koennen kuerzer sein).
								$tunings = explode('|', (string)$row['STuning']);
								for ($t = 0; $t <= 5; $t++) {
									if (!isset($tunings[$t])) { $tunings[$t] = "0"; }
								}
								$koff = explode('|', (string)$row['Kofferraum']);
								for ($t = 0; $t <= 3; $t++) {
									if (!isset($koff[$t]) || $koff[$t] === '') { $koff[$t] = "0"; }
								}

								$kofferraum = '<span class="text-muted">Kein Kofferraum</span>';
								if ($tunings[0] == "1") {
									$kWaffe = (int)$koff[2];
									$kWaffeName = (($kWaffe == 0) ? "-" : ((isset($weaponNames[$kWaffe])) ? $weaponNames[$kWaffe] : 'Waffe #'.$kWaffe));
									$kofferraum = "Drogen: ".number_format($koff[0],0,"",".")." g<br>
									Mats: ".number_format($koff[1],0,"",".")." Stk.<br>
									Waffe: ".htmlspecialchars($kWaffeName)." / ".(($koff[3] > 0) ? number_format($koff[3],0,"",".")." Schuss" : "-");
								}

								$vName	= ((isset($vehname[$row['Typ']])) ? $vehname[$row['Typ']] : 'Modell #'.(int)$row['Typ']);
								$pX		= (float)$row['Spawnpos_X'];
								$pY		= (float)$row['Spawnpos_Y'];
								$ort	= getZoneName($pX, $pY, 0, true).", ".getZoneName($pX, $pY, 0, false);

								$hinweis = "";
								if (isset($row['Beschlagnahmt']) && $row['Beschlagnahmt'] == "1") {
									$hinweis .= '<br><span class="text-danger"><b>Beschlagnahmt</b></span>';
								}
								if (isset($row['totalschaden']) && $row['totalschaden'] == "1") {
									$hinweis .= '<br><span class="text-danger"><b>Totalschaden</b></span>';
								}

								echo '<tr>
									<td><b>'.$nr.'</b></td>
									<td>
										<b>'.htmlspecialchars($vName).'</b><br>
										<small>Slot '.(int)$row['Slot'].((!empty($row['plate'])) ? ' &middot; Kennzeichen '.htmlspecialchars($row['plate']) : '').'</small>
										'.$hinweis.'
									</td>
									<td>
										'.htmlspecialchars($ort).'<br>
										<a href="#" onclick="cpMarker(\'karteFahrzeuge\', [['.$pX.','.$pY.',\'Slot '.(int)$row['Slot'].'\']], false); return false;">Nur dieses zeigen</a>
									</td>
									<td>
										Kofferraum: ['.(($tunings[0] == "1") ? "x" : "&nbsp;").']<br>
										Panzerung: ['.(($tunings[1] == "1") ? "x" : "&nbsp;").']<br>
										Benzinersparnis: ['.(($tunings[2] == "1") ? "x" : "&nbsp;").']<br>
										GPS: ['.(($tunings[3] == "1") ? "x" : "&nbsp;").']<br>
										Doppelreifen: ['.(($tunings[4] == "1") ? "x" : "&nbsp;").']<br>
										Nebelwerfer: ['.(($tunings[5] == "1") ? "x" : "&nbsp;").']
										'.((UID_BASED) ?
										'<br><br>Antrieb: '.(($row['Antrieb'] == "awd") ? "Allrad" : (($row['Antrieb'] == "fwd") ? "Frontantrieb" : "Heckantrieb")).'
										<br>Bremse: Stufe '.(int)$row['Bremse'].'
										<br>Sportmotor: Stufe '.(int)$row['Sportmotor'] : '').'
									</td>
									<td>'.$kofferraum.'</td>
								</tr>';
							}

							if (count($meineFahrzeuge) == 0) {
								echo '<tr><td colspan="5">Du besitzt derzeit kein Fahrzeug.</td></tr>';
							}
							?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<div class="col-md-5">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-map-marker"></i> Wo stehen meine Fahrzeuge?
			</div>
			<div class="panel-body">
				<?php if (count($meineFahrzeuge) == 0) { ?>
				<p>Sobald Du ein Fahrzeug besitzt, wird sein Standort hier markiert.</p>
				<?php } else { ?>
				<p>
					Die Nummern auf der Karte entsprechen der Spalte <b>#</b> in der Tabelle.
					Mit der Maus über einen Punkt fahren zeigt das Fahrzeug.
					<br>
					<a href="#" onclick="alleFahrzeuge(); return false;">Alle Fahrzeuge anzeigen</a>
				</p>
				<?php } ?>
				<?php cpKarte('karteFahrzeuge', $mapPunkte, true); ?>
			</div>
		</div>
	</div>
</div>
<script>
	var fahrzeugPunkte = <?=$jsAlle?>;

	function alleFahrzeuge() {
		cpMarker('karteFahrzeuge', fahrzeugPunkte, true);
	}
</script>
