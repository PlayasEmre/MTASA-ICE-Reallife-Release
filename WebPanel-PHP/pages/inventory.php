<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
?>
<div class="row">
	<div class="col-md-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				Inventar
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<thead>
							<tr>
								<th>Item</th>
								<th>Anzahl</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td>Würfel</td>
								<td><?=(int)$CP->UserData['inventar']['Wuerfel']?></td>
							</tr>
							<tr>
								<td>Zigaretten</td>
								<td><?=number_format($CP->UserData['inventar']['Zigaretten'],0,"",".")?></td>
							</tr>
							<tr>
								<td>Materials</td>
								<td><?=number_format($CP->UserData['inventar']['Materials'],0,"",".")?></td>
							</tr>
							<tr>
								<td>Drogen</td>
								<td><?=number_format($CP->UserData['userdata']['Drogen'],0,"",".")?></td>
							</tr>
							<tr>
								<td>Benzinkanister</td>
								<td><?=number_format($CP->UserData['inventar']['Benzinkanister'],0,"",".")?></td>
							</tr>
							<tr>
								<td>Casino Chips</td>
								<td><?=number_format($CP->UserData['inventar']['Chips'],0,"",".")?></td>
							</tr>
							<tr>
								<td>Geschenke</td>
								<td><?=number_format($CP->UserData['inventar']['Geschenke'],0,"",".")?></td>
							</tr>
							<tr>
								<td>Kürbisse</td>
								<td><?=number_format($CP->UserData['inventar']['kuerbisse'],0,"",".")?></td>
							</tr>
							<tr>
								<td>Medikits</td>
								<td><?=number_format($CP->UserData['inventar']['Medikit'],0,"",".")?></td>
							</tr>
							<tr>
								<td>Repairkits</td>
								<td><?=number_format($CP->UserData['inventar']['Repairkit'],0,"",".")?></td>
							</tr>
							<tr>
								<td>Blumensamen</td>
								<td><?=number_format($CP->UserData['inventar']['Blumensamen'],0,"",".")?></td>
							</tr>
							<tr>
								<td>Fernglas</td>
								<td><?=(($CP->UserData['inventar']['fglass'] == '1') ? 'Ja' : 'Nein')?></td>
							</tr>
							<tr>
								<td>Platzierbares Objekt</td>
								<td><?=(($CP->UserData['inventar']['Objekt'] > 0) ? '#'.(int)$CP->UserData['inventar']['Objekt'] : '-')?></td>
							</tr>
							<tr>
								<?php
								/*
									inventar.Spezial ist standardmaessig leer. Fehlende
									Felder mit 0 auffuellen, sonst PHP-8-Warnungen.
								*/
								$spezmun = explode("|", (string)$CP->UserData['inventar']['Spezial']);
								for ($sm = 0; $sm <= 6; $sm++) {
									if (!isset($spezmun[$sm]) || $spezmun[$sm] === '') { $spezmun[$sm] = 0; }
								}
								?>
								<td>Phosphor-Munition</td>
								<td><?=number_format($spezmun[1],0,"",".")?></td>
							</tr>
							<tr>
								<td>Dumdum-Munition</td>
								<td><?=number_format($spezmun[2],0,"",".")?></td>
							</tr>
							<tr>
								<td>Panzer-Munition</td>
								<td><?=number_format($spezmun[3],0,"",".")?></td>
							</tr>
							<tr>
								<td>Vulcano-Munition</td>
								<td><?=number_format($spezmun[4],0,"",".")?></td>
							</tr>
							<tr>
								<td>Pfeffer-Munition</td>
								<td><?=number_format($spezmun[5],0,"",".")?></td>
							</tr>
							<tr>
								<td>Halloween-Munition</td>
								<td><?=number_format($spezmun[6],0,"",".")?></td>
							</tr>
							<tr>
								<?php
								$huf = explode("|", (string)$CP->UserData['achievments']['Hufeisen']);
								$hufeisen = 0;
								for ($i = 0; $i <= 24; $i++) {
									$hufeisen = $hufeisen + ((isset($huf[$i])) ? (int)$huf[$i] : 0);
								}
								?>
								<td>Hufeisen</td>
								<td><?=$hufeisen?>/25</td>
							</tr>
							<tr>
								<?php
								$look = explode("|", (string)$CP->UserData['achievments']['LookoutsA']);
								$lookouts = 0;
								for ($i = 0; $i <= 9; $i++) {
									$lookouts = $lookouts + ((isset($look[$i])) ? (int)$look[$i] : 0);
								}
								?>
								<td>Aussichtspunkte</td>
								<td><?=$lookouts?>/10</td>
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
				Waffenbox
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<tbody>
							<td width="33%" align="center">
								<b>Slot 1</b>
								<br>
								<?php
								$weaponID = "0";
								$weapon = "Leer";
								$ammo = "0";
								
								$slot = $CP->UserData['userdata']['Gunbox1'];
								$sInfo = cpParseWeaponSlot($slot);
								$weaponID = $sInfo['id'];
								$weapon = $sInfo['name'];
								$ammo = $sInfo['ammo'];
								?>
								<img src="assets/img/weapons/weapon_<?=$weaponID?>.png" width="64" style="margin: 5px;">
								<br>
								<?=$weapon?>
								<br>
								<?=$ammo?> Schuss
							</td>
							
							<td width="33%" align="center">
								<b>Slot 2</b>
								<br>
								<?php
								$weaponID = "0";
								$weapon = "Leer";
								$ammo = "0";
								
								$slot = $CP->UserData['userdata']['Gunbox2'];
								$sInfo = cpParseWeaponSlot($slot);
								$weaponID = $sInfo['id'];
								$weapon = $sInfo['name'];
								$ammo = $sInfo['ammo'];
								?>
								<img src="assets/img/weapons/weapon_<?=$weaponID?>.png" width="64" style="margin: 5px;">
								<br>
								<?=$weapon?>
								<br>
								<?=$ammo?> Schuss
							</td>
							
							<td width="33%" align="center">
								<b>Slot 3</b>
								<br>
								<?php
								$weaponID = "0";
								$weapon = "Leer";
								$ammo = "0";
								
								$slot = $CP->UserData['userdata']['Gunbox3'];
								$sInfo = cpParseWeaponSlot($slot);
								$weaponID = $sInfo['id'];
								$weapon = $sInfo['name'];
								$ammo = $sInfo['ammo'];
								?>
								<img src="assets/img/weapons/weapon_<?=$weaponID?>.png" width="64" style="margin: 5px;">
								<br>
								<?=$weapon?>
								<br>
								<?=$ammo?> Schuss
							</td>
						</tbody>
					</table>
				</div>
			</div>
		</div>

		<div class="panel panel-default">
			<div class="panel-heading">
				Getragene Waffen
			</div>
			<div class="panel-body">
				<div class="table-responsive">
					<table class="table">
						<thead>
							<tr>
								<th>Slot</th>
								<th>Waffe</th>
								<th>Munition</th>
							</tr>
						</thead>
						<tbody>
							<?php
							// ICE: inventar.Waffenslot1-3 im Format "WaffenID|Munition"
							for ($i = 1; $i <= 3; $i++) {
								$slot = $CP->UserData['inventar']['Waffenslot'.$i];
								$wName = "Leer";
								$wAmmo = "-";

								if (!empty($slot) && $slot != "0") {
									$teile = explode('|', $slot);
									if (isset($teile[0]) && $teile[0] > 0) {
										$wName = ((isset($weaponNames[$teile[0]])) ? $weaponNames[$teile[0]] : 'Waffe #'.(int)$teile[0]);
										$wAmmo = number_format((isset($teile[1]) ? $teile[1] : 0),0,"",".")." Schuss";
									}
								}

								echo '<tr>
									<td>'.$i.'</td>
									<td>'.htmlspecialchars($wName).'</td>
									<td>'.$wAmmo.'</td>
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