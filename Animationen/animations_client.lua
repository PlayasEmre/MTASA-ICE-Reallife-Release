--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local selfmadeAnimationen={
["Animationen"]={
"Hände hoch",
"Hinlegen",
"Winken",
"Arme verschränken",
"Lachen",
"Pissen",
"Ass Slap",
"Bitch Slap",
"Kotzen",
"Masturbieren",
"Kratzen Genitalbreich",
"Kratzen Kopf",
"Fuck you",
"Warten",
"Etwas zeigen",
"Nach oben zeigen",
"Tanzen orientalisch",
"Tanzen chillig",
"Tanzen rhythmisch",
"Tanzen wild",
"Tanzen HipHop",
"Tanzen sexy",
"Tanzen nuttig",
"Tanzen strip 1",
"Tanzen strip 2",
},
}


local Anim={Window={},Button={},Gridlist={},GridlistColumn={},Label={},Edit={},Image={},Tabpanel={},Tab={},}

function animGUI()
	if introCutsceneAktiv then return end -- Waehrend der Intro-Kamerafahrt gesperrt, siehe quest/intro_cutscene_client.lua
	if(getElementData(localPlayer,"ElementClicked")==false)then
	if  getElementData ( localPlayer, "jailtime" ) <1 and getElementData ( localPlayer, "prison" ) <1 then
			showCursor(true)
			setElementData(localPlayer,"ElementClicked",true)
			Anim.Window[1]=dgsCreateWindow(0,GLOBALscreenY/2-400/2,300,400,"Animations-Panel",false)
			dgsWindowSetCloseButtonEnabled(Anim.Window[1], false)
			dgsMoveTo(Anim.Window[1],GLOBALscreenX/2-300/2,GLOBALscreenY/2-400/2,false,false,"OutQuad",1500)
			dgsWindowSetSizable(Anim.Window[1],false)
			dgsWindowSetMovable(Anim.Window[1],false)
			Anim.Button[1]=dgsCreateButton(274,-25,26,25,"×",false,Anim.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
			dgsSetProperty(Anim.Button[1],"textSize",{1.6,1.6})
			
			Anim.Gridlist[1]=dgsCreateGridList(10,10,280,340,false,Anim.Window[1],_,tocolor(50,50,50,255),tocolor(255,255,255,255),tocolor(30,30,30,255),tocolor(65,65,65,255))
			animation=dgsGridListAddColumn(Anim.Gridlist[1], "Animation", 0.94)
			
			
			
			for key,_ in pairs(selfmadeAnimationen["Animationen"])do
				row=dgsGridListAddRow(Anim.Gridlist[1])
				dgsGridListSetItemText(Anim.Gridlist[1],row,animation,selfmadeAnimationen["Animationen"][key],false,false)
			end
			
			addEventHandler("onDgsMouseDoubleClick",Anim.Gridlist[1],
				function(btn)
					if btn == "left" then
						-- Ein Doppelklick neben die Eintraege liefert -1, womit
					-- dgsGridListGetItemText fehlschlaegt.
					local zeile=dgsGridListGetSelectedItem(Anim.Gridlist[1])
					if not zeile or zeile < 0 then return end
					local anim=dgsGridListGetItemText(Anim.Gridlist[1],zeile,1)
							
						if(not(selfmadeGui==""))then
							if(not(getElementData(localPlayer,"smokeweed"))==true)then
								triggerServerEvent("start.animation",localPlayer,anim)
								dgsCloseWindow(Anim.Window[1])
								showCursor(false)
								setElementData(localPlayer,"ElementClicked",false)
							else triggerClientEvent(localPlayer, "infobox_start", getRootElement(), "Zurzeit nicht möglich, da du rauchst!", 7500, 135, 206, 250)end
						end
					end
				end,
			false)
			addEventHandler("onDgsMouseClickUp",Anim.Button[1],
				function(btn)
					if btn == "left" then
						dgsCloseWindow(Anim.Window[1])
						showCursor(false)
						setElementData(localPlayer,"ElementClicked",false)
					end
				end,
		    false)
	 end
   end
end	
bindKey("f3","down",animGUI)