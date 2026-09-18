--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local ReportPickup=createPickup(125.1,-187.5,2001,3,1239,1)

local Report={Window={},Button={},Gridlist={},Label={},Edit={},Image={},}

function openReporthalle_GUI(player)
	if player == lp then
		if not isPedInVehicle(lp)then
			if(getElementData(lp,"ElementClicked")==false)then
				showCursor(true)
				setElementData(lp,"ElementClicked",true)
				Report.Window[1]=dgsCreateWindow(GLOBALscreenX/2-450/2,GLOBALscreenY/2-300/2,450,300,""..Tables.servername.."-Reallife Reporthalle",false)
				dgsWindowSetCloseButtonEnabled(Report.Window[1], false)
				dgsWindowSetSizable(Report.Window[1],false)
				dgsWindowSetMovable(Report.Window[1],false)
				Report.Button[1]=dgsCreateButton(424,-25,26,25,"×",false,Report.Window[1])
                dgsSetProperty(Report.Button[1],"textSize",{1.6,1.6})

				Report.Label[1]=dgsCreateLabel(10,20,200,60,"Willkommen in der "..Tables.servername.."-Reallife Reporthalle.\n Wenn du Hilfe benötigst, klicke auf 'Hilfe Anfordern' .\nAnsonsten wünschen wir dir Viel Spaß auf "..Tables.servername.."-Reallife.",false,Report.Window[1])

				Report.Button[2]=dgsCreateButton(10,160,430,45,"Hilfe anfordern",false,Report.Window[1],nil,nil,nil,nil,nil,nil,tocolor(100,181,246,255),tocolor(150,205,250,255),tocolor(66,140,205,255))
				Report.Button[3]=dgsCreateButton(10,215,430,45,"Reporthalle verlassen",false,Report.Window[1])
				
				
				
				addEventHandler("onDgsMouseClick",Report.Button[3],
					function(btn,state)
						if btn=="left" and state=="up" then
							dgsCloseWindow(Report.Window[1])
							showCursor(false)
							setElementData(lp,"ElementClicked",false)
							triggerServerEvent("reporthalle:leave",lp,lp)
						end
					end,
				false)
				
				addEventHandler("onDgsMouseClick",Report.Button[2],
					function(btn,state)
						if btn=="left" and state=="up" then
							dgsCloseWindow(Report.Window[1])
							showCursor(false)
							setElementData(lp,"ElementClicked",false)
							triggerServerEvent("reporthalle:hilfe",lp,lp)
						end
					end,
				false)
				
				addEventHandler("onDgsMouseClick",Report.Button[1],
					function(btn,state)
						if btn=="left" and state=="up" then
							dgsCloseWindow(Report.Window[1])
							showCursor(false)
							setElementData(lp,"ElementClicked",false)
						end
					end,
				false)
				
			end
		end
	end
end
addEventHandler("onClientPickupHit",ReportPickup,openReporthalle_GUI)


local function initSound()
	local sound = playSound3D ( "http://www.iloveradio.de/ilove2dance.m3u", 114.85832977295,-184.16856384277,2001.0999755859 ) 
	setSoundVolume(sound,0.40)
end
addEventHandler( "onClientResourceStart", root, initSound )