--//                                              \\--
--||   Developers: Lars                           ||--
--||   2019 - All rights reserved.                ||--
--\\                                              //--

cdn = {}
local s,w = guiGetScreenSize()

function cdn.new()
    local self = setmetatable({},{__index=cdn})
    self.m_Counter = 0
    self.m_Max = 0
    self.m_Content = {}
    self.m_Ready = false
		
    addEvent("cdn:receiveContent",true)
    addEvent("cdn:receiveFile",true)
    addEvent("cdn:onClientReady",true)
    addEventHandler("cdn:receiveContent",root,function(...)self:receiveContent(...)end)
    addEventHandler("cdn:receiveFile",root,function(...)self:receiveFile(...)end)
    self.m_fRender=function(...)self:renderMain(...)end
    self.m_ScreenX,self.m_ScreenY =guiGetScreenSize()
    self.m_Width,self.m_Heigth = 320,40
    triggerServerEvent("cdn:requireContent",lp)
    return self
end

function cdn:receiveContent(list)
    local demanded = {}
    for _,v in pairs(list)do
        if fileExists(v[1])then
            local file = fileOpen(v[1],true)
            if (file) then
                if (md5(fileRead(file,fileGetSize(file))) ~= v[2]) then
                    self.m_Max = self.m_Max +1
                    demanded[self.m_Max] = v[1]
                end
                fileClose(file)
            end
        else
            self.m_Max = self.m_Max+1
            demanded[self.m_Max] = v[1]
        end
    end

    if self.m_Max > 0 then
        self.m_Content = demanded
        addEventHandler("onClientRender",root,self.m_fRender)
		downloadMusic = playSound(":"..getResourceName(getThisResource()).."/sounds/Downloading.mp3",true)
		setSoundVolume(downloadMusic,0.2)
		setElementData(localPlayer, "inDownload", true)
        triggerServerEvent("cdn:requireFiles",lp,self.m_Content)
    else
        self:setReady()
    end
end

function cdn:receiveFile(data,path,counter)
    local file = fileCreate(path)
    if (file) then
        fileWrite(file,data)
        fileClose(file)
        self.m_Counter = counter
        if( self.m_Counter == self.m_Max )then
            self:setReady()
        else
            triggerServerEvent("cdn:requestNextFile",lp,lp)
        end
    end
end

function cdn:setReady()
    triggerEvent("cdn:onClientReady",root,resourceRoot)
    removeEventHandler("onClientRender",root,self.m_fRender)
    self.m_Ready = true
	showChat(true)
	if isElement(downloadMusic) then
		destroyElement(downloadMusic)
	end	
	setElementData(localPlayer, "inDownload", false)
end

function cdn:getReady()
    return self.m_Ready
end

function cdn:renderMain()
	if ( self.m_Counter > 0 ) then
		showChat(false)
		fadeCamera(true)
		setElementDimension(lp,0)
		setElementInterior(lp,0)
		dxDrawImage(0, 0, s, w, ":"..getResourceName(getThisResource()).."/custom-downloader/test.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
		dxDrawRectangle(780*Gsx,460*Gsy,360*Gsx,240*Gsy,guibgcolor,false)
		dxDrawRectangle(780*Gsx,460*Gsy,360*Gsx,20*Gsy,guimaincolor,false)
		dxDrawImage(780*Gsx,480*Gsy,360*Gsx,2*Gsy,":"..getResourceName(getThisResource()).."/custom-downloader/White.png",0,0,0,guilinecolor,false)
		dxDrawText("Downloading files...",1730*Gsx,460.5*Gsy,200*Gsx,20*Gsy,tocolor(255,255,255,255),1.00*Gsx,"arial","center",_,_,_,false,_,_)	
		dxDrawText("Willkommen auf "..Tables.servername.." Reallife.\nEine neue Generation unter Deutschen Reallife Servern",790*Gsx,490*Gsy,200*Gsx,20*Gsy,tocolor(255,255,255,255),1.10*Gsx,"default-bold","left",_,_,_,false,_,_)
		dxDrawText(self.m_Counter.."/"..self.m_Max.."",790*Gsx,640*Gsy,200*Gsx,20*Gsy,tocolor(255,255,255,255),1.00*Gsx,"arial","left",_,_,_,false,_,_)
		dxDrawRectangle(785*Gsx,665*Gsy,350*Gsx,30*Gsy,tocolor(0,0,0,140),false)
		dxDrawRectangle(785*Gsx,665*Gsy,self.m_Counter*350/self.m_Max*Gsx,30*Gsy,tocolor(150,0,0,140),false)
	end
end

addEventHandler("onClientResourceStart",resourceRoot,function()
    _G["cdn"]=cdn.new()
end)