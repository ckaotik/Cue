local addonName, ns, _ = ...

local BNET_PREFIX = "(OQ)"

-- GLOBALS: BNFeaturesEnabledAndConnected, BNConnected, BNGetInfo, BNGetNumFriends, BNGetFriendInfo, BNSetCustomMessage, BNSendFriendInvite, BNGetFriendInfoByID

function ns.GetBnetFriendInfo(searchBattleTag)
	local presenceID, battleTag, client, isOnline
	for i = 1, BNGetNumFriends() do
		presenceID, _, battleTag, _, _, _, client, isOnline = BNGetFriendInfo(i)
		if battleTag == searchBattleTag then
			return presenceID, isOnline, client == 'WoW'
		end
	end
end

-- send a message across battle.net via private message -or- friend request + note
function ns.SendBnetMessage(battleTag, message, messageType)
	local presenceID, isOnline, isWoW = ns.GetBnetFriendInfo(battleTag)
	if presenceID then
		if isOnline and isWoW then
			-- BNSendGameData(presenceID, addonPrefix, message)
			-- BNSendWhisper(presenceID, message)
		end
	else
		-- TODO: FIXME: trashes tables
		table.insert(ns.db.bntracking, { battleTag, messageType, message })
		BNSendFriendInvite(battleTag, message)
	end
end

-- battleTag or playerName, realmName if not bTag, messageType, message, token, ttl
-- target, targetRealm, 'ri', message, 'W1', 0
function ns.SendMessage(target, targetRealm, messageType, message, token, ttl)
	if not target or not message then return end
	-- if string.find(target, '#') then
	-- if not message or not target or not to_realm or to_name == '-' or (to_name == ns.playerName and to_realm == ns.playerRealm) then

	local fullMessage = strjoin(',', 'OQ', ns.OQversion, token or ns.oq.GenerateToken('W'), ttl or ns.OQmaxPosts, messageType, message)
	if not targetRealm or targetRealm == ns.playerRealm then
		SendAddonMessage("OQ", fullMessage, "WHISPER", target)
	else
		ns.SendBnetMessage(target, fullMessage, messageType)
	end
end

local playerData
function ns.JoinQueue(leader, password)
	if ns.db.queued[leader] and ns.db.queued[leader] > ns.const.status.NONE then
		-- we already requested wait list slot
		return
	end

	local target, targetRealm, battleTag = ns.oq.DecodeLeaderData(leader)
	if targetRealm == ns.playerRealm then
		if target == ns.playerName then return end
		targetRealm = nil
	else
		target = battleTag
	end

	-- prepare message
	if not playerData then
		playerData = ns.oq.EncodeLeaderData(ns.playerName, ns.playerRealm, ns.playerBattleTag)
	end

	local premadeType = ns.db.premadeCache[leader].type
	local playerStats = ns.EncodeStats(premadeType)
	local password    = ns.oq.EncodePassword(password)
	local groupSize   = 1 -- GetNumGroupMembers()

	local message     = strjoin(',', ns.db.premadeCache[leader].token, premadeType, groupSize, ns.oq.GenerateToken('Q', leader), playerData, playerStats, password)

	-- send message
	ns.SendMessage(target, targetRealm, 'ri', message, 'W1', 0)
	ns.db.queued[leader] = ns.const.status.PENDING
	ns.UpdateUI(true)
end

function ns.LeaveQueue(leader, announce)
	ns.db.queued[leader] = nil
	if announce then
		-- send message to get us out of queue
		local target, targetRealm, battleTag = ns.oq.DecodeLeaderData(leader)
		if targetRealm == ns.playerRealm then
			if target == ns.playerName then return end
			targetRealm = nil
		else
			target = battleTag
		end

		local message = strjoin(',', ns.db.premadeCache[leader].token, ns.db.tokens[leader])
		ns.SendMessage(target, targetRealm, 'leave_waitlist', message, 'W1', 0)
	end
end
