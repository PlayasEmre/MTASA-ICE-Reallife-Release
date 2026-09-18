--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addEvent("cdn:onClientReady",true)
addEventHandler("cdn:onClientReady",resourceRoot,function()
	local shader_blbd = dxCreateShader(":"..getResourceName(getThisResource()).."/banner/shader.fx")
	local img_blbd = dxCreateTexture(":"..getResourceName(getThisResource()).."/banner/img.jpg")
	dxSetShaderValue(shader_blbd, "Tex0", img_blbd)
	engineApplyShaderToWorldTexture( shader_blbd, "homies_*")
	engineApplyShaderToWorldTexture( shader_blbd, "bobo_2")
	createObject ( 4729, -1989.400390625,75.900390625,45.5,0,0.4998779296875,109.99514770508)
end)