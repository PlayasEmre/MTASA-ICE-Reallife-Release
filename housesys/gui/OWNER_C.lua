--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local HouseO_GUI={Window={},Button={},Gridlist={},GridlistColumn={},Label={},Edit={},Image={},Tabpanel={},Tab={},}

function openHouseOwnerGUI(house)
	if not isPedInVehicle(localPlayer)then
		if getElementData(localPlayer,"ElementClicked")==false then
			showCursor(true)
			setElementData(localPlayer,"ElementClicked",true)
			HouseO_GUI.Window[1]=dgsCreateWindow(0,GLOBALscreenY/2-250/2,300,250,"Hausmenü",false)				dgsWindowSetCloseButtonEnabled(HouseO_GUI.Window[1],false)
			dgsMoveTo(HouseO_GUI.Window[1],GLOBALscreenX/2-300/2,GLOBALscreenY/2-250/2,false,false,"OutQuad",1500)
			dgsWindowSetSizable(HouseO_GUI.Window[1],false)
			dgsWindowSetMovable(HouseO_GUI.Window[1],false)
			HouseO_GUI.Button[1]=dgsCreateButton(274,-25,26,25,"×",false,HouseO_GUI.Window[1])
			dgsSetProperty(HouseO_GUI.Button[1],"textSize",{1.6,1.6})
			
			local locked = getElementData(house,"locked")
			local preis = getElementData(house,"preis")
			local rent = getElementData(house,"miete")
			local owner = getElementData(house,"owner")
			
			if(locked==false)then
				locked="Tür Zuschließen"
			else
				locked="Tür Aufschließen"
			end
			
			HouseO_GUI.Label[1]=dgsCreateLabel(10,10,200,40,"Besitzer: "..owner,false,HouseO_GUI.Window[1])
			HouseO_GUI.Label[2]=dgsCreateLabel(10,25,200,40,"Preis: ",false,HouseO_GUI.Window[1])
			HouseO_GUI.Label[3]=dgsCreateLabel(10,40,200,40,"Standort: "..getZoneName(getElementPosition(lp)),false,HouseO_GUI.Window[1])
			HouseO_GUI.Label[4]=dgsCreateLabel(10,55,200,40,"Türe: "..locked,false,HouseO_GUI.Window[1])
			HouseO_GUI.Label[5]=dgsCreateLabel(10,70,200,40,"Miete: "..rent..""..Tables.waehrung.."",false,HouseO_GUI.Window[1])
			
			HouseO_GUI.Button[5]=dgsCreateButton(10,100,130,30,"Miete setzen",false,HouseO_GUI.Window[1])
			HouseO_GUI.Edit[1]=dgsCreateEdit(160,100,130,30,"",false,HouseO_GUI.Window[1])
			HouseO_GUI.Button[2]=dgsCreateButton(10,140,130,30,"Betreten",false,HouseO_GUI.Window[1],nil,nil,nil,nil,nil,nil,tocolor(100,181,246,255),tocolor(150,205,250,255),tocolor(66,140,205,255))
			HouseO_GUI.Button[4]=dgsCreateButton(160,140,130,30,"Verkaufen",false,HouseO_GUI.Window[1])
			HouseO_GUI.Button[3]=dgsCreateButton(10,180,280,30,"Türe auf/zu",false,HouseO_GUI.Window[1])
			
			dgsSetText(HouseO_GUI.Label[2],"Preis: "..preis..""..Tables.waehrung.."")
			dgsSetText(HouseO_GUI.Button[3],locked)
			dgsSetText(HouseO_GUI.Label[4],"Türe: "..locked)
			dgsSetText(HouseO_GUI.Label[5],"Miete: "..rent..""..Tables.waehrung.."")
			
			addEventHandler("onDgsMouseClickUp",HouseO_GUI.Button[5],
				function(btn)
					if btn == "left" then
						local edit=dgsGetText(HouseO_GUI.Edit[1])
						if (#edit > 0) then
							if (tonumber(edit)) then
								dgsCloseWindow(HouseO_GUI.Window[1])
								showCursor(false)
								setElementData(lp,"ElementClicked",false)
								triggerServerEvent('onHouseSetRent',lp,lp,tonumber(edit))
							else
								outputChatBox('Es sind nur Zahlen erlaubt!', 200,0,0)
							end
						else
							outputChatBox('Bitte gebe eine Zahl ein!', 200,0,0)
						end
					end
				end,
			false)
			
			addEventHandler("onDgsMouseClickUp",HouseO_GUI.Button[4],
				function(btn)
					if btn == "left" then
						dgsCloseWindow(HouseO_GUI.Window[1])
						showCursor(false)
						setElementData(lp,"ElementClicked",false)
						triggerServerEvent("onHouseSellGUI",lp,lp)
					end
				end,
			false)
			
			addEventHandler("onDgsMouseClickUp",HouseO_GUI.Button[3],
				function(btn)
					if btn=="left" then
						locked=getElementData(house,"locked")
						if(locked==true)then locked="Tür Zuschließen" else locked="Tür Aufschließen" end 
						dgsSetText(HouseO_GUI.Button[3],locked)
						dgsSetText(HouseO_GUI.Label[4],"Türe: "..locked)
						triggerServerEvent("onHouseSetState",lp,lp)
					end
				end,
			false)
			addEventHandler("onDgsMouseClickUp",HouseO_GUI.Button[2],
				function(btn)
					if btn == "left" then
						dgsCloseWindow(HouseO_GUI.Window[1])
						showCursor(false)
						setElementData(lp,"ElementClicked",false)
						triggerServerEvent("onHouseEnter",lp,lp)
					end
				end,
			false)
			
			addEventHandler("onDgsMouseClickUp",HouseO_GUI.Button[1],
				function(btn)
					if btn == "left" then
						dgsCloseWindow(HouseO_GUI.Window[1])
						showCursor(false)
						setElementData(lp,"ElementClicked",false)
					end
				end,
			false)
			
		end
	end
end
addEvent("onCreateOwnerHouseGUI",true)
addEventHandler("onCreateOwnerHouseGUI",lp,openHouseOwnerGUI)