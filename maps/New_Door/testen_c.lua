local ID = 1491

addEvent("cdn:onClientReady",true)
addEventHandler("cdn:onClientReady",resourceRoot,function()
	local txd = engineLoadTXD(":"..getResourceName(getThisResource()).."/maps/New_Door/door.txd")
	engineImportTXD(txd,ID)
	local dff = engineLoadDFF(":"..getResourceName(getThisResource()).."/maps/New_Door/door.dff")
	engineReplaceModel(dff,ID)
end)