--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function isSerialValid ( serial )
	if serial then
		
		for i = 1, #serial do
			local sub = string.sub ( serial, i, i )
			if not ( isNumber ( sub ) or isLetter ( sub ) ) then -- Ueberpruefe ob Buchstabe oder Zahl.
				return false
			end
		end
		
		if not (string.len(serial) == 32) then -- Ueberpruefe laenge
			return false
		end
		
		return true
		
	else
		return false
	end
end

function isNumber ( char )
	if tonumber ( char ) then
		return true
	else
		return false
	end
end

function isLetter ( char )
	if not isNumber ( char ) then
		if not ( string.upper ( char ) == string.lower ( char ) ) then
			if isValidSerialChar(char) then -- Ueberpruefe 1-F
				return true
			else
				return false
			end
		end
	end
	return false
end

function isValidSerialChar(char)
	if char then
		local char = string.lower(char)
		if char == "a" or char == "b" or char == "c" or char == "d" or char == "e" or char == "f" then
			return true
		else
			return false
		end
	else
		return false
	end
end