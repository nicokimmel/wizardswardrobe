WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.conditions = {}
local WWC = WW.conditions
local WWG = WW.gui

function WWC.Init()
	WWC.name = WW.name .. "Conditions"
	
	WWC.lookupTriggers = {}
	for mode, value in pairs(WW.TRIGGERS) do
		WWC.lookupTriggers[value] = mode
	end
	
	WWC.Reset()
	WWG.CreateConditionDialog()
end

function WWC.LoadSetups(zone, pageId)
	WWC.Reset()
	for entry in WW.PageIterator(zone, pageId) do
		local setup = Setup:FromStorage(zone.tag, pageId, entry.index)
		if setup:HasCondition() then
			--d("Added " .. zone.name .. " " .. tostring(pageId) .. " " .. tostring(index))
			WWC.AddCondition(setup:GetCondition(), zone, pageId, entry.index)
		end
	end
end

function WWC.AddCondition(condition, zone, pageId, index)
	if not WWC.lookup[condition.mode] then WWC.lookup[condition.mode] = {} end
	WWC.lookup[condition.mode][condition.trigger] = {
		zone = zone,
		pageId = pageId,
		index = index,
	}
end

function WWC.CheckBossChange(bossName)
	if WWC.lookup[WW.TRIGGERS.BOSS_CHANGE][bossName] then
		local setup = WWC.lookup[WW.TRIGGERS.BOSS_CHANGE][bossName]
		WW.LoadSetup(setup.zone, setup.pageId, setup.index, true)
	end
	
	if WWC.lookup[WW.TRIGGERS.TRASH_AFTER_BOSS][bossName] then
		WWC.cache.trash = WWC.lookup[WW.TRIGGERS.TRASH_AFTER_BOSS][bossName]
		--d("Woop! Boss detected. Lets change Trash setups.")
	end
end

function WWC.CheckTrashChange(zone, index)
	local ult, _, _ = GetUnitPower("player", POWERTYPE_ULTIMATE)
	if WWC.lookup[WW.TRIGGERS.TRASH_IF_ULT][ult] then
		local setup = WWC.lookup[WW.TRIGGERS.TRASH_IF_ULT][ult]
		WW.LoadSetup(setup.zone, setup.pageId, setup.index, true)
	end
	
	if WWC.cache.trash and index == 1 and not WW.IsCustomSetup(zone, index) then
		--d("Custom trash setup detected. Equip this one.")
		local setup = WWC.cache.trash
		WW.LoadSetup(setup.zone, setup.pageId, setup.index, true)
		return true
	end
	return false
end

function WWC.Reset()
	WWC.lookup = {
		[WW.TRIGGERS.BOSS_CHANGE] = {},
		[WW.TRIGGERS.TRASH_AFTER_BOSS] = {},
		[WW.TRIGGERS.TRASH_IF_ULT] = {},
	}
	WWC.cache = {
		trash = nil,
	}
end

function WWG.ShowConditionDialog(setup, index)
	PlaySound(SOUNDS.DIALOG_SHOW)
	local conditionStruct = setup:GetCondition()
	if not conditionStruct then
		conditionStruct = {mode = nil, trigger = nil}
	end
	WWC.triggerSelection.m_comboBox:SelectItemByIndex((conditionStruct.mode or WW.TRIGGERS.NONE), true)
	WWC.conditionEditBox:SetText(conditionStruct.trigger or "")
	WWC.dialogWindow:SetHidden(false)
	SCENE_MANAGER:SetInUIMode(true, false)
	WWC.saveButton:SetHandler("OnClicked", function(self)
		WWC.dialogWindow:SetHidden(true)
		local conditionStruct = {
			mode = WW.TRIGGERS[WWC.triggerSelection.m_comboBox:GetSelectedItem()] or WW.TRIGGERS.NONE,
			trigger = WWC.conditionEditBox:GetText(),
		}
		setup:SetCondition(conditionStruct)
		setup:ToStorage(WW.selection.zone.tag, WW.selection.pageId, index)
		WWC.LoadSetups(WW.selection.zone, WW.selection.pageId)
		WW.Log(GetString(WW_MSG_CONDITIONSAVED))
	end)
end

function WWG.CreateConditionDialog()
	local window = WINDOW_MANAGER:CreateTopLevelWindow("WizardsWardrobeCondition")
	WWC.dialogWindow = window
	window:SetDimensions(GuiRoot:GetWidth() + 8, GuiRoot:GetHeight() + 8)
	window:SetAnchor(CENTER, GUI_ROOT, CENTER, 0, 0)
	window:SetDrawTier(DT_HIGH)
	window:SetClampedToScreen(false)
	window:SetMouseEnabled(true)
	window:SetMovable(false)
	window:SetHidden(true)
	
	local fullscreenBackground = WINDOW_MANAGER:CreateControlFromVirtual(window:GetName() .. "BG", window, "ZO_DefaultBackdrop")
	fullscreenBackground:SetAlpha(0.7)
	
	local dialog = WINDOW_MANAGER:CreateControl(window:GetName() .. "Dialog", window, CT_CONTROL)
	dialog:SetDimensions(350, 500)
	dialog:SetAnchor(CENTER, window, CENTER, 0, 0)
	dialog:SetMouseEnabled(true)
	
	local dialogBackground = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "BG", dialog, "ZO_DefaultBackdrop")
	dialogBackground:SetAlpha(0.95)
	
	local hideButton = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Hide", dialog, CT_BUTTON)
	hideButton:SetDimensions(25, 25)
	hideButton:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -6, 6)
	hideButton:SetState(BSTATE_NORMAL)
	hideButton:SetClickSound(SOUNDS.DIALOG_HIDE)
	hideButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
	hideButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
	hideButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
	hideButton:SetHandler("OnClicked", function(self) window:SetHidden(true) end)
	
	local title = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Title", dialog, CT_LABEL)
	title:SetAnchor(CENTER, dialog, TOP, 0, 25)
	title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	title:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
	title:SetFont("ZoFontWinH1")
	title:SetText(GetString(WW_CONDITIONS):upper())
	
	local triggerLabel = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "TriggerLabel", dialog, CT_LABEL)
	triggerLabel:SetAnchor(TOPLEFT, dialog, TOPLEFT, 20, 80)
	triggerLabel:SetFont("ZoFontGame")
	triggerLabel:SetText(GetString(WW_TRIGGER))
	
	local triggerSelection = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "TriggerSelection", dialog, "ZO_ComboBox")
	WWC.triggerSelection = triggerSelection
	triggerSelection:SetHeight(30)
	triggerSelection:SetWidth(200)
	triggerSelection:SetAnchor(TOPLEFT, dialog, TOPLEFT, 120, 80)
	local comboBox = triggerSelection.m_comboBox
	comboBox:SetSortsItems(false)
	for i = 1, #WWC.lookupTriggers do
		comboBox:AddItem(ZO_ComboBox:CreateItemEntry(WWC.lookupTriggers[i], function()
			-- TODO: Change UI if needed
			-- d(value)
		end))
	end
	
	local conditionLabel = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "ConditionLabel", dialog, CT_LABEL)
	conditionLabel:SetAnchor(TOPLEFT, dialog, TOPLEFT, 20, 124)
	conditionLabel:SetFont("ZoFontGame")
	conditionLabel:SetText(GetString(WW_CONDITION))
	
	local editBackground = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "ConditionEditBoxBG", dialog, "ZO_SingleLineEditBackdrop_Keyboard")
	editBackground:SetHeight(30)
	editBackground:SetWidth(198)
	editBackground:SetAnchor(TOPLEFT, dialog, TOPLEFT, 120, 120)
	
	local conditionEditBox = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "ConditionEditBox", editBackground, "ZO_DefaultEditForBackdrop")
	WWC.conditionEditBox = conditionEditBox
	conditionEditBox:SetHeight(30)
	conditionEditBox:SetWidth(198)
	conditionEditBox:SetAnchor(TOPLEFT, editBackground, TOPLEFT, 3, 3)
	WWG.SetTooltip(conditionEditBox, TOP, GetString(WW_CONDITION_TT))
	
	local saveButton = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "SaveButton", dialog, "ZO_DefaultButton")
	WWC.saveButton = saveButton
	saveButton:SetDimensions(150, 25)
	saveButton:SetAnchor(CENTER, dialog, BOTTOM, 0, -30)
	saveButton:SetText(GetString(WW_BUTTON_SAVE))
	saveButton:SetClickSound(SOUNDS.DIALOG_ACCEPT)
end