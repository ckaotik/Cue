local addonName, ns, _ = ...
ns.const = {}

local levelRange = { "unavailable", "10 - 14", "15 - 19", "20 - 24", "25 - 29", "30 - 34", "35 - 39", "40 - 44", "45 - 49", "50 - 54", "55 - 59", "60 - 64", "65 - 69", "70 - 74", "75 - 79", "80 - 84", "85", "85 - 89", "90" }
ns.const.level = levelRange

local premadeType = {
	["TYPE_NONE"]      = 'X',
	["TYPE_BG"]        = 'B',
	["TYPE_RBG"]       = 'A',
	["TYPE_ARENA"]     = 'a',
	["TYPE_LADDER"]    = 'L',
	["TYPE_QUESTS"]    = 'Q',
	["TYPE_SCENARIO"]  = 'S',
	["TYPE_CHALLENGE"] = 'C',
	["TYPE_DUNGEON"]   = 'D',
	["TYPE_RAID"]      = 'R',
	["TYPE_MISC"]      = 'M',
}
ns.const.type = premadeType

local premadeTypeLabels = {
	{ 'TYPE_NONE', UNKNOWN },
	{ 'TYPE_MISC', MISCELLANEOUS },
	{ '', PLAYER_V_PLAYER},
	{ 'TYPE_BG', BATTLEFIELDS },
	{ 'TYPE_RBG', PVP_RATED_BATTLEGROUNDS },
	{ 'TYPE_ARENA', ARENA },
	{ 'TYPE_LADDER', RANKING },
	{ '', INSTANCE },
	{ 'TYPE_QUESTS', LFG_TYPE_QUEST },
	{ 'TYPE_SCENARIO', GUILD_CHALLENGE_TYPE4 },
	{ 'TYPE_CHALLENGE', CHALLENGES },
	{ 'TYPE_DUNGEON', LFG_TYPE_DUNGEON }, -- GUILD_CHALLENGE_TYPE1
	{ 'TYPE_RAID', LFG_TYPE_RAID },    -- GUILD_CHALLENGE_TYPE2
}
ns.const.typeLabels = premadeTypeLabels

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
