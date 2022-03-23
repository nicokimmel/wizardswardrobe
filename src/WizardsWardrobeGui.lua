WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.gui = WW.gui or {}
local WWG = WW.gui

local PANEL_WIDTH = 245
local PANEL_HEIGHT = 70
local PANEL_WIDTH_MINI = PANEL_WIDTH - 70
local PANEL_HEIGHT_MINI = PANEL_HEIGHT - 30

local PANEL_DEFAULT_TOP = ActionButton8:GetTop()  + 25
local PANEL_DEFAULT_LEFT = ActionButton8:GetLeft() + ActionButton8:GetWidth() + 2

local WINDOW_WIDTH = 358
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
	
	WWG.HandleFirstStart()
	WWG.SetSceneManagement()
	WWG.SetDialogManagement()
	
	WWG.SetupPanel()
	WWG.SetupWindow()
	WWG.SetupPageMenu()
	WWG.SetupSetupList()
	WWG.SetupBottomMenu()
	WWG.CreateSetupPool()
	WWG.SetupTopMenu()
	
	WWG.SetupModifyDialog()
	WWG.SetupArrangeDialog()
	
	WWG.RegisterEvents()
	
	zo_callLater(function() WWG.OnWindowResize("stop") end, 250)
end

function WWG.RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(WWG.name, EVENT_PLAYER_DEAD, function() WizardsWardrobePanel.fragment:Refresh() end)
	EVENT_MANAGER:RegisterForEvent(WWG.name, EVENT_PLAYER_ALIVE, function() WizardsWardrobePanel.fragment:Refresh() end)
end

function WWG.HandleFirstStart()
	if not WW.settings.changelogs then WW.settings.changelogs = {} end
	
	if not WW.settings.initialized then
		local function HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, dataString)
			if linkType ~= WW.LINK_TYPES.URL then return end
			if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
				if dataString == "esoui" then
					RequestOpenUnsafeURL("https://www.esoui.com/downloads/info3170-WizardsWardrobe.html")
				end
			end
			return true
		end
		LibChatMessage:RegisterCustomChatLink(WW.LINK_TYPES.URL, function(linkStyle, linkType, data, displayText)
			return ZO_LinkHandler_CreateLinkWithoutBrackets(displayText, nil, WW.LINK_TYPES.URL, data)
		end)
		LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, HandleClickEvent)
		LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, HandleClickEvent)
		zo_callLater(function()
				local urlLink = ZO_LinkHandler_CreateLink("esoui.com", nil, WW.LINK_TYPES.URL, "esoui")
				local pattern = string.format("|c18bed8[|c65d3b0W|cb2e789W|cfffc61]|r |cFFFFFF%s|r", GetString(WW_MSG_FIRSTSTART))
				local output = string.format(pattern, "|r" .. urlLink .. "|cFFFFFF")
				CHAT_ROUTER:AddSystemMessage(output)
				WW.settings.initialized = true
		end, 500)
		
		-- dont show changelogs if first time
		WW.settings.changelogs["v1.8.0"] = true
		return
	end
	
	if not WW.settings.changelogs["v1.8.0"] then
		EVENT_MANAGER:RegisterForUpdate(WWG.name .. "UpdateWarning", 1000, function()
			if not WW.settings.changelogs["v1.8.0"]
				and not ZO_Dialogs_IsShowingDialog() then
				
				WWG.ShowConfirmationDialog(WWG.name .. "UpdateWarning", GetString(WW_CHANGELOG), function()
					EVENT_MANAGER:UnregisterForUpdate(WWG.name .. "UpdateWarning")
					WW.settings.changelogs["v1.8.0"] = true
					RequestOpenUnsafeURL("https://www.esoui.com/downloads/info3170-WizardsWardrobe.html")
				end)
			end
		end)
	end
end

function WWG.SetSceneManagement()
	local onSceneChange = function(scene, oldState, newState)	
		local sceneName = scene:GetName()
		
		if sceneName == "gameMenuInGame" then return end
		
		if newState == SCENE_SHOWING then
			local savedScene = WW.settings.window[sceneName]
			if savedScene then
				if not savedScene.hidden then
					WizardsWardrobeWindow:ClearAnchors()
					WizardsWardrobeWindow:SetAnchor(TOPLEFT, GUI_ROOT, TOPLEFT, savedScene.left, savedScene.top)
					WizardsWardrobeWindow:SetHidden(false)
				end
			end
		end
		
		-- looks better when window hides faster
		if newState == SCENE_HIDING then
			local savedScene = WW.settings.window[sceneName]
			if savedScene then
				WizardsWardrobeWindow:SetHidden(true)
			end
			if sceneName == "hud" or sceneName == "hudui" then
				if not WW.settings.window[sceneName] then
					WW.settings.window[sceneName] = {
						top = WizardsWardrobeWindow:GetTop(),
						left = WizardsWardrobeWindow:GetLeft(),
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
		WizardsWardrobeWindow:ClearAnchors()
		WizardsWardrobeWindow:SetAnchor(CENTER, GUI_ROOT, RIGHT, -(WizardsWardrobeWindow:GetWidth() / 2 + 50), 0)
		WizardsWardrobeWindow:SetHidden(false)
		PlaySound(SOUNDS.DEFAULT_WINDOW_OPEN)
    end)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
		if panel:GetName() ~= "WizardsWardrobeMenu" then return end
		WizardsWardrobeWindow:SetHidden(true)
    end)
	
	SLASH_COMMANDS["/wizard"] = function()
		local scene = SCENE_MANAGER:GetCurrentScene()
		local sceneName = scene:GetName()
		if sceneName == "gameMenuInGame" then
			WizardsWardrobeWindow:SetHidden(not WizardsWardrobeWindow:IsHidden())
			return
		end
		if sceneName == "inventory" and QUICKSLOT_FRAGMENT:IsShowing() then
			sceneName = "inventoryQuickslot"
		end
		local savedScene = WW.settings.window[sceneName]
		if savedScene then
			if savedScene.hidden then
				-- open
				WizardsWardrobeWindow:ClearAnchors()
				WizardsWardrobeWindow:SetAnchor(TOPLEFT, GUI_ROOT, TOPLEFT, savedScene.left, savedScene.top)
				WizardsWardrobeWindow:SetHidden(false)
				PlaySound(SOUNDS.DEFAULT_WINDOW_OPEN)
				SCENE_MANAGER:SetInUIMode(true, false)
				WW.settings.window[sceneName].hidden = false
			else
				-- close
				WizardsWardrobeWindow:SetHidden(true)
				PlaySound(SOUNDS.DEFAULT_WINDOW_CLOSE)
				WW.settings.window[sceneName].hidden = true
			end
		else
			-- open but new
			WizardsWardrobeWindow:ClearAnchors()
			WizardsWardrobeWindow:SetAnchor(CENTER, GUI_ROOT, CENTER, 0, 0)
			WizardsWardrobeWindow:SetHidden(false)
			PlaySound(SOUNDS.DEFAULT_WINDOW_OPEN)
			SCENE_MANAGER:SetInUIMode(true, false)
			WW.settings.window[sceneName] = {
				top = WizardsWardrobeWindow:GetTop(),
				left = WizardsWardrobeWindow:GetLeft(),
				hidden = false,
			}
		end
	end
end

function WWG.SetDialogManagement()
	WWG.dialogList = {}
	SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
		if newState ~= SCENE_HIDING then return end
		for _, dialog in ipairs(WWG.dialogList) do
			dialog:SetHidden(true)
		end
	end)
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
	WizardsWardrobePanel:SetAnchor(TOPLEFT, GUI_ROOT, TOPLEFT, PANEL_DEFAULT_LEFT, PANEL_DEFAULT_TOP)
	WW.settings.window = {
		wizard = {
			width = WINDOW_WIDTH,
			height = WINDOW_HEIGHT,
			scale = 1,
			locked = false,
		},
	}
	WizardsWardrobeWindow:SetWidth(WINDOW_WIDTH)
	WizardsWardrobeWindow:SetHeight(WINDOW_HEIGHT)
	WWG.OnWindowResize("stop")
end

function WWG.SetupPanel()
	WizardsWardrobePanel.fragment = ZO_SimpleSceneFragment:New(WizardsWardrobePanel)
	WizardsWardrobePanel.fragment:SetConditional(function()
		return not WW.settings.panel.hidden and not IsUnitDead("player")
	end)
	HUD_SCENE:AddFragment(WizardsWardrobePanel.fragment)
	HUD_UI_SCENE:AddFragment(WizardsWardrobePanel.fragment)
	zo_callLater(function() WizardsWardrobePanel.fragment:Refresh() end, 1)
	
	WizardsWardrobePanel:SetDrawLayer(2)
	
	WizardsWardrobePanelIcon:SetHandler("OnMouseEnter", function(self)
		self:SetDesaturation(0.4)
	end)
	WizardsWardrobePanelIcon:SetHandler("OnMouseExit", function(self)
		self:SetDesaturation(0)
	end)
	WizardsWardrobePanelIcon:SetHandler("OnMouseDown", function(self)
		self:SetDesaturation(0.8)
	end)
	WizardsWardrobePanelIcon:SetHandler("OnMouseUp", function(self, mouseButton)
		if MouseIsOver(self, 0, 0, 0, 0)
			and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			
			SLASH_COMMANDS["/wizard"]()
			self:SetDesaturation(0.4)
		else
			self:SetDesaturation(0)
		end
	end)
	
	WizardsWardrobePanelTopLabel:SetText(WW.displayName:upper())
	WizardsWardrobePanelMiddleLabel:SetText("Version " .. WW.version)
	WizardsWardrobePanelBottomLabel:SetText("@ownedbynico")
	
	if WW.settings.panel and WW.settings.panel.mini then
		WizardsWardrobePanel:SetDimensions(PANEL_WIDTH_MINI, PANEL_HEIGHT_MINI)
		WizardsWardrobePanelBG:SetHidden(true)
		WizardsWardrobePanelIcon:SetHidden(true)
		WizardsWardrobePanelTopLabel:SetHidden(true)
		WizardsWardrobePanelMiddleLabel:SetAnchor(TOPLEFT, WizardsWardrobePanel, TOPLEFT)
		WizardsWardrobePanelBottomLabel:SetAnchor(BOTTOMLEFT, WizardsWardrobePanel, BOTTOMLEFT)
	end
	
	if WW.settings.panel and WW.settings.panel.top and WW.settings.panel.setup then
		WizardsWardrobePanel:SetAnchor(TOPLEFT, GUI_ROOT, TOPLEFT, WW.settings.panel.left, WW.settings.panel.top)
		WizardsWardrobePanel:SetMovable(not WW.settings.panel.locked)
	else
		WW.settings.panel = {
			top = PANEL_DEFAULT_TOP,
			left = PANEL_DEFAULT_LEFT,
			locked = true,
			hidden = false,
			setup = true,
		}
		WizardsWardrobePanel:SetAnchor(TOPLEFT, GUI_ROOT, TOPLEFT, PANEL_DEFAULT_LEFT, PANEL_DEFAULT_TOP)
	end
end

function WWG.OnPanelMove()
	WW.settings.panel.top = WizardsWardrobePanel:GetTop()
	WW.settings.panel.left = WizardsWardrobePanel:GetLeft()
end

function WWG.SetPanelText(zoneTag, pageName, setupName)
	local middleText = string.format("%s / %s", zoneTag, pageName)
	WizardsWardrobePanelMiddleLabel:SetText(middleText)
	
	local logColor = IsUnitInCombat("player") and WW.LOGTYPES.INFO or WW.LOGTYPES.NORMAL
	local middleText = string.format("|c%s%s|r", logColor, setupName)
	WizardsWardrobePanelBottomLabel:SetText(middleText)
	
	if IsUnitInCombat("player") then
		WW.queue.Push(function()
			middleText = string.format("|c%s%s|r", WW.LOGTYPES.NORMAL, setupName)
			WizardsWardrobePanelBottomLabel:SetText(middleText)
		end)
	end
end

function WWG.SetupWindow()
	WizardsWardrobeWindow.fragment = ZO_SimpleSceneFragment:New(WizardsWardrobeWindow)
	WizardsWardrobeWindow:SetDimensions(WW.settings.window.wizard.width, WW.settings.window.wizard.height)
	WizardsWardrobeWindow:SetResizeHandleSize(8)
	
	WizardsWardrobeWindowTitleLabel:SetText(WW.displayName:upper())
	
	if os.date("%d%m") == "0104" then
		WizardsWardrobeWindow:SetTransformRotationZ(math.rad(180))
	end
end

function WWG.OnWindowMove()
	local scene = SCENE_MANAGER:GetCurrentScene()
	local sceneName = scene:GetName()
	WW.settings.window[sceneName] = {
		top = WizardsWardrobeWindow:GetTop(),
		left = WizardsWardrobeWindow:GetLeft(),
		hidden = false,
	}
end

function WWG.OnWindowResize(action)
	local function OnResize()
		local count = #WWG.setupTable
		local height = WizardsWardrobeWindow:GetHeight() -TITLE_HEIGHT -TOP_MENU_HEIGHT -DIVIDER_HEIGHT -PAGE_MENU_HEIGHT -DIVIDER_HEIGHT -BOTTOM_MENU_HEIGHT
		local width = WizardsWardrobeWindow:GetWidth() - 2
		
		local rows = zo_floor(width / SETUP_BOX_WIDTH)
		local itemsPerCol = zo_ceil(count / rows)
		
		local scrollBox = WizardsWardrobeWindowSetupList:GetNamedChild("ScrollChild")
		
		for i = 1, #WWG.setupTable do
			local key = WWG.setupTable[i]
			local setupControl = WWG.setupPool:AcquireObject(key)
			local x = zo_floor((i-1) / itemsPerCol) * SETUP_BOX_WIDTH + 5
			local y = (((i-1) % itemsPerCol) * SETUP_BOX_HEIGHT)
			setupControl:ClearAnchors()
			setupControl:SetAnchor(TOPLEFT, scrollBox, TOPLEFT, x, y)
		end
		
		WWG.substituteExplain:ClearAnchors()
		WWG.substituteExplain:SetAnchor(TOP, scrollBox, TOP, 0, itemsPerCol * SETUP_BOX_HEIGHT + 10)
		
		WWG.addSetupButton:ClearAnchors()
		WWG.addSetupButton:SetAnchor(TOP, scrollBox, TOP, 0, itemsPerCol * SETUP_BOX_HEIGHT - 10)
		WWG.addSetupButtonSpacer:ClearAnchors()
		WWG.addSetupButtonSpacer:SetAnchor(TOP, scrollBox, TOP, 0, itemsPerCol * SETUP_BOX_HEIGHT + 10)
		
		WizardsWardrobeWindowTitle:SetWidth(width)
		WizardsWardrobeWindowPageMenu:SetWidth(width)
		WizardsWardrobeWindowSetupList:SetDimensions(width, height)
		WizardsWardrobeWindowBottomMenu:SetWidth(width)
		
		WizardsWardrobeWindowTopDivider:SetWidth(width)
		WizardsWardrobeWindowBottomDivider:SetWidth(width)
	end
	
	local function OnResizeEnd()
		local rows = zo_floor(((WizardsWardrobeWindow:GetWidth() + 2) / SETUP_BOX_WIDTH) + 0.5)
		local width = rows * SETUP_BOX_WIDTH + 8
		WizardsWardrobeWindow:SetWidth(width)
		OnResize()
		
		WW.settings.window.wizard.width = WizardsWardrobeWindow:GetWidth()
		WW.settings.window.wizard.height = WizardsWardrobeWindow:GetHeight()
	end
	
	local identifier = WW.name .. "WindowResize"
	if action == "start" then
		EVENT_MANAGER:RegisterForUpdate(identifier, 50, OnResize)
	elseif action == "stop" then
		EVENT_MANAGER:UnregisterForUpdate(identifier)
		OnResizeEnd()
	end
end

function WWG.SetupTopMenu()
	WizardsWardrobeWindowTitleHide:SetHandler("OnClicked", function(self)
		SLASH_COMMANDS["/wizard"]()
	end)
	
	local selection = GridComboBox:New("$(parent)Selection", WizardsWardrobeWindow)
	selection:SetAnchor(LEFT, WizardsWardrobeWindowTopMenu, LEFT, 16)
	selection:SetDimensions(240, 16)
	selection:SetItemsPerRow(4)
    selection:SetItemSize(57)
	selection:SetItemSpacing(4)
	selection:ClearItems()
	for _, zone in ipairs(WWG.GetSortedZoneList()) do
		selection:AddItem({
			label = zone.name,
			tag = zone.tag,
			icon = zone.icon,
			callback = function()
				WWG.OnZoneSelect(zone)
			end,
		})
	end
	WWG.zoneSelection = selection
	
	WizardsWardrobeWindowTopMenuAddPage:SetHandler("OnClicked", function(self)
		WWG.CreatePage(WW.selection.zone)
	end)
	WWG.SetTooltip(WizardsWardrobeWindowTopMenuAddPage, TOP, GetString(WW_BUTTON_ADDPAGE))
	
	local autoEquipTextures = {
		[true] = "/esoui/art/crafting/smithing_tabicon_armorset_down.dds",
		[false] = "/esoui/art/crafting/smithing_tabicon_armorset_up.dds"
	}
	local autoEquipMessages = {
		[true] = GetString(WW_MSG_TOGGLEAUTOEQUIP_ON),
		[false] = GetString(WW_MSG_TOGGLEAUTOEQUIP_OFF)
	}
	WizardsWardrobeWindowTopMenuAutoEquip:SetHandler("OnClicked", function(self)
		WW.settings.autoEquipSetups = not WW.settings.autoEquipSetups
		WW.storage.autoEquipSetups = WW.settings.autoEquipSetups
		self:SetNormalTexture(autoEquipTextures[WW.settings.autoEquipSetups])
		WW.Log(GetString(WW_MSG_TOGGLEAUTOEQUIP), WW.LOGTYPES.NORMAL, nil, autoEquipMessages[WW.settings.autoEquipSetups])
	end)
	WizardsWardrobeWindowTopMenuAutoEquip:SetNormalTexture(autoEquipTextures[WW.settings.autoEquipSetups])
	WWG.SetTooltip(WizardsWardrobeWindowTopMenuAutoEquip, TOP, GetString(WW_BUTTON_TOGGLEAUTOEQUIP))
end

function WWG.OnZoneSelect(zone)
	PlaySound(SOUNDS.TABLET_PAGE_TURN)
	
	if not WW.pages[zone.tag] then
		WWG.CreatePage(zone, true)
	end
	
	WW.selection.zone = zone
	WW.selection.pageId = WW.pages[zone.tag][0].selected
	
	WWG.BuildPage(WW.selection.zone, WW.selection.pageId)
	
	WWG.zoneSelection:SetLabel(zone.name)
	
	local isSubstitute = zone.tag == "SUB"
	WWG.substituteExplain:SetHidden(not isSubstitute)
	WWG.addSetupButton:SetHidden(isSubstitute)
end

function WWG.SetupPageMenu()
	WizardsWardrobeWindowPageMenuWarning:SetHandler("OnMouseUp", function(self, mouseButton)
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			local missingGear = WW.CheckGear(WW.selection.zone, WW.selection.pageId)
			if #missingGear > 0 then
				local missingGearText = string.format(GetString(WW_MISSING_GEAR_TT), WWG.GearLinkTableToString(missingGear))
				WWG.SetTooltip(self, TOP, missingGearText)
			else
				self:SetHidden(true)
				WWG.SetTooltip(self, TOP, nil)
			end
		end
	end)
	WizardsWardrobeWindowPageMenuDropdown:SetHandler("OnClicked", function(self, mouseButton)
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsMenuVisible() then
				ClearMenu()
			else
				WWG.ShowPageContextMenu(WizardsWardrobeWindowPageMenuLabel)
			end
		end
	end)
	WizardsWardrobeWindowPageMenuBank:SetHandler("OnClicked", function(self)
		if IsShiftKeyDown() then
			WW.banking.DepositPage(WW.selection.zone, WW.selection.pageId)
		else
			WW.banking.WithdrawPage(WW.selection.zone, WW.selection.pageId)
		end
	end)
	WizardsWardrobeWindowPageMenuLeft:SetHandler("OnClicked", function(self)
		WWG.PageLeft()
	end)
	WizardsWardrobeWindowPageMenuRight:SetHandler("OnClicked", function(self)
		WWG.PageRight()
	end)
end

function WWG.SetupSetupList()
	-- always show scrollbar (set hidden to false only would show some errors)
	local oldScrollFunction = ZO_Scroll_UpdateScrollBar
	ZO_Scroll_UpdateScrollBar = function(self, forceUpdateBarValue)
		local _, verticalExtents = self.scroll:GetScrollExtents()
		if verticalExtents > 0 or self:GetName() ~= "WizardsWardrobeWindowSetupList" then
			oldScrollFunction(self, forceUpdateBarValue)
		else
			ZO_Scroll_ResetToTop(self)
			self.scroll:SetFadeGradient(1, 0, 0, 0)
			local scrollBarHeight = self.scrollbar:GetHeight() / self.scroll:GetScale()
			self.scrollbar:SetThumbTextureHeight(scrollBarHeight)
			self.scrollbar:SetHidden(false)
		end
	end
	
	local scrollBox = WizardsWardrobeWindowSetupList:GetNamedChild("ScrollChild")
	WWG.addSetupButton = WWG.CreateButton({
		parent = scrollBox,
		size = 42,
		anchor = {TOPLEFT, scrollBox, TOPLEFT},
		texture = "/esoui/art/buttons/plus",
		tooltip = GetString(WW_BUTTON_ADDSETUP),
		clicked = function() WWG.CreateSetup() end,
	})
	WWG.addSetupButtonSpacer = WWG.CreateLabel({
		parent = scrollBox,
		font = "ZoFontGame",
		text = " ",
		anchor = {TOPLEFT, scrollBox, TOPLEFT},
	})
	WWG.substituteExplain = WWG.CreateLabel({
		parent = scrollBox,
		font = "ZoFontGame",
		text = GetString(WW_SUBSTITUTE_EXPLAIN),
		constraint = 310,
		anchor = {TOPLEFT, scrollBox, TOPLEFT},
		hidden = true,
	})
end

function WWG.SetupBottomMenu()
	WWG.SetTooltip(WizardsWardrobeWindowBottomMenuSettings, TOP, GetString(WW_BUTTON_SETTINGS))
	WizardsWardrobeWindowBottomMenuSettings:SetHandler("OnClicked", function(self)
		LibAddonMenu2:OpenToPanel(WW.menu.panel)
	end)
	WWG.SetTooltip(WizardsWardrobeWindowBottomMenuQueue, TOP, GetString(WW_BUTTON_CLEARQUEUE))
	WizardsWardrobeWindowBottomMenuQueue:SetHandler("OnClicked", function(self)
		local entries = WW.queue.Size()
		WW.queue.Reset()
		WW.Log(GetString(WW_MSG_CLEARQUEUE), WW.LOGTYPES.NORMAL, nil, entries)
	end)
	WWG.SetTooltip(WizardsWardrobeWindowBottomMenuUndress, TOP, GetString(WW_BUTTON_UNDRESS))
	WizardsWardrobeWindowBottomMenuUndress:SetHandler("OnClicked", function(self)
		WW.Undress()
	end)
	WWG.SetTooltip(WizardsWardrobeWindowBottomMenuPrebuff, TOP, GetString(WW_BUTTON_PREBUFF))
	WizardsWardrobeWindowBottomMenuPrebuff:SetHandler("OnClicked", function(self)
		WW.prebuff.dialog:SetHidden(false)
	end)
	WWG.SetTooltip(WizardsWardrobeWindowBottomMenuHelp, TOP, GetString(WW_HELP))
end

function WWG.CreateButton(data)
	local button = WINDOW_MANAGER:CreateControl(data.name, data.parent, CT_BUTTON)
	button:SetDimensions(data.size, data.size)
	button:SetAnchor(unpack(data.anchor))
	button:SetHidden(data.hidden or false)
	button:SetClickSound(SOUNDS.DEFAULT_CLICK)
	button:SetNormalTexture(data.texture .. "_up.dds")
	button:SetMouseOverTexture(data.texture .. "_over.dds")
	button:SetPressedTexture(data.texture .. "_down.dds")
	button:SetDisabledTexture(data.texture .. "_disabled.dds")
	if data.clicked then button:SetHandler("OnClicked", data.clicked) end
	if data.tooltip then WWG.SetTooltip(button, TOP, data.tooltip) end
	return button
end

function WWG.CreateLabel(data)
	local label = WINDOW_MANAGER:CreateControl(data.name, data.parent, CT_LABEL)
	label:SetFont(data.font)
	label:SetText(data.text or "")
	label:SetAnchor(unpack(data.anchor))
	label:SetDimensionConstraints(AUTO_SIZE, AUTO_SIZE, data.constraint or AUTO_SIZE, data.oneline and label:GetFontHeight() or AUTO_SIZE)
	label:SetHidden(data.hidden or false)
	label:SetMouseEnabled(data.mouse or false)
	if data.tooltip then WWG.SetTooltip(label, TOP, data.tooltip) end
	return label
end

function WWG.CreateSetupPool()
	local scrollBox = WizardsWardrobeWindowSetupList:GetNamedChild("ScrollChild")
	
	local function FactoryItem()
        local setup = WINDOW_MANAGER:CreateControl(nil, scrollBox, CT_CONTROL)
		setup:SetDimensions(SETUP_BOX_WIDTH, SETUP_BOX_HEIGHT)
		
		setup.name = WWG.CreateLabel({
			parent = setup,
			font = "ZoFontWinH4",
			anchor = {TOPLEFT, setup, TOPLEFT},
			constraint = 252,
			oneline = true,
			mouse = true,
		})
		setup.dropdown = WWG.CreateButton({
			parent = setup,
			size = 16,
			anchor = {LEFT, setup.name, RIGHT, 2, 0},
			texture = "/esoui/art/buttons/scrollbox_downarrow",
		})
		setup.modify = WWG.CreateButton({
			parent = setup,
			size = 32,
			anchor = {TOPRIGHT, setup, TOPRIGHT, -8, -8},
			texture = "/esoui/art/buttons/edit",
			tooltip = GetString(WW_BUTTON_MODIFY),
		})
		setup.save = WWG.CreateButton({
			parent = setup,
			size = 32,
			anchor = {RIGHT, setup.modify, LEFT, 8},
			texture = "/esoui/art/buttons/edit_save",
			tooltip = GetString(WW_BUTTON_SAVE),
		})
		setup.preview = WWG.CreateButton({
			parent = setup,
			size = 32,
			anchor = {RIGHT, setup.save, LEFT, 6, 2},
			texture = "/esoui/art/guild/tabicon_roster",
			tooltip = GetString(WW_BUTTON_PREVIEW),
		})
		setup.banking = WWG.CreateButton({
			parent = setup,
			hidden = true,
			size = 34,
			anchor = {RIGHT, setup.preview, LEFT, 6},
			texture = "/esoui/art/icons/guildranks/guild_indexicon_misc09",
			tooltip = GetString(WW_BUTTON_BANKING),
		})
		
		local skills = { [0] = {}, [1] = {} }
		for hotbarCategory = 0, 1 do
			for slotIndex = 3, 8 do
				local x = (slotIndex - 3) * 42
				local y = hotbarCategory * 42 + 25
				
				local skill = WINDOW_MANAGER:CreateControl(nil, setup, CT_TEXTURE)
				skill:SetDimensions(40, 40)
				skill:SetAnchor(TOPLEFT, setup, TOPLEFT, x, y)
				skill:SetDrawLevel(2)
				skill:SetMouseEnabled(true)
				skill:SetTexture("/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds")
				skills[hotbarCategory][slotIndex] = skill
				
				local frame = WINDOW_MANAGER:CreateControl(nil, skill, CT_TEXTURE)
				frame:SetDimensions(40, 40)
				frame:SetAnchor(CENTER, skill, CENTER, 0, 0)
				frame:SetDrawLevel(3)
				frame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
			end
		end
		setup.skills = skills
		
		local x = 6 * 42
		local y = 25
		
		setup.food = WWG.CreateButton({
			parent = setup,
			size = 42,
			anchor = {TOPLEFT, setup, TOPLEFT, x + 1, y - 1},
			texture = "/esoui/art/crafting/provisioner_indexicon_meat",
		})
		local foodFrame = WINDOW_MANAGER:CreateControl(nil, setup.food, CT_TEXTURE)
		foodFrame:SetDimensions(40, 40)
		foodFrame:SetAnchor(CENTER, setup.food, CENTER, 0, 0)
		foodFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
		
		setup.gear = WWG.CreateButton({
			parent = setup,
			size = 42,
			anchor = {TOPLEFT, setup, TOPLEFT, x + 42, y - 1},
			texture = "/esoui/art/guild/tabicon_heraldry",
		})
		local gearFrame = WINDOW_MANAGER:CreateControl(nil, setup.gear, CT_TEXTURE)
		gearFrame:SetDimensions(40, 40)
		gearFrame:SetAnchor(CENTER, setup.gear, CENTER, 0, 0)
		gearFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
		
		setup.skill = WWG.CreateButton({
			parent = setup,
			size = 44,
			anchor = {TOPLEFT, setup, TOPLEFT, x, y + 42 - 2},
			texture = "/esoui/art/mainmenu/menubar_skills",
		})
		local skillFrame = WINDOW_MANAGER:CreateControl(nil, setup.skill, CT_TEXTURE)
		skillFrame:SetDimensions(40, 40)
		skillFrame:SetAnchor(CENTER, setup.skill, CENTER, 0, 0)
		skillFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
		
		setup.cp = WWG.CreateButton({
			parent = setup,
			size = 40,
			anchor = {TOPLEFT, setup, TOPLEFT, x + 42 + 1, y + 42},
			texture = "/esoui/art/mainmenu/menubar_champion",
		})
		local cpFrame = WINDOW_MANAGER:CreateControl(nil, setup.cp, CT_TEXTURE)
		cpFrame:SetDimensions(40, 40)
		cpFrame:SetAnchor(CENTER, setup.cp, CENTER, 0, 0)
		cpFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
		
        return setup
    end
    local function ResetItem(setup)
        setup:SetHidden(true)
    end
    
    WWG.setupPool = ZO_ObjectPool:New(FactoryItem, ResetItem)
end

function WWG.AquireSetupControl(setup)
	local setupControl, key = WWG.setupPool:AcquireObject()
	table.insert(WWG.setupTable, key)
	local index = #WWG.setupTable
	
	setupControl:SetHidden(false)
	setupControl.i = index
	
	setupControl.name:SetHandler("OnMouseEnter", function(self)
		ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(WW_BUTTON_LABEL))
		if not setup:IsDisabled() then
		 	self:SetColor(1, 0.5, 0.5, 1)
		end
	end)
	setupControl.name:SetHandler("OnMouseExit", function(self)
		ZO_Tooltips_HideTextTooltip()
		local color = 1
		if setup:IsDisabled() then
		 	color = 0.3
		end
		self:SetColor(color, color, color, 1)
	end)
	setupControl.name:SetHandler("OnMouseDown", function(self)
		self:SetColor(0.8, 0.4, 0.4, 1)
	end)
	setupControl.name:SetHandler("OnMouseUp", function(self, mouseButton)
		if not MouseIsOver(self, 0, 0, 0, 0) then return end
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			WW.LoadSetupCurrent(index, false)
		end
	end)
	
	setupControl.dropdown:SetHandler("OnClicked", function(self, mouseButton)
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsMenuVisible() then
				ClearMenu()
			else
				WWG.ShowSetupContextMenu(setupControl.name, index)
			end
		end
	end)
	setupControl.modify:SetEnabled(not (WW.selection.zone.tag == "SUB"))
	setupControl.modify:SetHandler("OnClicked", function(self)
		WWG.ShowModifyDialog(setupControl, setup, index)
	end)
	setupControl.save:SetHandler("OnClicked", function(self)
		WW.SaveSetup(WW.selection.zone, WW.selection.pageId, index)
		setup = Setup:FromStorage(WW.selection.zone.tag, WW.selection.pageId, index)
		WWG.RefreshSetup(setupControl, setup)
	end)
	setupControl.preview:SetHandler("OnClicked", function(self)
		WW.preview.ShowPreviewFromSetup(setup, WW.selection.zone.name)
	end)
	setupControl.banking:SetHandler("OnClicked", function(self)
		if IsShiftKeyDown() then
			WW.banking.DepositSetup(WW.selection.zone, WW.selection.pageId, index)
		else
			WW.banking.WithdrawSetup(WW.selection.zone, WW.selection.pageId, index)
		end
	end)
	
	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local skillControl = setupControl.skills[hotbarCategory][slotIndex]
			local function OnSkillDragStart(self)
				if IsUnitInCombat("player") then return	end -- would fail at protected call anyway
				if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then return end
				
				local abilityId = setup:GetSkills()[hotbarCategory][slotIndex]
				if not abilityId then return end
				
				local baseAbilityId = WW.GetBaseAbilityId(abilityId)
				if not baseAbilityId then return end
				
				local skillType, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(baseAbilityId)
				if CallSecureProtected("PickupAbilityBySkillLine", skillType, skillLine, skillIndex) then
					setup:SetSkill(hotbarCategory, slotIndex, 0)
					setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
					self:GetHandler("OnMouseExit")()
					WWG.RefreshSetup(setupControl, setup)
				end
			end
			local function OnSkillDragReceive(self)
				if GetCursorContentType() ~= MOUSE_CONTENT_ACTION then return end
				local abilityId = GetCursorAbilityId()
				
				local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityId)
				if not progression then return end
				
				if progression:IsUltimate() and slotIndex < 8 or
					not progression:IsUltimate() and slotIndex > 7 then
					-- Prevent ult on normal slot and vice versa
					return
				end
				
				if progression:IsChainingAbility() then
					abilityId = GetEffectiveAbilityIdForAbilityOnHotbar(abilityId, hotbarCategory)
				end
				
				ClearCursor()
				
				local previousAbilityId = setup:GetSkills()[hotbarCategory][slotIndex]
				setup:SetSkill(hotbarCategory, slotIndex, abilityId)
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				
				self:GetHandler("OnMouseExit")()
				WWG.RefreshSetup(setupControl, setup)
				
				if previousAbilityId and previousAbilityId > 0 then
					local baseAbilityId = WW.GetBaseAbilityId(previousAbilityId)
					local skillType, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(baseAbilityId)
					CallSecureProtected("PickupAbilityBySkillLine", skillType, skillLine, skillIndex)
				end
			end
			skillControl:SetHandler("OnReceiveDrag", OnSkillDragReceive)
			skillControl:SetHandler("OnMouseUp", function(self)
				if MouseIsOver(self, 0, 0, 0, 0) then
					OnSkillDragReceive(self)
				end
			end)
			skillControl:SetHandler("OnDragStart", OnSkillDragStart)
		end
	end
	
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
		
		WW.SaveFood(setup, slotIndex)
		setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
		
		self:GetHandler("OnMouseExit")()
		WWG.RefreshSetup(setupControl, setup)
		self:GetHandler("OnMouseEnter")()
		
		ClearCursor()
		return true
	end
	setupControl.food:SetHandler("OnReceiveDrag", OnFoodDrag)
	setupControl.food:SetHandler("OnClicked", function(self, mouseButton)
		if OnFoodDrag(self) then return end
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsShiftKeyDown() then
				WW.SaveFood(setup)
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				self:GetHandler("OnMouseExit")()
				WWG.RefreshSetup(setupControl, setup)
				self:GetHandler("OnMouseEnter")()
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetFood({})
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				ZO_Tooltips_HideTextTooltip()
				self:GetHandler("OnMouseExit")()
				WWG.RefreshSetup(setupControl, setup)
				self:GetHandler("OnMouseEnter")()
			else
				WW.EatFood(setup)
			end
		end
	end)
	
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
		WWG.RefreshSetup(setupControl, setup)
		self:GetHandler("OnMouseEnter")()
		
		ClearCursor()
		return true
	end
	setupControl.gear:SetHandler("OnReceiveDrag", OnGearDrag)
	setupControl.gear:SetHandler("OnClicked", function(self, mouseButton)
		if OnGearDrag(self) then return end
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsShiftKeyDown() then
				WW.SaveGear(setup)
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				local tooltip = setup:GetGearText()
				if tooltip and tooltip ~= "" then
					ZO_Tooltips_ShowTextTooltip(self, RIGHT, tostring(tooltip))
				end
				WWG.RefreshSetup(setupControl, setup)
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetGear({mythic = nil})
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				ZO_Tooltips_HideTextTooltip()
				WWG.RefreshSetup(setupControl, setup)
			else
				WW.LoadGear(setup)
			end
		end
	end)
	
	setupControl.skill:SetHandler("OnClicked", function(self, mouseButton)
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsShiftKeyDown() then
				WW.SaveSkills(setup)
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				local tooltip = setup:GetSkillsText()
				if tooltip and tooltip ~= "" then
					ZO_Tooltips_ShowTextTooltip(self, RIGHT, tostring(tooltip))
				end
				WWG.RefreshSetup(setupControl, setup)
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetSkills({[0] = {},[1] = {}})
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				ZO_Tooltips_HideTextTooltip()
				WWG.RefreshSetup(setupControl, setup)
			else
				WW.LoadSkills(setup)
			end
		end
	end)
	
	setupControl.cp:SetHandler("OnClicked", function(self, mouseButton)
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsShiftKeyDown() then
				WW.SaveCP(setup)
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				local tooltip = setup:GetCPText()
				if tooltip and tooltip ~= "" then
					ZO_Tooltips_ShowTextTooltip(self, RIGHT, tostring(tooltip))
				end
				WWG.RefreshSetup(setupControl, setup)
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetCP({})
				setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
				ZO_Tooltips_HideTextTooltip()
				WWG.RefreshSetup(setupControl, setup)
			else
				WW.LoadCP(setup)
			end
		end
	end)
	
	return setupControl
end

function WWG.GetSetupControl(index)
	local key = WWG.setupTable[index]
	local setupControl = WWG.setupPool:AcquireObject(key)
	return setupControl
end

function WWG.CreateSetup()
	local index = #WWG.setupTable + 1
	local tag = WW.selection.zone.tag
	local pageId = WW.selection.pageId
	
	local setup = Setup:FromStorage(tag, pageId, index)
	setup:ToStorage(tag, pageId, index)
	
	local control = WWG.AquireSetupControl(setup)
	WWG.RefreshSetup(control, setup)
	WWG.OnWindowResize("stop")
end

function WWG.RenameSetup()
	
end

function WWG.ClearPage()
	for i = 1, #WWG.setupTable do
		local key = WWG.setupTable[i]
		WWG.setupPool:ReleaseObject(key)
	end
	WWG.setupTable = {}
end

function WWG.BuildPage(zone, pageId)
	WWG.ClearPage()
	for entry in WW.PageIterator(zone, pageId) do
		local setup = Setup:FromStorage(zone.tag, pageId, entry.index)
		local control = WWG.AquireSetupControl(setup)
	end
	if zone.tag == "SUB" and #WWG.setupTable == 0 then
		WWG.CreateDefaultSetups(zone, pageId)
		WWG.BuildPage(zone, pageId)
		return
	end
	WWG.RefreshPage()
	WWG.OnWindowResize("stop")
	ZO_Scroll_ResetToTop(WizardsWardrobeWindowSetupList)
end

function WWG.CreatePage(zone, skipBuilding)
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
	
	WWG.CreateDefaultSetups(WW.selection.zone, WW.selection.pageId)
	
	if not skipBuilding then
		WWG.BuildPage(WW.selection.zone, WW.selection.pageId)
	end
	
	return nextPageId
end

function WWG.CreateDefaultSetups(zone, pageId)
	for i, boss in ipairs(zone.bosses) do
		local setup = Setup:FromStorage(zone.tag, pageId, i)
		setup:SetName(boss.displayName or boss.name)
		setup:SetCondition({
			boss = boss.name,
			trash = (boss.name == GetString(WW_TRASH)) and WW.CONDITIONS.EVERYWHERE or nil
		})
		setup:ToStorage(zone.tag, pageId, i)
	end
end

function WWG.DuplicatePage()
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	
	local cloneId = WWG.CreatePage(zone, true)
	
	local pageName = WW.pages[zone.tag][pageId].name
	WW.pages[zone.tag][cloneId].name = string.format(GetString(WW_DUPLICATE_NAME), pageName)
	
	WW.setups[zone.tag][cloneId] = {}
	ZO_DeepTableCopy(WW.setups[zone.tag][pageId], WW.setups[zone.tag][cloneId])
	
	WWG.BuildPage(WW.selection.zone, WW.selection.pageId)
end

function WWG.DeletePage()
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	
	local nextPageId = pageId - 1
	if nextPageId < 1 then nextPageId = pageId end
	
	WW.pages[zone.tag][0].selected = nextPageId
	WW.selection.pageId = nextPageId
	
	table.remove(WW.pages[zone.tag], pageId)
	if WW.setups[zone.tag] and WW.setups[zone.tag][pageId] then
		-- does not get removed??
		table.remove(WW.setups[zone.tag], pageId)
	end
	
	WW.markers.BuildGearList()
	WWG.BuildPage(zone, nextPageId)
	
	return nextPageId
end

function WWG.RenamePage()
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	
	local initialText = WW.pages[zone.tag][pageId].name
	WWG.ShowEditDialog("PageNameEdit", GetString(WW_RENAME_PAGE), initialText,
	function(input)
		if not input then
			return
		end
		if input == "" then
			WW.pages[zone.tag][pageId].name = GetString(WW_UNNAMED)
		else
			WW.pages[zone.tag][pageId].name = input
		end
		local pageName = WW.pages[zone.tag][pageId].name
		WizardsWardrobeWindowPageMenuLabel:SetText(pageName:upper())
	end)
end

function WWG.PageLeft()
	if WW.selection.pageId - 1 < 1 then
		return
	end
	local prevPage = WW.selection.pageId - 1
	WW.selection.pageId = prevPage
	WW.pages[WW.selection.zone.tag][0].selected = prevPage
	WWG.BuildPage(WW.selection.zone, WW.selection.pageId)
end

function WWG.PageRight()
	if WW.selection.pageId + 1 > #WW.pages[WW.selection.zone.tag] then
		return
	end
	local nextPage = WW.selection.pageId + 1
	WW.selection.pageId = nextPage
	WW.pages[WW.selection.zone.tag][0].selected = nextPage
	WWG.BuildPage(WW.selection.zone, WW.selection.pageId)
end

function WWG.RefreshPage()
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	
	for i = 1, #WWG.setupTable do
		local setupControl = WWG.GetSetupControl(i)
		local setup = Setup:FromStorage(zone.tag, pageId, i)
		WWG.RefreshSetup(setupControl, setup)
	end
	
	local pageName = WW.pages[zone.tag][pageId].name
	WizardsWardrobeWindowPageMenuLabel:SetText(pageName:upper())
	
	if pageId == 1 then WizardsWardrobeWindowPageMenuLeft:SetEnabled(false) else WizardsWardrobeWindowPageMenuLeft:SetEnabled(true) end
	if pageId == #WW.pages[zone.tag] then WizardsWardrobeWindowPageMenuRight:SetEnabled(false) else WizardsWardrobeWindowPageMenuRight:SetEnabled(true) end
	
	WW.conditions.LoadConditions()
	
	local missingGear = WW.CheckGear(zone, pageId)
	if #missingGear > 0 then
		WizardsWardrobeWindowPageMenuWarning:SetHidden(false)
		local missingGearText = string.format(GetString(WW_MISSING_GEAR_TT), WWG.GearLinkTableToString(missingGear))
		WWG.SetTooltip(WizardsWardrobeWindowPageMenuWarning, TOP, missingGearText)
	else
		WizardsWardrobeWindowPageMenuWarning:SetHidden(true)
		WWG.SetTooltip(WizardsWardrobeWindowPageMenuWarning, TOP, nil)
	end
	
	WWG.OnWindowResize("stop")
end

function WWG.RefreshSetup(control, setup)
	local color = (setup:IsDisabled() and 0.3 or 1)
	local name = string.format("|cC5C29E%s|r %s", control.i, setup:GetName():upper())
	control.name:SetText(name)
	control.name:SetColor(color, color, color, 1)
	
	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local abilityId = setup:GetSkills()[hotbarCategory][slotIndex]
			local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
			if abilityId and abilityId > 0 then
				abilityIcon = GetAbilityIcon(abilityId)
			end
			local skillControl = control.skills[hotbarCategory][slotIndex]
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
	
	local food = setup:GetFood()
	if food.link then
		control.food:SetHandler("OnMouseEnter", function()
			InitializeTooltip(ItemTooltip, control.food, LEFT, 4, 0, RIGHT)
			ItemTooltip:SetLink(food.link)
		end)
		control.food:SetHandler("OnMouseExit", function()
			ClearTooltip(ItemTooltip)
		end)
	else
		WWG.SetTooltip(control.food, RIGHT, GetString(WW_BUTTON_BUFFFOOD))
	end
	
	local gearText = setup:GetGearText()
	WWG.SetTooltip(control.gear, RIGHT, gearText)
	
	local skillsText = setup:GetSkillsText()
	WWG.SetTooltip(control.skill, RIGHT, skillsText)
	
	local cpText = setup:GetCPText()
	WWG.SetTooltip(control.cp, RIGHT, cpText)
	
	if IsBankOpen() and not WW.DISABLEDBAGS[GetBankingBag()] then
		control.banking:SetHidden(false)
		WizardsWardrobeWindowPageMenuBank:SetHidden(false)
	else
		control.banking:SetHidden(true)
		WizardsWardrobeWindowPageMenuBank:SetHidden(true)
	end
end

function WWG.ShowPageContextMenu(control)
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	
	ClearMenu()
	
	AddMenuItem(GetString(WW_BUTTON_RENAME), function() WWG.RenamePage() end, MENU_ADD_OPTION_LABEL)
	
	if WW.selection.zone.tag ~= "SUB" then
		AddMenuItem(GetString(WW_BUTTON_REARRANGE), function() WWG.ShowArrangeDialog(zone, pageId) end, MENU_ADD_OPTION_LABEL)
	end
	
	AddMenuItem(GetString(WW_DUPLICATE), function() WWG.DuplicatePage() end, MENU_ADD_OPTION_LABEL)
	
	AddMenuItem(GetString(WW_DELETE):upper(), function()
		if #WW.pages[zone.tag] > 1 then
			local pageName = WW.pages[zone.tag][pageId].name
			WWG.ShowConfirmationDialog("DeletePageConfirmation", string.format(GetString(WW_DELETEPAGE_WARNING), pageName),
			function()
				WWG.DeletePage()
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

function WWG.ShowSetupContextMenu(control, index)
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	
	ClearMenu()
	
	-- LINK TO CHAT
	AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
		WW.preview.PrintPreviewString(zone, pageId, index)
	end, MENU_ADD_OPTION_LABEL)
	
	-- CUSTOM CODE
	AddMenuItem(GetString(WW_CUSTOMCODE), function() WW.code.ShowCodeDialog(zone, pageId, index) end, MENU_ADD_OPTION_LABEL)
	
	-- IMPORT / EXPORT
	AddMenuItem(GetString(WW_IMPORT), function() WW.transfer.ShowImportDialog(zone.tag, pageId, index) end, MENU_ADD_OPTION_LABEL)
	AddMenuItem(GetString(WW_EXPORT), function() WW.transfer.ShowExportDialog(zone.tag, pageId, index) end, MENU_ADD_OPTION_LABEL)
	
	-- ENABLE / DISABLE
	--if setup:IsDisabled() then
	--	AddMenuItem(GetString(WW_ENABLE), function() WWG.SetSetupDisabled(zone, pageId, index, false) end, MENU_ADD_OPTION_LABEL)
	--else
	--	AddMenuItem(GetString(WW_DISABLE), function() WWG.SetSetupDisabled(zone, pageId, index, true) end, MENU_ADD_OPTION_LABEL)
	--end
	
	-- DELETE
	if WW.selection.zone.tag ~= "SUB" then
		AddMenuItem(GetString(WW_DELETE):upper(), function()
			PlaySound(SOUNDS.DEFER_NOTIFICATION)
			WW.DeleteSetup(zone, pageId, index)
		end, MENU_ADD_OPTION_LABEL, "ZoFontGameBold", ZO_ColorDef:New(1, 0, 0, 1), ZO_ColorDef:New(1, 0, 0, 1))
	end
	
	-- lets fix some ZOS bugs(?)
	if control:GetWidth() >= ZO_Menu.width then
        ZO_Menu.width = control:GetWidth() - 10
    end
	
	ShowMenu(control, 2, MENU_TYPE_COMBO_BOX)
	SetMenuPad(100)
	AnchorMenu(control, 0)
end

function WWG.SetupModifyDialog()
	WizardsWardrobeModify:SetDimensions(GuiRoot:GetWidth() + 8, GuiRoot:GetHeight() + 8)
	WizardsWardrobeModifyDialogTitle:SetText(GetString(WW_BUTTON_MODIFY):upper())
	WizardsWardrobeModifyDialogHide:SetHandler("OnClicked", function(self)
		WizardsWardrobeModify:SetHidden(true)
	end)
	WizardsWardrobeModifyDialogSave:SetText(GetString(WW_BUTTON_SAVE))
	WizardsWardrobeModifyDialogNameLabel:SetText(GetString(WW_CONDITION_NAME):upper())
	WizardsWardrobeModifyDialogConditionBossLabel:SetText(GetString(WW_CONDITION_BOSS):upper())
	WizardsWardrobeModifyDialogConditionTrashLabel:SetText(GetString(WW_CONDITION_AFTER):upper())
	table.insert(WWG.dialogList, WizardsWardrobeModify)
end

function WWG.ShowModifyDialog(setupControl, setup, index)
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	
	local condition = setup:GetCondition()
	
	local newBoss, newTrash
	
	WizardsWardrobeModifyDialogNameEdit:SetText(setup:GetName())
	
	if zone.tag == "GEN" then
		WizardsWardrobeModifyDialogCondition:SetHeight(50)
		WizardsWardrobeModifyDialogConditionBossCombo:SetHidden(true)
		WizardsWardrobeModifyDialogConditionBossEdit:SetHidden(false)
		WizardsWardrobeModifyDialogConditionTrashLabel:SetHidden(true)
		WizardsWardrobeModifyDialogConditionTrashCombo:SetHidden(true)
		
		WizardsWardrobeModifyDialogConditionBossEdit:SetText(condition.boss or "")
		WizardsWardrobeModifyDialogConditionBossEdit:SetHandler("OnTextChanged", function(self)
			newBoss = self:GetText()
		end)
	else
		local function OnBossCombo(selection)
			newBoss = selection
			if newBoss == GetString(WW_TRASH) then
				WizardsWardrobeModifyDialogCondition:SetHeight(100)
				WizardsWardrobeModifyDialogConditionTrashLabel:SetHidden(false)
				WizardsWardrobeModifyDialogConditionTrashCombo:SetHidden(false)
			else
				WizardsWardrobeModifyDialogCondition:SetHeight(50)
				WizardsWardrobeModifyDialogConditionTrashLabel:SetHidden(true)
				WizardsWardrobeModifyDialogConditionTrashCombo:SetHidden(true)
			end
		end
		local function OnTrashCombo(selection)
			newTrash = selection
		end
		
		WizardsWardrobeModifyDialogConditionBossCombo:SetHidden(false)
		WizardsWardrobeModifyDialogConditionBossEdit:SetHidden(true)
		
		local bossCombo = WizardsWardrobeModifyDialogConditionBossCombo.m_comboBox
		bossCombo:SetSortsItems(false)
		bossCombo:ClearItems()
		bossCombo:AddItem(ZO_ComboBox:CreateItemEntry(GetString(WW_CONDITION_NONE), function() OnBossCombo(WW.CONDITIONS.NONE) end))
		local bossId = zone.lookupBosses[condition.boss]
		local selectedBoss = bossId and (zone.bosses[bossId].displayName or zone.bosses[bossId].name) or GetString(WW_CONDITION_NONE)
		bossCombo:SetSelectedItemText(selectedBoss)
		OnBossCombo(condition.boss or WW.CONDITIONS.NONE)
		
		local trashCombo = WizardsWardrobeModifyDialogConditionTrashCombo.m_comboBox
		trashCombo:SetSortsItems(false)
		trashCombo:ClearItems()
		trashCombo:AddItem(ZO_ComboBox:CreateItemEntry(GetString(WW_CONDITION_EVERYWHERE), function() OnTrashCombo(WW.CONDITIONS.EVERYWHERE) end))
		local trashId = zone.lookupBosses[condition.trash]
		local selectedTrash = trashId and (zone.bosses[trashId].displayName or zone.bosses[trashId].name) or GetString(WW_CONDITION_EVERYWHERE)
		trashCombo:SetSelectedItemText(selectedTrash)
		OnTrashCombo(condition.trash or WW.CONDITIONS.EVERYWHERE)
		
		for i, boss in ipairs(zone.bosses) do
			bossCombo:AddItem(ZO_ComboBox:CreateItemEntry(boss.displayName or boss.name, function() OnBossCombo(boss.name) end))
			if boss.name ~= GetString(WW_TRASH) then
				trashCombo:AddItem(ZO_ComboBox:CreateItemEntry(boss.displayName or boss.name, function() OnTrashCombo(boss.name) end))
			end
		end
	end
	
	WizardsWardrobeModifyDialogSave:SetHandler("OnClicked", function(self)
		local newName = WizardsWardrobeModifyDialogNameEdit:GetText()
		if #newName == 0 then newName = GetString(WW_UNNAMED) end
		local name = string.format("|cC5C29E%s|r %s", index, newName:upper())
		setupControl.name:SetText(name)
		setup:SetName(newName)
		setup:SetCondition({
			boss = newBoss,
			trash = newTrash,
		})
		setup:ToStorage(zone.tag, pageId, index)
		WW.conditions.LoadConditions()
		WizardsWardrobeModify:SetHidden(true)
	end)
	
	WizardsWardrobeModify:SetHidden(false)
	SCENE_MANAGER:SetInUIMode(true, false)
end

function WWG.SetupArrangeDialog()
	WizardsWardrobeArrange:SetDimensions(GuiRoot:GetWidth() + 8, GuiRoot:GetHeight() + 8)
	WizardsWardrobeArrangeDialogTitle:SetText(GetString(WW_BUTTON_REARRANGE):upper())
	WizardsWardrobeArrangeDialogSave:SetText(GetString(WW_BUTTON_SAVE))
	WizardsWardrobeArrangeDialogSave:SetHandler("OnClicked", function(self)
		local dataList = ZO_ScrollList_GetDataList(WizardsWardrobeArrangeDialogList)
		WWG.RearrangeSetups(dataList, WW.selection.zone, WW.selection.pageId)
	end)
	WizardsWardrobeArrangeDialogHide:SetHandler("OnClicked", function(self)
		WizardsWardrobeArrange:SetHidden(true)
	end)
	WizardsWardrobeArrangeDialogUp:SetHandler("OnClicked", function(self)
		local index = ZO_ScrollList_GetSelectedDataIndex(WizardsWardrobeArrangeDialogList)
		
		if not index or index == 1 then return end
		
		local dataList = ZO_ScrollList_GetDataList(WizardsWardrobeArrangeDialogList)
		
		local current = dataList[index]
		local above = dataList[index - 1]
		
		dataList[index] = above
		dataList[index - 1] = current
		
		ZO_ScrollList_Commit(WizardsWardrobeArrangeDialogList)
		WizardsWardrobeArrangeDialogList:GetNamedChild("ScrollBar"):SetHidden(false)
	end)
	WizardsWardrobeArrangeDialogDown:SetHandler("OnClicked", function(self)
		local index = ZO_ScrollList_GetSelectedDataIndex(WizardsWardrobeArrangeDialogList)
		local dataList = ZO_ScrollList_GetDataList(WizardsWardrobeArrangeDialogList)
		
		if not index or index == #dataList then return end
		
		local current = dataList[index]
		local below = dataList[index + 1]
		
		dataList[index] = below
		dataList[index + 1] = current
		
		ZO_ScrollList_Commit(WizardsWardrobeArrangeDialogList)
		WizardsWardrobeArrangeDialogList:GetNamedChild("ScrollBar"):SetHidden(false)
	end)
	
	local function OnRowSetup(rowControl, data, scrollList)
		rowControl:SetFont("ZoFontGame")
		rowControl:SetMaxLineCount(1)
		rowControl:SetText(data.name)
		rowControl:SetHandler("OnMouseUp", function() ZO_ScrollList_MouseClick(scrollList, rowControl) end)
	end
	
	local function OnSelection(previouslySelectedData, selectedData, reselectingDuringRebuild)
		if not selectedData then return end
	end
	
	ZO_ScrollList_AddDataType(WizardsWardrobeArrangeDialogList, 1, "ZO_SelectableLabel", 30, OnRowSetup, nil, nil, nil)
	ZO_ScrollList_EnableSelection(WizardsWardrobeArrangeDialogList, "ZO_ThinListHighlight", OnSelection)
	ZO_ScrollList_EnableHighlight(WizardsWardrobeArrangeDialogList, "ZO_ThinListHighlight")
	ZO_ScrollList_SetDeselectOnReselect(WizardsWardrobeArrangeDialogList, false)
	table.insert(WWG.dialogList, WizardsWardrobeArrange)
end

function WWG.ShowArrangeDialog(zone, pageId)
	local function GetSetupList()
		local setupList = {}
		for entry in WW.PageIterator(zone, pageId) do
			table.insert(setupList, {
				name = entry.setup.name,
				index = entry.index
			})
		end
		return setupList
	end
	
	local function UpdateScrollList(data)
		local dataCopy = ZO_DeepTableCopy(data)
		local dataList = ZO_ScrollList_GetDataList(WizardsWardrobeArrangeDialogList)
		
		ZO_ClearNumericallyIndexedTable(dataList)
		
		for _, value in ipairs(dataCopy) do
			local entry = ZO_ScrollList_CreateDataEntry(1, value)
			table.insert(dataList, entry)
		end
		
		ZO_ScrollList_Commit(WizardsWardrobeArrangeDialogList)
	end
	
	local data = GetSetupList()
	UpdateScrollList(data)
	
	WizardsWardrobeArrange:SetHidden(false)
	
	WizardsWardrobeArrangeDialogList:GetNamedChild("ScrollBar"):SetHidden(false)
end

function WWG.RearrangeSetups(sortTable, zone, pageId)
	local pageCopy = ZO_DeepTableCopy(WW.setups[zone.tag][pageId])
	for newIndex, entry in ipairs(sortTable) do
		local oldIndex = entry.data.index
		if newIndex ~= oldIndex then
			WW.setups[zone.tag][pageId][newIndex] = pageCopy[oldIndex]
		end
	end
	WW.conditions.LoadConditions()
	WWG.BuildPage(zone, pageId)
	WizardsWardrobeArrange:SetHidden(true)
end