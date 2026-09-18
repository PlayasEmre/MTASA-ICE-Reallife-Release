--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

function wDealerWindow()

	showCursor ( true )
	if gWindow["waffendealer"] then
		dgsSetVisible ( gWindow["waffendealer"], true )
		dgsBringToFront ( gWindow["waffendealer"] )
	else
		local screenwidth, screenheight = guiGetScreenSize ()

		gWindow["waffendealer"] = dgsCreateWindow(screenwidth/2-365/2,145,365,399,"Waffen Menue",false)
		dgsBringToFront ( gWindow["waffendealer"] )
		gLabel["waffenname"] = dgsCreateLabel(50,30,76,14,"Waffenname",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["waffenname"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["waffenname"],"top")
		dgsLabelSetHorizontalAlign(gLabel["waffenname"],"left",false)
		dgsSetFont(gLabel["waffenname"],"default-bold")
		gLabel["materialkosten"] = dgsCreateLabel(165,29,88,15,"Materialkosten",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["materialkosten"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["materialkosten"],"top")
		dgsLabelSetHorizontalAlign(gLabel["materialkosten"],"left",false)
		dgsSetFont(gLabel["materialkosten"],"default-bold")
		gLabel["kosten9mmsd"] = dgsCreateLabel(191,61,77,13,"10",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["kosten9mmsd"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["kosten9mmsd"],"top")
		dgsLabelSetHorizontalAlign(gLabel["kosten9mmsd"],"left",false)

		gButton["verkaufen"] = dgsCreateButton(73,354,102,20,"Verkaufen",false,gWindow["waffendealer"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["WDealerAbbrechen"] = dgsCreateButton(200,354,102,20,"Abbrechen",false,gWindow["waffendealer"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		addEventHandler("onDgsMouseClickUp", gButton["WDealerAbbrechen"], SubmitWDealerAbbrechenBtn, false)
		addEventHandler("onDgsMouseClickUp", gButton["verkaufen"], SubmitSellgun, false)

		gLabel["kosten9mm"] = dgsCreateLabel(193,87,77,13,"7",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["kosten9mm"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["kosten9mm"],"top")
		dgsLabelSetHorizontalAlign(gLabel["kosten9mm"],"left",false)
		gLabel["munition"] = dgsCreateLabel(287,29,55,13,"Munition",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["munition"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["munition"],"top")
		dgsLabelSetHorizontalAlign(gLabel["munition"],"left",false)
		dgsSetFont(gLabel["munition"],"default-bold")

		gLabel["munition9mmsd"] = dgsCreateLabel(301,61,48,13,"0",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["munition9mmsd"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["munition9mmsd"],"top")
		dgsLabelSetHorizontalAlign(gLabel["munition9mmsd"],"left",false)
		gLabel["munition9mm"] = dgsCreateLabel(301,87,55,14,"0",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["munition9mm"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["munition9mm"],"top")
		dgsLabelSetHorizontalAlign(gLabel["munition9mm"],"left",false)
		gLabel["kostendeserteagle"] = dgsCreateLabel(193,112,77,13,"12",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["kostendeserteagle"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["kostendeserteagle"],"top")
		dgsLabelSetHorizontalAlign(gLabel["kostendeserteagle"],"left",false)
		gLabel["munitiondeserteagle"] = dgsCreateLabel(301,110,50,15,"0",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["munitiondeserteagle"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["munitiondeserteagle"],"top")
		dgsLabelSetHorizontalAlign(gLabel["munitiondeserteagle"],"left",false)
		gLabel["kostenshotgun"] = dgsCreateLabel(193,136,77,13,"10",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["kostenshotgun"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["kostenshotgun"],"top")
		dgsLabelSetHorizontalAlign(gLabel["kostenshotgun"],"left",false)
		gLabel["munitionshotgun"] = dgsCreateLabel(301,135,46,13,"0",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["munitionshotgun"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["munitionshotgun"],"top")
		dgsLabelSetHorizontalAlign(gLabel["munitionshotgun"],"left",false)
		gLabel["kostenmp5"] = dgsCreateLabel(193,160,77,13,"14",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["kostenmp5"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["kostenmp5"],"top")
		dgsLabelSetHorizontalAlign(gLabel["kostenmp5"],"left",false)
		gLabel["munitionmp5"] = dgsCreateLabel(301,160,44,13,"0",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["munitionmp5"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["munitionmp5"],"top")
		dgsLabelSetHorizontalAlign(gLabel["munitionmp5"],"left",false)
		gLabel["kostenmesser"] = dgsCreateLabel(193,184,77,13,"3",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["kostenmesser"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["kostenmesser"],"top")
		dgsLabelSetHorizontalAlign(gLabel["kostenmesser"],"left",false)
		gLabel["testeR"] = dgsCreateLabel(301,185,43,13,"0",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["testeR"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["testeR"],"top")
		dgsLabelSetHorizontalAlign(gLabel["testeR"],"left",false)
		gLabel["kostengewehr"] = dgsCreateLabel(193,206,77,13,"10",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["kostengewehr"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["kostengewehr"],"top")
		dgsLabelSetHorizontalAlign(gLabel["kostengewehr"],"left",false)
		gLabel["munitiongewehr"] = dgsCreateLabel(301,207,46,13,"0",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["munitiongewehr"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["munitiongewehr"],"top")
		dgsLabelSetHorizontalAlign(gLabel["munitiongewehr"],"left",false)
		gLabel["kostenak47"] = dgsCreateLabel(193,229,77,13,"20",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["kostenak47"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["kostenak47"],"top")
		dgsLabelSetHorizontalAlign(gLabel["kostenak47"],"left",false)
		gLabel["munitionak47"] = dgsCreateLabel(301,228,54,13,"0",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["munitionak47"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["munitionak47"],"top")
		dgsLabelSetHorizontalAlign(gLabel["munitionak47"],"left",false)
		gEdit["munitionmaterialien"] = dgsCreateEdit(282,266,59,21,"",false,gWindow["waffendealer"])
		gLabel["kostenmaterialen"] = dgsCreateLabel(196,270,77,13,"-",false,gWindow["waffendealer"])
		dgsLabelSetColor(gLabel["kostenmaterialen"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["kostenmaterialen"],"top")
		dgsLabelSetHorizontalAlign(gLabel["kostenmaterialen"],"left",false)

		gRadio["9mmsd"] = dgsCreateRadioButton(26,63,100,15,"9mm Schallgedaempft",false,gWindow["waffendealer"])
		dgsRadioButtonSetSelected(gRadio["9mmsd"],true)
		gRadio["9mm"] = dgsCreateRadioButton(26,88,100,15,"9mm",false,gWindow["waffendealer"])
		gRadio["deserteagle"] = dgsCreateRadioButton(26,113,100,15,"Desert Eagle",false,gWindow["waffendealer"])
		gRadio["shotgun"] = dgsCreateRadioButton(26,137,100,15,"Shotgun",false,gWindow["waffendealer"])
		gRadio["gewehr"] = dgsCreateRadioButton(26,207,100,15,"Gewehr",false,gWindow["waffendealer"])
		gRadio["messer"] = dgsCreateRadioButton(26,184,100,15,"Messer",false,gWindow["waffendealer"])
		gRadio["ak47"] = dgsCreateRadioButton(26,230,70,15,"AK-47",false,gWindow["waffendealer"])
		gRadio["materialien"] = dgsCreateRadioButton(26,269,100,15,"Materialien",false,gWindow["waffendealer"])
		gRadio["mp5"] = dgsCreateRadioButton(26,161,70,15,"MP5",false,gWindow["waffendealer"])
	end
end

function SubmitSellgun ( btn )

	if btn ~= nil and btn ~= "left" then return end
	local ammo = 0
	if dgsRadioButtonGetSelected(gRadio["9mmsd"] ) then
		gun = "9mmsd"
	elseif dgsRadioButtonGetSelected(gRadio["9mm"] ) then
		gun = "9mm"
	elseif dgsRadioButtonGetSelected(gRadio["deserteagle"] ) then
		gun = "eagle"
	elseif dgsRadioButtonGetSelected(gRadio["shotgun"] ) then
		gun = "shotgun"
	elseif dgsRadioButtonGetSelected(gRadio["mp5"] ) then
		gun = "mp5"
	elseif dgsRadioButtonGetSelected(gRadio["messer"] ) then
		gun = "messer"
	elseif dgsRadioButtonGetSelected(gRadio["gewehr"] ) then
		gun = "gewehr"
	elseif dgsRadioButtonGetSelected(gRadio["ak47"] ) then
		gun = "ak47"
	elseif dgsRadioButtonGetSelected(gRadio["materialien"] ) then
		gun = "mats"
		ammo = tonumber ( dgsGetText ( gEdit["munitionmaterialien"] ) )
	end
	local target = vioClientGetElementData ( "curclicked" )
	triggerServerEvent ( "sellgun", localPlayer, localPlayer, "haha", target, gun, ammo )
end

function SubmitWDealerAbbrechenBtn ( btn )

	if btn ~= nil and btn ~= "left" then return end
	dgsSetVisible(gWindow["waffendealer"],false)
	showCursor ( false )
end