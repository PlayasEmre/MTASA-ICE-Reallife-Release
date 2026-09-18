--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local HouseN_GUI={Window={},Button={},Gridlist={},GridlistColumn={},Label={},Edit={},Image={},Tabpanel={},Tab={},}

function openHouseOwnerGUI(house)
	if not isPedInVehicle(localPlayer)then
		if getElementData(localPlayer,"ElementClicked") == false then
			showCursor(true)
			setElementData(localPlayer,"ElementClicked",true)
			HouseN_GUI.Window[1]=dgsCreateWindow(0,GLOBALscreenY/2-250/2,300,250,"Hausmenü",false)				dgsWindowSetCloseButtonEnabled(HouseN_GUI.Window[1],false)
			dgsMoveTo(HouseN_GUI.Window[1],GLOBALscreenX/2-300/2,GLOBALscreenY/2-250/2,false,false,"OutQuad",1500)
			dgsWindowSetSizable(HouseN_GUI.Window[1],false)
			dgsWindowSetMovable(HouseN_GUI.Window[1],false)
			HouseN_GUI.Button[1]=dgsCreateButton(274,-25,26,25,"×",false,HouseN_GUI.Window[1])
			dgsSetProperty(HouseN_GUI.Button[1],"textSize",{1.6,1.6})
			
			local preis = getElementData(house,"preis")
			
			HouseN_GUI.Label[1]=dgsCreateLabel(10,10,200,40,"Preis: ",false,HouseN_GUI.Window[1])
			HouseN_GUI.Label[2]=dgsCreateLabel(10,25,200,40,"Mindestspielzeit: 3 Stunden",false,HouseN_GUI.Window[1])
			
			HouseN_GUI.Button[2]=dgsCreateButton(10,140,280,30,"Bezahlen [Bar]",false,HouseN_GUI.Window[1])
			HouseN_GUI.Button[3]=dgsCreateButton(10,180,280,30,"Bezahlen [Bank]",false,HouseN_GUI.Window[1])
			
			dgsSetText(HouseN_GUI.Label[1],"Preis: "..preis..""..Tables.waehrung.."")
			
	
			
			addEventHandler("onDgsMouseClickUp",HouseN_GUI.Button[3],
				function(btn)
					if btn == "left" then
						dgsCloseWindow(HouseN_GUI.Window[1])
						showCursor(false)
						setElementData(lp,"ElementClicked",false)
						triggerServerEvent("onHouseBuyGUI",lp,lp,"bank")
					end
				end,
			false)
			
			addEventHandler("onDgsMouseClickUp",HouseN_GUI.Button[2],
				function(btn)
					if btn == "left" then
						dgsCloseWindow(HouseN_GUI.Window[1])
						showCursor(false)
						setElementData(lp,"ElementClicked",false)
						triggerServerEvent("onHouseBuyGUI",lp,lp,"bar")
					end
				end,
			false)
			
			addEventHandler("onDgsMouseClickUp",HouseN_GUI.Button[1],
				function(btn)
					if btn == "left" then
						dgsCloseWindow(HouseN_GUI.Window[1])
						showCursor(false)
						setElementData(lp,"ElementClicked",false)
					end
				end,
			false)
			
		end
	end
end
addEvent("onCreateNewHouseGUI",true)
addEventHandler("onCreateNewHouseGUI",lp,openHouseOwnerGUI)