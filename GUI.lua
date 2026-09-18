--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addEventHandler("onClientResourceStart",getResourceRootElement(),function()
	lrVersion = Tables.servername.." RL v."..Tables.ScriptVersion
	versionLabel=guiCreateLabel(1,1,0.3,0.3,lrVersion,true)
	guiSetSize(versionLabel,guiLabelGetTextExtent(versionLabel),guiLabelGetFontHeight(versionLabel),false)
	x,y=guiGetSize(versionLabel,true)
	guiSetPosition(versionLabel,1-x,1-y*1.8,true)
	guiSetAlpha(versionLabel,0.5)
end)

local function BlurLevel()
	setBlurLevel(0)
end	
BlurLevel()

GLOBALscreenX,GLOBALscreenY=guiGetScreenSize()
Gsx=GLOBALscreenX/1920
Gsy=GLOBALscreenY/1080


function checkResolutionOnStart ()
	local x,y = guiGetScreenSize() 
	if ( x <= 1768 ) and ( y <= 992 ) then
		outputChatBox ( "WARNING: Sie haben eine niedrige Auflösung. Einige GUI sind möglicherweise platziert oder werden falsch angezeigt." )
	end
end
addEventHandler ( "onClientResourceStart", resourceRoot, checkResolutionOnStart )