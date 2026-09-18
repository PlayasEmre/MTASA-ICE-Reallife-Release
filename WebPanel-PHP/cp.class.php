<?php
/*************************************************
***** Copyright (c) FirstOne Media 2014-2018 *****
**************************************************/
/*
	Angepasst fuer ICE-Reallife:
	- Login prueft sha512(Passwort) (siehe register_login/register_login_server.lua)
	- Coins liegen in userdata.Coins (ICE hat keine "coins"-Tabelle)
	- Premium liegt in userdata.PremiumData (DATETIME, NULL = kein Premium) / userdata.PremiumPaket
	- Kills/Tode liegen in der Tabelle "statistics"
	- Alle Tabellen werden ueber die UID verknuepft
*/

class CP {
	var $mySQLcon		= false;

	var $Loggedin		= null;
	var $Name			= null;
	var $UID			= null;
	var $Admin			= null;
	var $Adminlvl		= null;
	var $Banned			= null;
	var $UserData 		= null;
	var $inGameLoggedin = null;
	var $InGameQuelle	= "";		// woher der Online-Status kommt (fuer die Anzeige)
	var $Coins 			= null;
	var $LeftVIPDays 	= null;


	public function __construct($con) {
		if ($con->connect_errno) { return false; }
		$this->mySQLcon = $con;

		// Funktionen aufrufen, Variablen in Klasse speichern.
		$this->Loggedin = $this->isLoggedin();
		if ($this->Loggedin == true) {
			$this->Banned			= $this->isBanned();
			$this->UserData			= $this->getUserData();
			$this->inGameLoggedin	= $this->isInGameLoggedin();
			// Falls ein Spieler in "players" steht, aber (noch) nicht in "userdata".
			$this->Adminlvl			= ((isset($this->UserData['userdata']['Adminlevel'])) ? (int)$this->UserData['userdata']['Adminlevel'] : 0);
			$this->Admin			= (($this->Adminlvl > 0) ? true : false);
			$this->Coins 			= (int)$this->UserData['userdata']['Coins'];
			$this->LeftVIPDays		= $this->checkPlayerVIP();
		}

	}

	public function __destruct() {}

	// Gibt die WHERE-Bedingung fuer den eingeloggten Spieler zurueck.
	public function where() {
		if (UID_BASED) {
			return "UID='".$this->mySQLcon->escape_string($this->UID)."'";
		}
		return "Name='".$this->mySQLcon->escape_string($this->Name)."'";
	}

	// Private functions
	private function isLoggedin() {
		if (isset($_COOKIE['cpuser']) && !empty($_COOKIE['cpuser'])) {
			if (isset($_COOKIE['cpauth']) && !empty($_COOKIE['cpauth'])) {

				$whereFIX = "id='".$this->mySQLcon->escape_string($_COOKIE['cpuser'])."'";
				if (UID_BASED) {
					// UID ist eine Zahl - Cast verhindert, dass ein Text-Cookie auf UID 0 passt.
					$whereFIX = "UID='".(int)$_COOKIE['cpuser']."'";
				}
				$sql = $this->mySQLcon->query("SELECT * FROM players WHERE ".$whereFIX);
				if (!$sql) { return false; }
				while ($row = $sql->fetch_assoc()) {
					$id			= ((isset($row['id']) && !empty($row['id'])) ? $row['id'] : $row['UID']);
					$name		= $row['Name'];
					$pw			= $row['Passwort'];
					$salt		= ((isset($row['Salt']) && !empty($row['Salt'])) ? $row['Salt'] : '');

					$this->Name = $name;
					$this->UID	= $id;

					$cookie		= hash('sha256', $pw.$name.$salt.cpIpPrefix());

					if (hash_equals($cookie, $_COOKIE['cpauth'])) {
						return true;
					}
				}
			}
		}
		return false;
	}

	private function isBanned() {
		$whereFIX = "Name='".$this->mySQLcon->escape_string($this->Name)."'";
		if (UID_BASED) {
			$whereFIX = "UID='".$this->mySQLcon->escape_string($this->UID)."'";
		}
		$sql = $this->mySQLcon->query("SELECT * FROM ban WHERE ".$whereFIX);
		if ($sql && $sql->num_rows > 0) {
			/*
				Abgelaufene Timebans ignorieren.
				ICE loescht sie erst beim naechsten Login-Versuch ingame
				(register_login_server.lua Z. 30-49). Ohne diese Pruefung waere
				ein Spieler nach Ablauf der Zeit im Panel weiter "gebannt".
			*/
			$jetzt = getSecTime(0);
			while ($row = $sql->fetch_assoc()) {
				$sTime = (int)$row['STime'];
				if ($sTime != 0 && ($sTime - $jetzt) <= 0) { continue; }
				return $row;
			}
		}
		return false;
	}

	private function getUserData() {
		$arr = array();

		$whereFIX = "Name='".$this->mySQLcon->escape_string($this->Name)."'";
		if (UID_BASED) {
			$whereFIX = "UID='".$this->mySQLcon->escape_string($this->UID)."'";
		}

		// Tabellen die in der ICE-DB alle ueber die UID laufen.
		foreach (array("userdata", "achievments", "bonustable", "players", "inventar", "statistics", "skills") as $table) {
			$arr[$table] = array();
			if (!cpTableExists($this->mySQLcon, $table)) { continue; }
			$sql = $this->mySQLcon->query("SELECT * FROM ".$table." WHERE ".$whereFIX);
			if ($sql && $sql->num_rows > 0) {
				$arr[$table] = $sql->fetch_assoc() ?: array();
			} else {
				/*
					Fehlt der Datensatz (z.B. Account aus einer aelteren Script-Version),
					werden alle Spalten mit "" vorbelegt. Sonst wuerde jede Seite
					dutzende "Undefined array key"-Warnungen ausgeben.
				*/
				$cols = $this->mySQLcon->query("SHOW COLUMNS FROM `".str_replace('`', '', $table)."`");
				while ($cols && $col = $cols->fetch_assoc()) {
					$arr[$table][$col['Field']] = "";
				}
			}
		}

		/*
			Coins stehen bei ICE in userdata.Coins - eine eigene "coins"-Tabelle
			gibt es nicht (die frueheren Felder txn/psc gehoerten zu PayPal und
			Paysafecard, beides ist entfernt).
		*/
		$arr["coins"] = array(
			"Name"	=> $this->Name,
			"Coins"	=> ((isset($arr["userdata"]['Coins'])) ? $arr["userdata"]['Coins'] : 0)
		);

		return $arr;
	}

	/*
		Ist der Spieler gerade im Spiel?

		Zwei Wege, weil einer allein nicht zuverlaessig ist:

		1. Tabelle "loggedin" - die pflegt der Spielserver selbst.
		   Schnell, aber sie bleibt leer, solange die korrigierte Datei
		   register_login/loggedin_mysql.lua nicht auf dem Server liegt
		   (und der Server nicht neu gestartet wurde).

		2. Direkte Frage an den MTA-Server (ASE-Port, siehe cpMtaAseAbfrage
		   in usefull.php). Braucht kein Passwort und keinen Neustart.

		Sagt einer von beiden "online", gilt der Spieler als online.
	*/
	private function isInGameLoggedin() {

		// 1) Datenbank
		$whereFIX = "Name='".$this->mySQLcon->escape_string($this->Name)."'";
		if (UID_BASED) {
			$whereFIX = "UID='".$this->mySQLcon->escape_string($this->UID)."'";
		}
		$sql = $this->mySQLcon->query("SELECT Loggedin FROM loggedin WHERE ".$whereFIX);
		while ($sql && $row = $sql->fetch_assoc()) {
			if ($row['Loggedin'] == "1") {
				$this->InGameQuelle = "Tabelle loggedin";
				return true;
			}
		}

		// 2) Direkt beim Spielserver nachfragen
		$ase = cpIstImSpiel($this->Name);
		if ($ase === true) {
			$this->InGameQuelle = "Abfrage beim Spielserver";
			return true;
		}
		if ($ase === false) {
			$this->InGameQuelle = "Abfrage beim Spielserver";
			return false;
		}

		// null = Server nicht erreichbar
		$this->InGameQuelle = "unbekannt (Spielserver nicht erreichbar)";
		return false;
	}

	/*
		ICE speichert das Premium-Ende als DATETIME in userdata.PremiumData.
		NULL = kein Premium. Rueckgabe: verbleibende Tage.
	*/
	private function checkPlayerVIP() {
		/*
			userdata.PremiumData ist eine DATETIME-Spalte ("2026-09-12 14:30:00"),
			NULL bedeutet "kein Premium". Frueher stand dort ein Unix-Zeitstempel -
			ein (int)-Cast wuerde auf dem Datumsstring 2026 ergeben, deshalb hier
			strtotime().
		*/
		$roh = ((isset($this->UserData['userdata']['PremiumData'])) ? $this->UserData['userdata']['PremiumData'] : null);
		if ($roh === null || $roh === '' || $roh === '0000-00-00 00:00:00') { return 0; }

		$until = strtotime($roh);
		if ($until === false || $until <= 0) { return 0; }

		$days = ceil(($until - time()) / 86400);
		return (($days > 0) ? $days : 0);
	}

	// Public functions
	/*
		Coins abbuchen.

		Wichtig: Die Datenbank rechnet selbst (Coins = Coins - x) und nur,
		wenn auch genug da sind (WHERE Coins >= x).

		Vorher wurde der neue Stand in PHP berechnet und fest eingetragen.
		Klickte jemand zweimal schnell hintereinander (zwei Anfragen
		gleichzeitig), lasen beide denselben alten Stand - man konnte also
		zwei Sachen kaufen und nur einmal bezahlen.

		Rueckgabe: true = abgebucht, false = zu wenig Coins
	*/
	public function takePlayerCoins($coins, $reason) {
		$coins = (int)$coins;
		if ($coins <= 0) { return false; }

		$this->mySQLcon->query("UPDATE userdata SET Coins = Coins - ".$coins."
			WHERE ".$this->where()." AND Coins >= ".$coins);

		if ($this->mySQLcon->affected_rows < 1) {
			cpWriteLog("coins.log", "(FEHLGESCHLAGEN: zu wenig Coins fuer ".$coins.") ".$reason);
			return false;
		}

		// Stand in der Klasse mitziehen, damit die Seite den neuen Wert zeigt.
		$this->Coins = (int)$this->Coins - $coins;
		if ($this->Coins < 0) { $this->Coins = 0; }

		cpWriteLog("coins.log", "(TAKE ".$coins." Coins) ".$reason);
		return true;
	}

	/*
		Schreibt einem Spieler (per Name) Coins gut.
		Vergleich mit "=" statt "LIKE": bei LIKE koennte man mit Platzhaltern
		(% oder _) einen fremden Account treffen. Der Vergleich ist trotzdem
		nicht Gross-/Kleinschreibungs-abhaengig (latin1_swedish_ci).
	*/
	public function givePlayerCoins($name, $coins, $reason) {
		$coins = (int)$coins;
		if ($coins <= 0) { return false; }

		$sql = $this->mySQLcon->query("SELECT UID, Name FROM userdata WHERE Name='".$this->mySQLcon->escape_string($name)."'");
		if (!$sql || $sql->num_rows == 0) { return false; }
		$row = $sql->fetch_assoc();

		$this->mySQLcon->query("UPDATE userdata SET Coins=Coins+".$coins." WHERE UID='".$this->mySQLcon->escape_string($row['UID'])."'");
		cpWriteLog("coins.log", "(GIVE ".$coins." Coins) ".$reason);

		if (strtolower($row['Name']) == strtolower($this->Name)) {
			$this->Coins = (int)$this->Coins + $coins;
		}
		return true;
	}

	/*
		Schreibt einen neuen Namen in alle Tabellen, in denen ein
		SPIELERNAME steht. In der ICE-DB haengt sonst alles an der UID -
		nur diese Tabellen arbeiten noch mit dem Namen selbst.

		Achtung: NICHT aufnehmen, auch wenn sie eine Spalte "Name" haben —
		das sind keine Spielernamen:
		biz (Geschaeftsname), fraktionen, gangs, gang_basic,
		carhouses_icons, cars_ai, clothes ist dagegen namensbasiert.
	*/
	private function renameInAllTables($oldname, $newname) {
		$oldname = $this->mySQLcon->escape_string($oldname);
		$newname = $this->mySQLcon->escape_string($newname);

		$nameColumns = array(
			"players"		=> array("Name"),
			"userdata"		=> array("Name"),
			"racing"		=> array("Name"),
			"pm"			=> array("Sender"),
			"prestige"		=> array("Besitzer"),
			"object"		=> array("placer"),
			"whitelist"		=> array("Name"),
			"promotion"		=> array("Username"),
			"clothes"		=> array("Name"),
			"marry"			=> array("pl1", "pl2")
		);

		foreach ($nameColumns as $table => $columns) {
			if (!cpTableExists($this->mySQLcon, $table)) { continue; }
			foreach ($columns as $column) {
				if (!cpColumnExists($this->mySQLcon, $table, $column)) { continue; }
				$this->mySQLcon->query("UPDATE `".$table."` SET `".$column."`='$newname' WHERE `".$column."`='$oldname'");
			}
		}
	}

	/*
		Namensaenderung durch den Spieler selbst (Coins-Bereich).
	*/
	public function changePlayerName($oldname, $newname) {
		if ($this->Loggedin) {
			if ($oldname == $this->Name) {
				if ($this->inGameLoggedin == true) {
					return false;
				}
			} else {
				$sql = $this->mySQLcon->query("SELECT * FROM loggedin WHERE ".$this->where());
				if ($sql) {
					while ($row = $sql->fetch_assoc()) {
						if ($row['Loggedin'] == "1") {
							return false;
						}
					}
				}
			}

			$this->renameInAllTables($oldname, $newname);
			$this->Name = $newname;
			return true;
		}
		return false;
	}

	/*
		Namensaenderung durch einen Admin fuer einen BELIEBIGEN Spieler.

		Anders als changePlayerName(): dort wuerde der Online-Check bei
		einem fremden Ziel-Namen den Admin selbst statt den Zielspieler
		pruefen (er haengt an $this->where()) - das waere hier falsch.
		Ob der Zielspieler ingame offline ist, muss der Aufrufer VORHER
		selbst mit cpSpielerIstOnline() pruefen.
	*/
	public function adminRenamePlayer($oldname, $newname) {
		$this->renameInAllTables($oldname, $newname);
		return true;
	}


	public function getNameFromUID($uid) {
		static $cache = array();
		if (isset($cache[$uid])) { return $cache[$uid]; }

		$sql = $this->mySQLcon->query("SELECT Name FROM players WHERE UID='".$this->mySQLcon->escape_string($uid)."'");
		$name = "-";
		if ($sql && $sql->num_rows > 0) {
			$row = $sql->fetch_assoc();
			$name = $row['Name'];
		}
		$cache[$uid] = $name;
		return $name;
	}

}
?>
