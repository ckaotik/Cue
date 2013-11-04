local addonName, ns, _ = ...

local config = {
	['CueDB'] = {
		useBattleNet = false,
	}
}

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
if not AceConfig or not AceConfigDialog then return end

local function GetSetting(info)
	local settingTable = info[#info - 1]
	local settingName = info[#info]

	return _G[settingTable][settingName]
end

local function SetSetting(info, value)
	local settingTable = info[#info - 1]
	local settingName = info[#info]

	_G[settingTable][settingName] = value
end

local optionsTable = {
	type = 'group',
	args = {
		--[[ ['CueLocalDB'] = {
			type = 'group',
			inline = true,
			name = 'Individual Settings',
			order = 1,
			args = {},
		}, --]]
		['CueDB'] = {
			type = 'group',
			inline = true,
			name = 'Shared Settings',
			order = 2,
			args = {},
		},
	},
	get = GetSetting,
	set = SetSetting,
}

local function GenerateMidgetConfig()
	for namespace, _ in pairs(optionsTable.args) do
		wipe(optionsTable.args[namespace].args)
		for key, value in pairs(config[ namespace ]) do -- _G[namespace]
			if type(value) == 'boolean' then
				optionsTable.args[namespace].args[ key ] = {
					type = 'toggle',
					name = key,
					-- desc = '',
				}
			elseif type(value) == 'number' then
				optionsTable.args[namespace].args[ key ] = {
					type = 'range',
					name = key,
					-- desc = '',
					min = -200,
					max = 200,
					bigStep = 10,
				}
			end
		end
	end
	return optionsTable
end

-- In case the addon is loaded from another condition, always call the remove interface options
if AddonLoader and AddonLoader.RemoveInterfaceOptions then
	AddonLoader:RemoveInterfaceOptions(addonName)
end

AceConfig:RegisterOptionsTable(addonName, GenerateMidgetConfig)
AceConfigDialog:AddToBlizOptions(addonName)
