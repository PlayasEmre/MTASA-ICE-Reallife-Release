<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Ranglisten.

	Vorher lag jede Liste in einer eigenen <div class="row"> mit nur einer
	halben Spalte - dadurch stand alles untereinander und die rechte
	Haelfte der Seite blieb leer. Jetzt ein sauberes Raster mit zwei
	Spalten und gleich aufgebauten Panels.

	Alle Listen kommen aus "userdata" bzw. "statistics" (Kills/Tode liegen
	bei ICE dort, nicht in userdata).
*/

/*
	Gibt eine Top-10-Liste aus.
	$spalten: Ueberschriften, $zeilen: fertige Werte-Arrays
	Der eigene Eintrag wird hervorgehoben.
*/
if (!function_exists('rangListe')) {
function rangListe($titel, $icon, $kopf, $zeilen, $eigenerName) {
	echo '<div class="panel panel-default">
		<div class="panel-heading"><i class="fa '.$icon.'"></i> '.htmlspecialchars($titel).'</div>
		<div class="panel-body">
			<div class="table-responsive">
				<table class="table table-striped table-condensed">
					<thead><tr><th style="width: 40px;">#</th>';

	foreach ($kopf as $spalte) {
		echo '<th>'.htmlspecialchars($spalte).'</th>';
	}
	echo '</tr></thead><tbody>';

	if (count($zeilen) == 0) {
		echo '<tr><td colspan="'.(count($kopf) + 1).'">Noch keine Daten vorhanden.</td></tr>';
	}

	$platz = 0;
	foreach ($zeilen as $zeile) {
		$platz++;

		$name = $zeile['name'];
		$istIch = (strtolower($name) == strtolower($eigenerName));
		$stil = (($istIch) ? ' style="background-color: rgba(66,139,202,0.18);"' : '');

		// Kleine Medaille fuer die ersten drei Plaetze.
		$platzText = $platz.'.';
		if ($platz == 1) { $platzText = '<span title="Platz 1">&#129351;</span>'; }
		if ($platz == 2) { $platzText = '<span title="Platz 2">&#129352;</span>'; }
		if ($platz == 3) { $platzText = '<span title="Platz 3">&#129353;</span>'; }

		echo '<tr'.$stil.'>
			<td>'.$platzText.'</td>
			<td>'.htmlspecialchars($name).(($istIch) ? ' <small class="text-muted">(du)</small>' : '').'</td>';

		foreach ($zeile['werte'] as $wert) {
			echo '<td>'.$wert.'</td>';
		}
		echo '</tr>';
	}

	echo '</tbody></table></div></div></div>';
}
}

// ---------------------------------------------------------------
// Daten sammeln
// ---------------------------------------------------------------

// Level / EXP
$level = array();
$sql = $mySQLcon->query("SELECT Name, level, exp FROM userdata ORDER BY level DESC, exp DESC LIMIT 10");
while ($sql && $row = $sql->fetch_assoc()) {
	$level[] = array("name" => $row['Name'], "werte" => array(
		(int)$row['level'],
		number_format($row['exp'],0,"",".")
	));
}

// Geld (Hand + Bank) - in der Datenbank summieren, nicht in PHP.
$geld = array();
$sql = $mySQLcon->query("SELECT Name, (Geld + Bankgeld) AS Gesamt FROM userdata ORDER BY Gesamt DESC LIMIT 10");
while ($sql && $row = $sql->fetch_assoc()) {
	$geld[] = array("name" => $row['Name'], "werte" => array(
		number_format($row['Gesamt'],0,"",".").' $'
	));
}

// Spielzeit
$zeit = array();
$sql = $mySQLcon->query("SELECT Name, Spielzeit FROM userdata ORDER BY Spielzeit DESC LIMIT 10");
while ($sql && $row = $sql->fetch_assoc()) {
	$std = (int)$row['Spielzeit'];
	$zeit[] = array("name" => $row['Name'], "werte" => array(
		floor($std / 60).':'.str_pad($std % 60, 2, "0", STR_PAD_LEFT).' Std.'
	));
}

// Kills / Tode / K-D  (statistics + userdata)
$kills = array();
$sql = $mySQLcon->query("SELECT u.Name AS Name, s.Kills AS Kills, s.Tode AS Tode
	FROM statistics s JOIN userdata u ON u.UID = s.UID
	ORDER BY s.Kills DESC LIMIT 10");
while ($sql && $row = $sql->fetch_assoc()) {
	$k = (int)$row['Kills'];
	$t = (int)$row['Tode'];
	$kills[] = array("name" => $row['Name'], "werte" => array(
		number_format($k,0,"","."),
		number_format($t,0,"","."),
		(($t > 0) ? round($k / $t, 2) : $k)
	));
}

// Gangwar-Kills
$gangwar = array();
$sql = $mySQLcon->query("SELECT u.Name AS Name, s.GangwarKills AS GwKills, s.AnzahlGangwarsGewonnen AS Gewonnen
	FROM statistics s JOIN userdata u ON u.UID = s.UID
	ORDER BY s.GangwarKills DESC LIMIT 10");
while ($sql && $row = $sql->fetch_assoc()) {
	$gangwar[] = array("name" => $row['Name'], "werte" => array(
		number_format($row['GwKills'],0,"","."),
		number_format($row['Gewonnen'],0,"",".")
	));
}

// Bonuspunkte
$bonus = array();
$sql = $mySQLcon->query("SELECT Name, Bonuspunkte FROM userdata ORDER BY Bonuspunkte DESC LIMIT 10");
while ($sql && $row = $sql->fetch_assoc()) {
	$bonus[] = array("name" => $row['Name'], "werte" => array(
		number_format($row['Bonuspunkte'],0,"",".")
	));
}

// Fahrzeuge (Anzahl pro Spieler)
$autos = array();
$sql = $mySQLcon->query("SELECT u.Name AS Name, COUNT(v.id) AS Anzahl
	FROM vehicles v JOIN userdata u ON u.UID = v.UID
	GROUP BY v.UID, u.Name ORDER BY Anzahl DESC LIMIT 10");
while ($sql && $row = $sql->fetch_assoc()) {
	$autos[] = array("name" => $row['Name'], "werte" => array((int)$row['Anzahl']));
}

// Team
$team = array();
$sql = $mySQLcon->query("SELECT Name, Adminlevel FROM userdata WHERE Adminlevel > 0 ORDER BY Adminlevel DESC, Name ASC LIMIT 15");
while ($sql && $row = $sql->fetch_assoc()) {
	$team[] = array("name" => $row['Name'], "werte" => array(cpAdminRangName($row['Adminlevel'])));
}
?>
<div class="row">
	<div class="col-md-6">
		<?php rangListe('Level', 'fa-star', array('Name', 'Level', 'EXP'), $level, $CP->Name); ?>
		<?php rangListe('Spielstunden', 'fa-clock-o', array('Name', 'Zeit'), $zeit, $CP->Name); ?>
		<?php rangListe('Kills', 'fa-crosshairs', array('Name', 'Kills', 'Tode', 'K/D'), $kills, $CP->Name); ?>
		<?php rangListe('Bonuspunkte', 'fa-gift', array('Name', 'Punkte'), $bonus, $CP->Name); ?>
	</div>
	<div class="col-md-6">
		<?php rangListe('Reichste Spieler', 'fa-money', array('Name', 'Geld (Hand + Bank)'), $geld, $CP->Name); ?>
		<?php rangListe('Gangwar', 'fa-flag', array('Name', 'GW-Kills', 'Gewonnen'), $gangwar, $CP->Name); ?>
		<?php rangListe('Meiste Fahrzeuge', 'fa-truck', array('Name', 'Anzahl'), $autos, $CP->Name); ?>
		<?php rangListe('Team', 'fa-shield', array('Name', 'Rang'), $team, $CP->Name); ?>
	</div>
</div>
