--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

local CJShop = {gridlist = {},window = {},button = {}}

local CJKategorien = {
{"Shirts"},
{"Hosen"},
{"Schuhe"},
{"Hut"},
{"Bandana"},}

local CJKlamottenShirts = {
-- Bis ID 42
{"Freier Oberkörper",0},
{"Weißes Unterhemd",35},
{"Gestreiftes Shirt",70},
{"Weißes Shirt",50},
{"I love LS Shirt",400},
{"Weißes Homie Shirt",125},
{"Rotes Hemd",90},
{"Blaues Hemd",90},
{"Graues Hemd",90},
{"Grünes Shirt",65},
{"Oranges Shirt",65},
{"Rot schwarzes Shirt",235},
{"Rote College-Jacke",700},
{"Dunkelrote College-Jacke",700},
{"Rotes Basketballshirt",230},
{"Weißes Basketballshirt",230},
{"Blaues Sixty-niners Shirt",240},
{"Baseballshirt",135},
{"Rotes Shirt",75},
{"Schwarzes Shirt",75},
{"Weiß rote Jacke",350},
{"Blaues Hockeyshirt",400},
{"Grün weißes Shirt",125},
{"Bunte Jacke",175},
{"Weißes Shirt",80},
{"Weißes Shirt mit roten Ärmeln",250},
{"Rotes Shirt mit Streifen",345},
{"Weißes Shirt mit 5 Aufdruck",325},
{"Grün weißes Shirt mit Urban Aufdruck",255},
{"Graue Jacke",600},
{"Grüne Jacke",600},
{"Weißer Hoodie",200},
{"Blaue weiße Weste",375},
{"Grüne Knopfjacke",400},
{"Graue Knopfjacke",400},
{"Weißer Rockstar Pullover",500},
{"Blaue Rockstar Jacke",600},
{"Schwarze Rockstar Jacke",600},
{"Grüne Rockstar Jacke",600},
{"Braunes Shirt",300},
{"Blau weißes Hemd",250},
{"Grünes Shirt mit UZI",350},}

local CJKlamottenHaare = {
{"Braune kurze Haare",50},
{"Blonde kurze Haare",70},
{"Rote kurze Haare",70},
{"Blaue kurze Haare",70},
{"Grüne kurze Haare",70},
{"Pinke kurze Haare",70},
{"Glatze ohne Bart",40},
{"Glatze mit Vollbart",80},
{"Glatze mit Oberlippenbart",65},
{"Glatze mit Bart",55},
{"Soldatenschnitt",30},
{"Hoher Afro",150},
{"Schwarze Strähnen",240},
{"Blonde Strähnen",240},
{"Kurze Haare mit Muster",35},
{"Brauner Punkschnitt",95},
{"Blonder Punkschnitt",95},
{"Pinker Punkschnitt",95},
{"Brauner Punkschnitt mit Vollbart",105},
{"Afro",125},
{"Afro mit Oberlippenbart",140},
{"Afro mit Vollbart",140},
{"Blonder Afro",240},
{"Brauner Elvisschnitt",180},
{"Schwarzer Elvisschnitt",450},
{"Kurze Haare mit Vollbart",100},
{"Kurze Haare mit Oberlippenbart",100},}

local CJKlamottenHosen = {
{"Weiße Unterhose",0},
{"Grüne camouflage Hose",345},
{"Graue camouflage Hose",345},
{"Graue Hose",200},
{"Grüne Hose",200},
{"Weiße Hose",200},
{"Blaue Jogginghose",150},
{"Jeanshose",300},
{"Schwarze Unterhose",50},
{"Herz Unterhose",65},
{"Weiße Jeanshose",400},
{"Rote Jogginghose",350},
{"Graue Jogginghose",350},
{"Blaue Jogginghose",350},
{"Grüne Jogginghose",350},
{"Weiße kurze Hose",275},
{"Rote kurze Hose",275},
{"Hellrote kurze Hose",275},
{"Bunte Hose",435},
{"Graue kurze Hose",350},
{"Grüne kurze Hose",350},
{"Graue Sporthose",400},
{"Grüne Sporthose",400},
{"Rote Sporthose",400},
{"Blaue Sporthose",400},
{"Dunkelgrüne kurze Hose",350},
{"Grüne Jeanshose",560},
{"Rote Jeanshose",560},}

local CJKlamottenSchuhe = {
{"Barfuß",0},
{"Cowboy Stiefel",200},
{"Cowboy Stiefel 2",200},
{"Biker Stiefel",200},
{"Weiß-graue Schuhe",150},
{"Weiße Schuhe",330},
{"Grüne Schuhe",300},
{"Blaue Schuhe",360},
{"Schwarze Schuhe",275},
{"Sandalen",150},
{"Sandalen mit Socken",175},
{"Blau-schwarze Sandalen",175},
{"Blau-weiße Turnschuhe",180},}

local Hut = {
{"Hut 1",16},
{"Hut 2",16},
{"Hut 3",16},
{"Hut 4",16},
{"Hut 5",16},
{"Hut 6",16},
{"Hut 7",16},
{"Hut 8",16},
{"Hut 9",16},
{"Hut 10",16},
{"Hut 11",16},
{"Hut 12",16},
{"Hut 13",16},
{"Hut 14",16},
{"Hut 15",16},
{"Hut 16",16},
{"Hut 17",16},
{"Hut 18",16},
{"Hut 19",16},
{"Hut 20",16},
{"Hut 21",16},
{"Hut 22",16},
{"Hut 23",16},
{"Hut 24",16},
{"Hut 25",16},
{"Hut 26",16},
{"Hut 27",16},
{"Hut 28",16},
{"Hut 29",16},
{"Hut 30",16},
{"Hut 31",16},
{"Hut 32",16},
{"Hut 33",16},
{"Hut 34",16},
{"Hut 35",16},
{"Hut 36",16},
{"Hut 37",16},
{"Hut 38",16},
{"Hut 39",16},
{"Hut 40",16},
{"Hut 41",16},
{"Hut 42",16},
{"Hut 43",16},
{"Hut 44",16},
{"Hut 45",16},
{"Hut 46",16},
{"Hut 47",16},
{"Hut 48",16},
{"Hut 49",16},
{"Hut 50",16},
{"Hut 51",16},
{"Hut 52",16},
{"Hut 53",16},}


local Bandana = {
{"Bandana 1",15},
{"Bandana 2",15},
{"Bandana 3",15},
{"Bandana 4",15},}



local clothes=
{
--//Shirts
["Freier Oberkörper"] = {"player_torso","torso",0},
["Weißes Unterhemd"] = {"vest","vest",0},
["Gestreiftes Shirt"] = {"tshirt2horiz","tshirt2",0},
["Weißes Shirt"] = {"tshirtwhite","tshirt",0},
["Grünes Shirt mit UZI"] = {"tshirtmaddgrn","tshirt",0},
["I love LS Shirt"] = {"tshirtilovels","tshirt",0},
["Weißes Homie Shirt"] = {"tshirtblunts","tshirt",0},
["Rotes Hemd"] = {"shirtbplaid","shirtb",0},
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

--//Hut
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

--//Bandana
["Bandana 1"] = {"bandred3","bandmask",15},
["Bandana 2"] = {"bandblue3","bandmask",15},
["Bandana 3"] = {"bandgang3","bandmask",15},
["Bandana 4"] = {"bandblack3","bandmask",15},}


function clientCJClothesShop()
	if getElementData(lp,"ElementClicked")==false then
		guiSetInputMode("no_binds_when_editing")
		showCursor(true)
		setElementData(lp,"ElementClicked",true)
		setElementAlpha(lp,0)

        CJShop.window[1] = dgsCreateWindow(0.01, 0.27, 0.38, 0.43, "CJ Skinshop (Klick - anprobieren, Doppelklick - kaufen)", true, nil,nil,nil,nil,nil, tocolor(16,29,61,255))
        dgsBringToFront(CJShop.window[1])
        dgsSetProperty(CJShop.window[1], "image", false)
        dgsWindowSetMovable(CJShop.window[1], false)
        dgsWindowSetSizable(CJShop.window[1], false)

        CJShop.gridlist[1] = dgsCreateGridList(0.02, 0.07, 0.31, 0.82, true, CJShop.window[1])
        kategorien = dgsGridListAddColumn(CJShop.gridlist[1], "Kategorie", 0.9)
        dgsGridListAddRow(CJShop.gridlist[1])

		for key,_ in pairs(CJKategorien)do
			row = dgsGridListAddRow(CJShop.gridlist[1])
			dgsGridListSetItemText(CJShop.gridlist[1],row,kategorien,CJKategorien[key][1],false,false)
		end

        CJShop.gridlist[2] = dgsCreateGridList(0.35, 0.07, 0.63, 0.82, true, CJShop.window[1])
        klamotten = dgsGridListAddColumn(CJShop.gridlist[2], "Klamotten", 0.7)
		preis = dgsGridListAddColumn(CJShop.gridlist[2], "Preis", 0.5)
        dgsGridListAddRow(CJShop.gridlist[2])

		addEventHandler("onDgsGridListSelect",CJShop.gridlist[1],function(r)
			dgsGridListClear(CJShop.gridlist[2])
			if not r or r == -1 then return end
			ID = dgsGridListGetItemText(CJShop.gridlist[1],r,kategorien)

			if(ID == "Shirts")then klamottentable = CJKlamottenShirts end
			if(ID == "Hosen")then klamottentable = CJKlamottenHosen end
			if(ID == "Schuhe")then klamottentable = CJKlamottenSchuhe end
			if(ID == "Hut")then klamottentable = Hut end
			if(ID == "Bandana")then klamottentable = Bandana end

			for key,_ in pairs(klamottentable)do
				row = dgsGridListAddRow(CJShop.gridlist[2])
				dgsGridListSetItemText(CJShop.gridlist[2],row,klamotten,klamottentable[key][1],false,false)
				dgsGridListSetItemText(CJShop.gridlist[2],row,preis,klamottentable[key][2],false,false)
			end
		end,false)

		addEventHandler("onDgsGridListSelect",CJShop.gridlist[2],function(r)
			if not r or r == -1 then return end
			ID = dgsGridListGetItemText(CJShop.gridlist[2],r,klamotten)

			if(not(ID == ""))then
				addPedClothes(cjShopPed,clothes[ID][1],clothes[ID][2],clothes[ID][3])
			end
		end,false)

		addEventHandler("onDgsMouseDoubleClick",CJShop.gridlist[2],function()
			local kr = dgsGridListGetSelectedItem(CJShop.gridlist[1])
			local ir = dgsGridListGetSelectedItem(CJShop.gridlist[2])
			if kr == -1 or ir == -1 then return end
			KATEGORIE = dgsGridListGetItemText(CJShop.gridlist[1],kr,kategorien)
			ID = dgsGridListGetItemText(CJShop.gridlist[2],ir,klamotten)
			PRICE = dgsGridListGetItemText(CJShop.gridlist[2],ir,preis)

			if(not(ID == ""))then
				if(KATEGORIE == "Shirts")then
					triggerServerEvent("addCJPedClothes",lp,ID,PRICE,"shirts")
				elseif(KATEGORIE == "Hosen")then
					triggerServerEvent("addCJPedClothes",lp,ID,PRICE,"hosen")
				elseif(KATEGORIE == "Schuhe")then
					triggerServerEvent("addCJPedClothes",lp,ID,PRICE,"schuhe")
				elseif(KATEGORIE == "Hut")then
					triggerServerEvent("addCJPedClothes",lp,ID,PRICE,"Hut")
				elseif(KATEGORIE == "Bandana")then
					triggerServerEvent("addCJPedClothes",lp,ID,PRICE,"Bandana")
				end
			end
		end,false)

		CJShop.button[1] = dgsCreateButton(0.02, 0.91, 0.96, 0.06, "Schließen", true, CJShop.window[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		addEventHandler("onDgsMouseClickUp",CJShop.button[1],function(btn)
			if btn ~= "left" then return end
			destroyElement(CJShop.window[1])
			CJShop.window[1] = nil
			destroyElement(cjShopPed)
			setCameraTarget(lp)
			setElementAlpha(lp,255)
			showCursor(false)
			guiSetInputMode("allow_binds")
			setElementData(lp,"ElementClicked",false)
		end,false)

		cjShopPed = createPed(0,202.24049377441,-4.0901470184326,1001.2109375,270)
		setElementInterior(cjShopPed,5)
		setCameraMatrix(209.48950195313,-4.3166999816895,1002.0604248047,208.49360656738,-4.3109288215637,1001.9700317383)
	end
end
addEvent("clientCJClothesShop",true)
addEventHandler("clientCJClothesShop",root,clientCJClothesShop)

function HairShop()
	if getElementData(lp,"ElementClicked")==false then
		guiSetInputMode("no_binds_when_editing")
		showCursor(true)
		setElementData(lp,"ElementClicked",true)

        CJShop.window[1] = dgsCreateWindow(0.01, 0.28, 0.26, 0.43, "Friseur (Klick - anprobieren, Doppelklick - kaufen)", true, nil,nil,nil,nil,nil, tocolor(16,29,61,255))
        dgsBringToFront(CJShop.window[1])
        dgsSetProperty(CJShop.window[1], "image", false)
        dgsWindowSetMovable(CJShop.window[1], false)
        dgsWindowSetSizable(CJShop.window[1], false)

        CJShop.gridlist[1] = dgsCreateGridList(0.03, 0.07, 0.95, 0.81, true, CJShop.window[1])
        haare = dgsGridListAddColumn(CJShop.gridlist[1], "Haare", 0.7)
        preis = dgsGridListAddColumn(CJShop.gridlist[1], "Preis", 0.5)
        CJShop.button[1] = dgsCreateButton(0.03, 0.90, 0.95, 0.07, "Schließen", true, CJShop.window[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		setElementAlpha(lp,0);

		for key,_ in pairs(CJKlamottenHaare)do
			row = dgsGridListAddRow(CJShop.gridlist[1])
			dgsGridListSetItemText(CJShop.gridlist[1],row,haare,CJKlamottenHaare[key][1],false,false)
			dgsGridListSetItemText(CJShop.gridlist[1],row,preis,CJKlamottenHaare[key][2],false,false)
		end

		addEventHandler("onDgsGridListSelect",CJShop.gridlist[1],function(r)
			if not r or r == -1 then return end
			ID = dgsGridListGetItemText(CJShop.gridlist[1],r,haare)

			if(not(ID == ""))then
				addPedClothes(cjShopPed,clothes[ID][1],clothes[ID][2],clothes[ID][3])
			end
		end,false)

		addEventHandler("onDgsMouseDoubleClick",CJShop.gridlist[1],function()
			local hr = dgsGridListGetSelectedItem(CJShop.gridlist[1])
			if hr == -1 then return end
			ID = dgsGridListGetItemText(CJShop.gridlist[1],hr,haare)
			PRICE = dgsGridListGetItemText(CJShop.gridlist[1],hr,preis)

			if(not(ID == ""))then
				triggerServerEvent("addCJPedClothes",lp,ID,PRICE,"hairs")
			end
		end,false)

		cjShopPed = createPed(0,412.1044921875,-49.132778167725,1001.9010620117,180)
		setElementInterior(cjShopPed,12)
		setCameraMatrix(411.84899902344,-54.06909942627,1002.7196044922,411.87268066406,-53.107410430908,1002.446472168)

		addEventHandler("onDgsMouseClickUp",CJShop.button[1],function(btn)
			if btn ~= "left" then return end
			destroyElement(CJShop.window[1])
			CJShop.window[1] = nil
			destroyElement(cjShopPed)
			setCameraTarget(lp)
			setElementAlpha(lp,255)
			showCursor(false)
			guiSetInputMode("allow_binds")
			setElementData(lp,"ElementClicked",false)
		end,false)
	end
end
addEvent("HairShop",true)
addEventHandler("HairShop",root,HairShop)

local CJ_X, CJ_Y, CJ_Z = 202.91520690918, -12.234784126282, 1001.2109375
local CJ_TEXT = "Lauf in den Pickup, um dir für\n2500"..Tables.waehrung.." einen CJ-Skin zu kaufen."

addEventHandler("onClientRender",root,function()
	local px, py, pz = getElementPosition(lp)
	if getDistanceBetweenPoints3D(CJ_X, CJ_Y, CJ_Z, px, py, pz) > 5 then return end

	local gsx, gsy = getScreenFromWorldPosition(CJ_X, CJ_Y, CJ_Z)
	if not gsx or not gsy then return end

	local gpx, gpy, gpz = getCameraMatrix()
	if not isLineOfSightClear(CJ_X, CJ_Y, CJ_Z, gpx, gpy, gpz, true, false, false) then return end

	dxDrawText(CJ_TEXT,gsx,gsy,gsx,gsy,tocolor(255,255,255,255),1.10,"arial","center","top",false,false,false,true)
end)