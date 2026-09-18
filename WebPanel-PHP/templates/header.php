<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta charset="utf-8" />
		
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		
		<title><?php
			$page = ((isset($_GET['page']) && !empty($_GET['page'])) ? $_GET['page'] : 'index');
			$title = WEBSITE_TITLE." - ".((!empty($pagetitles[$page])) ? $pagetitles[$page] : '404 Not Found');
			echo $title;
		?></title>
		
		
		<!-- BOOTSTRAP STYLES-->
		<link href="assets/css/bootstrap.css" rel="stylesheet" />
		<!-- FONTAWESOME STYLES-->
		<link href="assets/css/font-awesome.css" rel="stylesheet" />
		<!-- CUSTOM STYLES-->
		<?php
			/*
				?v=<Aenderungszeit> haengt an die CSS an, wann sie zuletzt
				geaendert wurde. Dadurch holt der Browser eine neue Version
				automatisch - ohne Strg+F5 beim Besucher.
			*/
			$cssDatei = dirname(dirname(__FILE__)).DIRECTORY_SEPARATOR.'assets'.DIRECTORY_SEPARATOR.'css'.DIRECTORY_SEPARATOR.'custom.css';
			$cssVer   = ((file_exists($cssDatei)) ? filemtime($cssDatei) : '1');
		?>
		<link href="assets/css/custom.css?v=<?=$cssVer?>" rel="stylesheet" />
		<!-- GOOGLE FONTS-->
		<link rel="preconnect" href="https://fonts.googleapis.com" />
		<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
		<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet" />
		
		<!--
			Gewaehlte Ansicht setzen, BEVOR die Seite gezeichnet wird.
			Stuende das weiter unten, saehe der Besucher beim Laden kurz
			die helle Seite aufblitzen, bevor sie dunkel wird.
		-->
		<script>
			(function () {
				try {
					var wahl = localStorage.getItem('ice-theme');
					if (wahl === 'hell' || wahl === 'dunkel') {
						document.documentElement.setAttribute('data-theme', wahl);
					}
				} catch (e) {
					/* Privater Modus ohne Speicher: dann gilt die Systemeinstellung. */
				}
			})();
		</script>

		<!-- JQUERY SCRIPTS -->
		<script src="assets/js/jquery-1.10.2.js"></script>
	</head>
	<body class="page-<?=htmlspecialchars($page)?><?=(($CP->Loggedin) ? ' ist-eingeloggt' : ' nicht-eingeloggt')?>">
		<div id="wrapper">
			<nav class="navbar navbar-default navbar-cls-top " role="navigation" style="margin-bottom: 0">
				<div class="navbar-header">
					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".sidebar-collapse">
						<span class="sr-only">Toggle navigation</span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
					</button>
					<a class="navbar-brand" href="?page=home"><?=SERVER_NAME?></a> 
				</div>
				<div style="color: white; padding: 15px 50px 5px 50px; float: right; font-size: 16px;">
					<button type="button" class="theme-schalter" id="theme-schalter" title="Zwischen heller und dunkler Ansicht wechseln">
						<i class="fa fa-adjust"></i><span id="theme-schalter-text">Ansicht</span>
					</button>
					<?php if ($CP->Loggedin) { ?>
					<a href="?page=logout" class="btn btn-danger square-btn-adjust">Logout</a>
					<?php } ?>
				</div>

				<script>
					(function () {
						var knopf = document.getElementById('theme-schalter');
						var text  = document.getElementById('theme-schalter-text');
						if (!knopf) { return; }

						// Ohne eigene Wahl richtet sich die Seite nach dem System.
						// Der Knopf zeigt dann an, wohin ein Klick fuehren wuerde.
						function aktuell() {
							var gesetzt = document.documentElement.getAttribute('data-theme');
							if (gesetzt === 'hell' || gesetzt === 'dunkel') { return gesetzt; }
							return (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) ? 'dunkel' : 'hell';
						}

						function beschriften() {
							text.textContent = (aktuell() === 'dunkel') ? 'Hell' : 'Dunkel';
						}

						knopf.addEventListener('click', function () {
							var neu = (aktuell() === 'dunkel') ? 'hell' : 'dunkel';
							document.documentElement.setAttribute('data-theme', neu);
							try { localStorage.setItem('ice-theme', neu); } catch (e) {}
							beschriften();
						});

						beschriften();
					})();
				</script>
			</nav>   
			<!-- /. NAV TOP  -->
			
			<nav class="navbar-default navbar-side" role="navigation">
				<div class="sidebar-collapse">
					<ul class="nav" id="main-menu">
						<?php if ($CP->Loggedin) { ?>
						<li class="text-center">
							<div class="alert alert-info">
								<b>Schon gewusst?</b><br>
								<?php
									/*
										(int) ist wichtig: der Cookie kommt vom Besucher.
										Stand dort Text, warf PHP 8 bei "abc" + 1 einen
										Fatal Error - und zwar auf JEDER Seite.
									*/
									if (isset($_COOKIE['lastInfo']) && !empty($_COOKIE['lastInfo'])) {
										$info = (int)$_COOKIE['lastInfo'] + 1;
									} else {
										$info = 1;
									}
									if ($info < 1) { $info = 1; }
									if ($info > 6) {
										$info = 1;
									}
									cpSetzeCookie("lastInfo", $info, 99999);
									
									switch ($info) {
										case 1:
											$whereFIX = ((UID_BASED) ? 'UID' : 'id');
											$neusterUser = "-";
											$sql = $mySQLcon->query("SELECT Name FROM players ORDER BY ".$whereFIX." DESC LIMIT 1");
											while ($sql && $row = $sql->fetch_assoc()) {
												$neusterUser = $row['Name'];
											}
											echo "Das wir insgesamt <b>".number_format(cpCountRows($mySQLcon, "SELECT UID FROM players"),0,"",".")."</b> Registrierte Spieler haben, von denen <b>".number_format(cpCountRows($mySQLcon, "SELECT UID FROM ban"),0,"",".")."</b> gebannt sind?<br>Der neuste Spieler heißt <b>".htmlspecialchars($neusterUser)."</b>";
											break;
										case 2:
											echo "Das alle Spieler insgesamt <b>".number_format(cpCountRows($mySQLcon, "SELECT id FROM vehicles"),0,"",".")."</b> Fahrzeuge besitzen?";
											break;
										case 3:
											$hc = cpCountRows($mySQLcon, "SELECT ID FROM houses");
											$hfrei = cpCountRows($mySQLcon, "SELECT ID FROM houses WHERE ".((UID_BASED) ? "UID='0'" : "Besitzer='none'"));
											echo "Das es <b>".number_format($hc,0,"",".")."</b> Häuser gibt, von denen <b>".number_format(($hc-$hfrei),0,"",".")."</b> verkauft sind?";
											break;
										case 4:
											echo "Momentan wachsen <b>".number_format(cpCountRows($mySQLcon, "SELECT id FROM weed"),0,"",".")."</b> Cannabispflanzen.";
											break;
										case 5:
											/*
												Zaehlung ueber alle Fraktionen aus cfg.php
												(inkl. 14 Anonymus und 15 Fahrschule).
												"art" steht dort bei jeder Fraktion:
												staat / illegal / neutral.
												Eine Abfrage statt einer pro Fraktion.
											*/
											$staat = 0; $illegal = 0; $neutral = 0;

											$res = $mySQLcon->query("SELECT Fraktion, COUNT(*) AS Anzahl FROM userdata WHERE Fraktion > 0 GROUP BY Fraktion");
											while ($res && $r = $res->fetch_assoc()) {
												$fID	= (int)$r['Fraktion'];
												$anz	= (int)$r['Anzahl'];
												$art	= ((isset($factions[$fID]['art'])) ? $factions[$fID]['art'] : 'neutral');

												if ($art == 'staat')		{ $staat   += $anz; }
												else if ($art == 'illegal')	{ $illegal += $anz; }
												else						{ $neutral += $anz; }
											}
											$frak = $staat + $illegal + $neutral;

											echo "Das <b>".$frak."</b> Spieler in einer Fraktion sind? Davon <b>".$staat."</b> bei den Staatsfraktionen, <b>".$illegal."</b> bei den illegalen und <b>".$neutral."</b> in einer neutralen Fraktion.";
											break;
										case 6:
											$umlaufgeld = 0;

											$sql = @$mySQLcon->query("SELECT Geld, Bankgeld FROM userdata");
											while ($sql && $row = $sql->fetch_assoc()) {
												$umlaufgeld = $umlaufgeld + $row['Geld'];
												$umlaufgeld = $umlaufgeld + $row['Bankgeld'];
											}

											$sql = @$mySQLcon->query("SELECT Kasse FROM biz");
											while ($sql && $row = $sql->fetch_assoc()) {
												$umlaufgeld = $umlaufgeld + $row['Kasse'];
											}

											$sql = @$mySQLcon->query("SELECT Kasse FROM houses");
											while ($sql && $row = $sql->fetch_assoc()) {
												$umlaufgeld = $umlaufgeld + $row['Kasse'];
											}

											$sql = @$mySQLcon->query("SELECT DepotGeld FROM fraktionen");
											while ($sql && $row = $sql->fetch_assoc()) {
												$umlaufgeld = $umlaufgeld + $row['DepotGeld'];
											}

											echo "Das <b>".number_format($umlaufgeld,0,"",".")." $</b> im Umlauf sind?";
											break;
									}	
								?>
							</div>
						</li>
						<?php
						/*
							Menue aus einer Liste aufbauen - dadurch sind alle
							Eintraege gleich formatiert und neue Seiten muessen nur
							hier eingetragen werden.

							"trenner" => Ueberschrift ueber der folgenden Gruppe
							"farbe"   => Farbe der Gruppe (siehe custom.css, .men-*)

							Jede Gruppe hat eine eigene Farbe. Sie faerbt das Icon,
							den aktiven Menuepunkt und - ueber die Klasse am <body> -
							auch die Akzente auf der Seite selbst.
						*/
						$menue = array(
							array("trenner" => "Mein Charakter", "farbe" => "blau"),
							array("seite" => "home",		"icon" => "fa-info-circle",	"text" => "Übersicht"),
							array("seite" => "vehicles",	"icon" => "fa-truck",		"text" => "Fahrzeuge"),
							array("seite" => "house",		"icon" => "fa-home",		"text" => "Haus"),
							array("seite" => "inventory",	"icon" => "fa-suitcase",	"text" => "Inventar &amp; Waffen"),
							array("seite" => "faction",		"icon" => "fa-flag",		"text" => "Fraktion &amp; Gang"),
							array("seite" => "statistik",	"icon" => "fa-line-chart",	"text" => "Meine Statistik"),

							array("trenner" => "Server", "farbe" => "gruen"),
							array("seite" => "kaufen",		"icon" => "fa-shopping-cart", "text" => "Autohäuser &amp; Geschäfte"),
							array("seite" => "rang",		"icon" => "fa-bar-chart-o",	"text" => "Ranglisten"),

							array("trenner" => "Account", "farbe" => "lila"),
						);

						if (USE_COINS) {
							$menue[] = array("seite" => "coins", "icon" => "fa-heart", "text" => "Coins");
						}
						$menue[] = array("seite" => "settings", "icon" => "fa-cogs", "text" => "Einstellungen");

						$aktuelleSeite = ((isset($_GET['page'])) ? $_GET['page'] : '');

						$gruppenFarbe = 'blau';

						foreach ($menue as $eintrag) {
							if (isset($eintrag['trenner'])) {
								$gruppenFarbe = ((isset($eintrag['farbe'])) ? $eintrag['farbe'] : 'blau');
								echo '<li class="menue-trenner men-'.$gruppenFarbe.'">'.$eintrag['trenner'].'</li>';
								continue;
							}

							$aktiv = (($aktuelleSeite == $eintrag['seite']) ? ' class="active-menu"' : '');
							echo '<li class="men-'.$gruppenFarbe.'"><a'.$aktiv.' href="?page='.$eintrag['seite'].'"><i class="fa '.$eintrag['icon'].' fa-3x"></i> '.$eintrag['text'].'</a></li>';
						}
						?>

						<?php if ($CP->Admin) { ?>
						<li class="menue-trenner men-rot">Administration</li>
						<li class="men-rot">
							<a class="<?=((strpos($aktuelleSeite, 'admin-') !== false || $aktuelleSeite == 'diagnose') ? 'active-menu' : '')?>" href="#"><i class="fa fa-shield fa-3x"></i> Admin<span class="fa arrow"></span></a>
							<ul class="nav nav-second-level">
								<li><a href="?page=admin-players">Übersicht &amp; Spieler</a></li>
								<li><a href="?page=admin-checkplayer">Spieler überprüfen</a></li>
								<li><a href="?page=admin-userdata">Spielerdaten bearbeiten</a></li>
								<li><a href="?page=admin-bans">Bans verwalten</a></li>
							<li><a href="?page=diagnose">System-Check</a></li>
								<li>
									<a href="?page=admin-logs">Logs<span class="fa arrow"></span></a>
									<ul class="nav nav-third-level">
										<?php
										/*
											Logs liegen bei ICE als Dateien im Spielserver und
											werden ueber die Lua-Funktion getLogContent gelesen.
											Die Auswahl kommt aus $LogNames (cfg.php).
										*/
										foreach ($LogNames as $i => $name) {
											echo '<li><a href="?page=admin-logs&log='.urlencode($i).'">'.htmlspecialchars($name).'</a></li>';
										}
										?>
									</ul>
								</li>
							</ul>
						</li>
						<?php } ?>
						<?php } else { ?>
						<li class="men-blau">
							<a class="<?=((isset($_GET['page']) && $_GET['page'] == 'login') ? 'active-menu' : '')?>" href="?page=login"><i class="fa fa-edit fa-3x"></i> Login</a>
						</li>
						<?php } ?>
					</ul>
				</div>
			</nav>  
			<!-- /. NAV SIDE  -->
			
			<div id="page-wrapper" >
				<div id="page-inner">
					<div class="row">
						<div class="col-md-12">
							<h2><?=((!empty($pagetitles[$page])) ? $pagetitles[$page] : '404 Not Found')?></h2>   
						</div>
					</div>
					<hr />