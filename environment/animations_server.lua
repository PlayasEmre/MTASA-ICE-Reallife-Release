--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function showanimlist(playerSource)
	outputChatBox("Animationen:",playerSource, 0, 200, 0 )
	outputChatBox("/handsup,/phoneout,/phonein,/drunk,/robman",playerSource, 200, 200, 0 )
	outputChatBox("/bomb,/getarrested,/laugh,/lookout,/crossarms",playerSource, 200, 200, 0 )
	outputChatBox("/lay,/hide,/vomit,/eat,/wave,/slapass",playerSource, 200, 200, 0 )
	outputChatBox("/deal,/crack,/smoke,/smokef,/ground,/fucku",playerSource, 200, 200, 0 )
	outputChatBox("/chat,/taichi,/chairsit,/dance [1-7],/piss,/wank,/winken,/sitzen",playerSource, 200, 200, 0 )
	outputChatBox("Zum Abbrechen einer Animation: /stopanim",playerSource, 0, 0, 200 )
end

function executeCommandHandlerServer_func ( player, cmd, arg )
	if player == client or not client then
		executeCommandHandler ( cmd, player, arg )
	end
end
addEvent ( "executeCommandHandlerServer", true )
addEventHandler ( "executeCommandHandlerServer", getRootElement(), executeCommandHandlerServer_func )

function sex_func(player)
	if MtxGetElementData ( player, "jailtime" ) > 0 or MtxGetElementData ( player, "prison" ) > 0 or isPedInVehicle ( player ) then
		return
	end
	MtxSetElementData(player,"anim", 1)
	local sex = math.random ( 1, 2 )
	if sex == 1 then
		setPedAnimation(player,"sex","sex_1_cum_w",1,true,false)
	else
		setPedAnimation(player,"sex","sex_1_cum_p",1,true,false)
	end
	bindKey ( player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", player, "Sex")
end

function handsup(Player)
	if MtxGetElementData ( Player, "jailtime" ) and  MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) and MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "shop", "SHP_HandsUp_Scr")
	setTimer(handb,500,1,Player)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Handsup")
end

function phoneout(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "ped", "phone_in",-1,false,true,true)
	bindKey ( Player, "space", "down", stopanima)
	triggerClientEvent ( "Animshow", Player, "Phoneout")
end

function phonein(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "ped", "phone_out",-1,false,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Phonein")
end

function handb(Player)
	if getElementData ( Player, "jailtime" ) > 0 or getElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	setPedAnimation(Player,"shop","SHP_Rob_HandsUp",-1,false)
end

function stopanima(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	if MtxGetElementData(Player,"anim")==1 then
		setPedAnimation(Player)
		MtxSetElementData(Player,"anim", 0) 
		triggerClientEvent (Player, "Animhide", Player)
	end	
end

function drunk(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "ped", "WALK_drunk",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Drunk")
end

function bomb(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "bomber", "BOM_Plant_In",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	setTimer(bombb,500,1,Player)
	triggerClientEvent ( "Animshow", Player, "Plant Bomb")
end

function bombb(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	setPedAnimation(Player, "bomber", "BOM_Plant",-1,false,false,true)
end

function smoke(Player)
	if MtxGetElementData ( Player, "jailtime" ) and MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) and MtxGetElementData ( Player, "prison" ) > 0 then
		return
	end
	if not gotLastHit[Player] or gotLastHit[Player] + healafterdmgtime <= getTickCount() then
		if MtxGetElementData ( Player, "zigaretten" ) and MtxGetElementData ( Player, "zigaretten" ) >= 1 then
			MtxSetElementData ( Player, "zigaretten", MtxGetElementData ( Player, "zigaretten" ) - 1 )
			smokeCigarett ( Player )
		else
			outputChatBox ( "Du hast keine Zigaretten!", Player, 125, 0, 0 )
		end
	else
		outputChatBox ( "Es muss dafür "..( healafterdmgtime/1000 ) .." Sekunden nach dem letzten Schuss vergangen sein!", Player, 200, 0, 0 )
	end
end

function robman(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "shop", "ROB_Loop_Threat",-1,true,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Robman")
end

function getarrested(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "ped", "ARRESTgun",-1,false,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Getarrested")
end

function laugh(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "rapping", "Laugh_01",-1,true,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Laugh")
end

function lookout(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "shop", "ROB_Shifty",-1,true,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Lookout")
end

function crossarms(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "cop_ambient", "Coplook_loop",-1,true,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Crossarms")
end

function lay(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "beach", "bather",-1,true,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "lay")
end

function hide(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "ped", "cower",-1,true,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "hide")
end

function vomit(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "food", "EAT_Vomit_P",-1,true,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "vomit")
end

function eat(Player,cmd,slot)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 then
		return
	end
	if slot then
		local slot = tonumber ( slot )
		if MtxGetElementData ( Player, "food"..slot ) == 5 then
			if not isPedInVehicle ( Player ) then
				setPedAnimation(Player, "food", "EAT_Burger",1,true,false,true)
				setTimer ( setPedAnimation, 1200, 1, Player )
			end
			setElementHealth ( Player, 100 )
			setPedArmor ( Player, 100 )
			setElementHunger ( Player, 100 )
		elseif MtxGetElementData ( Player, "food"..slot ) == 2 then
			drinkAlcohol ( Player, "Bier" )
		elseif MtxGetElementData ( Player, "food"..slot ) > 1 then
			if not isPedInVehicle ( Player ) then
				setPedAnimation(Player, "food", "EAT_Burger",1,true,false,true)
				setTimer ( setPedAnimation, 1200, 1, Player )
			end
			setElementHealth ( Player, getElementHealth ( Player ) + foodHeal[slot] )
			setElementHunger ( Player, getElementHunger ( Player ) + foodHeal[slot] )
		elseif MtxGetElementData ( Player, "food"..slot ) == 1 then
			if not isPedInVehicle ( Player ) then
				setPedAnimation(Player, "bomber", "BOM_Plant_In",1,true,true,true)
				setTimer ( setPedAnimation, 500, 1, Player )
			end
			setElementHealth ( Player, getElementHealth ( Player ) + 50 )
		end
		MtxSetElementData ( Player, "food"..slot, 0 )
	else
		outputChatBox ( "Gebrauch: /eat [1-3]", Player, 125, 0, 0 )
	end
end

function wave(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "ON_LOOKERS", "wave_loop",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Wave")
end

function slapass(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "sweet", "sweet_ass_slap",-1,true,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Slapass")
end

function deal(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "dealer", "dealer_deal",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Deal")
end

function crack(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "crack", "crckdeth2",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Crack")
end

function ground(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "beach", "ParkSit_M_loop",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Ground")
end

function fucku(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "ped", "fucku",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Fucku")
end

function chat(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "ped", "IDLE_chat",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Chat")
end

function taichi(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "park", "Tai_Chi_Loop",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Taichi")
end

function chairsit(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "BEACH", "SitnWait_loop_W",-1,true,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Chairsit")
end

function piss(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "PAULNMAC", "Piss_loop",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Piss")
end

function winken(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "BD_FIRE", "BD_GF_Wave",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "winken")
end

function sitzen(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "BEACH", "ParkSit_M_loop",-1,true,true,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "sitzen")
end


function wank(Player)
	if MtxGetElementData ( Player, "jailtime" ) > 0 or MtxGetElementData ( Player, "prison" ) > 0 or isPedInVehicle ( Player ) then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "PAULNMAC", "wank_loop",-1,true,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Wank")
end


function kiss(Player)
	
	if MtxGetElementData ( Player, "jailtime" ) > 0 then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "KISSING", "Grlfrd_Kiss_02",-1,false,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "Kiss")
end


function test1(Player)
	
	if MtxGetElementData ( Player, "jailtime" ) > 0 then
		return
	end
	MtxSetElementData(Player,"anim", 1)
	setPedAnimation(Player, "beach", "sitnwait_loop_w",-1,false,false,true)
	bindKey ( Player, "space", "down", stopanima )
	triggerClientEvent ( "Animshow", Player, "test1")
end


addCommandHandler("test1",test1)
addCommandHandler("sex",sex_func)
addCommandHandler("piss",piss)
addCommandHandler("wank",wank)
addCommandHandler("ground",ground)
addCommandHandler("fucku",fucku)
addCommandHandler("chat",chat)
addCommandHandler("taichi",taichi)
addCommandHandler("chairsit",chairsit)
addCommandHandler("vomit",vomit)
addCommandHandler("eat",eat)
addCommandHandler("wave",wave)
addCommandHandler("slapass",slapass)
addCommandHandler("deal",deal)
addCommandHandler("crack",crack)
addCommandHandler("animlist",showanimlist)
addCommandHandler("handsup",handsup)
addCommandHandler("stopanim",stopanima)
addCommandHandler("phoneout",phoneout)
addCommandHandler("phonein",phonein)
addCommandHandler("drunk",drunk)
addCommandHandler("bomb",bomb)
addCommandHandler("smoke",smoke)
addCommandHandler("robman",robman)
addCommandHandler("getarrested",getarrested) 
addCommandHandler("laugh",laugh)
addCommandHandler("lookout",lookout)
addCommandHandler("crossarms",crossarms)
addCommandHandler("lay",lay)
addCommandHandler("hide",hide)
addCommandHandler("winken",winken)
addCommandHandler("sitzen",sitzen)
addCommandHandler("kiss",kiss)

function dance_func ( player, cmd, style )
	if MtxGetElementData ( player, "jailtime" ) > 0 or MtxGetElementData ( player, "prison" ) > 0 or isPedInVehicle ( player ) then
		return
	end
	if style then
		local style = tonumber ( style )
		if style == 1 then
			setPedAnimation ( player, "DANCING", "dnce_M_a",-1,true,false,false )
		elseif style == 2 then
			setPedAnimation ( player, "DANCING", "dnce_M_b",-1,true,false,false )
		elseif style == 3 then
			setPedAnimation ( player, "DANCING", "dnce_M_c",-1,true,false,false )
		elseif style == 4 then
			setPedAnimation ( player, "DANCING", "dnce_M_d",-1,true,false,false )
		elseif style == 5 then
			setPedAnimation ( player, "DANCING", "dnce_M_e",-1,true,false,false )
		elseif style == 6 then
			setPedAnimation ( player, "DANCING", "dance_loop",-1,true,false,false )
		else
			local rnd = math.random ( 1, 4 )
			if rnd == 1 then
				setPedAnimation ( player, "STRIP", "STR_Loop_A",-1,true,false,false )
			elseif rnd == 2 then
				setPedAnimation ( player, "STRIP", "STR_Loop_B",-1,true,false,false )
			elseif rnd == 3 then
				setPedAnimation ( player, "STRIP", "STR_Loop_C",-1,true,false,false )
			else
				setPedAnimation ( player, "STRIP", "STR_Loop_A",-1,true,false,false )
			end
		end
		MtxSetElementData( player, "anim", 1)
		bindKey ( player, "space", "down", stopanima )
		triggerClientEvent ( "Animshow", player, "Dance "..tostring(style).."")
	else
		outputChatBox ( "FEHLER: /dance [1-7]", player, 125, 0, 0 )
	end
end
addCommandHandler("dance",dance_func)