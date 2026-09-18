--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local NosBottleWidth, NosBottleHeight = 75 / 2, 200 / 2
local nosX = screenwidth - 221 - NosBottleWidth - 60
local nosY = screenheight - 50 --211
local distToBottom = 45 / 200 * NosBottleHeight
local distToTop = 28 / 200 * NosBottleHeight
local fixDist = 7 / 200 * NosBottleHeight
local nosAmountToDraw = 0
local nosBottle = nil

-- Alles, was sich nie aendert, einmal beim Laden ausrechnen statt in jedem Frame:
-- Bildpfad ( sonst pro Frame eine neue String-Verkettung ), Zeichen-Y-Position und
-- die nutzbare Innenhoehe der Flasche.
local NOS_BILD        = ":"..getResourceName(getThisResource()).."/images/carsys/nos/nos.png"
local NOS_FLASCHE     = ":"..getResourceName(getThisResource()).."/images/carsys/nos/bottle.png"
local NOS_DRAW_Y      = nosY + fixDist - distToTop
local NOS_INNENHOEHE  = NosBottleHeight - distToBottom - distToTop

function nosRender ()
	local veh = getPedOccupiedVehicle ( lp )
	if not ( drawNos and veh and getVehicleUpgradeOnSlot ( veh, 8 ) ) then
		drawNos = false
		if isElement ( nosBottle ) then
			destroyElement ( nosBottle )
		end
		nosBottle = nil
		removeEventHandler ( "onClientRender", getRootElement(), nosRender )
		return
	end

	local height = NOS_INNENHOEHE / 100 * nosAmountToDraw
	dxDrawImageSection ( nosX, NOS_DRAW_Y, NosBottleWidth, -height, 1, distToTop, NosBottleWidth, height, NOS_BILD )
end

function refreshNosValues ()
	local veh = getPedOccupiedVehicle ( lp )
	-- Guard Clause statt verschachtelter ifs; getElementData kann false liefern,
	-- wenn der Schluessel nie gesetzt wurde ( frueher: Vergleich Zahl mit Boolean ).
	local nitro = veh and getPedOccupiedVehicleSeat ( lp ) == 0 and getElementData ( veh, "nitro" )
	if type ( nitro ) == "number" and nitro > 0 then
		nosAmountToDraw = nitro - ( usedNos or 0 )
		if not drawNos then
			drawNos = true
			addEventHandler ( "onClientRender", getRootElement(), nosRender )
			nosBottle = guiCreateStaticImage ( nosX, nosY - NosBottleHeight, NosBottleWidth, NosBottleHeight, NOS_FLASCHE, false )
		end
		return
	end

	drawNos = false
	if isElement ( nosBottle ) then
		destroyElement ( nosBottle )
		nosBottle = nil
		removeEventHandler ( "onClientRender", getRootElement(), nosRender )
	end
end