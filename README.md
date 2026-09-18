<!--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //-->

# ICE Reallife – Installationsanleitung

Schritt für Schritt vom leeren Server bis zum laufenden Gamemode mit Web-Panel.

**Inhalt**

1. [Was du brauchst](#1-was-du-brauchst)
2. [ICE-Script installieren – Windows](#2-ice-script-installieren--windows)
3. [ICE-Script installieren – Linux](#3-ice-script-installieren--linux)
4. [Web-Panel installieren – Windows](#4-web-panel-installieren--windows)
5. [Web-Panel installieren – Linux](#5-web-panel-installieren--linux)
6. [Häufige Probleme](#6-häufige-probleme)

> Reihenfolge: Erst **Teil 2 oder 3** (Gamemode), danach optional **Teil 4 oder 5** (Web-Panel).

---

## 1. Was du brauchst

| Was | Wozu | Woher |
|---|---|---|
| MTA:SA **Server** 1.6.0-9.21765 oder neuer | Spielserver | [multitheftauto.com](https://multitheftauto.com/) |
| MySQL / MariaDB | Datenbank | Windows: XAMPP, Linux: `mariadb-server` |
| Resource **DGS** | Benutzeroberfläche (Pflicht) | [DGS von thisdp](https://github.com/thisdp/dgs) |
| Resource **newmodels_red** | Eigene Modelle (Pflicht) | MTA-Community-Resource (Autor: FernandoMTA) |
| Apache + PHP | Nur für das Web-Panel | Windows: XAMPP, Linux: `apache2 php` |

Der Ordner des Gamemodes muss **`ICE`** heißen (nicht `ICE-main` o. Ä.).
Wenn du ihn von GitHub als ZIP lädst, benenne ihn nach dem Entpacken um.

---

## 2. ICE-Script installieren – Windows

### Schritt 1 – Datenbank starten
1. [XAMPP](https://www.apachefriends.org/) installieren.
2. Im **XAMPP Control Panel** bei **MySQL** auf **Start** klicken.

### Schritt 2 – Leere Datenbank anlegen
1. Im Browser `http://localhost/phpmyadmin` öffnen.
2. Links auf **Neu** klicken, Name `reallife` eingeben, Zeichensatz `utf8mb4_general_ci`, **Anlegen**.

Tabellen legt ICE beim ersten Start selbst an – du musst nichts importieren.

### Schritt 3 – Resources kopieren
Diese drei Ordner nach `MTA San Andreas 1.6\server\mods\deathmatch\resources\` kopieren:

```
ICE
DGS
newmodels_red
```

### Schritt 4 – Datenbank-Zugang eintragen
Datei [mysql/mysql_start.lua](mysql/mysql_start.lua) öffnen, Zeilen 8–11 anpassen:

```lua
gMysqlHost = "127.0.0.1"
gMysqlUser = "root"
gMysqlPass = ""
gMysqlDatabase = "reallife"
```

> Auf einem öffentlichen Server ein eigenes Passwort für den Datenbank-Benutzer setzen und hier eintragen. Trage **niemals** echte Zugangsdaten in ein öffentliches GitHub-Repository ein.

### Schritt 5 – Resources beim Serverstart laden
In `server\mods\deathmatch\mtaserver.conf` diese Zeilen zu den anderen `<resource ... />`-Einträgen ergänzen:

```xml
<resource src="DGS" startup="1" protected="0" />
<resource src="newmodels_red" startup="1" protected="0" />
<resource src="ICE" startup="1" protected="0" />
```

### Schritt 6 – Server starten
1. `MTA Server.exe` starten.
2. Im Serverfenster darf **kein roter Fehler** zu `ICE` erscheinen. Beim ersten Start entstehen die Tabellen – das kann einen Moment dauern.

### Schritt 7 – Erster Login
1. Mit MTA:SA auf den Server verbinden (`localhost` bzw. `127.0.0.1`).
2. Das **Registrierungsfenster** öffnet sich automatisch – Account anlegen.

### Schritt 8 – Ersten Admin festlegen
1. In phpMyAdmin Datenbank `reallife` → Tabelle `players` öffnen, bei deinem Namen die **`UID`** ablesen.
2. Tabelle `userdata` öffnen, die Zeile mit dieser `UID` bearbeiten und **`Adminlevel`** auf `6` setzen.
3. Im Spiel neu einloggen.

✅ Der Gamemode läuft. Weiter mit dem [Web-Panel](#4-web-panel-installieren--windows), wenn du es brauchst.

---

## 3. ICE-Script installieren – Linux

### Schritt 1 – MariaDB installieren
```bash
sudo apt install mariadb-server
sudo systemctl enable --now mariadb
```

### Schritt 2 – Datenbank und Benutzer anlegen
`sudo mariadb` öffnen und ausführen:

```sql
CREATE DATABASE reallife CHARACTER SET utf8mb4;
CREATE USER 'iceuser'@'localhost' IDENTIFIED BY 'DEIN_PASSWORT';
GRANT ALL PRIVILEGES ON reallife.* TO 'iceuser'@'localhost';
FLUSH PRIVILEGES;
```

Tabellen legt ICE beim ersten Start selbst an.

### Schritt 3 – Resources kopieren
`ICE`, `DGS` und `newmodels_red` nach `mods/deathmatch/resources/` kopieren und die Rechte setzen:

```bash
sudo chown -R <mta-benutzer>:<mta-benutzer> mods/deathmatch/resources/ICE mods/deathmatch/resources/DGS mods/deathmatch/resources/newmodels_red
```

### Schritt 4 – Datenbank-Zugang eintragen
In `mysql/mysql_start.lua` (Zeilen 8–11) eintragen:

```lua
gMysqlHost = "127.0.0.1"
gMysqlUser = "iceuser"
gMysqlPass = "DEIN_PASSWORT"
gMysqlDatabase = "reallife"
```

### Schritt 5 – Resources beim Serverstart laden
In `mods/deathmatch/mtaserver.conf` ergänzen:

```xml
<resource src="DGS" startup="1" protected="0" />
<resource src="newmodels_red" startup="1" protected="0" />
<resource src="ICE" startup="1" protected="0" />
```

### Schritt 6 bis 8
Server (neu) starten, verbinden, registrieren und ersten Admin festlegen – **genau wie unter Windows, Schritt 6–8**
(in `userdata` das Feld `Adminlevel` auf `6` setzen).

---

## 4. Web-Panel installieren – Windows

Das Panel liegt im Ordner [WebPanel-PHP](WebPanel-PHP). Voraussetzung: Der Gamemode läuft (Teil 2).

### Schritt 1 – Dateien kopieren
Den **Inhalt** von `WebPanel-PHP` (nicht den Ordner selbst) nach `C:\xampp\htdocs\` kopieren.
Danach im XAMPP Control Panel bei **Apache** auf **Start** klicken.

### Schritt 2 – Panel-Account im Spiel anlegen
Das Panel steuert den Server über einen normalen Spiel-Account. Lege dafür einen eigenen an
(z. B. `PanelAdmin`), indem du dich damit ingame registrierst.

### Schritt 3 – Account in die Admin-Gruppe
In `server\mods\deathmatch\acl.xml` die bestehende Gruppe `Admin` suchen und **eine Zeile ergänzen** (vorhandene Einträge nicht löschen):

```xml
<group name="Admin">
    <!-- ... vorhandene Einträge ... -->
    <object name="user.PanelAdmin"></object>
</group>
```

Server einmal neu starten.

### Schritt 4 – `mtaserver.conf`: Web-Zugriff erlauben
In `mtaserver.conf` die IP des Webservers eintragen (bei gleichem Rechner `127.0.0.1`):

```xml
<http_dos_exclude>127.0.0.1</http_dos_exclude>
<auth_serial_http_ip_exceptions>127.0.0.1</auth_serial_http_ip_exceptions>
```

Läuft das Panel auf einem **anderen Rechner** als der Spielserver, dort die IP des Webservers eintragen.
Server neu starten.

### Schritt 5 – `cfg.php` anpassen
`C:\xampp\htdocs\cfg.php` öffnen und diese Werte setzen:

| Einstellung | Bedeutung |
|---|---|
| `ICE_RESOURCE_PFAD` | Voller Pfad zum `ICE`-Ordner. Daraus liest das Panel die MySQL-Zugangsdaten und Logdateien automatisch. |
| `MTA_USER` / `MTA_PASS` | Der Account aus Schritt 2. |
| `MTA_IP` / `MTA_PORT` / `MTA_HTTP_PORT` | Standard: `127.0.0.1` / `22003` / `22005` (wie in `mtaserver.conf`). |
| `SERVER_TIMEZONE` | Zeitzone deines Servers, Standard `Europe/Berlin`. |

Beispiel:
```php
define('ICE_RESOURCE_PFAD', 'C:\\MTA San Andreas 1.6\\server\\mods\\deathmatch\\resources\\ICE');
define('MTA_USER', 'PanelAdmin');
define('MTA_PASS', 'DEIN_GEHEIMES_PASSWORT');
```

### Schritt 6 – Testen
1. `http://localhost/` im Browser öffnen.
2. Mit deinem **Spiel-Account** (Name und Passwort aus dem Spiel) einloggen.
3. Etwas läuft nicht? Als Admin `http://localhost/?page=diagnose` öffnen – die Seite **System-Check** zeigt, ob Panel, Datenbank und Spielserver zusammenpassen.

---

## 5. Web-Panel installieren – Linux

### Schritt 1 – Apache und PHP installieren
```bash
sudo apt install apache2 php php-mysqli
sudo systemctl enable --now apache2
```

### Schritt 2 – Dateien kopieren
Den **Inhalt** von `WebPanel-PHP` nach `/var/www/html/` kopieren:

```bash
sudo cp -r WebPanel-PHP/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html
```

### Schritt 3 bis 6
Panel-Account anlegen, in die ACL-Gruppe `Admin` eintragen, `mtaserver.conf` anpassen, `cfg.php` ausfüllen und testen – **genau wie unter Windows, Schritt 2–6**.
Das Panel erreichst du danach unter `http://<server-ip>/`.

> Auf einem öffentlichen Server das Panel zusätzlich mit HTTPS absichern (z. B. Let's Encrypt), da sich Spieler dort mit ihrem Passwort anmelden.

---

## 6. Häufige Probleme

| Problem | Lösung |
|---|---|
| **MySQL-Verbindung schlägt fehl** | Datenbank-Dienst läuft nicht, oder Zugangsdaten in `mysql/mysql_start.lua` stimmen nicht. |
| **`Unknown column ...` in der Konsole** | Datenbank stammt von einer älteren Version. ICE ergänzt fehlende Spalten beim Start selbst. Nur für Neuinstallationen: Datenbank leeren und neu starten lassen. |
| **ICE startet nicht** | In der Server-Konsole nach dem Fehler suchen. Häufig: `DGS` oder `newmodels_red` fehlt oder startet nicht, Tippfehler in `meta.xml`, oder der Ordner heißt nicht `ICE`. |
| **Kein Registrierungsfenster** | `ICE` und `DGS` laufen? Im Server-Fenster `start ICE` bzw. `start DGS` eingeben und auf Fehler achten. |
| **Panel zeigt Hinweis statt Serverdaten** | `MTA_USER`/`MTA_PASS` sind noch Beispielwerte, oder der Account ist nicht in der ACL-Gruppe `Admin`. |
| **Panel: HTTP-Anmeldung wird abgelehnt** | Die IP des Webservers fehlt bei `http_dos_exclude` und `auth_serial_http_ip_exceptions` in `mtaserver.conf`. |
| **Zeiten (z. B. Bans) im Panel falsch** | `SERVER_TIMEZONE` in `cfg.php` an die Zeitzone deines Spielservers anpassen. |
