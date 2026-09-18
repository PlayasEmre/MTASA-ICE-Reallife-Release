--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

local casheer = createInvulnerablePed ( 178, -104.79, -8.56, 1000.36, 180, 3, 0 )
local xxxShopMarker = createMarker ( -104.79, -10.79, 999.61, "cylinder", 1, 125, 0, 0, 150 )
setElementInterior ( xxxShopMarker, 3 )

function xxxShopMarker_hit ( player, dim )

	if player == lp and dim then
		if isElement ( gWindow["sexShop"] ) then
			return
		end

		guiSetInputMode ( "no_binds_when_editing" )
		showCursor ( true )
		setElementClicked ( true )
		gWindow["sexShop"] = dgsCreateWindow(screenwidth/2-194/2,screenheight/2-(295-70)/2,194,295-70,"Sexshop",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
		dgsWindowSetSizable ( gWindow["sexShop"], false )
		dgsWindowSetMovable ( gWindow["sexShop"], false )
		dgsBringToFront ( gWindow["sexShop"] )
		dgsSetProperty ( gWindow["sexShop"], "image", false )
		gGrid["sexShop"] = dgsCreateGridList(12,15,170,205-70,false,gWindow["sexShop"])
		dgsGridListSetSelectionMode(gGrid["sexShop"],0)
		gColumn["sexShopItem"] = dgsGridListAddColumn(gGrid["sexShop"],"Item",0.6)
		gColumn["sexShopPrice"] = dgsGridListAddColumn(gGrid["sexShop"],"Preis",0.2)
		gButton["sexShopBuy"] = dgsCreateButton(12,160,69,42,"Kaufen",false,gWindow["sexShop"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["sexShopClose"] = dgsCreateButton(113,160,69,42,"Schliessen",false,gWindow["sexShop"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		local row
		for key, index in pairs ( sexShopItems ) do
			row = dgsGridListAddRow ( gGrid["sexShop"] )
			dgsGridListSetItemText ( gGrid["sexShop"], row, gColumn["sexShopItem"], index, false, false )
			dgsGridListSetItemText ( gGrid["sexShop"], row, gColumn["sexShopPrice"], sexShopItemPrices[key].." $", false, false )
		end

		addEventHandler ( "onDgsMouseClickUp", gButton["sexShopBuy"],
			function ( btn )
				if btn ~= "left" then return end
				local row, column = dgsGridListGetSelectedItem ( gGrid["sexShop"] )
				if row == -1 then return end
				local item = dgsGridListGetItemText ( gGrid["sexShop"], row, gColumn["sexShopItem"] )
				if item then
					for key, index in pairs ( sexShopItems ) do
						if sexShopItems[key] == item then
							item = key
							hideSexShopGUI ()
							triggerServerEvent ( "xxxShopBuy", lp, item )
							break
						end
					end
				end
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["sexShopClose"],
			function ( btn )
				if btn ~= "left" then return end
				hideSexShopGUI ()
			end,
		false )
	end
end
addEventHandler ( "onClientMarkerHit", xxxShopMarker, xxxShopMarker_hit )

function hideSexShopGUI ()

	if isElement ( gWindow["sexShop"] ) then
		destroyElement ( gWindow["sexShop"] )
		gWindow["sexShop"] = nil
	end
	guiSetInputMode ( "allow_binds" )
	showCursor ( false )
	setElementClicked ( false )
end