local addonName, ns, _ = ...

local BNET_PREFIX = "(OQ)"

-- GLOBALS: BNFeaturesEnabledAndConnected, BNConnected, BNGetInfo, BNGetNumFriends, BNGetFriendInfo, BNSetCustomMessage, BNSendFriendInvite, BNGetFriendInfoByID

function ns.GetBnetFriendInfo(searchBattleTag)
	searchBattleTag = searchBattleTag:lower()
	for i = 1, BNGetNumFriends() do
		local presenceID, _, battleTag, _, _, _, client, isOnline = BNGetFriendInfo(i)
		if battleTag and battleTag:lower() == searchBattleTag then
			return presenceID, isOnline, client == 'WoW'
		end
	end
end

-- battleTag or playerName, realmName or true to force sending to BNet, messageType, message, token, ttl
function ns.SendMessage(target, targetRealm, messageType, message, token, ttl)
	if not target or not message then return end
	local fullMessage = strjoin(',', 'OQ', ns.OQversion, token or ns.oq.GenerateToken('W'), ttl or ns.OQmaxPosts, messageType, message)

	if targetRealm == true or (targetRealm ~= nil and targetRealm ~= ns.playerRealm) then
		local presenceID
		if type(target) == 'number' then
			-- this is already the toon's id
			presenceID = target
		elseif target:find('#') then
			-- get presenceID from battleTag
			local isOnline, isWow
			presenceID, isOnline, isWow = ns.GetBnetFriendInfo(target)
		end

		print('Sending message to', presenceID, target, "\n".._G.GRAY_FONT_COLOR_CODE..fullMessage.."|r")
		if presenceID then
			BNSendGameData(presenceID, 'OQ', fullMessage)
		else
			table.insert(ns.db.bntracking, { target, messageType, fullMessage })
			BNSendFriendInvite(target, fullMessage)
		end
	else
		SendAddonMessage('OQ', fullMessage, 'WHISPER', target)
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
	-- ns.SendMessage(target, targetRealm, 'ri', message, 'W1', 0)
	ns.SendMessage(battleTag, true, 'ri', message, 'W1', 0)
	ns.db.queued[leader] = ns.const.status.PENDING
	ns.UpdateUI(true)
end

function ns.LeaveQueue(leader, announce)
	local target, targetRealm, battleTag = ns.oq.DecodeLeaderData(leader)
	if announce then
		-- send message to get us out of queue
		if targetRealm == ns.playerRealm then
			if target == ns.playerName then return end
			targetRealm = nil
		else
			target = battleTag
		end

		local message = strjoin(',', ns.db.premadeCache[leader].token, ns.db.tokens[leader])
		ns.SendMessage(target, targetRealm, 'leave_waitlist', message, 'W1', 0)
	else
		ns.db.queued[leader] = nil

		local presenceID = ns.GetBnetFriendInfo(battleTag)
		if presenceID then
			local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend = BNGetFriendInfoByID(presenceID)
			if isBattleTagPresence and isRIDFriend and (noteText == 'OQ' or noteText == 'OQ,leader') then
				BNRemoveFriend(presenceID) -- or toonID
			end
		end
	end
end
