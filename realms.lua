local _, ns = ...
local lower, gsub, unpack= string.utf8lower, string.gsub, unpack

-- portals: us, eu, kr, tw, ch
-- locales: deDE, enUS, enGB, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW

-- only load realm data for our region, US can never encounter EU etc.
local region = string.lower( GetCVar('portal') or '' )

-- required info: realm name, id, battle group, language
local realmInfo = {}
function ns.GetRealmInfoFromName(realmName)
	realmName = gsub(realmName, "%s-%b()", "") -- remove suffixes such as (EU)
	realmName = gsub(realmName, " ", "")

	local data = realmInfo[ realmName ]
	if data then
		return data.id, data.plain or realmName, data.locale, data.pvp, data.rp, data.group
	else
		for _, data in pairs(realmInfo) do
			if data.plain and data.plain == realmName then
				return data.id, data.plain, data.locale, data.pvp, data.rp, data.group
			end
		end
	end
end

function ns.GetRealmInfoFromID(realmID, asTable)
	if type(realmID) == "string" then
		realmID = tonumber(realmID)
	end

	for realmName, data in pairs(realmInfo) do
		if data.id == realmID then
			if asTable then
				return data
			else
				return realmID, data.plain or realmName, data.locale, data.pvp, data.rp, data.group
			end
		end
	end
end

if     region == 'us' then
	realmInfo = {
		-- us
		["AeriePeak"] 			= { id = 206, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Aggramar"] 			= { id =  58, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Alexstrasza"] 		= { id = 188, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Alleria"] 			= { id = 189, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Antonidas"] 			= { id = 150, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Arathor"] 			= { id =  21, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Area52"] 				= { id =  96, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Arygos"] 				= { id = 210, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Azjol-Nerub"] 		= { id = 226, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Azuremyst"] 			= { id =  98, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Baelgun"] 			= { id = 134, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Blackhand"] 			= { id = 191, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Blade'sEdge"] 		= { id =  99, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Bladefist"] 			= { id =  40, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Bloodhoof"] 			= { id = 118, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["BoreanTundra"]		= { id = 151, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Bronzebeard"] 		= { id = 229, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Dalaran"] 			= { id = 172, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Dentarg"] 			= { id = 174, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Doomhammer"] 			= { id = 214, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Draenor"] 			= { id = 233, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Dragonblight"] 		= { id = 234, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Drak'thul"] 			= { id =   4, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Durotan"] 			= { id = 119, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Eitrigg"] 			= { id =   6, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Eldre'Thalas"] 		= { id =  24, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Eonar"] 				= { id =  63, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Exodar"] 				= { id = 103, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Garona"] 				= { id = 195, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Ghostlands"] 			= { id = 106, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Hellscream"] 			= { id = 198, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Hyjal"] 				= { id =  46, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Kael'thas"] 			= { id = 200, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Kargath"] 			= { id =  67, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Khadgar"] 			= { id = 178, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["KhazModan"] 			= { id =  11, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Kilrogg"] 			= { id =  87, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["KulTiras"] 			= { id =  13, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Lightbringer"] 		= { id =  48, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Lothar"] 				= { id = 121, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Malfurion"] 			= { id = 142, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Malygos"] 			= { id =  71, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Medivh"] 				= { id = 125, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Nordrassil"] 			= { id = 162, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Norgannon"] 			= { id = 180, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Perenolde"] 			= { id = 237, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Proudmoore"] 			= { id =  90, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Ravencrest"] 			= { id = 202, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Rexxar"] 				= { id =  17, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Runetotem"] 			= { id =  18, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Sen'jin"] 			= { id =  91, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Shadowsong"] 			= { id =  31, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Silvermoon"] 			= { id =  32, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Stormrage"] 			= { id = 128, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Suramar"] 			= { id = 240, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Terenas"] 			= { id =  36, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Terokkar"] 			= { id = 109, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Thrall"] 				= { id = 183, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Thunderhorn"] 		= { id =  75, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Trollbane"] 			= { id = 129, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Turalyon"] 			= { id = 184, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Uldaman"] 			= { id = 224, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Uldum"] 				= { id = 241, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Vek'nilash"] 			= { id =  95, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Ysera"] 				= { id = 185, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Zul'jin"] 			= { id = 131, group = "", locale = "enUS", rp = nil,  pvp = nil },

		["Aegwynn"] 			= { id =   1, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Agamaggan"] 			= { id = 132, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Anetheron"] 			= { id = 169, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Anub'arak"] 			= { id =  38, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Archimonde"] 			= { id = 170, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Arthas"] 				= { id = 115, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Auchindoun"] 			= { id =  97, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Azshara"] 			= { id = 133, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Balnazzar"] 			= { id = 190, group = "", locale = "enUS", rp = nil,  pvp = true },
		["BlackDragonflight"] 	= { id = 171, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Blackrock"] 			= { id =  79, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Bloodscalp"] 			= { id = 227, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Boulderfist"] 		= { id = 228, group = "", locale = "enUS", rp = nil,  pvp = true },
		["BurningBlade"] 		= { id =  59, group = "", locale = "enUS", rp = nil,  pvp = true },
		["BurningLegion"] 		= { id =  60, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Cho'gall"] 			= { id = 192, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Chromaggus"] 			= { id =   3, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Crushridge"] 			= { id = 230, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Daggerspine"] 		= { id = 231, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Dalvengyr"] 			= { id = 173, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Darkspear"] 			= { id = 232, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Deathwing"] 			= { id = 212, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Destromath"] 			= { id = 193, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Dethecus"] 			= { id = 194, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Dragonmaw"] 			= { id =  23, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Dunemaul"] 			= { id = 235, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Eredar"] 				= { id =  64, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Executus"] 			= { id = 176, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Frostmane"] 			= { id =  26, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Frostwolf"] 			= { id =  84, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Gorgonnash"] 			= { id = 196, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Gul'dan"] 			= { id = 197, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Hakkar"] 				= { id =   9, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Haomarush"] 			= { id = 177, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Illidan"] 			= { id = 199, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Jaedenar"] 			= { id = 217, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Kel'Thuzad"] 			= { id = 218, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Kil'jaeden"] 			= { id =  86, group = "", locale = "enUS", rp = nil,  pvp = true },
		["LaughingSkull"] 		= { id =  68, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Lightning'sBlade"] 	= { id =  69, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Magtheridon"] 		= { id = 123, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Mal'Ganis"] 			= { id = 179, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Mannoroth"] 			= { id = 124, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Mug'thol"] 			= { id =  15, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Nathrezim"] 			= { id =  28, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Nazjatar"] 			= { id = 144, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Ner'zhul"] 			= { id =  89, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Onyxia"] 				= { id = 220, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Sargeras"] 			= { id = 145, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Shadowmoon"] 			= { id =  74, group = "", locale = "enUS", rp = nil,  pvp = true },
		["ShatteredHalls"] 		= { id = 108, group = "", locale = "enUS", rp = nil,  pvp = true },
		["ShatteredHand"] 		= { id = 126, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Skullcrusher"] 		= { id = 127, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Spinebreaker"] 		= { id = 203, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Stonemaul"] 			= { id = 238, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Stormreaver"] 		= { id = 204, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Stormscale"] 			= { id = 239, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Tichondrius"] 		= { id =  94, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Vashj"] 				= { id =  56, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Warsong"] 			= { id = 130, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Wildhammer"] 			= { id = 149, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Ysondre"] 			= { id = 186, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Zuluhed"] 			= { id = 187, group = "", locale = "enUS", rp = nil,  pvp = true },

		["ArgentDawn"] 			= { id = 114, group = "", locale = "enUS", rp = true, pvp = nil },
		["EarthenRing"] 		= { id =  62, group = "", locale = "enUS", rp = true, pvp = nil },
		["KirinTor"] 			= { id = 201, group = "", locale = "enUS", rp = true, pvp = nil },
		["ShadowCouncil"]		= { id =  30, group = "", locale = "enUS", rp = true, pvp = nil },
		["SteamwheedleCartel"] 	= { id = 182, group = "", locale = "enUS", rp = true, pvp = nil },

		["EmeraldDream"] 		= { id = 137, group = "", locale = "enUS", rp = true, pvp = true },
		["Ravenholdt"] 			= { id =  51, group = "", locale = "enUS", rp = true, pvp = true },
		["TheVentureCo"] 		= { id = 223, group = "", locale = "enUS", rp = true, pvp = true },
		["TwistingNether"] 		= { id = 147, group = "", locale = "enUS", rp = true, pvp = true },

		-- oceanic
		["Caelestrasz"] 		= { id =  80, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Dath'Remar"] 			= { id =  81, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Khaz'goroth"] 		= { id =  85, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Aman'Thul"] 			= { id =  77, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Nagrand"]		 		= { id =  88, group = "", locale = "enUS", rp = nil,  pvp = nil },
		["Saurfang"]	 		= { id =  19, group = "", locale = "enUS", rp = nil,  pvp = nil },

		["Gundrak"] 			= { id =   8, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Jubei'Thos"] 			= { id =  10, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Barthilas"] 			= { id =  78, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Dreadmaul"] 			= { id =  82, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Thaurissan"] 			= { id =  93, group = "", locale = "enUS", rp = nil,  pvp = true },
		["Frostmourne"] 		= { id =  83, group = "", locale = "enUS", rp = nil,  pvp = true },

		-- brazil
		["Gallywix"] 			= { id = 249, group = "", locale = "prBR", rp = nil,  pvp = nil },
		["Goldrinn"] 			= { id = 247, group = "", locale = "prBR", rp = nil,  pvp = nil },
		["Azralon"] 			= { id = 246, group = "", locale = "prBR", rp = nil,  pvp = true },
		["Nemesis"] 			= { id = 248, group = "", locale = "prBR", rp = nil,  pvp = true },
		["TolBarad"] 			= { id = 250, group = "", locale = "prBR", rp = nil,  pvp = true },

		-- latin america
		["Quel'Thalas"] 		= { id =  72, group = "", locale = "esMX", rp = nil,  pvp = nil },
		["Drakkari"] 			= { id =  61, group = "", locale = "esMX", rp = nil,  pvp = true },
		["Ragnaros"] 			= { id =  73, group = "", locale = "esMX", rp = nil,  pvp = true },
	}
elseif region == 'eu' then
	realmInfo = {
		-- EU english
		["AeriePeak"] 			= { id = 206, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Aggramar"] 			= { id =  58, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Alonsus"] 			= { id = 257, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Anachronos"] 			= { id = 258, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Arathor"] 			= { id =  21, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Aszune"] 				= { id = 253, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Azjol-Nerub"] 		= { id = 226, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Azuremyst"] 			= { id =  98, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Blade'sEdge"] 		= { id =  99, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Bloodhoof"] 			= { id = 118, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Bronzebeard"] 		= { id = 229, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["BronzeDragonflight"] 	= { id = 259, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["ChamberofAspects"] 	= { id = 266, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Darkspear"] 			= { id = 232, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Doomhammer"] 			= { id = 214, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Draenor"] 			= { id = 233, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Dragonblight"] 		= { id = 234, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["EmeraldDream"] 		= { id = 137, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Eonar"] 				= { id =  63, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Ghostlands"] 			= { id = 106, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Hellfire"] 			= { id = 283, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Hellscream"] 			= { id = 198, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Khadgar"] 			= { id = 178, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Kilrogg"] 			= { id =  87, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["KulTiras"] 			= { id =  13, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Lightbringer"] 		= { id =  48, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Nagrand"] 			= { id =  88, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Nordrassil"] 			= { id = 162, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Quel'Thalas"]			= { id =  72, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Runetotem"] 			= { id =  18, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Saurfang"] 			= { id =  19, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Shadowsong"] 			= { id =  31, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Silvermoon"] 			= { id =  32, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Stormrage"] 			= { id = 128, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Terenas"] 			= { id =  36, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Terokkar"] 			= { id = 109, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Thunderhorn"] 		= { id =  75, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Turalyon"] 			= { id = 184, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Vek'nilash"] 			= { id =  95, group = "", locale = "enGB", rp = nil,  pvp = nil },
		["Wildhammer"] 			= { id = 149, group = "", locale = "enGB", rp = nil,  pvp = nil },

		["Agamaggan"] 			= { id = 132, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Ahn'Qiraj"] 			= { id = 278, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Al'Akir"] 			= { id = 252, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Auchindoun"] 			= { id =  97, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Balnazzar"] 			= { id = 190, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Bladefist"] 			= { id =  40, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Bloodfeather"] 		= { id = 271, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Bloodscalp"] 			= { id = 227, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Boulderfist"] 		= { id = 228, group = "", locale = "enGB", rp = nil,  pvp = true },
		["BurningBlade"] 		= { id =  59, group = "", locale = "enGB", rp = nil,  pvp = true },
		["BurningLegion"] 		= { id =  60, group = "", locale = "enGB", rp = nil,  pvp = true },
		["BurningSteppes"] 		= { id = 260, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Chromaggus"] 			= { id =   3, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Crushridge"] 			= { id = 230, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Daggerspine"] 		= { id = 231, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Darksorrow"] 			= { id = 272, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Deathwing"] 			= { id = 212, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Dentarg"] 			= { id = 174, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Dragonmaw"] 			= { id =  23, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Drak'thul"] 			= { id =   4, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Dunemaul"] 			= { id = 235, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Emeriss"] 			= { id = 279, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Executus"] 			= { id = 176, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Frostmane"] 			= { id =  26, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Frostwhisper"] 		= { id = 274, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Genjuros"] 			= { id = 263, group = "", locale = "enGB", rp = nil,  pvp = true },
		["GrimBatol"] 			= { id = 267, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Hakkar"] 				= { id =   9, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Haomarush"] 			= { id = 177, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Jaedenar"] 			= { id = 217, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Karazhan"] 			= { id = 284, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Kazzak"] 				= { id = 268, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Kor'gall"] 			= { id = 262, group = "", locale = "enGB", rp = nil,  pvp = true },
		["LaughingSkull"] 		= { id =  68, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Lightning'sBlade"] 	= { id =  69, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Magtheridon"] 		= { id = 123, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Mazrigos"] 			= { id = 280, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Neptulon"] 			= { id = 275, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Outland"] 			= { id = 269, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Ragnaros"] 			= { id =  73, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Ravencrest"] 			= { id = 202, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Shadowmoon"] 			= { id =  74, group = "", locale = "enGB", rp = nil,  pvp = true },
		["ShatteredHalls"] 		= { id = 108, group = "", locale = "enGB", rp = nil,  pvp = true },
		["ShatteredHand"] 		= { id = 126, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Skullcrusher"] 		= { id = 127, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Spinebreaker"] 		= { id = 203, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Stonemaul"] 			= { id = 238, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Stormreaver"] 		= { id = 204, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Stormscale"] 			= { id = 239, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Sunstrider"] 			= { id = 254, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Sylvanas"] 			= { id = 276, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Talnivarr"] 			= { id = 282, group = "", locale = "enGB", rp = nil,  pvp = true },
		["TarrenMill"] 			= { id = 270, group = "", locale = "enGB", rp = nil,  pvp = true },
		["TheMaelstrom"] 		= { id = 277, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Trollbane"] 			= { id = 129, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Twilight'sHammer"] 	= { id = 255, group = "", locale = "enGB", rp = nil,  pvp = true },
		["TwistingNether"] 		= { id = 147, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Vashj"] 				= { id =  56, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Warsong"] 			= { id = 130, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Xavius"] 				= { id = 265, group = "", locale = "enGB", rp = nil,  pvp = true },
		["Zenedar"] 			= { id = 256, group = "", locale = "enGB", rp = nil,  pvp = true },

		["ArgentDawn"] 			= { id = 114, group = "", locale = "enGB", rp = true, pvp = nil },
		["DarkmoonFaire"] 		= { id = 261, group = "", locale = "enGB", rp = true, pvp = nil },
		["EarthenRing"] 		= { id =  62, group = "", locale = "enGB", rp = true, pvp = nil },
		["Moonglade"] 			= { id = 281, group = "", locale = "enGB", rp = true, pvp = nil },
		["SteamwheedleCartel"] 	= { id = 182, group = "", locale = "enGB", rp = true, pvp = nil },
		["TheSha'tar"] 			= { id = 286, group = "", locale = "enGB", rp = true, pvp = nil },

		["DefiasBrotherhood"] 	= { id = 273, group = "", locale = "enGB", rp = true, pvp = true },
		["Ravenholdt"] 			= { id =  51, group = "", locale = "enGB", rp = true, pvp = true },
		["ScarshieldLegion"] 	= { id = 264, group = "", locale = "enGB", rp = true, pvp = true },
		["Sporeggar"] 			= { id = 285, group = "", locale = "enGB", rp = true, pvp = true },
		["TheVentureCo"] 		= { id = 223, group = "", locale = "enGB", rp = true, pvp = true },

		-- EU french
		["Chantséternels"] 		= { id = 301, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["Dalaran"] 			= { id = 172, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["Drek'Thar"] 			= { id = 296, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["Eitrigg"] 			= { id =   6, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["Elune"] 				= { id = 289, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["Hyjal"] 				= { id =  46, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["KhazModan"] 			= { id =  11, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["Krasus"] 				= { id = 308, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["MarécagedeZangar"] 	= { id = 303, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["Medivh"] 				= { id = 125, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["Suramar"] 			= { id = 240, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["Uldaman"] 			= { id = 224, group = "", locale = "frFR", rp = nil,  pvp = nil },
		["Vol'jin"] 			= { id = 294, group = "", locale = "frFR", rp = nil,  pvp = nil },

		["Arak-arahm"] 			= { id = 291, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Arathi"] 				= { id = 306, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Archimonde"] 			= { id = 170, group = "", locale = "frFR", rp = nil,  pvp = true },
		["BlackDragonflight"] 	= { id = 171, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Cho'gall"] 			= { id = 192, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Eldre'Thalas"] 		= { id =  24, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Garona"] 				= { id = 195, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Illidan"] 			= { id = 199, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Kael'thas"] 			= { id = 200, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Naxxramas"] 			= { id = 304, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Ner'zhul"] 			= { id =  89, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Rashgarroth"] 		= { id = 298, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Sargeras"] 			= { id = 145, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Sinstralis"] 			= { id = 290, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Templenoir"] 			= { id = 305, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Throk'Feroth"] 		= { id = 299, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Varimathras"] 		= { id = 300, group = "", locale = "frFR", rp = nil,  pvp = true },
		["Ysondre"] 			= { id = 186, group = "", locale = "frFR", rp = nil,  pvp = true },

		["ConfrérieduThorium"] 	= { id = 292, group = "", locale = "frFR", rp = true, pvp = nil },
		["KirinTor"] 			= { id = 201, group = "", locale = "frFR", rp = true, pvp = nil },
		["LesClairvoyants"] 	= { id = 302, group = "", locale = "frFR", rp = true, pvp = nil },
		["LesSentinelles"] 		= { id = 297, group = "", locale = "frFR", rp = true, pvp = nil },

		["ConseildesOmbres"] 	= { id = 295, group = "", locale = "frFR", rp = true, pvp = true },
		["CultedelaRiveNoire"] 	= { id = 307, group = "", locale = "frFR", rp = true, pvp = true },
		["LaCroisadeécarlate"] 	= { id =  29, group = "", locale = "frFR", rp = true, pvp = true }, -- is also 293?

		-- EU german
		["Aegwynn"] 			= { id =   1, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Anetheron"] 			= { id = 169, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Anub'arak"] 			= { id =  38, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Arthas"] 				= { id = 115, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Azshara"] 			= { id = 133, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Blackmoore"] 			= { id = 327, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Blackrock"] 			= { id =  79, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Blutkessel"] 			= { id = 332, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Dalvengyr"] 			= { id = 173, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Destromath"] 			= { id = 193, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Dethecus"] 			= { id = 194, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Echsenkessel"] 		= { id = 335, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Eredar"] 				= { id =  64, group = "", locale = "deDe", rp = nil,  pvp = true },
		["FestungderStürme"] 	= { id = 336, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Kil'jaeden"] 			= { id =  86, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Kel'Thuzad"] 			= { id = 218, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Gul'dan"] 			= { id = 197, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Gorgonnash"] 			= { id = 196, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Frostwolf"] 			= { id =  84, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Frostmourne"] 		= { id =  83, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Krag'jin"] 			= { id = 321, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Nazjatar"] 			= { id = 144, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Nathrezim"] 			= { id =  28, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Mug'thol"] 			= { id =  15, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Mannoroth"] 			= { id = 124, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Mal'Ganis"] 			= { id = 179, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Nefarian"] 			= { id = 331, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Nera'thor"] 			= { id = 323, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Onyxia"] 				= { id = 220, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Rajaxx"] 				= { id = 343, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Taerar"] 				= { id = 344, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Terrordar"] 			= { id = 324, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Theradras"] 			= { id = 325, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Ulduar"] 				= { id = 346, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Tichondrius"] 		= { id =  94, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Un'Goro"] 			= { id = 317, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Vek'lor"] 			= { id = 347, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Wrathbringer"]		= { id = 326, group = "", locale = "deDe", rp = nil,  pvp = true },
		["Zuluhed"] 			= { id = 187, group = "", locale = "deDe", rp = nil,  pvp = true },

		["Alexstrasza"] 		= { id = 188, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Alleria"] 			= { id = 189, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Aman'Thul"] 			= { id =  77, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Ambossar"] 			= { id = 339, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Antonidas"] 			= { id = 150, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Area52"] 				= { id =  96, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Arygos"] 				= { id = 210, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Baelgun"] 			= { id = 134, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Blackhand"] 			= { id = 191, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["DunMorogh"] 			= { id = 320, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Durotan"] 			= { id = 119, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Garrosh"]             = { id = 156, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Gilneas"] 			= { id =  65, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Kargath"] 			= { id =  67, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Lordaeron"] 			= { id = 342, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Lothar"] 				= { id = 121, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Madmortem"] 			= { id = 310, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Malfurion"] 			= { id = 142, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Malygos"] 			= { id =  71, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Nethersturm"] 		= { id = 337, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Norgannon"] 			= { id = 180, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Nozdormu"] 			= { id = 311, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Perenolde"] 			= { id = 237, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Proudmoore"] 			= { id =  90, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Rexxar"] 				= { id =  17, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Sen'jin"] 			= { id =  91, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Shattrath"] 			= { id = 338, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Teldrassil"] 			= { id = 315, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Thrall"] 				= { id = 183, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Tirion"] 				= { id = 345, group = "", locale = "deDE", rp = nil,  pvp = nil },
		["Ysera"] 				= { id = 185, group = "", locale = "deDE", rp = nil,  pvp = nil },

		["DasKonsortium"] 		= { id = 333, group = "", locale = "deDE", rp = true, pvp = true },
		["DasSyndikat"] 		= { id = 318, group = "", locale = "deDE", rp = true, pvp = true },
		["DerabyssischeRat"] 	= { id = 340, group = "", locale = "deDE", rp = true, pvp = true },
		["DieArguswacht"] 		= { id = 328, group = "", locale = "deDE", rp = true, pvp = true },
		["DieTodeskrallen"] 	= { id = 330, group = "", locale = "deDE", rp = true, pvp = true },
		["KultderVerdammten"] 	= { id = 322, group = "", locale = "deDE", rp = true, pvp = true },

		["DerMithrilorden"] 	= { id = 313, group = "", locale = "deDE", rp = true, pvp = nil },
		["DerRatvonDalaran"] 	= { id = 319, group = "", locale = "deDE", rp = true, pvp = nil },
		["DieAldor"] 			= { id = 334, group = "", locale = "deDE", rp = true, pvp = nil },
		["DieewigeWacht"] 		= { id = 329, group = "", locale = "deDE", rp = true, pvp = nil },
		["DieNachtwache"] 		= { id = 341, group = "", locale = "deDE", rp = true, pvp = nil },
		["DieSilberneHand"] 	= { id = 309, group = "", locale = "deDE", rp = true, pvp = nil },
		["Forscherliga"] 		= { id = 314, group = "", locale = "deDE", rp = true, pvp = nil },
		["Todeswache"] 			= { id = 316, group = "", locale = "deDE", rp = true, pvp = nil },
		["ZirkeldesCenarius"] 	= { id = 312, group = "", locale = "deDE", rp = true, pvp = nil },

		-- EU spanish
		["C'Thun"] 				= { id = 349, group = "", locale = "esES", rp = nil,  pvp = true },
		["DunModr"] 			= { id = 350, group = "", locale = "esES", rp = nil,  pvp = true },
		["Sanguino"] 			= { id = 353, group = "", locale = "esES", rp = nil,  pvp = true },
		["Uldum"] 				= { id = 241, group = "", locale = "esES", rp = nil,  pvp = true },
		["Zul'jin"] 			= { id = 131, group = "", locale = "esES", rp = nil,  pvp = true },

		["ColinasPardas"] 		= { id = 348, group = "", locale = "esES", rp = nil,  pvp = nil },
		["Exodar"] 				= { id = 103, group = "", locale = "esES", rp = nil,  pvp = nil },
		["Minahonda"] 			= { id = 352, group = "", locale = "esES", rp = nil,  pvp = nil },
		["Tyrande"] 			= { id = 355, group = "", locale = "esES", rp = nil,  pvp = nil },

		["Shen'dralar"] 		= { id = 354, group = "", locale = "esES", rp = true, pvp = true },

		["LosErrantes"] 		= { id = 351, group = "", locale = "esES", rp = true, pvp = nil },

		-- EU portugese
		["Aggra"] 				= { id = 287, group = "Blackout", locale = "ptBR", rp = nil,  pvp = true },

		-- EU italian
		["Nemesis"] 			= { id = 248, group = "", locale = "itIT", rp = nil, pvp = true },
		["Pozzodell'Eternità"]	= { id = 288, group = "", locale = "itIT", rp = nil, pvp = nil },

		-- EU russian
		["Азурегос"] 			= { id = 357, group = "", locale = "ruRU", rp = nil, pvp = nil,   plain = "Azuregos" },
		["Борейскаятундра"] 	= { id = 368, group = "", locale = "ruRU", rp = nil, pvp = nil,   plain = "BoreanTundra" },
		["ВечнаяПесня"] 		= { id = 358, group = "", locale = "ruRU", rp = nil, pvp = nil,   plain = "Eversong" },
		["Галакронд"] 			= { id = 369, group = "", locale = "ruRU", rp = nil, pvp = nil,   plain = "Galakrond" },
		["Голдринн"] 			= { id = 359, group = "", locale = "ruRU", rp = nil, pvp = nil,   plain = "Goldrinn" },
		["Дракономор"] 			= { id = 370, group = "", locale = "ruRU", rp = nil, pvp = nil,   plain = "Fordragon" },

		["Гордунни"] 			= { id = 360, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Gordunni" },
		["Гром"] 				= { id = 361, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Grom" },
		["Король-лич"] 			= { id = 362, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "LichKing" },
		["Пиратскаябухта"] 		= { id = 363, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "BootyBay" },
		["Подземье"] 			= { id = 371, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Deephome" },
		["Разувий"] 			= { id = 372, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Razuvious" },
		["Ревущийфьорд"] 		= { id = 373, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "HowlingFjord" },
		["СвежевательДуш"] 		= { id = 364, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Soulflayer" },
		["Седогрив"] 			= { id = 374, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Greymane" },
		["СтражСмерти"] 		= { id = 365, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Deathguard" },
		["Термоштепсель"] 		= { id = 366, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Thermaplugg" },
		["ТкачСмерти"] 			= { id = 375, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Deathweaver" },
		["ЧерныйШрам"] 			= { id = 356, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Blackscar" },
		["Ясеневыйлес"] 		= { id = 367, group = "", locale = "ruRU", rp = nil, pvp = true,  plain = "Ashenvale" },
	}
elseif region == 'kr' then
	realmInfo = {
		["렉사르"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = nil, plain = "Rexxar" },
		["불타는군단"] 			= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = nil, plain = "BurningLegion" },
		["스톰레이지"] 			= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = nil, plain = "Stormrage" },
		["와일드해머"] 			= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = nil, plain = "Wildhammer" },
		["윈드런너"] 				= { id =  37, group = "", locale = "koKR", rp = nil,  pvp = nil, plain = "Windrunner" },

		["가로나"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Garona" },
		["굴단"] 					= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Gul’dan" },
		["노르가논"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Norgannon" },
		["달라란"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Dalaran" },
		["데스윙"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Deathwing" },
		["듀로탄"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Durotan" },
		["라그나로스"] 			= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Ragnaros" },
		["레인"] 					= { id =  70, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Llane" },
		["말리고스"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Malygos" },
		["말퓨리온"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Malfurion" },
		["메디브"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Medivh" },
		["블랙무어"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Blackmoore" },
		["살타리온"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Sartharion" },
		["세나리우스"] 			= { id =  42, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Cenarius" },
		["아즈샤라"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Azshara" },
		["알레리아"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Alleria" },
		["알렉스트라자"] 			= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Alexstrasza" },
		["에이그윈"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Aegwynn" },
		["엘룬"] 					= { id = 120, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Elune" },
		["우서"] 					= { id =  55, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Uther" },
		["이오나"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Eonar" },
		["줄진"] 					= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Zul'jin" },
		["카라잔"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Karazhan" },
		["카르가스"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Kargath" },
		["쿨티라스"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "KulTiras" },
		["티리온"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Tirion" },
		["하이잘"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Hyjal" },
		["헬스크림"] 				= { id = nil, group = "", locale = "koKR", rp = nil,  pvp = true, plain = "Hellscream" },
	}
elseif region == 'tw' then
	realmInfo = {
		["世界之樹"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = nil, plain = "Worldtree" },
		["亞雷戈斯"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = nil, plain = "Arygos" },
		["天空之牆"] 				= { id =  33, group = "", locale = "zhTW", rp = nil,  pvp = nil, plain = "Skywall" },
		["奧妮克希亞"] 			= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = nil, plain = "Onyxia" },
		["巴納札爾"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = nil, plain = "Balnazzar" },
		["暗影之月"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = nil, plain = "Shadowmoon" },
		["暴風祭壇"] 				= { id = 207, group = "", locale = "zhTW", rp = nil,  pvp = nil, plain = "AltarofStorms" },
		["眾星之子"] 				= { id = 163, group = "", locale = "zhTW", rp = nil,  pvp = nil, plain = "Quel'dorei" },
		["聖光之願"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = nil, plain = "Light'sHope" },
		["語風"] 				= { id = 205, group = "", locale = "zhTW", rp = nil,  pvp = nil, plain = "Whisperwind" },

		["克爾蘇加德"] 			= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Kel'Thuzad" },
		["冰霜之刺"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Frostmane" },
		["冰風崗哨"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "ChillwindPoint" },
		["凜風峽灣"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "HowlingFjord" },
		["地獄吼"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Hellscream" },
		["夜空之歌"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Nightsong" },
		["奈辛瓦里"] 				= { id = 161, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Nesingwary" },
		["寒冰皇冠"] 				= { id = 216, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Icecrown" },
		["尖石"] 				= { id =  35, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Spirestone" },
		["屠魔山谷"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "DemonFallCanyon" },
		["巨龍之喉"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Dragonmaw" },
		["惡魔之魂"] 				= { id = 213, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "DemonSoul" },
		["憤怒使者"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Wrathbringer" },
		["戰歌"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Warsong" },
		["撒爾薩里安"] 			= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Sartharion" },
		["日落沼澤"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "SundownMarsh" },
		["死亡之翼"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Deathwing" },
		["水晶之刺"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "CrystalpineStinger" },
		["狂心"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Frenzyheart" },
		["狂熱之刃"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "ZealotBlade" },
		["米奈希爾"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Menethil" },
		["血之谷"] 				= { id = 117, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "BleedingHollow" },
		["諾姆瑞根"] 				= { id = 215, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Gnomeregan" },
		["遠祖灘頭"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "StrandoftheAncients" },
		["銀翼要塞"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "SilverwingHold" },
		["阿薩斯"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Arthas" },
		["雷鱗"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "Stormscale" },
		["鬼霧峰"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "DreadmistPeak" },
		["黑龍軍團"] 				= { id = nil, group = "", locale = "zhTW", rp = nil,  pvp = true, plain = "BlackDragonflight" },
	}
elseif region == 'ch' then
	realmInfo = {
		-- region 1
		["奥蕾莉亚"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Alleria" },
		-- ["艾格文"] 			= { plain = "Aegwynn (Merged into 奥蕾莉亚 (Alleria)" },
		["回音山"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "EchoRidge" },
		-- ["莱恩"] 				= { plain = "Llane (Merged into 回音山 (Echo Ridge)" },
		["玛多兰"] 				= { id = 122, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Madoran" },
		-- ["英雄之谷"] 			= { plain = "ValleyofHeroes (Merged into 玛多兰 (Madoran)" },
		["莫德古得"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Modgud" },
		-- ["绿龙军团"] 			= { plain = "Green Dragonflight (Merged into 莫德古得 (Modgud)" },
		["普瑞斯托"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Prestor" },
		-- ["诺甘农"] 			= { plain = "Norgannon (Merged into 普瑞斯托 (Prestor)" },
		["白银之手"] 				= { id =  92, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Silverhand" },
		-- ["肯瑞托"] 			= { plain = "Kirin Tor (Merged into 白银之手 (Silverhand)" },
		["图拉扬"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Turalyon" },
		-- ["阿曼苏尔"] 			= { plain = "Aman'Thul (Merged into 图拉扬 (Turalyon)" },
		["伊瑟拉"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Ysera" },
		-- ["光明使者"] 			= { plain = "Lightbringer (Merged into 伊瑟拉 (Ysera)" },

		["阿格拉玛"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Aggramar" },
		["暴风祭坛"] 				= { id = 207, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "AltarofStorms" },
		["安威玛尔"] 				= { id = 209, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Anvilmar" },
		["艾苏恩"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Aszune" },
		["黑龙军团"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "BlackDragonflight" },
		["黑石尖塔"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "BlackrockSpire" },
		["蓝龙军团"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "BlueDragonflight" },
		["藏宝海湾"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "BootyBay" },
		["铜龙军团"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "BronzeDragonflight" },
		["燃烧平原"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "BurningSteppes" },
		["冰风岗"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "ChillwindPoint" },
		["达纳斯"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Danath" },
		["死亡之翼"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Deathwing" },
		["迪托马斯"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Destromath" },
		["尘风峡谷"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "DustwindGulch" },
		["烈焰峰"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "FlameCrest" },
		["诺莫瑞根"] 				= { id = 215, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Gnomeregan" },
		["卡扎克"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Kazzak" },
		["卡德罗斯"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Khardros" },
		["基尔罗格"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Kilrogg" },
		["库德兰"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Kurdran" },
		["洛萨"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Lothar" },
		["玛瑟里顿"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Magtheridon" },
		["山丘之王"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "MountainKing" },
		["耐萨里奥"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Neltharion" },
		["红龙军团"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "RedDragonflight" },
		["罗宁"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Rhonin" },
		["萨格拉斯"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Sargeras" },
		["索瑞森"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Thaurissan" },
		["索拉丁"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Thoradin" },
		["雷霆之王"] 				= { id =  74, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Thunderlord" },
		["奥达曼"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Uldaman" },
		["国王之谷"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "ValleyofKings" },

		-- region 2
		["艾森娜"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Aessina" },
		["塞纳里奥"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Cenarion" },
		["塞纳留斯"] 				= { id =  42, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Cenarius" },
		["众星之子"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "ChildrenoftheStars" },
		["梦境之树"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "DreamBough" },
		["艾露恩"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Elune" },
		["月光林地"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Moonglade" },
		["夜空之歌"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Nightsong" },
		["诺达希尔"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Nordrassil" },
		["神谕林地"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "OracleGlade" },
		["月神殿"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "TempleoftheMoon" },
		["泰兰德"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Tyrande" },
		["迷雾之海"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "VeiledSea" },
		["轻风之语"] 				= { id = 205, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Whisperwind" },
		["冬泉谷"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Winterspring" },

		["阿迦玛甘"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Agamaggan" },
		["奥拉基尔"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Al'Akir" },
		["阿克蒙德"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Archimonde" },
		["爱斯特纳"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Astrannar" },
		["埃加洛尔"] 				= { id = 116, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Azgalor" },
		["艾萨拉"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Azshara" },
		["埃苏雷格"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Azuregos" },
		["达斯雷玛"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Dath'Remar" },
		["屠魔山谷"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "DemonFallCanyon" },
		["毁灭之锤"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Doomhammer" },
		["火焰之树"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Firetree" },
		["冰霜之刃"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Frostsaber" },
		["地狱咆哮"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Hellscream" },
		["海加尔"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Hyjal" },
		["伊利丹"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Illidan" },
		["卡德加"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Khadgar" },
		["闪电之刃"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Lightning'sBlade" },
		["麦维影歌"] 				= { id =  49, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "MaievShadowsong" },
		["梅尔加尼"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Mal'Ganis" },
		["玛法里奥"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Malfurion" },
		["主宰之剑"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Master'sGlaive" },
		["耐普图隆"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Neptulon" },
		["拉文凯斯"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Ravencrest" },
		["暗影之月"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Shadowmoon" },
		["石爪峰"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "StonetalonPeak" },
		["风暴之怒"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Stormrage" },
		["战歌"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Warsong" },
		["风行者"] 				= { id =  37, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Windrunner" },
		["夏维安"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Xavian" },

		-- region 3
		["吉安娜"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Jaina" },
		["米莎"] 				= { id =  50, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Misha" },
		["灵魂石地"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "SpiritRock" },

		["布莱克摩"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Blackmoore" },
		["黑暗之矛"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Darkspear" },
		["鬼雾峰"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "DreadmistPeak" },
		["杜隆坦"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Durotan" },
		["回音群岛"] 				= { id =  44, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "EchoIsles" },
		["埃德萨拉"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Eldre'Thalas" },
		["迦罗娜"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Garona" },
		["玛里苟斯"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Malygos" },
		["红云台地"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "RedCloudMesa" },
		["雷克萨"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Rexxar" },
		["符文图腾"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Runetotem" },
		["奥丹姆"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Uldum" },

		-- region 4
		["布瑞尔"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Brill" },
		["达拉然"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Dalaran" },
		["遗忘海岸"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "ForgottenCoast" },
		["霜之哀伤"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Frostmourne" },
		["圣光之愿"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Light'sHope" },
		["麦迪文"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Medivh" },
		["纳斯雷兹姆"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Nathrezim" },
		["银月"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Silvermoon" },
		["银松森林"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "SilverpineForest" },
		["泰瑞纳斯"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Terenas" },
		["乌瑟尔"] 				= { id =  55, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Uther" },
		["耳语海岸"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "WhisperingShore" },

		["鹰巢山"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "AeriePeak" },
		["奥特兰克"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Alterac" },
		["安东尼达斯"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Antonidas" },
		["阿拉索"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Arathor" },
		["阿尔萨斯"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Arthas" },
		["达隆米尔"] 				= { id =  43, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Darrowmere" },
		["艾欧纳尔"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Eonar" },
		["霜狼"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Frostwolf" },
		["玛诺洛斯"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Mannoroth" },
		["耐奥祖"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Ner'zhul" },
		["匹瑞诺德"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Perenolde" },
		["拉格纳罗斯"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Ragnaros" },
		["莱斯霜语"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "RasFrostwhisper" },
		["瑞文戴尔"] 				= { id = 164, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Rivendare" },
		["血色十字军"] 			= { id =  29, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "ScarletCrusade" },
		["通灵学院"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Scholomance" },
		["激流堡"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Stromgarde" },
		["塔伦米尔"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "TarrenMill" },

		-- region 5
		["金色平原"] 				= { id = nil, group = "", locale = "zhCN", rp = true, pvp = true, plain = "GoldenPlains" },

		-- region 6
		["海达希亚"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Hydraxian" },
		["瓦里玛萨斯"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = nil, plain = "Varimathras" },

		["安其拉"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Ahn'Qiraj" },
		["阿纳克洛斯"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Anachronos" },
		["安纳塞隆"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Anetheron" },
		["阿努巴拉克"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Anub'arak" },
		["阿拉希"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Arathi" },
		["巴纳扎尔"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Balnazzar" },
		["黑手军团"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "BlackhandLegion" },
		["黑翼之巢"] 				= { id = 211, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "BlackwingLair" },
		["血羽"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Bloodfeather" },
		["燃烧军团"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "BurningLegion" },
		["克洛玛古斯"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Chromaggus" },
		["破碎岭"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Crushridge" },
		["克苏恩"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "C'Thun" },
		["德拉诺"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Draenor" },
		["龙骨平原"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "DragonbonePlain?" },
		["范达尔鹿盔"] 			= { id = 146, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "FandralStaghelm" },
		["无尽之海"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "GreatSea" },
		["格瑞姆巴托"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "GrimBatol" },
		["古拉巴什"] 				= { id =  27, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Gurubashi" },
		["哈卡"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Hakkar" },
		["海克泰尔"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Sea?" },
		["卡拉赞"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Karazhan" },
		["库尔提拉斯"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "KulTiras" },
		["莱索恩"] 				= { id = 219, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Lethon" },
		["洛丹伦"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Lordaeron" },
		["熔火之心"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "MoltenCore" },
		["纳克萨玛斯"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Naxxramas" },
		["奈法利安"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Nefarian" },
		["奎尔萨拉斯"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Quel'Thalas" },
		["拉贾克斯"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Rajaxx" },
		["拉文霍德"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Ravenholdt" },
		["萨菲隆"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Sapphiron" },
		["森金"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Sen'jin" },
		["泰拉尔"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Taerar" },
		["桑德兰"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Thunderaan" },
		["雷霆之怒"] 				= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Thunderfury" },
		["瓦拉斯塔兹"] 			= { id = nil, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "Vaelastrasz" },
		["永恒之井"] 				= { id = 288, group = "", locale = "zhCN", rp = nil,  pvp = true, plain = "WellofEternity" },
	}
end

--[[-- not listed on realm status page?
	"LostIsles(US)"] 		= { id = 242 },
	"Gilneas(US)"] 		= { id = 243 },
	"Hamuul(KR)"] 			= { id = 244 },
	"Mekkatorque"] 		= { id = 245 },
	"Anasterian"]	 		= { id = 251 },

	-- missing
	"Akama",--[2]
	"AlteracMountains",--[208]
	"Andorhal",--[168]
	"BlackwaterRaiders",--[39]
	"BloodFurnace",--[100]
	"Bonechewer",--[22]
	"Cairne",--[152]
	"CenarionCircle",--[41]
	"Coilfang",--[101]
	"DarkIron",--[135]
	"Dawnbringer",--[102]
	"Detheroc",--[136]
	"Drak'Tharon",--[153]
	"Draka",--[5]
	"Drenden",--[154]
	"Duskwood",--[175]
	"Farstriders",--[155]
	"Feathermoon",--[236]
	"Fenris",--[45]
	"Fizzcrank",--[104]
	"Galakrond",--[105]
	"Garithos",--[7]
	"Gorefiend",--[66]
	"Greymane",--[138]
	"Hydraxis",--[157]
	"Kalecgos",--[139]
	"Korgath",--[12]
	"Korialstrasz",--[47]
	"Lightninghoof",--[140]
	"Maelstrom",--[141]
	"Malorne",--[14]
	"Mok'Nathal",--[158]
	"MoonGuard",--[159]
	"Moonrunner",--[143]
	"Muradin",--[16]
	"Nazgrel",--[160]
	"Scilla",--[181]
	"Sentinels",--[221]
	"Shandris",--[165]
	"Shu'halo",--[52]
	"SistersofElune",--[53]
	"Smolderthorn",--[34]
	"Tanaris",--[222]
	"TheForgottenCoast",--[54]
	"TheScryers",--[110]
	"TheUnderbog",--[111]
	"ThoriumBrotherhood",--[20]
	"Tortheldrin",--[166]
	"Undermine",--[225]
	"Ursin",--[148]
	"Velen",--[112]
	"Winterhoof",--[57]
	"WyrmrestAccord",--[167]
	"Zangarmarsh",--[113]
--]]
