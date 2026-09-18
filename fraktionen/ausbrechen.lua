--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local ausbruchstart = createPickup ( -1574.3695068359,667.51806640625,7.1901206970215,3,1239,0)

function ausbruch_hit ( hitElement )

	if isEvil ( hitElement ) then
		outputChatBox("Tippe /befreien [Name] um die insassen zu befreien.", hitElement, 0, 125, 0 )
	else
		outputChatBox ("Nur für böse Fraktionen!", hitElement, 0, 125, 0 )
	end
end
addEventHandler("onPickupHit", ausbruchstart, ausbruch_hit )

local knastausbruchan = true

function knastausbruch_func(player, cmd, pplayer)
    if isEvil(player) then
	    if getDistanceBetweenPoints3D ( -1574.3695068359,667.51806640625,7.1901206970215, getElementPosition (player) ) < 5 then
	        local target = getPlayerFromName(pplayer)
	        if isElement ( target ) then	
	            local target = getPlayerFromName(pplayer)
	            if MtxGetElementData(target, "jailtime") >= 1 then
		            if not knastausbruchan then
			            outputChatBox("Hat leider nicht geklappt, versuche es später erneut!", player, 200, 0, 0)
						return
		            end		
                    knastausbruchan = false	
		            setTimer(function ()
			            knastausbruchan = true
		            end, 60*60*1000, 1)				
                    MtxSetElementData(target, "jailtime", 0)
		            MtxSetElementData(target, "wanteds", 6)	
		            setPlayerWantedLevel(target, 6)				
                    setElementPosition (target, -1621.8283691406,678.16351318359,7.1875)
		            setElementInterior(target, 0)
	                toggleControl (target, "enter_exit", true)
	                toggleControl (target, "fire", true)
	                toggleControl (target, "jump", true)
	                toggleControl (target, "action", true)
		            outputChatBox("Einem Häftling wurde die Flucht aus dem Gefängniss ermöglicht!", getRootElement(), 200, 0, 0)
		            outputChatBox("Du bist vom Gefängniss ausgebrochen, warte hier auf deine Kammeraden!", target, 200, 0, 0)
		            outputChatBox("Du hast dem Spieler erfolgreich bei der Flucht geholfen. Er wartet vor dem SFPD!", player, 200, 0, 0)			
		            MtxSetElementData(player, "wanteds", 6)
		            setPlayerWantedLevel(player, 6)				
				else
			        outputChatBox("Ungültiger Spieler!", player, 255, 0, 0)
				end
			end
		end
	else
		outputChatBox("Du hast keine Berechtigung um diesen Befehl zu nutzen!", player, 255, 0, 0)
    end
end			
addCommandHandler ( "befreien", knastausbruch_func )