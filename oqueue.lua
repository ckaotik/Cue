local _, ns = ...
ns.oq = {}
-- GLOBALS: oq
-- GLOBALS: bit, string, strlen

-- Code taken from oQueue
-- encodings & decodings to be able to handle oQueues data.
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

local bset = oq and oq.bset or function(flags, mask, set)
	flags = bit.bor(flags, mask)
	if not set or set == 0 then
		flags = bit.bxor( flags, mask )
	end
	return flags
end

local base256 = oq and oq.base256 or function(w, x, y, z)
	local w, x, y, z = oq_mime64[ w ] or 0, oq_mime64[ x ] or 0,  oq_mime64[ y ] or 0, oq_mime64[ z ] or 0

	--    a = (w << 2) + ((x & 0x30) >> 4)
	local a = bit.lshift( w, 2 ) + bit.rshift( bit.band( x, 0x30 ), 4 )
	--    b = ((x & 0x0F) << 4) + ((y & 0x3C) >> 2)
	local b = bit.lshift( bit.band( x, 0x0F ), 4 ) + bit.rshift( bit.band( y, 0x3C ), 2 )
	--    c = ((y & 0x03) << 6) + z
	local c = bit.lshift( bit.band( y, 0x03 ), 6 ) + z

	a = oq_ascii[ a ]
	b = oq_ascii[ b ]
	c = oq_ascii[ c ]
	return a, b, c
end

-- raw (en|de)coding functions
local Decode256 = oq and oq.decode256 or function(enc)
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

local DecodeDigit = oq and oq.decode_mime64_digits or function(s)
	if not s then return 0 end
	local n = 0
	for i = 1, #s do
		n = n * 64 + oq_mime64[ s:sub( i,i ) or 'A' ]
	end
	return n
end
ns.oq.DecodeDigit = DecodeDigit

local DecodeFlags = oq and oq.decode_mime64_flags or function(f1, f2, f3, f4, f5, f6)
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

local password = "abc123"
local DecodeLeaderData = -- oq and oq.decode_data and function(data) return oq.decode_data(password, data) end or
function(data)
	local s = Decode256(data)
	      s = s:reverse():gsub(";", ",")

	-- decrypt, apparently buggy
	-- s = oq.decrypt(password, s)

	local name, realm, battleTag = string.split(',', s)
	local id, realmName, locale, pvp, rp, group = ns.GetRealmInfoFromID(realm)
	return name, realmName, battleTag
end
ns.oq.DecodeLeaderData = DecodeLeaderData

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

local GenerateToken = oq and oq.token_gen or
function()
	-- TODO: FIXME: only works on MacOS
	return EncodeNumber64(date('!%s') * 10000 + math.random(0, 10000), 5)
end
ns.oq.GenerateToken = GenerateToken
