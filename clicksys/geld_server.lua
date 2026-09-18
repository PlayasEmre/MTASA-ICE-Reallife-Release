--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


local bankStatements = {}
local MAX_STATEMENTS = 10


function addStatementEntry(player, grund, betrag, sonstiges)
    if not bankStatements[player] then
        bankStatements[player] = {}
    end

    local entry = {
        grund = grund,
        betrag = betrag,
        sonstiges = sonstiges
    }
    table.insert(bankStatements[player], 1, entry)


    if #bankStatements[player] > MAX_STATEMENTS then
        table.remove(bankStatements[player], #bankStatements[player])
    end
end



function requestRecentStatements_func()
    local thePlayer = client or source
    if isElement(thePlayer) then
        local statements = bankStatements[thePlayer] or {}
        triggerClientEvent(thePlayer, "receiveRecentStatements", thePlayer, statements)
    end
end

addEvent("requestRecentStatements", true)
addEventHandler("requestRecentStatements", root, requestRecentStatements_func)


function pay_func ( player, cmd, target, money )
	local money = tonumber ( money )
	if target and getPlayerFromName ( target ) then
		local target = getPlayerFromName ( target )
		if target and money then
			money = math.abs ( math.floor ( money + 0.5 ) )
			local pmoney = MtxGetElementData ( player, "money" )
			if pmoney >= money then
				local x1, y1, z1 = getElementPosition ( player )
				local x2, y2, z2 = getElementPosition ( target )
				if getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 ) <= 5 then
					if MtxGetElementData ( player, "playingtime" ) >= 180 then
						if not MtxGetElementData ( player, "gotdamoney" ) then
							takePlayerSaveMoney ( player, money )
							givePlayerSaveMoney ( target, money )
							meCMD_func ( player, "meCMD", "steckt "..getPlayerName ( target ).." ein paar Scheine zu..." )
							infobox ( target, "Du hast von\n"..getPlayerName ( player ).." "..money.." "..Tables.waehrung.."\nerhalten!", 5000, 0, 200, 0 )
							infobox ( player, "Du hast \n"..getPlayerName ( target ).." "..money.." "..Tables.waehrung.."\ngegeben!", 5000, 150, 0, 0 )
						else
							infobox ( player, "Du darfst\nnoch kein Geld\ngeben!!", 5000, 150, 0, 0 )
						end
					else
						infobox ( player, "\nErst ab 3\nStunden moeglich!", 5000, 150, 0, 0 )
					end
				else
					infobox ( player, "\nDu bist zu\nweit entfernt!", 5000, 150, 0, 0 )
				end
			else
				infobox ( player, "\nSoviel Geld hast\ndu nicht!", 5000, 150, 0, 0 )
			end
		else
			infobox ( player, "\nGebrauch:\n/pay [Name] [Summe]", 5000, 150, 0, 0 )
		end
	end
end
addCommandHandler ( "pay", pay_func )

function moneychange ( player, betrag )
	MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + betrag )
	playSoundFrontEnd ( player, 40 )
end

function givePlayerSaveMoney ( player, amount )
	local amount = tonumber ( amount )
	if isElement ( player ) and amount then
		MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + amount )
		playSoundFrontEnd ( player, 40 )
	end
end

function takePlayerSaveMoney ( player, amount )
	local amount = tonumber ( amount )
	if isElement ( player ) and amount then
		MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - amount )
		playSoundFrontEnd ( player, 40 )
	end
end


function showBankMoney_func ()
	if source == source then
		local bankmoney = MtxGetElementData ( source, "bankmoney" )
		outputChatBox ("Du hast "..bankmoney.." "..Tables.waehrung.." auf der Bank.", source, 0, 0, 255 )
	end
end
addEvent ( "showBankMoney", true )
addEventHandler ("showBankMoney", getRootElement(), showBankMoney_func )

function cashPointPayIn_func ( summe )
	if summe then
		local summe = math.abs(math.floor(tonumber(summe)))
		if source == client then
			if MtxGetElementData ( source, "money" ) >= tonumber(summe) and not MtxGetElementData ( source, "gotdamoney") then
				outputChatBox ("Du hast "..tonumber(summe).." "..Tables.waehrung.." eingezahlt!", source, 0, 0, 255 )
				MtxSetElementData ( source, "money", MtxGetElementData ( source, "money" ) - tonumber(summe) )
				MtxSetElementData ( source, "bankmoney", MtxGetElementData ( source, "bankmoney" ) + tonumber(summe) )
				playSoundFrontEnd ( source, 40 )
				addStatementEntry(source, "Einzahlung", summe, "Geldautomat "..getPlaceOfPlayer(source))
			end
		end
	end
end
addEvent ( "cashPointPayIn", true )
addEventHandler ( "cashPointPayIn", getRootElement(), cashPointPayIn_func )

function getPlaceOfPlayer ( player )
	local x, y, z = getElementPosition ( player )
	return getZoneName ( x, y, z, true )
end

function cashPointPayOut_func ( summe )
	if not tonumber(summe) then return end
	local summe = math.abs(math.floor(tonumber(summe)))
	if source == client then
		if MtxGetElementData ( source, "bankmoney" ) >= tonumber(summe) then
			outputChatBox ("Du hast "..tonumber(summe).." "..Tables.waehrung.." abgehoben!", source, 0, 0, 255 )
			MtxSetElementData ( source, "bankmoney", MtxGetElementData ( source, "bankmoney" ) - tonumber(summe) )
			MtxSetElementData ( source, "money", MtxGetElementData ( source, "money" ) + tonumber(summe) )
			playSoundFrontEnd ( source, 40 )
			addStatementEntry(source, "Auszahlung", summe * -1, "Geldautomat "..getPlaceOfPlayer(source))
		end
	end
end
addEvent ( "cashPointPayOut", true )
addEventHandler ( "cashPointPayOut", getRootElement(), cashPointPayOut_func )

function Spenden_func ( summe )
	local summe = math.abs(math.floor(tonumber(summe)))
	if source == client then
		if MtxGetElementData ( source, "bankmoney" ) >= tonumber(summe) and not MtxGetElementData ( source, "gotdamoney") then
			outputChatBox ("Du hast "..tonumber(summe).." "..Tables.waehrung.." gespendet!", source, 0, 0, 255 )
			MtxSetElementData ( source, "bankmoney", MtxGetElementData ( source, "bankmoney" ) - tonumber(summe) )
			playSoundFrontEnd ( source, 40 )
            addStatementEntry(source, "Spende", summe * -1, "an Organisation")
		end
	end
end
addEvent ( "Spenden", true )
addEventHandler ("Spenden", getRootElement(), Spenden_func )

function cashPointTransfer_func ( summe, ziel, online, reason )
	if source == client then
		if online then
			MtxSetElementData ( source, "bankmoney", MtxGetElementData ( source, "bankmoney" ) - 10 )
			reason = "Onlineueberweisung"
		end
		local summe = math.abs(math.floor(tonumber(summe)))
		if MtxGetElementData ( source, "playingtime" ) >= Tables.noobtime then
			if getPlayerFromName ( ziel ) then
				if tonumber(summe) >= 1 then
					if MtxGetElementData ( source, "bankmoney" ) >= tonumber(summe) then
						local player = getPlayerFromName ( ziel )
						if MtxGetElementData ( player, "loggedin" ) == 1 then
							MtxSetElementData ( source, "bankmoney", MtxGetElementData ( source, "bankmoney" ) - tonumber(summe) )
							MtxSetElementData ( player, "bankmoney", MtxGetElementData ( player, "bankmoney" ) + tonumber(summe) )
							outputChatBox ( "Du hast von "..getPlayerName(source).." "..tonumber(summe).." "..Tables.waehrung.." erhalten ("..reason..")!", player, 0, 255, 0 )
							outputChatBox ( "Du hast "..getPlayerName(player).." "..tonumber(summe).." "..Tables.waehrung.." ueberwiesen!", source, 0, 0, 255 )
							playSoundFrontEnd ( source, 40 )
							playSoundFrontEnd ( player, 40 )
							local playername = getPlayerName(source)
							if MtxGetElementData ( source, "playingtime" ) <= 180 then
								for playeritem, rang in pairs ( adminsIngame ) do
									if rang >= 1 then
										outputChatBox ( "Log: "..playername.." hat an "..ziel.." "..summe.." "..Tables.waehrung.." überwiesen!", playeritem, 200, 200, 0 )
									end
								end
							end
							outputLog ( "Log: "..playername.." hat an "..ziel.." "..summe.." "..Tables.waehrung.." überwiesen!", "Geld" )
							addStatementEntry(source, "Überweisung", summe * -1, "An "..getPlayerName(player))
                            addStatementEntry(player, "Überweisung", summe, "Von "..getPlayerName(source))
						else
							outputChatBox ("Der Spieler ist noch nicht eingeloggt!", source, 255, 0, 0 )
						end
					else
						outputChatBox ("Du hast nicht genug Geld!", source, 255, 0, 0 )
					end
				else
					outputChatBox ("Ungueltiger Betrag!", source, 255, 0, 0 )
				end
			else
				outputChatBox ("Du musst einen gueltigen Spielernamen eingeben!", source, 255, 0, 0 )
			end
		else
			outputChatBox ( "Du kannst erst ab 3 Stunden Spielzeit Geld vergeben!", source, 125, 0, 0 )
		end
	end
end
addEvent ( "Ueberweisen", true )
addEvent ( "cashPointTransfer", true )
addEventHandler ( "Ueberweisen", getRootElement(), cashPointTransfer_func )
addEventHandler ( "cashPointTransfer", getRootElement(), cashPointTransfer_func )

function geldgeben_func ( summe )
	if source == client then
		summe = tonumber ( summe )
		if summe and summe > 0 then
			summe = math.abs(math.floor(summe))
			if MtxGetElementData ( source, "playingtime" ) >= Tables.noobtime then
				local player = getPlayerFromName ( MtxGetElementData ( source, "curclicked" ) )
				if player then
					local x1, y1, z1 = getElementPosition ( source )
					local x2, y2, z2 = getElementPosition ( player )
					local summe = tonumber(summe)
					if summe <= MtxGetElementData ( source, "money" ) then
						if getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 ) <= 10 then
							MtxSetElementData ( source, "money", MtxGetElementData ( source, "money" ) - summe )
							MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + summe )
							setPlayerMoney( source, MtxGetElementData ( source, "money" ) )
							setPlayerMoney( player, MtxGetElementData ( player, "money" ) )
							outputChatBox ( "Du hast "..getPlayerName(player).. " "..summe.." "..Tables.waehrung.." gegeben!", source, 0, 255, 0 )
							outputChatBox ( "Du hast von "..getPlayerName(source).. " "..summe.." "..Tables.waehrung.." erhalten!", player, 0, 0, 255 )
							playSoundFrontEnd ( player, 40 )
							playSoundFrontEnd ( source, 40 )
						else
							outputChatBox ( "Du bist zu weit weg!", source, 255, 0, 0 )
						end
					else
						outputChatBox ( "Du hast nicht genug Geld!", source, 255, 0, 0 )
					end
				else
					outputChatBox ( "Spieler nicht gefunden!", source, 255, 0, 0 )
				end
			else
				outputChatBox ( "Du kannst erst ab 3 Stunden Spielzeit Geld vergeben!", source, 125, 0, 0 )
			end
		else
			outputChatBox ( "Ungültiger Betrag!", source, 255, 0, 0 )
		end
	end
end
addEvent ( "geldgeben", true )
addEventHandler ( "geldgeben", getRootElement(), geldgeben_func )