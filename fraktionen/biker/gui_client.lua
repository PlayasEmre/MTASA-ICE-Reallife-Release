--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function bikerKnockingOff ( bool )

	setPedCanBeKnockedOffBike ( lp, bool )

end
addEvent( "onBikerBoolGiven", true )
addEventHandler( "onBikerBoolGiven", getRootElement(), bikerKnockingOff )