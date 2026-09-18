--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

promptPath = "vio_stored_files/prompt/prompt.ice"
local promptFile = fileOpen ( promptPath, true )
local filesize = fileGetSize ( promptFile  )
promptMainText = fileRead( promptFile, filesize )
fileClose ( promptFile )

function prompt ( player, text, time )

	triggerClientEvent ( player, "prompt", player, text, time )
end

function changePrompt ( player, cmd, ... )

	if ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 4 then
		local msg = table.concat ( arg, " " )
		
		local file = fileCreate ( promptPath )
		fileWrite ( file, msg )
		fileClose ( file )
		
		promptMainText = msg
		
		dbExec ( handler, "UPDATE ?? SET ?? = ?", "userdata", "pred", "0" )
		
		outputChatBox ( "Erfolgreich geändert!", player, 0, 200, 0 )
	end
end
addCommandHandler ( "changeprompt", changePrompt )