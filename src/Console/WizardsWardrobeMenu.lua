WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.menu = {}
local WWM = WW.menu

function WWM.Init()
	WWM.InitSV()
	WWM.InitAM()
end

local addonMenuChoices = {
	names = {
		GetString( WW_MENU_COMPARISON_DEPTH_EASY ),
		GetString( WW_MENU_COMPARISON_DEPTH_DETAILED ),
		GetString( WW_MENU_COMPARISON_DEPTH_THOROUGH ),
	},
	values = {
		1,
		2,
		3
	},
	tooltips = {
		GetString( WW_MENU_COMPARISON_DEPTH_EASY_TT ),
		GetString( WW_MENU_COMPARISON_DEPTH_DETAILED_TT ),
		GetString( WW_MENU_COMPARISON_DEPTH_THOROUGH_TT ),
	}
}
function WWM.InitSV()
	WW.storage = ZO_SavedVars:NewCharacterIdSettings( "WizardsWardrobeSV", 1, nil, {
		setups = {},
		pages = {},
		prebuffs = {},
		autoEquipSetups = true,
		selectedZoneTag = 'GEN',
	} )
	WW.setups = WW.storage.setups
	WW.pages = WW.storage.pages
	WW.prebuffs = WW.storage.prebuffs

	WW.settings = ZO_SavedVars:NewAccountWide( "WizardsWardrobeSV", 1, nil, {
		panel = {
			locked = true,
			hidden = false,
			mini = false,
		},
		auto = {
			gear = true,
			skills = true,
			cp = true,
			food = false,
		},
		substitute = {
			overland = false,
			dungeons = false,
		},
		fixes = {
			surfingWeapons = false,
		},
		failedSwapLog = {},
		comparisonDepth = 1,
		changelogs = {},
		printMessages = "announcement",
		ignoreTabards = true,
		unequipEmpty = false,
		chargeWeapons = false,
		repairArmor = false,
		fillPoisons = false,
		eatBuffFood = false,
		initialized = false,
		fixGearSwap = false,
		canUseCrownRepairKits = false,
		setupValidation = {
			delay = 1500,
			ignorePoisons = true,
			ignoreCostumes = true
		},
		autoSelectInstance = true,
		autoSelectGeneral = false,
		lockSavedGear = true,
		quickslotsEnabled = false,
		resetToOriginalQuickslot = false,
		quickslots = {}
	} )

	-- migrate validation settings
	if WW.settings.validationDelay then
		WW.settings.setupValidation.delay = WW.settings.validationDelay
		WW.settings.validationDelay = nil
	end
	-- migrate printMessage settings
	if WW.settings.printMessages == true then
		WW.settings.printMessages = "chat"
	elseif WW.settings.printMessages == false then
		WW.settings.printMessages = "off"
	end
	-- migrate comparisonDepth settings
	if WW.settings.comparisonDepth == 4 then
		WW.settings.comparisonDepth = 1
	end
	-- dont look at this
	WW.settings.autoEquipSetups = WW.storage.autoEquipSetups
end

function WWM.InitAM()
	local panelData = {
		type = "panel",
		name = "Wizards Wardrobe",
		displayName = "Wizards Wardrobe",
		author = "STUDLETON",
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
			name = GetString( WW_MENU_GENERAL ),
		},

		{
			type = "dropdown",
			name = GetString( WW_MENU_PRINTCHAT ),
			choices = {
				GetString( WW_MENU_PRINTCHAT_OFF ),
				GetString( WW_MENU_PRINTCHAT_CHAT ),
				GetString( WW_MENU_PRINTCHAT_ALERT ),
				GetString( WW_MENU_PRINTCHAT_ANNOUNCEMENT )
			},
			choicesValues = { "off", "chat", "alert", "announcement" },
			getFunc = function() return WW.settings.printMessages end,
			setFunc = function( value ) WW.settings.printMessages = value end,
			tooltip = GetString( WW_MENU_PRINTCHAT_TT ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_LOCKSAVEDGEAR ),
			getFunc = function() return WW.settings.lockSavedGear end,
			setFunc = function( value ) WW.settings.lockSavedGear = value end,
			tooltip = GetString( WW_MENU_LOCKSAVEDGEAR_TT ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_UNEQUIPEMPTY ),
			getFunc = function() return WW.settings.unequipEmpty end,
			setFunc = function( value ) WW.settings.unequipEmpty = value end,
			tooltip = GetString( WW_MENU_UNEQUIPEMPTY_TT ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_IGNORE_TABARDS ),
			getFunc = function() return WW.settings.ignoreTabards end,
			setFunc = function( value ) WW.settings.ignoreTabards = value end,
			tooltip = GetString( WW_MENU_IGNORE_TABARDS_TT ),
			disabled = function() return not WW.settings.unequipEmpty end, -- only enabled if unequip empty is true

		},
		{
			type = "header",
			name = "Setup Validation",

		},
		{
			type = "dropdown",
			name = GetString( WW_MENU_COMPARISON_DEPTH ),
			choices = addonMenuChoices.names,
			choicesValues = addonMenuChoices.values,
			choicesTooltips = addonMenuChoices.tooltips,
			disabled = function() return false end,
			scrollable = true,
			getFunc = function() return WW.settings.comparisonDepth end,
			setFunc = function( var ) WW.settings.comparisonDepth = var end,
			width = "full",
		},

		{
			type = "slider",
			name = GetString( WW_MENU_VALIDATION_DELAY ),
			tooltip = GetString( WW_MENU_VALIDATION_DELAY_TT ),
			warning = GetString( WW_MENU_VALIDATION_DELAY_WARN ),
			getFunc = function() return WW.settings.setupValidation.delay end,
			setFunc = function( value )
				WW.settings.setupValidation.delay = value
			end,
			step = 10,
			min = 1500,
			max = 4500,
			clampInput = false,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_COMPARISON_IGNORE_COSTUME_SLOTS ),
			getFunc = function() return WW.settings.setupValidation.ignoreCostumes end,
			setFunc = function( value ) WW.settings.setupValidation.ignoreCostumes = value end,
			tooltip = GetString( WW_MENU_COMPARISON_IGNORE_COSTUME_SLOTS_TT ),

		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_COMPARISON_IGNORE_POISON_SLOTS ),
			getFunc = function() return WW.settings.setupValidation.ignorePoisons end,
			setFunc = function( value ) WW.settings.setupValidation.ignorePoisons = value end,
			tooltip = GetString( WW_MENU_COMPARISON_IGNORE_POISON_SLOTS_TT ),

		},

		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "button",
			name = GetString( WW_MENU_RESETUI ),
			func = WW.gui.ResetUI,
			warning = GetString( WW_MENU_RESETUI_TT ),
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "header",
			name = GetString( WW_MENU_AUTOEQUIP ),
		},
		{
			type = "description",
			text = GetString( WW_MENU_AUTOEQUIP_DESC ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_AUTOEQUIP_SETUP ),
			getFunc = function() return WW.storage.autoEquipSetups end,
			setFunc = function( value ) 
				WW.storage.autoEquipSetups = value 
				WW.settings.autoEquipSetups = value
				end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_AUTOEQUIP_GEAR ),
			getFunc = function() return WW.settings.auto.gear end,
			setFunc = function( value ) WW.settings.auto.gear = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_AUTOEQUIP_SKILLS ),
			getFunc = function() return WW.settings.auto.skills end,
			setFunc = function( value ) WW.settings.auto.skills = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_AUTOEQUIP_CP ),
			getFunc = function() return WW.settings.auto.cp end,
			setFunc = function( value ) WW.settings.auto.cp = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_AUTOEQUIP_BUFFFOOD ),
			getFunc = function() return WW.settings.auto.food end,
			setFunc = function( value ) WW.settings.auto.food = value end,
			width = "half",
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "header",
			name = GetString( WW_MENU_AUTO_ZONE_SELECT ),
		},
		{
			type = "description",
			text = GetString( WW_MENU_AUTO_ZONE_SELECT_DESCRIPTION ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_AUTO_SELECT_INSTANCE ),
			getFunc = function() return WW.settings.autoSelectInstance end,
			setFunc = function( value ) WW.settings.autoSelectInstance = value end,
			tooltip = GetString( WW_MENU_AUTO_SELECT_INSTANCE_TT ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_AUTO_SELECT_GENERAL ),
			getFunc = function() return WW.settings.autoSelectGeneral end,
			setFunc = function( value ) WW.settings.autoSelectGeneral = value end,
			tooltip = GetString( WW_MENU_AUTO_SELECT_GENERAL_TT ),
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "header",
			name = GetString( WW_MENU_SUBSTITUTE ),
		},
		{
			type = "description",
			text = GetString( WW_MENU_SUBSTITUTE_WARNING ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_SUBSTITUTE_OVERLAND ),
			getFunc = function() return WW.settings.substitute.overland end,
			setFunc = function( value ) WW.settings.substitute.overland = value end,
			tooltip = GetString( WW_MENU_SUBSTITUTE_OVERLAND_TT ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_SUBSTITUTE_DUNGEONS ),
			getFunc = function() return WW.settings.substitute.dungeons end,
			setFunc = function( value ) WW.settings.substitute.dungeons = value end,
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "header",
			name = GetString( WW_MENU_PANEL ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_PANEL_ENABLE ),
			getFunc = function() return not WW.settings.panel.hidden end,
			setFunc = function( value )
				WW.settings.panel.hidden = not value
				WizardsWardrobePanel.fragment:Refresh()
			end,
			tooltip = GetString( WW_MENU_PANEL_ENABLE_TT ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_PANEL_MINI ),
			getFunc = function() return WW.settings.panel.mini end,
			setFunc = function( value )
				WW.settings.panel.mini = value
				ReloadUI()
			end,
			disabled = function() return WW.settings.panel.hidden end,
			tooltip = GetString( WW_MENU_PANEL_MINI_TT ),
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_PANEL_LOCK ),
			getFunc = function() return WW.settings.panel.locked end,
			setFunc = function( value )
				WW.settings.panel.locked = value
				WizardsWardrobePanel:SetMovable( not value )
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
			name = GetString( WW_MENU_MODULES ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_CHARGEWEAPONS ),
			getFunc = function() return WW.settings.chargeWeapons end,
			setFunc = function( value )
				WW.settings.chargeWeapons = value
				WW.repair.RegisterChargeEvents()
			end,
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_REPAIRARMOR ),
			getFunc = function() return WW.settings.repairArmor end,
			setFunc = function( value )
				WW.settings.repairArmor = value
				WW.repair.RegisterRepairEvents()
			end,
			tooltip = GetString( WW_MENU_REPAIRARMOR_TT ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_KITCHOICE ),
			getFunc = function() return WW.settings.canUseCrownRepairKits end,
			setFunc = function( value )
				WW.settings.canUseCrownRepairKits = value
			end,
			tooltip = GetString( WW_MENU_KITCHOICE_TT ),
			disabled = function() return not WW.settings.repairArmor end,
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_FILLPOISONS ),
			getFunc = function() return WW.settings.fillPoisons end,
			setFunc = function( value )
				WW.settings.fillPoisons = value
				WW.poison.RegisterEvents()
			end,
			tooltip = GetString( WW_MENU_FILLPOISONS_TT ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_BUFFFOOD ),
			getFunc = function() return WW.settings.eatBuffFood end,
			setFunc = function( value )
				WW.settings.eatBuffFood = value
				WW.food.RegisterEvents()
			end,
			tooltip = GetString( WW_MENU_BUFFFOOD_TT ),
		},
		{
			type = "checkbox",
			name = GetString( WW_MENU_FIXES_FIXSURFINGWEAPONS ),
			getFunc = function() return WW.settings.fixes.surfingWeapons end,
			setFunc = function( value )
				WW.settings.fixes.surfingWeapons = value
			end,
			tooltip = GetString( WW_MENU_FIXES_FIXSURFINGWEAPONS_TT ),
		},
		{
			type = "header",
			name = "Delete log",
		},
		{
			type = "button",
			name = "Delete",
			danger = true,
			func = function() WW.settings.failedSwapLog = {} end,
			width = "full",
		},

	}

	WWM.panel = LibAddonMenu2:RegisterAddonPanel( "WizardsWardrobeMenu", panelData )
	LibAddonMenu2:RegisterOptionControls( "WizardsWardrobeMenu", optionData )
end
