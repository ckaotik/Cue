local addonName, ns, _ = ...

local BNET_PREFIX = "(OQ)"
local playerData

-- GLOBALS: BNFeaturesEnabledAndConnected, BNConnected, BNGetInfo, BNGetNumFriends, BNGetFriendInfo, BNSetCustomMessage, BNSendFriendInvite, BNGetFriendInfoByID

-- edits the player's battle.net status to include OQ tag
function ns.EnableBnetBroadcast()
	if not BNFeaturesEnabledAndConnected() or not BNConnected() or not ns.db.useBattleNet then return end

	local _, _, _, broadcastText = BNGetInfo()
	if broadcastText == "" then
		BNSetCustomMessage(BNET_PREFIX)
	elseif not broadcastText:find(BNET_PREFIX) then
		BNSetCustomMessage( BNET_PREFIX .. " " .. broadcastText:trim() )
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

function ns.GetBNFriendInfo(searchBattleTag)
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
	local presenceID, isOnline, isWoW = ns.GetBNFriendInfo(battleTag)
	if presenceID then
		if isWoW then
			-- BNSendWhisper(presenceID, message)
		end
	else
		-- if not ns.db.sentRequests then ns.db.sentRequests = {} end
		-- ns.db.sentRequests[battleTag] = (ns.db.sentRequests[battleTag] and ns.db.sentRequests[battleTag] .. ', ' or '') .. messageType
		BNSendFriendInvite(battleTag, message)
	end
end

--[[
	-- if same target name & realm, will whisper
	-- if no target, but same realm, use oqgeneral channel
	function oq.realid_msg( to_name, to_realm, real_id, msg )
	  if (msg == nil) then
	    return ;
	  end
	  local rc = 0 ;
	  if ((to_name == nil) or (to_name == "-") or (to_realm == nil)) then
	    return ;
	  end
	  if ((to_name == player_name) and (to_realm == player_realm)) then
	    -- sending to myself?
	    return ;
	  end
	  if (not oq.well_formed_msg( msg )) then
	      local msg_tok = "W".. oq.token_gen() ;
	      oq.token_push( msg_tok ) ;
	      msg = "OQ,"..
	            OQ_VER ..","..
	            msg_tok ..","..
	            OQ_TTL ..","..
	            msg ;
	  end

	  if (to_realm == player_realm) then
	    oq.SendAddonMessage( "OQ", msg, "WHISPER", to_name ) ;
	    return ;
	  end
	end
--]]

function ns.JoinQueue(leader, token)
	if ns.db.queued[leader] and ns.db.queued[leader] == ns.const.status.PENDING then
		-- we already requested wait list slot
		return
	end

	-- prepare message
	if not playerData then
		local _, battleTag = BNGetInfo()
		local name, realm = UnitName('player'), GetRealmName('player')
		playerData = ns.oq.EncodeLeaderData(name, realm, battleTag)
	end

	--[[
	oq.realid_msg( raid.leader, raid.leader_realm, raid.leader_rid,
                   OQ_MSGHEADER ..""..
                   OQ_VER ..","..
                   "W1,"..
                   "0,"..
                   "ri,"..
                   raid_token ..","..
                   tostring(raid.type or 0) ..","..
                   "1,"..
                   "Q".. oq.token_gen() ..",".. 		-- request token
                   playerData ..","..
                   oq.encode_my_stats( 0, 0, 0, 'A', 'A' ) ..","..
                   oq.encode_pword( pword )
                 ) ;
	--]]

	-- send message

	-- store
	ns.db.queued[leader] = ns.const.status.PENDING
end

function ns.LeaveQueue(leader, announce)
	ns.db.queued[leader] = nil
	if announce then
		-- send message to get us out of queue
	end
end

-- join a premade group
function ns.JoinBnetGroup(...)
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

	-- ns.LeaveQueue(leader)

	-- if removeFriendOnJoin then ... end
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

	-- TODO: remove :)
	hooksecurefunc('BNSendFriendInvite', function(battleTag, message)
		local version, token, ttl, messageType, message = ns.GetOQMessageInfo(message)
		if version then
			print('BNSendFriendInvite', token, messageType, "\n", message)

			-- token: 		W1
			-- messageType: ri
			-- message:		G8hlBU,R,1,QAPbmw,NjI5MiNsZWFqOzQzMzt5bmFoVAAA,ARBaiIAAAI5BaIioAAAAfTARzBk9AXlAAAAAAAAAAAAAAAAAAAAAAZ,LgAA

			-- token: 		W1
			-- messageType: leave_waitlist
			-- message:		GBALcc,QCuvV9
		end
		--[[
			oq.realid_msg( raid.leader, raid.leader_realm, raid.leader_rid,
				OQ_MSGHEADER .."".. OQ_VER ..","..
				"W1,".."0,".."ri,"..
				raid_token ..","..tostring(raid.type or 0) ..",".."1,"..req_token ..","..enc_data ..","..stats ..","..oq.encode_pword( pword ) )
		--]]
	end)
end
