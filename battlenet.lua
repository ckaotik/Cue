local addonName, ns, _ = ...
local BNET_PREFIX = "(OQ)"

-- edits the player's battle.net status to include OQ tag
function ns.EnableBnetBroadcast()
	if not BNConnected() or not ns.db.useBattleNet then return end

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

-- send a message across battle.net via private message -or- friend request + note
function ns.SendBnetMessage(battleTag, message, messageType)
	if false and IsBnetFriend(battleTag) then
		-- TODO: figure out presenceID if online
		-- BNSendWhisper(target, message)
	else
		if not ns.db.sentRequests then ns.db.sentRequests = {} end
		ns.db.sentRequests[battleTag] = (ns.db.sentRequests[battleTag] and ns.db.sentRequests[battleTag] .. ', ' or '') .. messageType
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

-- join a premade group
function ns.JoinBnetGroup(...)
	--

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

			if messageText:match('BLOCK') then  -- check if the message contains 'BLOCK'
				-- BNToastFrame_RemoveToast(toastType, toastData)  -- VOILA!
			end
		end
	end)
end
