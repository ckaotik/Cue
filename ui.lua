local addonName, ns, _ = ...

-- GLOBALS: _G, UIParent, GRAY_FONT_COLOR_CODE, RED_FONT_COLOR_CODE, COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN, MAX_PLAYER_LEVEL, SEARCH
-- GLOBALS: CreateFrame, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_Update, FauxScrollFrame_GetOffset, SetPortraitToTexture, UnitLevel, GetAverageItemLevel, GetCombatRating, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton, UIDropDownMenu_SetText, UIDropDownMenu_SetWidth, ToggleDropDownMenu, BNSendFriendInvite, IsIgnored, EditBox_ClearFocus, ChatFrame_SendSmartTell
-- GLOBALS: table, string, math, tonumber, wipe, pairs, ipairs, time

local tank   = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t"
local healer = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t"
local dps    = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t"

local UI_UPDATE_DELAY = 5

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
		if data.faction ~= playerFaction then return nil end

		local name, realm, battleTag = ns.oq.DecodeLeaderData( data.leader )
		local _, realm, locale = ns.GetRealmInfoByID(realm)
		local isBlocked = ns.Find(ns.db.blacklist, battleTag) or IsIgnored( realm and name.."-"..realm or name)
		if isBlocked then return nil end

		-- TODO: could probably be done by CustomSearch, too
		local premadeType = data.type
		local pass, isFiltered = false, false
		for filterType, _ in pairs(filters.types) do
			isFiltered = true
			if filterType == premadeType then
				pass = true
				break
			end
		end
		if isFiltered and not pass then return nil end

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

		return true
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

		local aStatus = ns.db.queued[a]
		local bStatus = ns.db.queued[b]
		if (aStatus or bStatus) and aStatus ~= bStatus then
			return (aStatus or math.huge) < (bStatus or math.huge)
		else
			for _, attribute in ipairs( sortables[currentSortBy] ) do
				if aData[attribute] ~= bData[attribute] then
					if currentSortReverse then
						return aData[attribute] > bData[attribute]
					else
						return aData[attribute] < bData[attribute]
					end
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
		if not data then
			ns.UpdateUI(true)
			return
		end

		local leaderName, realm, battleTag = ns.oq.DecodeLeaderData(data.leader)
		if not realm then return end

		local realmID, realmName, locale, isPvP, isRP, battleGroup = ns.GetRealmInfoByID(realm)
		if not realmName then print("no realm info found for", realm, leaderName); realmName = '?' end

		tooltip:AddLine(ns.const.typeLabels[data.type])
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
	-- ButtonFrameTemplate_ShowButtonBar(CueFrame)
	frame.TitleText:SetText(addonName)

	-- header inset, containing filters
	local header = CreateFrame("Frame", "$parentHeader", frame, "InsetFrameTemplate")
	header:SetPoint("TOPLEFT", 2, -20)
	header:SetPoint("BOTTOMRIGHT", "$parent", "TOPRIGHT", -4, -20 - 42)
	header:SetFrameLevel(1) -- move below portrait level

	-- filters
	local qualified = CreateFrame("CheckButton", nil, header, "UICheckButtonTemplate")
	      qualified:SetPoint("TOPLEFT", 58, -8)
	      qualified:SetSize(24, 24)
	      qualified.text:SetText(_G['AVAILABLE'])
	qualified:SetScript("OnClick", function(self, btn)
		filters.qualified = not filters.qualified and true or nil
		ns.UpdateUI(true)
	end)

	local typeDropDown = CreateFrame("Frame", "$parentPremadeDropDown", header, "UIDropDownMenuTemplate")
	      typeDropDown:SetPoint("TOPRIGHT", -36, -6)
	UIDropDownMenu_SetText(typeDropDown, '')	-- _G['LFG_TITLE'] .. '...'
	UIDropDownMenu_SetWidth(typeDropDown, 8, 0) -- 140, 0

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

		for _, data in ipairs(ns.const.typeDropdownLabels) do
			local value, text = data[1], data[2]
			if value == '' then
				info.isTitle = true
				info.notCheckable = true
				info.value    = nil
			else
				info.isTitle  = nil
				info.disabled = nil
				info.notCheckable = nil
				info.checked  = filters.types[value]
				info.value    = value
			end
			info.text = text
			UIDropDownMenu_AddButton(info, lvl)
		end
	end

	local searchbox = CreateFrame("EditBox", "$parentSearchBox", header, "SearchBoxTemplate")
		searchbox:SetPoint("RIGHT", typeDropDown, "LEFT", 20, 2)
		searchbox:SetFrameLevel(searchbox:GetFrameLevel() + 1)
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
		searchbox.tiptext = function(self, tooltip)
			tooltip:AddLine(SEARCH)
			tooltip:AddLine([[Combine queries by using |cffFFFFFF&|r (and), |cffFFFFFF|||r (or).
Search details using |cffFFFFFFr|realm, |cffFFFFFFl|reader, |cffFFFFFFg|rroup size, |cffFFFFFFw|rait list
|cffFFFFFFexample:|r flex & r:en & l:athene & g:> 9 & w:< 10]], nil, nil, nil, true)
		end
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

	local rowHeight = 29
	local list = CreateFrame("ScrollFrame", "$parentList", listFrame, "FauxScrollFrameTemplate")
	list:SetPoint("TOPLEFT", "$parent", "TOPLEFT", 4, -4)
	list:SetPoint("BOTTOMRIGHT", "$parent", "BOTTOMRIGHT", -4, -4)
	list.scrollBarHideable = true

	list.buttons = {}
	list.data = {}

	local function LeaveQueue(button, leader) ns.LeaveQueue(leader, not IsShiftKeyDown()); ns.UpdateUI(true) end
	local function AddBNFriend(button, battleTag) BNSendFriendInvite(battleTag) end
	local function Whisper(button, battleTag) ChatFrame_SendSmartTell(battleTag) end
	local function BanLeader(button, battleTag) table.insert(ns.db.blacklist, battleTag) end
	local dropDown = CreateFrame("Frame", "$parentPremadeDropDown", frame, "UIDropDownMenuTemplate")
	dropDown.displayMode = "MENU"
	dropDown.initialize = function(self, level, menuList)
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
		if ns.GetBnetFriendInfo(battleTag) then -- isFriend
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
			--[[
			LockHighlight(self)
			-- store selected info
			_G['CueFrame'].pauseUpdates = (numSelected > 0)
			--]]
			local leader = self:GetParent().key
			ns.JoinQueue(leader) -- TODO: ask for password if needed
			ns.UpdateUI(true)
		end
	end

	for i = 1, 11 do
		local row = CreateFrame("Button", nil, listFrame, nil, i)
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight") -- "Interface\\Buttons\\UI-Common-MouseHilight")
		row:SetHeight(rowHeight)
		row:Hide()

		local alpha = 0.35
		local background = row:CreateTexture(nil, "BACKGROUND")
		      background:SetPoint("TOPLEFT", row, "TOPLEFT")
		      background:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 2)
		      background:SetTexture(0.588, 0.588, 0.588, alpha)
		row.background = background

		row:SetPoint("RIGHT", list, "RIGHT", 2, 0)
		if i == 1 then
			row:SetPoint("TOPLEFT", list, "TOPLEFT")
			background:SetVertexColor(0.588, 0.588, 0.588, alpha)
		else
			row:SetPoint("TOPLEFT", list.buttons[i-1], "BOTTOMLEFT", 0, 0)
			if i%2 == 0 then
				background:SetVertexColor(0, 0.694, 0.941, alpha)
			else
				background:SetVertexColor(0.588, 0.588, 0.588, alpha)
			end
		end

		row:RegisterForClicks("RightButtonUp") -- AnyUp
		row:SetScript("OnClick", PremadeOnClick)
		row:SetScript("OnEnter", ns.ShowTooltip)
		row:SetScript("OnLeave", ns.HideTooltip)
		row.tiptext = ShowPremadeTooltip

		local level = row:CreateFontString(nil, nil, "GameFontHighlight")
		      level:SetPoint("TOPLEFT",    2, -2)
		      level:SetPoint("BOTTOMLEFT", 2,  2)
		      level:SetWidth(34)
		      level:SetJustifyH("CENTER")
		row.level = level

		local title = row:CreateFontString(nil, nil, "FriendsFont_Normal")
		      title:SetPoint("TOPLEFT",   level, "TOPRIGHT", 4, 0)
		      title:SetWidth(200)
		      title:SetJustifyH("LEFT")
		row.title = title

		local comment = row:CreateFontString(nil, nil, "FriendsFont_Small")
		      comment:SetPoint("BOTTOMLEFT",   level, "BOTTOMRIGHT", 4, 0)
		      comment:SetWidth(200)
		      comment:SetJustifyH("LEFT")
		      comment:SetVertexColor(0.486, 0.518, 0.541)
		row.comment = comment

		-- have title claim full height if no comment available
		title:SetPoint("BOTTOM", comment, "TOP")

		local group = row:CreateFontString(nil, nil, "FriendsFont_Normal")
		      group:SetPoint("TOPLEFT", title, "TOPRIGHT", 4, 0)
		      group:SetWidth(40)
		row.group = group

		local waiting = row:CreateFontString(nil, nil, "FriendsFont_Small")
		      waiting:SetPoint("BOTTOMLEFT", comment, "BOTTOMRIGHT", 4, 0)
		      waiting:SetWidth(40)
		      waiting:SetVertexColor(0.486, 0.518, 0.541)
		row.waiting = waiting

		-- have group claim full height if no one is waiting
		group:SetPoint("BOTTOM", waiting, "TOP")

		local status = row:CreateTexture(nil, "BACKGROUND")
		      status:SetPoint("TOPRIGHT", title, "TOPRIGHT", 0, 0)
		      status:SetSize(20, 20)
		row.status = status

		local actionButton = CreateFrame("Button", nil, row)
		      actionButton:SetPoint("RIGHT", 4, 1)
		      actionButton:SetSize(24, 32)
		      actionButton:SetNormalTexture("Interface\\FriendsFrame\\TravelPass-Invite")
		      actionButton:GetNormalTexture():SetTexCoord(0.01562500, 0.39062500, 0.27343750, 0.52343750)
		      actionButton:SetPushedTexture("Interface\\FriendsFrame\\TravelPass-Invite")
		      actionButton:GetPushedTexture():SetTexCoord(0.42187500, 0.79687500, 0.27343750, 0.52343750)
		      actionButton:SetDisabledTexture("Interface\\FriendsFrame\\TravelPass-Invite")
		      actionButton:GetDisabledTexture():SetTexCoord(0.01562500, 0.39062500, 0.00781250, 0.25781250)
		      actionButton:SetHighlightTexture("Interface\\FriendsFrame\\TravelPass-Invite")
		      actionButton:GetHighlightTexture():SetTexCoord(0.42187500, 0.79687500, 0.00781250, 0.25781250)
		row.button = actionButton

		actionButton:RegisterForClicks("LeftButtonUp")
		actionButton:SetScript("OnClick", PremadeOnClick)
		actionButton:SetScript("OnEnter", ns.ShowTooltip)
		actionButton:SetScript("OnLeave", ns.HideTooltip)
		actionButton.tiptext = _G.JOIN

		list.buttons[i] = row
	end

	local function UpdateRows(self)
		local offset = FauxScrollFrame_GetOffset(self)

		for i = 1, #self.buttons do
			local row = self.buttons[i]
			local index = i + offset

			local data = self.data[index]
			data = data and ns.db.premadeCache[ data ] or nil

			if not data then
				row:Hide()
			else
				row.key = self.data[index]

				if data.resilience > 0 then
					row.level:SetText(data.resilience)
				elseif data.ilvl > 0 then
					row.level:SetText(data.ilvl)
				else
					local level = ( ns.const.level[ data.level ] or ''):match("%d+$") or ''
					      level = tonumber(level) or MAX_PLAYER_LEVEL
					row.level:SetText(level ~= math.huge and level or '' )
				end

				if data.password then
					local locked = '|TInterface\\PetBattles\\PetBattle-LockIcon:0|t '
					row.title:SetText(locked .. data.title)
				else
					row.title:SetText(data.title)
				end
				row.comment:SetText(data.comment)

				row.group:SetText(data.size)
				--[[ if data.waiting and data.waiting > 0 then
					row.waiting:SetText('|TInterface\\FriendsFrame\\StatusIcon-Away:0|t' .. data.waiting)
				else
					row.waiting:SetText('')
				end --]]
				row.waiting:SetText((data.waiting and data.waiting > 0) and data.waiting or '')

				local status = ns.db.queued[ data.leader ]
				if status == ns.const.status.PENDING then
					row.status:SetTexture('Interface\\RaidFrame\\ReadyCheck-Waiting')
				elseif status == ns.const.status.QUEUED then
					row.status:SetTexture('Interface\\RaidFrame\\ReadyCheck-Ready')
				elseif status == ns.const.status.GROUPED then
					row.status:SetTexture('Interface\\GroupFrame\\UI-Group-LeaderIcon')
				else
					row.status:SetTexture(nil)
				end

				--[[
				if data.title:lower():find('full') or data.comment:lower():find('full') then
					--
				end
				--]]

				row:Show()
			end
		end

		local needsScrollBar = FauxScrollFrame_Update(self, #self.data, #self.buttons, rowHeight)
		self:SetPoint("BOTTOMRIGHT", -8+(needsScrollBar and -18 or 0), 2)
	end
	list:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, UpdateRows)
	end)

	local lastUpdate
	ns.UpdateUI = function(forced)
		if not _G['CueFrame']:IsVisible() or _G['CueFrame'].pauseUpdates then return end
		local now = time()
		if not forced and lastUpdate and now - lastUpdate < UI_UPDATE_DELAY then return end
		lastUpdate = now

		local numDisplayed, numTotal = UpdateData(list)
		UpdateHeaders(numDisplayed, numTotal)

		table.sort(list.data, SortData)
		UpdateRows(list)
	end

	-- setup initial state
	FauxScrollFrame_OnVerticalScroll(list, 0, rowHeight, UpdateRows)
	ns.UpdateUI()
end
