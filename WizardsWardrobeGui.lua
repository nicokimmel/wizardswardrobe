WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.gui = WW.gui or {}
local WWG = WW.gui

local SETUP_BOX_HEIGHT = 128
local SETUP_BOX_WIDTH = 350
local SETUP_BOX_OFFSET = 10

function WWG.Init()
	WWG.name = WW.name .. "Gui"
	
	WWG.zones = {}
	
	WWG.RegisterEvents()
	WWG.CreateWindow()
	WWG.CreatePanel()
	WWG.SetSceneManagement()
	WWG.CreateScrollContainerParent()
	WWG.CreatePageMenu()
	WWG.CreateBottomMenu()
	WWG.CreateTopMenu()
	WWG.HandleFirstStart()
end

function WWG.RegisterEvents()
	
end

function WWG.HandleFirstStart()
	local function HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, dataString)
		if linkType ~= WW.URL_LINK_TYPE then return end
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if dataString == "esoui" then
				RequestOpenUnsafeURL("https://www.esoui.com/downloads/info3170-WizardsWardrobe.html")
			end
		end
		return true
	end
	LibChatMessage:RegisterCustomChatLink(WW.URL_LINK_TYPE, function(linkStyle, linkType, data, displayText)
		return ZO_LinkHandler_CreateLinkWithoutBrackets(displayText, nil, WW.URL_LINK_TYPE, data)
	end)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, HandleClickEvent)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, HandleClickEvent)
	zo_callLater(function()
		if not WW.settings.initialized then
			local urlLink = ZO_LinkHandler_CreateLink("esoui.com", nil, WW.URL_LINK_TYPE, "esoui")
			local pattern = string.format("|c18bed8[|c65d3b0W|cb2e789W|cfffc61]|r |cFFFFFF%s|r", GetString(WW_MSG_FIRSTSTART))
			local output = string.format(pattern, "|r" .. urlLink .. "|cFFFFFF")
			CHAT_ROUTER:AddSystemMessage(output)
			WW.settings.initialized = true
		end
	end, 500)
end

function WWG.SetSceneManagement()
	local onSceneChange = function(scene, oldState, newState)	
		local sceneName = scene:GetName()
		
		if sceneName == "gameMenuInGame" then return end
		
		if newState == SCENE_SHOWING then
			local savedScene = WW.settings.window[sceneName]
			if savedScene then
				if not savedScene.hidden then
					WWG.window:ClearAnchors()
					WWG.window:SetAnchor(TOPLEFT, GUI_ROOT, TOPLEFT, savedScene.left, savedScene.top)
					WWG.window:SetHidden(false)
				end
			end
		end
		
		-- looks better when window hides faster
		if newState == SCENE_HIDING then
			local savedScene = WW.settings.window[sceneName]
			if savedScene then
				WWG.window:SetHidden(true)
			end
			if sceneName == "hud" or sceneName == "hudui" then
				if not WW.settings.window[sceneName] then
					WW.settings.window[sceneName] = {
						top = WWG.window:GetTop(),
						left = WWG.window:GetLeft(),
						hidden = true,
					}
				end
				WW.settings.window[sceneName].hidden = true
			end
		end
	end
	SCENE_MANAGER:RegisterCallback("SceneStateChanged", onSceneChange)
	
	-- quickslot tab will act like a independent scene
	QUICKSLOT_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		local quickslot = {
			GetName = function(GetName)
				return "inventoryQuickslot"
			end
		}
		local inventoryScene = SCENE_MANAGER:GetScene("inventory")
		if newState == SCENE_SHOWING then
			onSceneChange(inventoryScene, SCENE_SHOWN, SCENE_HIDING)
			onSceneChange(quickslot, SCENE_HIDDEN, SCENE_SHOWING)
		elseif newState == SCENE_HIDING then
			if inventoryScene:IsShowing() then
				onSceneChange(quickslot, SCENE_SHOWN, SCENE_HIDING)
				onSceneChange(inventoryScene, SCENE_HIDDEN, SCENE_SHOWING)
			else
				onSceneChange(quickslot, SCENE_SHOWN, SCENE_HIDING)
			end
		end
	end)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
		if panel:GetName() ~= "WizardsWardrobeMenu" then return end
		local icon = WINDOW_MANAGER:CreateControl("WizardsWardrobeMenuIcon", panel, CT_TEXTURE)
		icon:SetTexture("/WizardsWardrobe/assets/icon64.dds")
		icon:SetDimensions(64, 64)
		icon:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -45, -25)
    end)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel:GetName() ~= "WizardsWardrobeMenu" then return end
		WWG.window:ClearAnchors()
		WWG.window:SetAnchor(CENTER, GUI_ROOT, RIGHT, -(WWG.window:GetWidth() / 2 + 50), 0)
		WWG.window:SetHidden(false)
		PlaySound(SOUNDS.DEFAULT_WINDOW_OPEN)
    end)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
		if panel:GetName() ~= "WizardsWardrobeMenu" then return end
		WWG.window:SetHidden(true)
    end)
	
	SLASH_COMMANDS["/wizard"] = function()
		local scene = SCENE_MANAGER:GetCurrentScene()
		local sceneName = scene:GetName()
		if sceneName == "gameMenuInGame" then
			WWG.window:SetHidden(not WWG.window:IsHidden())
			return
		end
		if sceneName == "inventory" and QUICKSLOT_FRAGMENT:IsShowing() then
			sceneName = "inventoryQuickslot"
		end
		local savedScene = WW.settings.window[sceneName]
		if savedScene then
			if savedScene.hidden then
				-- open
				WWG.window:ClearAnchors()
				WWG.window:SetAnchor(TOPLEFT, GUI_ROOT, TOPLEFT, savedScene.left, savedScene.top)
				WWG.window:SetHidden(false)
				PlaySound(SOUNDS.DEFAULT_WINDOW_OPEN)
				SCENE_MANAGER:SetInUIMode(true, false)
				WW.settings.window[sceneName].hidden = false
			else
				-- close
				WWG.window:SetHidden(true)
				PlaySound(SOUNDS.DEFAULT_WINDOW_CLOSE)
				WW.settings.window[sceneName].hidden = true
			end
		else
			-- open but new
			WWG.window:ClearAnchors()
			WWG.window:SetAnchor(CENTER, GUI_ROOT, CENTER, 0, 0)
			WWG.window:SetHidden(false)
			PlaySound(SOUNDS.DEFAULT_WINDOW_OPEN)
			SCENE_MANAGER:SetInUIMode(true, false)
			WW.settings.window[sceneName] = {
				top = WWG.window:GetTop(),
				left = WWG.window:GetLeft(),
				hidden = false,
			}
		end
	end
end

function WWG.ShowSetupContextMenu(control, zone, pageId, index)
	ClearMenu()
	
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	
	-- LINK TO CHAT
	AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
		WW.preview.PrintPreviewString(zone, pageId, index)
	end, MENU_ADD_OPTION_LABEL)
	
	-- CODITIONS
	if WW.IsCustomSetup(zone, index) then
		AddMenuItem(GetString(WW_CONDITIONS), function()
			WWG.ShowConditionDialog(setup, index)
		end, MENU_ADD_OPTION_LABEL)
	end
	
	-- CUSTOM CODE
	AddMenuItem(GetString(WW_CUSTOMCODE), function() WW.code.ShowCodeDialog(zone, pageId, index) end, MENU_ADD_OPTION_LABEL)
	
	-- IMPORT / EXPORT
	AddMenuItem(GetString(WW_IMPORT), function() WW.transfer.ShowImportDialog(zone.tag, pageId, index) end, MENU_ADD_OPTION_LABEL)
	AddMenuItem(GetString(WW_EXPORT), function() WW.transfer.ShowExportDialog(zone.tag, pageId, index) end, MENU_ADD_OPTION_LABEL)
	
	-- ENABLE / DISABLE
	if setup:IsDisabled() then
		AddMenuItem(GetString(WW_ENABLE), function() WWG.SetSetupDisabled(zone, pageId, index, false) end, MENU_ADD_OPTION_LABEL)
	else
		AddMenuItem(GetString(WW_DISABLE), function() WWG.SetSetupDisabled(zone, pageId, index, true) end, MENU_ADD_OPTION_LABEL)
	end
	
	-- DELETE
	AddMenuItem(GetString(WW_DELETE):upper(), function()
		PlaySound(SOUNDS.DEFER_NOTIFICATION)
		WW.DeleteSetup(zone, pageId, index)
		WW.conditions.LoadSetups(zone, pageId) -- refresh conditions
	end, MENU_ADD_OPTION_LABEL, "ZoFontGameBold", ZO_ColorDef:New(1, 0, 0, 1), ZO_ColorDef:New(1, 0, 0, 1))
	
	-- lets fix some ZOS bugs(?)
	if control:GetWidth() >= ZO_Menu.width then
        ZO_Menu.width = control:GetWidth() - 10
    end
	
	ShowMenu(control, 2, MENU_TYPE_COMBO_BOX)
	SetMenuPad(100)
	AnchorMenu(control, 0)
end

function WWG.ShowPageContextMenu(control, zone, pageId)
	ClearMenu()
	
	AddMenuItem(GetString(WW_BUTTON_EDIT), function() WWG.PageRename() end, MENU_ADD_OPTION_LABEL)
	
	AddMenuItem(GetString(WW_DUPLICATE), function() WWG.DuplicatePage(WW.selection.zone, WW.selection.pageId) end, MENU_ADD_OPTION_LABEL)
	
	AddMenuItem(GetString(WW_DELETE):upper(), function() 
		if #WW.pages[WW.selection.zone.tag] > 1 then
			local pageName = WW.pages[WW.selection.zone.tag][WW.selection.pageId].name
			WWG.ShowConfirmationDialog("DeletePageConfirmation", string.format(GetString(WW_DELETEPAGE_WARNING), pageName),
			function()
				WWG.DeletePage(WW.selection.zone, WW.selection.pageId)
			end)
		end
	end, MENU_ADD_OPTION_LABEL, "ZoFontGameBold", ZO_ColorDef:New(1, 0, 0, 1), ZO_ColorDef:New(1, 0, 0, 1))
	
	
	-- lets fix some ZOS bugs(?)
	if control:GetWidth() >= ZO_Menu.width then
        ZO_Menu.width = control:GetWidth() - 10
    end
	
	ShowMenu(control, 2, MENU_TYPE_COMBO_BOX)
	SetMenuPad(100)
	AnchorMenu(control, 0)
end

function WWG.AddPage(zone, skipRefresh)
	if not WW.pages[zone.tag] then
		WW.pages[zone.tag] = {}
		WW.pages[zone.tag][0] = {}
		WW.pages[zone.tag][0].selected = 1
	end
	
	local nextPageId = #WW.pages[zone.tag] + 1
	WW.pages[zone.tag][nextPageId] = {
		name = string.format(GetString(WW_PAGE), tostring(nextPageId)),
	}
	
	WW.pages[zone.tag][0].selected = nextPageId
	WW.selection.pageId = nextPageId
	
	if not skipRefresh then
		WWG.RefreshPage()
	end
	
	return nextPageId
end

function WWG.DuplicatePage(zone, pageId)
	local cloneId = WWG.AddPage(zone, true)
	
	local pageName = WW.pages[zone.tag][pageId].name
	WW.pages[zone.tag][cloneId].name = string.format(GetString(WW_DUPLICATE_NAME), pageName)
	
	WW.setups[zone.tag][cloneId] = {}
	ZO_DeepTableCopy(WW.setups[zone.tag][pageId], WW.setups[zone.tag][cloneId])
	
	WWG.RefreshPage()
end

function WWG.DeletePage(zone, pageId)
	local nextPageId = pageId - 1
	if nextPageId < 1 then nextPageId = pageId end
	
	WW.pages[zone.tag][0].selected = nextPageId
	WW.selection.pageId = nextPageId
	
	table.remove(WW.pages[zone.tag], pageId)
	if WW.setups[zone.tag] and WW.setups[zone.tag][pageId] then
		table.remove(WW.setups[zone.tag], pageId)
	end
	
	WW.markers.BuildGearList()
	WWG.RefreshPage()
	
	return nextPageId
end

function WWG.PageRename()
	local initialText = WW.pages[WW.selection.zone.tag][WW.selection.pageId].name
	WWG.ShowEditDialog("PageNameEdit", GetString(WW_RENAME_PAGE), initialText,
	function(input)
		if not input then
			return
		end
		if input == "" then
			WW.pages[WW.selection.zone.tag][WW.selection.pageId].name = GetString(WW_UNNAMED)
		else
			WW.pages[WW.selection.zone.tag][WW.selection.pageId].name = input
		end
		local pageName = WW.pages[WW.selection.zone.tag][WW.selection.pageId].name
		WWG.pageLabel:SetText(pageName:upper())
	end)
end

function WWG.PageLeft()
	if WW.selection.pageId - 1 < 1 then
		return
	end
	local prevPage = WW.selection.pageId - 1
	WW.selection.pageId = prevPage
	WW.pages[WW.selection.zone.tag][0].selected = prevPage
	WWG.RefreshPage()
end

function WWG.PageRight()
	if WW.selection.pageId + 1 > #WW.pages[WW.selection.zone.tag] then
		return
	end
	local nextPage = WW.selection.pageId + 1
	WW.selection.pageId = nextPage
	WW.pages[WW.selection.zone.tag][0].selected = nextPage
	WWG.RefreshPage()
end

function WWG.RefreshPage()
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	
	for i = 1, WW.GetSetupCount(zone) do
		WWG.RefreshSetup(zone, pageId, i)
	end
	
	local pageName = WW.pages[zone.tag][pageId].name
	WWG.pageLabel:SetText(pageName:upper())
	
	if pageId == 1 then WWG.pageLeft:SetEnabled(false) else WWG.pageLeft:SetEnabled(true) end
	if pageId == #WW.pages[zone.tag] then WWG.pageRight:SetEnabled(false) else WWG.pageRight:SetEnabled(true) end
	
	WW.conditions.LoadSetups(zone, pageId)
	
	local missingGear = WW.CheckGear(zone, pageId)
	if #missingGear > 0 then
		WWG.pageWarning:SetHidden(false)
		local missingGearText = string.format(GetString(WW_MISSING_GEAR_TT), WWG.GearLinkTableToString(missingGear))
		WWG.SetTooltip(WWG.pageWarning, TOP, missingGearText)
	else
		WWG.pageWarning:SetHidden(true)
		WWG.SetTooltip(WWG.pageWarning, TOP, nil)
	end
	
	WWG.OnWindowResize()
end

function WWG.RefreshSetup(zone, pageId, index)
	local container = WWG.zones[zone.tag].boxes[index]
	local setup = Setup:FromStorage(zone.tag, pageId, index)
		
	-- refresh name & check disabled
	local color = (setup:IsDisabled() and 0.3 or 1)
	container.nameLabel:SetText(setup:GetName():upper())
	container.nameLabel:SetColor(color, color, color, 1)
	
	-- refresh skill icons
	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local abilityId = setup:GetSkills()[hotbarCategory][slotIndex]
			local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
			if abilityId and abilityId > 0 then
				abilityIcon = GetAbilityIcon(abilityId)
			end
			local skillControl = container.skills[hotbarCategory][slotIndex]
			skillControl:SetTexture(abilityIcon)
			skillControl:SetColor(color, color, color, 1)
			if abilityId and abilityId > 0 then
				skillControl:SetHandler("OnMouseEnter", function()
					InitializeTooltip(AbilityTooltip, skillControl, TOPLEFT, 8, -8, TOPRIGHT)
					AbilityTooltip:SetAbilityId(abilityId)
				end)
				skillControl:SetHandler("OnMouseExit", function()
					ClearTooltip(AbilityTooltip)
				end)
			else
				skillControl:SetHandler("OnMouseEnter", function() end)
				skillControl:SetHandler("OnMouseExit", function() end)
			end
		end
	end
	
	-- refresh bufffood icon and tooltip
	local food = setup:GetFood()
	if food.link then
		container.buffFoodButton:SetHandler("OnMouseEnter", function()
			InitializeTooltip(ItemTooltip, container.buffFoodButton, LEFT, 4, 0, RIGHT)
			ItemTooltip:SetLink(food.link)
		end)
		container.buffFoodButton:SetHandler("OnMouseExit", function()
			ClearTooltip(ItemTooltip)
		end)
	else
		WWG.SetTooltip(container.buffFoodButton, RIGHT, GetString(WW_BUTTON_BUFFFOOD))
	end
	
	-- refresh gear tooltip
	local gearText = setup:GetGearText()
	WWG.SetTooltip(container.gearButton, RIGHT, gearText)
	
	-- refresh skills tooltip
	local skillsText = setup:GetSkillsText()
	WWG.SetTooltip(container.skillButton, RIGHT, skillsText)
	
	-- refresh cp tooltip
	local cpText = setup:GetCPText()
	WWG.SetTooltip(container.cpButton, RIGHT, cpText)
	
	-- show withdraw button if bank is open
	if IsBankOpen() and not WW.banking.disabledBags[GetBankingBag()] then
		container.bankingButton:SetHidden(false)
		WWG.bankingPageButton:SetHidden(false)
	else
		container.bankingButton:SetHidden(true)
		WWG.bankingPageButton:SetHidden(true)
	end
end

function WWG.RenameSetup(zone, pageId, index)
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	WWG.ShowEditDialog("SetuNameEdit", GetString(WW_RENAME_SETUP), setup:GetName(),
	function(input)
		if not input then
			return
		end
		if input == "" then
			setup:SetName(GetString(WW_UNNAMED))
		else
			setup:SetName(input)
		end
		setup:ToStorage(zone.tag, pageId, index)
		WWG.RefreshSetup(WW.selection.zone, pageId, index)
	end)
end

local PANEL_WIDTH = 245
local PANEL_HEIGHT = 60
local PANEL_WIDTH_MINI = PANEL_WIDTH - 70
local PANEL_HEIGHT_MINI = PANEL_HEIGHT - 17

function WWG.CreatePanel()
	local panel = WINDOW_MANAGER:CreateTopLevelWindow("WizardsWardrobePanel")
	WWG.panel = panel
	panel:SetDimensions(PANEL_WIDTH, PANEL_HEIGHT)
	panel:SetHidden(true)
	panel:SetClampedToScreen(true)
	panel:SetMouseEnabled(true)
	panel:SetMovable(false)
	panel:SetDrawLayer(2)
	panel:SetHandler("OnMoveStop", function(self)
		WW.settings.panel.top = self:GetTop()
		WW.settings.panel.left = self:GetLeft()
	end)
	
	local background = WINDOW_MANAGER:CreateControlFromVirtual(panel:GetName() .. "BG", panel, "ZO_MinorMungeBackdrop_SemiTransparentBlack")
	background:SetAlpha(0.5)
	
	local icon = WINDOW_MANAGER:CreateControl(panel:GetName() .. "Icon", panel, CT_TEXTURE)
	icon:SetTexture("/WizardsWardrobe/assets/icon64.dds")
	icon:SetDimensions(46, 46)
	icon:SetAnchor(TOPLEFT, panel, TOPLEFT, 4, 6)
	icon:SetMouseEnabled(true)
	icon:SetHandler("OnMouseEnter", function(self)
		self:SetDesaturation(0.4)
	end)
	icon:SetHandler("OnMouseExit", function(self)
		self:SetDesaturation(0)
	end)
	icon:SetHandler("OnMouseDown", function(self)
		self:SetDesaturation(0.8)
	end)
	icon:SetHandler("OnMouseUp", function(self, mouseButton)
		if MouseIsOver(self, 0, 0, 0, 0) and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			SLASH_COMMANDS["/wizard"]()
			self:SetDesaturation(0.4)
		else
			self:SetDesaturation(0)
		end
	end)
	
	local topLabel = WINDOW_MANAGER:CreateControl(panel:GetName() .. "TopLabel", panel, CT_LABEL)
	topLabel:SetAnchor(TOPLEFT, panel, TOPLEFT, 8 + 44, 2)
	topLabel:SetFont("ZoFontGameBold")
	topLabel:SetText(WW.displayName:upper())
	
	local middleLabel = WINDOW_MANAGER:CreateControl(panel:GetName() .. "MiddleLabel", panel, CT_LABEL)
	panel.upperLabel = middleLabel
	middleLabel:SetAnchor(TOPLEFT, panel, TOPLEFT, 8 + 44, 18)
	middleLabel:SetFont("ZoFontGameBold")
	middleLabel:SetText("Version " .. WW.version)
	
	local bottomLabel = WINDOW_MANAGER:CreateControl(panel:GetName() .. "BottomLabel", panel, CT_LABEL)
	panel.lowerLabel = bottomLabel
	bottomLabel:SetAnchor(TOPLEFT, panel, TOPLEFT, 8 + 44, 34)
	bottomLabel:SetFont("ZoFontGameBold")
	bottomLabel:SetText("@ownedbynico")
	
	if WW.settings.panel and WW.settings.panel.mini then
		panel:SetDimensions(PANEL_WIDTH_MINI, PANEL_HEIGHT_MINI)
		icon:SetHidden(true)
		topLabel:SetHidden(true)
		middleLabel:SetAnchor(TOPLEFT, panel, TOPLEFT, 8, 2)
		bottomLabel:SetAnchor(TOPLEFT, panel, TOPLEFT, 8, 19)
	end
	
	if WW.settings.panel and WW.settings.panel.top and WW.settings.panel.setup then
		panel:SetAnchor(TOPLEFT, GUI_ROOT, TOPLEFT, WW.settings.panel.left, WW.settings.panel.top)
		panel:SetMovable(not WW.settings.panel.locked)
	else
		local ultButton = ZO_ActionBar_GetButton(8).slot
		local defaultTop = ultButton:GetTop() - 2
		local defaultLeft = ultButton:GetLeft() + ultButton:GetWidth() + 5
		panel:SetAnchor(TOPLEFT, GUI_ROOT, TOPLEFT, defaultLeft, defaultTop)
		WW.settings.panel = {
			top = defaultTop,
			left = defaultLeft,
			locked = true,
			hidden = false,
			setup = true,
		}
	end
	
	panel.fragment = ZO_SimpleSceneFragment:New(panel)
	panel.fragment:SetConditional(function() -- this is pretty cool ngl
		return not WW.settings.panel.hidden and not IsUnitDead("player")
	end)
	
	HUD_SCENE:AddFragment(panel.fragment)
	HUD_UI_SCENE:AddFragment(panel.fragment)
	
	zo_callLater(function()
		panel.fragment:Refresh()
	end, 1)
	
	EVENT_MANAGER:RegisterForEvent(WWG.name, EVENT_PLAYER_DEAD, function() panel.fragment:Refresh() end)
	EVENT_MANAGER:RegisterForEvent(WWG.name, EVENT_PLAYER_ALIVE, function() panel.fragment:Refresh() end)
end

function WWG.CreateWindow()
	-- window
	local window = WINDOW_MANAGER:CreateTopLevelWindow("WizardsWardrobeWindow")
	WWG.window = window
	WWG.fragment = ZO_SimpleSceneFragment:New(window)
	window:SetDimensions(WW.settings.window.wizard.width, WW.settings.window.wizard.height)
	window:SetDimensionConstraints(350, 350, AUTO_SIZE, AUTO_SIZE)
	window:SetAnchor(CENTER, GUI_ROOT, CENTER, 0, 0)
	window:SetClampedToScreen(false)
	window:SetHidden(true)
	window:SetMouseEnabled(true)
	window:SetMovable(true)
	window:SetHandler("OnMoveStop", function(self)
		local scene = SCENE_MANAGER:GetCurrentScene()
		local sceneName = scene:GetName()
		WW.settings.window[sceneName] = {
			top = self:GetTop(),
			left = self:GetLeft(),
			hidden = false,
		}
	end)
	window:SetResizeHandleSize(8)
	window:SetHandler("OnResizeStart", function(control)
		EVENT_MANAGER:RegisterForUpdate(WW.name .. "WindowResize", 50, WWG.OnWindowResize)
	end)
	window:SetHandler("OnResizeStop", function(control)
		EVENT_MANAGER:UnregisterForUpdate(WW.name .. "WindowResize")
		WWG.OnWindowResizeEnd()
	end)
	
	if os.date("%d%m") == "0104" then
		window:SetTransformRotationZ(math.rad(180))
	end
	
	-- background
	local background = WINDOW_MANAGER:CreateControlFromVirtual(window:GetName() .. "BG", window, "ZO_DefaultBackdrop")
	background:SetAlpha(0.95)
	
	-- icon
	local icon = WINDOW_MANAGER:CreateControl(window:GetName() .. "Icon", window, CT_TEXTURE)
	icon:SetTexture("/WizardsWardrobe/assets/icon64.dds")
	icon:SetDimensions(36, 36)
	icon:SetAnchor(TOPLEFT, window, TOPLEFT, 2, 2)
	
	-- title
	local title = WINDOW_MANAGER:CreateControl(window:GetName() .. "Title", window, CT_LABEL)
	title:SetAnchor(CENTER, window, TOP, 0, 22)
	title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	title:SetFont("ZoFontWinH2")
	--title:SetFont("ZoFontGamepadBold34")
	title:SetText(WW.displayName:upper())
	
	-- hide button
	local hideButton = WINDOW_MANAGER:CreateControl(window:GetName() .. "Hide", window, CT_BUTTON)
	hideButton:SetDimensions(24, 24)
	hideButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -2, 2)
	hideButton:SetState(BSTATE_NORMAL)
	hideButton:SetClickSound(SOUNDS.DEFAULT_WINDOW_CLOSE)
	hideButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
	hideButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
	hideButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
	hideButton:SetHandler("OnClicked", function(self)
		SLASH_COMMANDS["/wizard"]()
	end)
end

function WWG.ResetWindow()
	WW.settings.window = {
		wizard = {
			width = 353,
			height = 665,
			scale = 1,
			locked = false,
		},
	}
	WWG.window:SetWidth(353)
	WWG.window:SetHeight(665)
	WWG.OnWindowResize()
end

function WWG.OnWindowResize()
	if not WW.selection.zone
		or not WWG.zones[WW.selection.zone.tag]
		or not WWG.zones[WW.selection.zone.tag].scrollContainer then
		return
	end
	
	local count = WW.GetSetupCount(WW.selection.zone)
	local height = WWG.window:GetHeight() - 148
	local width = WWG.window:GetWidth() + 2
	
	local scrollContainer = WWG.zones[WW.selection.zone.tag].scrollContainer
	scrollContainer:SetDimensions(width, height)
	
	local rows = zo_floor(width / SETUP_BOX_WIDTH)
	local itemsPerCol = zo_ceil(count / rows)
	
	for i = 1, count do
		local setupContainer = WWG.zones[WW.selection.zone.tag].boxes[i]
		setupContainer:ClearAnchors()
		local x = zo_floor((i-1) / itemsPerCol) * SETUP_BOX_WIDTH
		local y = (((i-1) % itemsPerCol) * SETUP_BOX_HEIGHT) + SETUP_BOX_OFFSET
		setupContainer:SetAnchor(TOPLEFT, scrollBox, TOPLEFT, x, y)
	end
	
	WWG.bottomMenu:SetDimensions(WWG.window:GetWidth() + 10, 32)
	WWG.bottomMenu.divider:SetDimensions(WWG.window:GetWidth() - 5, 2)
	WWG.topMenu.divider:SetDimensions(WWG.window:GetWidth() - 5, 2)
end

function WWG.OnWindowResizeEnd()
	-- snap to rows
	local rows = zo_floor(((WWG.window:GetWidth() + 2) / SETUP_BOX_WIDTH) + 0.5)
	local width = rows * (SETUP_BOX_WIDTH + 2)
	WWG.window:SetWidth(width)
	WWG.OnWindowResize()
	
	-- save new size
	WW.settings.window.wizard.width = WWG.window:GetWidth()
	WW.settings.window.wizard.height = WWG.window:GetHeight()
	
	-- always show scroll bar
	if WW.selection.zone
		and WWG.zones[WW.selection.zone.tag]
		and WWG.zones[WW.selection.zone.tag].scrollContainer then
		
		WWG.zones[WW.selection.zone.tag].scrollContainer:GetNamedChild("ScrollBar"):SetHidden(false)
	end
end

function WWG.FillZoneSelection()
	local comboBox = WWG.zoneSelection.m_comboBox
	comboBox:ClearItems()
	
	local i = 1
	comboBox.lookupItems = {}
	
	local sortedZones = WWG.GetSortedZoneList()
	for _, zone in ipairs(sortedZones) do
		local itemName = string.format("|t32:32:%s|t%s", zone.legacyIcon, zone.name)
		comboBox:AddItem(ZO_ComboBox:CreateItemEntry(itemName, function() WWG.OnZoneSelect(zone) end))
		
		-- creates lookup table for combobox items
		comboBox.lookupItems[zone.name] = i
		i = i + 1
	end
	
	WWG.gridZoneSelection:ClearItems()
	for _, zone in ipairs(sortedZones) do
		WWG.gridZoneSelection:AddItem({
			label = zone.name,
			tag = zone.tag,
			icon = zone.icon,
			callback = function()
				WWG.OnZoneSelect(zone)
			end,
		})
	end
	
	zo_callLater(function()
		if WW.selection.zone and WW.selection.zone.tag ~= "SUB" then
			local index = comboBox.lookupItems[WW.selection.zone.name]
			comboBox:SelectItemByIndex(index, true)
			WWG.gridZoneSelection:Select(index)
		else
			comboBox:SelectItemByIndex(1, true)
			WWG.gridZoneSelection:Select(1)
		end
	end, 500)
end

function WWG.OnZoneSelect(zone)
	PlaySound(SOUNDS.TABLET_PAGE_TURN)
	
	-- create first page if not existing
	if not WW.pages[zone.tag] then
		WWG.AddPage(zone, true)
	end
	
	-- hide old page
	WWG.HidePage(true)
	
	-- set selection to new zone and page
	WW.selection.zone = zone
	WW.selection.pageId = WW.pages[zone.tag][0].selected
	
	-- create scroll container if not existing
	if not WWG.zones[zone.tag] then
		WWG.zones[zone.tag] = {}
		WWG.zones[WW.selection.zone.tag].scrollContainer = WWG.CreateScrollContainer(WW.selection.zone, WW.selection.pageId)
	end
	
	-- show new page
	WWG.HidePage(false)
	
	-- select zone in dropbox
	WWG.zoneSelection.m_comboBox:SelectItemByIndex(WWG.zoneSelection.m_comboBox.lookupItems[zone.name], true)
	WWG.gridZoneSelection:SetLabel(zone.name)
	
	-- refresh page
	WWG.RefreshPage()
end

function WWG.CreateTopMenu()
	local topContainer = WINDOW_MANAGER:CreateControl(WWG.window:GetName() .. "TopMenu", WWG.window, CT_CONTROL)
	WWG.topMenu = topContainer
	topContainer:SetDimensions(345 - 34, 32)
	topContainer:SetAnchor(CENTER, WWG.window, TOP, 0, 62)
	
	-- top divider
	local divider = WINDOW_MANAGER:CreateControl(topContainer:GetName() .. "Divider", topContainer, CT_TEXTURE)
	WWG.topMenu.divider = divider
	divider:SetDimensions(360, 2)
	divider:SetAnchor(CENTER, topContainer, BOTTOM, -2, 8)
	divider:SetTexture("/esoui/art/miscellaneous/centerscreen_topdivider.dds")
	
	-- legacy zone selection
	local zoneSelection = WINDOW_MANAGER:CreateControlFromVirtual(topContainer:GetName() .. "ZoneSelection", topContainer, "ZO_ComboBox")
	WWG.zoneSelection = zoneSelection
	zoneSelection:SetHeight(32)
	zoneSelection:SetWidth(251)
	zoneSelection:SetAnchor(TOPLEFT, topContainer, TOPLEFT, 0, 0)
	zoneSelection:SetHidden(not WW.settings.legacySelection)
	
	local comboBox = zoneSelection.m_comboBox
	comboBox:SetSortsItems(false)
	comboBox:SetSpacing(5)
	
	-- new zone selection
	local gridComboBox = GridComboBox:New(topContainer:GetName() .. "GridZoneSelection", topContainer)
	WWG.gridZoneSelection = gridComboBox
	gridComboBox:SetAnchor(TOPLEFT, topContainer, TOPLEFT, 4, 10)
	gridComboBox:SetDimensions(240, 16)
	gridComboBox:SetItemsPerRow(4)
    gridComboBox:SetItemSize(57)
	gridComboBox:SetItemSpacing(4)
	gridComboBox:SetHidden(WW.settings.legacySelection)
	
	WWG.FillZoneSelection()
		
	-- autoequip button
	local autoEquipTextures = {
		[true] = "/esoui/art/crafting/smithing_tabicon_armorset_down.dds",
		[false] = "/esoui/art/crafting/smithing_tabicon_armorset_up.dds"
	}
	local autoEquipMessages = {
		[true] = GetString(WW_MSG_TOGGLEAUTOEQUIP_ON),
		[false] = GetString(WW_MSG_TOGGLEAUTOEQUIP_OFF)
	}
	local autoequipButton = WINDOW_MANAGER:CreateControl(topContainer:GetName() .. "ToggleAutoEquip", topContainer, CT_BUTTON)
	autoequipButton:SetDimensions(32, 32)
	autoequipButton:SetAnchor(LEFT, zoneSelection, RIGHT, 6, 0)
	autoequipButton:SetState(BSTATE_NORMAL)
	autoequipButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	autoequipButton:SetNormalTexture("/esoui/art/crafting/smithing_tabicon_armorset_up.dds")
	autoequipButton:SetMouseOverTexture("/esoui/art/crafting/smithing_tabicon_armorset_over.dds")
	autoequipButton:SetPressedTexture("/esoui/art/crafting/smithing_tabicon_armorset_down.dds")
	autoequipButton:SetHandler("OnClicked", function(self)
		WW.settings.autoEquipSetups = not WW.settings.autoEquipSetups
		WW.storage.autoEquipSetups = WW.settings.autoEquipSetups
		self:SetNormalTexture(autoEquipTextures[WW.settings.autoEquipSetups])
		WW.Log(GetString(WW_MSG_TOGGLEAUTOEQUIP), WW.LOGTYPES.NORMAL, nil, autoEquipMessages[WW.settings.autoEquipSetups])
	end)
	autoequipButton:SetNormalTexture(autoEquipTextures[WW.settings.autoEquipSetups])
	WWG.SetTooltip(autoequipButton, TOP, GetString(WW_BUTTON_TOGGLEAUTOEQUIP))
	
	-- add page button
	local addPageButton = WINDOW_MANAGER:CreateControl(topContainer:GetName() .. "PageAdd", topContainer, CT_BUTTON)
	addPageButton:SetDimensions(36, 36)
	addPageButton:SetAnchor(LEFT, autoequipButton, RIGHT, 0, 1)
	addPageButton:SetState(BSTATE_NORMAL)
	addPageButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	addPageButton:SetNormalTexture("/esoui/art/buttons/plus_up.dds")
	addPageButton:SetMouseOverTexture("/esoui/art/buttons/plus_over.dds")
	addPageButton:SetPressedTexture("/esoui/art/buttons/plus_down.dds")
	addPageButton:SetHandler("OnClicked", function(self)
		WWG.AddPage(WW.selection.zone)
	end)
	WWG.SetTooltip(addPageButton, TOP, GetString(WW_BUTTON_ADD))
end

function WWG.CreatePageMenu()
	-- label
	local pageLabel = WINDOW_MANAGER:CreateControl(WWG.window:GetName() .. "PageLabel", WWG.window, CT_LABEL)
	WWG.pageLabel = pageLabel
	pageLabel:SetAnchor(CENTER, WWG.window, TOP, 0, 110)
	pageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	pageLabel:SetFont("ZoFontWinH3")
	pageLabel:SetDimensionConstraints(1, 1, 270, pageLabel:GetFontHeight())
	
	-- warning icon
	local warning = WINDOW_MANAGER:CreateControl(WWG.window:GetName() .. "PageWarning", WWG.window, CT_TEXTURE)
	WWG.pageWarning = warning
	warning:SetHidden(true)
	warning:SetDimensions(32, 32)
	warning:SetAnchor(RIGHT, pageLabel, LEFT, 0, 0)
	warning:SetTexture("/esoui/art/miscellaneous/eso_icon_warning.dds")
	warning:SetColor(1, 1, 0, 1)
	warning:SetMouseEnabled(true)
	warning:SetHandler("OnMouseUp", function(self, mouseButton)
		if MouseIsOver(self, 0, 0, 0, 0) and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			local missingGear = WW.CheckGear(WW.selection.zone, WW.selection.pageId)
			if #missingGear > 0 then
				WWG.pageWarning:SetHidden(false)
				local missingGearText = string.format(GetString(WW_MISSING_GEAR_TT), WWG.GearLinkTableToString(missingGear))
				WWG.SetTooltip(WWG.pageWarning, TOP, missingGearText)
			else
				WWG.pageWarning:SetHidden(true)
				WWG.SetTooltip(WWG.pageWarning, TOP, nil)
			end
		end
	end)
	
	-- dropdown button
	local dropdownButton = WINDOW_MANAGER:CreateControl(WWG.window:GetName() .. "PageDropdown", WWG.window, CT_BUTTON)
	WWG.pageDropdown = dropdownButton
	dropdownButton:SetDimensions(16, 16)
	dropdownButton:SetAnchor(LEFT, pageLabel, RIGHT, 2, -1)
	dropdownButton:SetState(BSTATE_NORMAL)
	dropdownButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	dropdownButton:SetNormalTexture("/esoui/art/buttons/scrollbox_downarrow_up.dds")
	dropdownButton:SetMouseOverTexture("/esoui/art/buttons/scrollbox_downarrow_over.dds")
	dropdownButton:SetPressedTexture("/esoui/art/buttons/scrollbox_downarrow_down.dds")
	dropdownButton:SetHandler("OnClicked", function(self, mouseButton)
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsMenuVisible() then
				ClearMenu()
			else
				WWG.ShowPageContextMenu(pageLabel, WW.selection.zone, WW.selection.pageId)
			end
		end
	end)
	
	--withdraw and deposit gear
	local bankingPageButton = WINDOW_MANAGER:CreateControl(WWG.window:GetName() .. "PageBanking", WWG.window, CT_BUTTON)
	WWG.bankingPageButton = bankingPageButton
	bankingPageButton:SetHidden(true)
	bankingPageButton:SetDimensions(38, 38)
	bankingPageButton:SetAnchor(LEFT, dropdownButton, RIGHT, -7, 0)
	bankingPageButton:SetState(BSTATE_NORMAL)
	bankingPageButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	bankingPageButton:SetNormalTexture("/esoui/art/icons/guildranks/guild_indexicon_misc09_up.dds")
	bankingPageButton:SetMouseOverTexture("/esoui/art/icons/guildranks/guild_indexicon_misc09_over.dds")
	bankingPageButton:SetPressedTexture("/esoui/art/icons/guildranks/guild_indexicon_misc09_down.dds")
	bankingPageButton:SetHandler("OnClicked", function(self)
		if IsShiftKeyDown() then
			WW.banking.DepositPage(WW.selection.zone, WW.selection.pageId)
		else
			WW.banking.WithdrawPage(WW.selection.zone, WW.selection.pageId)
		end
	end)
	WWG.SetTooltip(bankingPageButton, TOP, GetString(WW_BANKING_TT))
	
	-- left page button
	local leftPageButton = WINDOW_MANAGER:CreateControl(WWG.window:GetName() .. "PageLeft", WWG.window, CT_BUTTON)
	WWG.pageLeft = leftPageButton
	leftPageButton:SetDimensions(31, 31)
	leftPageButton:SetAnchor(TOPLEFT, WWG.window, TOPLEFT, 0, 94)
	leftPageButton:SetState(BSTATE_NORMAL)
	leftPageButton:SetClickSound(SOUNDS.TABLET_PAGE_TURN)
	leftPageButton:SetNormalTexture("/esoui/art/buttons/large_leftarrow_up.dds")
	leftPageButton:SetMouseOverTexture("/esoui/art/buttons/large_leftarrow_over.dds")
	leftPageButton:SetPressedTexture("/esoui/art/buttons/large_leftarrow_down.dds")
	leftPageButton:SetDisabledTexture("/esoui/art/buttons/large_leftarrow_disabled.dds")
	leftPageButton:SetHandler("OnClicked", WWG.PageLeft)
	
	-- right page button
	local rightPageButton = WINDOW_MANAGER:CreateControl(WWG.window:GetName() .. "PageRight", WWG.window, CT_BUTTON)
	WWG.pageRight = rightPageButton
	rightPageButton:SetDimensions(32, 32)
	rightPageButton:SetAnchor(TOPRIGHT, WWG.window, TOPRIGHT, 0, 94)
	rightPageButton:SetState(BSTATE_NORMAL)
	rightPageButton:SetClickSound(SOUNDS.TABLET_PAGE_TURN)
	rightPageButton:SetNormalTexture("/esoui/art/buttons/large_rightarrow_up.dds")
	rightPageButton:SetMouseOverTexture("/esoui/art/buttons/large_rightarrow_over.dds")
	rightPageButton:SetPressedTexture("/esoui/art/buttons/large_rightarrow_down.dds")
	rightPageButton:SetDisabledTexture("/esoui/art/buttons/large_rightarrow_disabled.dds")
	rightPageButton:SetHandler("OnClicked", WWG.PageRight)
end

function WWG.CreateBottomMenu()	
	local bottomContainer = WINDOW_MANAGER:CreateControl(WWG.window:GetName() .. "BottomMenu", WWG.window, CT_CONTROL)
	WWG.bottomMenu = bottomContainer
	bottomContainer:SetDimensions(WWG.window:GetWidth() + 10, 32)
	bottomContainer:SetAnchor(CENTER, WWG.window, BOTTOM, 0, -12)
	
	-- bottom divider
	local divider = WINDOW_MANAGER:CreateControl(bottomContainer:GetName() .. "Divider", bottomContainer, CT_TEXTURE)
	WWG.bottomMenu.divider = divider
	divider:SetDimensions(360, 2)
	divider:SetAnchor(CENTER, bottomContainer, TOP, -2, 0)
	divider:SetTexture("/esoui/art/miscellaneous/centerscreen_topdivider.dds")
	
	-- settings button
	local settingsButton = WINDOW_MANAGER:CreateControl(bottomContainer:GetName() .. "Settings", bottomContainer, CT_BUTTON)
	settingsButton:SetDimensions(32, 32)
	settingsButton:SetAnchor(TOPLEFT, bottomContainer, TOPLEFT, 0, 0)
	settingsButton:SetState(BSTATE_NORMAL)
	settingsButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	settingsButton:SetNormalTexture("/esoui/art/skillsadvisor/advisor_tabicon_settings_up.dds")
	settingsButton:SetMouseOverTexture("/esoui/art/skillsadvisor/advisor_tabicon_settings_over.dds")
	settingsButton:SetPressedTexture("/esoui/art/skillsadvisor/advisor_tabicon_settings_down.dds")
	settingsButton:SetHandler("OnClicked", function(self)
		if WW.menu.panel then
			LibAddonMenu2:OpenToPanel(WW.menu.panel)
		end
	end)
	WWG.SetTooltip(settingsButton, TOP, GetString(WW_BUTTON_SETTINGS))
	
	-- clear queue
	local queueButton = WINDOW_MANAGER:CreateControl(bottomContainer:GetName() .. "Queue", bottomContainer, CT_BUTTON)
	queueButton:SetDimensions(32, 32)
	queueButton:SetAnchor(LEFT, settingsButton, RIGHT, -2, 1)
	queueButton:SetState(BSTATE_NORMAL)
	queueButton:SetNormalTexture("/esoui/art/inventory/inventory_tabicon_crafting_up.dds")
	queueButton:SetMouseOverTexture("/esoui/art/inventory/inventory_tabicon_crafting_over.dds")
	queueButton:SetPressedTexture("/esoui/art/inventory/inventory_tabicon_crafting_up.dds")
	queueButton:SetHandler("OnClicked", function()
		local entries = WW.queue.Size()
		WW.queue.Reset()
		WW.Log(GetString(WW_MSG_CLEARQUEUE), WW.LOGTYPES.NORMAL, nil, entries)
	end)
	WWG.SetTooltip(queueButton, TOP, GetString(WW_BUTTON_CLEARQUEUE))
	
	-- unequip button
	local unequipButton = WINDOW_MANAGER:CreateControl(bottomContainer:GetName() .. "Unequip", bottomContainer, CT_BUTTON)
	unequipButton:SetDimensions(32, 32)
	unequipButton:SetAnchor(LEFT, queueButton, RIGHT, -6, 0)
	unequipButton:SetState(BSTATE_NORMAL)
	unequipButton:SetNormalTexture("/esoui/art/inventory/inventory_tabicon_armor_up.dds")
	unequipButton:SetMouseOverTexture("/esoui/art/inventory/inventory_tabicon_armor_over.dds")
	unequipButton:SetPressedTexture("/esoui/art/inventory/inventory_tabicon_armor_up.dds")
	unequipButton:SetHandler("OnClicked", WW.Undress)
	WWG.SetTooltip(unequipButton, TOP, GetString(WW_BUTTON_UNDRESS))
	
	-- prebuff button
	local prebuffButton = WINDOW_MANAGER:CreateControl(bottomContainer:GetName() .. "Prebuff", bottomContainer, CT_BUTTON)
	prebuffButton:SetDimensions(32, 32)
	prebuffButton:SetAnchor(LEFT, unequipButton, RIGHT, -6, 0)
	prebuffButton:SetState(BSTATE_NORMAL)
	prebuffButton:SetNormalTexture("/esoui/art/progression/progression_indexicon_guilds_up.dds")
	prebuffButton:SetMouseOverTexture("/esoui/art/progression/progression_indexicon_guilds_over.dds")
	prebuffButton:SetPressedTexture("/esoui/art/progression/progression_indexicon_guilds_up.dds")
	prebuffButton:SetHandler("OnClicked", function()
		WW.prebuff.dialog:SetHidden(false)
	end)
	WWG.SetTooltip(prebuffButton, TOP, "Prebuff")
	
	-- help button
	local helpButton = WINDOW_MANAGER:CreateControl(bottomContainer:GetName() .. "Help", bottomContainer, CT_BUTTON)
	helpButton:SetDimensions(28, 28)
	helpButton:SetAnchor(TOPRIGHT, bottomContainer, TOPRIGHT, 0, 2)
	helpButton:SetState(BSTATE_NORMAL)
	helpButton:SetNormalTexture("/esoui/art/menubar/menubar_help_up.dds")
	helpButton:SetMouseOverTexture("/esoui/art/menubar/menubar_help_over.dds")
	helpButton:SetPressedTexture("/esoui/art/menubar/menubar_help_up.dds")
	WWG.SetTooltip(helpButton, TOP, GetString(WW_HELP))
end

function WWG.CreateScrollContainerParent()
	local container = WINDOW_MANAGER:CreateControl(WWG.window:GetName() .. "ScrollContainerParent", WWG.window, CT_CONTROL)
	WWG.scrollConainerParent = container
	container:SetDimensions(355, 515)
	container:SetAnchor(TOPLEFT, WWG.window, TOPLEFT, 1, 120)
end

function WWG.CreateScrollContainer(zone, pageId)
	local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual(WWG.window:GetName() .. "ScrollBox" .. zone.tag, WWG.scrollConainerParent, "ZO_ScrollContainer")
	scrollContainer:SetAnchor(TOPLEFT, WWG.scrollConainerParent, TOPLEFT, 0, 0)
	scrollContainer:SetDimensions(355, 515)
	scrollContainer:SetHidden(true)
	
	local scrollBox = scrollContainer:GetNamedChild("ScrollChild")
	
	-- always show scrollBar
	zo_callLater(function()
		scrollContainer:GetNamedChild("ScrollBar"):SetHidden(false)
	end, 1)
	
	-- load all setups
	WWG.zones[zone.tag].boxes = {}
	for i, boss in ipairs(zone.bosses) do
		local setupName = boss.displayName or boss.name
		WWG.zones[zone.tag].boxes[i] = WWG.CreateSetupContainer(scrollContainer, zone, pageId, i, setupName)
	end
	
	-- custom section
	if WW.settings.extraSlots and WW.settings.extraSlots > 0 and zone.tag ~= "SUB" then
		for i = #zone.bosses + 1, WW.GetSetupCount(zone) do
			local setup = Setup:FromStorage(zone.tag, pageId, i)
			WWG.zones[zone.tag].boxes[i] = WWG.CreateSetupContainer(scrollContainer, zone, pageId, i, setup:GetName())
		end
	end
	
	if zone.tag == "SUB" then
		local subExplain = WINDOW_MANAGER:CreateControl(scrollContainer:GetName() .. "SubExplain", scrollContainer, CT_LABEL)
		subExplain:SetAnchor(TOPLEFT, scrollContainer, TOPLEFT, 15, 268)
		subExplain:SetDimensionConstraints(AUTO_SIZE, AUTO_SIZE, 310, AUTO_SIZE)
		subExplain:SetFont("ZoFontGame")
		subExplain:SetText(GetString(WW_SUBSTITUTE_EXPLAIN))
	end
	
	WWG.RefreshPage()
	return scrollContainer
end

function WWG.CreateSetupContainer(parent, zone, pageId, index, setupName)
	local scrollBox = parent:GetNamedChild("ScrollChild")
	
	local setupContainer = WINDOW_MANAGER:CreateControl(parent:GetName() .. "SetupContainer" .. tostring(index), scrollBox, CT_CONTROL)
	--setupContainer:SetDimensions(350, ((index == WW.GetSetupCount(zone)) and SETUP_BOX_HEIGHT or (SETUP_BOX_HEIGHT-48)))
	setupContainer:SetDimensions(SETUP_BOX_WIDTH, SETUP_BOX_HEIGHT)
	setupContainer:SetAnchor(TOPLEFT, scrollBox, TOPLEFT, 0, (index - 1) * SETUP_BOX_HEIGHT)
	
	-- setup name label
	local nameLabel = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "NameLabel", setupContainer, CT_LABEL)
	setupContainer.nameLabel = nameLabel
	nameLabel:SetAnchor(TOPLEFT, setupContainer, TOPLEFT, 0, 0)
	nameLabel:SetMouseEnabled(true)
	nameLabel:SetFont("ZoFontWinH3")
	--nameLabel:SetText(setupName:upper())
	if WW.IsCustomSetup(zone, index) then
		nameLabel:SetDimensionConstraints(1, 1, 255, nameLabel:GetFontHeight())
	end
	nameLabel:SetHandler("OnMouseEnter", function(self)
		ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(WW_BUTTON_LABEL))
		local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
		if not setup:IsDisabled() then
		 	self:SetColor(1, 0.5, 0.5, 1)
		end
	end)
	nameLabel:SetHandler("OnMouseExit", function(self)
		ZO_Tooltips_HideTextTooltip()
		local color = 1
		local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
		if setup:IsDisabled() then
		 	color = 0.3
		end
		self:SetColor(color, color, color, 1)
	end)
	nameLabel:SetHandler("OnMouseDown", function(self, mouseButton)
		self:SetColor(0.8, 0.4, 0.4, 1)
	end)
	nameLabel:SetHandler("OnMouseUp", function(self, mouseButton)
		if not MouseIsOver(self, 0, 0, 0, 0) then return end
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			WW.LoadSetupCurrent(index, false)
		end
	end)
	
	-- dropdown button
	local dropdownButton = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "DropdownButton", setupContainer, CT_BUTTON)
	setupContainer.dropdownButton = dropdownButton
	dropdownButton:SetDimensions(16, 16)
	dropdownButton:SetAnchor(LEFT, nameLabel, RIGHT, 2, 0)
	dropdownButton:SetState(BSTATE_NORMAL)
	dropdownButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	dropdownButton:SetNormalTexture("/esoui/art/buttons/scrollbox_downarrow_up.dds")
	dropdownButton:SetMouseOverTexture("/esoui/art/buttons/scrollbox_downarrow_over.dds")
	dropdownButton:SetPressedTexture("/esoui/art/buttons/scrollbox_downarrow_down.dds")
	dropdownButton:SetHandler("OnClicked", function(self, mouseButton)
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsMenuVisible() then
				ClearMenu()
			else
				WWG.ShowSetupContextMenu(nameLabel, WW.selection.zone, WW.selection.pageId, index)
			end
		end
	end)
		
	-- custom setup buttons
	if WW.IsCustomSetup(zone, index) then	
		-- edit setup name button
		local editButton = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "EditButton", setupContainer, CT_BUTTON)
		setupContainer.editButton = editButton
		editButton:SetDimensions(32, 32)
		editButton:SetAnchor(TOPRIGHT, setupContainer, TOPRIGHT, -8, -4)
		editButton:SetState(BSTATE_NORMAL)
		editButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
		editButton:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
		editButton:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
		editButton:SetPressedTexture("/esoui/art/buttons/edit_down.dds")
		editButton:SetHandler("OnClicked", function(self) WWG.RenameSetup(WW.selection.zone, WW.selection.pageId, index) end)
		WWG.SetTooltip(editButton, TOP, GetString(WW_BUTTON_EDIT))
	end
	
	-- save setup button
	local saveButton = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "SaveButton", setupContainer, CT_BUTTON)
	setupContainer.saveButton = saveButton
	saveButton:SetDimensions(32, 32)
	if WW.IsCustomSetup(zone, index) then
		saveButton:SetAnchor(RIGHT, GetControl(setupContainer:GetName() .. "EditButton"), LEFT, 10, 0)
	else
		saveButton:SetAnchor(TOPRIGHT, setupContainer, TOPRIGHT, -4, -4)
	end
	saveButton:SetState(BSTATE_NORMAL)
	saveButton:SetClickSound(SOUNDS.DUNGEON_DIFFICULTY_NORMAL)
	saveButton:SetNormalTexture("/esoui/art/buttons/edit_save_up.dds")
	saveButton:SetMouseOverTexture("/esoui/art/buttons/edit_save_over.dds")
	saveButton:SetPressedTexture("/esoui/art/buttons/edit_save_down.dds")
	saveButton:SetHandler("OnClicked", function(self, mouseButton) WW.SaveSetup(WW.selection.zone, WW.selection.pageId, index) end)
	WWG.SetTooltip(saveButton, TOP, GetString(WW_BUTTON_SAVE))
	
	-- preview button
	local previewButton = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "PreviewButton", setupContainer, CT_BUTTON)
	setupContainer.previewButton = previewButton
	previewButton:SetDimensions(32, 32)
	previewButton:SetAnchor(RIGHT, saveButton, LEFT, 8, 2)
	previewButton:SetState(BSTATE_NORMAL)
	previewButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	previewButton:SetNormalTexture("/esoui/art/guild/tabicon_roster_up.dds")
	previewButton:SetMouseOverTexture("/esoui/art/guild/tabicon_roster_over.dds")
	previewButton:SetPressedTexture("/esoui/art/guild/tabicon_roster_down.dds")
	previewButton:SetHandler("OnClicked", function(self)
		local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
		WW.preview.ShowPreviewFromSetup(setup, WW.selection.zone.name)
	end)
	WWG.SetTooltip(previewButton, TOP, GetString(WW_BUTTON_PREVIEW))
	
	--withdraw and deposit gear
	local bankingButton = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "BankingButton", setupContainer, CT_BUTTON)
	setupContainer.bankingButton = bankingButton
	bankingButton:SetHidden(true)
	bankingButton:SetDimensions(36, 36)
	bankingButton:SetAnchor(RIGHT, previewButton, LEFT, 8, 2)
	bankingButton:SetState(BSTATE_NORMAL)
	bankingButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	bankingButton:SetNormalTexture("/esoui/art/icons/guildranks/guild_indexicon_misc09_up.dds")
	bankingButton:SetMouseOverTexture("/esoui/art/icons/guildranks/guild_indexicon_misc09_over.dds")
	bankingButton:SetPressedTexture("/esoui/art/icons/guildranks/guild_indexicon_misc09_down.dds")
	bankingButton:SetHandler("OnClicked", function(self)
		if IsShiftKeyDown() then
			WW.banking.DepositSetup(WW.selection.zone, WW.selection.pageId, index)
		else
			WW.banking.WithdrawSetup(WW.selection.zone, WW.selection.pageId, index)
		end
	end)
	WWG.SetTooltip(bankingButton, TOP, GetString(WW_BANKING_TT))
	
	-- skill frames and icons
	local skills = {}
	for hotbar = 0, 1 do
		skills[hotbar] = {}
		for slot = 3, 8 do
			local x = (slot - 3) * 42
			local y = hotbar * 42 + 30
			
			local skillName = string.format("%sSkill%d%d", setupContainer:GetName(), hotbar, slot)
			local skill = WINDOW_MANAGER:CreateControl(skillName, setupContainer, CT_TEXTURE)
			skill:SetDimensions(40, 40)
			skill:SetAnchor(TOPLEFT, setupContainer, TOPLEFT, x, y)
			skill:SetTexture("/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds")
			skill:SetMouseEnabled(true)
			skill:SetDrawLevel(2)
			local function OnSkillDragStart(self)
				if IsUnitInCombat("player") then return	end -- would fail at protected call anyway
				if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then return end
				
				local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				
				-- disabled for empty setups; will be fixed with 1.8
				if setup:IsEmpty() then return end
				
				local abilityId = setup:GetSkills()[hotbar][slot]
				if not abilityId then return end
				
				local baseAbilityId = WW.GetBaseAbilityId(abilityId)
				if not baseAbilityId then return end
				
				local skillType, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(baseAbilityId)
				if CallSecureProtected("PickupAbilityBySkillLine", skillType, skillLine, skillIndex) then
					setup:SetSkill(hotbar, slot, 0)
					setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
					self:GetHandler("OnMouseExit")()
					WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
				end
			end
			local function OnSkillDragReceive(self)
				if GetCursorContentType() ~= MOUSE_CONTENT_ACTION then return end
				local abilityId = GetCursorAbilityId()
				
				local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityId)
				if not progression then return end
				
				if progression:IsUltimate() and slot < 8 or
					not progression:IsUltimate() and slot > 7 then
					-- Prevent ult on normal slot and vice versa
					return
				end
				
				if progression:IsChainingAbility() then
					abilityId = GetEffectiveAbilityIdForAbilityOnHotbar(abilityId, hotbar)
				end
				
				ClearCursor()
				
				local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				
				-- disabled for empty setups; will be fixed with 1.8
				if setup:IsEmpty() then return end
				
				local previousAbilityId = setup:GetSkills()[hotbar][slot]
				setup:SetSkill(hotbar, slot, abilityId)
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				
				self:GetHandler("OnMouseExit")()
				WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
				
				if previousAbilityId and previousAbilityId > 0 then
					local baseAbilityId = WW.GetBaseAbilityId(previousAbilityId)
					local skillType, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(baseAbilityId)
					CallSecureProtected("PickupAbilityBySkillLine", skillType, skillLine, skillIndex)
				end
			end
			skill:SetHandler("OnReceiveDrag", OnSkillDragReceive)
			skill:SetHandler("OnMouseUp", function(self)
				if MouseIsOver(self, 0, 0, 0, 0) then
					OnSkillDragReceive(self)
				end
			end)
			skill:SetHandler("OnDragStart", OnSkillDragStart)
			skills[hotbar][slot] = skill
			
			local frameName = string.format("%sFrame%d%d", setupContainer:GetName(), hotbar, slot)
			local frame = WINDOW_MANAGER:CreateControl(frameName, setupContainer, CT_TEXTURE)
			frame:SetDimensions(40, 40)
			frame:SetAnchor(CENTER, skill, CENTER, 0, 0)
			frame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
			frame:SetDrawLevel(3)
		end
	end
	setupContainer.skills = skills
	
	-- gear cp skill food buttons
	local x = 6 * 42 + 2
	local y = 30
	
	local buffFoodButton = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "BuffFoodButton", setupContainer, CT_BUTTON)
	setupContainer.buffFoodButton = buffFoodButton
	buffFoodButton:SetDimensions(42, 42)
	buffFoodButton:SetAnchor(TOPLEFT, setupContainer, TOPLEFT, x + 1, y - 1)
	buffFoodButton:SetState(BSTATE_NORMAL)
	buffFoodButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	buffFoodButton:SetNormalTexture("esoui/art/crafting/provisioner_indexicon_meat_up.dds")
	buffFoodButton:SetMouseOverTexture("esoui/art/crafting/provisioner_indexicon_meat_over.dds")
	buffFoodButton:SetPressedTexture("esoui/art/crafting/provisioner_indexicon_meat_down.dds")
	local function OnFoodDrag(self)
		local cursorContentType = GetCursorContentType()
		if cursorContentType ~= MOUSE_CONTENT_INVENTORY_ITEM then return false end
		
		local bagId = GetCursorBagId()
		local slotIndex = GetCursorSlotIndex()
		
		if bagId ~= BAG_BACKPACK then return false end
		
		local foodLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
		local foodId = GetItemLinkItemId(foodLink)
		
		if not WW.BUFFFOOD[foodId] then
			WW.Log(GetString(WW_MSG_NOTFOOD), WW.LOGTYPES.ERROR)
			return false
		end
		
		local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
		
		-- disabled for empty setups; will be fixed with 1.8
		if setup:IsEmpty() then return end
		
		WW.SaveFood(setup, slotIndex)
		setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
		
		self:GetHandler("OnMouseExit")()
		WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
		self:GetHandler("OnMouseEnter")()
		
		ClearCursor()
		return true
	end
	buffFoodButton:SetHandler("OnReceiveDrag", OnFoodDrag)
	buffFoodButton:SetHandler("OnClicked", function(self, mouseButton)
		if OnFoodDrag(self) then return end
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
			if IsShiftKeyDown() then
				WW.SaveFood(setup)
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				self:GetHandler("OnMouseExit")()
				WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
				self:GetHandler("OnMouseEnter")()
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetFood({})
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				ZO_Tooltips_HideTextTooltip()
				self:GetHandler("OnMouseExit")()
				WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
				self:GetHandler("OnMouseEnter")()
			else
				WW.EatFood(setup)
			end
		end
	end)
	local buffFoodFrame = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "BuffFoodFrame", buffFoodButton, CT_TEXTURE)
	buffFoodFrame:SetDimensions(40, 40)
	buffFoodFrame:SetAnchor(CENTER, buffFoodButton, CENTER, 0, 0)
	buffFoodFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
	
	local gearButton = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "GearButton", setupContainer, CT_BUTTON)
	setupContainer.gearButton = gearButton
	gearButton:SetDimensions(42, 42)
	gearButton:SetAnchor(TOPLEFT, setupContainer, TOPLEFT, x + 42 + 1, y - 1)
	gearButton:SetState(BSTATE_NORMAL)
	gearButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	gearButton:SetNormalTexture("/esoui/art/guild/tabicon_heraldry_up.dds")
	gearButton:SetMouseOverTexture("/esoui/art/guild/tabicon_heraldry_over.dds")
	gearButton:SetPressedTexture("/esoui/art/guild/tabicon_heraldry_down.dds")
	local function OnGearDrag(self)
		local cursorContentType = GetCursorContentType()
		if cursorContentType ~= MOUSE_CONTENT_INVENTORY_ITEM and
			cursorContentType ~= MOUSE_CONTENT_EQUIPPED_ITEM then return false end
		
		local bagId = GetCursorBagId()
		local slotIndex = GetCursorSlotIndex()
		
		local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
		local equipType = GetItemLinkEquipType(itemLink)
		
		if not WW.GEARTYPE[equipType] then return false end
		local gearSlot = WW.GEARTYPE[equipType]
		
		if IsShiftKeyDown() then
			if gearSlot == EQUIP_SLOT_MAIN_HAND then
				gearSlot = EQUIP_SLOT_BACKUP_MAIN
			elseif gearSlot == EQUIP_SLOT_RING1 then
				gearSlot = EQUIP_SLOT_RING2
			elseif gearSlot == EQUIP_SLOT_POISON then
				gearSlot = EQUIP_SLOT_BACKUP_POISON
			end
		end
		
		local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
		
		-- disabled for empty setups; will be fixed with 1.8
		if setup:IsEmpty() then return end
		
		local gearTable = setup:GetGear()
		
		if gearTable.mythic then
			local isMythic = WW.IsMythic(bagId, slotIndex)
			if isMythic and gearSlot ~= gearTable.mythic then
				gearTable[gearTable.mythic] = {
					["link"] = "",
					["id"] = "0",
				}
				gearTable.mythic = gearSlot
			elseif not isMythic and gearSlot == gearTable.mythic then
				gearTable[gearTable.mythic] = {
					["link"] = "",
					["id"] = "0",
				}
				gearTable.mythic = nil
			end
		end
		
		if gearSlot == EQUIP_SLOT_MAIN_HAND then
			gearTable[EQUIP_SLOT_OFF_HAND] = {
				["link"] = "",
				["id"] = "0",
			}
		elseif gearSlot == EQUIP_SLOT_BACKUP_MAIN then
			gearTable[EQUIP_SLOT_BACKUP_OFF] = {
				["link"] = "",
				["id"] = "0",
			}
		end
		
		gearTable[gearSlot] = {
			id = Id64ToString(GetItemUniqueId(bagId, slotIndex)),
			link = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT),
		}
		
		if GetItemLinkItemType(gearTable[gearSlot].link) == ITEMTYPE_TABARD then
			gearTable[gearSlot].creator = GetItemCreatorName(bagId, slotIndex)
		end
		
		setup:SetGear(gearTable)
		setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
		
		self:GetHandler("OnMouseExit")()
		WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
		self:GetHandler("OnMouseEnter")()
		
		ClearCursor()
		return true
	end
	gearButton:SetHandler("OnReceiveDrag", OnGearDrag)
	gearButton:SetHandler("OnClicked", function(self, mouseButton)
		if OnGearDrag(self) then return end
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
			if IsShiftKeyDown() then
				WW.SaveGear(setup)
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				local tooltip = setup:GetGearText()
				if tooltip and tooltip ~= "" then
					ZO_Tooltips_ShowTextTooltip(self, RIGHT, tostring(tooltip))
				end
				WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetGear({mythic = nil})
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				ZO_Tooltips_HideTextTooltip()
				WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
			else
				WW.LoadGear(setup)
			end
		end
	end)
	local gearFrame = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "GearFrame", setupContainer, CT_TEXTURE)
	gearFrame:SetDimensions(40, 40)
	gearFrame:SetAnchor(CENTER, gearButton, CENTER, 0, 0)
	gearFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
	
	local skillButton = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "SkillButton", setupContainer, CT_BUTTON)
	setupContainer.skillButton = skillButton
	skillButton:SetDimensions(44, 44)
	skillButton:SetAnchor(TOPLEFT, setupContainer, TOPLEFT, x, y + 42 - 2)
	skillButton:SetState(BSTATE_NORMAL)
	skillButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	skillButton:SetNormalTexture("/esoui/art/mainmenu/menubar_skills_up.dds")
	skillButton:SetMouseOverTexture("/esoui/art/mainmenu/menubar_skills_over.dds")
	skillButton:SetPressedTexture("/esoui/art/mainmenu/menubar_skills_down.dds")
	skillButton:SetHandler("OnClicked", function(self, mouseButton)
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
			if IsShiftKeyDown() then
				WW.SaveSkills(setup)
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				local tooltip = setup:GetSkillsText()
				if tooltip and tooltip ~= "" then
					ZO_Tooltips_ShowTextTooltip(self, RIGHT, tostring(tooltip))
				end
				WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetSkills({[0] = {},[1] = {}})
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				ZO_Tooltips_HideTextTooltip()
				WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
			else
				WW.LoadSkills(setup)
			end
		end
	end)
	local skillFrame = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "SkillFrame", setupContainer, CT_TEXTURE)
	skillFrame:SetDimensions(40, 40)
	skillFrame:SetAnchor(CENTER, skillButton, CENTER, 0, 0)
	skillFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
	
	local cpButton = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "CPButton", setupContainer, CT_BUTTON)
	setupContainer.cpButton = cpButton
	cpButton:SetDimensions(42, 42)
	cpButton:SetAnchor(TOPLEFT, setupContainer, TOPLEFT, x + 42 + 1, y + 42 - 1)
	cpButton:SetState(BSTATE_NORMAL)
	cpButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
	cpButton:SetNormalTexture("/esoui/art/mainmenu/menubar_champion_up.dds")
	cpButton:SetMouseOverTexture("/esoui/art/mainmenu/menubar_champion_over.dds")
	cpButton:SetPressedTexture("/esoui/art/mainmenu/menubar_champion_down.dds")
	cpButton:SetHandler("OnClicked", function(self, mouseButton)
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			local setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
			if IsShiftKeyDown() then
				WW.SaveCP(setup)
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				local tooltip = setup:GetCPText()
				if tooltip and tooltip ~= "" then
					ZO_Tooltips_ShowTextTooltip(self, RIGHT, tostring(tooltip))
				end
				WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetCP({})
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				ZO_Tooltips_HideTextTooltip()
				WWG.RefreshSetup(WW.selection.zone, WW.selection.pageId, index)
			else
				WW.LoadCP(setup)
			end
		end
	end)
	local cpFrame = WINDOW_MANAGER:CreateControl(setupContainer:GetName() .. "CPFrame", setupContainer, CT_TEXTURE)
	cpFrame:SetDimensions(40, 40)
	cpFrame:SetAnchor(CENTER, cpButton, CENTER, 0, 0)
	cpFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
	
	return setupContainer
end