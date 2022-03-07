WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.menu = {}
local WWM = WW.menu

function WWM.Init()
	WWM.InitSV()
	WWM.InitAM()
end

function WWM.InitSV()
	WW.storage = ZO_SavedVars:NewCharacterIdSettings("WizardsWardrobeSV", 1, nil, {
		setups = {},
		pages = {},
		prebuffs = {},
		autoEquipSetups = true,
	})
	WW.setups = WW.storage.setups
	WW.pages = WW.storage.pages
	WW.prebuffs = WW.storage.prebuffs
	
	WW.settings = ZO_SavedVars:NewAccountWide("WizardsWardrobeSV", 1, nil, {
		window = {
			wizard = {
				width = 358,
				height = 665,
				scale = 1,
				locked = false,
			},
		},
		panel = {
			locked = true,
			hidden = false,
			mini = false,
		},
		auto = {
			gear = true,
			skills = true,
			cp = true,
			food = true,
		},
		substitute = {
			overland = false,
			dungeons = false,
		},
		printMessages = true,
		overwriteWarning = true,
		inventoryMarker = true,
		unequipEmpty = false,
		chargeWeapons = false,
		repairArmor = false,
		fillPoisons = false,
		eatBuffFood = false,
		initialized = false,
	})
	
	-- dont look at this
	WW.settings.autoEquipSetups = WW.storage.autoEquipSetups
end

function WWM.InitAM()
	
	local panelData = {
		type = "panel",
		name = WW.simpleName,
		displayName = WW.displayName:upper(),
		author = "ownedbynico",
		version = WW.version,
		registerForRefresh = true,
	}
	
	local optionData = {
		{
			type = "description",
			text = "Throw all your setups into the wardrobe and let the wizard equip them exactly when you need it.",
		},
		{
			type = "header",
			name = GetString(WW_MENU_GENERAL),
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_PRINTCHAT),
			getFunc = function() return WW.settings.printMessages end,
			setFunc = function(value) WW.settings.printMessages = value end,
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_OVERWRITEWARNING),
			getFunc = function() return WW.settings.overwriteWarning end,
			setFunc = function(value) WW.settings.overwriteWarning = value end,
			tooltip = GetString(WW_MENU_OVERWRITEWARNING_TT),
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_INVENTORYMARKER),
			getFunc = function() return WW.settings.inventoryMarker end,
			setFunc = function(value) WW.settings.inventoryMarker = value end,
			tooltip = GetString(WW_MENU_INVENTORYMARKER_TT),
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_UNEQUIPEMPTY),
			getFunc = function() return WW.settings.unequipEmpty end,
			setFunc = function(value) WW.settings.unequipEmpty = value end,
			tooltip = GetString(WW_MENU_UNEQUIPEMPTY_TT),
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "button",
			name = GetString(WW_MENU_RESETUI),
			func = WW.gui.ResetUI,
			warning = GetString(WW_MENU_RESETUI_TT),
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "header",
			name = GetString(WW_MENU_AUTOEQUIP),
		},
		{
			type = "description",
			text = GetString(WW_MENU_AUTOEQUIP_DESC),
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_AUTOEQUIP_GEAR),
			getFunc = function() return WW.settings.auto.gear end,
			setFunc = function(value) WW.settings.auto.gear = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_AUTOEQUIP_SKILLS),
			getFunc = function() return WW.settings.auto.skills end,
			setFunc = function(value) WW.settings.auto.skills = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_AUTOEQUIP_CP),
			getFunc = function() return WW.settings.auto.cp end,
			setFunc = function(value) WW.settings.auto.cp = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_AUTOEQUIP_BUFFFOOD),
			getFunc = function() return WW.settings.auto.food end,
			setFunc = function(value) WW.settings.auto.food = value end,
			width = "half",
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "header",
			name = GetString(WW_MENU_SUBSTITUTE),
		},
		{
			type = "description",
			text = GetString(WW_MENU_SUBSTITUTE_WARNING),
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_SUBSTITUTE_OVERLAND),
			getFunc = function() return WW.settings.substitute.overland end,
			setFunc = function(value) WW.settings.substitute.overland = value end,
			tooltip = GetString(WW_MENU_SUBSTITUTE_OVERLAND_TT),
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_SUBSTITUTE_DUNGEONS),
			getFunc = function() return WW.settings.substitute.dungeons end,
			setFunc = function(value) WW.settings.substitute.dungeons = value end,
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "header",
			name = GetString(WW_MENU_PANEL),
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_PANEL_ENABLE),
			getFunc = function() return not WW.settings.panel.hidden end,
			setFunc = function(value)
						WW.settings.panel.hidden = not value
						WizardsWardrobePanel.fragment:Refresh()
					  end,
			tooltip = GetString(WW_MENU_PANEL_ENABLE_TT),
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_PANEL_MINI),
			getFunc = function() return WW.settings.panel.mini end,
			setFunc = function(value)
						WW.settings.panel.mini = value
					  end,
			disabled = function() return WW.settings.panel.hidden end,
			tooltip = GetString(WW_MENU_PANEL_MINI_TT),
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_PANEL_LOCK),
			getFunc = function() return WW.settings.panel.locked end,
			setFunc = function(value)
						WW.settings.panel.locked = value
						WizardsWardrobePanel:SetMovable(not value)
					  end,
			disabled = function() return WW.settings.panel.hidden end,
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "header",
			name = GetString(WW_MENU_MODULES),
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_CHARGEWEAPONS),
			getFunc = function() return WW.settings.chargeWeapons end,
			setFunc = function(value)
						WW.settings.chargeWeapons = value
						WW.repair.RegisterChargeEvents()
					  end,
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_REPAIRARMOR),
			getFunc = function() return WW.settings.repairArmor end,
			setFunc = function(value)
						WW.settings.repairArmor = value
						WW.repair.RegisterRepairEvents()
					  end,
			tooltip = GetString(WW_MENU_REPAIRARMOR_TT),
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_FILLPOISONS),
			getFunc = function() return WW.settings.fillPoisons end,
			setFunc = function(value)
						WW.settings.fillPoisons = value
						WW.poison.RegisterEvents()
					  end,
			tooltip = GetString(WW_MENU_FILLPOISONS_TT),
		},
		{
			type = "checkbox",
			name = GetString(WW_MENU_BUFFFOOD),
			getFunc = function() return WW.settings.eatBuffFood end,
			setFunc = function(value)
						WW.settings.eatBuffFood = value
						WW.food.RegisterEvents()
					  end,
			tooltip = GetString(WW_MENU_BUFFFOOD_TT),
		},
	}
	
	WWM.panel = LibAddonMenu2:RegisterAddonPanel("WizardsWardrobeMenu", panelData)
	LibAddonMenu2:RegisterOptionControls("WizardsWardrobeMenu", optionData)
end