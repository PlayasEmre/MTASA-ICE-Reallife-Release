--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


function lookoutFound_func ( id )
	local player = client
	local pname = getPlayerName ( player )
	local result =  dbQueryCoro ( "SELECT ?? FROM ?? WHERE ?? = ?", "LookoutsA", "achievments", "UID", playerUID[pname] )
	if result and result[1] then
		local dataString = result[1]["LookoutsA"]
		if tonumber ( gettok ( dataString, id, string.byte ( '|' ) ) ) == 0 then
			local newstring = ""
			for i = 1, 10 do
				if i == id then
					newstring = newstring.."1".."|"
				else
					newstring = newstring..gettok ( dataString, i, string.byte ( '|' ) ).."|"
				end
			end
			local count = 0
			for i = 1, 10 do
				if tonumber ( gettok ( newstring, i, string.byte ( '|' ) ) ) == 1 then
					count = count + 1
				end
			end
			MtxSetElementData ( player, "bonuspoints", MtxGetElementData ( player, "bonuspoints" ) + 10 )
			MtxSetElementData ( player, "viewpoints", count )
			triggerClientEvent ( player, "showAchievmentBox", player, " Aussichts-\n punkt\n gefunden!", 10, 10000 )
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "LookoutsA", newstring, "UID", playerUID[pname] )
		end
	end
end
addEvent ( "lookoutFound", true )
addEventHandler ( "lookoutFound", getRootElement(), function ( id )
	runAsync ( function ()
		lookoutFound_func ( id )
	end )
end )


function casinoAchievCheck ( player, amount )
	local pname = getPlayerName ( player )
	if amount >= 100000 then
		if MtxGetElementData ( player, "chickendinner_achiev" ) == 0 then
			MtxSetElementData ( player, "bonuspoints", MtxGetElementData ( player, "bonuspoints" ) + 15 )
			triggerClientEvent ( player, "showAchievmentBox", player, " Chicken\n Dinner!", 15, 10000 )
			MtxSetElementData ( player, "chickendinner_achiev", 1 )	
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "ChickenDinner", 1, "UID", playerUID[pname] )
		end
	elseif amount <= -100000 then
		if MtxGetElementData ( player, "nichtsgehtmehr_achiev" ) == 0 then
			MtxSetElementData ( player, "bonuspoints", MtxGetElementData ( player, "bonuspoints" ) + 15 )
			triggerClientEvent ( player, "showAchievmentBox", player, " Nichts geht\n mehr!", 15, 10000 )
			MtxSetElementData ( player, "nichtsgehtmehr_achiev", 1 )
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "NichtGehtMehr", 1, "UID", playerUID[pname] )
		end
	end
end

function ReallifeAchievCheck ( player )

	if tonumber ( MtxGetElementData ( player, "playingtime" ) ) >= 10000 and MtxGetElementData ( player, "rl_achiev" ) ~= "done" then							-- Achiev: Collector
		MtxSetElementData ( player, "rl_achiev", "done" )																									-- Achiev: Collector
		triggerClientEvent ( player, "showAchievmentBox", player, " Reallife -\n WTF?!", 50, 10000 )													-- Achiev: Collector
		MtxSetElementData ( player, "bonuspoints", tonumber(MtxGetElementData ( player, "bonuspoints" )) + 50 )												-- Achiev: Collector
		dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "ReallifeWTF", "done", "UID", playerUID[getPlayerName(player)] )
	end																																					-- Achiev: Collector
end

function OwnFootCheck ( player )
	if MtxGetElementData ( player, "own_foots" ) ~= "done" then
		MtxSetElementData ( player, "own_foots", "done" )																									-- Achiev: Own Foots
		triggerClientEvent ( player, "showAchievmentBox", player, " Eigene\n Füße!", 15, 10000 )														-- Achiev: Own Foots
		MtxSetElementData ( player, "bonuspoints", tonumber(MtxGetElementData ( player, "bonuspoints" )) + 15 )												-- Achiev: Own Foots
		dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "EigeneFuesse", "done", "UID", playerUID[getPlayerName(player)] )
	end
end

KingofTheHill = createMarker ( -2316.7216796875, -1661.7271728516, 483.32159423828, "corona", 200, 0, 0, 0, 0, getRootElement() )
function KingofTheHillCheck ( hitElement )

	local player = nil
	if getElementType ( hitElement ) == "vehicle" then 
		player = getVehicleOccupant ( hitElement, 0 ) 
	else
		if getElementType ( hitElement ) == "player" then 
			player = hitElement
		else
			player = nil
		end
	end
	if player then
		if MtxGetElementData ( player, "kingofthehill_achiev" ) ~= "done" then
			MtxSetElementData ( player, "kingofthehill_achiev", "done" )																						-- Achiev: King of the Hill
			triggerClientEvent ( player, "showAchievmentBox", player, " King of\n the Hill!", 15, 10000 )													-- Achiev: King of the Hill
			MtxSetElementData ( player, "bonuspoints", (tonumber(MtxGetElementData ( player, "bonuspoints" )) or 0 )+ 15 )												-- Achiev: King of the Hill
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "KingOfTheHill", "done", "UID", playerUID[getPlayerName(player)] )
		end
	end
end
addEventHandler ( "onMarkerHit", KingofTheHill, KingofTheHillCheck )


function checkCarWahnAchiev ( player )
	if MtxGetElementData ( player, "carwahn_achiev" ) ~= "done" then
		local amountbought = MtxGetElementData ( player, "FahrzeugeGekauft" )
		if amountbought and amountbought >= 20 then
			MtxSetElementData ( player, "carwahn_achiev", "done" )																									-- Achiev: Own Foots
			triggerClientEvent ( player, "showAchievmentBox", player, " Auto\nWahn!", 15, 10000 )														-- Achiev: Own Foots
			MtxSetElementData ( player, "bonuspoints", tonumber(MtxGetElementData ( player, "bonuspoints" )) + 30 )												-- Achiev: Own Foots
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "Fahrzeugwahn", "done", "UID", playerUID[getPlayerName(player)] )
		end
	end	
end


function HighwayToHellCheck ( player )
	if MtxGetElementData ( player, "highwaytohell_achiev" ) ~= "done" then
		if bikerskins[getElementModel(player)] then
			triggerClientEvent ( player, "showAchievmentBox", player, " Born to\n be Wild!", 10, 10000 )													-- Achiev: Born to be Wild!
			MtxSetElementData ( player, "bonuspoints", tonumber(MtxGetElementData ( player, "bonuspoints" )) + 10 )
			MtxSetElementData ( player, "highwaytohell_achiev", "done" )
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "HighwayToHell", "done", "UID", playerUID[getPlayerName(player)] )
		end
	end
end