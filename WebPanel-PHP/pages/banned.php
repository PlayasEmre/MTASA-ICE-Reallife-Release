<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
if (!$CP->Banned) {
	header("Location: ?page=home");
	exit;
}
?>
<div class="row">
	<div class="col-md-12">
		<div class="alert alert-danger"><b>
			<?php
			/*
				STime ist keine echte Unix-Zeit, sondern die ICE-Rechnung
				"Jahr*365*24*60 + Tag*24*60 + Stunde*60 + Minute" (getSecTime).
				Vorher wurde daraus ab 01.01.1900 ein Datum gebildet - wegen der
				fehlenden Schalttage lag das Ergebnis rund einen Monat daneben.
				Jetzt wird die Restzeit auf die aktuelle Uhrzeit gerechnet.
			*/
			$leftBanTime = round((((int)$CP->Banned['STime'] - getSecTime(0)) / 60), 2);
			if ($leftBanTime < 0) { $leftBanTime = 0; }
			$endTime = date('d.m.Y, H:i', time() + (int)round($leftBanTime * 3600));
			?>
			Du wurdest am <i><?=htmlspecialchars($CP->Banned['Datum'])?> Uhr</i> von <i><?php
			$banAdmin = ((UID_BASED) ? (((int)$CP->Banned['AdminUID'] == 0) ? 'System / Anticheat' : $CP->getNameFromUID($CP->Banned['AdminUID'])) : $CP->Banned['Admin']);
			echo htmlspecialchars($banAdmin);
			?></i> <?=(($CP->Banned['STime'] == "0") ? "permanent gebannt" : "gebannt. Du wirst in ".$leftBanTime." Std. (am ".$endTime." Uhr) entbannt")?> (Grund: <i><?=htmlspecialchars($CP->Banned['Grund'])?></i>).
			<br>
			Während Du gebannt bist kannst Du das User-Panel nicht in vollem Umfang nutzen.
		</b></div>
	</div>
</div>