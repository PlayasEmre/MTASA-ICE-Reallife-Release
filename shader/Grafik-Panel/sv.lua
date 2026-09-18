
--------------------------------------------------------
-----------------------Game Light-----------------------
-------- Discord https://discord.gg/HFwHnGguun ---------
--------------------------------------------------------

addEventHandler("onPlayerJoin",root,function ()
	data = getElementData(source,"settingGrafickPatch")
	if data then
		triggerClientEvent(source,"setSettingGraphis",source,data)
	end
end)


addEventHandler("onPlayerQuit",root,function ()
	road = getElementData(source,"Settinghdroad") or true
	water = getElementData(source,"Settinghdwater") or true
	aero = getElementData(source,"Settinghdaero") or true
	reflect = getElementData(source,"Settinghdreflect") or true
	dist = getElementData(source,"SettingClipDistance") or 250

	local playerProps = getElementData(source, "settingGrafickPatch")
	playerProps = (playerProps) and fromJSON(playerProps) or {}
	playerProps.road = road
	playerProps.water = water
	playerProps.aero = aero
	playerProps.reflect = reflect
	playerProps.dist = dist

	setElementData(source, "settingGrafickPatch", toJSON(playerProps, true))

end)

--------------------------------------------------------
-----------------------Game Light-----------------------
-------- Discord https://discord.gg/HFwHnGguun ---------
--------------------------------------------------------