--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local sx,sy=guiGetScreenSize()
local components = { "weapon", "ammo", "health", "clock", "money", "breath", "armour", "wanted" }
local State = false
local progress = 0
local money = 0
local coins1 = 0   -- Coins-Anzeige fuer HUD-Stil 1 (HUD2 hat ihre eigene "coins"-Variable weiter unten)
local Health = 0
local Armor = 0
local Hunger = 0

--// Ausdauersystem (Sprint-Stamina) \\--
local staminaMax = 100
local stamina = staminaMax
local staminaDrainPerSec = 5           -- % Ausdauer, die pro Sekunde beim Rennen verloren geht
local staminaRegenPerSec = 3           -- % Ausdauer, die pro Sekunde regeneriert wird
local staminaRecoverThreshold = 60     -- % ab der wieder gerannt werden darf, nachdem die Ausdauer leer war
local staminaDisplayGrace = 6000       -- ms, wie lange nach dem Rennen noch die Ausdauerleiste statt des Hungers gezeigt wird
local staminaStartDelay = 4000         -- ms, wie lange man am Stück rennen muss, bevor die Ausdauerleiste statt des Hungers eingeblendet wird
local sprintContinuityGap = 6000       -- ms Toleranz für kurze Unterbrechungen (z.B. wenn CJ kurz verschnauft), bevor der Rennen-Timer neu startet
local staminaExhausted = false
local lastSprintTick = 0
local sprintStartTick = 0
local showingStamina = false
local lastStaminaTick = getTickCount()

function isShowingStamina()
	return showingStamina
end

function updateStamina()
	local now = getTickCount()
	local dt = (now - lastStaminaTick) / 1000
	lastStaminaTick = now

	if getElementData(localPlayer, "inTactic") == true then
		-- In der Tactic-Arena keine Ausdauer-Beschraenkung: Sprint bleibt immer
		-- moeglich, Ausdauerleiste bleibt aus.
		if staminaExhausted then
			staminaExhausted = false
			toggleControl("sprint", true)
		end
		stamina = staminaMax
		showingStamina = false
		return
	end

	local isSprinting = false
	if not staminaExhausted and isElement(localPlayer) and getElementHealth(localPlayer) > 0 and not isPedInVehicle(localPlayer) and getPedControlState(localPlayer, "sprint") then
		local moveState = getPedMoveState(localPlayer)
		if moveState ~= "stand" and moveState ~= "crouch" and moveState ~= "wait" and moveState ~= "wait_arm_folded" then
			isSprinting = true
		end
	end

	if isSprinting then
		if (now - lastSprintTick) > sprintContinuityGap then
			sprintStartTick = now
		end
		lastSprintTick = now

		stamina = math.max(0, stamina - staminaDrainPerSec * dt)
		if stamina <= 0 then
			staminaExhausted = true
			toggleControl("sprint", false)
		end

		if not showingStamina and (now - sprintStartTick) >= staminaStartDelay then
			showingStamina = true
		end
	else
		if stamina < staminaMax then
			stamina = math.min(staminaMax, stamina + staminaRegenPerSec * dt)
		end
		if staminaExhausted and stamina >= staminaRecoverThreshold then
			staminaExhausted = false
			toggleControl("sprint", true)
		end

		-- Erst zurück zum Hunger wechseln, wenn die Ausdauer komplett voll ist
		if showingStamina and stamina >= staminaMax then
			showingStamina = false
		end
	end
end
addEventHandler("onClientPreRender", root, updateStamina)

addEventHandler("onClientPlayerSpawn", localPlayer, function()
	stamina = staminaMax
	staminaExhausted = false
	showingStamina = false
	toggleControl("sprint", true)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	toggleControl("sprint", true)
end)

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
function ()
	for _, component in ipairs( components ) do
		setPlayerHudComponentVisible( component, false )
	end
end)

-- Bekommt dxDrawImage einen Pfad-String, loest MTA die Textur bei jedem Aufruf
-- neu ueber den Dateinamen auf. Hier wird jedes Bild beim ersten Zeichnen einmal
-- geladen und danach als Textur wiederverwendet. Schlaegt das Laden fehl, wird
-- der Pfad zurueckgegeben, das Verhalten bleibt dann wie zuvor.
local hudPfad = ":"..getResourceName ( getThisResource () )
local hudBild = setmetatable ( {}, {
	__index = function ( tabelle, pfad )
		local voll = pfad:sub ( 1, 1 ) == "/" and hudPfad..pfad or pfad
		local textur = dxCreateTexture ( voll ) or voll
		rawset ( tabelle, pfad, textur )
		return textur
	end
} )

-- Dasselbe fuer die Waffensymbole. Der Pfad wurde bisher in JEDEM Frame neu
-- zusammengesetzt ( ":"..getResourceName(getThisResource()).."/images/..."..id..".png" )
-- und MTA musste die Textur danach jedes Mal ueber den Dateinamen aufloesen.
-- Jetzt: pro Waffen-ID einmal laden, danach nur noch Tabellenzugriff.
local function waffenBildCache ( ordner )
	return setmetatable ( {}, {
		__index = function ( tabelle, id )
			local voll = hudPfad..ordner..id..".png"
			local textur = dxCreateTexture ( voll ) or voll
			rawset ( tabelle, id, textur )
			return textur
		end
	} )
end
local waffenBild1 = waffenBildCache ( "/images/weapons/" )
local waffenBild2 = waffenBildCache ( "/images/hud2/" )

-- Wiederkehrende Farben einmal berechnen statt bei jedem Zeichenaufruf.
local FARBE_WEISS      = tocolor ( 255, 255, 255, 255 )
local FARBE_SCHWARZ    = tocolor ( 0, 0, 0, 255 )
local FARBE_GELD       = tocolor ( 228, 227, 227, 254 )
local FARBE_COINS      = tocolor ( 255, 255, 255, 200 )
local FARBE_WANTED     = tocolor ( 240, 240, 0, 255 )
local FARBE_ROT_BOX    = tocolor ( 1, 0, 0, 185 )
local FARBE_ZEITBALKEN = tocolor ( 150, 0, 0, 200 )
local FARBE_KNASTBOX   = tocolor ( 0, 0, 0, 160 )
local FARBE_SAUERSTOFF = tocolor ( 0, 0, 255, 255 )
local FARBE_AUSDAUER   = tocolor ( 160, 32, 240, 255 )
local FARBE_AUSDAUERBG = tocolor ( 60, 20, 90, 255 )
local FARBE_AUSDAUERDUNKEL = tocolor ( 40, 15, 60, 255 )
local FARBE_HUD2_BG   = tocolor ( 0, 0, 0, 120 )
local FARBE_HUD2_KOPF = tocolor ( 0, 0, 0, 180 )

-- getRealTime() legt bei jedem Aufruf eine neue Tabelle an. Die Uhr braucht
-- keine Frame-Genauigkeit - viermal pro Sekunde reicht fuer eine Sekundenanzeige.
local zeitCache, zeitCacheTick
local function getZeitCached ()
	local now = getTickCount ()
	if not zeitCache or ( now - zeitCacheTick ) >= 200 then
		zeitCache = getRealTime ()
		zeitCacheTick = now
	end
	return zeitCache
end

-- formatNumber() macht string.match + reverse + gsub + reverse. Das lief pro
-- Frame zweimal, obwohl sich der Wert die meiste Zeit gar nicht aendert.
local geldWert, geldText = nil, ""
local function formatGeldCached ( wert )
	if wert ~= geldWert then
		geldWert = wert
		geldText = formatNumber ( wert )..Tables.waehrung
	end
	return geldText
end
local coinWert, coinText = nil, ""
local function formatCoinsCached ( wert )
	if wert ~= coinWert then
		coinWert = wert
		coinText = formatNumber ( wert ).." ¢"
	end
	return coinText
end

function HUD()
	if introCutsceneAktiv then return end -- Waehrend der Intro-Kamerafahrt ausgeblendet, siehe quest/intro_cutscene_client.lua
	local name = getPlayerName(localPlayer)
	local armor = getPedArmor(localPlayer)
	local health = getElementHealth(localPlayer)
	local hunger = getElementHunger(localPlayer,"hunger")
	local currentMoney = tonumber(getPlayerMoney(localPlayer))
	local currentCoins = tonumber(vioClientGetElementData("coins")) or 0
	local weaponslot = getPedWeaponSlot(localPlayer)
	local jailtime = tonumber(getElementData(localPlayer, "jailtime"))
	local oxygen = getPedOxygenLevel(localPlayer)
	local currentTick = getTickCount()/1500

	-- Der Blink-Alphawert wurde in den Warn-Zweigen ( Leben/Ruestung/Hunger
	-- unter 25 % ) bis zu neunmal pro Frame identisch neu berechnet, samt
	-- eigenem tocolor-Aufruf. Jetzt einmal pro Frame.
	local blink = math.abs(math.sin(currentTick)*255)
	local BLINK_SCHWARZ = tocolor(0, 0, 0, blink)
	local BLINK_WEISS = tocolor(255, 255, 255, blink)

	local time = getZeitCached()
	local hour = time.hour
	local minute = time.minute
	local second = time.second
	local day = time.monthday
	local year = time.year + 1900
	local month = time.month + 1

    if State == false then

        if progress < 1 then
            progress = progress + 0.04
        end
		
         local posX, moveY, moveZ = interpolateBetween(sx , 0, 225, sx - 350, 255, 487.5, progress, "Linear")
             roundedRectangle(posX + 2*Gsx, 44*Gsy, 275*Gsx,  235*Gsy, FARBE_ROT_BOX)
             dxDrawText(""..name.."", posX + 30*Gsx, 52*Gsy, 100*Gsx, 100*Gsy, FARBE_WEISS, 0.7, "pricedown", "left", "center", false, false, false, false, false)
             dxDrawText(string.format("%02d:%02d %02d.%02d.%d", hour, minute, day, month, year),posX + 110*Gsx,52*Gsy,140*Gsx,100*Gsy,FARBE_WEISS, 0.6, "pricedown", "left", "center", false, false, false, false, false)
			 
            if Armor > armor then
				Armor = Armor - 1
			end
			if Armor < armor then
				Armor = Armor + 1
			end
            --> Schutzweste Anzeige	
			if (armor) >= 25 or (armor) == 0 then
				roundedRectangle(posX + 25*Gsx, 88*Gsy, 212*Gsx, 22*Gsy, FARBE_SCHWARZ)	
				dxDrawImage(posX + 28*Gsx, 91*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/armourBG.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 91*Gsy, 205/100*Gsx*Armor,16*Gsy, hudBild["/images/hud/armourbar.png"], 0, 0, 0, FARBE_WEISS, false)
			elseif (armor) <= 25 then				
				roundedRectangle(posX + 25*Gsx, 88*Gsy, 212*Gsx, 22*Gsy, BLINK_SCHWARZ)
				dxDrawImage(posX + 28*Gsx, 91*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/armourBG.png"], 0, 0, 0, BLINK_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 91*Gsy, 205/100*Gsx*Armor,16*Gsy, hudBild["/images/hud/armourbar.png"], 0, 0, 0, BLINK_WEISS, false)
			end					

			if Health > health then
				Health = Health - 1
			end
			if Health < health then
				Health = Health + 1
			end
            --> Lebenbar Anzeige		
			if (health) >= 25 then
				roundedRectangle(posX + 25*Gsx, 114*Gsy, 212*Gsx, 22*Gsy, FARBE_SCHWARZ)
				dxDrawImage(posX + 28*Gsx, 117*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/healthBG.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 117*Gsy, 205/100*Gsx*Health,Gsy*16, hudBild["/images/hud/healthbar.png"], 0, 0, 0, FARBE_WEISS, false)
			elseif (health) <= 25 then
				roundedRectangle(posX + 25*Gsx, 114*Gsy, 212*Gsx, 22*Gsy, BLINK_SCHWARZ)
				dxDrawImage(posX + 28*Gsx, 117*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/healthBG.png"], 0, 0, 0, BLINK_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 117*Gsy, 205/100*Gsx*Health,16*Gsy, hudBild["/images/hud/healthbar.png"], 0, 0, 0, BLINK_WEISS, false)
			end	
		

            if Hunger > hunger then
				Hunger = Hunger - 1
			end
			if Hunger < hunger then
				Hunger = Hunger + 1
			end
            --> Hungerbar Anzeige			
			if (hunger) >= 25 then
				roundedRectangle(posX + 25*Gsx, 140*Gsy, 212*Gsx, 22*Gsy, FARBE_SCHWARZ)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/hungerBG.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205/100*Gsx*Hunger,16*Gsy, hudBild["/images/hud/hungerbar.png"], 0, 0, 0, FARBE_WEISS, false)
			elseif (hunger) <= 25 then				
				roundedRectangle(posX + 25*Gsx, 140*Gsy, 212*Gsx, 22*Gsy, BLINK_SCHWARZ)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/hungerBG.png"], 0, 0, 0, BLINK_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205/100*Gsx*Hunger,16*Gsy, hudBild["/images/hud/hungerbar.png"], 0, 0, 0, BLINK_WEISS, false)
			end	
			
			
			
			if currentMoney  ~= money then
				if currentMoney < money then -- Geld wird weniger
					local moneydiff = money-currentMoney
					local abzug = math.ceil(moneydiff/100)
					money = money-abzug
				else -- Geld wird mehr
					local moneydiff = currentMoney-money
					local abzug = math.ceil(moneydiff/100)
					money = money+abzug
				end
			end
			dxDrawText(formatGeldCached(money), posX + 30*Gsx, 160*Gsy, 1884*Gsx, 206*Gsy, FARBE_GELD, 1.50, "pricedown", "left", "top", false, false, false, false, false)

			if currentCoins ~= coins1 then
				if currentCoins < coins1 then
					local coindiff = coins1 - currentCoins
					local abzug = math.ceil(coindiff/100)
					coins1 = coins1 - abzug
				else
					local coindiff = currentCoins - coins1
					local abzug = math.ceil(coindiff/100)
					coins1 = coins1 + abzug
				end
			end
			dxDrawText(formatCoinsCached(coins1), posX + 30*Gsx, 198*Gsy, 1884*Gsx, 244*Gsy, FARBE_COINS, 1.30, "pricedown", "left", "top", false, false, false, false, false)

			
			--//Wanteds
			local wanted = getElementData(localPlayer, "wanteds")
			if(wanted and wanted > 0)then
                local wantedY=0
                for i=1,wanted do
                    dxDrawImage(posX+wantedY + 20*Gsx,235*Gsy,30*Gsx,30*Gsy,hudBild["/images/hud/wanted_active.png"],0,0,0,FARBE_WANTED,false)
                    wantedY=wantedY+37
                end
            end
			
			
			--/images/Weapon
			local weaponID = getPedWeapon(localPlayer)
			dxDrawImage(posX - 100*Gsx, 50*Gsy, 82*Gsx, 87*Gsy, waffenBild1[weaponID], 0, 0, 0, FARBE_WEISS, false)
			
			--/images/Ammo
			if weaponslot >= 2 and weaponslot <= 9 then
			local clip = getPedAmmoInClip (localPlayer, weaponslot )
			local clip1 = getPedTotalAmmo (localPlayer, weaponslot )
				dxDrawText(clip.."|"..clip1, posX - 80*Gsx, 121*Gsy, 1564*Gsx, 165*Gsy, FARBE_GELD, 1, "default-bold", "left", "center", false, false, false, false, false)
			end
			
            dxDrawImage(posX + 243*Gsx,  89*Gsy,     16*Gsx, 16*Gsy, hudBild["/images/hud/armour.png"], 0, 0, 0, FARBE_WEISS, false)
            dxDrawImage(posX + 243*Gsx,  115*Gsy,    16*Gsx, 16*Gsy, hudBild["/images/hud/health.png"], 0, 0, 0, FARBE_WEISS, false)
            dxDrawImage(posX + 243*Gsx,  59+5*Gsy,   16*Gsx, 16*Gsy, hudBild["/images/hud/time.png"], 0, 0, 0, FARBE_WEISS, false)
            dxDrawImage(posX + 243*Gsx,  172.5+5*Gsy,14*Gsx, 16*Gsy, hudBild["/images/hud/money.png"], 0, 0, 0, FARBE_WEISS, false)
			
			if(jailtime and jailtime > 0)then
				dxDrawRectangle(1630*Gsx,325*Gsy,280*Gsx,25*Gsy,guimaincolor,false)
				dxDrawRectangle(1630*Gsx,350*Gsy,280*Gsx,100*Gsy,FARBE_KNASTBOX,false)
				dxDrawText("KNAST",1740*Gsx,325*Gsy,200*Gsx,22*Gsy,FARBE_WEISS,1.00*Gsx,dxFONT,_,_,_,_,false,_,_)
				dxDrawText("Du bist noch für "..math.floor(jailtime).." Minuten im Knast",1660*Gsx,385*Gsy,200*Gsx,22*Gsy,FARBE_WEISS,1.00,dxFONT2,_,_,_,_,false,_,_)
			end
			
			
				--/images/Armor-Percent
				dxDrawText(""..math.floor(tonumber(Armor)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 83*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
				
				--/images/Health-Percent
				dxDrawText(""..math.floor(tonumber(Health)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 135*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
				
				--/images/hunger-Percent
				dxDrawText(""..math.floor(tonumber(Hunger)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 187*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
			
			if(isElementInWater(localPlayer))then
				roundedRectangle(posX + 25*Gsx, 140*Gsy, 212*Gsx, 22*Gsy, FARBE_SCHWARZ)
				dxDrawImage(posX + 243*Gsx, 141*Gsy, 16*Gsx, 16*Gsy, hudBild["/images/hud/oxygen.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/armourBG.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 191/1000*Gsx*oxygen,16*Gsy, hudBild["/images/hud/armourbar.png"], 0, 0, 0, FARBE_SAUERSTOFF, false)
				dxDrawText(""..math.floor(tonumber(oxygen/10.7)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 187*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
			else
				roundedRectangle(posX + 25*Gsx, 140*Gsy, 212*Gsx, 22*Gsy, FARBE_SCHWARZ)
				if isShowingStamina() then
				dxDrawImage(posX + 243*Gsx, 141*Gsy, 16*Gsx, 16*Gsy, hudBild["/images/hud/air.png"], 0, 0, 0, FARBE_AUSDAUER, false)
				dxDrawRectangle(posX + 28*Gsx, 143*Gsy, 205*Gsx, 16*Gsy, FARBE_AUSDAUERBG)
				dxDrawRectangle(posX + 28*Gsx, 143*Gsy, 205/100*Gsx*stamina, 16*Gsy, FARBE_AUSDAUER)
				dxDrawText(""..math.floor(tonumber(stamina)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 187*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
			else
				dxDrawImage(posX + 243*Gsx, 141*Gsy, 16*Gsx, 16*Gsy, hudBild["/images/hud/air.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/hungerBG.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205/100*Gsx*Hunger,16*Gsy, hudBild["/images/hud/hungerbar.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawText(""..math.floor(tonumber(Hunger)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 187*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
			end
			end
					
			dxDrawImage(820*Gsx,0*Gsy,280*Gsx,30*Gsy,hudBild["/images/hud/Time2.png"],0,0,0,FARBE_ZEITBALKEN,false)
			dxDrawText(hour..":"..minute..":"..second.." : "..day.."."..month.."."..year,1725*Gsx,0*Gsy,200*Gsx,20*Gsy,FARBE_WEISS,1.0,dxFONT,"center",nil,nil,false,nil,nil)
 
    elseif State == true then
        if progress > 0 then
            progress = progress - 0.02
        end
       
		  local posX, moveY, moveZ = interpolateBetween(sx , 0, 225, sx - 350, 255, 487.5, progress, "Linear")
             roundedRectangle(posX + 2*Gsx, 44*Gsy, 275*Gsx,  235*Gsy, FARBE_ROT_BOX)
             dxDrawText(""..name.."", posX + 30*Gsx, 52*Gsy, 100*Gsx, 100*Gsy, FARBE_WEISS, 0.7, "pricedown", "left", "center", false, false, false, false, false)
             dxDrawText(string.format("%02d:%02d %02d.%02d.%d", hour, minute, day, month, year),posX + 110*Gsx,52*Gsy,140*Gsx,100*Gsy,FARBE_WEISS, 0.6, "pricedown", "left", "center", false, false, false, false, false)
			 
            if Armor > armor then
				Armor = Armor - 1
			end
			if Armor < armor then
				Armor = Armor + 1
			end
            --> Schutzweste Anzeige	
			if (armor) >= 25 or (armor) == 0 then
				roundedRectangle(posX + 25*Gsx, 88*Gsy, 212*Gsx, 22*Gsy, FARBE_SCHWARZ)	
				dxDrawImage(posX + 28*Gsx, 91*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/armourBG.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 91*Gsy, 205/100*Gsx*Armor,16*Gsy, hudBild["/images/hud/armourbar.png"], 0, 0, 0, FARBE_WEISS, false)
			elseif (armor) <= 25 then				
				roundedRectangle(posX + 25*Gsx, 88*Gsy, 212*Gsx, 22*Gsy, BLINK_SCHWARZ)
				dxDrawImage(posX + 28*Gsx, 91*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/armourBG.png"], 0, 0, 0, BLINK_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 91*Gsy, 205/100*Gsx*Armor,16*Gsy, hudBild["/images/hud/armourbar.png"], 0, 0, 0, BLINK_WEISS, false)
			end					

			if Health > health then
				Health = Health - 1
			end
			if Health < health then
				Health = Health + 1
			end
            --> Lebenbar Anzeige		
			if (health) >= 25 then
				roundedRectangle(posX + 25*Gsx, 114*Gsy, 212*Gsx, 22*Gsy, FARBE_SCHWARZ)
				dxDrawImage(posX + 28*Gsx, 117*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/healthBG.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 117*Gsy, 205/100*Gsx*Health,Gsy*16, hudBild["/images/hud/healthbar.png"], 0, 0, 0, FARBE_WEISS, false)
			elseif (health) <= 25 then
				roundedRectangle(posX + 25*Gsx, 114*Gsy, 212*Gsx, 22*Gsy, BLINK_SCHWARZ)
				dxDrawImage(posX + 28*Gsx, 117*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/healthBG.png"], 0, 0, 0, BLINK_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 117*Gsy, 205/100*Gsx*Health,16*Gsy, hudBild["/images/hud/healthbar.png"], 0, 0, 0, BLINK_WEISS, false)
			end	
		

            if Hunger > hunger then
				Hunger = Hunger - 1
			end
			if Hunger < hunger then
				Hunger = Hunger + 1
			end
            --> Hungerbar Anzeige			
			if (hunger) >= 25 then
				roundedRectangle(posX + 25*Gsx, 140*Gsy, 212*Gsx, 22*Gsy, FARBE_SCHWARZ)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/hungerBG.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205/100*Gsx*Hunger,16*Gsy, hudBild["/images/hud/hungerbar.png"], 0, 0, 0, FARBE_WEISS, false)
			elseif (hunger) <= 25 then				
				roundedRectangle(posX + 25*Gsx, 140*Gsy, 212*Gsx, 22*Gsy, BLINK_SCHWARZ)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/hungerBG.png"], 0, 0, 0, BLINK_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205/100*Gsx*Hunger,16*Gsy, hudBild["/images/hud/hungerbar.png"], 0, 0, 0, BLINK_WEISS, false)
			end	
			
			
			
			if currentMoney  ~= money then
				if currentMoney < money then -- Geld wird weniger
					local moneydiff = money-currentMoney
					local abzug = math.ceil(moneydiff/100)
					money = money-abzug
				else -- Geld wird mehr
					local moneydiff = currentMoney-money
					local abzug = math.ceil(moneydiff/100)
					money = money+abzug
				end
			end
			dxDrawText(formatGeldCached(money), posX + 30*Gsx, 160*Gsy, 1884*Gsx, 206*Gsy, FARBE_GELD, 1.50, "pricedown", "left", "top", false, false, false, false, false)

			if currentCoins ~= coins1 then
				if currentCoins < coins1 then
					local coindiff = coins1 - currentCoins
					local abzug = math.ceil(coindiff/100)
					coins1 = coins1 - abzug
				else
					local coindiff = currentCoins - coins1
					local abzug = math.ceil(coindiff/100)
					coins1 = coins1 + abzug
				end
			end
			dxDrawText(formatCoinsCached(coins1), posX + 30*Gsx, 198*Gsy, 1884*Gsx, 244*Gsy, FARBE_COINS, 1.30, "pricedown", "left", "top", false, false, false, false, false)

			
			--//Wanteds
			local wanted = getElementData(localPlayer, "wanteds")
			if(wanted and wanted > 0)then
                local wantedY=0
                for i=1,wanted do
                    dxDrawImage(posX+wantedY + 20*Gsx,235*Gsy,30*Gsx,30*Gsy,hudBild["/images/hud/wanted_active.png"],0,0,0,FARBE_WANTED,false)
                    wantedY=wantedY+37
                end
            end
			
			
			--/images/Weapon
			local weaponID = getPedWeapon(localPlayer)
			dxDrawImage(posX - 100*Gsx, 50*Gsy, 82*Gsx, 87*Gsy, waffenBild1[weaponID], 0, 0, 0, FARBE_WEISS, false)
			
			--/images/Ammo
			if weaponslot >= 2 and weaponslot <= 9 then
			local clip = getPedAmmoInClip (localPlayer, weaponslot )
			local clip1 = getPedTotalAmmo (localPlayer, weaponslot )
				dxDrawText(clip.."|"..clip1, posX - 80*Gsx, 121*Gsy, 1564*Gsx, 165*Gsy, FARBE_GELD, 1, "default-bold", "left", "center", false, false, false, false, false)
			end
                        
            dxDrawImage(posX + 243*Gsx,  89*Gsy,     16*Gsx, 16*Gsy, hudBild["/images/hud/armour.png"], 0, 0, 0, FARBE_WEISS, false)
            dxDrawImage(posX + 243*Gsx,  115*Gsy,    16*Gsx, 16*Gsy, hudBild["/images/hud/health.png"], 0, 0, 0, FARBE_WEISS, false)
            dxDrawImage(posX + 243*Gsx,  59+5*Gsy,   16*Gsx, 16*Gsy, hudBild["/images/hud/time.png"], 0, 0, 0, FARBE_WEISS, false)
            dxDrawImage(posX + 243*Gsx,  172.5+5*Gsy,14*Gsx, 16*Gsy, hudBild["/images/hud/money.png"], 0, 0, 0, FARBE_WEISS, false)
			
			if(jailtime and jailtime > 0) then
				dxDrawRectangle(1630*Gsx,325*Gsy,280*Gsx,25*Gsy,guimaincolor,false)
				dxDrawRectangle(1630*Gsx,350*Gsy,280*Gsx,100*Gsy,FARBE_KNASTBOX,false)
				dxDrawText("Du bist noch für "..math.floor(jailtime).." Minuten im Knast",1660*Gsx,385*Gsy,200*Gsx,22*Gsy,FARBE_WEISS,1.00,dxFONT2,_,_,_,_,false,_,_)
				dxDrawText("KNAST",1740*Gsx,325*Gsy,200*Gsx,22*Gsy,FARBE_WEISS,1.00*Gsx,dxFONT,_,_,_,_,false,_,_)
			end
			
			
				--/images/Armor-Percent
				dxDrawText(""..math.floor(tonumber(Armor)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 83*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
				
				--/images/Health-Percent
				dxDrawText(""..math.floor(tonumber(Health)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 135*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
				
				--/images/hunger-Percent
				dxDrawText(""..math.floor(tonumber(Hunger)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 187*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
			
			if(isElementInWater(localPlayer))then
				roundedRectangle(posX + 25*Gsx, 140*Gsy, 212*Gsx, 22*Gsy, FARBE_SCHWARZ)
				dxDrawImage(posX + 243*Gsx, 141*Gsy, 16*Gsx, 16*Gsy, hudBild["/images/hud/oxygen.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/armourBG.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 191/1000*Gsx*oxygen,16*Gsy, hudBild["/images/hud/armourbar.png"], 0, 0, 0, FARBE_SAUERSTOFF, false)
				dxDrawText(""..math.floor(tonumber(oxygen/10.7)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 187*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
			else
				roundedRectangle(posX + 25*Gsx, 140*Gsy, 212*Gsx, 22*Gsy, FARBE_SCHWARZ)
				if isShowingStamina() then
				dxDrawImage(posX + 243*Gsx, 141*Gsy, 16*Gsx, 16*Gsy, hudBild["/images/hud/air.png"], 0, 0, 0, FARBE_AUSDAUER, false)
				dxDrawRectangle(posX + 28*Gsx, 143*Gsy, 205*Gsx, 16*Gsy, FARBE_AUSDAUERBG)
				dxDrawRectangle(posX + 28*Gsx, 143*Gsy, 205/100*Gsx*stamina, 16*Gsy, FARBE_AUSDAUER)
				dxDrawText(""..math.floor(tonumber(stamina)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 187*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
			else
				dxDrawImage(posX + 243*Gsx, 141*Gsy, 16*Gsx, 16*Gsy, hudBild["/images/hud/air.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205*Gsx, 16*Gsy, hudBild["/images/hud/hungerBG.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawImage(posX + 28*Gsx, 143*Gsy, 205/100*Gsx*Hunger,16*Gsy, hudBild["/images/hud/hungerbar.png"], 0, 0, 0, FARBE_WEISS, false)
				dxDrawText(""..math.floor(tonumber(Hunger)).."%", posX + 130*Gsx, 115*Gsy, 206*Gsx, 187*Gsy, FARBE_WEISS, 1, "default-bold", "left", "center", false, false, false, false, false)
			end
			end
					
			dxDrawImage(820*Gsx,0*Gsy,280*Gsx,30*Gsy,hudBild["/images/hud/Time2.png"],0,0,0,FARBE_ZEITBALKEN,false)
			dxDrawText(hour..":"..minute..":"..second.." : "..day.."."..month.."."..year,1725*Gsx,0*Gsy,200*Gsx,20*Gsy,FARBE_WEISS,1.0,dxFONT,"center",nil,nil,false,nil,nil)

	 end
end
addEvent("ShowHud", true)
addEventHandler("ShowHud", getRootElement(), function() State = true end)
addEvent("HideHud", true)
addEventHandler("HideHud", getRootElement(), function() State = false end)


--  ╔══════════════════════════════╗
--  ║ » Head up Display Script     ║
--  ║ » ICE Realife - made for Emre║
--  ║ » Author: iLimix             ║
--  ║ » Copyright © 2020           ║
--  ║ » In Order from ICE Reallife ║
--  ╚══════════════════════════════╝

--// Resolution
local screenX, screenY = guiGetScreenSize()
local standartX, standartY = 1920, 1080
local sx, sy = screenX / standartX, screenY / standartY

local noreloadweapons = { 
    [16] = true, [17] = true, [18] = true, 
    [19] = true, [25] = true, [33] = true, 
    [34] = true, [35] = true, [36] = true, 
    [37] = true, [38] = true, [39] = true, 
    [41] = true, [42] = true, [43] = true 
}

local meleespecialweapons = { 
    [0] = true, [1] = true, [2] = true, 
    [3] = true, [4] = true, [5] = true, 
    [6] = true, [7] = true, [8] = true, 
    [9] = true, [10] = true, [11] = true, 
    [12] = true, [13] = true, [14] = true, 
    [15] = true, [40] = true, [44] = true, 
    [45] = true, [46] = true 
}

local hudTable = { "ammo", "armour", "clock", "health", "money", "weapon", "wanted", "area_name", "vehicle_name", "breath", "clock" }
--// Disable Standart HUD
for i = 1, #hudTable do
    setPlayerHudComponentVisible(hudTable[i], false)
end

-- Waffensymbole laufen jetzt ueber waffenBild2 ( Textur-Cache weiter oben ),
-- der frueher hier definierte iconpath wird nicht mehr gebraucht.
local textsize = { 1, 1.3, 0.8 } --// 1. Zeit, 2. Money
local textfont = { "default", "pricedown", "default-bold"} -- 1. Zeit, 2.Money, Leben-/Armor-/Foodanzeige  - statt string kann auch dxCreateFont benutzt werden
local Servername = ""..Tables.servername.." Reallife"

local function getTime()
    local realtime = getZeitCached()
    local hour = realtime.hour
    local minute = realtime.minute
    return (hour > 9 and hour or "0" .. hour) .. ":" .. (minute > 9 and minute or "0" .. minute)
end

function convertMoney(cash)
    local format = cash
    while true do
        format, k = string.gsub(format, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then break end
    end
    format = tostring(format)
    return format
end

function formatNumber(n) 
    if (not n) then return "Error catching data" end 
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$') 
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right 
end


local progress = 0
local HUDstate = true
local smoothMoveHealth = 0
local smoothMoveArmor = 0
local smoothMoveFood = 0
local coins = 0
local currentMoney = 0
local bar_width = 282
local bar_height = 20

function HUD2()
	if introCutsceneAktiv then return end -- Waehrend der Intro-Kamerafahrt ausgeblendet, siehe quest/intro_cutscene_client.lua

    if HUDstate == false then
        if progress < 1 then
            progress = progress + 0.04
        end
    elseif HUDstate == true then
        if progress > 0 then
            progress = progress - 0.04
        end
    end

    local posX, moveY, moveZ = interpolateBetween(screenX - 360 * sx, 0, 0, screenX + 10 * sx, 255, 0, progress, "Linear")
    roundedRectangle(posX, 10 * sy, 350 * sx, 180 * sy, FARBE_HUD2_BG)
    roundedRectangle(posX, 10 * sy, 350 * sx, 25 * sy, FARBE_HUD2_KOPF)
    dxDrawText(Servername .." - ".. getTime(), posX + 135, 10 * sy, screenX - 360 * sx + 350 * sx, 10 * sy + 25 * sy, FARBE_COINS, textsize[1], textfont[1], "left", "center")

    --// Health, Armor, Hunger \\--
    local healthX, healthY, healthWidth, healthHeight = posX + 20, 50, 304, 22
    dxDrawImage(healthX, healthY, healthWidth, healthHeight, hudBild["/images/hud2/health.png"])
    local health = getElementHealth(localPlayer)
    if smoothMoveHealth > health then
        smoothMoveHealth = smoothMoveHealth - 1
    end
    if smoothMoveHealth < health then
        smoothMoveHealth = smoothMoveHealth + 1
    end
    local progress = (smoothMoveHealth/100)*bar_width
    dxDrawImageSection(healthX + 22, healthY + 1, progress, bar_height, 0, 0, progress, bar_height, hudBild["/images/hud2/health1.png"], 0, 0, 0, FARBE_WEISS, false)
    dxDrawText(smoothMoveHealth.." %", healthX, healthY, healthWidth + healthX, healthHeight + healthY, FARBE_WEISS, 1, textfont[3], "center", "center")

    --//Armor
    armorX, armorY, armorWidth, armorHeight = posX + 20, 80, 304, 22
    dxDrawImage(armorX, armorY, armorWidth, armorHeight, hudBild["/images/hud2/armor.png"])
    local armor = getPedArmor(localPlayer)
    if smoothMoveArmor > armor then
        smoothMoveArmor = smoothMoveArmor - 1
    end
    if smoothMoveArmor < armor then
        smoothMoveArmor = smoothMoveArmor + 1
    end
    local progress = (smoothMoveArmor/100)*bar_width
    dxDrawImageSection(armorX + 22, armorY + 1, progress, bar_height, 0, 0, progress, bar_height, hudBild["/images/hud2/armor1.png"], 0, 0, 0, FARBE_WEISS, false)
    dxDrawText(smoothMoveArmor.." %", armorX, armorY, armorWidth + armorX, armorHeight + armorY, FARBE_WEISS, 1, textfont[3], "center", "center")

    --//Hunger / Ausdauer
    hungerX, hungerY, hungerWidth, hungerHeight = posX + 20, 110, 304, 22
    local showingStamina = isShowingStamina()
    if showingStamina then
        dxDrawRectangle(hungerX, hungerY, hungerWidth, hungerHeight, FARBE_AUSDAUERDUNKEL)
    else
        dxDrawImage(hungerX, hungerY, hungerWidth, hungerHeight, hudBild["/images/hud2/food.png"])
    end
    local foodTarget = showingStamina and stamina or getElementHunger(localPlayer)
    if smoothMoveFood > foodTarget then
        smoothMoveFood = smoothMoveFood - 1
    end
    if smoothMoveFood < foodTarget then
        smoothMoveFood = smoothMoveFood + 1
    end
    local progress = (smoothMoveFood/100)*bar_width
    if showingStamina then
        dxDrawRectangle(hungerX + 22, hungerY + 1, progress, bar_height, FARBE_AUSDAUER)
    else
        dxDrawImageSection(hungerX + 22, hungerY + 1, progress, bar_height, 0, 0, progress, bar_height, hudBild["/images/hud2/food1.png"], 0, 0, 0, FARBE_WEISS, false)
    end
    -- "Ausdauer" stand vorher als eigene Zeile ueber dem Balken, dafuer war
    -- zur Ruestungsleiste aber nur 8px Platz - sie ragte in die Zeile
    -- darueber. Jetzt steht die Beschriftung direkt mit im Balkentext, dafuer
    -- wird kein zusaetzlicher vertikaler Platz gebraucht.
    local hungerLabel = showingStamina and ( "Ausdauer "..smoothMoveFood.." %" ) or ( smoothMoveFood.." %" )
    dxDrawText(hungerLabel, hungerX, hungerY, hungerWidth + hungerX, hungerHeight + hungerY, FARBE_WEISS, 1, textfont[3], "center", "center")
	
	local currentMoney = tonumber(getPlayerMoney(localPlayer))
	if currentMoney  ~= money then
		if currentMoney < money then -- Geld wird weniger
			local moneydiff = money-currentMoney
			local abzug = math.ceil(moneydiff/100)
			money = money-abzug
		else -- Geld wird mehr
			local moneydiff = currentMoney-money
			local abzug = math.ceil(moneydiff/100)
			money = money+abzug
		end
	end
    --// Money \\--
    dxDrawText("€ "..money, posX + 15, 290 * sy, screenX - 360 * sx + 45 * sx, 10 * sy + 25 * sy, FARBE_COINS, textsize[2], textfont[2], "left", "center")
    
	local coin = tonumber(vioClientGetElementData("coins"))
	if coin ~= coins then
		if coin < coins then -- Geld wird weniger
			local moneydiff = coins-coin
			local abzug = math.ceil(moneydiff/100)
			coins = coins-abzug
		else -- Geld wird mehr
			local moneydiff = coin-coins
			local abzug = math.ceil(moneydiff/100)
			coins = coins+abzug
		end
	end
    --// Coins \\--
    dxDrawText("¢ "..coins, posX + 190, 290 * sy, screenX - 360 * sx + 190 * sx, 10 * sy + 25 * sy, FARBE_COINS, textsize[2], textfont[2], "left", "center")
	
	local time = getZeitCached()
	local hour = time.hour
	local minute = time.minute
	local second = time.second
	local day = time.monthday
	local year = time.year + 1900
	local month = time.month + 1
	
	dxDrawImage(820*sx,0*sy,280*sx,30*sy,hudBild["/images/hud/Time2.png"],0,0,0,FARBE_ZEITBALKEN,false)
	dxDrawText(hour..":"..minute..":"..second.." : "..day.."."..month.."."..year,1725*sx,0*sy,200*sx,20*sy,FARBE_WEISS,1.0,dxFONT,"center",nil,nil,false,nil,nil)

    local weapon = getPedWeapon(localPlayer)
    dxDrawImage(posX - 80 , 20 * sy, 70 * sx, 70 * sy, waffenBild2[weapon])
    if noreloadweapons[weapon] then
        local totalammo = getPedTotalAmmo(localPlayer)
        dxDrawText(totalammo, posX - 70, 170 * sy, screenX - 500 * sx + 50 * sx, 50 * sy, FARBE_WEISS, textsize[3], textfont[2], "left", "center")
    elseif not meleespecialweapons[weapon] then
        local ammoinclip = getPedAmmoInClip(localPlayer)
        local totalammo = getPedTotalAmmo(localPlayer)
        dxDrawText(ammoinclip .. " / " .. (totalammo - ammoinclip), posX - 75, 170 * sy, screenX - 500 * sx + 50 * sx, 50 * sy, FARBE_WEISS, textsize[3], textfont[2], "left", "center")
    elseif weapon == 0 then
        dxDrawText("Faust", posX - 69, 170 * sy, screenX - 500 * sx + 50 * sx, 50 * sy, FARBE_WEISS, textsize[2], textfont[3], "left", "center")
    elseif weapon == 46 then
        dxDrawText("Fallschirm", posX  - 70, 170 * sy, screenX - 500 * sx + 50 * sx, 50 * sy, FARBE_WEISS, textsize[1], textfont[3], "left", "center")
    end
	
    local wanted = getElementData(localPlayer,"wanteds")
    if wanted and wanted >= 1 then
        local wantedX = 20
		for i=1,wanted do
            dxDrawImage((posX + wantedX), 200 * sy, 30 * sx, 30 * sy, hudBild["/images/hud2/Wanted.png"], 0, 0, 0, FARBE_WEISS, true)
            wantedX = wantedX + 50
        end
    end
end

function animateHUD()
    if HUDstate == false then
        HUDstate = true
    elseif HUDstate == true then
        HUDstate = false
    end
end
bindKey("b", "down", animateHUD)
 
 
function drawHuDD()
    if State == false then
        triggerEvent("ShowHud", root)
    elseif State == true then
	    triggerEvent("HideHud", root)
    end
end
bindKey( "b", "down", drawHuDD )

addEvent("showhudclient", true)
addEventHandler("showhudclient", localPlayer, function( hud )
	local current_hud = tonumber(getElementData( localPlayer, "hud"))

    -- 1. Zuerst alle möglichen HUD-Handler entfernen, um Warnungen und Doppel-Rendern zu vermeiden
    removeEventHandler("onClientRender", root, HUD)
    removeEventHandler("onClientRender", root, HUD2)
    
    -- 2. Dann den korrekten Handler basierend auf dem aktuellen Wert hinzufügen
    if current_hud == 1 then
        addEventHandler("onClientRender", root, HUD)
    elseif current_hud == 2 then
        addEventHandler("onClientRender", root, HUD2) 
    end
end)
