local ID = 17017

addEvent("cdn:onClientReady",true)
addEventHandler("cdn:onClientReady",resourceRoot,function()
	local txd = engineLoadTXD(":"..getResourceName(getThisResource()).."/maps/Mechaniker_Hausmod/firehouse.txd")
	engineImportTXD(txd,ID)
	local dff = engineLoadDFF(":"..getResourceName(getThisResource()).."/maps/Mechaniker_Hausmod/firehouse.dff")
	engineReplaceModel(dff,ID)
	local col = engineLoadCOL(":"..getResourceName(getThisResource()).."/maps/Mechaniker_Hausmod/firehouse.col")
	engineReplaceCOL(col,ID)
end)