local addonName, ns, _ = ...
ns.OQversion = '1A'
ns.OQmaxPosts = 5
ns.const = {}

local levelRange = { "unavailable", "10 - 14", "15 - 19", "20 - 24", "25 - 29", "30 - 34", "35 - 39", "40 - 44", "45 - 49", "50 - 54", "55 - 59", "60 - 64", "65 - 69", "70 - 74", "75 - 79", "80 - 84", "85", "85 - 89", "90" }
ns.const.level = levelRange

local premadeType = {
	["TYPE_NONE"]      = 'X',
	["TYPE_MISC"]      = 'M',
	["TYPE_BG"]        = 'B',
	["TYPE_RBG"]       = 'A',
	["TYPE_ARENA"]     = 'a',
	["TYPE_LADDER"]    = 'L',
	["TYPE_QUESTS"]    = 'Q',
	["TYPE_SCENARIO"]  = 'S',
	["TYPE_CHALLENGE"] = 'C',
	["TYPE_DUNGEON"]   = 'D',
	["TYPE_RAID"]      = 'R',
}
ns.const.type = premadeType

local premadeTypeLabels = {
	[premadeType.TYPE_NONE]      = UNKNOWN,
	[premadeType.TYPE_MISC]      = MISCELLANEOUS,
	[premadeType.TYPE_BG]        = BATTLEFIELDS,
	[premadeType.TYPE_RBG]       = PVP_RATED_BATTLEGROUNDS,
	[premadeType.TYPE_ARENA]     = ARENA,
	[premadeType.TYPE_LADDER]    = RANKING,
	[premadeType.TYPE_QUESTS]    = LFG_TYPE_QUEST,
	[premadeType.TYPE_SCENARIO]  = GUILD_CHALLENGE_TYPE4,
	[premadeType.TYPE_CHALLENGE] = CHALLENGES,
	[premadeType.TYPE_DUNGEON]   = LFG_TYPE_DUNGEON, -- GUILD_CHALLENGE_TYPE1
	[premadeType.TYPE_RAID]      = LFG_TYPE_RAID,    -- GUILD_CHALLENGE_TYPE2
}
ns.const.typeLabels = premadeTypeLabels

local premadeTypeDropdownLabels = {
	{ premadeType.TYPE_NONE, UNKNOWN },
	{ premadeType.TYPE_MISC, MISCELLANEOUS },
	{ '', PLAYER_V_PLAYER},
	{ premadeType.TYPE_BG, BATTLEFIELDS },
	{ premadeType.TYPE_RBG, PVP_RATED_BATTLEGROUNDS },
	{ premadeType.TYPE_ARENA, ARENA },
	{ premadeType.TYPE_LADDER, RANKING },
	{ '', INSTANCE },
	{ premadeType.TYPE_QUESTS, LFG_TYPE_QUEST },
	{ premadeType.TYPE_SCENARIO, GUILD_CHALLENGE_TYPE4 },
	{ premadeType.TYPE_CHALLENGE, CHALLENGES },
	{ premadeType.TYPE_DUNGEON, LFG_TYPE_DUNGEON }, -- GUILD_CHALLENGE_TYPE1
	{ premadeType.TYPE_RAID, LFG_TYPE_RAID },    -- GUILD_CHALLENGE_TYPE2
}
ns.const.typeDropdownLabels = premadeTypeDropdownLabels

local battlegroundID = {
	["RND"]  =  0,
	["NONE"] = 15,
	["TP"]   =  1,
	["BFG"]  =  2,
	["WSG"]  =  3,
	["AB"]   =  4,
	["EOTS"] =  5,
	["AV"]   =  6,
	["SOTA"] =  7,
	["IOC"]  =  8,
	["SSM"]  =  9,
	["TOK"]  = 10,
	["DWG"]  = 11,
	["DKP"]  = 16,
}
ns.const.bg = battlegroundID

local RANGED, MELEE, CASTER, TANK = 1, 2, 3, 4
local specInfo = { -- this data is horribly incorrect and rather useless, but we need to retain oQ compatibility
	[  0] = { id =  0, stats = MELEE  }, -- unspecced
	[250] = { id =  1, stats = TANK   }, -- deathknight
	[251] = { id =  2, stats = MELEE  },
	[252] = { id =  3, stats = MELEE  },
	[102] = { id =  4, stats = RANGED }, -- druid
	[103] = { id =  5, stats = RANGED },
	[104] = { id =  6, stats = TANK   },
	[105] = { id =  7, stats = CASTER },
	[253] = { id =  8, stats = RANGED }, -- hunter
	[254] = { id =  9, stats = RANGED },
	[255] = { id = 10, stats = RANGED },
 	[ 62] = { id = 11, stats = CASTER }, -- mage
 	[ 63] = { id = 12, stats = CASTER },
 	[ 64] = { id = 13, stats = CASTER },
	[268] = { id = 14, stats = MELEE  }, -- monk
	[269] = { id = 15, stats = MELEE  },
	[270] = { id = 16, stats = MELEE  },
 	[ 65] = { id = 17, stats = RANGED }, -- paladin
 	[ 66] = { id = 18, stats = TANK   },
 	[ 70] = { id = 19, stats = MELEE  },
	[256] = { id = 20, stats = CASTER }, -- priest
	[257] = { id = 21, stats = CASTER },
	[258] = { id = 22, stats = CASTER },
	[259] = { id = 23, stats = MELEE  }, -- rogue
	[260] = { id = 24, stats = MELEE  },
	[261] = { id = 25, stats = MELEE  },
	[262] = { id = 26, stats = RANGED }, -- shaman
	[263] = { id = 27, stats = MELEE  },
	[264] = { id = 28, stats = CASTER },
	[265] = { id = 29, stats = CASTER }, -- warlock
	[266] = { id = 30, stats = CASTER },
	[267] = { id = 31, stats = CASTER },
 	[ 71] = { id = 32, stats = MELEE  }, -- warrior
 	[ 72] = { id = 33, stats = MELEE  },
 	[ 73] = { id = 34, stats = TANK   },
}
ns.const.specInfo = specInfo

local playerRaces = {
	"Dwarf", "Draenei", "Gnome", "Human", "NightElf", "Worgen",
	"BloodElf", "Goblin", "Orc", "Tauren", "Troll", "Scourge",
	"Pandaren",
}
ns.const.playerRaces = playerRaces

-- maps _,_,classID = UnitClass(unit) to OQ tiny class
local playerTinyClasses = {
	'K', 'F', 'C', 'H', 'G', 'A', 'I', 'D', 'J', 'E', 'B'
}
-- TODO: missing: NONE / XX / L, UNKNOWN / ZZ / N,  / YY / M
ns.const.playerClasses = playerTinyClasses

--[[ local queueStatus = {
	[0] = "-", 	 -- 0: none
	"queued",    -- 1: queued
	"CONFIRM",   -- 2: confirm
	"inside",    -- 3: active
	"error",     -- 4: error
}
ns.const.status = queueStatus --]]

ns.const.status = {
	NONE     = 1,
	PENDING  = 2, -- sent message to leader
	QUEUED   = 3, -- got leader's reply: on wait list
	GROUPED  = 4, -- got invited
}
