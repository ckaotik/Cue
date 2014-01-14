local addonName, ns, _ = ...
local DATA_TIMEOUT = 60*3

-- GLOBALS: IsInRaid, IsRatedBattleground, InCombatLockdown, PlaySound, BNGetNumFriendInvites, BNGetFriendInviteInfo, BNAcceptFriendInvite, BNDeclineFriendInvite
-- GLOBALS: time, date, pairs, wipe, collectgarbage, select, strsplit

local function SanitizeText(text)
	-- text = text:gsub('[°!"§$%?^*#]', ' ') -- :gsub('[.,+><]+', ' ')
	text = text:gsub('`´', '\''):gsub('%s+', ' ')
	-- text = text:lower():gsub('^%l', string.utf8upper):gsub(' %l', string.utf8upper) -- create common capitalization
	-- text = text:match("^[%p%s]+(.-)[%p%s]-$") or text 	-- snipe away punctuation
	text = text:trim() 					-- trim spaces, can also supply specific characters for removal
	return text
end

function ns.PruneData()
	-- remove posts older than 2min
	local outdatedTime = time() - DATA_TIMEOUT
	for leader, info in pairs(ns.db.premadeCache) do
		if info.updated < outdatedTime then
			if not ns.db.queued[leader] then
				wipe(info)
				ns.db.premadeCache[leader] = nil
			else
				ns.db.premadeCache[leader].updated = 0
			end
		end
	end

	ns.UpdateUI()
	if not InCombatLockdown() then
		collectgarbage()
	end
end

function ns.GetLeaderByRequestToken(reqToken)
	for leader, token in pairs(ns.db.tokens) do
		if token == reqToken then
			return leader
		end
	end
end

function ns.GetLeaderByToken(token)
	for leader, data in pairs(ns.db.premadeCache) do
		if data.token == token then
			return leader
		end
	end
end

-- handles "Mychar-Myrealm", "Mychar-123" and "Mychar" ["Myrealm"]
function ns.GetLeaderByName(name, realm)
	if not name or name == '' then return end
	if not realm and name:find('-') then
		name, realm = strsplit("-", name)
		realm = realm and tonumber(realm) or realm
	end

	if not realm then
		realm = ns.playerRealm
	elseif type(realm) ~= "number" then
		realm = ns.GetRealmInfoByName(realm)
	end

	local leaderName, leaderRealm
	for leader, data in pairs(ns.db.premadeCache) do
		leaderName, leaderRealm = ns.oq.DecodeLeaderData(leader)
		if leaderName == name and leaderRealm == realm then
			return leader
		end
	end
end

function ns.GetOQMessageInfo(message)
	local version, token, ttl, messageType, message = message:match("^OQ,([^,]+),([^,]+),([^,]+),([^,]+),(.-)$")
	return version, token, ttl, messageType, message
end

local function OnPremade(version, token, ttl, messageType, messageText)
	local sender, targetName, targetRealm
	-- local message, to, realm, from = messageText:match("^(.-),#to:([^,]+),#rlm:([^,]+),#fr:([^,]+)$")
	-- TODO: FIXME: re-creating functions on every premade/disband is really bad
	local message = messageText:gsub('(,#([^:]+):([^,]+))', function(field, key, value)
		-- remove all fields from messsage string, but store their values
		if key == 'to' then
			targetName = value
		elseif key == 'rlm' then
			targetRealm = value
		elseif key == 'fr' then
			sender = value
		end
		return ''
	end)

	local raidToken, premadeTitle, premadeInfo, leaderInfo, comment, premadeType, groupData, leaderExperience = strsplit(",", message)
	local faction, hasPassword, realmSpecific, is_source, level, iLvl, resilience, numMembers, numWaiting, status, msgTime, minMMR = ns.oq.DecodePremadeInfo(premadeInfo)

	-- a message from the future!
	if msgTime > time() + 4*24*60 then return end
	--[[ TYPE_NONE, TYPE_ARENA, TYPE_BG, TYPE_DUNGEON, TYPE_QUESTS, TYPE_RBG, TYPE_RAID, TYPE_SCENARIO, TYPE_CHALLENGE, --]]

	faction = faction == "H" and "Horde" or "Alliance"
	premadeTitle = ns.oq.DecodeText(premadeTitle)
	comment = ns.oq.DecodeText(comment)

	local tank, heal, dps = 0, 0, 0
	if groupData:match('^[THDX]+$') then
		groupData:gsub(".", function(character)
			if character == 'T' then tank = tank + 1
			elseif character == 'H' then heal = heal + 1
			else dps = dps + 1 end
		end)
	else
		tank, heal, dps = groupData:match("^(.)(.)(.)")
		tank 	= tank   == '-' and 0 or ns.oq.DecodeDigit(tank)
		heal 	= heal   == '-' and 0 or ns.oq.DecodeDigit(heal)
		dps 	= dps    == '-' and 0 or ns.oq.DecodeDigit(dps)
	end

	local premadeCache = ns.db.premadeCache
	-- use leader as unique key, as every player can only ever have one premade to his or her name
	premadeCache[leaderInfo] = premadeCache[leaderInfo] or {}
	if premadeCache[leaderInfo].updated and premadeCache[leaderInfo].updated > msgTime then return end
	premadeCache[leaderInfo].token      = raidToken
	premadeCache[leaderInfo].faction    = faction
	premadeCache[leaderInfo].type       = premadeType
	premadeCache[leaderInfo].password   = (hasPassword and hasPassword ~= 0) and true or false
	premadeCache[leaderInfo].title      = SanitizeText(premadeTitle)
	premadeCache[leaderInfo].comment    = SanitizeText(comment)
	premadeCache[leaderInfo].leader     = leaderInfo
	premadeCache[leaderInfo].size       = numMembers > 0 and numMembers or 1
	premadeCache[leaderInfo].waiting    = numWaiting
	premadeCache[leaderInfo].updated    = msgTime

	premadeCache[leaderInfo].level      = level
	premadeCache[leaderInfo].ilvl       = iLvl
	premadeCache[leaderInfo].resilience = resilience

	premadeCache[leaderInfo].group      = premadeCache[leaderInfo].group or {}
	premadeCache[leaderInfo].group.tank = tank
	premadeCache[leaderInfo].group.heal = heal
	premadeCache[leaderInfo].group.dps  = dps

	ns.UpdateUI()
end

local function OnDisband(version, token, ttl, messageType, messageText)
	local raidToken, msgToken, targetName, targetRealm, sender = strsplit(",", messageText)
	targetName  = targetName  and string.sub(targetName, 5)
	targetRealm = targetRealm and string.sub(targetRealm, 6)
	sender      = sender      and string.sub(sender, 5)

	local leader = ns.GetLeaderByToken(raidToken) or ns.GetLeaderByName(sender)
	if leader then
		wipe(ns.db.premadeCache[leader])
		ns.db.premadeCache[leader] = nil
		ns.db.queued[leader] = nil
	else
		-- ns.Print("Could not find disbanded group %s by %s", raidToken or '', sender or '')
	end
end

local function OnJoin(_, token, _, messageType, message)
	local reqToken, invType, leader = strsplit(',', message)
	reqToken = reqToken and string.sub(reqToken, 6)
	leader   = leader   and string.sub(leader, 6)

	local friendNote
	if invType == '#lead' then
		friendNote = 'OQ,leader'
	else
		friendNote = 'OQ'
		-- group leader:
		-- local leadName, leadRealmID = strsplit('-', leader)
	end

	--[[-- TODO: do this when receiving friend request leading to invite
	if IsInGroup(_G.LE_PARTY_CATEGORY_HOME) then
		if ns.db.leaveExistingGroup then
			LeaveParty()
		else
			ns.Print('You are already in a group.')
			return
		end
	end
	--]]

	-- ns.db.tokens[reqToken] = nil
	-- ns.db.queued[leader] = ns.const.status.GROUPED

	-- accept friend request + add reason/note to db
	return true, friendNote
end

local function OnWaitlistLeave(version, token, ttl, messageType, message)
	local raidToken, reqToken = strsplit(',', message)
	local leader = ns.GetLeaderByRequestToken(reqToken) or ns.GetLeaderByToken(raidToken)

	if leader then
		-- TOOD: reset .queued status, reset .tokens[reqToken], print info
	end

	-- decline friend request
	return false
end

local function OnResponse(version, token, ttl, messageType, message)
	local raidToken, reqToken, answer, reason = strsplit(",", message)
	if ns.Find(ns.db.tokens, reqToken) then
		-- multi-boxer can receive same msg if via real-id msg
		return
	end

	local leader = ns.GetLeaderByToken(raidToken)
	if not leader then
		ns.Print("Could not find premade %s that we tried to join", raidToken)
		return
	end

	local title = ns.db.premadeCache[leader].title
	if answer == 'Y' then
		PlaySound("PVPENTERQUEUE")
		ns.Print("Successfully joined wait list for '%s'", title)
		ns.db.queued[leader] = ns.const.status.QUEUED
	else
		PlaySound("igQuestFailed")
		ns.Print("Wait list slot for '%s' was declined: %s", title, reason)
		ns.db.queued[leader] = nil
	end

	-- decline friend request
	return false
end

local messageHandler = {
	["p8"] = OnPremade,
	["disband"] = OnDisband,
	["invite"]  = OnJoin,
	["invite_req_response"]   = OnResponse,
	["leave_waitlist"]        = OnWaitlistLeave,
	["removed_from_waitlist"] = OnWaitlistLeave,
}

-- ================================================
--  Listen for message & handle appropriately
-- ================================================
ns.RegisterEvent("CHAT_MSG_CHANNEL", function(self, event, ...)
	-- if InCombatLockdown() or IsInRaid() or IsRatedBattleground() then return end
	local channelName, _, _, senderGUID = select(9, ...)
	if channelName:lower() ~= "oqgeneral" then return end

	local version, token, ttl, messageType, message = ns.GetOQMessageInfo(...)
	if messageType and messageHandler[messageType] then
		messageHandler[messageType](version, token, ttl, messageType, message)
	end
end, "oq_msg_channel")

ns.RegisterEvent("CHAT_MSG_BN_WHISPER", function(self, event, ...)
	-- if InCombatLockdown() or IsInRaid() or IsRatedBattleground() then return end
	local chatMessage = ...
	local presenceID  = select(13, ...)

	local version, token, ttl, messageType, message = ns.GetOQMessageInfo(chatMessage)
	if messageType and messageHandler[messageType] then
		messageHandler[messageType](version, token, ttl, messageType, message)
	end
end, "oq_msg_bnet")

ns.RegisterEvent("CHAT_MSG_ADDON", function(self, event, prefix, msg, channel, sender)
	if prefix ~= "OQ" or sender == ns.playerName then return end

	local version, token, ttl, messageType, message = ns.GetOQMessageInfo(msg)
	if messageType and messageHandler[messageType] then
		messageHandler[messageType](version, token, ttl, messageType, message)
	end
end, "oq_msg_addon")

local notes = {}
local function SetFriendNote()
	for presenceID, note in pairs(notes) do
		local noteText = select(12, BNGetFriendInfoByID(presenceID))
		if not noteText or noteText == '' then
			BNSetFriendNote(presenceID, note)
			notes[presenceID] = nil
		end
	end
	ns.UnregisterEvent("BN_FRIEND_LIST_SIZE_CHANGED", 'friendnote')
end
local function HandleFriendInvites(self, event)
	for i = BNGetNumFriendInvites(), 1, -1 do
		local presenceID, presenceName, isBattleTagPresence, msg, broadcastTime = BNGetFriendInviteInfo(i)

		local version, token, ttl, messageType, message = ns.GetOQMessageInfo(msg)
		if not version then
			token, message = msg:match('^OQ,([^,]+),(.-)$')
			messageType = 'invite'
		end

		if messageType and messageHandler[messageType] then
			local shouldAccept, friendNote = messageHandler[messageType](version, token, ttl, messageType, message)

			if shouldAccept then
				if friendNote and friendNote ~= '' then
					notes[presenceID] = friendNote
					ns.RegisterEvent('BN_FRIEND_LIST_SIZE_CHANGED', SetFriendNote, 'friendnote', true)
				end

				BNAcceptFriendInvite(presenceID)
			else
				BNDeclineFriendInvite(presenceID)
			end
		end
	end
end
ns.RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED", HandleFriendInvites, "availfriendreq")
ns.RegisterEvent("BN_FRIEND_INVITE_ADDED", HandleFriendInvites, "newfriendreq")

local currentGroupLeader = nil
ns.RegisterEvent("PARTY_INVITE_REQUEST", function(self, event, leaderName, ...)
	local leader = ns.GetLeaderByName(leaderName)
	if leader then
		ns.db.tokens[leader] = nil
		if ns.db.queued[leader] then
			ns.db.queued[leader] = ns.const.status.GROUPED
			currentGroupLeader = leader
			ns.UpdateUI(true)
		end
	end
	-- ns.LeaveQueue(otherLeader)
	-- if removeFriendOnJoin then ... end
end, "invite_group")

ns.RegisterEvent("GROUP_ROSTER_UPDATE", function(self, event)
	if currentGroupLeader and GetNumGroupMembers() <= 1 then
		-- group left
		ns.LeaveQueue(currentGroupLeader)
		ns.db.queued[leader] = nil
		currentGroupLeader = nil
		ns.UpdateUI(true)
	end
end, 'leave_group')
