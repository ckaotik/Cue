local addonName, ns, _ = ...

function ns.PruneData()
	-- remove posts older than 2min
	local outdatedTime = time() - 2*60
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

local function SanitizeText(text)
	-- text = text:gsub('[°!"§$%?^*#]', ' ') -- :gsub('[.,+><]+', ' ')
	text = text:gsub('`´', '\''):gsub('%s+', ' ')
	-- text = text:lower():gsub('^%l', string.utf8upper):gsub(' %l', string.utf8upper) -- create common capitalization
	-- text = text:match("^[%p%s]+(.-)[%p%s]-$") or text 	-- snipe away punctuation
	text = text:trim() 					-- trim spaces, can also supply specific characters for removal
	return text
end

local function OnPremade(version, token, ttl, messageType, messageText)
	-- FIXME: not all messages include realm/from/...
	if not messageText then
		print("premade missing message", version, token, ttl, messageType, messageText)
		return
	end

	local sender, targetName, targetRealm
	-- local message, to, realm, from = messageText:match("^(.-),#to:([^,]+),#rlm:([^,]+),#fr:([^,]+)$")
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

	local raidToken, premadeTitle, premadeInfo, leaderInfo, comment, premadeType, groupData, leaderExperience = string.split(",", message)
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

	if not ns.db.premadeCache then ns.db.premadeCache = {} end
	local premadeCache = ns.db.premadeCache

	-- use leader as unique key, as every player can only ever have one premade to his or her name
	premadeCache[leaderInfo] = premadeCache[leaderInfo] or {}
	if premadeCache[leaderInfo].updated and premadeCache[leaderInfo].updated > msgTime then return end
	premadeCache[leaderInfo].token      = raidToken
	premadeCache[leaderInfo].faction    = faction
	premadeCache[leaderInfo].type       = premadeType
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

	-- print(groupData, string.format("%d |4tank:tanks;, %d |4healer:healers;, %d |4dps:dps;", tank, heal, dps))
	--[[ print('premade', premadeType, faction, SanitizeText(premadeTitle), '/', SanitizeText(comment), '/', dps, heal, tank, '/', level, iLvl, "\n",
		numMembers..' in group,', numWaiting..' waiting,',
		"\n Leader:", leaderName, realm, battleTag, leaderExperience,
		"\n", msgTime, status, minMMR, realmSpecific, hasPassword) --]]

	ns.UpdateUI()
end

local function OnWaitlistJoin(...)
	if not ns.db.queues then ns.db.queues = {} end
	-- add battleTag + reason to db
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
	["leave_waitlist"] = OnWaitlistLeave,
	["removed_from_waitlist"] = OnWaitlistLeave,
}

local function GetOQMessageInfo(message)
	local version, token, ttl, messageType, message = message:match("^OQ,([^,]+),([^,]+),([^,]+),([^,]+),(.-)$")
	return version, token, ttl, messageType, message
end

hooksecurefunc("BNSendFriendInvite", function(battleTag, message)
	local version, token, ttl, messageType, message = message:match("^OQ,([^,]+),([^,]+),([^,]+),([^,]+),(.-)$")
	if version then
		print('BNSendFriendInvite', token, messageType, "\n", message)
	end
	--[[
		oq.realid_msg( raid.leader, raid.leader_realm, raid.leader_rid,
			OQ_MSGHEADER .."".. OQ_VER ..","..
			"W1,".."0,".."ri,"..
			raid_token ..","..tostring(raid.type or 0) ..",".."1,"..req_token ..","..enc_data ..","..stats ..","..oq.encode_pword( pword ) )
	--]]
end)

-- ================================================
--  Listen for message & handle appropriately
-- ================================================
ns.RegisterEvent("CHAT_MSG_CHANNEL", function(self, event, ...)
	if InCombatLockdown() or IsInRaid() or IsRatedBattleground() then return end
	local channelName, _, _, senderGUID = select(9, ...)
	if channelName:lower() ~= "oqgeneral" then return end

	local version, token, ttl, messageType, message = GetOQMessageInfo(...)
	if messageHandler[messageType] then
		messageHandler[messageType](version, token, ttl, messageType, message)
	end
end, "oq_msg_channel")

local playerName, playerRealm = UnitName("player")
ns.RegisterEvent("CHAT_MSG_ADDON", function(self, event, prefix, msg, channel, sender)
	if prefix ~= "OQ" or sender == playerName then return end
	-- print("CHAT_MSG_ADDON", channel, sender, msg)
	local version, token, ttl, messageType, message = GetOQMessageInfo(msg)
	-- print(version, token, ttl, messageType, message)

	--[[
	channel: RAID
	message: 0Z RzcofK GywCPw stats Tîesto,263,KRBawJBAAKVBfIhoJecARtAgyCbYAkUAAAAAAAAAAAAAAAAAAAAAAZ,dimitris#2322
	--]]

	--[[ if ((prefix ~= "OQ") or (sender == player_name)) or ((msg == nil) or (msg == "")) then
		resilienceturn ;
	end
	if ((channel == "WHISPER") and oq.iam_party_leader() and (sender == oq.raid.leader) and (not OQ_toon.disabled)) then
		-- from the leader and i'm party leader, send only to my party
		oq.SendAddonMessage( "OQ", msg, "PARTY" ) ;
	end

	-- just process, do not send it on
	_local_msg = true ;
	_source    = "addon" ;
	if (channel == "PARTY") then
		_source = "party" ;
	end
	_ok2relay  = nil ;
	oq._sender = sender ;

	oq.process_msg( sender, msg ) ;
	oq.post_process() ; --]]
end, "oq_msg_addon")
