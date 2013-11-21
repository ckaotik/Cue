local _, ns = ...

-- GLOBALS: _G
-- GLOBALS: GetAverageItemLevel, GetStatistic, UnitSex, UnitFactionGroup, UnitRace, UnitClass, GetSpecialization, GetSpecializationInfo, UnitLevel, UnitHealthMax, GetCombatRatingBonus
-- GLOBALS: select, ipairs, bit, math, string

local RANGED, MELEE, CASTER, TANK = 1, 2, 3, 4
local statGetters = {
	[TANK]   = { GetDodgeChance, GetParryChance, GetBlockChance, GetMasteryEffect },
	[CASTER] = { GetSpellBonusHealing,  function() return GetCombatRatingBonus(_G.CR_HIT_SPELL) end, GetMasteryEffect, UnitSpellHaste },
	[RANGED] = { UnitRangedAttackPower, function() return GetCombatRatingBonus(_G.CR_HIT_RANGED) end, GetRangedCritChance, GetMasteryEffect, GetRangedHaste },
	[MELEE]  = { UnitAttackPower,       function() return GetCombatRatingBonus(_G.CR_HIT_MELEE) end, GetCritChance, GetMasteryEffect, GetMeleeHaste }
}
-- achievements to check for progress data. one encoded character per subtable, each encounter as 10man followed by 25man
local raidProgress = {
	-- terrace of endless spring
	{6813, 7965, 6815, 7967, 6817, 7969, 6819, 7971}, -- 10/25 normal
	{6814, 7966, 6816, 7968, 6818, 7970, 6820, 7972}, -- 10/25 heroic
	-- heart of fear
	{6801, 7951, 6803, 7954, 6805, 7956, 6807, 7958, 6809, 7961, 6811, 7963}, -- 10/25 normal
	{6802, 7953, 6804, 7955, 6806, 7957, 6808, 7960, 6810, 7962, 6812, 7964}, -- 10/25 heroic
	-- mogu'shan
	{6789, 7914, 6791, 7917, 6793, 7919, 6795, 7921, 6797, 7923}, -- 10/25 normal
	{6790, 7915, 6792, 7918, 6794, 7920, 6796, 7922, 6798, 7924}, -- 10/25 heroic
	-- throne of thunder
	{8142, 8143, 8149, 8150, 8154, 8155, 8159, 8160, 8164, 8165, 8169, 8170}, -- 10/25 normal
	{8174, 8175, 8179, 8182, 8184, 8185, 8189, 8190, 8194, 8195, 8199, 8200},
	{8144, 8145, 8151, 8152, 8156, 8157, 8162, 8161, 8166, 8167, 8171, 8172}, -- 10/25 heroic
	{8176, 8177, 8181, 8180, 8186, 8187, 8191, 8192, 8196, 8197, 8202, 8201},
	{8203, 8256} -- Ra-Den
}

local typesPvE = {
	[ns.const.type.TYPE_QUESTS]    = true,
	[ns.const.type.TYPE_SCENARIO]  = true,
	[ns.const.type.TYPE_CHALLENGE] = true,
	[ns.const.type.TYPE_DUNGEON]   = true,
	[ns.const.type.TYPE_RAID]      = true,
}

local statStub
function ns.EncodeStats(premadeType)
	-- static info
	if not statStub then
		local _, race = UnitRace('player')
		local raceID = 0
		for i, raceName in ipairs(ns.const.playerRaces) do
			if raceName == race then
				raceID = i
				break
			end
		end
		local _, _, classID = UnitClass('player')
		local faction = UnitFactionGroup('player')
		      faction = faction == 'Horde' and 0 or 1
		local gender = UnitSex('player')
		      gender = gender == 2 and 0 or 1

		local demographics = bit.lshift(raceID, 2) + bit.lshift(gender, 1) + faction
		local flags, xFlags, charm, s1, s2 = 0, 0, 0, 'A', 'A'

		statStub = 'A' -- group/slot index
			.. (premadeType or ns.const.type['TYPE_NONE'])
			.. '%s'										-- level
			.. ns.oq.EncodeNumber64(demographics, 1)
			.. ns.const.playerClasses[classID]
			.. ns.oq.EncodeNumber64(flags, 1)
			.. ns.oq.EncodeNumber64(xFlags, 1)
			.. ns.oq.EncodeNumber64(charm, 1)
			.. '%s%s%s%s'								-- maxHealth, role, spec, itemLevel
			.. ns.oq.EncodeNumber64(ns.OQversion, 1)
	end

	-- dynamic info
	local level        = UnitLevel('player')
	local maxHealth    = UnitHealthMax('player')
	      maxHealth    = math.floor(maxHealth / 1000)
	local _, itemLevel = GetAverageItemLevel()

	local specID   = GetSpecialization()
	local specRole = 'NONE'
	if specID then
		specID, _, _, _, _, specRole = GetSpecializationInfo(specID)
	end
	local OQRoleID = (specRole == 'DAMAGER' and 1) or (specRole == 'HEALER' and 2) or (specRole == 'TANK' and 4) or 3
	local OQSpecID, OQStatType  = ns.const.specInfo[specID].id, ns.const.specInfo[specID].stats

	local stats = string.format(statStub,
		ns.oq.EncodeNumber64(level, 2),
		ns.oq.EncodeNumber64(maxHealth, 2),
		ns.oq.EncodeNumber64(OQRoleID, 1),
		ns.oq.EncodeNumber64(OQSpecID, 1),
		ns.oq.EncodeNumber64(itemLevel, 2)
	)

	if typesPvE[premadeType] then
		local bonus
		for _, statGetter in ipairs(statGetters[OQStatType]) do
			bonus = statGetter('player')
			stats = stats .. ns.oq.EncodeNumber64(bonus*100, 3)
		end

		if premadeType == ns.const.type.TYPE_CHALLENGE then
			-- challenge mode medals
			for _, statistic in ipairs({ 7400, 7401, 7402 }) do
				stats = stats .. ns.oq.EncodeNumber64((GetStatistic(statistic)), 2)
			end
		else
			-- raid progression data
			local progressData = ''
			local flags, achievement10, achievement25
			for _, raidAchievements in ipairs(raidProgress) do
				flags = 0
				for i = 1, #raidAchievements, 2 do
					achievement10, achievement25 = raidAchievements[i], raidAchievements[i+1]
					flags = ns.oq.bset(flags, 2^(i-1), (GetStatistic(achievement10) ~= '--') or (GetStatistic(achievement25) ~= '--'))
				end
				stats = stats .. ns.oq.EncodeNumber64(flags, 1)
			end
		end

		-- wipes & kills, ignore for now
		stats = stats
			.. ns.oq.EncodeNumber64(0, 3) -- boss kills (5man, challenge, raid)
			.. ns.oq.EncodeNumber64(0, 2) -- boss wipes
			.. ns.oq.EncodeNumber64(0, 3) -- leader dkp
			.. ns.oq.EncodeNumber64(0, 3) -- dkp
	else
		-- TODO
		--[[
		-- pvp stats
	    local bg_stats = OQ_toon.stats["rbg"] ;
	    if (oq.raid.type == OQ.TYPE_BG) then
	      bg_stats = OQ_toon.stats["bg"] ;
	    end
	    s = s .."".. oq.encode_mime64_3digit( oq.get_resil() ) ;
	    s = s .."".. oq.encode_mime64_3digit( oq.get_pvppower() ) ;
	    s = s .."".. oq.encode_mime64_3digit( bg_stats.nWins ) ;
	    s = s .."".. oq.encode_mime64_3digit( bg_stats.nLosses ) ;
	    s = s .."".. oq.encode_mime64_3digit( oq.total_tears() ) ; -- the only tears that count are those of your enemy; rbgs could be same faction
	    s = s .."".. oq.encode_mime64_2digit( oq.get_best_mmr(oq.raid.type) ) ; -- rbg rating
	    s = s .."".. oq.encode_mime64_2digit( oq.get_hks() ) ; -- total hks
	    s = s .."".. s1 ;
	    s = s .."".. s2 ;
	    if (m ~= nil) then
	      m.ranks = oq.get_pvp_experience() ;
	      s = s .."".. m.ranks ; -- ranks & titles
	    else
	      s = s .."".. oq.get_pvp_experience() ;
	    end
		--]]
	end
	stats = stats .. ns.oq.EncodeNumber64(25, 1) -- TODO: karma

	return stats
end
