--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local screenW, screenH = guiGetScreenSize()

-- TO DO | KOORDINATEN --
local greenzones = { 
	[1] = { x = -2016.5999755859, y = 78.300003051758, width = 102.5, height = 160.1 },
	[2] = { x = -2060.9541015625, y = 383.71136474609, width = 50.5, height = 140.1 }
}
local colCuboids = {}

addEventHandler ("onClientResourceStart", resourceRoot, function()
    for i=1, #greenzones do
        createRadarArea ( greenzones[i].x, greenzones[i].y, greenzones[i].width, greenzones[i].height, 0, 255, 0, 127, localPlayer )
        colCuboids[i] = createColCuboid ( greenzones[i].x, greenzones[i].y, -50, greenzones[i].width, greenzones[i].height, 7500)
        setElementID (colCuboids[i], "greenzoneColshape")
        addEventHandler ( "onClientColShapeHit", colCuboids[i], startGreenZone )
        addEventHandler ( "onClientColShapeLeave", colCuboids[i], stopGreenZone )
    end
end )

-- Pfad einmal beim Laden bauen statt in jedem Frame ( erzeugte sonst pro Frame
-- eine neue Zeichenkette ). Farbe ebenfalls vorberechnet.
local NODM_BILD  = ":"..getResourceName(getThisResource()).."/environment/greenzone/ICE-NO-DM.png"
local NODM_FARBE = tocolor(254, 253, 253, 200)

function DrawNodmImage ()
	dxDrawImage(1694, 327, 226, 107, NODM_BILD, 0, 0, 0, NODM_FARBE, false)
end

function startGreenZone (hitElement, matchingDimension)
    if hitElement == localPlayer and matchingDimension then
		if isControlEnabled("next_weapon") or isControlEnabled("previous_weapon") or isControlEnabled("fire") or isControlEnabled("aim_weapon") then
			toggleControl("next_weapon",false)
			toggleControl("previous_weapon",false)
			toggleControl("fire",false)
			toggleControl("aim_weapon",false)
			vioClientSetElementData ( "nodmzone", 1 )
			setPedWeaponSlot ( hitElement, 0 )
			addEventHandler("onClientRender", root, DrawNodmImage)
		end
	end
end

function stopGreenZone (leaveElement, matchingDimension)
	if leaveElement == localPlayer and matchingDimension then
		removeEventHandler("onClientRender", root, DrawNodmImage)
		toggleControl("next_weapon",true)
		toggleControl("previous_weapon",true)
		toggleControl("fire",true)
		toggleControl("aim_weapon",true)
		vioClientSetElementData ( "nodmzone", 0 )
	end
end

addEventHandler ( "onClientPlayerSpawn", localPlayer, function ( )
	for i=1, #colCuboids do
		if isElementWithinColShape ( source, colCuboids[i] ) then
			startGreenZone ( source, true )
		end
	end
end )


addEventHandler ( "onClientVehicleExit", localPlayer, function ( )
	setPedWeaponSlot ( localPlayer, 0 )
end )

addEventHandler ( "onClientPlayerDamage", localPlayer, function ( )
	if vioClientGetElementData("nodmzone") == 1 then
		cancelEvent()
	end	
end )
