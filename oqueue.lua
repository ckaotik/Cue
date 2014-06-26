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
ns.oq.bset = bset

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
	-- ..(2:level)(1:demo)(1:class)...(2:hp)(1:role)(1:specid)(2:ilevel)(1:oqversion)(...:info)
	-- PVE info: (dungeon/raid/roleplay)
	-- 	(3:dodge)(3:parry)(3:block)(3:mastery)(...:meta)				-- tank
	--  (3:power)(3:hit)(3:crit)(3:mastery)(3:haste)(...:meta)			-- ranged dps / caster / melee
	-- PVP info:
	-- 	(3:resil)(3:pvppwr)(3:wins)(3:losses)(3:tears)(2:mmr)(2:hks)..(...:meta)
	-- meta: (...:data)(1:karma) contains raids / ranks
	-- karma: oq.decode_mime64_digits( m.karma ) - 25

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
ns.oq.EncodeNumber64 = EncodeNumber64

-- --------------------------------------------------------
--  ~
-- --------------------------------------------------------
local GenerateToken = oq and oq.token_gen or
function(prefix, saveKey)
	-- get normalized UTC time with random modifier
	local token = EncodeNumber64(ns.utc() * 10000 + fastrandom(0, 10000), 5)
	      token = (prefix or '') .. token

	if saveKey then
		ns.db.tokens[saveKey] = token
	end
	return token
end
ns.oq.GenerateToken = GenerateToken

-- TODO: this is stupid, anyone can grab password from messages and sign themselves up :( need at least 1-way-encryption + char dependent salt
function ns.oq.EncodePassword(password)
	if not password or password == '' then
		password = '.'
	end
	local s = password:sub(0, 10):gsub(',', ';'):reverse()
	return Encode64(s)
end

local salt = "abc123"
function ns.oq.EncodeLeaderData(name, realm, battleTag)
	local s = strjoin(",", name, realm, battleTag)
	      s = s:gsub(',', ';'):reverse()

	-- encrypt
	-- s = oq.encrypt(salt, s)

	return Encode64(s)
end

function ns.oq.DecodeLeaderData(data)
	local s = Decode256(data)
	      s = s:reverse():gsub(";", ",")

	-- decrypt
	-- s = oq.decrypt(salt, s)

	local name, realm, battleTag = string.split(',', s)
	return name, tonumber(realm or '') or realm, battleTag
end
