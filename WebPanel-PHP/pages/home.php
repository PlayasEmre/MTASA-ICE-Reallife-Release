<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
?>
<div class="row">
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				Infos
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr>
								<td rowspan="23" width="150"><img src="assets/img/skins/<?=(int)$CP->UserData['userdata']['Skinid']?>.png" alt=""></td>
								<td height="23" align="left"><b>Name:</b></td>
								<td><?=htmlspecialchars($CP->Name)?></td>
							</tr>
							<tr>
								<td height="23"><b>Registrierungsdatum:</b></td>
								<td><?=htmlspecialchars($CP->UserData['players']['RegisterDatum'])?></td>
							</tr>
							<tr>
								<td height="23"><b>Letzter Login:</b></td>
								<td><?=htmlspecialchars($CP->UserData['players']['Last_login'])?></td>
							</tr>
						</tbody>
					</table>
					
					<table class="table">
						<tbody>
							<tr>
								<td width="150" height="23"><b>Geld:</b></td>
								<td><?=number_format($CP->UserData['userdata']['Geld'],0,"",".")?> $ (Hand), <?=number_format($CP->UserData['userdata']['Bankgeld'],0,"",".")?> $ (Bank)</td>
							</tr>
							<tr>
								<td height="23"><b>Spielzeit:</b></td>
								<td><?=floor($CP->UserData['userdata']['Spielzeit']/60).":".($CP->UserData['userdata']['Spielzeit']%60)?> Std.</td>
							</tr>
							<tr>
								<td height="23"><b>Level:</b></td>
								<td><?=(int)$CP->UserData['userdata']['level']?> (<?=number_format((int)$CP->UserData['userdata']['exp'],0,"",".")?> EXP)</td>
							</tr>
							<tr>
								<td height="23"><b>Coins:</b></td>
								<td><?=number_format((int)$CP->UserData['userdata']['Coins'],0,"",".")?></td>
							</tr>
							<tr>
								<td height="23"><b>Premium:</b></td>
								<td><?php
								// Paketnamen wie ingame (siehe $premiumPakete in cfg.php)
								$paketID	= (int)$CP->UserData['userdata']['PremiumPaket'];
								$paketName	= ((isset($premiumPakete[$paketID])) ? $premiumPakete[$paketID] : 'Paket '.$paketID);

								if ($CP->LeftVIPDays >= 1000) {
									echo '<b>Lifetime</b> ('.htmlspecialchars($paketName).')';
								} else if ($CP->LeftVIPDays > 0) {
									echo 'noch <b>'.$CP->LeftVIPDays.'</b> Tage ('.htmlspecialchars($paketName).')';
								} else {
									echo '<span class="text-muted">Inaktiv</span>';
								}
								?></td>
							</tr>
							<tr>
								<td height="23"><b>Fraktion:</b></td>
								<td><?php
									// Unbekannte Fraktions-ID darf keine PHP-Warnung erzeugen.
									$mFrak = (int)$CP->UserData['userdata']['Fraktion'];
									echo ((isset($factions[$mFrak])) ? htmlspecialchars($factions[$mFrak]['name']) : 'Unbekannt ('.$mFrak.')');
									?> (Rang <?=(int)$CP->UserData['userdata']['FraktionsRang']?>)</td>
							</tr>
							<tr>
								<td height="23"><b>Fahrzeuge:</b></td>
								<td><?=(int)$CP->UserData['userdata']['CurrentCars']?> / <?=(int)$CP->UserData['userdata']['MaximumCars']?> Slots</td>
							</tr>
							<tr>
								<td height="23"><b>Wanteds:</b></td>
								<td><?=(int)$CP->UserData['userdata']['Wanteds']?></td>
							</tr>
							<tr>
								<td height="23"><b>Job:</b></td>
								<td><?=(($CP->UserData['userdata']['Job'] != "none") ? ucfirst($CP->UserData['userdata']['Job']) : "-")?></td>
							</tr>
							<tr>
								<td height="23"><b>Sozialer Status:</b></td>
								<td><?=htmlspecialchars($CP->UserData['userdata']['SocialState'])?></td>
							</tr>
							<tr>
								<td height="23"><b>Telefonnummer:</b></td>
								<td><?=htmlspecialchars($CP->UserData['userdata']['Telefonnr'])?></td>
							</tr>
							<tr>
								<td height="23"><b>Bonuspunkte:</b></td>
								<td><?=number_format($CP->UserData['userdata']['Bonuspunkte'],0,"",".")?></td>
							</tr>
							<tr>
								<td height="23"><b>STVO-Punkte:</b></td>
								<td><?=(int)$CP->UserData['userdata']['StvoPunkte']?></td>
							</tr>
							<tr>
								<td height="23"><b>Warns:</b></td>
								<td><?=(int)$CP->UserData['userdata']['Warns']?></td>
							</tr>
							<?php
							// ICE speichert Kills/Tode in der Tabelle "statistics", nicht in "userdata".
							$kills = (int)((UID_BASED) ? $CP->UserData['statistics']['Kills'] : $CP->UserData['userdata']['Kills']);
							$tode  = (int)((UID_BASED) ? $CP->UserData['statistics']['Tode']  : $CP->UserData['userdata']['Tode']);
							?>
							<tr>
								<td height="23"><b>Kills:</b></td>
								<td><?=number_format($kills,0,"",".")?></td>
							</tr>
							<tr>
								<td height="23"><b>Tode:</b></td>
								<td><?=number_format($tode,0,"",".")?></td>
							</tr>
							<tr>
								<td height="23"><b>Kill/Death-Ratio:</b></td>
								<td><?=(($tode > 0) ? round($kills/$tode, 2) : $kills)?></td>
							</tr>
							<tr>
								<td height="23"><b>GWD-Note:</b></td>
								<?php
								/*
									ICE speichert 10 Werte als "|1|2|...|10" (saveArmyPermissions).
									Der 10. Wert ist die GWD-Note. Beim DB-Standardwert
									"|0|0|0|0|0|0|0|0|0|" fehlt er - dann 0 anzeigen.
								*/
								$ex = explode('|', (string)$CP->UserData['userdata']['ArmyPermissions']);
								$gwdIndex = ((UID_BASED) ? 10 : 9);
								$gwd = ((isset($ex[$gwdIndex]) && $ex[$gwdIndex] !== '') ? (int)$ex[$gwdIndex] : 0);
								?>
								<td><?=$gwd?> %</td>
							</tr>
						</tbody>
					</table>
					
				</div>
			</div>
		</div>
	</div>
	
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				Achievments
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr>
								<td height="23">Angler</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['Angler'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Chicken Dinner</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['ChickenDinner'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Der Sammler</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['DerSammler'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Eigene Füße</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['EigeneFuesse'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Fahrzeugwahn</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['Fahrzeugwahn'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Highscore</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['highscore'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Highway to Hell</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['HighwayToHell'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">King of the Hill</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['KingOfTheHill'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Mr. License</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['Lizensen'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Nichts geht mehr</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['NichtGehtMehr'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Reallife WTF?</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['ReallifeWTF'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Revolverheld</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['Revolverheld'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Schlaflos in SA</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['SchlaflosInSA'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Silent Assasin</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['SilentAssasin'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">The Truth is out there</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['TheTruthIsOutThere'] == 'done') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr>
								<td height="23">Waffenschieber</td>
								<td><img src="assets/img/<?=(($CP->UserData['achievments']['Waffenschieber'] != "0") ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
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
				Scheine
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<tr height="22">
								<td valign="top">Autoführerschein</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['Autofuehrerschein'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Motorradführerschein</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['Motorradtfuehrerschein'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">LKW-Führerschein</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['LKWfuehrerschein'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Helikopterführerschein</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['Helikopterfuehrerschein'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Flugschein Klasse A</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['FlugscheinKlasseA'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Flugschein Klasse B</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['FlugscheinKlasseB'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Motorbootschein</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['Motorbootschein'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Seegelschein</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['Segelschein'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Angelschein</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['Angelschein'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Waffenschein</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['Waffenschein'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Personalausweiß</td>
								<td><img src="assets/img/<?=(($CP->UserData['userdata']['Perso'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		
		
		<div class="panel panel-default">
			<div class="panel-heading">
				<i class="fa fa-users"></i> Spieler Online
			</div>
			<div class="panel-body">
				<?php
				/*
					Wer ist online?

					Zwei Wege - der erste funktioniert immer, auch ohne
					Datenbank-Eintraege und ohne Server-Neustart.
				*/
				$onlineSpieler	= array();
				$proFraktion	= array();
				$ohneUserdata	= array();
				$quelle			= "";

				/*
					Weg 1: direkt beim Spielserver nachfragen (ASE-Port).
					Das klappt ohne Datenbank, ohne Passwort und ohne
					Server-Neustart - siehe cpMtaAseAbfrage in usefull.php.
				*/
				$serverStatus = cpMtaAseAbfrage();

				if ($serverStatus && !empty($serverStatus['ok']) && count($serverStatus['spieler']) > 0) {
					$quelle = "Spielserver";

					/*
						Zu jedem Namen die Fraktion aus userdata holen.
						Eine Abfrage fuer alle Namen zusammen.
					*/
					$namenEscaped = array();
					foreach ($serverStatus['spieler'] as $sp) {
						$namenEscaped[] = "'".$mySQLcon->escape_string($sp)."'";
					}

					$fraktionVonName = array();
					$sqlF = $mySQLcon->query("SELECT Name, Fraktion FROM userdata WHERE Name IN (".implode(',', $namenEscaped).")");
					while ($sqlF && $rowF = $sqlF->fetch_assoc()) {
						$fraktionVonName[strtolower($rowF['Name'])] = (int)$rowF['Fraktion'];
					}

					foreach ($serverStatus['spieler'] as $sp) {
						$fID = ((isset($fraktionVonName[strtolower($sp)])) ? $fraktionVonName[strtolower($sp)] : 0);
						$onlineSpieler[] = array("name" => $sp, "fraktion" => $fID);
						if (!isset($proFraktion[$fID])) { $proFraktion[$fID] = 0; }
						$proFraktion[$fID]++;
					}

				} else {
					/*
						Weg 2: Tabelle "loggedin" (der Spielserver pflegt sie).
						LEFT JOIN, damit ein Spieler ohne userdata-Datensatz nicht
						stillschweigend verschwindet.
					*/
					$quelle = "Datenbank";

					$sql = $mySQLcon->query("SELECT l.UID AS UID, u.Name AS Name, u.Fraktion AS Fraktion
						FROM loggedin l LEFT JOIN userdata u ON u.UID = l.UID
						WHERE l.Loggedin='1' ORDER BY u.Name ASC");
					while ($sql && $row = $sql->fetch_assoc()) {
						if ($row['Name'] === null) {
							$ohneUserdata[] = (int)$row['UID'];
							continue;
						}
						$fID = (int)$row['Fraktion'];
						$onlineSpieler[] = array("name" => $row['Name'], "fraktion" => $fID);
						if (!isset($proFraktion[$fID])) { $proFraktion[$fID] = 0; }
						$proFraktion[$fID]++;
					}
				}

				$online			= count($onlineSpieler);
				$registriert	= cpCountRows($mySQLcon, "SELECT UID FROM players");

				// Zum Erkennen, WARUM die Liste leer ist:
				$zeilenLoggedin	= cpCountRows($mySQLcon, "SELECT UID FROM loggedin");
				$zeilenAktiv	= cpCountRows($mySQLcon, "SELECT UID FROM loggedin WHERE Loggedin='1'");
				?>
				<div style="font-size: 15px; margin-bottom: 12px;">
					<span class="label label-<?=(($online > 0) ? 'success' : 'default')?>" style="font-size: 15px;">
						<?=$online?> <?=(($online == 1) ? 'Spieler' : 'Spieler')?> online
					</span>
					<span class="text-muted" style="margin-left: 8px;">
						von <?=number_format($registriert,0,"",".")?> registrierten
					</span>
				</div>

				<?php if ($online == 0) { ?>
				<p class="text-muted">
					Zur Zeit ist niemand im Spiel.
				</p>
				<div class="alert alert-info" style="font-size: 12px;">
					<b>Woher diese Angabe kommt:</b><br>
					<?php
					if ($serverStatus && !empty($serverStatus['ok'])) {
						echo 'Direkt vom Spielserver <b>'.htmlspecialchars($serverStatus['name']).'</b>
						(<code>'.htmlspecialchars(MTA_IP).':'.(int)MTA_PORT.'</code>) — er meldet
						<b>'.(int)$serverStatus['anzahl'].'</b> von '.(int)$serverStatus['max'].' Spielern.';
					} else {
						echo 'Der Spielserver antwortet nicht auf <code>'.htmlspecialchars(MTA_IP).':'.((int)MTA_PORT + 123).'</code>'
							.((isset($serverStatus['fehler'])) ? '<br><small>'.htmlspecialchars($serverStatus['fehler']).'</small>' : '').'<br>
						Deshalb wird die Datenbank benutzt: Einträge in <code>loggedin</code>: <b>'.$zeilenLoggedin.'</b>,
						davon eingeloggt: <b>'.$zeilenAktiv.'</b>.<br><br>
						Läuft der Server? Stimmt <code>MTA_IP</code> / <code>MTA_PORT</code> in <code>cfg.php</code>?
						Mehr dazu unter <a href="?page=diagnose">System-Check</a>.';
					}
					?>
				</div>
				<?php } else { ?>
				<p><small class="text-muted">
					<?php if ($quelle == "Spielserver") { ?>
					Quelle: direkte Abfrage beim Spielserver. Die Liste zeigt <b>alle</b> Spieler auf dem
					Server — also auch die, die noch im Login-Fenster stehen (die erscheinen dann als Zivilist).
					<?php } else { ?>
					Quelle: Datenbank (Tabelle <code>loggedin</code>) — der Spielserver war nicht erreichbar.
					<?php } ?>
				</small></p>
				<?php if (count($ohneUserdata) > 0) { ?>
				<div class="alert alert-warning" style="font-size: 12px;">
					Zu <?=count($ohneUserdata)?> eingeloggten UID(s) fehlt der Datensatz in <code>userdata</code>
					(UID: <?=htmlspecialchars(implode(', ', $ohneUserdata))?>) — sie fehlen in der Liste.
				</div>
				<?php } ?>
				<div class="table-responsive">
					<table class="table table-condensed">
						<tbody>
							<?php
							foreach ($onlineSpieler as $sp) {
								$fID	= $sp['fraktion'];
								$fName	= ((isset($factions[$fID])) ? $factions[$fID]['name'] : 'Unbekannt ('.$fID.')');
								$fRGB	= ((isset($factions[$fID])) ? $factions[$fID]['rgb'] : '200,200,200');
								$ich	= ((strtolower($sp['name']) == strtolower($CP->Name)) ? ' <small class="text-muted">(du)</small>' : '');

								echo '<tr>
									<td><b>'.htmlspecialchars($sp['name']).'</b>'.$ich.'</td>
									<td style="text-align: right;">
										<span style="display:inline-block; width:10px; height:10px; background:rgb('.$fRGB.'); border:1px solid #999; margin-right:5px;"></span>
										'.htmlspecialchars($fName).'
									</td>
								</tr>';
							}
							?>
						</tbody>
					</table>
				</div>
				<?php } ?>

				<hr>
				<p><b>Fraktionen</b> <small class="text-muted">(Farbe = Fraktion, Zahl = gerade online)</small></p>
				<div>
					<?php
					foreach ($factions as $key => $val) {
						$anzahl = ((isset($proFraktion[$key])) ? $proFraktion[$key] : 0);
						$stark  = (($anzahl > 0) ? 'font-weight: bold;' : 'opacity: 0.65;');

						echo '<div style="display:inline-block; margin: 0 10px 6px 0; white-space: nowrap; '.$stark.'">
							<span style="display:inline-block; width:12px; height:12px; background:rgb('.$val['rgb'].'); border:1px solid #999; vertical-align:middle; margin-right:4px;"></span>
							'.htmlspecialchars($val['name']).' <span class="text-muted">('.$anzahl.')</span>
						</div>';
					}
					?>
				</div>
			</div>
		</div>
	</div>
	
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				Skills
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							
							<tr height="22">
								<td colspan="2"><b>Fahrzeuge:</b></td>
							</tr>
							<tr height="22">
								<td valign="top">Fahrzeugslots</td>
								<?php
								// ICE: bonustable.CarslotUpdate2..5 (int) + CarslotUpgrades (varchar 'buyed')
								// Angezeigt werden die tatsaechlich freigeschalteten Slots.
								$fix = "true";
								$slots = (int)$CP->UserData['userdata']['MaximumCars'];
								if ($slots <= 0) { $slots = 5; }

								$gekauft = 0;
								if ($CP->UserData['bonustable']['CarslotUpgrades'] == "buyed") { $gekauft++; }
								foreach (array('CarslotUpdate2', 'CarslotUpdate3', 'CarslotUpdate4', 'CarslotUpdate5') as $col) {
									if (isset($CP->UserData['bonustable'][$col]) && $CP->UserData['bonustable'][$col] == "1") { $gekauft++; }
								}
								if ($gekauft == 0) { $fix = "false"; }
								?>
								<td><img src="assets/img/<?=$fix?>.png" width="16" height="16" alt=""> (<?=$slots?> Slots)</td>
							</tr>
							<tr height="22">
								<td valign="top">Vortex</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['Vortex'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Skimmer</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['Skimmer'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Caddy</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['Caddy'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Leichenwagen</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['Leichenwagen'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Quad</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['Quad'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							
							<tr height="22">
								<td colspan="2"><br><b>Items:</b></td>
							</tr>
							<tr height="22">
								<td valign="top">Fernglas</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['fglass'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Notebook</td>
								<td><img src="assets/img/<?=(($CP->UserData['inventar']['FruitNotebook'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Medikit</td>
								<td><img src="assets/img/<?=(($CP->UserData['inventar']['Medikit'] > 0) ? 'true' : 'false')?>.png" width="16" height="16" alt=""> (<?=(int)$CP->UserData['inventar']['Medikit']?>)</td>
							</tr>
							<tr height="22">
								<td valign="top">Repairkit</td>
								<td><img src="assets/img/<?=(($CP->UserData['inventar']['Repairkit'] > 0) ? 'true' : 'false')?>.png" width="16" height="16" alt=""> (<?=(int)$CP->UserData['inventar']['Repairkit']?>)</td>
							</tr>
							
							<tr height="22">
								<td colspan="2"><br><b>Kampfstile:</b></td>
							</tr>
							<tr height="22">
								<td valign="top">Boxen</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['Boxen'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Kung-Fu</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['KungFu'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Streetfighting</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['Streetfighting'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							
							<tr height="22">
								<td colspan="2"><br><b>Körperlich:</b></td>
							</tr>
							<tr height="22">
								<td valign="top">Lungenvolumen</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['Lungenvolumen'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Muskeln</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['Muskeln'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Kondition</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['Kondition'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							
							<tr height="22">
								<td colspan="2"><br><b>Skins:</b></td>
							</tr>
							<tr height="22">
								<td valign="top">Cluckin Bell</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['BonusSkin1'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							
							<tr height="22">
								<td colspan="2"><br><b>Waffenskills:</b></td>
							</tr>
							<tr height="22">
								<td valign="top">Pistole</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['PistolenSkill'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Deagle</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['DeagleSkill'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Sturmgewehr</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['AssaultSkill'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Schrotflinten</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['ShotgunSkill'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">MP5</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['MP5Skills'] == 'buyed') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
							<tr height="22">
								<td valign="top">Doppel SMG</td>
								<td><img src="assets/img/<?=(($CP->UserData['bonustable']['uzi'] == '1') ? 'true' : 'false')?>.png" width="16" height="16" alt=""></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>