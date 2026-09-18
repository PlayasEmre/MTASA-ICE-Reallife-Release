--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local loehne_payday = {}

for i = 1, 15, 1 do
	loehne_payday[i] = {}
end

loehne_payday[1][0] = 100
loehne_payday[1][1] = 250
loehne_payday[1][2] = 450
loehne_payday[1][3] = 750
loehne_payday[1][4] = 850
loehne_payday[1][5] = 1000

loehne_payday[2][0] = 100
loehne_payday[2][1] = 250
loehne_payday[2][2] = 450
loehne_payday[2][3] = 750
loehne_payday[2][4] = 850
loehne_payday[2][5] = 1000

loehne_payday[3][0] = 100
loehne_payday[3][1] = 250
loehne_payday[3][2] = 450
loehne_payday[3][3] = 750
loehne_payday[3][4] = 850
loehne_payday[3][5] = 1000

loehne_payday[4][0] = 100
loehne_payday[4][1] = 250
loehne_payday[4][2] = 450
loehne_payday[4][3] = 750
loehne_payday[4][4] = 850
loehne_payday[4][5] = 1000

loehne_payday[5][0] = 100
loehne_payday[5][1] = 250
loehne_payday[5][2] = 450
loehne_payday[5][3] = 750
loehne_payday[5][4] = 850
loehne_payday[5][5] = 1000

loehne_payday[6][0] = 100
loehne_payday[6][1] = 250
loehne_payday[6][2] = 450
loehne_payday[6][3] = 750
loehne_payday[6][4] = 850
loehne_payday[6][5] = 1000

loehne_payday[7][0] = 100
loehne_payday[7][1] = 250
loehne_payday[7][2] = 450
loehne_payday[7][3] = 750
loehne_payday[7][4] = 850
loehne_payday[7][5] = 1000

loehne_payday[8][0] = 100
loehne_payday[8][1] = 250
loehne_payday[8][2] = 450
loehne_payday[8][3] = 750
loehne_payday[8][4] = 850
loehne_payday[8][5] = 1000

loehne_payday[9][0] = 100
loehne_payday[9][1] = 250
loehne_payday[9][2] = 450
loehne_payday[9][3] = 750
loehne_payday[9][4] = 850
loehne_payday[9][5] = 1000

loehne_payday[10][0] = 100
loehne_payday[10][1] = 250
loehne_payday[10][2] = 450
loehne_payday[10][3] = 750
loehne_payday[10][4] = 850
loehne_payday[10][5] = 1000

loehne_payday[11][0] = 100
loehne_payday[11][1] = 250
loehne_payday[11][2] = 450
loehne_payday[11][3] = 750
loehne_payday[11][4] = 850
loehne_payday[11][5] = 1000

loehne_payday[12][0] = 100
loehne_payday[12][1] = 250
loehne_payday[12][2] = 450
loehne_payday[12][3] = 750
loehne_payday[12][4] = 850
loehne_payday[12][5] = 1000

loehne_payday[13][0] = 100
loehne_payday[13][1] = 250
loehne_payday[13][2] = 450
loehne_payday[13][3] = 750
loehne_payday[13][4] = 850
loehne_payday[13][5] = 1000

loehne_payday[14][0] = 100
loehne_payday[14][1] = 250
loehne_payday[14][2] = 450
loehne_payday[14][3] = 750
loehne_payday[14][4] = 850
loehne_payday[14][5] = 1000

loehne_payday[15][0] = 100
loehne_payday[15][1] = 250
loehne_payday[15][2] = 450
loehne_payday[15][3] = 750
loehne_payday[15][4] = 850
loehne_payday[15][5] = 1000


function payday ( player )

	if math.floor ( MtxGetElementData ( player, "playingtime" ) / 60 ) == ( MtxGetElementData ( player, "playingtime" ) / 60 ) then
	    local paket = MtxGetElementData ( player, "Paket" )
		local player_payday = {}
		
		local faction = getPlayerFaction ( player )
		local rank = getPlayerRank ( player )
		player_payday["Boni"] = tonumber(MtxGetElementData( player, "boni" )) 
		
		if isEvil ( player ) then
		
			player_payday["Zuschuesse"] = loehne_payday[faction][rank]
			
		else
		
			player_payday["Zuschuesse"] = 1000
			
		end
		
		if isStateFaction ( player ) then
		
			local incoming = tonumber(MtxGetElementData( player, "pdayincome" ))
			local multiplikator
			
			if incoming > 50 then
				multiplikator = 1
			elseif incoming > 40 then
				multiplikator = 5/6
			elseif incoming > 30 then
				multiplikator = 4/6
			elseif incoming > 20 then
				multiplikator = 3/6
			elseif incoming > 10 then
				multiplikator = 2/6
			else
				multiplikator = 1/6
			end
			
			local var = math.floor(loehne_payday[faction][rank] * multiplikator)
		
			player_payday["Lohn"] = var
			
		elseif faction >= 1 then
		
			player_payday["Lohn"] = loehne_payday[faction][rank]
			
		else
		
			player_payday["Lohn"] = 0
		
		end
		
		local grund 
		local costs
		
		if MtxGetElementData ( player, "handyType" ) == 1 then
			grund = 10
			costs = tonumber(MtxGetElementData( player, "handyCosts" ))
		elseif MtxGetElementData ( player, "handyType" ) == 2 then
			grund = 0
			costs = 0
		else
			grund = 50
			costs = 0
		end
		
		player_payday["Handykosten"] = grund + costs
		
		local club = MtxGetElementData ( player, "club" )
		
		if club == "gartenverein" then
			player_payday["Clubkosten"] = 30
			outputChatBox ( "Um deine Clubmitgliedschaft zu kündigen, tippe /leaveclub", player, 125, 0, 0 )
		elseif club == "biker" then
			player_payday["Clubkosten"] = 50
			bizArray["MistysBar"]["kasse"] = bizArray["MistysBar"]["kasse"] + 50
			outputChatBox ( "Um deine Clubmitgliedschaft zu kündigen, tippe /leaveclub", player, 125, 0, 0 )
		elseif club == "rc" then
			player_payday["Clubkosten"] = 50
			outputChatBox ( "Um deine Clubmitgliedschaft zu kündigen, tippe /leaveclub", player, 125, 0, 0 )
		else
			player_payday["Clubkosten"] = 0
		end
		local var_zinsen = MtxGetElementData( player, "bankmoney" ) * 0.003
		local Zinsen = math.floor(var_zinsen)
		
		if Zinsen > 300 then
			player_payday["Zinsen"] = 300
		else
			player_payday["Zinsen"] = Zinsen
		end
		
		player_payday["Fahrzeugsteuer"] = math.floor( MtxGetElementData(player, "curcars") * 75 )
		if MtxGetElementData ( player, "married" ) == 1 then
			player_payday["Fahrzeugsteuer"] = math.floor( player_payday["Fahrzeugsteuer"] * 0.8 )
		end
		
		rent = 0
		
		if MtxGetElementData ( player, "housekey" ) < 0 then
			local ID = math.abs(MtxGetElementData ( player, "housekey" ))
			local haus = houses["pickup"][ID]
			rent = MtxGetElementData ( haus, "miete" )
			local Kasse = tonumber ( (dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Kasse", "houses", "ID", ID ))[1]["Kasse"] )
			dbExec ( handler, "UPDATE ?? SET ?? = ? WHERE ID = ?", "houses", "Kasse", Kasse + rent, ID )
		end
		
		player_payday["Miete"] = rent
		
		if MtxGetElementData ( player, "socialState" ) == "Rentner" then
			player_payday["Zuschuesse"] = player_payday["Zuschuesse"] + 100
		end
		
		local amount = factionGangAreas[faction] or 0
						
		if MtxGetElementData ( player, "stvo_punkte" ) >= 1 then
			MtxSetElementData ( player, "stvo_punkte", MtxGetElementData ( player, "stvo_punkte" ) - 1 )
			outputChatBox ( "Dir wurde soeben 1 STVO Punkt erlassen!", player, 125, 0, 0 )
		end


		if math.floor ( tonumber ( MtxGetElementData ( player, "playingtime" ) ) / 120 ) == ( tonumber ( MtxGetElementData ( player, "playingtime" ) ) / 120 ) and tonumber ( MtxGetElementData ( player, "wanteds" ) ) >= 1 then
			MtxSetElementData ( player, "wanteds", MtxGetElementData ( player, "wanteds" ) - 1 )
			setPlayerWantedLevel ( player, MtxGetElementData ( player, "wanteds" ) )
			outputChatBox ( "Dir wurde soeben 1 Wantedpunkt erlassen!", player, 125, 0, 0 )
		end
						
		outputChatBox ( "|___Zahltag___|", player, 0, 200, 0 )
		outputChatBox ( "Einkommen:", player, 200, 200, 0 )
		outputChatBox ( "Job: "..player_payday["Lohn"]..""..Tables.waehrung.."; Boni: "..player_payday["Boni"]..""..Tables.waehrung.."; Zuschüsse: "..player_payday["Zuschuesse"]..""..Tables.waehrung..";", player, 200, 200, 0 )
		outputChatBox ( "Kosten:", player, 200, 200, 0 )
		outputChatBox ( "Handykosten: "..player_payday["Handykosten"]..""..Tables.waehrung..";", player, 200, 200, 0 )
		outputChatBox ( "Club: "..player_payday["Clubkosten"]..""..Tables.waehrung.."; Fahrzeugsteuer: "..player_payday["Fahrzeugsteuer"]..""..Tables.waehrung.."; Miete: "..player_payday["Miete"]..""..Tables.waehrung..";", player, 200, 200, 0 )
		outputChatBox ( "Zinsen: "..player_payday["Zinsen"].." "..Tables.waehrung.."", player, 200, 200, 0 )
		
		if amount > 0 then
			player_payday["Gangarea"] = amount * 100
			outputChatBox ( "Einnahmen durch Ganggebiete: "..player_payday["Gangarea"]..""..Tables.waehrung.."", player, 0, 200, 0 )
		else
			player_payday["Gangarea"] = 0
		end
		
		player_payday["Gesamt"] = player_payday["Lohn"] + player_payday["Boni"] + player_payday["Zuschuesse"] - player_payday["Handykosten"] - player_payday["Clubkosten"] - player_payday["Fahrzeugsteuer"] - player_payday["Miete"] + player_payday["Zinsen"] + player_payday["Gangarea"]
		
		
		outputChatBox ( "_______________", player, 125, 0, 0 )
		outputChatBox ( "Einnahmen: "..player_payday["Gesamt"]..""..Tables.waehrung.." ", player, 0, 200, 0 )
		outputChatBox ( "Die Einnahmen wurden auf dein Konto überwiesen!", player, 125, 0, 125 )
		
		if event.isHalloween then
			local eggs = MtxGetElementData ( player, "kuerbisse" )
			MtxSetElementData ( player, "kuerbisse", eggs + 1 )
			outputChatBox ( "Außerdem hast du einen Kürbis bekommen. Loese ihn mit /halloween ein!", player, 0, 125, 0 )
		end
		
		
		vipMoney = math.floor((player_payday["Gesamt"]/100)*vipPayDayExtra[paket])
		outputChatBox ( "Premium Geld: "..vipMoney..""..Tables.waehrung.." ", player, 0, 200, 0 )
		player_payday["Gesamt"] = player_payday["Gesamt"] + vipMoney
			
		--//Event
	    if event.ispaydaycoins == true then
			MtxSetElementData(player,"coins",tonumber(MtxGetElementData(player,"coins"))+10)
			givePlayerEXP(player,10)
			outputChatBox("Payday-Event: Du erhältst 10 Coins",player,255,255,255)
			outputChatBox("Payday-Event: Du erhältst 10 EXP",player,255,255,255)
		end
		
		triggerClientEvent ( player, "createNewStatementEntry", player, "Abrechnung\n", player_payday["Gesamt"], "\n" )

		MtxSetElementData ( player, "pdayincome", 0 )
		MtxSetElementData ( player, "boni", 0 )

		triggerClientEvent ( player, "achievsound", player )

		MtxSetElementData ( player, "bankmoney", MtxGetElementData ( player, "bankmoney" ) + player_payday["Gesamt"] )
		datasave_remote ( player )
	end
end

function playingtime ( player )

	if isElement ( player ) then
	
		if MtxGetElementData ( player, "loggedin" ) == 1 then
		
			setPlayerWantedLevel ( player, tonumber( MtxGetElementData ( player, "wanteds" ) ))
			local pname = getPlayerName ( player )
			MtxSetElementData ( player, "lastcrime", "none" )
			
			if not MtxGetElementData ( player, "isafk" ) then
				MtxSetElementData ( player, "curplayingtime", MtxGetElementData ( player, "curplayingtime" ) + 1 )						-- Achiev: Schlaflos in SA, 12 Stunden am St??zocken, 30 Punkte
				
				if math.random ( 1, 10 ) == 1 then
					checkForSymptoms ( player )
				end
					
				if math.floor ( MtxGetElementData ( player, "curplayingtime" ) / 3 ) == MtxGetElementData ( player, "curplayingtime" ) / 3 then
					lowerFlush ( player )
				elseif math.floor ( MtxGetElementData ( player, "curplayingtime" ) / 20 ) == MtxGetElementData ( player, "curplayingtime" ) / 20 then
					lowerAddict ( player )
				end
					
				MtxSetElementData ( player, "playingtime", MtxGetElementData ( player, "playingtime" ) + 1 )								-- Spielzeit
			
				local jailed = tonumber( MtxGetElementData ( player, "jailtime" ) )
				
				if jailed > 1 then
				
					MtxSetElementData ( player, "jailtime", jailed - 1 )
					
				elseif jailed == 1 then
				
					freePlayerFromJail ( player )
						
				end
				
				local prisonjailed = tonumber( MtxGetElementData ( player, "prison" ) )
				
				if prisonjailed > 1 then
				
					MtxSetElementData ( player, "prison", prisonjailed - 1 )
					
				elseif prisonjailed == 1 then
				
					freePlayerFromJail ( player )
						
				end 
					
				if tonumber ( MtxGetElementData ( player, "jobtime" ) ) ~= 0 then
					MtxSetElementData ( player, "jobtime", tonumber ( MtxGetElementData ( player, "jobtime" ) ) - 1 )
				end
			
			
				if isOnDuty ( player ) or isArmy ( player ) then	
				
					if isFBI(player) then
						bonus = 1.2
					else
						bonus = 1
					end
					
					local income = tonumber(MtxGetElementData( player, "pdayincome" ))
					MtxSetElementData ( player, "pdayincome", income+1 )

				end
			
				payday ( player )
				dbExec ( handler, "UPDATE ?? SET ??=?, ??=? WHERE ??=?", "userdata", "Bankgeld", MtxGetElementData ( player, "bankmoney"), "Geld", MtxGetElementData ( player, "money" ), "UID", playerUID[pname] )
				ReallifeAchievCheck ( player )
				

				MtxSetElementData ( player, "timePlayedToday", MtxGetElementData ( player, "timePlayedToday" ) + 1 )
				
				if MtxGetElementData ( player, "timePlayedToday" ) >= 720 and MtxGetElementData ( player, "schlaflosinsa" ) ~= "done" then						-- Achiev: Schlaflos in SA, 12 Stunden am St??zocken, 30 Punkte
					triggerClientEvent ( player, "showAchievmentBox", player, "Schlaflos in SA", 50, 10000 )													-- Achiev: Schlaflos in SA, 12 Stunden am St??zocken, 30 Punkte
					MtxSetElementData ( player, "bonuspoints", MtxGetElementData ( player, "bonuspoints" ) + 50 )												-- Achiev: Schlaflos in SA, 12 Stunden am St??zocken, 30 Punkte
					MtxSetElementData ( player, "schlaflosinsa", "done" )																						-- Achiev: Schlaflos in SA, 12 Stunden am St??zocken, 30 Punkte
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "SchlaflosInSA", "done", "UID", playerUID[getPlayerName ( player )] )										-- Achiev: Schlaflos in SA, 12 Stunden am St??zocken, 30 Punkte
				end	
			end
			
				
		end
			
	end
	
end