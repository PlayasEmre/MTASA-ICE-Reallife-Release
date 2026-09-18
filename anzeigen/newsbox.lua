--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addEvent ( "deActivateCustomRadar", true )

function news1()
    for _, player in ipairs(getElementsByType("player")) do
        if MtxGetElementData(player, "loggedin") == 1 then
            outputChatBox(" ≡≡≡≡≡≡≡≡≡≡≡ "..Tables.servername.."-Reallife Info ≡≡≡≡≡≡≡≡≡≡≡", player, 72, 118, 255)
            outputChatBox("→ "..Tables.servername.." Reallife verfügt über ein Report System /report", player, 255, 255, 255)
            outputChatBox("→ Unsere TeamSpeak IP: "..Tables.tsip, player, 255, 255, 255)
            outputChatBox("→ Über /admins siehst du das Server Team", player, 255, 255, 255)
            outputChatBox("→ Hier könnt ihr alle Leader in der Fraktion sehen /checkLeader !", player, 255, 255, 255)
            outputChatBox("→ Hier könnt ihr euren Level sehen /showLevel !", player, 255, 255, 255)
            outputChatBox("→ Wir haben vor kurzem einen neuen Level Shop", player, 255, 255, 255)
            outputChatBox("→ Wir wünschen dir viel Spaß!", player, 255, 255, 255)
            
            if event and event.isHalloween then
                outputChatBox("→ Aktuell ist das Halloween-Event aktiv! Viel Spaß in der Kürbissuche!", player, 255, 255, 255)
                outputChatBox("→ Befehle! /Kürbis ", player, 255, 255, 255)
            end
            
            outputChatBox("≡≡≡≡≡≡≡≡≡≡≡ Information beendet ≡≡≡≡≡≡≡≡≡", player, 72, 118, 255)
        end
    end
end

-- Timer alle 5 Minute ausführen
setTimer(news1, 300000, 0)


function infobox ( player, text, time, r, g, b )
	if isElement ( player ) then
		triggerClientEvent ( player, "infobox_start", getRootElement(),text, time, r, g, b)
	end
end

local infoPickup = createPickup(-1979.5146484375,138.1455078125,27.6875,3,1239,500)

function infotext(thePlayer)
	outputChatBox("#47C1EEWillkommen #6DEC6Dauf #6DEC6DICE-Reallife #47C1EEUns gibt es schon seit 2019 #6DEC6DViel Spaß auf unserem Server",thePlayer,0,0,0,true)
end
addEventHandler("onPickupHit",infoPickup,infotext)
