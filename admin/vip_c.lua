--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local ppanel = {Window={},Button={},Gridlist={},GridlistColumn={},Label={},Edit={},Image={},Tabpanel={},Tab={},endebutton={}}

function Premiumpanel()
	if getElementData(localPlayer,"ElementClicked") == false then
		showCursor ( true )
		ppanel.Window[1] = dgsCreateWindow(580, 401, 702, 404,"Premium-Panel", false)		dgsWindowSetCloseButtonEnabled(ppanel.Window[1], false)
		dgsWindowSetSizable(ppanel.Window[1], false)             
		dgsWindowSetMovable(ppanel.Window[1] ,false)
		ppanel.Button[2] = dgsCreateButton(16, 38, 154, 28, "Fahrzeug Tanken", false, ppanel.Window[1])
		ppanel.Button[3] = dgsCreateButton(190, 38, 154, 28, "Fahrzeug reparieren [100"..Tables.waehrung.."]", false, ppanel.Window[1])
		ppanel.Button[4] = dgsCreateButton(364, 38, 154, 28, "Radio", false, ppanel.Window[1])
		ppanel.Button[5] = dgsCreateButton(533, 38, 154, 28, "Leben auffüllen [300"..Tables.waehrung.."]", false, ppanel.Window[1])
		ppanel.endebutton[0] = dgsCreateButton(675,-25,27,25,"×",false,ppanel.Window[1])
		dgsSetProperty(ppanel.endebutton[0],"textSize",{1.6,1.6})
		setElementData(localPlayer,"ElementClicked",true)
		
		addEventHandler("onDgsMouseClickUp",ppanel.endebutton[0],
			function(btn)
				if btn == "left" then
					dgsCloseWindow(ppanel.Window[1])
					showCursor(false)
					setElementData(localPlayer,"ElementClicked",false)
				end
			end,
		false)
		
		addEventHandler("onDgsMouseClickUp",ppanel.Button[2],
			function(btn)
				if btn == "left" then
					dgsCloseWindow(ppanel.Window[1])
					showCursor(false)
					setElementData(localPlayer,"ElementClicked",false)
					triggerServerEvent("fillComplete1",localPlayer,localPlayer)
				end
			end,
		false)
		
		
		addEventHandler("onDgsMouseClickUp",ppanel.Button[3],
			function(btn)
				if btn == "left" then
					dgsCloseWindow(ppanel.Window[1])
					showCursor(false)
					setElementData(localPlayer,"ElementClicked",false)
					triggerServerEvent("fixveh1",localPlayer,localPlayer)
				end
			end,
		false)
		
		
		
		addEventHandler("onDgsMouseClickUp",ppanel.Button[4],
			function(btn)
				if btn == "left" then
					dgsCloseWindow(ppanel.Window[1])
					setElementData(localPlayer,"ElementClicked",false)
					triggerEvent ( "onPlayerViewSpeakerManagment", localPlayer, localPlayer )
				end
			end,
		false)
		
		addEventHandler("onDgsMouseClickUp",ppanel.Button[5],
			function(btn)
				if btn == "left" then
					dgsCloseWindow(ppanel.Window[1])
					showCursor(false)
					setElementData(localPlayer,"ElementClicked",false)
					triggerServerEvent("lebenessen",localPlayer,localPlayer)
				end
			end,
		false)
		
	end
end
addEvent("Premiumpanel",true)
addEventHandler("Premiumpanel",root,Premiumpanel)