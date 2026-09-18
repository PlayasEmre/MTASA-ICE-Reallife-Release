Fahrschule_Gate1 = createObject ( 9131, -1753.6, -112.6, 3.7, 0, 0, 0 )
Fahrschule_Gate2 = createObject ( 9131, -1753.6, -115.1, 3.7, 0, 0, 0 )
Fahrschule_Gate3 = createObject ( 9131, -1753.6, -117.6, 3.7, 0, 0, 0 )
Fahrschule_Gate4 = createObject ( 9131, -1753.6, -120.0, 3.7, 0, 0, 0 )

Fahrschule_Gate_Moving = false
Fahrschule_Gate_Moved = false
function Fahrschule_Gate_func ( player )
	if isOnDuty(player) or isFahrschule(player) then
		if getDistanceBetweenPoints3D ( -1753.7, -116.4, 3.7, getElementPosition ( player ) ) < 14 then
			if Fahrschule_Gate_Moving == false then
				Fahrschule_Gate_Moving = true
				if Fahrschule_Gate_Moved == false then
					moveObject ( Fahrschule_Gate1, 2000, -1753.6, -112.6, 1.4, 0, 0, 0 )
					moveObject ( Fahrschule_Gate2, 2000, -1753.6, -115.1, 1.4, 0, 0, 0 )
					moveObject ( Fahrschule_Gate3, 2000, -1753.6, -117.6, 1.4, 0, 0, 0 )
					moveObject ( Fahrschule_Gate4, 2000, -1753.6, -120.0, 1.4, 0, 0, 0 )
					setTimer ( triggerFahrschule_Gate_Varb, 3000, 1 )
					Fahrschule_Gate_Moved = true
				else
					moveObject ( Fahrschule_Gate1, 2000, -1753.6, -112.6, 3.7, 0, 0, 0 )
					moveObject ( Fahrschule_Gate2, 2000, -1753.6, -115.1, 3.7, 0, 0, 0 )
					moveObject ( Fahrschule_Gate3, 2000, -1753.6, -117.6, 3.7, 0, 0, 0 )
					moveObject ( Fahrschule_Gate4, 2000, -1753.6, -120.0, 3.7, 0, 0, 0 )
					setTimer ( triggerFahrschule_Gate_Varb, 3000, 1 )
					Fahrschule_Gate_Moved = false
				end
			end
		end
	end
end
addCommandHandler ( "mv", Fahrschule_Gate_func )

function triggerFahrschule_Gate_Varb ()
	Fahrschule_Gate_Moving = false
end