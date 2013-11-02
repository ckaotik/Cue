local addonName, ns, _ = ...
ns.const = {}

local levelRange = { "unavailable", "10 - 14", "15 - 19", "20 - 24", "25 - 29", "30 - 34", "35 - 39", "40 - 44", "45 - 49", "50 - 54", "55 - 59", "60 - 64", "65 - 69", "70 - 74", "75 - 79", "80 - 84", "85", "85 - 89", "90" }
ns.const.level = levelRange

local premadeType = {
	["TYPE_NONE"]      = 'X',
	["TYPE_BG"]        = 'B',
	["TYPE_RBG"]       = 'A',
	["TYPE_RAID"]      = 'R',
	["TYPE_DUNGEON"]   = 'D',
	["TYPE_SCENARIO"]  = 'S',
	["TYPE_ARENA"]     = 'a',
	["TYPE_QUESTS"]    = 'Q',
	["TYPE_LADDER"]    = 'L',
	["TYPE_CHALLENGE"] = 'C',
}
ns.const.type = premadeType

local battlegroundID = {
	["RND"]  =  0,
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
	["NONE"] = 15,
	["DKP"]  = 16,
}
ns.const.bg = battlegroundID

local queueStatus = {
	[0] = "-", 	 -- 0: none
	"queued",    -- 1: queued
	"CONFIRM",   -- 2: confirm
	"inside",    -- 3: active
	"error",     -- 4: error
}
ns.const.status = queueStatus

-- TODO: obfuscate
local bannedList = {
	"tts#1959", 			-- OQ exploiter
	"humiliation#1231", 	-- nazi symbol in OQ names
	"peaceandlove#1473", 	-- bandit
	"mokkthemadd#1462", 	-- flamed out, hard
	"fr0st#1118", 			-- n-word to scorekeeper
	"drunkhobo15#1211", 	-- exploit/hack
	"bradley#1957", 		-- spamming the scorekeeper, douchery
	"thetcer#1446", 		-- OQ exploiter
	"pawnstar#1571", 		-- exploit helm; 'f-you f*ggot' - chumlee
}
ns.const.banned = bannedList
