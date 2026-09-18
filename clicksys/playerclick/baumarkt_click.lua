--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

pcall(function() loadstring(exports.DGS:dgsImportFunction())() end)

createMarker ( -2667.78, -5.39, 5.05, "cylinder", 3, 255, 0, 0, 150 )
baumarktSphere = createColSphere ( -2667.78, -5.39, 5.05, 3 )
createBlip ( -2667.78, -5.39, 5.05, 11, 2, 255, 0, 0, 255, 0, 200 )
local clickedbut = nil

function showBaumarktMenue ( hit )

	if hit == lp then
		dgsSetInputMode ( "no_binds_when_editing" )
		showCursor ( true )
		setElementClicked ( true )
		if isElement ( gWindow["baumarkt"] ) then
			dgsSetVisible ( gWindow["baumarkt"], true )
		else
			gWindow["baumarkt"] = dgsCreateImage(screenwidth/2-445/2,screenheight/2-294/2,445,294,":"..getResourceName(getThisResource()).."/images/background.png",false)

			gLabel[1] = dgsCreateLabel(10,26,418,32,"Herzlich Willkommen!\nHier kannst du Objekte erwerben, die du anschließend platzieren kannst.",false,gWindow["baumarkt"])
			dgsLabelSetColor(gLabel[1],255,255,255,255)
			dgsLabelSetVerticalAlign(gLabel[1],"top")
			dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
			dgsSetFont(gLabel[1],"default-bold")

			gButton["closeBaumarkt"] = dgsCreateButton(419,23,16,17,"x",false,gWindow["baumarkt"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
			addEventHandler ( "onDgsMouseClickUp", gButton["closeBaumarkt"], hideBaumarktMenue, false )

			local placeableItems = {
				{ x = 9,   y = 58,  id = 841,  icon = "campfire.png", name = "Lagerfeuer" },
				{ x = 157, y = 58,  id = 3461, icon = "torch.png",    name = "Fackel" },
				{ x = 9,   y = 140, id = 1946, icon = "ball_a.png",   name = "Basketball" },
				{ x = 157, y = 140, id = 1598, icon = "ball_b.png",   name = "Strandball" },
				{ x = 303, y = 58,  id = 1481, icon = "grill.png",    name = "Grill" },
				{ x = 303, y = 140, id = 1255, icon = "liege.png",    name = "Liege" },
				{ x = 10,  y = 214, id = 1640, icon = "towel.png",    name = "Handtuch" },
			}

			for i, item in ipairs ( placeableItems ) do
				gButton[i] = dgsCreateButton(item.x,item.y,133,67,"",false,gWindow["baumarkt"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
				local btn = gButton[i]
				setElementData ( btn, "placeableItemId", item.id )
				local img = dgsCreateImage(8,6,50,50,":"..getResourceName(getThisResource()).."/images/inventory/placeable/"..item.icon,false,btn)
				dgsSetEnabled(img,false)
				local label = dgsCreateLabel(63,10,65,52,item.name.."\n\n"..placeablePrices[item.id].." "..Tables.waehrung.."",false,btn)
				dgsSetEnabled(label,false)
				dgsLabelSetColor(label,255,255,255,255)
				dgsLabelSetVerticalAlign(label,"top")
				dgsLabelSetHorizontalAlign(label,"left",false)
				dgsSetFont(label,"default-bold")

				addEventHandler ( "onDgsMouseClickUp", btn,
					function (button)
						if button ~= "left" then return end
						clickedbut = getElementData ( source, "placeableItemId" )
						purchaseItem ()
					end,
				false )
			end

			gRadio["colorSelect2"] = dgsCreateRadioButton(151,213,73,23,"Lila",false,gWindow["baumarkt"])
			dgsSetFont(gRadio["colorSelect2"],"default-bold")
			gRadio["colorSelect1"] = dgsCreateRadioButton(151,236,73,23,"Gruen",false,gWindow["baumarkt"])
			dgsSetFont(gRadio["colorSelect1"],"default-bold")
			gRadio["colorSelect3"] = dgsCreateRadioButton(229,213,73,23,"Rot",false,gWindow["baumarkt"])
			dgsSetFont(gRadio["colorSelect3"],"default-bold")
			gRadio["colorSelect4"] = dgsCreateRadioButton(229,236,73,23,"Gelb",false,gWindow["baumarkt"])
			dgsRadioButtonSetSelected(gRadio["colorSelect4"],true)
			dgsSetFont(gRadio["colorSelect4"],"default-bold")
		end
	end
end
addEventHandler ( "onClientColShapeHit", baumarktSphere, showBaumarktMenue )

function hideBaumarktMenue (button)

	if button ~= nil and button ~= "left" then return end
	dgsSetVisible ( gWindow["baumarkt"], false )
	dgsSetInputMode ( "allow_binds" )
	showCursor ( false )
	setElementClicked ( false )
end

function purchaseItem ()

	if clickedbut then
		if clickedbut == 1640 then
			-- Radio Buttons
			if dgsRadioButtonGetSelected ( gRadio["colorSelect2"] ) then
				clickedbut = 1641
			elseif dgsRadioButtonGetSelected ( gRadio["colorSelect3"] ) then
				clickedbut = 1642
			elseif dgsRadioButtonGetSelected ( gRadio["colorSelect4"] ) then
				clickedbut = 1643
			end
		end
		triggerServerEvent ( "purchaseItem", lp, clickedbut )
	end
end
