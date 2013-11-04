local addonName, ns, _ = ...

-- GLOBALS: _G, UIParent, GRAY_FONT_COLOR_CODE, RED_FONT_COLOR_CODE, COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN, MAX_PLAYER_LEVEL, SEARCH
-- GLOBALS: CreateFrame, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_Update, FauxScrollFrame_GetOffset, SetPortraitToTexture, UnitLevel, GetAverageItemLevel, GetCombatRating, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton, UIDropDownMenu_SetText, UIDropDownMenu_SetWidth, ToggleDropDownMenu, BNSendFriendInvite, IsIgnored, EditBox_ClearFocus, ChatFrame_SendSmartTell
-- GLOBALS: table, string, math, tonumber, wipe, pairs, ipairs, time

local tank   = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t"
local healer = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t"
local dps    = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t"

local playerFaction = UnitFactionGroup("player")
function ns.UpdateUI()
	-- dummy until UI has been initialized
end

function ns.InitUI()
	if _G['CueFrame'] then return end

	-- UI filters
	local filters = {
		types = {},
	}
	local function MatchesFilters(data)
		local name, realm, battleTag = ns.oq.DecodeLeaderData( data.leader )
		local _, realm, locale = ns.GetRealmInfoFromID(realm)
		local isBlocked = ns.Find(ns.db.blacklist, battleTag) or IsIgnored(name.."-"..realm)
		if isBlocked then return nil end

		-- TODO: could probably be done by CustomSearch, too
		local premadeType = data.type
		if ns.Count( filters.types ) > 0 then
			local pass = false
			for filter, _ in pairs(filters.types) do
				if ns.const.type[ filter ] == premadeType then
					pass = true
					break
				end
			end
			if not pass then return nil end
		end

		if filters.search then
			if not ns.Find(data, filters.search) then
				return nil
			end
		end

		if filters.qualified then
			local playerLevel = UnitLevel("player")
			local level = ns.const.level[ data.level ] or MAX_PLAYER_LEVEL
			local min, max = string.match(level, "^(%d+)%D*(%d*)$")
			      max = max ~= '' and max or min

			if playerLevel < tonumber(min) or playerLevel > tonumber(max) then
				return nil
			end
			if data.ilvl > 0 and (GetAverageItemLevel()) < data.ilvl then
				return nil
			end
			if data.resilience > 0 and GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN) < data.resilience then
				return nil
			end
		end

		return data.faction == playerFaction
	end

	local function UpdateData(self)
		wipe(self.data)
		local numDisplayed, numTotal = 0, 0
		for leader, info in pairs(ns.db.premadeCache) do
			numTotal = numTotal + 1
			if MatchesFilters(info) then
				numDisplayed = numDisplayed + 1
				table.insert(self.data, leader)
			end
		end
		return numDisplayed, numTotal
	end

	local currentSortBy, currentSortReverse = 2, false
	local sortables = {
		{ 'level', 'resilience', 'ilvl' },
		{ 'title', 'comment' },
		{ 'size', 'waiting' },
	}
	local function SortData(a, b)
		local aData = ns.db.premadeCache[a]
		local bData = ns.db.premadeCache[b]

		for _, attribute in ipairs( sortables[currentSortBy] ) do
			if aData[attribute] ~= bData[attribute] then
				if currentSortReverse then
					return aData[attribute] > bData[attribute]
				else
					return aData[attribute] < bData[attribute]
				end
			end
		end

		-- fallback, sort by key
		return a < b
	end
	local function OnSorterClick(self, btn)
		local newSort = self:GetID()
		if newSort == currentSortBy then
			currentSortReverse = not currentSortReverse
		else
			currentSortReverse = false
		end
		currentSortBy = newSort
		ns.UpdateUI(true)
	end

	local function ShowPremadeTooltip(self, tooltip)
		if not self.key then return end
		local data = ns.db.premadeCache[ self.key ]

		local leaderName, realm, battleTag = ns.oq.DecodeLeaderData(data.leader)
		if not realm then return end

		local realmID, realmName, locale, isPvP, isRP, battleGroup = ns.GetRealmInfoFromID(realm)
		if not realmName then print("no realm info found for", realm, leaderName); realmName = '?' end

		tooltip:AddDoubleLine(leaderName, string.format("%s%s%s (%s)",
			isRP and '' or '',
			isPvP and "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t" or '',
			realmName,
			locale and string.sub(locale, 0, 2) or '?'
		))

		if data.group then
			tooltip:AddLine(nil)
			tooltip:AddLine(string.format(-- "%d |4tank:tanks;, %d |4healer:healers;, %d |4dps:dps;",
				"%d%s %d%s %d%s",
				data.group.tank, tank, data.group.heal, healer, data.group.dps, dps))
		end

		if ns.db.queued and ns.db.queued[ data.leader ] then
			local status = ns.db.queued[ data.leader ]
			if status == ns.const.status.PENDING then
				tooltip:AddLine('You have asked the leader for a queue slot')
			elseif status == ns.const.status.QUEUED then
				tooltip:AddLine('You are queued for this group')
			elseif status == ns.const.status.GROUPED then
				tooltip:AddLine('This is your current group')
			end
		end
	end

	local frame = CreateFrame("Frame", "CueFrame", UIParent, "PortraitFrameTemplate")
	frame:Hide()
	frame:EnableMouse()

	frame:SetAttribute("UIPanelLayout-defined", true)
	frame:SetAttribute("UIPanelLayout-enabled", true)
	frame:SetAttribute("UIPanelLayout-whileDead", true)
	frame:SetAttribute("UIPanelLayout-area", "left")
	frame:SetAttribute("UIPanelLayout-pushable", 5)

	SetPortraitToTexture(frame.portrait, "Interface\\Icons\\Achievement_BG_KillXEnemies_GeneralsRoom")
	frame.TitleText:SetText(addonName)

	-- header inset, containing filters
	local header = CreateFrame("Frame", "$parentHeader", frame, "InsetFrameTemplate")
	header:SetPoint("TOPLEFT", 2, -20)
	header:SetPoint("BOTTOMRIGHT", "$parent", "TOPRIGHT", -4, -20 - 60)
	header:SetFrameLevel(1) -- move below portrait level

	-- filters
	local headerText = header:CreateFontString(nil, nil, "GameFontNormalLarge")
	      headerText:SetPoint("TOPLEFT", 58, -6)
	      headerText:SetText(_G['FILTERS'])

	local qualified = CreateFrame("CheckButton", nil, header, "UICheckButtonTemplate")
	      qualified:SetPoint("BOTTOMLEFT", 6, 2)
	      qualified:SetSize(24, 24)
	      qualified.text:SetText(_G['AVAILABLE'])
	qualified:SetScript("OnClick", function(self, btn)
		filters.qualified = not filters.qualified and true or nil
		ns.UpdateUI(true)
	end)

	local typeDropDown = CreateFrame("Frame", "$parentPremadeDropDown", header, "UIDropDownMenuTemplate")
	      typeDropDown:SetPoint("TOPRIGHT", -36, -6)
	UIDropDownMenu_SetText(typeDropDown, _G['LFG_TITLE'] .. '...')
	UIDropDownMenu_SetWidth(typeDropDown, 140, 0)

	local function ToggleType(self)
		filters.types[ self.value ] = not filters.types[ self.value ] and true or nil
		ns.UpdateUI(true)
	end
	typeDropDown.initialize = function(self, level, menuList)
		local lvl = level or 1
		local info = UIDropDownMenu_CreateInfo()
		      info.isNotRadio   = true
		      info.func         = ToggleType
		      info.keepShownOnClick = true

		for _, data in ipairs(ns.const.typeLabels) do
			if data[1] == '' then
				info.isTitle = true
				info.notCheckable = true
				info.value    = nil
			else
				info.isTitle  = nil
				info.disabled = nil
				info.notCheckable = nil
				info.checked  = filters.types[ data[1] ]
				info.value    = data[1]
			end
			info.text     = data[2]
			UIDropDownMenu_AddButton(info, lvl)
		end
	end

	local searchbox = CreateFrame("EditBox", "$parentSearchBox", header, "SearchBoxTemplate")
		searchbox:SetPoint("TOPRIGHT", typeDropDown, "BOTTOMRIGHT", 34, 2)
		searchbox:SetSize(150, 20)
		searchbox:SetScript("OnEnterPressed", EditBox_ClearFocus)
		searchbox:SetScript("OnEscapePressed", function(self)
			self:SetText(SEARCH)
			EditBox_ClearFocus(self)
			ns.UpdateUI(true)
		end)
		searchbox:SetScript("OnTextChanged", function(self)
			local oldText, text = filters.search, self:GetText()
			if oldText == text then return end
			filters.search = (text ~= "" and text ~= SEARCH) and string.lower(text) or nil
			ns.UpdateUI(true)
		end)
		searchbox.tiptext = [[Use & (and) and | (or) to combine queries.
  r - realm
  l - leader
  g - group size
  w - wait list
example: flex & r:en & l:athene & g:> 9 & w:< 10]]
		searchbox:SetScript("OnEnter", ns.ShowTooltip)
		searchbox:SetScript("OnLeave", ns.HideTooltip)
	header.search = searchbox

	-- table headers
	local requirement = frame:CreateFontString(nil, nil, "GameFontNormal")
	      requirement:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 6, -8)
	      requirement:SetWidth(34)
	      requirement:SetJustifyH("CENTER")
	      requirement:SetText(_G['LEVEL_ABBR'])
	local toggle = CreateFrame("Button", nil, frame, nil, 1)
	      toggle:SetAllPoints(requirement)
	      toggle:SetScript('OnClick', OnSorterClick)
	requirement.toggle = toggle

	local information = frame:CreateFontString(nil, nil, "GameFontNormal")
	      information:SetPoint("TOPLEFT", requirement, "TOPRIGHT", 4, 0)
	      information:SetWidth(200)
	      information:SetJustifyH("LEFT")
	      information:SetText(_G['QUEST_DESCRIPTION'])
	local toggle = CreateFrame("Button", nil, frame, nil, 2)
	      toggle:SetAllPoints(information)
	      toggle:SetScript('OnClick', OnSorterClick)
	information.toggle = toggle

	local group = frame:CreateFontString(nil, nil, "GameFontNormal")
	      group:SetPoint("TOPLEFT", information, "TOPRIGHT", 4, 2)
	      group:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
	      group:SetJustifyH("LEFT")
	      group:SetText(_G['GROUP'])
	      	-- "|TInterface\\FriendsFrame\\UI-Toast-ToastIcons.tga:16:16:0:0:128:64:2:29:34:61|t"
	local toggle = CreateFrame("Button", nil, frame, nil, 3)
	      toggle:SetAllPoints(group)
	      toggle:SetScript('OnClick', OnSorterClick)
	group.toggle = toggle

	local function UpdateHeaders(numDisplayed, numTotal)
		information:SetFormattedText('%s (%d/%d)', _G['QUEST_DESCRIPTION'], numDisplayed, numTotal)
	end

	-- list inset, containing premade rows
	local listFrame = CreateFrame("Frame", "$parentBody", frame, "InsetFrameTemplate")
	listFrame:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2 - 24)
	listFrame:SetPoint("BOTTOMRIGHT", "$parent", "BOTTOMRIGHT", -4, 4)

	local rowHeight = 30
	local list = CreateFrame("ScrollFrame", "$parentList", listFrame, "FauxScrollFrameTemplate")
	list:SetPoint("TOPLEFT", "$parent", "TOPLEFT", 4, -4)
	list:SetPoint("BOTTOMRIGHT", "$parent", "BOTTOMRIGHT", -4, -4)
	list.scrollBarHideable = true

	list.buttons = {}
	list.data = {}

	local function LeaveQueue(button, leader) ns.LeaveQueue(leader) end
	local function AddBNFriend(button, battleTag) BNSendFriendInvite(battleTag) end
	local function Whisper(button, battleTag) ChatFrame_SendSmartTell(battleTag) end
	local function BanLeader(button, battleTag) table.insert(ns.db.blacklist, battleTag) end
	local dropDown = CreateFrame("Frame", "$parentPremadeDropDown", frame, "UIDropDownMenuTemplate")
	dropDown.displayMode = "MENU"
	dropDown.initialize = function(self, level, menuList)
		print('init', level, menuList, self.key)
		local lvl = level or 1
		local info = UIDropDownMenu_CreateInfo()

		info.text = "Cue"
		info.isTitle      = true
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, lvl)

		info.isTitle  = nil
		info.disabled = nil

		if ns.db.queued[ self.key ] then
			info.text     = "Leave queue"
			info.func     = LeaveQueue
			info.arg1     = self.key
			UIDropDownMenu_AddButton(info, lvl)
		end

		local name, _, battleTag = ns.oq.DecodeLeaderData( self.key )
		if ns.IsBnetFriend(battleTag) then -- isFriend
			info.text = _G["WHISPER"]
			info.func = Whisper
			info.arg1 = battleTag
			UIDropDownMenu_AddButton(info, lvl)
		else
			-- add battle tag friend
			info.text = _G["SEND_BATTLETAG_REQUEST"]
			info.func = AddBNFriend
			info.arg1 = battleTag
			UIDropDownMenu_AddButton(info, lvl)
		end

		-- _G["REPORT_PLAYER_FOR"] / REPORT_SPAMMING, REPORT_BAD_NAME, REPORT_BAD_LANGUAGE, REPORT_CHEATING
		info.text = "Add leader to blacklist"
		info.func = BanLeader
		info.arg1 = battleTag
		UIDropDownMenu_AddButton(info, lvl)
	end

	local function PremadeOnClick(self, btn)
		if btn == "RightButton" then
			dropDown.key = self.key
			ToggleDropDownMenu(nil, nil, dropDown, "cursor", 3, -3)
		else
			--
		end
	end

	for i = 1, 10 do
		local row = CreateFrame("Button", nil, listFrame, nil, i)
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight") -- "Interface\\Buttons\\UI-Common-MouseHilight")
		row:SetHeight(rowHeight)
		row:Hide()

		local background = row:CreateTexture(nil, "BACKGROUND")
		      background:SetPoint("TOPLEFT", row, "TOPLEFT")
		      background:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 2)
		      background:SetTexture(0.588, 0.588, 0.588, 0.3)
		row.background = background

		row:SetPoint("RIGHT", list, "RIGHT", 2, 0)
		if i == 1 then
			row:SetPoint("TOPLEFT", list, "TOPLEFT")
		else
			row:SetPoint("TOPLEFT", list.buttons[i-1], "BOTTOMLEFT", 0, 0)
		end

		row:RegisterForClicks("AnyUp")
		row:SetScript("OnClick", PremadeOnClick)
		row:SetScript("OnEnter", ns.ShowTooltip)
		row:SetScript("OnLeave", ns.HideTooltip)
		row.tiptext = ShowPremadeTooltip

		local level = row:CreateFontString(nil, nil, "GameFontHighlight")
		      level:SetPoint("LEFT", 2, 0)
		      level:SetWidth(34)
		      level:SetJustifyH("CENTER")
		row.level = level

		local title = row:CreateFontString(nil, nil, "FriendsFont_Normal") -- GameFontHighlight")
		      title:SetPoint("LEFT", level, "RIGHT", 4, 0)
		      title:SetPoint("TOP", row, 0, -3)
		      title:SetJustifyH("LEFT")
		      title:SetSize(200, 12)
		row.title = title

		local comment = row:CreateFontString(nil, nil, "FriendsFont_Small") -- GameFontHighlight")
		      comment:SetPoint("TOPLEFT",  title, "BOTTOMLEFT",  0, -2)
		      comment:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 0, -2)
		      comment:SetJustifyH("LEFT")
		      comment:SetHeight(10)
		      comment:SetVertexColor(0.486, 0.518, 0.541)
		row.comment = comment

		local waiting = row:CreateFontString(nil, nil, "GameFontHighlight")
		      waiting:SetPoint("TOPLEFT", title, "TOPRIGHT", 4, 0)
		      waiting:SetPoint("BOTTOM", 0, 2)
		      waiting:SetJustifyH("LEFT")
		      waiting:SetWidth(36)
		row.waiting = waiting

		local group = row:CreateFontString(nil, nil, "GameFontHighlight")
		      group:SetPoint("TOPLEFT",    waiting, "TOPRIGHT",    4, 0)
		      group:SetPoint("BOTTOMLEFT", waiting, "BOTTOMRIGHT", 4, 0)
		      group:SetPoint("RIGHT")
		      group:SetJustifyH("CENTER")
		row.group = group

		list.buttons[i] = row
	end

	local function UpdateRows(self)
		local offset = FauxScrollFrame_GetOffset(self)

		-- local avgItemLvl = GetAverageItemLevel()
		-- local resilienceRating = GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
		-- local playerLevel = UnitLevel("player")

		for i = 1, #self.buttons do
			local row = self.buttons[i]
			local index = i + offset

			local data = self.data[index]
			if data then data = ns.db.premadeCache[ data ] end

			if data then
				row.key = self.data[index]

				if data.resilience > 0 then
					-- local isLow = resilienceRating < data.resilience
					row.level:SetFormattedText("%s%s", --[[isLow and RED_FONT_COLOR_CODE or --]] '', data.resilience)
				elseif data.ilvl > 0 then
					-- local isHigh = avgItemLvl < data.ilvl
					row.level:SetFormattedText("%s%s", --[[isHigh and RED_FONT_COLOR_CODE or --]] '', data.ilvl)
				else
					local level = ( ns.const.level[ data.level ] or ''):match("%d+$") or ''
					      level = tonumber(level) or MAX_PLAYER_LEVEL
					row.level:SetFormattedText("%s%s", --[[(level < playerLevel and GRAY_FONT_COLOR_CODE) or (level > playerLevel and RED_FONT_COLOR_CODE) or--]] '', level ~= math.huge and level or '' )
				end

				row.title:SetText(data.title)
				row.comment:SetText(data.comment)

				row.group:SetText(data.size)
				if data.waiting and data.waiting > 0 then
					row.waiting:SetText('|TInterface\\FriendsFrame\\StatusIcon-Away:0|t' .. data.waiting)
				else
					row.waiting:SetText('')
				end
				-- row.group:SetFormattedText("%d/%d/%d", data.group.tank or 0, data.group.heal or 0, data.group.dps or 0)

				if i%2 == 0 then -- .queued
					row.background:SetVertexColor(0, 0.694, 0.941, 0.3)
		      	else
		      		row.background:SetVertexColor(0.588, 0.588, 0.588, 0.3)
				end

				row:Show()
			else
				row:Hide()
			end
		end

		local needsScrollBar = FauxScrollFrame_Update(self, #self.data, #self.buttons, rowHeight)
		self:SetPoint("BOTTOMRIGHT", -8+(needsScrollBar and -18 or 0), 2)
	end
	list:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, UpdateRows)
	end)

	local lastUpdate
	function ns.UpdateUI(forced)
		if not _G['CueFrame']:IsVisible() then return end
		local now = time()
		if not forced and lastUpdate and now - lastUpdate < 5 then return end
		lastUpdate = now

		local numDisplayed, numTotal = UpdateData(list)
		UpdateHeaders(numDisplayed, numTotal)

		table.sort(list.data, SortData)
		UpdateRows(list)
	end

	-- setup initial state
	FauxScrollFrame_OnVerticalScroll(list, 0, rowHeight, UpdateRows)
	ns.UpdateUI()

	--[[
	local tabIndex = PVEFrame.numTabs + 1
	local tab = CreateFrame("Button", "$parentTab"..tabIndex, PVEFrame, "CharacterFrameTabButtonTemplate", tabIndex)
	      tab:SetPoint("LEFT", "$parentTab"..(tabIndex-1), "RIGHT", -16, 0)
	      tab:SetText(addonName)
	      tab:SetScript("OnClick", function(self, btn)
	      	PanelTemplates_SetTab(self, tabIndex)
	      	self.activeTabIndex = self:GetID()
	      	frame:Show()
	      end)
	PVEFrame["tab"..tabIndex] = tab
	PanelTemplates_SetNumTabs(PVEFrame, tabIndex)
	PanelTemplates_TabResize(tab) -- , padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)
	-- PanelTemplates_SelectTab(tab)
	--]]
end
