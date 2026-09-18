--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

eatSwitch = false

local HouseIn_GUI = {Window={},Button={},Label={},Edit={}}

local btnBgColor    = tocolor(25,25,25,180)
local btnHoverColor = tocolor(0,150,255,150)
local btnClickColor = tocolor(0,100,200,200)

local function styleHouseButton ( button )
	dgsSetProperty ( button, "textColor", tocolor(255,255,255) )
end

function showHouseGui_func ( amount )

	if source == lp then
		dgsSetInputMode ( "no_binds_when_editing" )
		if HouseIn_GUI.Window[1] then
			eatSwitch = false
			dgsSetVisible ( HouseIn_GUI.Window[1], true )
			dgsSetText ( HouseIn_GUI.Label[2], "Kasse: "..amount.." "..Tables.waehrung.."" )
		else
			HouseIn_GUI.Window[1] = dgsCreateWindow(0,GLOBALscreenY/2-315/2,320,315,"Hausmenü",false)
			dgsWindowSetCloseButtonEnabled(HouseIn_GUI.Window[1], false)
			dgsMoveTo(HouseIn_GUI.Window[1],GLOBALscreenX/2-320/2,GLOBALscreenY/2-315/2,false,false,"OutQuad",1500)
			dgsWindowSetSizable(HouseIn_GUI.Window[1],false)
			dgsWindowSetMovable(HouseIn_GUI.Window[1],false)
			HouseIn_GUI.Button[1] = dgsCreateButton(294,-25,26,25,"×",false,HouseIn_GUI.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
			dgsSetProperty(HouseIn_GUI.Button[1],"textSize",{1.6,1.6})

			-- Bereich: Hauskasse
			HouseIn_GUI.Label[1] = dgsCreateLabel(15,14,290,18,"Hauskasse",false,HouseIn_GUI.Window[1])
			dgsLabelSetColor(HouseIn_GUI.Label[1],63,160,224)
			dgsSetFont(HouseIn_GUI.Label[1],"default-bold")
			dgsSetProperty(HouseIn_GUI.Label[1],"textSize",{1.1,1.1})

			HouseIn_GUI.Label[2] = dgsCreateLabel(15,36,290,20,"Kasse: "..amount.." "..Tables.waehrung.."",false,HouseIn_GUI.Window[1])
			dgsLabelSetColor(HouseIn_GUI.Label[2],0,200,0)

			HouseIn_GUI.Label[3] = dgsCreateLabel(15,68,150,18,"Betrag:",false,HouseIn_GUI.Window[1])
			dgsLabelSetColor(HouseIn_GUI.Label[3],255,255,255)
			HouseIn_GUI.Edit[1] = dgsCreateEdit(15,88,290,28,"",false,HouseIn_GUI.Window[1])

			HouseIn_GUI.Button[2] = dgsCreateButton(15,128,140,32,"Einzahlen",false,HouseIn_GUI.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
			styleHouseButton ( HouseIn_GUI.Button[2] )
			HouseIn_GUI.Button[3] = dgsCreateButton(165,128,140,32,"Auszahlen",false,HouseIn_GUI.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
			styleHouseButton ( HouseIn_GUI.Button[3] )

			-- Bereich: Sonstiges
			HouseIn_GUI.Label[4] = dgsCreateLabel(15,172,290,18,"Sonstiges",false,HouseIn_GUI.Window[1])
			dgsLabelSetColor(HouseIn_GUI.Label[4],63,160,224)
			dgsSetFont(HouseIn_GUI.Label[4],"default-bold")
			dgsSetProperty(HouseIn_GUI.Label[4],"textSize",{1.1,1.1})

			HouseIn_GUI.Button[4] = dgsCreateButton(15,198,140,32,"Heilen",false,HouseIn_GUI.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
			styleHouseButton ( HouseIn_GUI.Button[4] )
			HouseIn_GUI.Button[5] = dgsCreateButton(165,198,140,32,"Essen",false,HouseIn_GUI.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
			styleHouseButton ( HouseIn_GUI.Button[5] )
			HouseIn_GUI.Button[6] = dgsCreateButton(15,242,140,32,"Waffenbox",false,HouseIn_GUI.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
			styleHouseButton ( HouseIn_GUI.Button[6] )
			HouseIn_GUI.Button[7] = dgsCreateButton(165,242,140,32,"Verlassen",false,HouseIn_GUI.Window[1],_,_,_,_,_,_,nil,nil,nil,true)
			styleHouseButton ( HouseIn_GUI.Button[7] )

			addEventHandler("onDgsMouseClickUp",HouseIn_GUI.Button[1],
				function(btn)
					if btn == "left" then
						dgsSetVisible ( HouseIn_GUI.Window[1], false )
						setElementClicked ( false )
						showCursor ( false )
					end
				end,
			false)

			addEventHandler("onDgsMouseClickUp",HouseIn_GUI.Button[2],
				function(btn)
					if btn == "left" then
						local amount = tonumber ( dgsGetText ( HouseIn_GUI.Edit[1] ) )
						if not amount or amount <= 0 then
							outputChatBox ( "Bitte gebe eine gueltige Zahl ein!", 200, 0, 0 )
							return
						end
						triggerServerEvent ( "houseClickServer", lp, lp, "give", amount )
					end
				end,
			false)

			addEventHandler("onDgsMouseClickUp",HouseIn_GUI.Button[3],
				function(btn)
					if btn == "left" then
						local amount = tonumber ( dgsGetText ( HouseIn_GUI.Edit[1] ) )
						if not amount or amount <= 0 then
							outputChatBox ( "Bitte gebe eine gueltige Zahl ein!", 200, 0, 0 )
							return
						end
						triggerServerEvent ( "houseClickServer", lp, lp, "take", amount )
					end
				end,
			false)

			addEventHandler("onDgsMouseClickUp",HouseIn_GUI.Button[4],
				function(btn)
					if btn == "left" then
						triggerServerEvent ( "houseClickServer", lp, lp, "heal" )
					end
				end,
			false)

			addEventHandler("onDgsMouseClickUp",HouseIn_GUI.Button[5],
				function(btn)
					if btn == "left" then
						if not eatSwitch then
							eatSwitch = true
							triggerServerEvent ( "houseClickServer", lp, lp, "eat" )
						end
					end
				end,
			false)

			addEventHandler("onDgsMouseClickUp",HouseIn_GUI.Button[6],
				function(btn)
					if btn == "left" then
						dgsSetVisible ( HouseIn_GUI.Window[1], false )
						_createGunboxMenue ()
					end
				end,
			false)

			addEventHandler("onDgsMouseClickUp",HouseIn_GUI.Button[7],
				function(btn)
					if btn == "left" then
						dgsSetVisible ( HouseIn_GUI.Window[1], false )
						setElementClicked ( false )
						showCursor ( false )
						triggerServerEvent ( "onHouseLeave", lp, lp )
					end
				end,
			false)
		end
	end
end
addEvent ( "showHouseGui", true )
addEventHandler ( "showHouseGui", getRootElement(), showHouseGui_func )
