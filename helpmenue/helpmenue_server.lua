--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--\\                                                  //

-- Speichert die im Hilfe-Menü ("Webinterface"-Reiter) gesetzte Domain in einer
-- Datei, damit sie einen Ressourcen-/Serverneustart übersteht.

local webInterfacePath = "helpmenue/webinterface.txt"

local function loadWebInterfaceURL()
	if not fileExists(webInterfacePath) then return "" end
	local f = fileOpen(webInterfacePath, true)
	if not f then return "" end
	local url = fileRead(f, fileGetSize(f))
	fileClose(f)
	return url or ""
end

local function saveWebInterfaceURL(url)
	if fileExists(webInterfacePath) then
		fileDelete(webInterfacePath)
	end
	local f = fileCreate(webInterfacePath)
	if f then
		fileWrite(f, url)
		fileClose(f)
	end
end

WebInterfaceURL = loadWebInterfaceURL()

addEvent("helpmenue:requestWebInterface", true)
addEventHandler("helpmenue:requestWebInterface", root, function()
	if isElement(client) then
		triggerClientEvent(client, "helpmenue:webInterfaceSync", client, WebInterfaceURL)
	end
end)

addEvent("helpmenue:setWebInterface", true)
addEventHandler("helpmenue:setWebInterface", root,
	function(url)
		local player = client
		if tonumber(MtxGetElementData(player, "adminlvl")) ~= 6 then
			outputChatBox("Dazu bist du nicht berechtigt!", player, 125, 0, 0)
			return
		end

		url = tostring(url or "")
		url = url:gsub("^%s+", ""):gsub("%s+$", "")
		if #url > 150 then
			url = url:sub(1, 150)
		end

		WebInterfaceURL = url
		saveWebInterfaceURL(url)
		triggerClientEvent(root, "helpmenue:webInterfaceSync", root, WebInterfaceURL)
		outputChatBox("Webinterface-Domain wurde aktualisiert: "..(WebInterfaceURL ~= "" and WebInterfaceURL or "(leer)"), player, 0, 150, 0)
	end
)
