--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //
  
function replaceModel()
   local col = engineLoadCOL ( ":"..getResourceName(getThisResource()).."/SF/data/hubprops6_SFSe.col" )
   engineReplaceCOL ( col, 11391 )
   local col = engineLoadCOL ( ":"..getResourceName(getThisResource()).."/SF/data/hubprops1_SFS.col")
   engineReplaceCOL ( col, 11393 )
   local txd = engineLoadTXD ( ":"..getResourceName(getThisResource()).."/SF/data/oldgarage_sfse.txd")
   engineImportTXD ( txd, 11387 )
end

addEvent("cdn:onClientReady",true)
addEventHandler("cdn:onClientReady",resourceRoot,function()
	replaceModel()
	setTimer(replaceModel,1000,1)
end)