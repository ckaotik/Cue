local addonName, ns, _ = ...

function ns.Initialize()
	ns.ldb = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
		type  = "launcher",
		icon  = "Interface\\Icons\\Achievement_BG_KillXEnemies_GeneralsRoom",
		label = addonName,

		OnClick = function(self, button)
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
		end,
	})

	RegisterAddonMessagePrefix("OQ")
	ns.PreventBnetSpam()

	if not CueDB then CueDB = {} end
	ns.db = CueDB

	if not ns.db.queued then ns.db.queued = {} end
	if not ns.db.blacklist then ns.db.blacklist = {} end

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
	enabled = true

	ns.PruneData()
	pruneData = AceTimer:ScheduleRepeatingTimer(ns.PruneData, 60)
end

function ns.Disable()
	LeaveChannelByName('oqgeneral')
	ns.DisableBnetBroadcast()
	enabled = nil

	AceTimer:CancelTimer(pruneData)
end

function ns.Toggle()
	if enabled then
		ns.Disable()
	else
		ns.Enable()
	end
end

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
--  Little Helpers
-- ================================================
function ns.Print(text, ...)
	if ... and text:find("%%[ds123456789]") then
		text = format(text, ...)
	elseif ... then
		text = join(", ", tostringall(text, ...))
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cffE01B5DTwinkle|r "..text)
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
