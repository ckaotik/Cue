local addonName, ns, _ = ...

local BNET_PREFIX = "(OQ)"

-- GLOBALS: BNFeaturesEnabledAndConnected, BNConnected, BNGetInfo, BNGetNumFriends, BNGetFriendInfo, BNSetCustomMessage, BNSendFriendInvite, BNGetFriendInfoByID

-- edits the player's battle.net status to include OQ tag
function ns.EnableBnetBroadcast()
	if not BNFeaturesEnabledAndConnected() or not BNConnected() or not ns.db.useBattleNet then return end

	local _, _, _, broadcastText = BNGetInfo()
	if broadcastText == "" then
		BNSetCustomMessage(BNET_PREFIX)
	elseif not broadcastText:find(BNET_PREFIX) then
		BNSetCustomMessage(BNET_PREFIX .. " " .. broadcastText:trim())
	end
end

-- removes OQ tag from player's battle.net status
function ns.DisableBnetBroadcast()
	if not BNConnected() or not ns.db.useBattleNet then return end

	local _, _, _, broadcastText = BNGetInfo()
	if broadcastText:find(BNET_PREFIX) then
		local message = broadcastText:gsub(BNET_PREFIX, ""):trim()
		BNSetCustomMessage(message)
	end

	-- if removeAddedFriends then ... end
end

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

-- big credits to nefftd@wowinterface
function ns.PreventBnetSpam()
	-- Pull in constants from BNet.lua
	local BN_TOAST_TYPE_ONLINE = 1
	local BN_TOAST_TYPE_OFFLINE = 2
	local BN_TOAST_TYPE_BROADCAST = 3
	local BN_TOAST_TYPE_PENDING_INVITES = 4
	local BN_TOAST_TYPE_NEW_INVITE = 5
	local BN_TOAST_TYPE_CONVERSATION = 6

	hooksecurefunc('BNToastFrame_AddToast', function(toastType, toastData)
		-- hide (OQ) message toasts
		-- hide automated Friend Request Sent/Received toast
		if toastType == BN_TOAST_TYPE_NEW_INVITE then
			--
		elseif toastType == BN_TOAST_TYPE_BROADCAST then
			local presenceID, givenName, surname, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, broadcastTime, canSoR = BNGetFriendInfoByID(toastData)
			-- local _, toonName, client = BNGetToonInfo(presenceID)

			-- if messageText:match('BLOCK') then  -- check if the message contains 'BLOCK'
				-- BNToastFrame_RemoveToast(toastType, toastData)  -- VOILA!
			-- end
		end
	end)
end

-- TODO: remove :)
--[[ hooksecurefunc('BNSendFriendInvite', function(battleTag, message)
	local version, token, ttl, messageType, message = ns.GetOQMessageInfo(message)
	if version then
		print('BNSendFriendInvite', battleTag, token, ttl, messageType, "\n", message)
	end
end) --]]
