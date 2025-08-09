WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.consoleControl = {}
local WWCC = WW.consoleControl

function WWCC.Init()    
	local LibHarvensAddonSettings = LibHarvensAddonSettings
	
	local options = {
		allowRefresh = false,
		author = "STUDLETON",
	}
	WWCC.menuName = "Wizards Wardrobe Control"
	local settings = LibHarvensAddonSettings:AddAddon(WWCC.menuName, options)
	if not settings then
		return
	end

	local areSettingsDisabled = false

	local label = {
		type = LibHarvensAddonSettings.ST_LABEL,
		label = "Thanks to |cff0000Ned919x|r for making this possible",
	}
	settings:AddSetting(label)

	local setupIndex = WW.pages[WW.selection.zone.tag][WW.selection.pageId].selected or 1
	local equipped = { zone = nil, page = nil, setup = nil}
	WW.equipped = equipped
	local rearrangeSelectedIndex = 1
	local selectedSetupName = ""
	local function getSetupListItemControl(index)
		local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)
		
		local controlPool = tooltip.customControlPools["WizardsWardrobeRearrangeItem"]
		if controlPool ~= nil then
			local control = controlPool:GetActiveObjects()[index]
			if control ~= nil then return control end
		end
		local control = tooltip:AcquireCustomControl({
			controlTemplate = "WizardsWardrobeRearrangeItem",
			controlTemplateOverrideName = "WizardsWardrobeRearrangeItem",
			widthPercent = 100,
		})
		tooltip:AddDimensionedControl(control)
		return control
	end
	local function showSetupList()
		local sceneName = SCENE_MANAGER:GetCurrentSceneName()
		if sceneName ~= "LibHarvensAddonSettingsScene" and sceneName ~= "gamepad_banking" then return end
		GAMEPAD_TOOLTIPS:LayoutSettingTooltip(GAMEPAD_RIGHT_TOOLTIP, WW.selection.zone.name .. "\n" .. WW.pages[WW.selection.zone.tag][WW.selection.pageId].name , "")
		for index, setup in ipairs(WW.setups[WW.selection.zone.tag][WW.selection.pageId]) do
			local control = getSetupListItemControl(index)
			local nameLabel = control:GetNamedChild("Name")
			local equippedLabel = control:GetNamedChild("Equipped")
			local text = tostring(index) .. ": " .. setup.name
			if index == setupIndex then 
				text = "|c00ffff>|r " .. text .. " |c00ffff<|r"
			end
			nameLabel:SetText(text)
			if WW.selection.zone.tag == equipped.zone and WW.selection.pageId == equipped.page and index == equipped.setup then
				equippedLabel:SetText("|c00ff00EQUIPPED|r")
			else equippedLabel:SetText("") end
			
			local skillIndex = 1
			local skillsContainer = control:GetNamedChild("Skills")
			for hotbarCategory = 1, 0, -1 do
				for slotIndex = 3, 8 do
					local abilityId = setup.skills[hotbarCategory][slotIndex]
					local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
					if abilityId and abilityId > 0 then
						abilityIcon = GetAbilityIcon( abilityId )
					end
					local skillControl = skillsContainer:GetChild(skillIndex)
					skillControl:SetTexture( abilityIcon )
					skillIndex = skillIndex + 1
				end
			end
		end
	end

	local zonesByCategory = {
		[WW.ACTIVITIES.GENERAL] = {name = "General", items = {}},
		[WW.ACTIVITIES.TRIALS] = {name = "Trials", items = {}},
		[WW.ACTIVITIES.DUNGEONS] = {name = "Dungeons", items = {}},
		[WW.ACTIVITIES.DLC_DUNGEONS] = {name = "DLC Dungeons", items = {}},
		[WW.ACTIVITIES.ARENAS] = {name = "Arenas", items = {}},
		[WW.ACTIVITIES.MISC] = {name = "Misc", items = {}},
		[WW.ACTIVITIES.ENDLESS] = {name = "Endless Dungeons", items = {}},
	}
	for _, zone in pairs(WW.gui.GetSortedZoneList()) do
		table.insert(zonesByCategory[zone.category].items, { name = zone.name, data = zone.tag })
	end
	local categoryItems = {}
	for category, data in pairs(zonesByCategory) do
		if #data.items > 0 then
			table.insert(categoryItems, { name = data.name, data = category })
		end
	end
	local selectedCategory = WW.zones[WW.storage.selectedZoneTag].category
	local categoryDropdown = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Category",
		tooltip = "General can be used for anywhere, but you can also create setups for specific instances.\nIf you want to use auto-equip, you must select and use the specific category.\nSave Trash and Boss setups in Misc>Substitute Setups and they will be loaded upon auto-equip if category specific setups are empty.",
		setFunction = function(combobox, name, item)
			selectedCategory = item.data
			WW.gui.OnZoneSelect(WW.zones[zonesByCategory[item.data].items[1].data])
			setupIndex = 1
			showSetupList()
		end,
		getFunction = function() return zonesByCategory[selectedCategory].name end,
		items = categoryItems,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(categoryDropdown)

	local subCategoryDropdown = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Subcategory",
		setFunction = function(combobox, name, item)
			WW.gui.OnZoneSelect(WW.zones[item.data])
			setupIndex = 1
			showSetupList()
		end,
		getFunction = function() return WW.selection.zone.name end,
		items = function() return zonesByCategory[selectedCategory].items end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(subCategoryDropdown)

	local pageDropdown = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Page",
		tooltip = "You can create multiple pages per subcategory",
		setFunction = function(combobox, name, item)
			WW.pages[WW.selection.zone.tag][0].selected = item.data
			WW.selection.pageId = item.data
			setupIndex = 1
			showSetupList()
		end,
		getFunction = function() return WW.pages[WW.selection.zone.tag][WW.selection.pageId].name end,
		items = function()
			local items = {}
			for i, page in ipairs(WW.pages[WW.selection.zone.tag]) do
				table.insert(items, { name = page.name, data = i })
			end
			return items
		end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(pageDropdown)

	local createPageButton = {
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = "Create page",
		tooltip = "Create a new page in the selected subcategory",
		buttonText = "Create page",
		clickHandler = function(control, button)
			WW.gui.CreatePage(WW.selection.zone)
			setupIndex = 1
			showSetupList()
		end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(createPageButton)

	local deletePageButton = {
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = "Delete page",
		tooltip = "Delete the selected page",
		buttonText = "Delete page",
		clickHandler = function(control, button)
			WW.gui.DeletePage()
			setupIndex = 1
			showSetupList()
		end,
		disable = function() return areSettingsDisabled or #WW.pages[WW.selection.zone.tag] == 1 end,
	}
	settings:AddSetting(deletePageButton)

	local renamePage = {
		type = LibHarvensAddonSettings.ST_EDIT,
		label = "Rename Page",
		tooltip = "Rename currently selected Page",
		setFunction = function(value)
			WW.pages[WW.selection.zone.tag][WW.selection.pageId].name = value
			showSetupList()
		end,
		getFunction = function() return WW.pages[WW.selection.zone.tag][WW.selection.pageId].name end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(renamePage)

	local quickEquipChecked = false
	local quickEquipCheckbox = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Quick Equip",
		tooltip = "Turn on to equip setups immediately when cycling",
		default = false,
		setFunction = function(state)
				quickEquipChecked = state
		end,
		getFunction = function()
				return quickEquipChecked
		end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(quickEquipCheckbox)

	local equipButton = {
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = "Equip Selected Setup",
		tooltip = "Equip Selected Setup",
		buttonText = "Equip",
		clickHandler = function(control, button)
			WW.LoadSetupCurrent(setupIndex)
			showSetupList()
		end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(equipButton)

	local setupItems = {}
	local setupDropdownSetting = nil
	local function findSetupItemIndex(item)
		for index, setupItem in ipairs(setupItems) do
			if item == setupItem then
				return index
			end
		end
		return 1
	end
	local function generateSetupItems()
		setupItems = {}
		for index, setup in ipairs(WW.setups[WW.selection.zone.tag][WW.selection.pageId]) do
			table.insert(setupItems, { name = setup.name, data = index })
		end
		if not setupItems[setupIndex] then setupIndex = 1 end
		selectedSetupName = setupItems[setupIndex].name
		return setupItems
	end
	local function getSetupPreviewControl()
		local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP) -- move to globalish
		
		local controlPool = tooltip.customControlPools["WizardsWardrobeSetupPreview"]
		if controlPool ~= nil then
			local control = controlPool:GetActiveObjects()[1]
			if control ~= nil then return control end
		end
		local control = tooltip:AcquireCustomControl({
			controlTemplate = "WizardsWardrobeSetupPreview",
			controlTemplateOverrideName = "WizardsWardrobeSetupPreview",
			widthPercent = 100,
		})
		tooltip:AddDimensionedControl(control)
		return control
	end
	local function showSetupPreview()	
		local containerControl = getSetupPreviewControl()
		containerControl:GetNamedChild("Name"):SetText(selectedSetupName)

		local skillIndex = 1
		local setup = WW.setups[WW.selection.zone.tag][WW.selection.pageId][setupIndex]
		local skillsContainer = containerControl:GetNamedChild("Skills")
		for hotbarCategory = 1, 0, -1 do
			for slotIndex = 3, 8 do
				local abilityId = setup.skills[hotbarCategory][slotIndex]
				local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
				if abilityId and abilityId > 0 then
					abilityIcon = GetAbilityIcon( abilityId )
				end
				local skillControl = skillsContainer:GetChild(skillIndex)
				skillControl:SetTexture( abilityIcon )
				skillIndex = skillIndex + 1
			end
		end

		local gearContainer = containerControl:GetNamedChild("Gear")
		for index, gearSlot in ipairs( WW.GEARSLOTS ) do
			local gear = setup.gear[gearSlot]
			local gearControl = gearContainer:GetChild(index)
			local itemLabel = gearControl:GetNamedChild("Name")
			local itemIcon = gearControl:GetNamedChild("Icon")
			if gear and gear.link and #gear.link > 0 then
				local itemName = gear.link
				if gearSlot == EQUIP_SLOT_COSTUME and gear.creator then
					itemName = string.format( "%s |c808080(%s)|r", gear.link, gear.creator )
				elseif gearSlot ~= EQUIP_SLOT_POISON and gearSlot ~= EQUIP_SLOT_BACKUP_POISON then
					itemName = string.format( "%s |c808080(%s)|r", gear.link,
					GetString( "SI_ITEMTRAITTYPE", GetItemLinkTraitInfo( gear.link ) ) )
				end
				itemLabel:SetText( itemName )
				itemIcon:SetTexture( GetItemLinkIcon( gear.link ) )
			else
				itemLabel:SetText( "-/-" )
				itemIcon:SetTexture( WW.GEARICONS[ gearSlot ] )
			end
		end

		local foodContainer = containerControl:GetNamedChild("Food")
		local foodIcon = foodContainer:GetNamedChild("Icon")
		local foodLabel = foodContainer:GetNamedChild("Label")
		local food = setup.food
		if food and food.link and #food.link > 0 then
			foodLabel:SetText(food.link)
			foodIcon:SetTexture(GetItemLinkIcon(food.link))
		else
			foodLabel:SetText("-/-")
			foodIcon:SetTexture("/esoui/art/crafting/provisioner_indexicon_meat_disabled.dds")
		end

		local cpContainer = containerControl:GetNamedChild("CP")
		for cpIndex = 1, 12 do
			local cpControl = cpContainer:GetChild(cpIndex)
			local cpIcon = cpControl:GetNamedChild("Icon")
			local cpLabel = cpControl:GetNamedChild("Label")
			local cpId = setup.cp[cpIndex]
			if cpId then
				local cpName = zo_strformat( "<<C:1>>", GetChampionSkillName( cpId ) )
				if #cpName > 0 then
					local text = string.format( "|c%s%s|r", WW.CPCOLOR[cpIndex], cpName )
					cpLabel:SetText( text )
					cpIcon:SetTexture(WW.CPICONS[cpIndex])
					cpIcon:SetHidden(false)
				end
			else
				cpIcon:SetHidden(true)
				cpLabel:SetText("-/-")
			end
		end
	end
	
	local rearrangeDropdownSetting = nil
	local setupsDropdown = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Setups",
		tooltip = "Setup Preview",
		setFunction = function(combobox, name, item, isBankScene)
			setupIndex = findSetupItemIndex(item)
			if not setupItems[setupIndex] then setupIndex = 1 end
			rearrangeSelectedIndex = setupIndex
			selectedSetupName = setupItems[setupIndex].name
			if not isBankScene then
				if quickEquipChecked then 
					WW.LoadSetupCurrent(setupIndex)
				end
				if setupDropdownSetting.control == LibHarvensAddonSettings.list:GetSelectedControl() then showSetupPreview() end
			end
			showSetupList()
		end,
		getFunction = function(isBankScene)
			if not isBankScene and setupDropdownSetting.control == LibHarvensAddonSettings.list:GetSelectedControl() then zo_callLater(showSetupPreview,0) end
			return selectedSetupName
		end,
		items = generateSetupItems,
		disable = function() return areSettingsDisabled end,
	}
	setupDropdownSetting = settings:AddSetting(setupsDropdown)

	local rearrangeDropdown = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Rearrange Setups",
		setFunction = function(combobox, name, item)
			if rearrangeDropdownSetting.control == LibHarvensAddonSettings.list:GetSelectedControl() then
				local wws = WW.setups[WW.selection.zone.tag][WW.selection.pageId]
				name = tonumber(name)
				if name ~= rearrangeSelectedIndex then
					wws[rearrangeSelectedIndex], wws[name] = wws[name], wws[rearrangeSelectedIndex]
					if WW.selection.zone.tag == equipped.zone and WW.selection.pageId == equipped.page and equipped.setup == rearrangeSelectedIndex then
						equipped.setup = name
					elseif WW.selection.zone.tag == equipped.zone and WW.selection.pageId == equipped.page and equipped.setup == name then
						equipped.setup= rearrangeSelectedIndex
					end
					if rearrangeSelectedIndex == rearrangeSelectedIndex then
						setupIndex = name
					elseif rearrangeSelectedIndex == name then
						setupIndex = rearrangeSelectedIndex
					end
					rearrangeSelectedIndex = name
				end
			end
			showSetupList()
		end,
		getFunction = function()
			return tostring(rearrangeSelectedIndex)
		end,
		items = function()
			local items = {}
			for i = 1, #WW.setups[WW.selection.zone.tag][WW.selection.pageId] do
				table.insert(items, {name = tostring(i), data = 1})
			end
			return items
		end,
		disable = function() return areSettingsDisabled end,
	}
	rearrangeDropdownSetting = settings:AddSetting(rearrangeDropdown)

	local saveButton = {
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = "Save Setup",
		tooltip = "Save to setup",
		buttonText = "Save",
		clickHandler = function(control, button)
			WW.SaveSetup( WW.selection.zone, WW.selection.pageId, setupIndex )
			showSetupList()
		end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(saveButton)

	local createButton = {
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = "Create Setup",
		tooltip = "Create a new setup",
		buttonText = "Create",
		clickHandler = function(control, button)
			WW.gui.CreateSetup()
			generateSetupItems()
			setupIndex = #setupItems
			rearrangeSelectedIndex = setupIndex
			LibHarvensAddonSettings:RefreshAddonSettings()
			selectedSetupName = setupItems[setupIndex].name
			showSetupList()
		end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(createButton)
	local deleteButton = {
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = "Delete Setup",
		tooltip = "Delete setup",
		buttonText = "Delete",
		clickHandler = function(control, button)
			if #setupItems == 1 then return end
			WW.DeleteSetup( WW.selection.zone, WW.selection.pageId, setupIndex )
			if WW.selection.zone.tag == equipped.zone and WW.selection.pageId == equipped.page and equipped.setup == setupIndex then equipped.setup = nil end
			rearrangeSelectedIndex = setupIndex
			selectedSetupName = setupItems[setupIndex].name
			LibHarvensAddonSettings:RefreshAddonSettings()
			generateSetupItems()
			showSetupList()
		end,
		disable = function() return areSettingsDisabled or #setupItems == 1 end,
	}
	settings:AddSetting(deleteButton)

	local renameSetup = {
		type = LibHarvensAddonSettings.ST_EDIT,
		label = "Rename Setup",
		tooltip = "Rename currently selected setup",
		setFunction = function(value)
			WW.setups[WW.selection.zone.tag][WW.selection.pageId][setupIndex].name = value
			selectedSetupName = value
			showSetupList()
		end,
		getFunction = function() return selectedSetupName end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(renameSetup)

	local autoEquipConditionDropdown = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Auto Equip Condition",
		tooltip = "Enable auto equip to set.\nWill attempt to equip the setup when you get close to the boss.\nIf you select Trash, set the After condition below to equip after a specific boss.",
		setFunction = function(combobox, name, item)
			WW.setups[WW.selection.zone.tag][WW.selection.pageId][setupIndex].condition.boss = item.data
			if item.data ~= GetString(WW_TRASH) then
				WW.setups[WW.selection.zone.tag][WW.selection.pageId][setupIndex].condition.trash = WW.CONDITIONS.EVERYWHERE
			end
		end,
		getFunction = function()
			local boss = WW.selection.zone.bosses[WW.selection.zone.lookupBosses[WW.setups[WW.selection.zone.tag][WW.selection.pageId][setupIndex].condition.boss]]
			if not boss then return "None" end
			return boss.displayName or boss.name
		end,
		items = function()
			local items = {
				{name = "None", data = {boss = WW.CONDITIONS.NONE}},
			}
			for _, boss in ipairs( WW.selection.zone.bosses ) do
				table.insert(items, {name = boss.displayName or boss.name, data = boss.name})
			end
			return items
		end,
		disable = function()
			return areSettingsDisabled
				or not WW.settings.autoEquipSetups 
				or #WW.zones[WW.selection.zone.tag].bosses < 3
		end,
	}
	settings:AddSetting(autoEquipConditionDropdown)

	local autoEquipConditionAfterDropdown = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Auto Equip Trash After",
		tooltip = "Enable auto equip and select Trash above to set.\nThis can be set to equip after a specific boss, or every boss.",
		setFunction = function(combobox, name, item)
			WW.setups[WW.selection.zone.tag][WW.selection.pageId][setupIndex].condition.trash = item.data
		end,
		getFunction = function()
			local boss = WW.selection.zone.bosses[WW.selection.zone.lookupBosses[WW.setups[WW.selection.zone.tag][WW.selection.pageId][setupIndex].condition.trash]]
			if not boss then return "Every Boss" end
			return boss.displayName or boss.name
		end,
		items = function()
			local items = {
				{name = "Every Boss", data = WW.CONDITIONS.EVERYWHERE},
			}
			for _, boss in ipairs( WW.selection.zone.bosses ) do
				if boss.name ~= GetString(WW_TRASH) then
					table.insert(items, {name = boss.displayName or boss.name, data = boss.name})
				end
			end
			return items
		end,
		disable = function()
			return areSettingsDisabled
				or not WW.settings.autoEquipSetups
				or #WW.zones[WW.selection.zone.tag].bosses < 3
				or WW.setups[WW.selection.zone.tag][WW.selection.pageId][setupIndex].condition.boss ~= GetString(WW_TRASH)
				or WW.setups[WW.selection.zone.tag][WW.selection.pageId][setupIndex].condition.boss == WW.CONDITIONS.NONE
		end,
	}
	settings:AddSetting(autoEquipConditionAfterDropdown)

	local panelSection = {
		type = LibHarvensAddonSettings.ST_SECTION,
		label = "Info Panel",
	}
	settings:AddSetting(panelSection)

	local litePanelCheckbox = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Lite Mode",
		tooltip = "Removes the background, icon and title for a smaller, simpler info panel.\nWill reload ui upon toggling.",
		setFunction = function(state)
			WW.settings.panel.mini = state
			ReloadUI()
		end,
		getFunction = function() return WW.settings.panel.mini end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(litePanelCheckbox)

	local function temporarilyShowPanel()
		if WW.settings.panel.mini then WizardsWardrobePanelBG:SetHidden(false) end
		SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene"):AddFragment(WizardsWardrobePanel.fragment)
		WizardsWardrobePanel:SetDrawTier(2)
		WizardsWardrobePanel:SetDrawLayer(2)
		
		EVENT_MANAGER:UnregisterForUpdate("WizardsWardrobePanelMove")
		EVENT_MANAGER:RegisterForUpdate("WizardsWardrobePanelMove", 5000, function()
			SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene"):RemoveFragment(WizardsWardrobePanel.fragment)
			WizardsWardrobePanel:SetDrawTier(0)
			WizardsWardrobePanel:SetDrawLayer(1)
			if WW.settings.panel.mini then WizardsWardrobePanelBG:SetHidden(true) end
			EVENT_MANAGER:UnregisterForUpdate("WizardsWardrobePanelMove")
		end)
	end

	local scaleSliderSetting
	local scaleSlider = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Panel Scale",
		tooltip = "Adjust the scale of the panel",
		setFunction = function(value)
			temporarilyShowPanel()
			WW.settings.panel.scale = value
			scaleSliderSetting:UpdateControl()
			WizardsWardrobePanel:SetScale(WW.settings.panel.scale)
		end,
		getFunction = function() return WW.settings.panel.scale end,
		min = 1,
		max = 20,
		step = 0.1,
		disable = function() return areSettingsDisabled end,
	}
	scaleSliderSetting = settings:AddSetting(scaleSlider)

	local incSliderValue = 100
	local incSlider = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Reposition increments",
		tooltip = "Multiplier to move the panel quicker/slower",
		setFunction = function(value) incSliderValue = value end,
		getFunction = function() return incSliderValue end,
		min = 1,
		max = 5,
		step = 10,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(incSlider)
	
	local xSliderSetting
	local function getMaxX() return math.max(0, GuiRoot:GetWidth() - WizardsWardrobePanel:GetWidth()) end
	local xSlider = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Panel X position",
		tooltip = "Move the panel left or right",
		setFunction = function(value)
			temporarilyShowPanel()
			local offset = (value - WW.settings.panel.left) * incSliderValue
			local newX = WW.settings.panel.left + offset
			local maxX = getMaxX()
			if newX > maxX then newX = maxX end
			if newX < 0 then newX = 0 end
			WW.settings.panel.left = newX
			xSliderSetting:UpdateControl()
			WizardsWardrobePanel:ClearAnchors()
			WizardsWardrobePanel:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, WW.settings.panel.left, WW.settings.panel.top )
		end,
		getFunction = function() return WW.settings.panel.left end,
		min = 0,
		max = GuiRoot:GetWidth(),
		step = 1,
		disable = function() return areSettingsDisabled end,
	}
	xSliderSetting = settings:AddSetting(xSlider)


	local ySliderSetting
	local function getMaxY() return GuiRoot:GetHeight() - WizardsWardrobePanel:GetHeight() end
	local ySlider = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Panel Y position",
		tooltip = "Move the panel up or down",
		setFunction = function(value)	
			temporarilyShowPanel()
			local offset = (value - WW.settings.panel.top) * incSliderValue
			local newY = WW.settings.panel.top + offset
			local maxY = getMaxY()
			if newY > maxY then newY = maxY end
			if newY < 0 then newY = 0 end
			WW.settings.panel.top = newY
			ySliderSetting:UpdateControl()
			WizardsWardrobePanel:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, WW.settings.panel.left, WW.settings.panel.top )
		end,
		getFunction = function() return WW.settings.panel.top end,
		min = 0,
		max = GuiRoot:GetHeight(),
		step = 1,
		disable = function() return areSettingsDisabled end,
	}
	ySliderSetting = settings:AddSetting(ySlider)

	local resetPanelButton = {
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = "Reset panel position",
		tooltip = "Reset panel to the default position",
		buttonText = "Reset",
		clickHandler = function(control, button)
			WW.settings.panel.left, WW.settings.panel.top = 1290, 980
			WizardsWardrobePanel:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, WW.settings.panel.left, WW.settings.panel.top )
			temporarilyShowPanel()
		end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(resetPanelButton)
	
	local quickslotSection = {
		type = LibHarvensAddonSettings.ST_SECTION,
		label = "Quickslot bindings",
	}
	settings:AddSetting(quickslotSection)
	
	local selectedQuickslot = 1
	local quickslotItems = {
		{name = "1 (SE)", data = 1},
		{name = "2 (E)", data = 2},
		{name = "3 (NE)", data = 3},
		{name = "4 (N)", data = 4},
		{name = "5 (NW)", data = 5},
		{name = "6 (W)", data = 6},
		{name = "7 (SW)", data = 7},
		{name = "8 (S)", data = 8},
	}
	local quickslotActions = {
		nil,
		function() WW.LoadSetupCurrent(1) end,
		function() WW.LoadSetupCurrent(2) end,
		function() WW.LoadSetupAdjacent(-1) end,
		function() WW.LoadSetupAdjacent(0) end,
		function() WW.LoadSetupAdjacent(1) end,
	}
		
	local quickslotActionItems = {
		{name = "None", data = 1},
		{name = "Equip First", data = 2},
		{name = "Equip Second", data = 3},
		{name = "Equip Previous", data = 4},
		{name = "Equip Current", data = 5},
		{name = "Equip Next", data = 6},
	}
	
	local lastQuickSlot = GetCurrentQuickslot()
	local function onQuickslotSelected(_, slotIndex)
		if WW.settings.quickslots[slotIndex] and quickslotActions[WW.settings.quickslots[slotIndex]] then
			quickslotActions[WW.settings.quickslots[slotIndex]]()
			if WW.settings.resetToOriginalQuickslot and not (WW.settings.quickslots[lastQuickSlot] and WW.settings.quickslots[lastQuickSlot] > 1)then
				SetCurrentQuickslot(lastQuickSlot)
				return
			end
		end
		lastQuickSlot = slotIndex
	end
	
	local function toggleQuickslots(state)
		if state then
			EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_ACTIVE_QUICKSLOT_CHANGED, onQuickslotSelected)
		else
			EVENT_MANAGER:UnregisterForEvent(WW.name, EVENT_ACTIVE_QUICKSLOT_CHANGED)
		end
	end
	toggleQuickslots(WW.settings.quickslotsEnabled)
	
	local function buildQuickslotBindingsText()
		local text = "\n\nBound quickslots:"
		for slotIndex, actionIndex in pairs(WW.settings.quickslots) do
			if actionIndex > 1 then
				text = text .. "\n" .. quickslotItems[slotIndex].name .. " - " .. quickslotActionItems[actionIndex].name
			end
		end
		return text
	end
	
	local quickslotsEnabledCheckbox = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Quickslots enabled",
		tooltip = function() 
			local text = "Turn on to enable quickslot bindings.\nThese will trigger a Wizards action when you select the corresponding quickslot.\nWarning: may overlap with other addons, bind wisely."
			return text .. buildQuickslotBindingsText()
		end,
		setFunction = function(state)
			WW.settings.quickslotsEnabled = state
			toggleQuickslots(state)
		end,
		getFunction = function()
			return WW.settings.quickslotsEnabled
		end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(quickslotsEnabledCheckbox)
	
	
	local function isResetToOriginalQuickslotDisabled()
		return not WW.settings.resetToOriginalQuickslot and (WW.settings.quickslots[lastQuickSlot] and WW.settings.quickslots[lastQuickSlot] > 1)
	end
	local resetToOriginalQuickslotCheckbox = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Reset after equip",
		tooltip = function()
			local text = "Reset to your originally selected quickslot after equipping the setup."
			if isResetToOriginalQuickslotDisabled() then
				text = text .. "\nDisabled: select an unbound quickslot before you can enable this"
			end
			return text
		end,
		setFunction = function(state)
			WW.settings.resetToOriginalQuickslot = state
		end,
		getFunction = function()
			return WW.settings.resetToOriginalQuickslot
		end,
		disable = function() return areSettingsDisabled or not WW.settings.quickslotsEnabled or isResetToOriginalQuickslotDisabled() end,
	}
	settings:AddSetting(resetToOriginalQuickslotCheckbox)
	
	local quickslotDropdown = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Select Quickslot",
		tooltip = function() 
			local text = "Select a quickslot to bind. Use compass directions to identify your target slot."
			return text .. buildQuickslotBindingsText()
		end,
		setFunction = function(combobox, name, item)
			selectedQuickslot = item.data
		end,
		getFunction = function() return quickslotItems[selectedQuickslot] end,
		items = quickslotItems,
		disable = function() return areSettingsDisabled or not WW.settings.quickslotsEnabled end,
	}
	settings:AddSetting(quickslotDropdown)
	
	local function isQuickslotActionDisabled()
		return WW.settings.resetToOriginalQuickslot and lastQuickSlot == selectedQuickslot
	end
	local quickslotActionDropdown = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Select Action",
		tooltip = function()
			local text = ""
			if isQuickslotActionDisabled() then 
				text = text .. "Disabled: this is your character's current quickslot and \"Reset After Equip\" is enabled. Turn off Reset or change your quickslot"
			end
			return text .. buildQuickslotBindingsText()
		end,
		setFunction = function(combobox, name, item)
			WW.settings.quickslots[selectedQuickslot] = item.data
		end,
		getFunction = function()
			if WW.settings.quickslots[selectedQuickslot] then
				return quickslotActionItems[WW.settings.quickslots[selectedQuickslot]].name
			end
			return "None"
		end,
		items = quickslotActionItems,
		disable = function() return areSettingsDisabled or not WW.settings.quickslotsEnabled or isQuickslotActionDisabled() end,
	}
	settings:AddSetting(quickslotActionDropdown)

	local controlSceneHidden = true
	local bankDialogHidden = true
	local dropdownsBeforeBank, lastActivatedControl
	local bankingButton = {
		name = "Wizards",
		keybind = "UI_SHORTCUT_QUINARY",
		callback = function()
			ZO_Dialogs_ShowPlatformDialog("WizardsWardrobeBankDialog") 
			zo_callLater(function()
				if not bankDialogHidden then
					showSetupList()
					zo_callLater(function()
						if not bankDialogHidden then
							showSetupList()
						end
					end, 500)
				end
			end, 500) 
			bankDialogHidden = false
		end,
		alignment = KEYBIND_STRIP_ALIGN_RIGHT,
	}
	SCENE_MANAGER:RegisterCallback( "SceneStateChanged", function(scene, oldState, newState)
		if scene:GetName() == "LibHarvensAddonSettingsScene" then
			if newState == SCENE_SHOWN and settings.selected then
				-- the tooltip doesn't show if called right away, and the first time it's called it has anxiety; scrunched up
				-- calling it again after it calms down, look into fixing properly later
				zo_callLater(function()
					if not controlSceneHidden then
						showSetupList()
						zo_callLater(function()
							if not controlSceneHidden then
								showSetupList()
							end
						end, 500)
					end
				end, 500) 
				controlSceneHidden = false
				return
			end
			controlSceneHidden = true
		end
		if scene:GetName() == "gamepad_banking" then
			if newState == SCENE_SHOWN then
				KEYBIND_STRIP:AddKeybindButton(bankingButton)
				return
			end
			bankDialogHidden = true
			if newState == SCENE_HIDDEN then
				KEYBIND_STRIP:RemoveKeybindButton(bankingButton)
				if dropdownsBeforeBank then
					categoryDropdown.setFunction(nil, nil, {data = dropdownsBeforeBank.category})
					subCategoryDropdown.setFunction(nil, nil, {data = dropdownsBeforeBank.subCategory})
					pageDropdown.setFunction(nil, nil, {data = dropdownsBeforeBank.page})
					setupsDropdown.setFunction(nil, nil, {data = dropdownsBeforeBank.setup}, true)
					dropdownsBeforeBank = nil
				end
				if lastActivatedControl then
					if lastActivatedControl.Deactivate then lastActivatedControl:Deactivate() end
					lastActivatedControl = nil
				end
			end
		end
	end)
	
	local function handleActiveControl(control, _, selected)
    if not selected then return end
    if lastActivatedControl and lastActivatedControl ~= control then
        if lastActivatedControl.Deactivate then lastActivatedControl:Deactivate() end
    end
    if control.Activate then control:Activate() end
    lastActivatedControl = control
	end
	local function equalityFunction(leftData, rightData)
		return leftData == rightData.name or rightData == leftData.name or leftData.data == rightData.data
	end
	local function setupFunction(control, data)
		control:SetText(data.name)
		control:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
	end
	local function setupDialogHorizontalList(dropdown)
		return function(control, data, selected)
			control:GetNamedChild("Name"):SetText(dropdown.label)
			local combobox = control.horizontalListObject
			combobox.equalityFunction = equalityFunction
			combobox.setupFunction = setupFunction
			combobox:Clear()
			combobox:SetOnSelectedDataChangedCallback(nil)

			local items = type(dropdown.items) == "function" and dropdown.items() or dropdown.items
			for i = 1, #items do
				combobox:AddEntry(items[i])
			end
			combobox:Commit()
			combobox:SetSelectedIndex(combobox:FindIndexFromData(dropdown.getFunction(true), combobox.equalityFunction) or 0, false, true)
			combobox:SetOnSelectedDataChangedCallback(function(data)
				if dropdown.getFunction(true) ~= data.name then dropdown.setFunction(nil, nil, data, true) end
			end)
			handleActiveControl(combobox, nil, selected)
		end
	end
	local function setupDialogButton(...)
		handleActiveControl(...)
		ZO_SharedGamepadEntry_OnSetup(...)
	end
	ZO_Dialogs_RegisterCustomDialog(
		"WizardsWardrobeBankDialog",
    {
			gamepadInfo =
			{
					dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
			},

			title =
			{
					text = "Wizards Wardrobe Banking",
			},

			setup = function(dialog)
				dialog:setupFunc()
				if not dropdownsBeforeBank then
					dropdownsBeforeBank = {
						category = selectedCategory,
						subCategory = WW.selection.zone.tag,
						page = WW.selection.pageId,
						setup = setupIndex,
					}
				end
			end,

			parametricList =
			{
				{
					template = "ZO_GamepadHorizontalListRow",
					templateData =
					{
						setup = setupDialogHorizontalList(categoryDropdown)
					},
				},
				{
					template = "ZO_GamepadHorizontalListRow",
					templateData =
					{
						setup = setupDialogHorizontalList(subCategoryDropdown)
					},
				},
				{
					template = "ZO_GamepadHorizontalListRow",
					templateData =
					{
						setup = setupDialogHorizontalList(pageDropdown)
					},
				},
				{
					template = "ZO_GamepadHorizontalListRow",
					templateData =
					{
						setup = setupDialogHorizontalList(setupsDropdown)
					},
				},
				{
					template = "ZO_GamepadMenuEntryTemplate",
					templateData =
					{
						text = "Withdraw Setup",
						setup = setupDialogButton,
						callback = function(dialog) WW.banking.WithdrawSetup(WW.selection.zone, WW.selection.pageId, setupIndex) end,
					},
				},
        {
					template = "ZO_GamepadMenuEntryTemplate",
					templateData =
					{
						text = "Deposit Setup",
						setup = setupDialogButton,
						callback = function(dialog) WW.banking.DepositSetup(WW.selection.zone, WW.selection.pageId, setupIndex) end,
					},
        },
				{
					template = "ZO_GamepadMenuEntryTemplate",
					templateData =
					{
						text = "Withdraw Page",
						setup = setupDialogButton,
						callback = function(dialog)
							WW.banking.WithdrawPage(WW.selection.zone, WW.selection.pageId)
						end,
					},
				},
        {
					template = "ZO_GamepadMenuEntryTemplate",
					templateData =
					{
						text = "Deposit Page",
						setup = setupDialogButton,
						callback = function(dialog) WW.banking.DepositPage(WW.selection.zone, WW.selection.pageId) end,
					},
        },
        {
					template = "ZO_GamepadMenuEntryTemplate",
					templateData =
					{
						text = "Deposit All",
						setup = setupDialogButton,
						callback = function(dialog) WW.banking.DepositAllSetups() end,
					},
        },
    },

    buttons =
    {
			{
				text = SI_GAMEPAD_SELECT_OPTION,
				callback = function(dialog)
					local data = dialog.entryList:GetTargetData()
					if data.callback then data.callback(dialog) end
					bankDialogHidden = true
					GAMEPAD_BANKING:LayoutBankingEntryTooltip(GAMEPAD_BANKING:GetTargetData())
				end,
			},
			{
				text = SI_GAMEPAD_BACK_OPTION,
				callback = function(dialog)
					bankDialogHidden = true
					GAMEPAD_BANKING:LayoutBankingEntryTooltip(GAMEPAD_BANKING:GetTargetData())
				end,
			},
    }
	})
end
