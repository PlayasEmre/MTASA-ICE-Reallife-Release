--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

function showTrunkGui_func ( drugs, mats, gun, ammo )

	dgsSetInputMode ( "no_binds_when_editing" )

	-- Das Auto-Menue samt Admin-Panel gehoert nicht zum Kofferraum und blieb
	-- sonst daneben stehen.
	if gWindows and isElement ( gWindows["vehinteraktion"] ) then
		dgsSetVisible ( gWindows["vehinteraktion"], false )
	end
	if isElement ( gWindow["vehCarAdminWin"] ) then
		dgsSetVisible ( gWindow["vehCarAdminWin"], false )
	end
	if isElement ( gWindow["vehKeyPanel"] ) then
		dgsSetVisible ( gWindow["vehKeyPanel"], false )
	end

	showCursor ( true )
	if gWindow["trunkClick"] then
		dgsSetVisible ( gWindow["trunkClick"], true )
	else
		gWindow["trunkClick"] = dgsCreateImage(screenwidth/2-357/2,screenheight/2-232/2,357,232,":"..getResourceName(getThisResource()).."/images/background.png",false)

		gLabel["trunkInfo1"] = dgsCreateLabel(17,22,48,18,"Drogen:",false,gWindow["trunkClick"])
		dgsLabelSetColor(gLabel["trunkInfo1"],000,200,000,255)
		dgsLabelSetVerticalAlign(gLabel["trunkInfo1"],"top")
		dgsLabelSetHorizontalAlign(gLabel["trunkInfo1"],"left",false)
		dgsSetFont(gLabel["trunkInfo1"],"default-bold")
		gLabel["trunkDrugs"] = dgsCreateLabel(24,41,49,17,"500 g",false,gWindow["trunkClick"])
		dgsLabelSetColor(gLabel["trunkDrugs"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["trunkDrugs"],"top")
		dgsLabelSetHorizontalAlign(gLabel["trunkDrugs"],"left",false)
		dgsSetFont(gLabel["trunkDrugs"],"default-bold")
		gEdit["trunkDrugs"] = dgsCreateEdit(17,89,65,31,"500",false,gWindow["trunkClick"])
		gLabel["trunkInfo3"] = dgsCreateLabel(85,96,17,17,"g",false,gWindow["trunkClick"])
		dgsLabelSetColor(gLabel["trunkInfo3"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["trunkInfo3"],"top")
		dgsLabelSetHorizontalAlign(gLabel["trunkInfo3"],"left",false)
		dgsSetFont(gLabel["trunkInfo3"],"default-bold")
		gLabel["trunkInfo4"] = dgsCreateLabel(107,23,72,18,"Materialien:",false,gWindow["trunkClick"])
		dgsLabelSetColor(gLabel["trunkInfo4"],200,100,000,255)
		dgsLabelSetVerticalAlign(gLabel["trunkInfo4"],"top")
		dgsLabelSetHorizontalAlign(gLabel["trunkInfo4"],"left",false)
		dgsSetFont(gLabel["trunkInfo4"],"default-bold")
		gLabel["trunkMats"] = dgsCreateLabel(117,41,70,17,"200 Stk.",false,gWindow["trunkClick"])
		dgsLabelSetColor(gLabel["trunkMats"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["trunkMats"],"top")
		dgsLabelSetHorizontalAlign(gLabel["trunkMats"],"left",false)
		dgsSetFont(gLabel["trunkMats"],"default-bold")
		gEdit["trunkMats"] = dgsCreateEdit(109,88,65,31,"500",false,gWindow["trunkClick"])
		gLabel["trunkInfo2"] = dgsCreateLabel(177,96,25,17,"Stk.",false,gWindow["trunkClick"])
		dgsLabelSetColor(gLabel["trunkInfo2"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["trunkInfo2"],"top")
		dgsLabelSetHorizontalAlign(gLabel["trunkInfo2"],"left",false)
		dgsSetFont(gLabel["trunkInfo2"],"default-bold")
		gLabel["trunkInfo5"] = dgsCreateLabel(215,23,97,20,"Waffe:",false,gWindow["trunkClick"])
		dgsLabelSetColor(gLabel["trunkInfo5"],200,000,000,255)
		dgsLabelSetVerticalAlign(gLabel["trunkInfo5"],"top")
		dgsLabelSetHorizontalAlign(gLabel["trunkInfo5"],"left",false)
		dgsSetFont(gLabel["trunkInfo5"],"default-bold")
		gLabel["trunkStoredGun"] = dgsCreateLabel(208,39,139,30,"",false,gWindow["trunkClick"])
		dgsLabelSetColor(gLabel["trunkStoredGun"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["trunkStoredGun"],"top")
		dgsLabelSetHorizontalAlign(gLabel["trunkStoredGun"],"left",false)
		dgsSetFont(gLabel["trunkStoredGun"],"default-bold")
		gLabel["trunkInfo6"] = dgsCreateLabel(215,69,76,20,"In der Hand:",false,gWindow["trunkClick"])
		dgsLabelSetColor(gLabel["trunkInfo6"],200,000,00,255)
		dgsLabelSetVerticalAlign(gLabel["trunkInfo6"],"top")
		dgsLabelSetHorizontalAlign(gLabel["trunkInfo6"],"left",false)
		dgsSetFont(gLabel["trunkInfo6"],"default-bold")
		gLabel["trunkHandGun"] = dgsCreateLabel(208,86,144,30,"",false,gWindow["trunkClick"])
		dgsLabelSetColor(gLabel["trunkHandGun"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["trunkHandGun"],"top")
		dgsLabelSetHorizontalAlign(gLabel["trunkHandGun"],"left",false)
		dgsSetFont(gLabel["trunkHandGun"],"default-bold")

		gButton["trunkClose"] = dgsCreateButton(331,24,15,15,"x",false,gWindow["trunkClick"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["trunkClose"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					dgsSetVisible ( gWindow["trunkClick"], false )
					dgsSetVisible ( gWindow["vehCarDelete"], false )
					dgsSetInputMode ( "allow_binds" )
					showCursor ( false )
					vioClientSetElementData ( "clickedVehicle", false )
					setElementClicked ( false )
				end
			end,
		false )

		gButton["trunkTakeDrugs"] = dgsCreateButton(17,123,68,40,"Nehmen",false,gWindow["trunkClick"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["trunkStoreDrugs"] = dgsCreateButton(17,175,68,40,"Lagern",false,gWindow["trunkClick"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		gButton["trunkTakeMats"] = dgsCreateButton(108,123,68,40,"Nehmen",false,gWindow["trunkClick"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["trunkStoreMats"] = dgsCreateButton(108,175,68,40,"Lagern",false,gWindow["trunkClick"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		gButton["trunkTakeGun"] = dgsCreateButton(234,123,68,40,"Nehmen",false,gWindow["trunkClick"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["trunkStoreGun"] = dgsCreateButton(234,175,68,40,"Lagern",false,gWindow["trunkClick"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		trunkButtons = {
		[gButton["trunkTakeDrugs"]] = true,
		[gButton["trunkStoreDrugs"]] = true,
		[gButton["trunkTakeMats"]] = true,
		[gButton["trunkStoreMats"]] = true,
		[gButton["trunkTakeGun"]] = true,
		[gButton["trunkStoreGun"]] = true
		}

		for key, index in pairs ( trunkButtons ) do
			addEventHandler ( "onDgsMouseClickUp", key, trunkClick, false )
		end
	end
	dgsSetText ( gLabel["trunkDrugs"], drugs.." g" )
	dgsSetText ( gLabel["trunkMats"], mats.." Stk." )
	local gunText = "-"
	if ammo == 0 or gun <= 1 then
		gunText = "Keine"
	elseif ammo > 1 then
		if singleTrunkWeapons[gun] then
			fix = "Stk."
		else
			fix = "Schuss"
		end
		gunText = weaponNames[gun].."\n"..ammo.." "..fix
	else
		gunText = weaponNames[gun]
	end
	dgsSetText ( gLabel["trunkStoredGun"], gunText )

	gun = getPedWeapon ( lp )
	ammo = getPedTotalAmmo ( lp )
	local gunText = "-"
	if ammo == 0 or gun <= 1 then
		gunText = "Keine"
	elseif ammo > 1 then
		if singleTrunkWeapons[gun] then
			fix = "Stk."
		else
			fix = "Schuss"
		end
		gunText = weaponNames[gun].."\n"..ammo.." "..fix
	else
		gunText = weaponNames[gun]
	end
	dgsSetText ( gLabel["trunkHandGun"], gunText )
	dgsSetText ( gEdit["trunkDrugs"], "0" )
	dgsSetText ( gEdit["trunkMats"], "0" )

	if getElementData ( lp, "adminlvl" ) >= 2 then
		gWindow["vehCarDelete"] = dgsCreateImage(0,screenheight/2-132/2,151,137,":"..getResourceName(getThisResource()).."/images/background.png",false)
		if getElementData ( lp, "adminlvl" ) >= 3 then
			gButton["vehCarDel"] = dgsCreateButton(0.0596,0.1898,0.3974,0.2555,"Loeschen",true,gWindow["vehCarDelete"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		end
		gButton["vehCarResp"] = dgsCreateButton(0.4901,0.1898,0.457,0.2555,"Respawnen",true,gWindow["vehCarDelete"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gLabel["vehCarInfo1"] = dgsCreateLabel(0.0596,0.4891,0.3113,0.1387,"Grund:",true,gWindow["vehCarDelete"])
		dgsLabelSetColor(gLabel["vehCarInfo1"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["vehCarInfo1"],"top")
		dgsLabelSetHorizontalAlign(gLabel["vehCarInfo1"],"left",false)
		dgsSetFont(gLabel["vehCarInfo1"],"default-bold")
		gMemo["vehCarReason"] = dgsCreateMemo(0.0596,0.6058,0.8808,0.3358,"",true,gWindow["vehCarDelete"])

		addEventHandler("onDgsMouseClickUp", gButton["vehCarResp"],
			function(btn)
				if btn ~= "left" then return end
				local veh = vioClientGetElementData ( "clickedVehicle" )
				local towcar = getElementData ( veh, "carslotnr_owner" )
				local pname = getElementData ( veh, "owner" )
				triggerServerEvent ( "respawnVeh", lp, towcar, pname, veh )
			end
		)
		if getElementData ( lp, "adminlvl" ) >= 3 then
			addEventHandler("onDgsMouseClickUp", gButton["vehCarDel"],
				function(btn)
					if btn ~= "left" then return end
					local veh = vioClientGetElementData ( "clickedVehicle" )
					local towcar = getElementData ( veh, "carslotnr_owner" )
					local pname = getElementData ( veh, "owner" )
					if not pname then
						outputChatBox ( "Dieses Fahrzeug gehoert keinem Spieler!", 125, 0, 0 )
					else
						triggerServerEvent ( "deleteVeh", lp, towcar, pname, veh, dgsGetText ( gMemo["vehCarReason"] ) )
					end
				end,
			false)
		end
	end
end
addEvent ( "showTrunkGui", true )
addEventHandler ( "showTrunkGui", getRootElement(), showTrunkGui_func )

function trunkClick ( btn, state )

	if btn ~= "left" then return end
	if state == "up" then
		if trunkButtons[source] then
			local drugs = dgsGetText ( gLabel["trunkDrugs"] )
			drugs = tonumber ( string.sub ( drugs, 1, ( #drugs ) - 2 ) )

			local mats = dgsGetText ( gLabel["trunkMats"] )
			mats = tonumber ( string.sub (mats, 1, ( #mats ) - 5 ) )

			local drugsValue = tonumber ( dgsGetText ( gEdit["trunkDrugs"] ) )
			local matsValue = tonumber ( dgsGetText ( gEdit["trunkMats"] ) )

			if source == gButton["trunkTakeDrugs"] or source == gButton["trunkTakeMats"] or source == gButton["trunkTakeGun"] then
				if source == gButton["trunkTakeGun"] then
					if dgsGetText ( gLabel["trunkStoredGun"] ) ~= "Keine" then
						triggerServerEvent ( "trunkStorageServer", lp, "gun", "", true )
						dgsSetText ( gLabel["trunkHandGun"], dgsGetText ( gLabel["trunkStoredGun"] ) )
						dgsSetText ( gLabel["trunkStoredGun"], "Keine" )
					else
						outputChatBox ( "Du hast im Moment keine Waffe eingelagert!", 125, 0, 0 )
					end
				elseif source == gButton["trunkTakeDrugs"] then
					if drugs >= drugsValue then
						triggerServerEvent ( "trunkStorageServer", lp, "drugs", drugsValue, true )
						dgsSetText ( gLabel["trunkDrugs"], ( drugs - drugsValue ).." g" )
					else
						outputChatBox ( "Du nicht so viele Drogen gelagert!", 125, 0, 0 )
					end
				else
					if mats >= matsValue then
						triggerServerEvent ( "trunkStorageServer", lp, "mats", matsValue, true )
						dgsSetText ( gLabel["trunkMats"], ( mats - matsValue ).." Stk." )
					else
						outputChatBox ( "Du nicht so viele Materialien gelagert!", 125, 0, 0 )
					end
				end
			else
				if source == gButton["trunkStoreGun"] then
					if dgsGetText ( gLabel["trunkStoredGun"] ) == "Keine" then
						if dgsGetText ( gLabel["trunkHandGun"] ) ~= "Keine" then
							triggerServerEvent ( "trunkStorageServer", lp, "gun", "", false )
							dgsSetText ( gLabel["trunkStoredGun"], dgsGetText ( gLabel["trunkHandGun"] ) )
							dgsSetText ( gLabel["trunkHandGun"], "Keine" )
						else
							outputChatBox ( "Du hast keine Waffe in der Hand!", 125, 0, 0 )
						end
					else
						outputChatBox ( "Du hast bereits eine Waffe eingelagert!", 125, 0, 0 )
					end
				elseif source == gButton["trunkStoreDrugs"] then
					if vioClientGetElementData("drugs") >= drugsValue then
						triggerServerEvent ( "trunkStorageServer", lp, "drugs", drugsValue, false )
						dgsSetText ( gLabel["trunkDrugs"], ( drugs + drugsValue ).." g" )
					else
						outputChatBox ( "Du nicht so viele Drogen!", 125, 0, 0 )
					end
				else
					if vioClientGetElementData("mats") >= matsValue then
						triggerServerEvent ( "trunkStorageServer", lp, "mats", matsValue, false )
						dgsSetText ( gLabel["trunkMats"], ( mats + matsValue ).." Stk." )
					else
						outputChatBox ( "Du nicht so viele Materialien!", 125, 0, 0 )
					end
				end
			end
		end
	end
end