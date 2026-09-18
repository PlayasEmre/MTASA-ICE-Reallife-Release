--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function bindThatCursor()
	showCursor (not isCursorShowing ())
	if not isCursorShowing() then
		setElementClicked ( false )
	end
end
bindKey ("m", "down", bindThatCursor)
bindKey ("ralt", "down", bindThatCursor)


function showhmenue ( )
	if introCutsceneAktiv then return end -- Menue waehrend der Intro-Kamerafahrt gesperrt, siehe quest/intro_cutscene_client.lua
	if tonumber(getElementData ( localPlayer, "loggedin" )) == 1 then
		if not getElementClicked() then
			setElementClicked ( true )
			triggerEvent ( "ShowHelpmenueGui", root )
			showCursor ( true )
		end
	end
end
bindKey ("f1", "down", showhmenue)