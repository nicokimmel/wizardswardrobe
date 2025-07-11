WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.gui = WW.gui or {}
local WWG = WW.gui

local PANEL_WIDTH = 245
local PANEL_HEIGHT = 70
local PANEL_WIDTH_MINI = PANEL_WIDTH - 70
local PANEL_HEIGHT_MINI = PANEL_HEIGHT - 30

local PANEL_DEFAULT_TOP = ActionButton8:GetTop() - 10
local PANEL_DEFAULT_LEFT = ActionButton8:GetLeft() + ActionButton8:GetWidth() + 2

local WINDOW_WIDTH = 360
local WINDOW_HEIGHT = 665

local TITLE_HEIGHT = 50
local TOP_MENU_HEIGHT = 50
local PAGE_MENU_HEIGHT = 40
local BOTTOM_MENU_HEIGHT = 36
local DIVIDER_HEIGHT = 2

local SETUP_BOX_WIDTH = 350
local SETUP_BOX_HEIGHT = 128

function WWG.Init()
	WWG.name = WW.name .. "Gui"
	WWG.setupTable = {}

	WWG.SetupPanel()

	WWG.RegisterEvents()
end

function WWG.RegisterEvents()
	EVENT_MANAGER:RegisterForEvent( WWG.name, EVENT_PLAYER_DEAD, function() WizardsWardrobePanel.fragment:Refresh() end )
	EVENT_MANAGER:RegisterForEvent( WWG.name, EVENT_PLAYER_ALIVE, function() WizardsWardrobePanel.fragment:Refresh() end )
end

function WWG.ResetUI()
	WW.settings.panel = {
		top = PANEL_DEFAULT_TOP,
		left = PANEL_DEFAULT_LEFT,
		locked = true,
		hidden = false,
		setup = true,
	}
	WizardsWardrobePanel:ClearAnchors()
	WizardsWardrobePanel:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, PANEL_DEFAULT_LEFT, PANEL_DEFAULT_TOP )
end

function WWG.SetupPanel()
	WizardsWardrobePanel.fragment = ZO_SimpleSceneFragment:New( WizardsWardrobePanel )
	WizardsWardrobePanel.fragment:SetConditional( function()
		return not WW.settings.panel.hidden and not IsUnitDead( "player" )
	end )
	HUD_SCENE:AddFragment( WizardsWardrobePanel.fragment )
	HUD_UI_SCENE:AddFragment( WizardsWardrobePanel.fragment )
	zo_callLater( function() WizardsWardrobePanel.fragment:Refresh() end, 1 )

	WizardsWardrobePanelTopLabel:SetText( WW.displayName:upper() )
	WizardsWardrobePanelMiddleLabel:SetText( "Version " .. WW.version )
	WizardsWardrobePanelBottomLabel:SetText( "@ownedbynico" )

	if WW.settings.panel and WW.settings.panel.mini then
		WizardsWardrobePanel:SetDimensions( PANEL_WIDTH_MINI, PANEL_HEIGHT_MINI )
		WizardsWardrobePanelBG:SetHidden( true )
		WizardsWardrobePanelIcon:SetHidden( true )
		WizardsWardrobePanelTopLabel:SetHidden( true )
		WizardsWardrobePanelMiddleLabel:SetAnchor( TOPLEFT, WizardsWardrobePanel, TOPLEFT )
		WizardsWardrobePanelBottomLabel:SetAnchor( BOTTOMLEFT, WizardsWardrobePanel, BOTTOMLEFT )
	end

	if WW.settings.panel and WW.settings.panel.top and WW.settings.panel.setup then
		WizardsWardrobePanel:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, WW.settings.panel.left, WW.settings.panel.top )
		WizardsWardrobePanel:SetMovable( not WW.settings.panel.locked )
	else
		WW.settings.panel = {
			top = PANEL_DEFAULT_TOP,
			left = PANEL_DEFAULT_LEFT,
			locked = true,
			hidden = false,
			setup = true,
		}
		WizardsWardrobePanel:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, PANEL_DEFAULT_LEFT, PANEL_DEFAULT_TOP )
	end
end

function WWG.OnPanelMove()
	WW.settings.panel.top = WizardsWardrobePanel:GetTop()
	WW.settings.panel.left = WizardsWardrobePanel:GetLeft()
end

function WWG.SetPanelText( zoneTag, pageName, setupName )
	local middleText = string.format( "%s / %s", zoneTag, pageName )
	WizardsWardrobePanelMiddleLabel:SetText( middleText )

	local logColor = IsUnitInCombat( "player" ) and WW.LOGTYPES.INFO or WW.LOGTYPES.NORMAL
	local middleText = string.format( "|c%s%s|r", logColor, setupName )
	WizardsWardrobePanelBottomLabel:SetText( middleText )

	if IsUnitInCombat( "player" ) then
		WW.queue.Push( function()
			middleText = string.format( "|c%s%s|r", WW.LOGTYPES.NORMAL, setupName )
			WizardsWardrobePanelBottomLabel:SetText( middleText )
		end )
	end
end

function WWG.OnZoneSelect( zone )
	if (WW.currentZoneId ~= 0) then
		WW.storage.selectedZoneTag = zone.tag
	end
	
	if not WW.pages[ zone.tag ] then
		WWG.CreatePage( zone )
	end
	
	WW.selection.zone = zone
	WW.selection.pageId = WW.pages[ zone.tag ][ 0 ].selected
	WW.conditions.LoadConditions()
end

function WWG.CreateSetup()
	local tag = WW.selection.zone.tag
	local pageId = WW.selection.pageId
	local index = #WW.setups[tag][pageId] + 1

	local setup = Setup:FromStorage( tag, pageId, index )
	setup:ToStorage( tag, pageId, index )
end

function WWG.CreatePage( zone )
	if not WW.pages[ zone.tag ] then
		WW.pages[ zone.tag ] = {}
		WW.pages[ zone.tag ][ 0 ] = {}
		WW.pages[ zone.tag ][ 0 ].selected = 1
	end

	local nextPageId = #WW.pages[ zone.tag ] + 1
	WW.pages[ zone.tag ][ nextPageId ] = {
		name = string.format( GetString( WW_PAGE ), tostring( nextPageId ) ),
	}

	WW.pages[ zone.tag ][ 0 ].selected = nextPageId
	WW.selection.pageId = nextPageId

	WWG.CreateDefaultSetups( zone, nextPageId )

	return nextPageId
end

function WWG.CreateDefaultSetups( zone, pageId )
	if zone.tag == "GEN" or zone.tag == "PVP" then
		local setup = Setup:FromStorage( zone.tag, pageId, 1 )
		setup:ToStorage( zone.tag, pageId, 1 )
		return
	end
	
	for i, boss in ipairs( zone.bosses ) do
		local setup = Setup:FromStorage( zone.tag, pageId, i )
		setup:SetName( boss.displayName or boss.name )
		setup:SetCondition( {
			boss = boss.name,
			trash = (boss.name == GetString( WW_TRASH )) and WW.CONDITIONS.EVERYWHERE or nil
		} )
		setup:ToStorage( zone.tag, pageId, i )
	end
end

function WWG.DuplicatePage()
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	local pageName = WW.pages[ zone.tag ][ pageId ].name
	local newIndex = pageId + 1
	
	table.insert(WW.pages[ zone.tag ], newIndex, ZO_DeepTableCopy( WW.setups[ zone.tag ][ pageId ] ) )
	WW.pages[ zone.tag ][ newIndex ].name = string.format( GetString( WW_DUPLICATE_NAME ), pageName )
	table.insert(WW.setups[ zone.tag ], newIndex, ZO_DeepTableCopy( WW.setups[ zone.tag ][ pageId ] ))
end

function WWG.DeletePage()
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId

	-- this is a workaround for empty pages
	-- dont ask me why
	if #WWG.setupTable == 0 then
		WWG.CreateSetup()
	end

	local nextPageId = pageId - 1
	if nextPageId < 1 then nextPageId = pageId end

	WW.pages[ zone.tag ][ 0 ].selected = nextPageId
	WW.selection.pageId = nextPageId

	table.remove( WW.setups[ zone.tag ], pageId )
	table.remove( WW.pages[ zone.tag ], pageId )

	return nextPageId
end

function WWG.RenamePage()
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId

	local initialText = WW.pages[ zone.tag ][ pageId ].name
	WWG.ShowEditDialog( "PageNameEdit", GetString( WW_RENAME_PAGE ), initialText,
		function( input )
			if not input then
				return
			end
			if input == "" then
				WW.pages[ zone.tag ][ pageId ].name = GetString( WW_UNNAMED )
			else
				WW.pages[ zone.tag ][ pageId ].name = input
			end
			WWG.SetupPagesDropdown()
			WWG.tree:RefreshTree( WWG.tree.tree, zone )
		end )
end