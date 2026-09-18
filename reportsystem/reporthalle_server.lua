--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Stand vorher am Dateiende und war damit an beiden Benutzungsstellen noch
-- nil: add-/removeEventHandler bekamen keine Funktion, der Waffenentzug in der
-- Reporthalle hat nie funktioniert.
local function dontHoldWeapon()
	setPedWeaponSlot(source,0)
end

addCommandHandler("report",function(player)
	if MtxGetElementData(player,"loggedin") == 1 then
		if getElementInterior(player) == 0 then
			if not isPedInVehicle(player)then
				if not isPedDead(player)then
					if MtxGetElementData(player,"inReportHalle") == false then
						local x,y,z=getElementPosition(player)
						MtxSetElementData(player,"old_position_x",x)
						MtxSetElementData(player,"old_position_y",y)
						MtxSetElementData(player,"old_position_z",z)
						if tonumber(MtxGetElementData(player,"adminlvl")) >= 1 then
							setElementPosition(player,129,-187.3,2001.4)
							MtxSetElementData(player,"inReportHalle",true)
							addEventHandler("onPlayerWeaponSwitch",player,dontHoldWeapon)
							outputLog("[REPORT]: "..getPlayerName(player).." hat die Reporthalle betreten!","Reportsystem")
							outputChatBox("Tippe /leavereport, um die Report Halle wieder zu verlassen",player,0,255,0)
						else
							setElementPosition(player,121,-187.3,2001.4)
							outputChatBox("Report Halle",player,255,150,0)
							outputChatBox("══════════════════════════════════════════════════",player,255,255,255)
							outputChatBox("► Die Hilfe Funktion ist nicht zum Spamen gedacht!",player,255,150,0)
							outputChatBox("══════════════════════════════════════════════════",player,255,255,255)
							MtxSetElementData ( player, "inReportHalle", true)
							addEventHandler("onPlayerWeaponSwitch",player,dontHoldWeapon)
							outputLog("[REPORT]: "..getPlayerName(player).." hat die Reporthalle betreten!","Reportsystem")
						end
					else infobox(player,"Du bist bereits in der Reporthalle!",5000,255,0,0)end
				else infobox(player,"Du bist tot!",5000,255,0,0)end
			else infobox(player,"Steige vorher aus deinem Fahrzeug aus!",5000,255,0,0)end
		else infobox(player,"Verlasse zu erst dein Interior!",5000,255,0,0)end
	end
end)

function reporthalle_hilfe_func(player)
	local x, y, z = getElementPosition(player)
		for _, p in pairs(getElementsByType("player")) do
			if MtxGetElementData(p, "loggedin")== 1 then
				if tonumber(MtxGetElementData(p, "adminlvl")) >= 1 then
				    infobox(player,"Alle Teammitglieder, welche online sind wurden benachrichtig!",5000,0,255,0)
					outputChatBox("[ADMIN]: "..getPlayerName(player).." benötigt Hilfe! Tippe /report, um zu ihm zu gelangen!", p, 0,100,150)	
					outputLog("[REPORT]: "..getPlayerName(player).." hat Hilfe angefordert!","Reportsystem")
				end
		  end
	end
end
addEvent ( "reporthalle:hilfe", true )
addEventHandler ( "reporthalle:hilfe", root, reporthalle_hilfe_func )

function reporthalle_leave_func(player)
    if MtxGetElementData ( player, "inReportHalle" ) == true then
	    local x, y, z =  MtxGetElementData(player, "old_position_x"), MtxGetElementData(player, "old_position_y"), MtxGetElementData(player, "old_position_z")
	    if x and y and z then
		    setElementPosition(player, x, y, z)
		    MtxSetElementData ( player, "inReportHalle", false)
			removeEventHandler("onPlayerWeaponSwitch",player,dontHoldWeapon)
			setPlayerHudComponentVisible ( player, "radar", true )
			
			outputLog("[REPORT]: "..getPlayerName(player).." hat die Reporthalle verlassen!","Reportsystem")
		end
	end
end
addEvent ( "reporthalle:leave", true )
-- Absender erzwingen, sonst liesse sich ein fremder Spieler teleportieren.
addEventHandler ( "reporthalle:leave", root, function ()
	if not isElement ( client ) then return end
	reporthalle_leave_func ( client )
end )
addCommandHandler("leavereport", reporthalle_leave_func)