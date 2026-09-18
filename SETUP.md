<!--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //-->


# ICE Reallife – Einrichtungsanleitung

Erst das **ICE-Script**, danach das optionale **Web-Panel**. Wähle den
Abschnitt für dein Betriebssystem.

---

# Windows

## ICE-Script installieren

1. [XAMPP](https://www.apachefriends.org/) installieren, im Control Panel
   **MySQL** starten.
2. In phpMyAdmin (`http://localhost/phpmyadmin`) eine leere Datenbank
   anlegen, z.B. `reallife`. Tabellen legt das Skript beim ersten Start
   selbst an.
3. `ICE`-Ordner nach `server\mods\deathmatch\resources\` kopieren.
4. In [mysql/mysql_start.lua](mysql/mysql_start.lua) (Zeile 8-11) die
   Zugangsdaten eintragen:
   ```lua
   gMysqlHost = "127.0.0.1"
   gMysqlUser = "root"
   gMysqlPass = ""
   gMysqlDatabase = "reallife"
   ```
5. In `mtaserver.conf` eintragen: `<resource src="ICE" startup="1" protected="0" />`
6. `MTA Server.exe` starten, mit MTA:SA verbinden – Registrierungsfenster
   öffnet sich automatisch.
7. Ersten Admin setzen: in phpMyAdmin Tabelle `userdata`, eigene Zeile (per
   `UID`, aus Tabelle `players`), Feld `Adminlevel` auf `6` setzen, neu
   einloggen.

## Web-Panel installieren

1. Inhalt von [WebPanel-PHP](WebPanel-PHP) nach `C:\xampp\htdocs` kopieren,
   Apache starten.
2. In `cfg.php` zwei Werte eintragen:
   - `ICE_RESOURCE_PFAD` – Pfad zum `ICE`-Ordner (MySQL-Zugangsdaten holt
     sich das Panel darüber automatisch).
   - `MTA_USER` / `MTA_PASS` – ein per `/register` angelegter Account,
     Mitglied der `"Admin"`-Gruppe in `acl.xml`.
3. Panel läuft jetzt unter `http://localhost/`.

---

# Linux

## ICE-Script installieren

1. MariaDB installieren und starten:
   ```bash
   sudo apt install mariadb-server
   sudo systemctl enable --now mariadb
   ```
2. Datenbank anlegen:
   ```sql
   CREATE DATABASE reallife CHARACTER SET utf8mb4;
   CREATE USER 'iceuser'@'localhost' IDENTIFIED BY 'DEIN_PASSWORT';
   GRANT ALL PRIVILEGES ON reallife.* TO 'iceuser'@'localhost';
   ```
3. `ICE`-Ordner nach `mods/deathmatch/resources/` kopieren, Rechte setzen:
   ```bash
   sudo chown -R <mta-benutzer>:<mta-benutzer> mods/deathmatch/resources/ICE
   ```
4. In `mysql/mysql_start.lua` die Zugangsdaten eintragen (wie oben unter
   Windows, nur mit `iceuser`/`DEIN_PASSWORT`).
5. In `mtaserver.conf` eintragen: `<resource src="ICE" startup="1" protected="0" />`
6. Server (neu)starten, mit MTA:SA verbinden – Registrierungsfenster öffnet
   sich automatisch.
7. Ersten Admin setzen: wie unter Windows, Tabelle `userdata` →
   `Adminlevel` auf `6`.

## Web-Panel installieren

1. PHP + Apache installieren, falls nicht vorhanden:
   ```bash
   sudo apt install apache2 php php-mysqli
   sudo systemctl enable --now apache2
   ```
2. Inhalt von [WebPanel-PHP](WebPanel-PHP) nach `/var/www/html/` kopieren:
   ```bash
   sudo cp -r WebPanel-PHP/* /var/www/html/
   sudo chown -R www-data:www-data /var/www/html
   ```
3. In `cfg.php` dieselben zwei Werte eintragen wie unter Windows
   (`ICE_RESOURCE_PFAD`, `MTA_USER`/`MTA_PASS`).
4. Panel läuft jetzt unter `http://<server-ip>/`.

---

# Stolperfallen

- **MySQL-Verbindung schlägt fehl**: Dienst läuft nicht, oder Zugangsdaten in
  `mysql_start.lua` falsch.
- **Ressource startet nicht**: Server-Konsole/Log nach der Fehlermeldung
  durchsuchen (meist Tippfehler in `meta.xml` oder fehlende Datei).
- **Panel und Server auf unterschiedlichen Rechnern**: zusätzlich in
  `mtaserver.conf` die IP des Webservers bei `http_dos_exclude` und
  `auth_serial_http_ip_exceptions` eintragen.
