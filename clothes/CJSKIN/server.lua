--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local myBlip = createBlip( -1697.7846679688,951.95965576172,24.890625, 45)

-- // Skinshopmarker
local skinshop_marker={
-- x, y, z, interior
{208.80212402344,-3.5260908603668,1001.2177734375,5,"klamotten"},
{414.34588623047,-51.379570007324,1001.8984375,12,"hairs"},
}

for _,k in pairs(skinshop_marker)do
	skinshopMarker = createPickup(k[1],k[2],k[3],3,1275,50)
	setElementInterior(skinshopMarker,k[4])
	
	addEventHandler("onPickupHit",skinshopMarker,function(player)
		if(getElementModel(player) == 0)then
			if(k[5] == "klamotten")then
				triggerClientEvent(player,"clientCJClothesShop",player)
			elseif(k[5] == "hairs")then
				triggerClientEvent(player,"HairShop",player)
			end
		else outputChatBox("Für diesen Marker benötigst du einen CJ-Skin!",player)end
	end)
end

local BuyCJSkin = createPickup(202.91520690918,-12.234784126282,1001.2109375,3,1239,50)
setElementInterior(BuyCJSkin,5)

addEventHandler("onPickupHit",BuyCJSkin,function(player)
	if(MtxGetElementData(player,"money")>=2500)then
		if(getElementModel(player)>0)then
			setElementModel(player,0)
			MtxSetElementData(player,"skinid",0)
			MtxSetElementData(player,"money",MtxGetElementData(player,"money")-2500)
	    else outputChatBox("Du hast bereits einen CJ-Skin!",player)end
	else outputChatBox("Du hast nicht genug Geld dabei (2500"..Tables.waehrung..")!",player)end
end)

-- // Klamotten Tabelle
local clothes = {

--//Shirts
["Freier Oberkörper"] = {"player_torso","torso",0},
["Weißes Unterhemd"] = {"vest","vest",0},
["Gestreiftes Shirt"] = {"tshirt2horiz","tshirt2",0},
["Weißes Shirt"] = {"tshirtwhite","tshirt",0},
["I love LS Shirt"] = {"tshirtilovels","tshirt",0},
["Weißes Homie Shirt"] = {"tshirtblunts","tshirt",0},
["Rotes Hemd"] = {"shirtbplaid","shirtb",0},
["Grünes Shirt mit UZI"] = {"tshirtmaddgrn","tshirt",0},
["Blaues Hemd"] = {"shirtbcheck","shirtb",0},
["Graues Hemd"] = {"field","field",0},
["Grünes Shirt"] = {"tshirterisyell","tshirt",0},
["Oranges Shirt"] = {"tshirterisorn","tshirt",0},
["Rot schwarzes Shirt"] = {"trackytop2eris","trackytop1",0},
["Rote College-Jacke"] = {"bbjackrim","bbjack",0},
["Dunkelrote College-Jacke"] = {"bballjackrstar","bbjack",0},
["Rotes Basketballshirt"] = {"baskballdrib","baskball",0},
["Weißes Basketballshirt"] = {"baskballrim","baskball",0},
["Blaues Sixty-niners Shirt"] = {"sixtyniners","tshirt",0},
["Baseballshirt"] = {"bandits","baseball",0},
["Rotes Shirt"] = {"tshirtprored","tshirt",0},
["Schwarzes Shirt"] = {"tshirtproblk","tshirt",0},
["Weiß rote Jacke"] = {"trackytop1pro","trackytop1",0},
["Blaues Hockeyshirt"] = {"hockeytop","sweat",0},
["Grün weißes Shirt"] = {"bbjersey","sleevt",0},
["Bunte Jacke"] = {"shellsuit","trackytop1",0},
["Weißes Shirt"] = {"tshirtheatwht","tshirt",0},
["Weißes Shirt mit roten Ärmeln"] = {"tshirtbobomonk","tshirt",0},
["Rotes Shirt mit Streifen"] = {"tshirtbobored","tshirt",0},
["Weißes Shirt mit 5 Aufdruck"] = {"tshirtbase5","tshirt",0},
["Grün weißes Shirt mit Urban Aufdruck"] = {"tshirtsuburb","tshirt",0},
["Graue Jacke"] = {"hoodyamerc","hoodya",0},
["Grüne Jacke"] = {"hoodyabase5","hoodya",0},
["Weißer Hoodie"] = {"hoodyarockstar","hoodya",0},
["Blaue weiße Weste"] = {"wcoatblue","wcoat",0},
["Grüne Knopfjacke"] = {"coach","coach",0},
["Graue Knopfjacke"] = {"coachsemi","coach",0},
["Weißer Rockstar Pullover"] = {"sweatrstar","sweat",0},
["Blaue Rockstar Jacke"] = {"hoodyAblue","hoodyA",0},
["Schwarze Rockstar Jacke"] = {"hoodyAblack","hoodyA",0},
["Grüne Rockstar Jacke"] = {"hoodyAgreen","hoodyA",0},
["Braunes Shirt"] = {"sleevtbrown","sleevt",0},
["Blau weißes Hemd"] = {"shirtablue","shirta",0},


--//Haare
["Braune kurze Haare"] = {"player_face","head",1},
["Blonde kurze Haare"] = {"hairblond","head",1},
["Rote kurze Haare"] = {"hairred","head",1},
["Blaue kurze Haare"] = {"hairblue","head",1},
["Grüne kurze Haare"] = {"hairgreen","head",1},
["Pinke kurze Haare"] = {"hairpink","head",1},
["Glatze ohne Bart"] = {"bald","head",1},
["Glatze mit Vollbart"] = {"baldbeard","head",1},
["Glatze mit Oberlippenbart"] = {"baldtash","head",1},
["Glatze mit Bart"] = {"baldgoatee","head",1},
["Soldatenschnitt"] = {"highfade","head",1},
["Hoher Afro"] = {"highafro","highafro",1},
["Schwarze Strähnen"] = {"cornrows","cornrows",1},
["Blonde Strähnen"] = {"cornrowsb","cornrows",1},
["Kurze Haare mit Muster"] = {"tramline","tramline",1},
["Brauner Punkschnitt"] = {"mohawk","mohawk",1},
["Blonder Punkschnitt"] = {"mohawkblond","mohawk",1},
["Pinker Punkschnitt"] = {"mohawkpink","mohawk",1},
["Brauner Punkschnitt mit Vollbart"] = {"mohawkbeard","mohawk",1},
["Afro"] = {"afro","afro",1},
["Afro mit Oberlippenbart"] = {"afrotash","afro",1},
["Afro mit Vollbart"] = {"afrobeard","afro",1},
["Blonder Afro"] = {"afroblond","afro",1},
["Brauner Elvisschnitt"] = {"flattop","flattop",1},
["Schwarzer Elvisschnitt"] = {"elvishair","elvishair",1},
["Kurze Haare mit Vollbart"] = {"beard","head",1},
["Kurze Haare mit Oberlippenbart"] = {"tash","head",1},


--//Hosen
["Weiße Unterhose"] = {"player_legs","legs",2},
["Grüne camouflage Hose"] = {"worktrcamogrn","worktr",2},
["Graue camouflage Hose"] = {"worktrcamogry","worktr",2},
["Graue Hose"] = {"worktrgrey","worktr",2},
["Grüne Hose"] = {"worktrkhaki","worktr",2},
["Weiße Hose"] = {"tracktr","tracktr",2},
["Blaue Jogginghose"] = {"tracktreris","tracktr",2},
["Jeanshose"] = {"jeansdenim","jeans",2},
["Schwarze Unterhose"] = {"legsblack","legs",2},
["Herz Unterhose"] = {"legsheart","legs",2},
["Weiße Jeanshose"] = {"biegetr","chinosb",2},
["Rote Jogginghose"] = {"tracktrpro","tracktr",2},
["Graue Jogginghose"] = {"tracktrwhstr","tracktr",2},
["Blaue Jogginghose"] = {"tracktrblue","tracktr",2},
["Grüne Jogginghose"] = {"tracktrgang","tracktr",2},
["Weiße kurze Hose"] = {"bbshortwht","boxingshort",2},
["Rote kurze Hose"] = {"boxshort","boxingshort",2},
["Hellrote kurze Hose"] = {"bbshortred","boxingshort",2},
["Bunte Hose"] = {"shellsuittr","tracktr",2},
["Graue kurze Hose"] = {"shortsgrey","shorts",2},
["Grüne kurze Hose"] = {"shortskhaki","shorts",2},
["Graue Sporthose"] = {"chongergrey","chonger",2},
["Grüne Sporthose"] = {"chongergang","chonger",2},
["Rote Sporthose"] = {"chongerred","chonger",2},
["Blaue Sporthose"] = {"chongerblue","chonger",2},
["Dunkelgrüne kurze Hose"] = {"shortsgang","shorts",2},
["Grüne Jeanshose"] = {"denimsgang","jeans",2},
["Rote Jeanshose"] = {"denimsred","jeans",2},

--//Schuhe
["Barfuß"] = {"foot","feet",3},
["Biker Stiefel"] = {"biker","biker",3},
["Cowboy Stiefel"] = {"cowboyboot","biker",3},
["Cowboy Stiefel 2"] = {"snakeskin","biker",3},
["Weiß-graue Schuhe"] = {"bask2semi","bask1",3},
["Weiße Schuhe"] = {"bask1eris","bask1",3},
["Weiße Schuhe"] = {"sneakerbincgang","sneaker",3},
["Grüne Schuhe"] = {"sneakerbincblue","sneaker",3},
["Blaue Schuhe"] = {"sneakerbincblk","sneaker",3},
["Schwarze Schuhe"] = {"sandal","flipflop",3},
["Sandalen"] = {"sandalsock","flipflop",3},
["Sandalen mit Socken"] = {"flipflop","flipflop",3},
["Blau-schwarze Sandalen"] = {"hitop","bask1",3},
["Blau-weiße Turnschuhe"] = {"convproblk","conv",3},

["Hut 1"] = {"bandred","bandana",16},
["Hut 2"] = {"bandblue","bandana",16},
["Hut 3"] = {"bandgang","bandana",16},
["Hut 4"] = {"bandblack","bandana",16},
["Hut 5"] = {"bandred2","bandknots",16},
["Hut 6"] = {"bandblue2","bandknots",16},
["Hut 7"] = {"bandblack2","bandknots",16},
["Hut 8"] = {"bandgang2","bandknots",16},
["Hut 9"] = {"capknitgrn","capknit",16},
["Hut 10"] = {"captruck","captruck",16},
["Hut 11"] = {"boxingcap","boxingcap",16},
["Hut 12"] = {"hockey","hockeymask",16},
["Hut 13"] = {"capgang","cap",16},
["Hut 14"] = {"capgangback","capback",16},
["Hut 15"] = {"capgangside","capside",16},
["Hut 16"] = {"capgangover","capovereye",16},
["Hut 17"] = {"capgangup","caprimup",16},
["Hut 18"] = {"bikerhelmet","bikerhelmet",16},
["Hut 19"] = {"capred","cap",16},
["Hut 20"] = {"capredback","capback",16},
["Hut 21"] = {"capredside","capside",16},
["Hut 22"] = {"capredover","capovereye",16},
["Hut 23"] = {"capredup","caprimup",16},
["Hut 24"] = {"capblue","cap",16},
["Hut 25"] = {"capblueback","capback",16},
["Hut 26"] = {"capblueside","capside",16},
["Hut 27"] = {"capblueover","capovereye",16},
["Hut 28"] = {"capblueup","caprimup",16},
["Hut 29"] = {"skullyblk","skullycap",16},
["Hut 30"] = {"skullygrn","skullycap",16},
["Hut 31"] = {"hatmancblk","hatmanc",16},
["Hut 32"] = {"hatmancplaid","hatmanc",16},
["Hut 33"] = {"capzip","cap",16},
["Hut 34"] = {"capzipback","capback",16},
["Hut 35"] = {"capzipside","capside",16},
["Hut 36"] = {"capzipover","capovereye",16},
["Hut 37"] = {"capzipup","caprimup",16},
["Hut 38"] = {"beretred","beret",16},
["Hut 39"] = {"beretblk","beret",16},
["Hut 40"] = {"capblk","cap",16},
["Hut 41"] = {"capblkback","capback",16},
["Hut 42"] = {"capblkside","capside",16},
["Hut 43"] = {"capblkover","capovereye",16},
["Hut 44"] = {"capblkup","caprimup",16},
["Hut 45"] = {"trilbydrk","trilby",16},
["Hut 46"] = {"trilbylght","trilby",16},
["Hut 47"] = {"bowler","bowler",16},
["Hut 48"] = {"bowlerred","bowler",16},
["Hut 49"] = {"bowlerblue","bowler",16},
["Hut 50"] = {"bowleryellow","bowler",16},
["Hut 51"] = {"boater","boater",16},
["Hut 52"] = {"bowlergang","bowler",16},
["Hut 53"] = {"boaterblk","boater",16},

["Bandana 1"] = {"bandred3","bandmask",15},
["Bandana 2"] = {"bandblue3","bandmask",15},
["Bandana 3"] = {"bandgang3","bandmask",15},
["Bandana 4"] = {"bandblack3","bandmask",15},}

-- Echte Preise, NIE vom Client uebernehmen (gleiches Prinzip wie giveFgunsWeapon in
-- fdepots.lua bzw. onVioOAmtCarTuning in mechaniker_func_server.lua) - sonst koennte
-- ein veraenderter Client einen beliebig niedrigen PRICE mitschicken und sich Klamotten
-- quasi umsonst holen. Muss zu den Preis-Spalten in client.lua passen (CJKlamottenShirts,
-- CJKlamottenHosen, CJKlamottenSchuhe, CJKlamottenHaare, Hut, Bandana).
local echtePreiseKlamotten = {
	["Freier Oberkörper"] = 0, ["Weißes Unterhemd"] = 35, ["Gestreiftes Shirt"] = 70, ["Weißes Shirt"] = 50,
	["I love LS Shirt"] = 400, ["Weißes Homie Shirt"] = 125, ["Rotes Hemd"] = 90, ["Blaues Hemd"] = 90,
	["Graues Hemd"] = 90, ["Grünes Shirt"] = 65, ["Oranges Shirt"] = 65, ["Rot schwarzes Shirt"] = 235,
	["Rote College-Jacke"] = 700, ["Dunkelrote College-Jacke"] = 700, ["Rotes Basketballshirt"] = 230,
	["Weißes Basketballshirt"] = 230, ["Blaues Sixty-niners Shirt"] = 240, ["Baseballshirt"] = 135,
	["Rotes Shirt"] = 75, ["Schwarzes Shirt"] = 75, ["Weiß rote Jacke"] = 350, ["Blaues Hockeyshirt"] = 400,
	["Grün weißes Shirt"] = 125, ["Bunte Jacke"] = 175, ["Weißes Shirt mit roten Ärmeln"] = 250,
	["Rotes Shirt mit Streifen"] = 345, ["Weißes Shirt mit 5 Aufdruck"] = 325,
	["Grün weißes Shirt mit Urban Aufdruck"] = 255, ["Graue Jacke"] = 600, ["Grüne Jacke"] = 600,
	["Weißer Hoodie"] = 200, ["Blaue weiße Weste"] = 375, ["Grüne Knopfjacke"] = 400, ["Graue Knopfjacke"] = 400,
	["Weißer Rockstar Pullover"] = 500, ["Blaue Rockstar Jacke"] = 600, ["Schwarze Rockstar Jacke"] = 600,
	["Grüne Rockstar Jacke"] = 600, ["Braunes Shirt"] = 300, ["Blau weißes Hemd"] = 250,
	["Grünes Shirt mit UZI"] = 350,
	["Weiße Unterhose"] = 0, ["Grüne camouflage Hose"] = 345, ["Graue camouflage Hose"] = 345,
	["Graue Hose"] = 200, ["Grüne Hose"] = 200, ["Weiße Hose"] = 200, ["Blaue Jogginghose"] = 150,
	["Jeanshose"] = 300, ["Schwarze Unterhose"] = 50, ["Herz Unterhose"] = 65, ["Weiße Jeanshose"] = 400,
	["Rote Jogginghose"] = 350, ["Graue Jogginghose"] = 350, ["Grüne Jogginghose"] = 350,
	["Weiße kurze Hose"] = 275, ["Rote kurze Hose"] = 275, ["Hellrote kurze Hose"] = 275, ["Bunte Hose"] = 435,
	["Graue kurze Hose"] = 350, ["Grüne kurze Hose"] = 350, ["Graue Sporthose"] = 400, ["Grüne Sporthose"] = 400,
	["Rote Sporthose"] = 400, ["Blaue Sporthose"] = 400, ["Dunkelgrüne kurze Hose"] = 350,
	["Grüne Jeanshose"] = 560, ["Rote Jeanshose"] = 560,
	["Barfuß"] = 0, ["Cowboy Stiefel"] = 200, ["Cowboy Stiefel 2"] = 200, ["Biker Stiefel"] = 200,
	["Weiß-graue Schuhe"] = 150, ["Weiße Schuhe"] = 330, ["Grüne Schuhe"] = 300, ["Blaue Schuhe"] = 360,
	["Schwarze Schuhe"] = 275, ["Sandalen"] = 150, ["Sandalen mit Socken"] = 175,
	["Blau-schwarze Sandalen"] = 175, ["Blau-weiße Turnschuhe"] = 180,
	["Braune kurze Haare"] = 50, ["Blonde kurze Haare"] = 70, ["Rote kurze Haare"] = 70,
	["Blaue kurze Haare"] = 70, ["Grüne kurze Haare"] = 70, ["Pinke kurze Haare"] = 70,
	["Glatze ohne Bart"] = 40, ["Glatze mit Vollbart"] = 80, ["Glatze mit Oberlippenbart"] = 65,
	["Glatze mit Bart"] = 55, ["Soldatenschnitt"] = 30, ["Hoher Afro"] = 150, ["Schwarze Strähnen"] = 240,
	["Blonde Strähnen"] = 240, ["Kurze Haare mit Muster"] = 35, ["Brauner Punkschnitt"] = 95,
	["Blonder Punkschnitt"] = 95, ["Pinker Punkschnitt"] = 95, ["Brauner Punkschnitt mit Vollbart"] = 105,
	["Afro"] = 125, ["Afro mit Oberlippenbart"] = 140, ["Afro mit Vollbart"] = 140, ["Blonder Afro"] = 240,
	["Brauner Elvisschnitt"] = 180, ["Schwarzer Elvisschnitt"] = 450, ["Kurze Haare mit Vollbart"] = 100,
	["Kurze Haare mit Oberlippenbart"] = 100,
}
for i=1,53 do echtePreiseKlamotten["Hut "..i] = 16 end
for i=1,4 do echtePreiseKlamotten["Bandana "..i] = 15 end

-- // Klamotten hinzufügen
addEvent("addCJPedClothes",true)
addEventHandler("addCJPedClothes",root,function(ID,PRICE,TYP)
	if(getElementModel(client) == 0)then
		local preis = echtePreiseKlamotten[ID]
		if not preis or not clothes[ID] then return end
		if(MtxGetElementData(client,"money")>=preis)then
			MtxSetElementData(client,"money",MtxGetElementData(client,"money")-preis)
			addPedClothes(client,clothes[ID][1],clothes[ID][2],clothes[ID][3])
			
			if(ID == "Afro" or ID == "Afro mit Oberlippenbart" or ID == "Afro mit Vollbart" or ID == "Blonder Afro")then
				--setPlayerAchievment(client,"hair_afro","Was'n abgefuckter Wuschelkopf!")
			end
			
			if(TYP == "hairs")then
				infobox(client,"Du hast nun neue Haare.",7500,0,255,0)
				dbExec(handler,"UPDATE clothes SET hair1 = ?, hair2 = ? WHERE Name = ?",clothes[ID][1],clothes[ID][2],getPlayerName(client))
			elseif(TYP == "shirts")then
				infobox(client,"Artikel gekauft.",7500,0,255,0)
				dbExec(handler,"UPDATE clothes SET shirt1 = ?, shirt2 = ? WHERE Name = ?",clothes[ID][1],clothes[ID][2],getPlayerName(client))
			elseif(TYP == "hosen")then
				infobox(client,"Artikel gekauft.",7500,0,255,0)
				dbExec(handler,"UPDATE clothes SET hose1 = ?, hose2 = ? WHERE Name = ?",clothes[ID][1],clothes[ID][2],getPlayerName(client))
			elseif(TYP == "schuhe")then
				infobox(client,"Artikel gekauft.",7500,0,255,0)
				dbExec(handler,"UPDATE clothes SET schuhe1 = ?, schuhe2 = ? WHERE Name = ?",clothes[ID][1],clothes[ID][2],getPlayerName(client))
			elseif(TYP == "Hut")then
				infobox(client,"Artikel gekauft.",7500,0,255,0)
				dbExec(handler,"UPDATE clothes SET Hut1 = ?, Hut2 = ? WHERE Name = ?",clothes[ID][1],clothes[ID][2],getPlayerName(client))
			elseif(TYP == "Bandana")then
				infobox(client,"Artikel gekauft.",7500,0,255,0)
				dbExec(handler,"UPDATE clothes SET Bandana1 = ?, Bandana2 = ? WHERE Name = ?",clothes[ID][1],clothes[ID][2],getPlayerName(client))
			end
		else outputChatBox("Du hast nicht genug Geld dabei ("..preis..""..Tables.waehrung..")!",client)end
	end
end)


local kleidungsreingehmakrer = createMarker( -1695.052734375, 951.609375, 24.890625, "cylinder", -0.95, 255, 0, 0)
local kleidungsrausgehmarker = createMarker( 226.9853515625, -8.1689453125, 1002.2109375, "cylinder", -0.95, 255, 0, 0)
setElementInterior( kleidungsrausgehmarker, 5)

function reinindenkleidladen(player)
	if getElementType(player) == "player" and isPedInVehicle(player) == false then
		setElementPosition( player, 223.4296875, -8.3984375, 1002.2109375)
		setElementInterior(player, 5)
		addEventHandler("onPlayerWeaponSwitch",player,dontHoldWeapon)
	end
end
addEventHandler("onMarkerHit", kleidungsreingehmakrer, reinindenkleidladen)
function rausausdenkleidladen(player)
	if getElementType(player) == "player" and isPedInVehicle(player) == false then
		setElementPosition( player, -1698.0361328125, 950.1767578125, 24.890625)
		setElementInterior( player, 0)
		removeEventHandler("onPlayerWeaponSwitch",player,dontHoldWeapon)
	end
end
addEventHandler("onMarkerHit", kleidungsrausgehmarker, rausausdenkleidladen)



local hairreingehmakrer = createMarker( -2491.9677734375,-38.8525390625,25.765625, "cylinder", -0.95, 125, 125, 0)
local hairrausgehmakrer = createMarker( 412.099609375,-53.630859375,1001.8984375, "cylinder", -0.95, 125, 125, 0)
setElementInterior( hairrausgehmakrer, 12)

function hairreingehmakrer_func(player)
	if getElementType(player) == "player" and isPedInVehicle(player) == false then
		setElementPosition( player, 412.13223266602,-53.475124359131,1001.8984375)
		setElementInterior(player, 12)
		addEventHandler("onPlayerWeaponSwitch",player,dontHoldWeapon)
	end
end
addEventHandler("onMarkerHit", hairreingehmakrer, hairreingehmakrer_func)
function hairrausgehmakrer_func(player)
	if getElementType(player) == "player" and isPedInVehicle(player) == false then
		setElementPosition( player, -2492.5471191406,-39.002208709717,25.765625)
		setElementInterior( player, 0)
		removeEventHandler("onPlayerWeaponSwitch",player,dontHoldWeapon)
	end
end
addEventHandler("onMarkerHit", hairrausgehmakrer, hairrausgehmakrer_func)