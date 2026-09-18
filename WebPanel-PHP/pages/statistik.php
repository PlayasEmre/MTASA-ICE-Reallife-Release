<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Ersetzt die alte Support-Seite.
	Zeigt die Werte aus den ICE-Tabellen "statistics", "skills",
	"playingtime" und "blocks" fuer den eingeloggten Spieler.
*/
$stats  = $CP->UserData['statistics'];
$skills = $CP->UserData['skills'];

// Diese beiden Tabellen laedt cp.class.php nicht mit.
$spielzeitGesamt = 0;
$sql = $mySQLcon->query("SELECT Time FROM playingtime WHERE ".$CP->where());
if ($sql && $sql->num_rows > 0) {
	$row = $sql->fetch_assoc();
	$spielzeitGesamt = (int)$row['Time'];
}

$blockPunkte = 0;
$sql = $mySQLcon->query("SELECT Punkte FROM blocks WHERE ".$CP->where());
if ($sql && $sql->num_rows > 0) {
	$row = $sql->fetch_assoc();
	$blockPunkte = (int)$row['Punkte'];
}

// Kurzschreibweise, damit fehlende Zeilen keine Fehler werfen.
if (!function_exists('statWert')) {
	function statWert($arr, $key) {
		return ((isset($arr[$key])) ? (int)$arr[$key] : 0);
	}
	function statZahl($arr, $key) {
		return number_format(statWert($arr, $key), 0, "", ".");
	}
}

$kills = statWert($stats, 'Kills');
$tode  = statWert($stats, 'Tode');
$gwGewonnen = statWert($stats, 'AnzahlGangwarsGewonnen');
$gwGesamt   = statWert($stats, 'AnzahlGangwars');
?>
<div class="row">
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				Kampf
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr><td width="60%">Kills</td><td><?=statZahl($stats, 'Kills')?></td></tr>
							<tr><td>Tode</td><td><?=statZahl($stats, 'Tode')?></td></tr>
							<tr><td>Kill/Death-Ratio</td><td><?=(($tode > 0) ? round($kills/$tode, 2) : $kills)?></td></tr>
							<tr><td>Schaden ausgeteilt</td><td><?=statZahl($stats, 'DamageGemacht')?></td></tr>
							<tr><td>Schaden bekommen</td><td><?=statZahl($stats, 'DamageBekommen')?></td></tr>
							<tr><td>Tactic-Kills</td><td><?=number_format((int)$CP->UserData['userdata']['TacticKills'],0,"",".")?></td></tr>
							<tr><td>Tactic-Tode</td><td><?=number_format((int)$CP->UserData['userdata']['TacticTode'],0,"",".")?></td></tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>

		<div class="panel panel-default">
			<div class="panel-heading">
				Gangwar
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr><td width="60%">Gangwars gesamt</td><td><?=statZahl($stats, 'AnzahlGangwars')?></td></tr>
							<tr><td>Davon gewonnen</td><td><?=statZahl($stats, 'AnzahlGangwarsGewonnen')?></td></tr>
							<tr><td>Davon verloren</td><td><?=statZahl($stats, 'AnzahlGangwarsVerloren')?></td></tr>
							<tr><td>Siegquote</td><td><?=(($gwGesamt > 0) ? round(($gwGewonnen/$gwGesamt)*100, 1) : 0)?> %</td></tr>
							<tr><td>Gangwar-Kills</td><td><?=statZahl($stats, 'GangwarKills')?></td></tr>
							<tr><td>Gangwar-Tode</td><td><?=statZahl($stats, 'GangwarTode')?></td></tr>
							<tr><td>Gangwar-Schaden ausgeteilt</td><td><?=statZahl($stats, 'GangwarDamageGemacht')?></td></tr>
							<tr><td>Gangwar-Schaden bekommen</td><td><?=statZahl($stats, 'GangwarDamageBekommen')?></td></tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>

		<div class="panel panel-default">
			<div class="panel-heading">
				Knast &amp; Fraktion
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr><td width="60%">Spieler eingeknastet</td><td><?=statZahl($stats, 'AnzahlEingeknastet')?></td></tr>
							<tr><td>Selbst im Knast gewesen</td><td><?=statZahl($stats, 'AnzahlImKnast')?></td></tr>
							<tr><td>Aktuelle Knastzeit</td><td><?=(int)$CP->UserData['userdata']['Knastzeit']?></td></tr>
							<tr><td>Wanteds</td><td><?=(int)$CP->UserData['userdata']['Wanteds']?></td></tr>
							<tr><td>Fraktionen betreten</td><td><?=statZahl($stats, 'FraktionenBetreten')?></td></tr>
							<tr><td>Fraktionen verlassen</td><td><?=statZahl($stats, 'FraktionenVerlassen')?></td></tr>
							<tr><td>Letzter Fraktionswechsel</td><td><?=htmlspecialchars($CP->UserData['userdata']['LastFactionChange'])?></td></tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				Spielzeit
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr><td width="60%">Spielzeit gesamt</td><td><?=floor($spielzeitGesamt/60)?>:<?=str_pad($spielzeitGesamt%60, 2, "0", STR_PAD_LEFT)?> Std.</td></tr>
							<tr><td>Logins</td><td><?=statZahl($stats, 'Eingeloggt')?></td></tr>
							<tr><td>Letzte Woche</td><td><?=statZahl($stats, 'LetzteWocheSpielzeit')?> Min.</td></tr>
							<?php
							$wochentage = array(
								'MontagSpielzeit'		=> 'Montag',
								'DienstagSpielzeit'		=> 'Dienstag',
								'MittwochSpielzeit'		=> 'Mittwoch',
								'DonnerstagSpielzeit'	=> 'Donnerstag',
								'FreitagSpielzeit'		=> 'Freitag',
								'SamstagSpielzeit'		=> 'Samstag',
								'SonntagSpielzeit'		=> 'Sonntag'
							);
							foreach ($wochentage as $spalte => $tag) {
								echo '<tr><td>'.$tag.'</td><td>'.statZahl($stats, $spalte).' Min.</td></tr>';
							}
							?>
						</tbody>
					</table>
				</div>
			</div>
		</div>

		<div class="panel panel-default">
			<div class="panel-heading">
				Skills
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr><td width="60%">Angeln</td><td><?=statZahl($skills, 'fishing')?></td></tr>
							<tr><td>Reparieren</td><td><?=statZahl($skills, 'repair')?></td></tr>
							<tr><td>Glücksspiel</td><td><?=statZahl($skills, 'gamble')?></td></tr>
							<tr><td>Kochen</td><td><?=statZahl($skills, 'cook')?></td></tr>
							<tr><td>Trucker</td><td><?=htmlspecialchars($CP->UserData['userdata']['Truckerskill'])?></td></tr>
							<tr><td>Farmer-Level</td><td><?=(int)$CP->UserData['userdata']['farmerLVL']?></td></tr>
							<tr><td>Bauarbeiter-Level</td><td><?=(int)$CP->UserData['userdata']['bauarbeiterLVL']?></td></tr>
							<tr><td>Bus-Level</td><td><?=(int)$CP->UserData['userdata']['Buslevel']?></td></tr>
							<tr><td>Airport-Level</td><td><?=htmlspecialchars($CP->UserData['userdata']['AirportLevel'])?></td></tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>

		<div class="panel panel-default">
			<div class="panel-heading">
				Besitz &amp; Sonstiges
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr><td width="60%">Häuser gekauft</td><td><?=statZahl($stats, 'HaeuserGekauft')?></td></tr>
							<tr><td>Fahrzeuge gekauft</td><td><?=statZahl($stats, 'FahrzeugeGekauft')?></td></tr>
							<tr><td>Fahrzeuge verkauft</td><td><?=statZahl($stats, 'FahrzeugeVerkauft')?></td></tr>
							<tr><td>Fahrzeug-Slots belegt</td><td><?=(int)$CP->UserData['userdata']['CurrentCars']?> / <?=(int)$CP->UserData['userdata']['MaximumCars']?></td></tr>
							<tr><td>Blockpunkte</td><td><?=number_format($blockPunkte,0,"",".")?></td></tr>
							<tr><td>STVO-Punkte</td><td><?=(int)$CP->UserData['userdata']['StvoPunkte']?></td></tr>
							<tr><td>Straßenreinigung</td><td><?=number_format((int)$CP->UserData['userdata']['StreetCleanPoints'],0,"",".")?></td></tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>
