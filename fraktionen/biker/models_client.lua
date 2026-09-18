--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function models()
	if not cdn:getReady() then return end
	txd = engineLoadTXD ( ":"..getResourceName(getThisResource()).."/fraktionen/biker/skins/wmycr.txd" )
	engineImportTXD ( txd, 100 )
	txd = engineLoadTXD ( ":"..getResourceName(getThisResource()).."/fraktionen/biker/skins/bikera.txd" )
	engineImportTXD ( txd, 247 )
	txd = engineLoadTXD ( ":"..getResourceName(getThisResource()).."/fraktionen/biker/skins/bikerb.txd" )
	engineImportTXD ( txd, 248 )
end