<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Angepasst fuer ICE:
	- $_POST['nick'] wurde ungeprueft benutzt -> beim ersten Aufruf gab es
	  in PHP 8 die Warnung "Undefined array key nick"
	- der Name wird jetzt auch per GET akzeptiert (Link aus der Online-Liste)
	- Vergleich mit "=" statt LIKE, damit % und _ keine fremden Accounts treffen
	- alle Ausgaben werden escaped
*/
$nick = "";
if (isset($_POST['nick'])) {
	$nick = trim($_POST['nick']);
} else if (isset($_GET['nick'])) {
	$nick = trim($_GET['nick']);
}

$players	= false;
$userdata	= false;

if ($nick != "") {
	$sql = $mySQLcon->query("SELECT * FROM players WHERE Name='".$mySQLcon->escape_string($nick)."'");
	if ($sql && $sql->num_rows > 0) {
		$players = $sql->fetch_assoc();

		$sql = $mySQLcon->query("SELECT * FROM userdata WHERE UID='".(int)$players['UID']."'");
		$userdata = (($sql && $sql->num_rows > 0) ? $sql->fetch_assoc() : array());
	}
}

// Liefert einen Wert aus userdata, auch wenn der Datensatz fehlt.
if (!function_exists('cpUD')) {
	function cpUD($arr, $key, $default = '-') {
		return ((isset($arr[$key])) ? $arr[$key] : $default);
	}
}
?>
<div class="row">
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				Spieler
			</div>
			<div class="panel-body">
				<?php if ($players) { ?>
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr>
								<td><b>Name:</b></td>
								<td><?=htmlspecialchars($players['Name'])?></td>
							</tr>
							<tr>
								<td><b>User-ID:</b></td>
								<td><?=((isset($players['id']) && !empty($players['id'])) ? (int)$players['id'] : (int)$players['UID'])?></td>
							</tr>
							<tr>
								<td><b>Registrierungsdatum:</b></td>
								<td><?=htmlspecialchars($players['RegisterDatum'])?></td>
							</tr>
							<tr>
								<td><b>Letzter Login:</b></td>
								<td><?=htmlspecialchars($players['Last_login'])?></td>
							</tr>
							<tr>
								<td><b>Serial:</b></td>
								<td><?=htmlspecialchars($players['Serial'])?></td>
							</tr>
							<tr>
								<td><b>IP-Adresse:</b></td>
								<td><?=htmlspecialchars($players['IP'])?></td>
							</tr>
							<tr>
								<td><b>Geburtsdatum:</b></td>
								<td><?=(int)$players['Geburtsdatum_Tag']?>.<?=(int)$players['Geburtsdatum_Monat']?>.<?=(int)$players['Geburtsdatum_Jahr']?></td>
							</tr>
							<tr>
								<td><b>Geschlecht:</b></td>
								<td><?=(($players['Geschlecht'] == "0") ? "Männlich" : "Weiblich")?></td>
							</tr>
							<tr>
								<td><b>Aktuell eingeloggt:</b></td>
								<td><?php
								$sqlL = $mySQLcon->query("SELECT Loggedin FROM loggedin WHERE UID='".(int)$players['UID']."'");
								$rowL = (($sqlL && $sqlL->num_rows > 0) ? $sqlL->fetch_assoc() : false);
								echo (($rowL && $rowL['Loggedin'] == "1") ? '<b>Ja</b>' : 'Nein');
								?></td>
							</tr>
							<tr>
								<td><b>Ban:</b></td>
								<td><?php
								$sqlB = $mySQLcon->query("SELECT * FROM ban WHERE UID='".(int)$players['UID']."'");
								$rowB = (($sqlB && $sqlB->num_rows > 0) ? $sqlB->fetch_assoc() : false);
								if (!$rowB) {
									echo 'Nicht gebannt';
								} else {
									$sTime = (int)$rowB['STime'];
									if ($sTime == 0) {
										echo '<b>Permanent gebannt</b> (Grund: '.htmlspecialchars($rowB['Grund']).')';
									} else {
										$rest = round((($sTime - getSecTime(0)) / 60), 2);
										echo (($rest > 0) ? '<b>Noch '.$rest.' Std. gebannt</b>' : 'Ban abgelaufen').' (Grund: '.htmlspecialchars($rowB['Grund']).')';
									}
									echo ' &ndash; <a href="?page=admin-bans">verwalten</a>';
								}
								?></td>
							</tr>
							<tr>
								<td><b>Geld:</b></td>
								<td><?=number_format((float)cpUD($userdata, 'Geld', 0),0,"",".")?> $ (Hand), <?=number_format((float)cpUD($userdata, 'Bankgeld', 0),0,"",".")?> $ (Bank)</td>
							</tr>
							<tr>
								<td><b>Coins:</b></td>
								<td><?=number_format((int)cpUD($userdata, 'Coins', 0),0,"",".")?></td>
							</tr>
							<tr>
								<td><b>Spielzeit:</b></td>
								<td><?php
								$spielzeit = (int)cpUD($userdata, 'Spielzeit', 0);
								echo floor($spielzeit/60).":".str_pad($spielzeit%60, 2, "0", STR_PAD_LEFT);
								?> Std.</td>
							</tr>
							<tr>
								<td><b>Adminlevel:</b></td>
								<td><?=htmlspecialchars(cpAdminRangName(cpUD($userdata, 'Adminlevel', 0)))?> (<?=(int)cpUD($userdata, 'Adminlevel', 0)?>)</td>
							</tr>
							<tr>
								<td><b>Fraktion:</b></td>
								<td><?php
								$fID = (int)cpUD($userdata, 'Fraktion', 0);
								echo ((isset($factions[$fID])) ? htmlspecialchars($factions[$fID]['name']) : 'Unbekannt ('.$fID.')');
								?> (Rang <?=(int)cpUD($userdata, 'FraktionsRang', 0)?>)</td>
							</tr>
							<tr>
								<td><b>Job:</b></td>
								<td><?=((cpUD($userdata, 'Job', 'none') != "none") ? htmlspecialchars(ucfirst(cpUD($userdata, 'Job'))) : "-")?></td>
							</tr>
							<tr>
								<td><b>Sozialer Status:</b></td>
								<td><?=htmlspecialchars(cpUD($userdata, 'SocialState'))?></td>
							</tr>
							<tr>
								<td><b>Telefonnummer:</b></td>
								<td><?=htmlspecialchars(cpUD($userdata, 'Telefonnr'))?></td>
							</tr>
							<tr>
								<td><b>Bonuspunkte:</b></td>
								<td><?=number_format((int)cpUD($userdata, 'Bonuspunkte', 0),0,"",".")?></td>
							</tr>
							<tr>
								<td><b>Warns:</b></td>
								<td>
									<?php
									$whereFIX = "player='".$mySQLcon->escape_string($players['Name'])."'";
									if (UID_BASED) {
										$whereFIX = "UID='".(int)$players['UID']."'";
									}
									$sqlW = $mySQLcon->query("SELECT * FROM warns WHERE ".$whereFIX);
									echo (($sqlW) ? (int)$sqlW->num_rows : 0);
									?>
									<br>
									<ul>
										<?php
										while ($sqlW && $row = $sqlW->fetch_assoc()) {
											$admin = ((UID_BASED) ? $CP->getNameFromUID($row['adminUID']) : $row['admin']);
											echo '<li>Admin: '.htmlspecialchars($admin).', Grund: '.htmlspecialchars($row['reason']).'</li>';
										}
										?>
									</ul>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<a href="?page=admin-checkplayer">Anderen Spieler überprüfen</a>
				<?php } else { ?>
				<?php if ($nick != "") { ?>
				<div class="alert alert-danger"><b>Es gibt keinen Spieler mit dem Namen "<?=htmlspecialchars($nick)?>".</b></div>
				<?php } ?>
				<p>Gib den Namen des Spielers ein welchen du Überprüfen möchtest.</p>
				<form role="form" action="?page=admin-checkplayer" method="post">
					<div class="form-group">
						<label>Spielername</label>
						<input class="form-control" type="text" name="nick" value="<?=htmlspecialchars($nick)?>" />
					</div>
					<button type="submit" class="btn btn-default" name="check">Check</button>
				</form>
				<?php } ?>
			</div>
		</div>
	</div>
</div>
