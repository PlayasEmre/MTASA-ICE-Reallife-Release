--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function skillDataLoad ( player )

	local pname = getPlayerName ( player )
	setFishingValues ( player )
	local result = dbQueryCoro ( "SELECT ??, ?? FROM ?? WHERE ??=?", "fishing", "gamble", "skills", "UID", playerUID[pname] )
	if result and result[1] then
		MtxSetElementData ( player, "fishingSkill", tonumber ( result[1]["fishing"] ) )
		MtxSetElementData ( player, "fishingSkillOld", MtxGetElementData ( player, "fishingSkill" ) )
		MtxSetElementData ( player, "gambleSkill", tonumber ( result[1]["gamble"] ) )
	end
end

function skillDataSave ( player )

	local pname = getPlayerName ( player )
	if MtxGetElementData ( player, "fishingSkill" ) > MtxGetElementData ( player, "fishingSkillOld" ) then
		dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "skills", "fishing", MtxGetElementData ( player, "fishingSkill" ), "UID", playerUID[pname] )
	end
	saveFishingValues ( player )
	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "skills", "gamble", MtxGetElementData ( player, "gambleSkill" ), "UID", playerUID[pname] )
end