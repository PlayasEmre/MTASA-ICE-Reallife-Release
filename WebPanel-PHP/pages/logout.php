<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/

/*
	Abmelden: beide Cookies loeschen.
	cpSetzeCookie mit Dauer 0 setzt ein Datum in der Vergangenheit und
	benutzt dieselben Optionen (Pfad, HttpOnly, SameSite) wie beim Setzen -
	sonst wuerde der Browser den alten Cookie behalten.
*/
cpSetzeCookie("cpuser", "", 0);
cpSetzeCookie("cpauth", "", 0);

// Reste einer aelteren Panel-Version (Pfad "/") ebenfalls entfernen
cpAlteCookiesAufraeumen();

header("Location: ?page=login");
exit;
?>