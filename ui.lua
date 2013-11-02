local addonName, ns, _ = ...
local AceTimer = LibStub("AceTimer-3.0")

-- GLOBALS: _G, UIParent, GRAY_FONT_COLOR_CODE, RED_FONT_COLOR_CODE, COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN
-- GLOBALS: CreateFrame, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_Update, FauxScrollFrame_GetOffset, SetPortraitToTexture, UnitLevel, GetAverageItemLevel, GetCombatRating
-- GLOBALS: table, string, math, tonumber, wipe, pairs

local tank   = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t"
local healer = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t"
local dps    = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t"

function ns.InitUI()
	if _G["CueFrame"] then return end

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

	local header = CreateFrame("Frame", "$parentHeaderInset", frame, "InsetFrameTemplate")
	header:SetPoint("TOPLEFT", 2, -20)
	header:SetPoint("BOTTOMRIGHT", "$parent", "TOPRIGHT", -4, -20 - 60)
	header:SetFrameLevel(1) -- move below portrait level

	local requirement = frame:CreateFontString(nil, nil, "GameFontNormal")
	      requirement:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 6, -8)
	      requirement:SetWidth(34)
	      requirement:SetJustifyH("CENTER")
	      requirement:SetText('Req.')
	local info = frame:CreateFontString(nil, nil, "GameFontNormal")
	      info:SetPoint("LEFT", requirement, "RIGHT", 4, 0)
	      info:SetWidth(200)
	      info:SetJustifyH("LEFT")
	      info:SetText('Information')
	local roles = frame:CreateFontString(nil, nil, "GameFontNormal")
	      roles:SetPoint("LEFT", info, "RIGHT", 4, 0)
	      roles:SetPoint("RIGHT", frame, "RIGHT", -6, 0)
	      roles:SetJustifyH("RIGHT")
	      roles:SetText(tank..healer..dps)

	local listFrame = CreateFrame("Frame", "$parentListInset", frame, "InsetFrameTemplate")
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

		row:SetPoint("RIGHT", list, "RIGHT", 2, 0)
		if i == 1 then
			row:SetPoint("TOPLEFT", list, "TOPLEFT")
		else
			row:SetPoint("TOPLEFT", list.buttons[i-1], "BOTTOMLEFT", 0, 0)
		end

		local level = row:CreateFontString(nil, nil, "GameFontHighlight")
		      level:SetPoint("LEFT", 2, 0)
		      level:SetWidth(34)
		      level:SetJustifyH("CENTER")
		row.level = level

		local title = row:CreateFontString(nil, nil, "GameFontHighlight")
		      title:SetPoint("LEFT", level, "RIGHT", 4, 0)
		      title:SetJustifyH("LEFT")
		      title:SetWidth(200)
		row.title = title

		local group = row:CreateFontString(nil, nil, "GameFontHighlight")
		      group:SetPoint("LEFT", title, "RIGHT", 4, 0)
		      group:SetPoint("RIGHT")
		      group:SetJustifyH("RIGHT")
		      group:SetShadowColor(1, 1, 1, 1)
		      group:SetShadowOffset(0, 0)
		row.group = group

		list.buttons[i] = row
	end

	local function UpdateData(self)
		wipe(self.data)
		for token, info in pairs(ns.db.premadeCache) do
			if info.faction == ns.playerFaction then
				table.insert(self.data, token)
			end
		end
	end

	local function SortData(a, b)
		local aData = ns.db.premadeCache[a]
		local bData = ns.db.premadeCache[b]

		if aData.title == bData.title then
			return a < b
		else
			return (aData.title or '') < (bData.title or '')
		end
	end

	local function UpdateRows(self)
		local offset = FauxScrollFrame_GetOffset(self)
		for i = 1, #self.buttons do
			local row = self.buttons[i]
			local index = i + offset

			local data = self.data[index]
			if data then data = ns.db.premadeCache[ data ] end

			if data then
				if data.comment and data.comment ~= "" then
					row.title:SetFormattedText("%s\n%s%s|r", data.title, GRAY_FONT_COLOR_CODE, data.comment)
				else
					row.title:SetText(data.title)
				end

				if data.ilvl and data.ilvl > 0 then
					local isHigh = (GetAverageItemLevel()) < data.ilvl
					row.level:SetFormattedText("%s%s", isHigh and RED_FONT_COLOR_CODE or '', data.ilvl)
				elseif data.resilience and data.resilience > 0 then
					local isLow = GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN) < data.resilience
					row.level:SetFormattedText("%s%s", isLow and RED_FONT_COLOR_CODE or '', data.resilience)
				else
					local level = ( ns.const.level[ data.level ] or ''):match("%d+$") or ''
					      level = tonumber(level) or math.huge
					local myLevel = UnitLevel("player")
					row.level:SetFormattedText("%s%s", (level < myLevel and GRAY_FONT_COLOR_CODE) or (level > myLevel and RED_FONT_COLOR_CODE) or '', level ~= math.huge and level or '' )
				end

				if data.group then
					-- row.group:SetFormattedText("%d |4tank:tanks;, %d |4healer:healers;, %d |4dps:dps;",
					row.group:SetFormattedText("%d/%d/%d",
						data.group.tank or 0, data.group.heal or 0, data.group.dps or 0)
				else
					row.group:SetText('')
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
