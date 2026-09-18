<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/

/*
	ICE: userdata.Hausschluessel
	> 0 = Besitzer des Hauses mit dieser ID
	< 0 = Mieter des Hauses mit dieser ID
	  0 = kein Haus
	(siehe housesys/housecmds.lua und housesys/housebuy.lua)
*/
$hausKey	= (int)$CP->UserData['userdata']['Hausschluessel'];
$hs			= abs($hausKey);
$hausRow	= false;

if ($hs > 0) {
	$sqlH = $mySQLcon->query("SELECT * FROM houses WHERE ID='".$hs."'");
	$hausRow = (($sqlH && $sqlH->num_rows > 0) ? $sqlH->fetch_assoc() : false);
}

$pX = 0;
$pY = 0;

/*
	Karte:
	Wird ohne die PHP-Erweiterung GD gezeichnet (siehe cpKarte in usefull.php).
	Vorher kam das Bild von ajax/map.php - fehlte GD, war dort einfach nichts
	zu sehen.
*/
$meinHausPunkt = array();
if ($hausRow) {
	$meinHausPunkt[] = array(
		"x" => (float)$hausRow['SymbolX'],
		"y" => (float)$hausRow['SymbolY'],
		"titel" => 'Mein Haus (#'.(int)$hausRow['ID'].')'
	);
}

// Alle freien Haeuser fuer die Umschaltung "Freie Häuser".
$freiePunkte = array();
$sqlF = $mySQLcon->query("SELECT ID, SymbolX, SymbolY, Preis FROM houses WHERE ".((UID_BASED) ? "UID='0'" : "Besitzer='none'"));
while ($sqlF && $rowF = $sqlF->fetch_assoc()) {
	$freiePunkte[] = array(
		"x" => (float)$rowF['SymbolX'],
		"y" => (float)$rowF['SymbolY'],
		"titel" => 'Haus #'.(int)$rowF['ID'].' - '.number_format($rowF['Preis'],0,"",".").' $'
	);
}

// Sichere JavaScript-Liste (siehe cpPunkteJs in usefull.php)
$jsFreieHaeuser = cpPunkteJs($freiePunkte);
?>
<div class="row">
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				Haus
			</div>
			<div class="panel-body">
				<?php if ($hs == 0) { ?>
				<p>Du besitzt oder wohnst in keinem Haus.</p>
				<?php } else if (!$hausRow) { ?>
				<div class="alert alert-danger">
					<b>Dein Hausschlüssel (#<?=$hs?>) gehört zu keinem Haus in der Datenbank.</b><br>
					Bitte wende dich an einen Administrator.
				</div>
				<?php } else {
					$pX = $hausRow['SymbolX'];
					$pY = $hausRow['SymbolY'];
					$owner = ((UID_BASED) ? $CP->getNameFromUID($hausRow['UID']) : $hausRow['Besitzer']);
				?>
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr>
								<td>ID</td>
								<td><?=(int)$hausRow['ID']?></td>
							</tr>
							<tr>
								<td>Dein Status</td>
								<td><?=(($hausKey > 0) ? 'Besitzer' : 'Mieter')?></td>
							</tr>
							<tr>
								<td>Besitzer</td>
								<td><?=htmlspecialchars($owner)?></td>
							</tr>
							<tr>
								<td>Preis</td>
								<td><?=number_format($hausRow['Preis'],0,"",".")?> $</td>
							</tr>
							<tr>
								<td>Miete</td>
								<td><?=number_format($hausRow['Miete'],0,"",".")?> $</td>
							</tr>
							<?php if (isset($hausRow['Mindestzeit'])) { ?>
							<tr>
								<td>Erforderliche Spielzeit</td>
								<td><?=(int)$hausRow['Mindestzeit']?> Std.</td>
							</tr>
							<?php } ?>
							<tr>
								<td>Interior</td>
								<td><?=(int)$hausRow['CurrentInterior']?></td>
							</tr>
							<tr>
								<td>Position</td>
								<td><?=getZoneName($pX, $pY, 0, true).", ".getZoneName($pX, $pY, 0, false)?></td>
							</tr>
							<?php if ($owner == $CP->Name) { ?>
							<tr>
								<td>Kasse</td>
								<td><?=number_format($hausRow['Kasse'],0,"",".")?> $</td>
							</tr>
							<?php } ?>
							<tr>
								<td>Mieter</td>
								<td><?php
								// Mieter haben den negativen Hausschluessel.
								$mieterListe = array();
								$sqlM = $mySQLcon->query("SELECT Name FROM userdata WHERE Hausschluessel='-".$hs."'");
								while ($sqlM && $rowM = $sqlM->fetch_assoc()) {
									$mieterListe[] = htmlspecialchars($rowM['Name']);
								}
								echo ((count($mieterListe) > 0) ? implode(', ', $mieterListe) : 'Keine');
								?></td>
							</tr>
						</tbody>
					</table>
				</div>
				<br>
				<a href="#" onclick="zeigeKarte('meinHaus'); return false;">Position auf der Karte anzeigen</a>
				<?php } ?>
			</div>
		</div>
	</div>

	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-map-marker"></i> Karte
			</div>
			<div class="panel-body">
				<p>
					<?php if ($hausRow) { ?>
					<a href="#" onclick="zeigeKarte('meinHaus'); return false;"><b>Mein Haus</b></a> &middot;
					<?php } ?>
					<a href="#" onclick="zeigeKarte('freieHaeuser'); return false;">Freie Häuser (<?=count($freiePunkte)?>)</a>
				</p>

				<?php if ($hausRow) { ?>
				<div id="karteMeinHaus">
					<?php cpKarte('karteHaus1', $meinHausPunkt, false); ?>
					<p class="text-muted"><small>Roter Punkt = Dein Haus (#<?=(int)$hausRow['ID']?>) in
					<?=htmlspecialchars(getZoneName($pX, $pY, 0, false))?>.</small></p>
				</div>
				<?php } ?>

				<div id="karteFreieHaeuser" <?=(($hausRow) ? 'style="display: none;"' : '')?>>
					<?php cpKarte('karteHaus2', $freiePunkte, false); ?>
					<p class="text-muted"><small><?=count($freiePunkte)?> freie Häuser. Mit der Maus über einen Punkt fahren zeigt ID und Preis.</small></p>
				</div>
			</div>
		</div>
	</div>
</div>
<script>
	var freieHausPunkte = <?=$jsFreieHaeuser?>;

	function zeigeKarte(welche, alleWiederherstellen) {
		$("#karteMeinHaus").toggle(welche === 'meinHaus');
		$("#karteFreieHaeuser").toggle(welche === 'freieHaeuser');

		// Nach dem Klick auf eine einzelne Zeile alle Häuser wieder einzeichnen.
		if (welche === 'freieHaeuser' && alleWiederherstellen !== false) {
			cpMarker('karteHaus2', freieHausPunkte, false);
		}
	}
</script>




<div class="row">
	<div class="col-md-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				Verfügbare Häuser
			</div>
			<div class="panel-body">
				<p>Klick auf eine Zeile, um die Position auf der Karte anzuzeigen.</p>
				<br>
				<div class="table-responsive">
					<table class="table table-striped table-bordered table-hover" id="dataTables-example">
						<thead>
							<tr>
								<th>#</th>
								<th>Ort</th>
								<th>Interior</th>
								<th>Preis</th>
							</tr>
						</thead>
						<tbody>
							<?php
							$whereFIX = ((UID_BASED) ? "UID='0'" : "Besitzer='none'");
							$sql = $mySQLcon->query("SELECT * FROM houses WHERE ".$whereFIX." ORDER BY ID ASC");
							$freieHaeuser = 0;
							while ($sql && $row = $sql->fetch_assoc()) {
								$freieHaeuser++;

								// Beim Klick nur dieses Haus auf der Karte markieren.
								// (Das frühere showHouseInt() gab es im Panel nie -> JS-Fehler.)
								$markerJS = "zeigeKarte('freieHaeuser', false); cpMarker('karteHaus2', [[".(float)$row['SymbolX'].",".(float)$row['SymbolY'].",'Haus #".(int)$row['ID']."']]);";

								echo "<tr style=\"cursor: pointer;\" onclick=\"".$markerJS."\">
								<td>".(int)$row['ID']."</td>
								<td>".getZoneName($row['SymbolX'], $row['SymbolY'], $row['SymbolZ'], true).", ".getZoneName($row['SymbolX'], $row['SymbolY'], $row['SymbolZ'], false)."</td>
								<td>".(int)$row['CurrentInterior']."</td>
								<td>".number_format($row['Preis'],0,"",".")." $</td>
								</tr>\n";
							}

							if ($freieHaeuser == 0) {
								echo '<tr><td colspan="4">Derzeit steht kein Haus zum Verkauf.</td></tr>';
							}
							?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>
