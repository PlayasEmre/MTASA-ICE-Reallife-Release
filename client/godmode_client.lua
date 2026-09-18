function setInvulnerable ( bool )
	invulnerable = bool
end

function isInvulnerable ()
	return invulnerable
end

function godModeHandler ()
	if invulnerable then
		outputChatBox("Du bist unsterblich!", 255, 0, 0)
		cancelEvent()
	end
end
addEventHandler ( "onClientPedDamage", localPlayer, godModeHandler )