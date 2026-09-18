--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //
local levelShopPickup = createPickup(-1981.2669677734, 153.42135620117, 27.6875, 3, 1239, 1000)
local levelshop = {Window={},Button={},Gridlist={},GridlistColumn={},Label={},Edit={},Image={},Tabpanel={},Tab={},endebutton={}}

function testooo(hitPlayer)
	if hitPlayer == localPlayer then
		if getElementData(localPlayer,"ElementClicked") == false then
			if not isPedInVehicle(localPlayer) then
				showCursor(true)
				setElementData(localPlayer,"ElementClicked",true)
				levelshop.Window[1] = dgsCreateWindow(680, 401, 702, 404,"LevelShop-Panel", false)			dgsWindowSetCloseButtonEnabled(levelshop.Window[1], false)
				dgsWindowSetSizable(levelshop.Window[1], false)             
				dgsWindowSetMovable(levelshop.Window[1], false)
				levelshop.Button[2] = dgsCreateButton(16, 38, 154, 28, "30.000€ Level 5", false, levelshop.Window[1])
				levelshop.Button[3] = dgsCreateButton(190, 38, 154, 28,"Premuim Gold Level 10", false, levelshop.Window[1])
				levelshop.Button[4] = dgsCreateButton(364, 38, 154, 28,"Coins Level 20", false, levelshop.Window[1])
				levelshop.Button[5] = dgsCreateButton(533, 38, 154, 28,"100.000€ + 500 Coins Level 30", false, levelshop.Window[1])
				levelshop.endebutton[0] = dgsCreateButton(675,-25,27,25,"×",false,levelshop.Window[1])
				dgsSetProperty(levelshop.endebutton[0],"textSize",{1.6,1.6})
			
				addEventHandler("onDgsMouseClickUp",levelshop.endebutton[0],
					function(button)
						if button == "left" then
							dgsCloseWindow(levelshop.Window[1])
							showCursor(false)
							setElementData(localPlayer,"ElementClicked",false)
						end
					end,
				false)
				
				
				addEventHandler("onDgsMouseClickUp",levelshop.Button[2],
					function(button)
					if button == "left" then
						if getElementData(localPlayer,"level") >= 5 and dgsGetEnabled(levelshop.Button[2]) then
							dgsSetEnabled(levelshop.Button[2],true)
							dgsCloseWindow(levelshop.Window[1])
							triggerServerEvent ( "levelshop", localPlayer, localPlayer )
							showCursor ( false )
							setElementData(localPlayer,"ElementClicked",false)
							end
						end
					end
				,false)
				
				addEventHandler("onDgsMouseClickUp",levelshop.Button[3],
					function(button)
					if button == "left" then
						if getElementData(localPlayer,"level") >= 10 and dgsGetEnabled(levelshop.Button[3]) then
							dgsSetEnabled(levelshop.Button[3],true)
							dgsCloseWindow(levelshop.Window[1])
							triggerServerEvent ( "levelshop2", localPlayer, localPlayer )
							showCursor ( false )
							setElementData(localPlayer,"ElementClicked",false)
							end
						end
					end
				,false)
				
				addEventHandler("onDgsMouseClickUp",levelshop.Button[4],
					function(button)
					if button == "left" then
						if getElementData(localPlayer,"level") >= 20 and dgsGetEnabled(levelshop.Button[4]) then
							dgsSetEnabled(levelshop.Button[4],true)
							dgsCloseWindow(levelshop.Window[1])
							triggerServerEvent ( "levelshop3", localPlayer, localPlayer )
							showCursor ( false )
							setElementData(localPlayer,"ElementClicked",false)
							end
						end
					end
				,false)
				
				addEventHandler("onDgsMouseClickUp",levelshop.Button[5],
					function(button)
					if button == "left" then
						if getElementData(localPlayer,"level") >= 30 and dgsGetEnabled(levelshop.Button[5]) then
							dgsSetEnabled(levelshop.Button[5],true)
							dgsCloseWindow(levelshop.Window[1])
							triggerServerEvent ( "levelshop4", localPlayer, localPlayer )
							showCursor ( false )
							setElementData(localPlayer,"ElementClicked",false)
							end
						end
					end
				,false)
			
			end
		end
	end
end
addEventHandler ( "onClientPickupHit",levelShopPickup,testooo)