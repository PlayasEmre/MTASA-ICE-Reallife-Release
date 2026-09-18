--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

--[[local coinshopPickup = createPickup(-1981.2109375, 155.07421875, 27.6875, 3, 1239, 1000)
local coinshop = {Window={},Button={},Gridlist={},GridlistColumn={},Label={},Edit={},Image={},Tabpanel={},Tab={},endebutton={}}

function coins(hitPlayer)
	if hitPlayer == localPlayer then
		if getElementData(localPlayer,"ElementClicked") == false then
			if not isPedInVehicle(localPlayer) then
				showCursor(true)
				setElementData(localPlayer,"ElementClicked",true)
				coinshop.Window[1] = dgsCreateWindow(680, 401, 702, 400,"Coinshop-Panel", false)
				dgsWindowSetSizable(coinshop.Window[1], false)             
				dgsWindowSetMovable(coinshop.Window[1], false)
				
				coinshop.Label[7] = dgsCreateLabel( 0.02,0.04,0.94,0.92, "Tactic K/D reset", true, coinshop.Window[1])
				coinshop.Button[2] = dgsCreateButton(16, 38, 154, 28, "250 ¢", false, coinshop.Window[1])
				
				coinshop.Label[8] = dgsCreateLabel( 0.27,0.04,0.94,0.92, "text", true, coinshop.Window[1])
				coinshop.Button[3] = dgsCreateButton(190, 38, 154, 28,"0 ¢", false, coinshop.Window[1])
				
				coinshop.Label[9] = dgsCreateLabel( 0.52,0.04,0.94,0.92, "text", true, coinshop.Window[1])
				coinshop.Button[4] = dgsCreateButton(364, 38, 154, 28,"0 ¢", false, coinshop.Window[1])
				
				coinshop.Label[10] = dgsCreateLabel( 0.76,0.04,0.94,0.92, "text", true, coinshop.Window[1])
				coinshop.Button[5] = dgsCreateButton(533, 38, 154, 28,"0 ¢", false, coinshop.Window[1])
				
				coinshop.endebutton[0] = dgsCreateButton(675,-25,27,25,"×",false,coinshop.Window[1])
				dgsSetProperty(coinshop.endebutton[0],"textSize",{1.6,1.6})
				
				coinshop.Label[6] = dgsCreateLabel ( 0.800, 0.79, 0.25, 0.2, "Coins: "..vioClientGetElementData ( "coins" ), true, coinshop.Window[1] )
				dgsLabelSetVerticalAlign ( coinshop.Label[6], "center" )

			
				addEventHandler("onDgsMouseClickUp",coinshop.endebutton[0],
					function(button)
						if button == "left" then
							dgsCloseWindow(coinshop.Window[1])
							showCursor(false)
							setElementData(localPlayer,"ElementClicked",false)
						end
					end,
				false)
				
				
				addEventHandler("onDgsMouseClickUp",coinshop.Button[2],
					function(button)
						if button == "left" then
							dgsCloseWindow(coinshop.Window[1])
							triggerServerEvent ( "coinshop",localPlayer )
							showCursor ( false )
							setElementData(localPlayer,"ElementClicked",false)
						end
					end
				,false)

				addEventHandler("onDgsMouseClickUp",coinshop.Button[3],
					function(button)
					if button == "left" then
							dgsCloseWindow(coinshop.Window[1])
							--triggerServerEvent ( "coinshop2",localPlayer )
							showCursor ( false )
							setElementData(localPlayer,"ElementClicked",false)
						end
					end
				,false)
				
				addEventHandler("onDgsMouseClickUp",coinshop.Button[4],
					function(button)
						if button == "left" then
							dgsCloseWindow(coinshop.Window[1])
							--triggerServerEvent ( "coinshop3",localPlayer )
							showCursor ( false )
							setElementData(localPlayer,"ElementClicked",false)
						end
					end
				,false)
				
				addEventHandler("onDgsMouseClickUp",coinshop.Button[5],
					function(button)
						if button == "left" then
							dgsCloseWindow(coinshop.Window[1])
							--triggerServerEvent ( "coinshop4",localPlayer )
							showCursor ( false )
							setElementData(localPlayer,"ElementClicked",false)
						end
					end
				,false)
				
				addEvent ( "updateCoinsInCoinshop", true )
				addEventHandler ( "updateCoinsInCoinshop", root, function ()
					if coinshop.Label[6] == nil then
						dgsSetText ( coinshop.Label[6], "Coins: "..vioClientGetElementData ( "coins" ) )
					end
				end )
			
			end
		end
	end
end
addEventHandler ( "onClientPickupHit",coinshopPickup,coins)--]]