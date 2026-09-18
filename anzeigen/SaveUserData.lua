--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local SaveUserData = {Window={},Button={},Gridlist={},GridlistColumn={},Label={},Edit={},Image={},Tabpanel={},Tab={},endebutton={}}

function SaveUserDataa()
		if getElementData(localPlayer,"ElementClicked") == false then
			showCursor(true)
			SaveUserData.Window[1] = dgsCreateWindow(837,417,296,197,"SaveUserData",false)
			dgsWindowSetCloseButtonEnabled(SaveUserData.Window[1], false)
			dgsWindowSetSizable(SaveUserData.Window[1], false)
			dgsWindowSetMovable(SaveUserData.Window[1], false)
			SaveUserData.Button[2] = dgsCreateButton(50, 30, 190, 73, "SAVE", false, SaveUserData.Window[1],nil,nil,nil,nil,nil,nil,tocolor(100,181,246,255),tocolor(150,205,250,255),tocolor(66,140,205,255))
			SaveUserData.endebutton[0] = dgsCreateButton(270,-25,26,25,"×",false,SaveUserData.Window[1])
			dgsSetProperty(SaveUserData.endebutton[0],"textSize",{1.6,1.6})
			setElementData(localPlayer,"ElementClicked",true)
		
			addEventHandler("onDgsMouseClickUp",SaveUserData.endebutton[0],
				function(button)
					if button == "left" then
						dgsCloseWindow(SaveUserData.Window[1])
						showCursor(false)
						setElementData(localPlayer,"ElementClicked",false)
					end
				end,
			false)
			
			addEventHandler("onDgsMouseClickUp",SaveUserData.Button[2],
				function(button)
					if button == "left" then
						dgsCloseWindow(SaveUserData.Window[1])
						showCursor(false)
						setElementData(localPlayer,"ElementClicked",false)
						triggerServerEvent ( "saveuserdata", localPlayer, localPlayer )
					end
				end,
			false)
	end
end
addCommandHandler("savedata", SaveUserDataa)