local addonName, ns, _ = ...
local AceTimer = LibStub("AceTimer-3.0")

-- GLOBALS: _G, UIParent, GRAY_FONT_COLOR_CODE, RED_FONT_COLOR_CODE, COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN
-- GLOBALS: CreateFrame, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_Update, FauxScrollFrame_GetOffset, SetPortraitToTexture, UnitLevel, GetAverageItemLevel, GetCombatRating
-- GLOBALS: table, string, math, tonumber, wipe, pairs

local tank   = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t"
local healer = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t"
local dps    = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t"

function ns.UpdateUI()
	-- dummy until UI has been initialized
end

function ns.InitUI()
	if _G["CueFrame"] then return end

	local function UpdateData(self)
		wipe(self.data)
		for leader, info in pairs(ns.db.premadeCache) do
			if info.faction == ns.playerFaction then
				table.insert(self.data, leader)
			end
		end
	end

	local currentSortBy, currentSortReverse = 2, false
	local function SortData(a, b)
		local aData = ns.db.premadeCache[a]
		local bData = ns.db.premadeCache[b]

		if currentSortBy == 1 then
			-- ilvl, resilience, level
			if aData.level ~= bData.level then
				if currentSortReverse then
					return aData.level > bData.level
				else
					return aData.level < bData.level
				end
			elseif aData.ilvl ~= bData.ilvl then
				if currentSortReverse then
					return (aData.ilvl or 0) > (bData.ilvl or 0)
				else
					return (aData.ilvl or 0) < (bData.ilvl or 0)
				end
			elseif aData.resilience ~= bData.resilience then
				if currentSortReverse then
					return (aData.resilience or 0) > (bData.resilience or 0)
				else
					return (aData.resilience or 0) < (bData.resilience or 0)
				end
			end
		elseif currentSortBy == 2 then
			-- title
			if aData.title ~= bData.title then
				if currentSortReverse then
					return (aData.title or '') > (bData.title or '')
				else
					return (aData.title or '') < (bData.title or '')
				end
			end
		elseif currentSortBy == 3 then
			-- group composition
			if currentSortReverse then
				return aData.group.size > bData.group.size
			else
				return aData.group.size < bData.group.size
			end
		end

		-- fallback, sort by premadeTag
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
			-- "|TInterface\\LFGFrame\\UI-LFG-ICON-HEROIC:16:13:-5:-3:32:32:0:16:0:20|t"
			realmName,
			locale and string.sub(locale, 0, 2) or '?'
		))

		if data.group then
			tooltip:AddLine(' ')
			tooltip:AddLine(string.format(-- "%d |4tank:tanks;, %d |4healer:healers;, %d |4dps:dps;",
				"%d%s %d%s %d%s",
				data.group.tank, tank, data.group.heal, healer, data.group.dps, dps))
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

	local function InitializePremadeMenu(self, level, menuList)
		print('init', level, menuList, self.key)
		local lvl = level or 1
		local info = UIDropDownMenu_CreateInfo()

		info.text = "Cue"
		info.isTitle = true
		info.checked = nil
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, lvl)

		info.isTitle = nil

		info.disabled = true
		info.text = "Leave queue"
		UIDropDownMenu_AddButton(info, lvl)

		info.disabled = nil

		if false then -- isFriend
			info.text = _G["WHISPER"]
			UIDropDownMenu_AddButton(info, lvl)
		else
			-- add battle tag friend
			info.text = _G["ADD_FRIEND"]
			UIDropDownMenu_AddButton(info, lvl)
		end

		-- _G["REPORT_PLAYER_FOR"] / REPORT_SPAMMING, REPORT_BAD_NAME, REPORT_BAD_LANGUAGE, REPORT_CHEATING
		info.text = "Ban leader"
		UIDropDownMenu_AddButton(info, lvl)
	end

	local dropDown = CreateFrame("Frame", "$parentDropDownMenuFrame", frame, "UIDropDownMenuTemplate")
	dropDown.displayMode = "MENU"
	dropDown.initialize = InitializePremadeMenu

	local function PremadeOnClick(self, btn)
		if btn == "RightButton" then
			dropDown.key = self.key
			ToggleDropDownMenu(nil, nil, dropDown, "cursor", 3, -3)
		else
			--
		end
	end

	local header = CreateFrame("Frame", "$parentHeader", frame, "InsetFrameTemplate")
	header:SetPoint("TOPLEFT", 2, -20)
	header:SetPoint("BOTTOMRIGHT", "$parent", "TOPRIGHT", -4, -20 - 60)
	header:SetFrameLevel(1) -- move below portrait level

	local requirement = frame:CreateFontString(nil, nil, "GameFontNormal")
	      requirement:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 6, -8)
	      requirement:SetWidth(34)
	      requirement:SetJustifyH("CENTER")
	      requirement:SetText('Req.')
	local toggle = CreateFrame("Button", nil, frame, nil, 1)
	      toggle:SetAllPoints(requirement)
	      toggle:SetScript('OnClick', OnSorterClick)
	requirement.toggle = toggle

	local info = frame:CreateFontString(nil, nil, "GameFontNormal")
	      info:SetPoint("TOPLEFT", requirement, "TOPRIGHT", 4, 0)
	      info:SetWidth(200)
	      info:SetJustifyH("LEFT")
	      info:SetText('Information')
	local toggle = CreateFrame("Button", nil, frame, nil, 2)
	      toggle:SetAllPoints(info)
	      toggle:SetScript('OnClick', OnSorterClick)
	info.toggle = toggle

	local group = frame:CreateFontString(nil, nil, "GameFontNormal")
	      group:SetPoint("TOPLEFT", info, "TOPRIGHT", 4, 2)
	      group:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
	      group:SetJustifyH("RIGHT")
	      group:SetText(_G['GROUP'])
	      	-- "|TInterface\\FriendsFrame\\UI-Toast-ToastIcons.tga:16:16:0:0:128:64:2:29:34:61|t"
	local toggle = CreateFrame("Button", nil, frame, nil, 3)
	      toggle:SetAllPoints(group)
	      toggle:SetScript('OnClick', OnSorterClick)
	group.toggle = toggle

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

		local avgItemLvl = GetAverageItemLevel()
		local resilienceRating = GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
		local playerLevel = UnitLevel("player")

		for i = 1, #self.buttons do
			local row = self.buttons[i]
			local index = i + offset

			local data = self.data[index]
			if data then data = ns.db.premadeCache[ data ] end

			if data then
				row.key = self.data[index]

				if data.ilvl and data.ilvl > 0 then
					local isHigh = avgItemLvl < data.ilvl
					row.level:SetFormattedText("%s%s", isHigh and RED_FONT_COLOR_CODE or '', data.ilvl)
				elseif data.resilience and data.resilience > 0 then
					local isLow = resilienceRating < data.resilience
					row.level:SetFormattedText("%s%s", isLow and RED_FONT_COLOR_CODE or '', data.resilience)
				else
					local level = ( ns.const.level[ data.level ] or ''):match("%d+$") or ''
					      level = tonumber(level) or MAX_PLAYER_LEVEL
					row.level:SetFormattedText("%s%s", (level < playerLevel and GRAY_FONT_COLOR_CODE) or (level > playerLevel and RED_FONT_COLOR_CODE) or '', level ~= math.huge and level or '' )
				end

				row.title:SetText(data.title)
				row.comment:SetText(data.comment)

				row.group:SetText(data.group.size)
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

	function ns.UpdateUI()
		if not _G['CueFrame']:IsVisible() then return end
		UpdateData(list)
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

	--[[
		<Frame name="$parentCommentInset" inherits="InsetFrameTemplate" frameLevel="1">
			<Anchors>
				<Anchor point="TOPLEFT" relativeTo="LFRQueueFrame" relativePoint="BOTTOMLEFT" x="4" y="76"/>
				<Anchor point="BOTTOMRIGHT" relativeTo="LFRQueueFrame" relativePoint="BOTTOMRIGHT" x="-4" y="25"/>
			</Anchors>
		</Frame>
		<ScrollFrame name="LFRQueueFrameCommentScrollFrame" inherits="UIPanelScrollFrameCodeTemplate">
			<Size x="313" y="36"/>
			<Anchors>
				<Anchor point="TOPLEFT" relativeTo="$parent" relativePoint="BOTTOMLEFT" x="13" y="70"/>
			</Anchors>
			<ScrollChild>
				<EditBox name="LFRQueueFrameComment" multiLine="true" letters="64" autoFocus="false" countInvisibleLetters="true">
					<Size x="313" y="1"/>
					<Anchors>
						<Anchor point="TOPLEFT" x="0" y="0"/>
					</Anchors>
					<Layers>
						<Layer level="OVERLAY">
							<FontString name="$parentExplanation" inherits="GameFontDisable" justifyH="LEFT" justifyV="TOP" text="TYPE_LFR_COMMENT_HERE">
								<Size x="313" y="36"/>
								<Anchors>
									<Anchor point="TOPLEFT"/>
								</Anchors>
							</FontString>
						</Layer>
					</Layers>
					<Scripts>
						<OnLoad>
							self.cursorOffset = 0;
						</OnLoad>
						<OnTextChanged>
							ScrollingEdit_OnTextChanged(self, self:GetParent());
						</OnTextChanged>
						<OnUpdate>
							ScrollingEdit_OnUpdate(self, elapsed, self:GetParent());
						</OnUpdate>
						<OnCursorChanged function="ScrollingEdit_OnCursorChanged"/>
						<OnEditFocusGained>
							if ( RaidBrowser_IsEmpowered() and (not LFRRaidList or LFRRaidList[1])) then
								LFRQueueFrameCommentExplanation:Hide();
							else
								self:ClearFocus();
							end
						</OnEditFocusGained>
						<OnEditFocusLost>
							if ( strtrim(self:GetText()) == "" ) then
								LFRQueueFrameCommentExplanation:Show();
							end
							SetLFGComment(self:GetText());
							PlaySound("UChatScrollButton");
						</OnEditFocusLost>
						<OnEscapePressed function="EditBox_ClearFocus"/>
						<OnEnterPressed function="EditBox_ClearFocus"/>
					</Scripts>
					<FontString inherits="GameFontHighlight"/>
				</EditBox>
			</ScrollChild>
			<Frames>
				<Slider name="$parentScrollBar" inherits="MinimalScrollBarTemplate" parentKey="ScrollBar">
					<Anchors>
						<Anchor point="TOPLEFT" relativePoint="TOPRIGHT" x="0" y="-16"/>
						<Anchor point="BOTTOMLEFT" relativePoint="BOTTOMRIGHT" x="0" y="13"/>
					</Anchors>
					<Scripts>
						<OnShow>
							LFRQueueFrameCommentScrollFrame:SetWidth(295);
							LFRQueueFrameComment:SetWidth(295);
						</OnShow>
						<OnHide>
							LFRQueueFrameCommentScrollFrame:SetWidth(313);
							LFRQueueFrameComment:SetWidth(313);
						</OnHide>
					</Scripts>
				</Slider>
			</Frames>
			<Scripts>
				<OnLoad>
					self.scrollBarHideable = true;
					self.noScrollThumb = true;
					ScrollFrame_OnLoad(self);
					self.ScrollBar.trackBG:Hide();
				</OnLoad>
			</Scripts>
		</ScrollFrame>
	--]]
end
