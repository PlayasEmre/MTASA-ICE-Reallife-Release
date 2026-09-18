-- ==========================================================
-- I. KONFIGURATION
-- ==========================================================
local REPO_USER = "PlayasEmre"
local REPO_NAME = "ICE-Reallife-Release"
local RES_NAME = "ICE"
local REPO_BRANCH = "main"
local LAST_COMMIT_FILE = "last_commit.txt"

local CONFIG_IGNORE_LIST = {
    ["mysql_start.lua"] = true,
    ["update.lua"] = true,
}

local DEBUG_TAG = "#FF9900["..RES_NAME.."]#FFFFFF"
local AUTO_CHECK_ENABLED = true
local AUTO_CHECK_INTERVAL_MINUTES = 60

-- ==========================================================
-- II. Globale Variablen
-- ==========================================================
local RemoteVersion = 0
local preUpdate = {}
local fileHash = {}
local UpdateCount = 0
local updateAvailable = false

-- ==========================================================
-- III. Hilfsfunktionen
-- ==========================================================
function isAdmin(player)
    if player and isElement(player) and getElementType(player) == "player" then
        return (tonumber(getElementData(player, "adminlvl")) or 0) >= 6
    end
    return false
end

local function outputChatBoxToAdmins(message)
    for _, player in ipairs(getElementsByType("player")) do
        if isAdmin(player) then outputChatBox(message, player, 255, 255, 255, true) end
    end
    outputDebugString(string.gsub(message, "#%x%x%x%x%x%x", ""))
end

local function normalize_path(p)
    return tostring(p):gsub("\\", "/"):gsub("^/+", "")
end

function createDirectoryRecursive(path)
    local parts = split(path:gsub("\\", "/"), "/")
    local current = ""
    for i, part in ipairs(parts) do
        current = current .. (i > 1 and "/" or "") .. part
        if not fileExists(current) then createDirectory(current) end
    end
end

-- ==========================================================
-- IV. Hauptlogik
-- ==========================================================
function checkUpdate(isManualCheck)
    local url = "https://api.github.com/repos/"..REPO_USER.."/"..REPO_NAME.."/commits/"..REPO_BRANCH
    fetchRemote(url, function(data, err)
        if err ~= 0 then return end
        local commitData = fromJSON(data)
        if not commitData or not commitData.sha then return end

        local currentRemoteSha = commitData.sha
        local localSha = ""
        if fileExists(LAST_COMMIT_FILE) then
            local f = fileOpen(LAST_COMMIT_FILE)
            localSha = fileRead(f, fileGetSize(f))
            fileClose(f)
        end

        if currentRemoteSha ~= localSha then
            updateAvailable = true
            outputChatBoxToAdmins(DEBUG_TAG.." #FFFF00Ein neues Update für "..RES_NAME.." wurde gefunden!")
            outputChatBoxToAdmins(DEBUG_TAG.." #FFFFFFNutze /update "..RES_NAME..", um es manuell zu installieren.")
        else
            updateAvailable = false
            if isManualCheck then
                outputChatBoxToAdmins(DEBUG_TAG.." #00FF00Alles auf dem neuesten Stand.")
            end
        end
    end)
end

function startUpdate()
    local url = "https://raw.githubusercontent.com/"..REPO_USER.."/"..REPO_NAME.."/"..REPO_BRANCH.."/meta.xml"
    fetchRemote(url, function(data, err)
        if err == 0 then
            if not fileExists("updated") then createDirectory("updated") end
            local meta = fileCreate("updated/meta.xml")
            fileWrite(meta, data)
            fileClose(meta)
            getGitHubTree()
        end
    end)
end

function getGitHubTree()
    local url = "https://api.github.com/repos/"..REPO_USER.."/"..REPO_NAME.."/git/trees/"..REPO_BRANCH.."?recursive=1"
    fetchRemote(url, function(data, err)
        if err == 0 then
            local tree = fromJSON(data)
            if not tree or not tree.tree then return end
            fileHash = {}
            for _, v in pairs(tree.tree) do
                if v.type == "blob" then fileHash[normalize_path(v.path)] = v.sha end
            end
            checkFiles()
        end
    end)
end

function checkFiles()
    local xml = xmlLoadFile("updated/meta.xml")
    if not xml then return end
    preUpdate = {}

    for _, node in ipairs(xmlNodeGetChildren(xml)) do
        local nodeName = xmlNodeGetName(node)
        if nodeName == "script" or nodeName == "file" then
            local path = xmlNodeGetAttribute(node, "src")
            local cleanPath = normalize_path(path)
            local fileName = cleanPath:match("([^/]+)$")

            if CONFIG_IGNORE_LIST[cleanPath] or CONFIG_IGNORE_LIST[fileName] then
                outputChatBoxToAdmins(DEBUG_TAG.." #FFFF00[INFO] Ignoriere geschützte Datei: #FFFFFF"..fileName)
            else
                local sha = ""
                if fileExists(path) then
                    local file = fileOpen(path)
                    local text = fileRead(file, fileGetSize(file))
                    fileClose(file)
                    text = string.gsub(text, "\r\n", "\n")
                    sha = hash("sha1", "blob " .. #text .. "\0" .. text)
                end

                if fileHash[cleanPath] and sha ~= fileHash[cleanPath] then
                    table.insert(preUpdate, path)
                end
            end
        end
    end
    xmlUnloadFile(xml)

    if #preUpdate > 0 then
        UpdateCount = 0
        DownloadFiles()
    else
        DownloadFinish()
    end
end

function DownloadFiles()
    UpdateCount = UpdateCount + 1
    if not preUpdate[UpdateCount] then DownloadFinish() return end

    local path = preUpdate[UpdateCount]
    local url = "https://raw.githubusercontent.com/"..REPO_USER.."/"..REPO_NAME.."/"..REPO_BRANCH.."/"..normalize_path(path)

    outputChatBoxToAdmins(DEBUG_TAG.." #AAAAAALade Datei ("..UpdateCount.."/"..#preUpdate.."): #FFFFFF"..path)

    fetchRemote(url, function(data, err)
        if err == 0 then
            if fileExists(path) then fileDelete(path) end
            local folder = string.match(path, "^(.-)/[^/]+$")
            if folder then createDirectoryRecursive(folder) end
            local file = fileCreate(path)
            fileWrite(file, data)
            fileClose(file)
        end
        DownloadFiles()
    end)
end

function DownloadFinish()
    -- Aktualisiere den SHA nach erfolgreichem Download
    local url = "https://api.github.com/repos/"..REPO_USER.."/"..REPO_NAME.."/commits/"..REPO_BRANCH
    fetchRemote(url, function(data)
        local commitData = fromJSON(data)
        if commitData and commitData.sha then
            local f = fileCreate(LAST_COMMIT_FILE)
            fileWrite(f, commitData.sha)
            fileClose(f)
        end

        if fileExists("meta.xml") then fileDelete("meta.xml") end
        if fileExists("updated/meta.xml") then fileRename("updated/meta.xml", "meta.xml") end

        outputChatBox(DEBUG_TAG.." #00FF00Update erfolgreich! Neustart in 3s...", root, 255, 255, 255, true)
        setTimer(function() restartResource(getThisResource()) end, 3000, 1)
    end)
end

-- ==========================================================
-- V. Events & Timer
-- ==========================================================
if AUTO_CHECK_ENABLED then
    setTimer(function()
        if updateAvailable then
            outputChatBoxToAdmins(DEBUG_TAG.." #FF9900Erinnerung: Ein Update steht noch aus! (/update "..RES_NAME..")")
        else
            checkUpdate(false)
        end
    end, AUTO_CHECK_INTERVAL_MINUTES * 60000, 0)
end

addCommandHandler("update", function(player, cmd, target)
    if isAdmin(player) then
        if target == RES_NAME then
            if updateAvailable then
                outputChatBoxToAdmins(DEBUG_TAG.." #FFFF00Starte manuellen Update-Prozess...")
                startUpdate()
            else
                outputChatBox(DEBUG_TAG.." #FF0000Es ist aktuell kein Update verfügbar.", player, 255, 255, 255, true)
            end
        else
            outputChatBox("Nutze /update "..RES_NAME, player, 255, 255, 255)
        end
    end
end)
