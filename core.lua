local addonName, ns, _ = ...

-- GLOBALS: _G, LibStub, GameTooltip, CueDB, SlashCmdList, SLASH_CUE1, SLASH_CUE2
-- GLOBALS: ToggleFrame, IsShiftKeyDown, RegisterAddonMessagePrefix, InterfaceOptionsFrame_OpenToCategory, JoinTemporaryChannel, LeaveChannelByName
-- GLOBALS: type, tostringall, assert, pairs, print
local join, format = string.join, string.format

-- ================================================
--  Event Handling
-- ================================================
local frame, eventHooks = CreateFrame("Frame", addonName.."EventHandler"), {}
local function eventHandler(frame, event, arg1, ...)
	if event == 'ADDON_LOADED' and arg1 == addonName then
		-- make sure we always init before any other module
		ns.Initialize()
		if not eventHooks[event] or ns.Count(eventHooks[event]) < 1 then
			frame:UnregisterEvent(event)
		end
	end

	if eventHooks[event] then
		for id, listener in pairs(eventHooks[event]) do
			listener(frame, event, arg1, ...)
		end
	end
end
frame:SetScript("OnEvent", eventHandler)
frame:RegisterEvent("ADDON_LOADED")

function ns.RegisterEvent(event, callback, id, silentFail)
	assert(callback and event and id, format("Usage: RegisterEvent(event, callback, id[, silentFail])"))
	if not eventHooks[event] then
		eventHooks[event] = {}
		frame:RegisterEvent(event)
	end
	assert(silentFail or not eventHooks[event][id], format("Event %s already registered by id %s.", event, id))

	eventHooks[event][id] = callback
end
function ns.UnregisterEvent(event, id)
	if not eventHooks[event] or not eventHooks[event][id] then return end
	eventHooks[event][id] = nil
	if ns.Count(eventHooks[event]) < 1 then
		eventHooks[event] = nil
		frame:UnregisterEvent(event)
	end
end

-- ================================================
--  Basic Setup
-- ================================================
function ns.Initialize()
	local LDB = LibStub("LibDataBroker-1.1")
	local ldb = LDB:GetDataObjectByName(addonName)
	if not ldb then
		ldb = LDB:NewDataObject(addonName, {
			type  = "launcher",
			icon  = "Interface\\Icons\\Achievement_BG_KillXEnemies_GeneralsRoom",
			label = addonName
		})
	end
	ldb.OnClick = function(self, button)
		if button == "RightButton" then
			-- open config
			InterfaceOptionsFrame_OpenToCategory(addonName)
		elseif IsShiftKeyDown() then
			ns.Toggle()
		else
			ns.InitUI()
			ToggleFrame(_G["CueFrame"])
			ns.UpdateUI()
		end
	end

	RegisterAddonMessagePrefix("OQ")
	ns.PreventBnetSpam()

	ns.playerName  = UnitName("player")
	ns.playerRealm = ns.GetRealmInfoByName( GetRealmName() )
	_, ns.playerBattleTag = BNGetInfo()
	ns.playerBattleTag = string.lower(ns.playerBattleTag)

	if not CueDB then CueDB = {} end
	ns.db = CueDB

	if not ns.db.queued then ns.db.queued = {} end 				-- tracks groups we've requested to join
	if not ns.db.blacklist then ns.db.blacklist = {} end 		-- tracks leaders' battletags we don't want to group with
	if not ns.db.bntracking then ns.db.bntracking = {} end 		-- tracks requests sent as BN friend invite
	if not ns.db.premadeCache then ns.db.premadeCache = {} end 	-- tracks groups that are currently available
	if not ns.db.tokens then ns.db.tokens = {} end 				-- tracks generated, sent request tokens

	SLASH_CUE1 = '/cue'
	SLASH_CUE2 = '/queue'
	SlashCmdList['CUE'] = function(msg)
		ns.InitUI()
		ns.UpdateUI()
		ToggleFrame(_G["CueFrame"])
	end

	ns.Enable()

	-- expose
	_G[addonName] = ns
end

local AceTimer = LibStub("AceTimer-3.0")
local pruneData

local enabled = nil
function ns.Enable()
	JoinTemporaryChannel('oqgeneral')
	ns.EnableBnetBroadcast()
	frame:Show() -- start listening for events
	enabled = true

	ns.PruneData()
	pruneData = AceTimer:ScheduleRepeatingTimer(ns.PruneData, 60)
end

function ns.Disable()
	LeaveChannelByName('oqgeneral')
	ns.DisableBnetBroadcast()
	frame:Hide()
	enabled = nil

	AceTimer:CancelTimer(pruneData)
end

function ns.Toggle()
	if enabled then
		ns.Print('Cue is disabled')
		ns.Disable()
	else
		ns.Print('Cue is enabled')
		ns.Enable()
	end
end

-- ================================================
--  Little Helpers
-- ================================================
function ns.Print(text, ...)
	if ... and text:find("%%[ds123456789]+") then
		text = format(text, ...)
	elseif ... then
		text = join(", ", tostringall(text, ...))
	end
	print("|cffE01B5D"..addonName.."|r "..text)
end

function ns.Debug(...)
  if true then
	ns.Print("! "..join(", ", tostringall(...)))
  end
end

-- counts table entries. for numerically indexed tables, use #table
function ns.Count(table)
	if not table or type(table) ~= "table" then return 0 end
	local i = 0
	for _ in pairs(table) do
		i = i + 1
	end
	return i
end

function ns.Find(where, what)
	for k, v in pairs(where) do
		if v == what then
			return k
		end
	end
end

function ns.ShowTooltip(self)
	if not self.tiptext and not self.link then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()

	if self.link then
		GameTooltip:SetHyperlink(self.link)
	elseif type(self.tiptext) == "string" and self.tiptext ~= "" then
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	elseif type(self.tiptext) == "function" then
		self.tiptext(self, GameTooltip)
	end
	GameTooltip:Show()
end
function ns.HideTooltip() GameTooltip:Hide() end
