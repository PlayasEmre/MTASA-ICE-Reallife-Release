--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local phonesound = nil


function achievsound_func ()

	local sound = playSound (":"..getResourceName(getThisResource()).."/sounds/reached.mp3", false)
	setSoundVolume ( sound, 0.15 )
end
addEvent ( "achievsound", true )
addEventHandler ( "achievsound", getRootElement(), achievsound_func )

function mousesound_func ()
	local sound = playSound (":"..getResourceName(getThisResource()).."/sounds/mouseclick.wav", false)
	setSoundVolume ( sound, 1 )
end

function phonesound_func ()
	if isElement ( phonesound ) then
		stopSound ( phonesound )
	end
	phonesound = playSound (":"..getResourceName(getThisResource()).."/sounds/ringtone.mp3", true)
	setSoundVolume ( phonesound, .5 )
end
addEvent ( "phonesound", true )
addEventHandler ( "phonesound", getRootElement(), phonesound_func )


function phonebesetzt_func ()
	if isElement ( phonesound ) then
		stopSound ( phonesound )
	end
	phonesound = playSound (":"..getResourceName(getThisResource()).."/sounds/besetzt.mp3", false)
	setSoundVolume ( phonesound, .3 )
end
addEvent ( "phonebesetzt", true )
addEventHandler ( "phonebesetzt", getRootElement(), phonebesetzt_func )


function phonekeinanschluss_func ()
	if isElement ( phonesound ) then
		stopSound ( phonesound )
	end
	phonesound = playSound (":"..getResourceName(getThisResource()).."/sounds/keinanschluss.mp3", false)
	setSoundVolume ( phonesound, .3 )
end
addEvent ( "phonekeinanschluss", true )
addEventHandler ( "phonekeinanschluss", getRootElement(), phonekeinanschluss_func )


function phonesms_func ()

	local sound = playSound (":"..getResourceName(getThisResource()).."/sounds/sms.mp3", false)
	setSoundVolume ( sound, .3 )
end
addEvent ( "phonesms", true )
addEventHandler ( "phonesms", getRootElement(), phonesms_func )


function phonewartezeichen_func ()
	if isElement ( phonesound ) then
		stopSound ( phonesound )
	end
	phonesound = playSound (":"..getResourceName(getThisResource()).."/sounds/wartezeichen.mp3", true)
	setSoundVolume ( phonesound, .5 )
end
addEvent ( "phonewartezeichen", true )
addEventHandler ( "phonewartezeichen", getRootElement(), phonewartezeichen_func )


function stopphonesound_func ()
	if isElement ( phonesound ) then
		stopSound ( phonesound )
	end
end
addEvent ( "stopphonesound", true )
addEventHandler ( "stopphonesound", getRootElement(), stopphonesound_func )


function sprunksound_func ()

	local sound = playSound (":"..getResourceName(getThisResource()).."/sounds/sprunk.ogg", false)
	setSoundVolume ( sound, .3 )
end
addEvent ( "sprunksound", true )
addEventHandler ( "sprunksound", getRootElement(), sprunksound_func )

function highnoonsound_func ( rnd )

	local sound = playSound (":"..getResourceName(getThisResource()).."/sounds/highnoon.ogg", false)
	setSoundVolume ( sound, 1 )
	setTimer ( bellsound_func, rnd*1000, 1, sound )
end
addEvent ( "highnoonsound", true )
addEventHandler ( "highnoonsound", getRootElement(), highnoonsound_func )

function bellsound_func ( sound )

	stopSound ( sound )
	local sound = playSound (":"..getResourceName(getThisResource()).."/sounds/bell.ogg", false)
	setSoundVolume ( sound, 1 )
end
addEvent ( "bellsound", true )
addEventHandler ( "bellsound", getRootElement(), bellsound_func )


function katjuschasound_func ( rockets, timeBetween, x, y, z )

	local sound = playSound3D (":"..getResourceName(getThisResource()).."/sounds/katjuscha.wav", x, y, z, false)
	setSoundVolume ( sound, 1 )
	setTimer ( katjuschaPlaySound, timeBetween, rockets, x, y, z )
end
addEvent ( "katjuschasound", true )
addEventHandler ( "katjuschasound", getRootElement(), katjuschasound_func )

function katjuschaPlaySound ( x, y, z)

	local sound = playSound3D (":"..getResourceName(getThisResource()).."/sounds/katjuscha.wav", x, y, z, false)
	setSoundVolume ( sound, 1 )
end

function locksound_func ()

	local sound = playSound (":"..getResourceName(getThisResource()).."/sounds/carlock.mp3", false)
	setSoundVolume ( sound, 1.0 )
end
addEvent ( "locksound", true )
addEventHandler ( "locksound", getRootElement(), locksound_func )

function lightound_sound_func ()

	local sound = playSound (":"..getResourceName(getThisResource()).."/sounds/Licht_an.mp3", false)
	setSoundVolume ( sound, 1.0 )
end
addEvent ( "lightsound", true )
addEventHandler ( "lightsound", getRootElement(), lightound_sound_func )

function lightound1_sound_func ()

	local sound = playSound (":"..getResourceName(getThisResource()).."/sounds/Licht_aus.mp3", false)
	setSoundVolume ( sound, 1.0 )
end
addEvent ( "lightsound1", true )
addEventHandler ( "lightsound1", getRootElement(), lightound1_sound_func )

function motorsound_func ()
	local mototsound = playSound (":"..getResourceName(getThisResource()).."/sounds/Motor-start.mp3", false)
	if mototsound then
		setSoundVolume ( mototsound, 1.0 )
	end
end
addEvent ( "motorsound", true )
addEventHandler ( "motorsound", getRootElement(), motorsound_func )

function motorstopsound_func ()
	local sound = playSound (":"..getResourceName(getThisResource()).."/sounds/Motor-stop.mp3", false)
	if sound then
		setSoundVolume ( sound, 1.0 )
	end
end
addEvent ( "motorrsound", true )
addEventHandler ( "motorrsound", getRootElement(), motorstopsound_func )

function motorsound_func1 ()

	local Motor_Bikes = playSound (":"..getResourceName(getThisResource()).."/sounds/Motor_Bike.ogg", false)
	if Motor_Bikes then
		setSoundVolume ( Motor_Bikes, 1.0 )
	end
end
addEvent ( "Motor_Bike", true )
addEventHandler ( "Motor_Bike", getRootElement(), motorsound_func1 )


function speaksound1 (player,x,y,z)
   if(x)and(y)and(z)then
    sound = playSound3D (":"..getResourceName(getThisResource()).."/fun/Polizeiansagen/ansage.mp3", x, y, z)
	setSoundMaxDistance( sound, 100 )
	attachElements(sound,player)
  end
end
addEvent ( "speak1", true )
addEventHandler ( "speak1", getRootElement(), speaksound1 )

function speaksound2 (player,x,y,z)
	if(x)and(y)and(z)then
		sound = playSound3D (":"..getResourceName(getThisResource()).."/fun/Polizeiansagen/vkk.wav", x, y, z)
		setSoundMaxDistance( sound, 100 )
		attachElements(sound,player)
	end
end
addEvent ( "speak2", true )
addEventHandler ( "speak2", getRootElement(), speaksound2 )

function speaksound3 (player,x,y,z)
    if(x)and(y)and(z)then
    sound = playSound3D (":"..getResourceName(getThisResource()).."/fun/Polizeiansagen/gesucht.wav", x, y, z)
	setSoundMaxDistance( sound, 100 )
	attachElements(sound,player)
  end
end
addEvent ( "speak3", true )
addEventHandler ( "speak3", getRootElement(), speaksound3 )



function speaksound4 (player,x,y,z)
    if(x)and(y)and(z)then
    sound = playSound3D (":"..getResourceName(getThisResource()).."/fun/Polizeiansagen/vkk2.mp3", x, y, z)
	setSoundMaxDistance( sound, 100 )
	attachElements(sound,player)
  end
end
addEvent ( "speak4", true )
addEventHandler ( "speak4", getRootElement(), speaksound4 )

function speaksound5 (player,x,y,z)
    if(x)and(y)and(z)then
    sound = playSound3D (":"..getResourceName(getThisResource()).."/fun/Polizeiansagen/SAPDVKK.mp3", x, y, z)
	setSoundMaxDistance( sound, 100 )
	attachElements(sound,player)
  end
end
addEvent ( "speak5", true )
addEventHandler ( "speak5", getRootElement(), speaksound5 )


addEvent("cdn:onClientReady",true)
addEventHandler("cdn:onClientReady",resourceRoot,function()
	txd = engineLoadTXD ( ":"..getResourceName(getThisResource()).."/images/raindanc.txd" )
	engineImportTXD ( txd, 563 )
end)