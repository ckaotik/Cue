local _, ns = ...
ns.oq = {}

-- GLOBALS: _G
-- GLOBALS: bit, string, strlen

-- encodings & decodings to be able to handle oQueues data.
-- Code taken from oQueue, credits go to tiny
local oq_ascii = {}
local oq_mime64 = {}

local function init_table()
	for i = 0, 255 do
		local c = string.format("%c", i)
		oq_ascii[i] = c
		oq_ascii[c] = i
	end

	local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	for i = 1, strlen(charset) do
		local c = charset:sub(i,i)
		oq_mime64[i-1] = c
		oq_mime64[c]   = i-1
	end
end
init_table()

local bset = -- oq and oq.bset or
function(flags, mask, set)
	flags = bit.bor(flags, mask)
	if not set or set == 0 then
		flags = bit.bxor( flags, mask )
	end
	return flags
end

local base64 = -- oq and oq.base64 or
function(a, b, c)
	a, b, c = oq_ascii[a], oq_ascii[b], oq_ascii[c]

	local w =                                    bit.rshift(bit.band(a, 0xFC), 2)
	local x = bit.lshift(bit.band(a, 0x03), 4) + bit.rshift(bit.band(b, 0xF0), 4)
	local y = bit.lshift(bit.band(b, 0x0F), 2) + bit.rshift(bit.band(c, 0xC0), 6)
	local z = bit.band(c, 0x3F)

	return oq_mime64[w], oq_mime64[x], oq_mime64[y], oq_mime64[z]
end

local base256 = -- oq and oq.base256 or
function(w, x, y, z)
	local w, x, y, z = oq_mime64[w] or 0, oq_mime64[x] or 0,  oq_mime64[y] or 0, oq_mime64[z] or 0

	local a = bit.lshift(w, 2)                 + bit.rshift(bit.band(x, 0x30), 4)
	local b = bit.lshift(bit.band(x, 0x0F), 4) + bit.rshift(bit.band(y, 0x3C), 2)
	local c = bit.lshift(bit.band(y, 0x03), 6) + z

	return oq_ascii[a], oq_ascii[b], oq_ascii[c]
end

-- --------------------------------------------------------
--  decoding functions
-- --------------------------------------------------------
local Decode256 = -- oq and oq.decode256 or
function(enc)
	if not enc or enc == "" then return "" end
	local str = ""
	local w, x, y, z, a, b, c
	for i = 1, strlen(enc), 4 do
		w = enc:sub(i,i)
		x = enc:sub(i+1,i+1)
		y = enc:sub(i+2,i+2)
		z = enc:sub(i+3,i+3)
		a, b, c = base256( w, x, y, z )
		str = str .."".. a .."".. b .."".. c
	end
	return str
end

local DecodeDigit = -- oq and oq.decode_mime64_digits or
function(s)
	if not s then return 0 end
	local n = 0
	for i = 1, #s do
		n = n * 64 + oq_mime64[ s:sub( i,i ) or 'A' ]
	end
	return n
end
ns.oq.DecodeDigit = DecodeDigit

local DecodeFlags = -- oq and oq.decode_mime64_flags or
function(f1, f2, f3, f4, f5, f6)
	local a = 0
	a = bset( a, 0x01, f1 )
	a = bset( a, 0x02, f2 )
	a = bset( a, 0x04, f3 )
	a = bset( a, 0x08, f4 )
	a = bset( a, 0x10, f5 )
	a = bset( a, 0x20, f6 )
	return oq_mime64[ a ]
end
ns.oq.DecodeFlags = DecodeFlags

local DecodeText = -- oq and oq.decode_name or
function(data)
	if not data then return "" end
	local s = Decode256(data)
	-- reverse then sub
	s = s:reverse()
	s = string.gsub( s, ";", "," )

	if s == "." then s = "" end
	return s ;
end
ns.oq.DecodeText = DecodeText

-- decode info that we know the structure of
local DecodePremadeInfo = -- oq and oq.decode_premade_info or
function(data)
	if not data then return nil end
	local info, level, iLvl, resilience, numMembers, numWaiting, stat, msgTime, minMMR, karma = string.match(data, "^(.)(.)(..)(...)(.)(.)(.)(......)(..)(.)")

	local is_horde, has_pword, is_realm_specific, is_source = DecodeFlags(info)
	local range = DecodeDigit(level) -- levelRange[ DecodeDigit(level) ]

	if not karma or karma == "" then
		karma = 0
	else
		karma = DecodeDigit(karma) - 25
	end

	return is_horde and "H" or "A", has_pword, is_realm_specific, is_source, range,
		DecodeDigit(iLvl),
		DecodeDigit(resilience),
		DecodeDigit(numMembers),
		DecodeDigit(numWaiting),
		DecodeDigit(stat),
		DecodeDigit(msgTime),
		DecodeDigit(minMMR),
		karma
end
ns.oq.DecodePremadeInfo = DecodePremadeInfo

-- --------------------------------------------------------
--  Encoding functions
-- --------------------------------------------------------
local function Encode64(text)
	local w, x, y, z
	local encoded = ''

	for i = 1, strlen(text), 3 do
		w, x, y, z = base64(text:sub(i, i), text:sub(i+1, i+1), text:sub(i+2, i+2))
		encoded = encoded .. w..x..y..z
	end
	return encoded
end

local function EncodeNumber64(number, numDigits)
	local result = ''
	local number, digit = tonumber(number or '') or 0, nil
	for i = numDigits, 1, -1 do
		digit  = math.floor(number%64)
		number = math.floor(number/64)
		result = oq_mime64[digit] .. result
	end
	return result
end

-- --------------------------------------------------------
--  ~
-- --------------------------------------------------------
local password = "abc123"

local EncodeLeaderData = -- oq and oq.encode_data and function(data) return oq.encode_data(password, name, realm, battleTag) end or
function(name, realm, battleTag)
	local realmID = ns.GetRealmInfoByName(realm)
	local s = strjoin(",", name, realmID, battleTag)
	      s = s:gsub(',', ';'):reverse()

	-- encrypt
	-- s = oq.encrypt(password, s)

	return encode64(s)
end
ns.oq.EncodeLeaderData = EncodeLeaderData

local DecodeLeaderData = -- oq and oq.decode_data and function(data) return oq.decode_data(password, data) end or
function(data)
	local s = Decode256(data)
	      s = s:reverse():gsub(";", ",")

	-- decrypt, apparently buggy
	-- s = oq.decrypt(password, s)

	local name, realm, battleTag = string.split(',', s)
	return name, realm, battleTag
end
ns.oq.DecodeLeaderData = DecodeLeaderData

local GenerateToken = oq and oq.token_gen or
function()
	-- get normalized UTC time with random modifier
	-- TODO: FIXME: only works on MacOS
	return EncodeNumber64(date('!%s') * 10000 + math.random(0, 10000), 5)
end
ns.oq.GenerateToken = GenerateToken

local RANGED, MELEE, CASTER, TANK = 1, 2, 3, 4
local statGetters = {
	[TANK]   = { GetDodgeChance, GetParryChance, GetBlockChance, GetMasteryEffect },
	[CASTER] = { GetSpellBonusHealing, function() return GetCombatRatingBonus(_G.CR_HIT_SPELL) end, GetMasteryEffect, UnitSpellHaste },
	[RANGED] = { UnitRangedAttackPower, function() GetCombatRatingBonus(_G.CR_HIT_RANGED) end, GetRangedCritChance, GetMasteryEffect, GetRangedHaste },
	[MELEE]  = { UnitAttackPower, function() GetCombatRatingBonus(_G.CR_HIT_MELEE) end, GetCritChance, GetMasteryEffect, GetMeleeHaste }
}
local function EncodeStats()
	-- static info
	local OQversion = '0Z'
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

	-- dynamic info
	local flags, xFlags, charm, s1, s2 = 0, 0, 0, 'A', 'A'
	local level     = UnitLevel('player')
	local maxHealth = UnitHealthMax('player')
	      maxHealth = math.floor(maxHealth / 1000)
	local _, itemLevel = GetAverageItemLevel()

	local specID   = GetSpecialization()
	local specRole = specID and select(6, GetSpecializationInfo(specID))
	local OQRoleID = (specRole == 'DPS' and 1) or (specRole == 'HEALER' and 2) or (specRole == 'TANK' and 4) or 3
	local OQSpecID, OQStatType  = ns.const.specInfo[specID].id, ns.const.specInfo[specID].stats

	-- if (my_group > 0) then m = oq.raid.group[my_group].member[my_slot] end
	local stats = '' -- oq.encode_slot(my_group, my_slot)
		.. ns.const.type['TYPE_NONE'] -- TODO: (oq.raid.type or OQ.TYPE_NONE)
		.. ns.oq.EncodeNumber64(level, 2)
		.. ns.oq.EncodeNumber64(demographics, 1)
		.. ns.const.playerClasses[ classID ]
		.. ns.oq.EncodeNumber64(flags, 1)
		.. ns.oq.EncodeNumber64(xFlags, 1)
		.. ns.oq.EncodeNumber64(charm, 1)
		.. ns.oq.EncodeNumber64(maxHealth, 2)
		.. ns.oq.EncodeNumber64(OQRoleID, 1)
		.. ns.oq.EncodeNumber64(OQSpecID, 1)
		.. ns.oq.EncodeNumber64(itemLevel, 2)
		.. ns.oq.EncodeNumber64(OQversion, 1)

	if ns.IsPvE(premadeType) then
		local bonus
		for _, bonusFunc in ipairs(statGetters[OQStatType]) do
			bonus = bonusFunc('player')
			stats = stats .. ns.oq.EncodeNumber64(bonus*100, 3)
		end

		--[[
		-- raid progression data
		if (oq.raid.type == OQ.TYPE_CHALLENGE) then
		  s = s .."".. oq.get_past_experience() ;
		else
		  s = s .."".. oq.get_raid_progression() ;
		end
		--]]
	else
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

	-- karma, tacked on the back to avoid protocol change and forced update
	stats = stats .. ns.oq.EncodeNumber64(50, 1) -- TODO: karma
	-- if my_group > 0 then oq.decode_stats2( player_name, player_realm, s, true ) end

	return stats
end
