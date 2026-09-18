--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addEvent ( "syncMoney", true )
addEvent ( "ElementClicked", true )
addEvent ( "HungerChange", true )
addEvent ( "triggerClientElementData", true )
addEvent ( "triggerClientElementDataBatch", true )

mymoney = 0
local hunger = 60
local elementclicked = false
local elementDataClient = {}


addEventHandler ( "syncMoney", root, function ( value )
	mymoney = tonumber ( value ) 
end )


function setElementClicked ( bool )
	elementclicked = bool
	setElementData ( localPlayer, "ElementClicked", bool )
	triggerServerEvent ( "ElementClickedServer", localPlayer, bool )
end


addEventHandler ( "ElementClicked", root, function ( bool )
	elementclicked = bool
	setElementData ( localPlayer, "ElementClicked", bool )
end )


function getElementClicked ( )
	if elementclicked then return true end
	return getElementData ( localPlayer, "ElementClicked" ) == true
end


function setElementHunger ( value )
	hunger = tonumber ( value )
	if hunger > 100 then
		hunger = 100
	end
	triggerServerEvent ( "HungerChangeServer", localPlayer, value )
end


addEventHandler ( "HungerChange", root, function ( value )
	hunger = tonumber ( value ) 
	triggerServerEvent ( "HungerChangeServer", localPlayer, value )
end )


function getElementHunger ( )
	return hunger
end


function vioClientGetElementData ( dataString )
	return elementDataClient[dataString] or false
end


function vioClientSetElementData ( dataString, value )
	elementDataClient[dataString] = value
	triggerServerEvent ( "changeClientElementData", lp, dataString, value )
end


addEventHandler ( "triggerClientElementData", root, function ( dataString, value )
	elementDataClient[dataString] = value
end )


addEventHandler ( "triggerClientElementDataBatch", root, function ( dataTable )
	if type ( dataTable ) == "table" then
		for dataString, value in pairs ( dataTable ) do
			elementDataClient[dataString] = value
		end
	end
end )