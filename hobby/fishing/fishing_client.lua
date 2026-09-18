--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

fishNames = {
 [1]="Schildkroete",
 [2]="Stiefel",
 [3]="Lachs",
 [4]="Forelle",
 [5]="Schnapper",
 [6]="Hai",
 [7]="Geldbeutel",
 [8]="Barsch",
 [9]="Schwertfisch",
 [10]="Rochen",
 [11]="Aal",
 [12]="Thunfisch"
}

local fishBiten = false
local fishingImage
local fishingTimer

function beginFishing ()

	if vioClientGetElementData ( "fishingPole" ) and vioClientGetElementData ( "fishingHooks" ) > 0 and vioClientGetElementData ( "fishingWorms" ) > 0 then
		if not vioClientGetElementData ( "anim" ) or vioClientGetElementData ( "anim" ) == 0 then
			if isPedOnGround ( lp ) then
				setElementFrozen ( lp, true )
				guiSetInputMode ( "no_binds_when_editing" )
				showCursor ( true )
				setElementClicked ( true )
				addEventHandler ( "onClientClick", getRootElement(), fishClick )
			else
				infobox_start_func ( "Nur auf dem Boden erlaubt!", 5000, 125, 0, 0 )
			end
		else
			infobox_start_func ( "Beende vorher\ndie Animation!", 5000, 125, 0, 0 )
		end
	else
		infobox_start_func ( "Du brauchst eine\nAngel, Haken und\nWuermer!", 5000, 125, 0, 0 )
	end
end
addCommandHandler ( "fish", beginFishing )

function fishClick ( btn, state, _, _, wx, wy, wz, element )

	setElementFrozen ( lp, false )
	removeEventHandler ( "onClientClick", getRootElement(), fishClick )
	if not element then
		local pX, pY, pZ = getElementPosition ( lp )
		local bool, wX, wY, wZ = testLineAgainstWater ( pX, pY, pZ + 100, wx, wy, wz )
		if bool then
			local x1, y1, z1 = getElementPosition ( lp )
			local x2, y2, z2 = wx, wy, wz
			local nX = x2 - ( ( x1 - x2 ) / ( z1 - z2 ) ) * ( z2 )
			local nY = y2 - ( ( y1 - y2 ) / ( z1 - z2 ) ) * ( z2 )

			local dist = getDistanceBetweenPoints2D ( x1, y1, nX, nY )

			if dist <= 35 then
				setPedRotation ( lp, findRotation ( x1, y1, nX, nY ) )
				setPedAnimation ( lp, "SWORD", "sword_3", -1, false, false, false, true )
				startFishing ()
				return nil
			end
		end
	end
	guiSetInputMode ( "allow_binds" )
	showCursor ( false )
	setElementClicked ( false )
	outputChatBox ( "Du musst deine Angel in Wasser in deiner Naehe werfen!", 125, 0, 0 )
end

function startFishing ()

	fishBiten = false

	bindKey ( "mouse1", "down", leftMouseFishing )

	fishingImage = dgsCreateImage ( screenwidth/2-100/2, 0, 100, 100, ":"..getResourceName(getThisResource()).."/images/skills/fishing/top.png", false )

	local rnd = math.random ( 1000, 20000 )
	local time = ( 3000 + rnd )
	fishingTimer = setTimer (
		function ()
			fishBiten = true
			destroyElement ( fishingImage )
			fishingImage = dgsCreateImage ( screenwidth/2-100/2, 0, 100, 100, ":"..getResourceName(getThisResource()).."/images/skills/fishing/down.png", false )
			fishingTimer = setTimer (
				function ()
					destroyElement ( fishingImage )
					unbindKey ( "mouse1", "down", leftMouseFishing )
					startFishing ()
				end,
			200 + math.random ( 50, 500 ), 1 )
		end,
	time, 1 )
end

function leftMouseFishing ()

	destroyElement ( fishingImage )
	if isTimer ( fishingTimer ) then
		killTimer ( fishingTimer )
	end
	unbindKey ( "mouse1", "down", leftMouseFishing )

	setPedAnimation ( lp, nil, nil )

	guiSetInputMode ( "allow_binds" )
	showCursor ( false )
	setElementClicked ( false )

	if fishBiten then
		triggerServerEvent ( "fishCought", lp )
	else
		outputChatBox ( "Leider nichts erwischt.", 125, 0, 0 )
	end
end

-- Fishing Shop --
fishingShop = createMarker ( -1353.87, 2057.60, 52.04, "cylinder", 1, 255, 0, 0, 150,false, getRootElement() )

function fishingShop_hit ( player, dim )

	if player == lp and dim and not getPedOccupiedVehicle ( player ) then
		if isElement ( gWindow["fishingShop"] ) then
			return
		end

		guiSetInputMode ( "no_binds_when_editing" )
		showCursor ( true )
		setElementClicked ( true )

		local hooks = vioClientGetElementData ( "fishingHooks" )
		local worms = vioClientGetElementData ( "fishingWorms" )
		local maxWormHooks = 5 + math.floor ( calcFishingSkillLevel ( lp ) ^ ( 1.1 ) * 5 )

		gWindow["fishingShop"] = dgsCreateWindow(screenwidth/2-398/2,screenheight/2-250/2,398,250,"Angelshop",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
		dgsWindowSetSizable ( gWindow["fishingShop"], false )
		dgsWindowSetMovable ( gWindow["fishingShop"], false )
		dgsBringToFront ( gWindow["fishingShop"] )
		dgsSetProperty ( gWindow["fishingShop"], "image", false )

		gButton["fishShopBuyPole"] = dgsCreateButton(10,29,109,48,"Angel\n\n",false,gWindow["fishingShop"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetFont(gButton["fishShopBuyPole"],"default-bold")
		gLabel[1] = dgsCreateLabel(40,29,32,14,fishingPolePrice.." $",false,gButton["fishShopBuyPole"])
		dgsLabelSetColor(gLabel[1],0,200,0)
		dgsLabelSetVerticalAlign(gLabel[1],"top")
		dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
		dgsSetFont(gLabel[1],"default-bold")
		dgsSetEnabled(gLabel[1], false)

		gButton["fishShopBuyHooks"] = dgsCreateButton(10,86,109,48,"Haken\n("..hooks.."/"..maxWormHooks..")\n",false,gWindow["fishingShop"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetFont(gButton["fishShopBuyHooks"],"default-bold")
		gLabel["fishHooksPrice"] = dgsCreateLabel(40,29,32,14,fishingHookPrice.." $",false,gButton["fishShopBuyHooks"])
		dgsLabelSetColor(gLabel["fishHooksPrice"],0,200,0)
		dgsLabelSetVerticalAlign(gLabel["fishHooksPrice"],"top")
		dgsLabelSetHorizontalAlign(gLabel["fishHooksPrice"],"left",false)
		dgsSetFont(gLabel["fishHooksPrice"],"default-bold")
		dgsSetEnabled(gLabel["fishHooksPrice"], false)

		gButton["fishShopBuyWorms"] = dgsCreateButton(10,143,109,48,"Koeder\n("..worms.."/"..maxWormHooks..")\n",false,gWindow["fishingShop"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetFont(gButton["fishShopBuyWorms"],"default-bold")
		gLabel["fishWormsPrice"] = dgsCreateLabel(40,29,32,14,fishingWormPrice.." $",false,gButton["fishShopBuyWorms"])
		dgsLabelSetColor(gLabel["fishWormsPrice"],0,200,0)
		dgsLabelSetVerticalAlign(gLabel["fishWormsPrice"],"top")
		dgsLabelSetHorizontalAlign(gLabel["fishWormsPrice"],"left",false)
		dgsSetFont(gLabel["fishWormsPrice"],"default-bold")
		dgsSetEnabled(gLabel["fishWormsPrice"], false)

		addEventHandler ( "onDgsMouseClickUp", gButton["fishShopBuyWorms"],
			function (btn)
				if btn ~= "left" then return end
				local amount = tonumber ( dgsGetText ( gMemo["fishingCount"] ) )
				triggerServerEvent ( "fishShopBuy", lp, "worms", amount )
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["fishShopBuyHooks"],
			function (btn)
				if btn ~= "left" then return end
				local amount = tonumber ( dgsGetText ( gMemo["fishingCount"] ) )
				triggerServerEvent ( "fishShopBuy", lp, "hooks", amount )
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["fishShopBuyPole"],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "fishShopBuy", lp, "pole", 1 )
			end,
		false )

		gLabel["fishInfo1"] = dgsCreateLabel(130,23,188,58,"Mit einer Angel kannst du - je\nnach Talent und Skill-LVL -\nverschiedene Fische fangen,\nverkaufen und bald auch kochen.",false,gWindow["fishingShop"])
		dgsLabelSetColor(gLabel["fishInfo1"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["fishInfo1"],"top")
		dgsLabelSetHorizontalAlign(gLabel["fishInfo1"],"left",false)
		dgsSetFont(gLabel["fishInfo1"],"default-bold")
		gImage[1] = dgsCreateImage(332,29+57*0,50,50,":"..getResourceName(getThisResource()).."/images/inventory/fishing/pole.png",false,gWindow["fishingShop"])

		gLabel["fishInfo2"] = dgsCreateLabel(130,143,171,48,"Zum Angeln brauchst du\nnicht nur eine Angel, sondern\nauch Koeder und Haken",false,gWindow["fishingShop"])
		dgsLabelSetColor(gLabel["fishInfo2"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["fishInfo2"],"top")
		dgsLabelSetHorizontalAlign(gLabel["fishInfo2"],"left",false)
		dgsSetFont(gLabel["fishInfo2"],"default-bold")
		-- guiCreateNumberField hat kein direktes DGS-Aequivalent: dgsCreateEdit
		-- + Validierung im Change-Handler bildet die Zahlenbeschraenkung nach.
		gMemo["fishingCount"] = dgsCreateEdit ( 163, 105, 74, 31, "0", false, gWindow["fishingShop"] )
		addEventHandler ( "onDgsChanged", gMemo["fishingCount"],
			function ()
				local text = dgsGetText ( gMemo["fishingCount"] )
				local num = tonumber ( ( text:gsub ( "%D", "" ) ) )
				dgsSetText ( gMemo["fishingCount"], tostring ( num or 0 ) )
			end,
		false )
		gImage[2] = dgsCreateImage(332,29+57*1,50,50,":"..getResourceName(getThisResource()).."/images/inventory/fishing/hook.png",false,gWindow["fishingShop"])

		gLabel[4] = dgsCreateLabel(177,88,43,17,"Anzahl:",false,gWindow["fishingShop"])
		dgsLabelSetColor(gLabel[4],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[4],"top")
		dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
		dgsSetFont(gLabel[4],"default-bold")
		gImage[3] = dgsCreateImage(332,29+57*2,50,50,":"..getResourceName(getThisResource()).."/images/inventory/fishing/worm.png",false,gWindow["fishingShop"])

		gButton["fishShopClose"] = dgsCreateButton(398/2-78/2,195,78,32,"Schliessen",false,gWindow["fishingShop"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["fishShopClose"],
			function (btn)
				if btn ~= "left" then return end
				guiSetInputMode ( "allow_binds" )
				showCursor ( false )
				setElementClicked ( false )
				destroyElement ( gWindow["fishingShop"] )
				gWindow["fishingShop"] = nil
			end,
		false )
	end
end
addEventHandler ( "onClientMarkerHit", fishingShop, fishingShop_hit )

function reOpenFishingShopGUI_func ()

	if isElement ( gWindow["fishingShop"] ) then
		destroyElement ( gWindow["fishingShop"] )
	end
	gWindow["fishingShop"] = nil
	fishingShop_hit ( lp, true )
end
addEvent ( "reOpenFishingShopGUI", true )
addEventHandler ( "reOpenFishingShopGUI", getRootElement(), reOpenFishingShopGUI_func )
