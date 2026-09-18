--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local selfmadeAnimationen={anim={},
["Animationen"]={
	["Hände hoch"]={"shop","SHP_HandsUp_Scr",-1,false,true,true,nil,nil},
	["Hinlegen"]={"beach","bather",-1,true,false,true,nil,nil},
	["Winken"]={"ON_LOOKERS","wave_loop",-1,true,false,true,nil,nil},
	["Arme verschränken"]={"cop_ambient","Coplook_loop",-1,true,false,true,nil,nil},
	["Lachen"]={"rapping","Laugh_01",-1,true,false,true,nil,nil},
	["Pissen"]={"PAULNMAC","Piss_loop",-1,false,false,false,false,nil},
	["Ass Slap"]={"sweet","sweet_ass_slap",-1,true,false,true,nil,nil},
	["Bitch Slap"]={"misc","bitchslap",-1,true,false,true,nil,nil},
	["Kotzen"]={"food","EAT_Vomit_P",-1,true,false,true,nil,nil},
	["Masturbieren"]={"PAULNMAC","wank_loop",-1,true,false,true,nil,nil},
	["Kratzen Genitalbreich"]={"misc","Scratchballs_01",-1,true,false,true,nil,nil},
	["Kratzen Kopf"]={"misc","plyr_shkhead",-1,true,false,true,nil,nil},
	["Fuck you"]={"ped","fucku",-1,true,true,true,nil,nil},
	["Warten"]={"ped","woman_idlestance",-1,true,false,true,nil,nil},
	["Etwas zeigen"]={"on_lookers","point_loop",-1,true,false,true,nil,nil},
	["Nach oben zeigen"]={"on_lookers","pointup_loop",-1,true,false,true,nil,nil},
	["Tanzen orientalisch"]={"DANCING","dnce_M_a",-1,true,false,false,nil,nil},
	["Tanzen chillig"]={"DANCING","dnce_M_b",-1,true,false,false,nil,nil},
	["Tanzen rhythmisch"]={"DANCING","dnce_M_d",-1,true,false,false,nil,nil},
	["Tanzen wild"]={"DANCING","dnce_M_e",-1,true,false,false,nil,nil},
	["Tanzen HipHop"]={"DANCING","dance_loop",-1,true,false,false,nil,nil},
	["Tanzen sexy"]={"STRIP","STR_Loop_A",-1,true,false,false,nil,nil},
	["Tanzen nuttig"]={"STRIP","STR_Loop_B",-1,true,false,false,nil,nil},
	["Tanzen strip 1"]={"STRIP","STR_Loop_C",-1,true,false,false,nil,nil},
	["Tanzen strip 2"]={"STRIP","strip_d",-1,true,false,false,nil,nil},
	},
}

addEvent("start.animation",true)
addEventHandler("start.animation",root,function(animation)
	if(selfmadeAnimationen["Animationen"][animation])then
		if(not(isPedInVehicle(client)))then
				selfmadeAnimationen.anim[client]=true
				setPedAnimation(client,selfmadeAnimationen["Animationen"][animation][1],selfmadeAnimationen["Animationen"][animation][2],selfmadeAnimationen["Animationen"][animation][3],selfmadeAnimationen["Animationen"][animation][4],selfmadeAnimationen["Animationen"][animation][5],selfmadeAnimationen["Animationen"][animation][6],selfmadeAnimationen["Animationen"][animation][7],selfmadeAnimationen["Animationen"][animation][8])
				triggerClientEvent(client, "infobox_start", getRootElement(), "Drücke Leertaste zum beenden der Animation.", 7500, 135, 206, 250)
				bindKey(client,"space","down",selfmadeAnimationen.stop)
		else triggerClientEvent(client, "infobox_start", getRootElement(), "Verlasse zu erst dein Fahrzeug!", 7500, 135, 206, 250)end
	end
end)

function selfmadeAnimationen.stop(player)
	if(selfmadeAnimationen.anim[player]==true)then
		selfmadeAnimationen.anim[player]=nil
		setPedAnimation(player)
		unbindKey(player,"space","down",selfmadeAnimationen.stop)
	end
end