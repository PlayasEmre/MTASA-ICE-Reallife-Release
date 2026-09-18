<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	HINWEIS: Diese Datei wird vom Panel nicht mehr gebraucht.

	Die Karten in den Seiten (Haus, Fahrzeuge, Autohäuser) werden inzwischen
	von cpKarte() in usefull.php erzeugt - als normales Bild mit CSS-Markierungen,
	also ohne die PHP-Erweiterung GD. Fehlte GD, kam hier nur Text zurueck und
	im Browser war nichts zu sehen.

	Die Datei bleibt als Alternative erhalten (z.B. wenn man ein fertiges
	Kartenbild zum Herunterladen braucht) und funktioniert nur mit GD.

	------------------------------------------------------------------
	Zeichnet Markierungen auf die San-Andreas-Karte.

	Aufruf:
	  map.php?x=1234&y=-567              eine Markierung (wie bisher)
	  map.php?p=1234,-567;890,120        mehrere Markierungen
	  map.php?p=...&nr=1                 Markierungen durchnummerieren

	Korrekturen gegenueber der alten Version:
	- Koordinaten werden als Zahl behandelt. In PHP 8 wirft "abc" + 3000
	  einen TypeError -> die Karte blieb komplett leer.
	- ImageCopy erwartet int. PHP 8.1 warnt bei float ("Implicit conversion
	  from float ... loses precision") - die Warnung landete mitten im
	  JPEG-Datenstrom und machte das Bild kaputt.
	- Fehlt GD oder eine Bilddatei, kommt eine verstaendliche Meldung.
*/

if (!function_exists('imagecreatefromjpeg')) {
	header("Content-Type: text/plain; charset=utf-8");
	exit("Die PHP-Erweiterung GD ist nicht aktiv. In der php.ini das Semikolon vor \"extension=gd\" entfernen und Apache neu starten.");
}

$mapFile  = __DIR__.DIRECTORY_SEPARATOR."..".DIRECTORY_SEPARATOR."assets".DIRECTORY_SEPARATOR."img".DIRECTORY_SEPARATOR."map.jpg";
$markFile = __DIR__.DIRECTORY_SEPARATOR."..".DIRECTORY_SEPARATOR."assets".DIRECTORY_SEPARATOR."img".DIRECTORY_SEPARATOR."mark.png";

if (!is_file($mapFile) || !is_file($markFile)) {
	header("Content-Type: text/plain; charset=utf-8");
	exit("Kartenbilder nicht gefunden (assets/img/map.jpg bzw. mark.png).");
}

/*
	Punkte einsammeln.
	"p" hat Vorrang, "x"/"y" bleibt fuer alte Aufrufe erhalten.
*/
$punkte = array();

if (isset($_GET['p']) && is_string($_GET['p']) && $_GET['p'] !== '') {
	foreach (explode(';', $_GET['p']) as $paar) {
		$xy = explode(',', $paar);
		if (count($xy) < 2) { continue; }
		if (!is_numeric(trim($xy[0])) || !is_numeric(trim($xy[1]))) { continue; }
		$punkte[] = array((float)$xy[0], (float)$xy[1]);
	}
} else if (isset($_GET['x']) && isset($_GET['y'])) {
	$punkte[] = array((float)$_GET['x'], (float)$_GET['y']);
}

$map  = @imagecreatefromjpeg($mapFile);
$mark = @imagecreatefrompng($markFile);

if (!$map || !$mark) {
	header("Content-Type: text/plain; charset=utf-8");
	exit("Die Kartenbilder konnten nicht geladen werden.");
}

header("Content-Type: image/jpeg");
header("Cache-Control: no-cache");

$mapW	= imagesx($map);
$mapH	= imagesy($map);
$markSX	= imagesx($mark);
$markSY	= imagesy($mark);

// Nummern anzeigen? (z.B. Fahrzeug-Slots)
$mitNummer	= (isset($_GET['nr']) && $_GET['nr'] == '1');
$textFarbe	= imagecolorallocate($map, 255, 255, 255);
$randFarbe	= imagecolorallocate($map, 0, 0, 0);

$i = 0;
foreach ($punkte as $punkt) {
	$i++;

	// GTA-SA-Welt: -3000 bis +3000 auf die Bildgroesse umrechnen.
	$x = ($punkt[0] + 6000 / 2) / 6000 * $mapW;
	$y = (-$punkt[1] + 6000 / 2) / 6000 * $mapH;

	// Ausserhalb der Karte (z.B. der alte Platzhalter 999999) nicht zeichnen.
	if ($x < 0 || $y < 0 || $x > $mapW || $y > $mapH) { continue; }

	imagecopy($map, $mark, (int)round($x - $markSX / 2), (int)round($y - $markSY / 2), 0, 0, $markSX, $markSY);

	if ($mitNummer && count($punkte) > 1) {
		$tx = (int)round($x + $markSX / 2) + 2;
		$ty = (int)round($y - $markSY / 2);
		// Kleiner Schatten, damit die Zahl auf jedem Untergrund lesbar ist.
		imagestring($map, 5, $tx + 1, $ty + 1, (string)$i, $randFarbe);
		imagestring($map, 5, $tx, $ty, (string)$i, $textFarbe);
	}
}

imagejpeg($map, null, 85);
imagedestroy($map);
imagedestroy($mark);
?>
