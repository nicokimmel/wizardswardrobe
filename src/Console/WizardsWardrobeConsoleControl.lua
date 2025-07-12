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
	local menuName = "Wizards Wardrobe Control"
	local settings = LibHarvensAddonSettings:AddAddon(menuName, options)
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
	local selectedName = ""
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
	
	local sceneHidden = true
	SCENE_MANAGER:RegisterCallback( "SceneStateChanged", function(scene, oldState, newState)
		if scene:GetName() == "LibHarvensAddonSettingsScene" then
			if newState == SCENE_SHOWN and settings.selected then
				-- the tooltip doesn't show if called right away, and the first time it's called it has anxiety; scrunched up
				-- calling it again after it calms down, look into fixing properly later
				zo_callLater(function()
					if not sceneHidden then
						showSetupList()
						zo_callLater(function()
							if not sceneHidden then
								showSetupList()
							end
						end, 500)
					end
				end, 500) 
				sceneHidden = false
				return
			end
			sceneHidden = true
		end
	end)

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

	local pageItems = {}
	for zoneTag, zone in pairs(WW.zones) do
		table.insert(pageItems, { name = zone.name, data = zoneTag })
	end
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
		disable = function() return areSettingsDisabled end,
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
		selectedName = setupItems[setupIndex].name
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
		containerControl:GetNamedChild("Name"):SetText(selectedName)
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
		local cpContainer = containerControl:GetNamedChild("CP")
		for cpIndex = 1, 12 do
			local cpControl = cpContainer:GetChild(cpIndex)
			local cpIcon = cpControl:GetNamedChild("Icon")
			cpIcon:SetHidden(true)
			local cpLabel = cpControl:GetNamedChild("Label")
			cpLabel:SetText( "-/-" )
			local cpId = setup.cp[cpIndex]
			if cpId then
				local cpName = zo_strformat( "<<C:1>>", GetChampionSkillName( cpId ) )
				if #cpName > 0 then
					local text = string.format( "|c%s%s|r", WW.CPCOLOR[cpIndex], cpName )
					cpLabel:SetText( text )
					cpIcon:SetTexture(WW.CPICONS[cpIndex])
					cpIcon:SetHidden(false)
				end
			end
		end
	end
	local rearrangeDropdownSetting = nil
	local setupsDropdown = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Setups",
		tooltip = "Setup Preview",
		setFunction = function(combobox, name, item)
			setupIndex = findSetupItemIndex(item)
			rearrangeSelectedIndex = setupIndex
			selectedName = setupItems[setupIndex].name
			if quickEquipChecked then 
				WW.LoadSetupCurrent(setupIndex)
			end
			if setupDropdownSetting.control == LibHarvensAddonSettings.list:GetSelectedControl() then showSetupPreview() end
			showSetupList()
		end,
		getFunction = function()
			if setupDropdownSetting.control == LibHarvensAddonSettings.list:GetSelectedControl() then zo_callLater(showSetupPreview,0) end
			return selectedName
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
			selectedName = setupItems[setupIndex].name
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
			WW.DeleteSetup( WW.selection.zone, WW.selection.pageId, setupIndex )
			if WW.selection.zone.tag == equipped.zone and WW.selection.pageId == equipped.page and equipped.setup == setupIndex then equipped.setup = nil end
			setupIndex = setupIndex - 1
			rearrangeSelectedIndex = setupIndex
			selectedName = setupItems[setupIndex].name
			LibHarvensAddonSettings:RefreshAddonSettings()
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
			selectedName = value
			showSetupList()
		end,
		getFunction = function() return selectedName end,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(renameSetup)

	local panelSection = {
		type = LibHarvensAddonSettings.ST_SECTION,
		label = "Panel Position",
	}
	settings:AddSetting(panelSection)

	local incSliderValue = 100
	local incSlider = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Reposition increments",
		tooltip = "Multiplier to move the panel quicker/slower",
		setFunction = function(value) incSliderValue = value end,
		getFunction = function() return incSliderValue end,
		min = 1,
		max = 100,
		step = 10,
		disable = function() return areSettingsDisabled end,
	}
	settings:AddSetting(incSlider)

	local function temporarilyShowPanel()
		SCENE_MANAGER:GetCurrentScene():AddFragment(WizardsWardrobePanel.fragment)
		WizardsWardrobePanel:SetDrawTier(2)
		WizardsWardrobePanel:SetDrawLayer(2)
		
		EVENT_MANAGER:UnregisterForUpdate("WizardsWardrobePanelMove")
		EVENT_MANAGER:RegisterForUpdate("WizardsWardrobePanelMove", 5000, function()
			SCENE_MANAGER:GetCurrentScene():RemoveFragment(WizardsWardrobePanel.fragment)
			WizardsWardrobePanel:SetDrawTier(0)
			WizardsWardrobePanel:SetDrawLayer(1)
			EVENT_MANAGER:UnregisterForUpdate("WizardsWardrobePanelMove")
		end)
	end
	
	local xSliderSetting
	local xSlider = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Panel X",
		tooltip = "Move the panel left or right",
		setFunction = function(value)
			temporarilyShowPanel()
			local offset = (value - WW.settings.panel.left) * incSliderValue
			WW.settings.panel.left = WW.settings.panel.left + offset
			xSliderSetting:UpdateControl()
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
	local ySlider = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Panel Y",
		tooltip = "Move the panel up or down",
		setFunction = function(value)	
			temporarilyShowPanel()
			local offset = (value - WW.settings.panel.top) * incSliderValue
			WW.settings.panel.top = WW.settings.panel.top + offset
			ySliderSetting:UpdateControl()
			WizardsWardrobePanel:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, WW.settings.panel.left, WW.settings.panel.top )
		end,
		getFunction = function() return WW.settings.panel.top end,
		min = 0,
		max = GuiRoot:GetWidth(),
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
	
	local lastQuickslot = GetCurrentQuickslot()
	local function onQuickslotSelected(_, slotIndex)
		if WW.settings.quickslots[slotIndex] and quickslotActions[WW.settings.quickslots[slotIndex]] then
			quickslotActions[WW.settings.quickslots[slotIndex]]()
			if WW.settings.resetToOriginalQuickslot then 
				SetCurrentQuickslot(lastQuickslot)
				return
			end
		end
		lastQuickslot = slotIndex
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
		return not WW.settings.resetToOriginalQuickslot and (WW.settings.quickslots[lastQuickslot] and WW.settings.quickslots[lastQuickslot] > 1)
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
		return WW.settings.resetToOriginalQuickslot and lastQuickslot == selectedQuickslot
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
end
