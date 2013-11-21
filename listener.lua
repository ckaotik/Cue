local addonName, ns, _ = ...
local DATA_TIMEOUT = 2*60

-- GLOBALS: IsInRaid, IsRatedBattleground, InCombatLockdown
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
	for token, info in pairs(ns.db.premadeCache) do
		if info.updated < outdatedTime then
			wipe(info)
			ns.db.premadeCache[token] = nil
		end
	end

	ns.UpdateUI()
	if not InCombatLockdown() then
		collectgarbage()
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
	premadeCache[leaderInfo].size       = numMembers
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

	local leaderName, leaderRealm, removed
	for leader, data in pairs(ns.db.premadeCache) do
		if data.token == raidToken then
			wipe(ns.db.premadeCache[leader])
			ns.db.premadeCache[leader] = nil

			removed = true
			break
		elseif sender and sender ~= '' then
			leaderName, leaderRealm = ns.oq.DecodeLeaderData(leader)
			if leaderName..'-'..leaderRealm == sender then
				wipe(ns.db.premadeCache[leader])
				ns.db.premadeCache[leader] = nil

				removed = true
				break
			end
		end
	end

	if not removed then
		--
	end
end

local function OnWaitlistJoin(...)
	-- if not ns.db.queued[ battleTag ] then ns.db.queued[ battleTag ] = {} end
	-- add battleTag + reason/note to db
end

local function OnWaitlistLeave(raidToken, reqToken)
	--
end

--[[
	oq.party_announce( "party_join,"..
		my_group ..","..
		oq.encode_name( oq.raid.name ) ..","..
		oq.raid.leader_class ..","..
		enc_data ..","..
		oq.raid.raid_token  ..","..
		oq.encode_note( oq.raid.notes )
	)
	CHAT_MSG_ADDON / PARTY: "OQ,".. OQ_VER ..",".. "P".. oq.token_gen() ..",".. oq.raid.raid_token ..",".. msg

	bb = oq.on_thebook ; -- was "thebook"
	boss = oq.on_boss ;
	brb = oq.on_brb ;
	btag = oq.on_btag ;
	btags = oq.on_btags ;
	charm = oq.on_charm ;
	contract = oq.on_bounty ; -- was "bounty"
	disband = oq.on_disband ;
	enter_bg = oq.on_enter_bg ;
	find = oq.queue_find_request ;
	fog = oq.fog_new_data ;
	group_hp = oq.on_group_hp ;
	gs = oq.on_grp_stats ;  -- changed from "grp_stats"
	iam_back = oq.on_iam_back ;
	identify = oq.on_identify ;
	imesh = oq.on_imesh ;
	invite_accepted = oq.on_invite_accepted ;
	invite_group = oq.on_invite_group ;
	invite_group_lead = oq.on_invite_group_lead ;
	invite_req_response= oq.on_invite_req_response ;
	join = oq.on_join ;
	k2 = oq.on_karma ;
	lag_times = oq.on_lag_times ;
	leave = oq.on_leave ;
	leave_queue = oq.on_leave_queue ;
	leave_slot = oq.on_leave_slot ;
	mbox_bn_enable = oq.on_mbox_bn_enable ;
	member = oq.on_member ;
	mesh_tag = oq.on_mesh_tag ;
	name = oq.on_name ;
	need_btag = oq.on_need_btag ;
	new_lead = oq.on_new_lead ;
	oq_version = oq.on_oq_version ;
	party_join = oq.on_party_join ;
	party_msg = oq.on_party_msg ;
	party_names = oq.on_party_names ;
	party_slot = oq.on_party_slot ;
	party_slots = oq.on_party_slots ;
	party_update = oq.on_party_update ;
	pass_lead = oq.on_pass_lead ;
	ping = oq.on_ping ;
	ping_ack = oq.on_ping_ack ;
	premade_note = oq.on_premade_note ;
	promote = oq.on_promote ;
	proxy_invite = oq.on_proxy_invite ;
	proxy_target = oq.on_proxy_target ;
	queue_tm = oq.on_queue_tm ;
	raid_join = oq.on_raid_join ;
	ready_check = oq.on_ready_check ;
	ready_check_complete= oq.on_ready_check_complete ;
	remove = oq.on_remove ;
	remove_group = oq.on_remove_group ;
	report_recvd = oq.on_report_recvd ;
	req_mesh = oq.on_req_mesh ;
	ri = oq.on_req_invite ; -- was "req_invite"
	role_check = oq.on_role_check ;
	scores = oq.on_scores ;
	stats = oq.on_stats ;
	top_dps_recvd = oq.on_top_dps_recvd ;
	top_heals_recvd = oq.on_top_heals_recvd ;
	v8 = oq.on_vlist ;

	oq.bg_msgids                = {} ;
	oq.bg_msgids[ "boss"            ] = 1 ;
	oq.bg_msgids[ "contract"        ] = 1 ; -- was "bounty"
	oq.bg_msgids[ "pass_lead"       ] = 1 ;
	oq.bg_msgids[ "p8"              ] = 1 ;
	oq.bg_msgids[ "fog"             ] = 1 ;
	oq.bg_msgids[ "k2"              ] = 1 ;
	oq.bg_msgids[ "report_recvd"    ] = 1 ;
	oq.bg_msgids[ "bb"              ] = 1 ;  -- was "thebook"
	oq.bg_msgids[ "top_dps_recvd"   ] = 1 ;
	oq.bg_msgids[ "top_heals_recvd" ] = 1 ;
	oq.bg_msgids[ "v8"              ] = 1 ;
--]]
local messageHandler = {
	["p8"] = OnPremade,
	["disband"] = OnDisband,
	-- ["ri"] = OnWaitlistJoin,
	["leave_waitlist"]        = OnWaitlistLeave,
	["removed_from_waitlist"] = OnWaitlistLeave,
}

-- ================================================
--  Listen for message & handle appropriately
-- ================================================
ns.RegisterEvent("CHAT_MSG_CHANNEL", function(self, event, ...)
	if InCombatLockdown() or IsInRaid() or IsRatedBattleground() then return end
	local channelName, _, _, senderGUID = select(9, ...)
	if channelName:lower() ~= "oqgeneral" then return end

	local version, token, ttl, messageType, message = ns.GetOQMessageInfo(...)
	if messageType and messageHandler[messageType] then
		messageHandler[messageType](version, token, ttl, messageType, message)
	end
end, "oq_msg_channel")

ns.RegisterEvent("CHAT_MSG_BN_WHISPER", function(self, event, ...)
	if InCombatLockdown() or IsInRaid() or IsRatedBattleground() then return end
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

-- probably also BN_FRIEND_INVITE_LIST_INITIALIZED
ns.RegisterEvent("BN_FRIEND_INVITE_ADDED", function(self, event, ...)
	print('new friend request', ...)
	for i = BNGetNumFriendInvites(), 1 do
		-- local presenceId, name, surname, message, timeSent, days = BNGetFriendInviteInfo(i)
		print('friend', i, BNGetFriendInviteInfo(i))
	end
end, "newfriendreq")
