--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //
local dgsOk, dgsErr = pcall(function()
	loadstring(exports.DGS:dgsImportFunction())()
end)

gButton = {}
gLabel = {}

function SubmitAmmunationGunshopAbbrechenBtn (btn)

	if btn == "left" then
		dgsSetVisible ( WaffenauswahlGunshopFenster, false )
		showCursor ( false )
		guiSetInputMode ( "allow_binds" )
		triggerServerEvent ( "cancel_gui_server", localPlayer )
		setPlayerHudComponentVisible ( "ammo", false )
		setPlayerHudComponentVisible ( "weapon", false )
		setPlayerHudComponentVisible ( "armour", false )
		setPlayerHudComponentVisible ( "money", false )
		triggerServerEvent ( "ammunationCancel", localPlayer, localPlayer )
	end
end
addEvent ( "SubmitAmmunationGunshopAbbrechen", true)
addEventHandler ( "SubmitAmmunationGunshopAbbrechen", getRootElement(), SubmitAmmunationGunshopAbbrechenBtn)

function SubmitAmmunationGunshopBaseballBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "baseballbat", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopSchaufelBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "schaufel", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopMesserBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "messer", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopSchlagringBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "schlagring", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshop9mmBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "9mm", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshop9mmSDBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "9mmsd", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopDeagleBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "eagle", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopMp5Btn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "mp5", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopShotgunBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "shotty", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopAk47Btn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "ak47", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopM4Btn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "m4", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopGewehrBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "gewehr", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopSGewehrBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "sniper", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopRaketenwerferBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "raketenwerfer", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopLuparaBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "gun", "lupara", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopArmorBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "armor", "armor" )
	end
end

function SubmitAmmunationGunshop9mmAmmoBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "ammo", "9mmammo", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopEagleAmmoBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "ammo", "eagleammo", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopMp5AmmoBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "ammo", "mp5ammo", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopSchrotBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "ammo", "schrot", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopAk47AmmoBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "ammo", "ak47ammo", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopM4AmmoBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "ammo", "m4ammo", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopGewehrAmmoBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "ammo", "gewehrammo", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopSGewehrAmmoBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "ammo", "sgewehrammo", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

function SubmitAmmunationGunshopRaketeBtn ( btn )

	if btn == "left" then
		local w0 = getPedWeapon ( localPlayer, 0 )
		local w1 = getPedWeapon ( localPlayer, 1 )
		local w2 = getPedWeapon ( localPlayer, 2 )
		local w3 = getPedWeapon ( localPlayer, 3 )
		local w4 = getPedWeapon ( localPlayer, 4 )
		local w5 = getPedWeapon ( localPlayer, 5 )
		local w6 = getPedWeapon ( localPlayer, 6 )
		local w7 = getPedWeapon ( localPlayer, 7 )
		triggerServerEvent ( "gunbuyGunshop", localPlayer, localPlayer, "ammo", "rocket", w0, w1, w2, w3, w4, w5, w6, w7 )
	end
end

		schlagringe_price = 50
		baseball_price = 30
		knife_price = 75
		shovels_price = 20
		pistol_price = 150
		sdpistol_price = 320
		pistolammo_price = 15
		eagle_price = 750
		eagleammo_price = 150
		shotgun_price = 250
		shotgunammo_price = 3
		mp_price = 270
		mpammo_price = 50
		ak_price = 550
		akammo_price = 75
		m_price = 750
		mammo_price = 100
		gewehr_price = 225
		gewehrammo_price = 2
		sgewehr_price = 750
		sgewehrammo_price = 7
		rakwerfer_price = 3000
		rak_price = 500
		spezgun_price = 150
		armor_price = 75

		schlagringcap = 20
		baseballcap = 20
		knifecap = 15
		shovelscap = 10
		pistolcap = 35
		sdpistolcap = 10
		pistolammocap = 125
		eaglecap = 5
		eagleammocap = 50
		shotguncap = 15
		shotgunammocap = 1200
		mpcap = 20
		mpammocap = 50
		akcap = 7
		akammocap = 20
		mcap = 5
		mammocap = 15
		gewehrcap = 10
		gewehrammocap = 150
		sgewehrcap = 3
		sgewehrammocap = 50
		raketenwerfercap = 3
		raketencap = 15
		spezguncap = 10
uncosts = 2		
schlagringe_gunshop_price = math.floor ( schlagringe_price*uncosts )
baseball_gunshop_price = math.floor ( baseball_price*uncosts )
knife_gunshop_price = math.floor ( knife_price*uncosts )
shovels_gunshop_price = math.floor ( shovels_price*uncosts )
pistol_gunshop_price = math.floor ( pistol_price*uncosts )
sdpistol_gunshop_price = math.floor ( sdpistol_price*uncosts )
pistolammo_gunshop_price = math.floor ( pistolammo_price*uncosts )
eagle_gunshop_price = math.floor ( eagle_price*uncosts )
eagleammo_gunshop_price = math.floor ( eagleammo_price*uncosts )
shotgun_gunshop_price = shotgun_price*uncosts
shotgunammo_gunshop_price = math.floor ( shotgunammo_price*uncosts )
mp_gunshop_price = math.floor ( mp_price*uncosts )
mpammo_gunshop_price = math.floor ( mpammo_price*uncosts )
ak_gunshop_price = math.floor ( ak_price*uncosts )
akammo_gunshop_price = math.floor ( akammo_price*uncosts )
m_gunshop_price = math.floor ( m_price*uncosts )
mammo_gunshop_price = math.floor ( mammo_price*uncosts )
gewehr_gunshop_price = math.floor ( gewehr_price*uncosts )
gewehrammo_gunshop_price = math.floor ( gewehrammo_price*uncosts )
sgewehr_gunshop_price = math.floor ( sgewehr_price*uncosts )
sgewehrammo_gunshop_price = math.floor ( sgewehrammo_price*uncosts )
rakwerfer_gunshop_price = math.floor ( rakwerfer_price*uncosts )
rak_gunshop_price = math.floor ( rak_price*uncosts )
spezgun_gunshop_price = math.floor ( spezgun_price*uncosts )
armor_gunshop_price = math.floor ( armor_price*uncosts )

function createAmmunationGunshop_func ()

	showCursor ( true )
	guiSetInputMode ( "no_binds_when_editing" )
	setPlayerHudComponentVisible ( "ammo", true )
	setPlayerHudComponentVisible ( "weapon", true )
	setPlayerHudComponentVisible ( "armour", true )
	setPlayerHudComponentVisible ( "money", true )
	if isElement ( WaffenauswahlGunshopFenster ) and dgsGetVisible ( WaffenauswahlGunshopFenster ) then
		dgsSetVisible ( WaffenauswahlGunshopFenster, true )
		dgsBringToFront ( WaffenauswahlGunshopFenster )
	else
		local screenwidth, screenheight = guiGetScreenSize ()

		WaffenauswahlGunshopFenster = dgsCreateWindow(screenwidth/2-319/2,screenheight/2-613/2,319,613,"Waffenauswahl",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255))
		dgsBringToFront ( WaffenauswahlGunshopFenster )
		dgsSetProperty(WaffenauswahlGunshopFenster, "image", false)
		AmmunationText = dgsCreateLabel(0.0376,0.0375,0.953,0.0816,"Willkommen bei Ammunation!\nHier findest du alles fuer dein\nUeberleben!",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(AmmunationText,255,255,255,255)
		dgsLabelSetVerticalAlign(AmmunationText,"top")
		dgsLabelSetHorizontalAlign(AmmunationText,"left",false)

		gLabel["ammunation_pistolen"] = dgsCreateLabel(0.0345,0.2414,0.1818,0.0245,"Pistolen",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_pistolen"],125,000,20,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_pistolen"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_pistolen"],"left",false)
		gLabel["ammunation_meele"] = dgsCreateLabel(0.0345,0.1256,0.1881,0.0277,"Nahkampf",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_meele"],125,000,20,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_meele"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_meele"],"left",false)
		gLabel["ammunation_mps"] = dgsCreateLabel(0.0345,0.3573,0.3197,0.0245,"Maschinenpistolen",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_mps"],125,0,20,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_mps"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_mps"],"left",false)
		gLabel["ammunation_shotguns"] = dgsCreateLabel(0.4044,0.3573,0.3197,0.0245,"Schrotflinten",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_shotguns"],125,0,20,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_shotguns"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_shotguns"],"left",false)
		gLabel["ammunation_sturmgewehre"] = dgsCreateLabel(0.0345,0.4878,0.3135,0.0245,"Sturmgewehre",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_sturmgewehre"],125,000,25,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_sturmgewehre"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_sturmgewehre"],"left",false)
		gLabel["ammunation_gewehre"] = dgsCreateLabel(0.4013,0.4878,0.1787,0.0245,"Gewehre",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_gewehre"],125,0,25,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_gewehre"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_gewehre"],"left",false)
		gLabel["ammunation_sonstiges"] = dgsCreateLabel(0.0345,0.6003,0.3135,0.0245,"Sonstiges",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_sonstiges"],125,0,25,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_sonstiges"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_sonstiges"],"left",false)
		gLabel["ammunation_ammo"] = dgsCreateLabel(0.0345,0.7129,0.3135,0.0245,"Munition",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_ammo"],125,0,25,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_ammo"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_ammo"],"left",false)

		gLabel["ammunation_baseball"] = dgsCreateLabel(0.0282,0.207,0.2,0.0245,"  "..baseball_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_baseball"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_baseball"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_baseball"],"left",false)
		gLabel["ammunation_shovel"] = dgsCreateLabel(0.3668,0.207,0.2,0.033,"  "..shovels_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_shovel"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_shovel"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_shovel"],"left",false)
		gLabel["ammunation_knife"] = dgsCreateLabel(0.5768,0.207,0.2,0.0277,"  "..knife_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_knife"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_knife"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_knife"],"left",false)
		gLabel["ammunation_ring"] = dgsCreateLabel(0.7649,0.207,0.2,0.0261,"  "..schlagringe_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_ring"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_ring"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_ring"],"left",false)
		gLabel["ammunation_9mm"] = dgsCreateLabel(0.0282,0.3263,0.2,0.0245,"  "..pistol_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_9mm"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_9mm"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_9mm"],"left",false)
		gLabel["ammunation_9mmsd"] = dgsCreateLabel(0.2038,0.3263,0.2,0.033,"  "..sdpistol_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_9mmsd"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_9mmsd"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_9mmsd"],"left",false)
		gLabel["ammunation_deagle"] = dgsCreateLabel(0.5611,0.3263,0.2,0.033,"  "..eagle_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_deagle"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_deagle"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_deagle"],"left",false)
		gLabel["ammunation_mp5"] = dgsCreateLabel(0.0313,0.4454,0.2,0.0245,"  "..mp_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_mp5"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_mp5"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_mp5"],"left",false)
		gLabel["ammunation_shotgun"] = dgsCreateLabel(0.4044,0.4454,0.2,0.0245,"  "..shotgun_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_shotgun"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_shotgun"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_shotgun"],"left",false)
		gLabel["ammunation_ak47"] = dgsCreateLabel(0.0282,0.5726,0.2,0.1,"  "..ak_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_ak47"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_ak47"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_ak47"],"left",false)
		gLabel["ammunation_m4"] = dgsCreateLabel(0.2069,0.5726,0.2,0.05,"  "..m_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_m4"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_m4"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_m4"],"left",false)
		gLabel["ammunation_gewehr"] = dgsCreateLabel(0.4013,0.5726,0.2,0.05,"  "..gewehr_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_gewehr"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_gewehr"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_gewehr"],"left",false)
		gLabel["ammunation_armor"] = dgsCreateLabel(0.56,0.6781,0.2,0.0245,"  "..armor_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_armor"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_armor"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_armor"],"left",false)
		gLabel["ammunation_9mmammo"] = dgsCreateLabel(0.0282,0.7945,0.2,0.0245,"  "..pistolammo_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_9mmammo"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_9mmammo"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_9mmammo"],"left",false)
		gLabel["ammunation_deagleammo"] = dgsCreateLabel(0.2257,0.7945,0.2,0.0245,"  "..eagleammo_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_deagleammo"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_deagleammo"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_deagleammo"],"left",false)
		gLabel["ammunation_mp5ammo"] = dgsCreateLabel(0.4922,0.7945,0.2,0.0245,"  "..mpammo_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_mp5ammo"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_mp5ammo"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_mp5ammo"],"left",false)
		gLabel["ammunation_schrot"] = dgsCreateLabel(0.0345,0.8728,0.2,0.0245,"  "..shotgunammo_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_schrot"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_schrot"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_schrot"],"left",false)
		gLabel["ammunation_akammo"] = dgsCreateLabel(0.3041,0.8728,0.2,0.0245,"  "..akammo_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_akammo"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_akammo"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_akammo"],"left",false)
		gLabel["ammunation_m4ammo"] = dgsCreateLabel(0.5862,0.8728,0.2,0.0245,"  "..mammo_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_m4ammo"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_m4ammo"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_m4ammo"],"left",false)
		gLabel["ammunation_gewehrammo"] = dgsCreateLabel(0.0313,0.9543,2,0.0245,"  "..gewehrammo_gunshop_price.." $",true,WaffenauswahlGunshopFenster)
		dgsLabelSetColor(gLabel["ammunation_gewehrammo"],000,125,000,255)
		dgsLabelSetVerticalAlign(gLabel["ammunation_gewehrammo"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammunation_gewehrammo"],"left",false)

		gButton["ammunation_mgunshopcancel"] = dgsCreateButton(0.7649,0.1,0.2038,0.0457,"Abbrechen",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_baseball"] = dgsCreateButton(0.0282,0.1582,0.3229,0.0457,"Baseballschlaeger",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_shovel"] = dgsCreateButton(0.3668,0.1582,0.1944,0.0457,"Schaufel",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_knife"] = dgsCreateButton(0.5768,0.1582,0.1724,0.0457,"Messer",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_schlagring"] = dgsCreateButton(0.7649,0.1582,0.2038,0.0457,"Schlagring",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_9mm"] = dgsCreateButton(0.0282,0.2724,0.1567,0.0457,"9mm",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_9mmSD"] = dgsCreateButton(0.2038,0.2724,0.3417,0.0457,"9mm Schallgedaempft",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_deagle"] = dgsCreateButton(0.5611,0.2724,0.2602,0.0457,"Desert Eagle",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_mp5"] = dgsCreateButton(0.0313,0.3915,0.1567,0.0457,"MP5",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_shotgun"] = dgsCreateButton(0.4044,0.3899,0.2445,0.0457,"Schrotflinte",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_ak-47"] = dgsCreateButton(0.0282,0.5204,0.1567,0.0457,"AK-47",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_m4"] = dgsCreateButton(0.2069,0.5204,0.1003,0.0457,"M4",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_gewehr"] = dgsCreateButton(0.4013,0.5188,0.1693,0.0457,"Gewehr",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_armor"] = dgsCreateButton(0.5266,0.6281,0.2445,0.0457,"Schusssichere\nWeste",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_9mmammo"] = dgsCreateButton(0.0282,0.7439,0.1787,0.0457,"9mm Magazin",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_eagleammo"] = dgsCreateButton(0.2257,0.7439,0.2508,0.0457,"Desert Eagle Magazin",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_mp5ammo"] = dgsCreateButton(0.4922,0.7439,0.2508,0.0457,"MP5 Magazin",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_schrot"] = dgsCreateButton(0.0282,0.8254,0.2602,0.0457,"Schrotkugeln",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_ak-47ammo"] = dgsCreateButton(0.3041,0.8254,0.2602,0.0457,"AK-47 Magazin",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_m4ammo"] = dgsCreateButton(0.5862,0.8238,0.2226,0.0457,"M4 Magazin",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["ammunation_gewehrammo"] = dgsCreateButton(0.0313,0.9021,0.2821,0.0457,"Gewehrpatrone",true,WaffenauswahlGunshopFenster, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		dgsWindowSetMovable ( WaffenauswahlGunshopFenster, false )
		dgsWindowSetSizable  ( WaffenauswahlGunshopFenster, false )

		addEventHandler("onDgsMouseClickUp", gButton["ammunation_mgunshopcancel"], SubmitAmmunationGunshopAbbrechenBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_baseball"], SubmitAmmunationGunshopBaseballBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_shovel"], SubmitAmmunationGunshopSchaufelBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_knife"], SubmitAmmunationGunshopMesserBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_schlagring"], SubmitAmmunationGunshopSchlagringBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_9mm"], SubmitAmmunationGunshop9mmBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_9mmSD"], SubmitAmmunationGunshop9mmSDBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_deagle"], SubmitAmmunationGunshopDeagleBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_mp5"], SubmitAmmunationGunshopMp5Btn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_shotgun"], SubmitAmmunationGunshopShotgunBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_ak-47"], SubmitAmmunationGunshopAk47Btn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_m4"], SubmitAmmunationGunshopM4Btn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_gewehr"], SubmitAmmunationGunshopGewehrBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_sgewehr"], SubmitAmmunationGunshopSGewehrBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_armor"], SubmitAmmunationGunshopArmorBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_9mmammo"], SubmitAmmunationGunshop9mmAmmoBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_eagleammo"], SubmitAmmunationGunshopEagleAmmoBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_mp5ammo"], SubmitAmmunationGunshopMp5AmmoBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_schrot"], SubmitAmmunationGunshopSchrotBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_ak-47ammo"], SubmitAmmunationGunshopAk47AmmoBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_m4ammo"], SubmitAmmunationGunshopM4AmmoBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["ammunation_gewehrammo"], SubmitAmmunationGunshopGewehrAmmoBtn, false)
	end
end
addEvent ( "createAmmunationGunshop", true )
addEventHandler ( "createAmmunationGunshop", getRootElement(), createAmmunationGunshop_func )