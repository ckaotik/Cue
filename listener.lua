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
		leaderName, leaderRealm, _ = ns.oq.DecodeLeaderData(leader)
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
		ns.LeaveQueue(leader)
		wipe(ns.db.premadeCache[leader])
		ns.db.premadeCache[leader] = nil
	else
		-- ns.Print("Could not find disbanded group %s by %s", raidToken or '', sender or '')
	end
end

local function OnJoin(version, token, ttl, messageType, message)
	-- "invite_group,"..req_token ..","..group_id ..","..slot ..","..oq.encode_name( oq.raid.name ) ..","..oq.raid.leader_class  ..","..enc_data ..","..oq.raid.raid_token ..",".oq.encode_note( oq.raid.notes ) ;

	print('OnJoin', version, token, ttl, messageType, message)
	-- BN_FRIEND_INVITE_ADDED nil: OQ,GTo8dm,#tok:QRvkoi,#grp:1,#nam:Бриллианта-362

	local reqToken, invType, leader = strsplit(',', message)
	reqToken = reqToken and string.sub(reqToken, 6) -- strip "#tok:"
	leader   = leader   and string.sub(leader, 6)   -- strip "#nam:"

	local friendNote
	if invType == '#lead' then
		friendNote = 'OQ,leader'
	else
		invType = string.sub(invType, 6)    -- strip "#grp:"
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

	-- OQ,GQIXxf,#tok:QOX3Xy,#grp:1,#nam:Darthsetta-231
	local data = ns.oq.EncodeLeaderData(ns.playerName, ns.playerRealm, ns.playerBattleTag)
	local _, _, battleTag = ns.oq.DecodeLeaderData(leader)
	local slot = 1
	local message = strjoin(",", token, invType, slot, player_class, data, reqToken)
	ns.SendMessage(battleTag, true, 'invite_accepted', message, nil, 1)

	-- ns.db.tokens[reqToken] = nil
	-- ns.db.queued[leader] = ns.const.status.GROUPED

	-- accept friend request + add reason/note to db
	return true, friendNote
end

local function OnWaitlistLeave(version, token, ttl, messageType, message)
	local raidToken, reqToken = strsplit(',', message)
	local leader = ns.GetLeaderByRequestToken(reqToken) or ns.GetLeaderByToken(raidToken)

	if leader then
		PlaySound("igQuestFailed")
		ns.Print("You were removed from '%s' wait list",
			ns.db.premadeCache[leader] and ns.db.premadeCache[leader].title or 'unknown')
		ns.LeaveQueue(leader)
	end

	-- decline friend request
	return false
end

local function OnResponse(version, token, ttl, messageType, message)
	local raidToken, reqToken, answer, reason = strsplit(",", message)
	if ns.Find(ns.db.tokens, reqToken) then
		-- multi-boxers can receive same msg if via real-id msg
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

local function OnPing(version, token, ttl, messageType, message, senderToonID)
	local toonName, realmName, faction, battleTag, timestamp, acknowledged = strsplit(",", message)
	local playerName, playerRealm = UnitName('player'), GetRealmName():gsub(' ', '')
	local timestamp = ns.oq.EncodeNumber64(ns.utc() or 0, 5)
	local message = strjoin(',', playerName, playerRealm, ns.playerFaction, ns.playerBattleTag, timestamp, 'ack')
	ns.SendMessage(senderToonID, true, 'oq_user', message, 'W1', 1)
end

local messageHandler = {
	["p8"] = OnPremade,
	["disband"] = OnDisband,
	["invite"]  = OnJoin,
	["invite_group"] = OnJoin,
	["invite_req_response"]   = OnResponse,
	["leave_waitlist"]        = OnWaitlistLeave,
	["removed_from_waitlist"] = OnWaitlistLeave,
	["oq_user"] = OnPing,
}

-- ================================================
--  Listen for message & handle appropriately
-- ================================================
local function HandleChatMessage(event, chatMessage, presenceID, senderName, blizzRealmID, senderToonID)
	local version, token, ttl, messageType, message = ns.GetOQMessageInfo(chatMessage)
	if messageType ~= "p8" and messageType ~= "scores" then
		if message then
			print(event, messageType, senderToonID, "\n".._G.GRAY_FONT_COLOR_CODE..chatMessage..'|r')
		else
			print(event, messageType, senderToonID, "UNPARSED\n".._G.GRAY_FONT_COLOR_CODE..chatMessage..'|r')
		end
	end
	if messageType and messageHandler[messageType] then
		messageHandler[messageType](version, token, ttl, messageType, message, senderToonID)
	end
end

ns.RegisterEvent('CHAT_MSG_CHANNEL', function(self, event, chatMessage, senderName, _, _, _, _, _, _, channelName)
	channelName = channelName:lower()
	if channelName == ns.OQchannel or channelName == 'oqgeneral' then
		HandleChatMessage(event, chatMessage, nil, senderName)
	end
end, 'oq_msg_channel')

ns.RegisterEvent('CHAT_MSG_ADDON', function(self, event, prefix, chatMessage, _, senderName)
	if prefix ~= 'OQ' or senderName == ns.playerName then return end
	HandleChatMessage(event, chatMessage, nil, senderName)
end, 'oq_msg_addon')

ns.RegisterEvent('BN_CHAT_MSG_ADDON', function(self, event, prefix, chatMessage, _, senderToonID)
	local _, toonName, client, realmName, realmID, _, _, _, _, _, _, _, _, _, _, presenceID = BNGetToonInfo(senderToonID)
	local senderName = toonName..'-'..realmName:gsub(' ', '')
	HandleChatMessage(event, chatMessage, presenceID, senderName, realmID, senderToonID)
end, 'oq_msg_bnet_addon')

ns.RegisterEvent('CHAT_MSG_BN_WHISPER', function(self, event, chatMessage, _, _, _, _, _, _, _, _, _, _, _, presenceID)
	HandleChatMessage(event, chatMessage, presenceID)
end, 'oq_msg_bnet')

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
local function HandleFriendInvites(self, event, ...)
	local prefix, msg, _, senderToonID = ...

	for i = BNGetNumFriendInvites(), 1, -1 do
		local presenceID, presenceName, isBattleTagPresence, msg, broadcastTime = BNGetFriendInviteInfoByAddon(i)

		local version, token, ttl, messageType, message = ns.GetOQMessageInfo(msg)
		print(event, messageType, "\n".._G.GRAY_FONT_COLOR_CODE..msg.."|r")
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

		if not ns.db.stayQueuedOnInvite then
			for otherLeader, status in pairs(ns.db.queued) do
				if otherLeader ~= leader then
					ns.LeaveQueue(otherLeader, true)
				end
			end
		end
	end
	-- if removeFriendOnJoin then ... end
end, "invite_group")

ns.RegisterEvent("GROUP_ROSTER_UPDATE", function(self, event)
	if currentGroupLeader and GetNumGroupMembers() <= 1 then
		-- left group
		ns.LeaveQueue(currentGroupLeader)
		currentGroupLeader = nil
		ns.UpdateUI(true)
	end
end, 'leave_group')
