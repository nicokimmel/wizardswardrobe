WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.code = {}
local WWC = WW.code
local WWG = WW.gui

function WWC.Init()
	WWC.name = WW.name .. "Code"
	WWC.CreateCodeDialog()
end

function WWC.ShowCodeDialog(zone, pageId, index)
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	WWC.editBox:SetText(setup:GetCode())
	WWC.dialogWindow:SetHidden(false)
	SCENE_MANAGER:SetInUIMode(true, false)
	WWC.editBox:TakeFocus()
	WWC.saveButton:SetHandler("OnClicked", function(self)
		WWC.dialogWindow:SetHidden(true)
		local code = tostring(WWC.editBox:GetText())
		setup:SetCode(code)
		setup:ToStorage(zone.tag, pageId, index)
	end)
end

function WWC.CreateCodeDialog()
	local window = WINDOW_MANAGER:CreateTopLevelWindow("WizardsWardrobeCode")
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
	dialog:SetDimensions(600, 500)
	dialog:SetAnchor(CENTER, window, CENTER, 0, 0)
	dialog:SetMouseEnabled(true)
	
	local dialogBackground = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "BG", dialog, "ZO_DefaultBackdrop")
	dialogBackground:SetAlpha(0.95)
	
	local helpButton = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Help", dialog, CT_BUTTON)
	helpButton:SetDimensions(25, 25)
	helpButton:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -6 -30, 5)
	helpButton:SetState(BSTATE_NORMAL)
	helpButton:SetNormalTexture("/esoui/art/menubar/menubar_help_up.dds")
	helpButton:SetMouseOverTexture("/esoui/art/menubar/menubar_help_over.dds")
	helpButton:SetPressedTexture("/esoui/art/menubar/menubar_help_up.dds")
	WWG.SetTooltip(helpButton, TOP, GetString(WW_CUSTOMCODE_HELP))
	
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
	title:SetText(GetString(WW_CUSTOMCODE):upper())
	
	local params = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Parameters", dialog, CT_LABEL)
	params:SetAnchor(TOPLEFT, dialog, TOPLEFT, 10, 55)
	params:SetVerticalAlignment(TEXT_ALIGN_LEFT)
	params:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
	params:SetFont("ZoFontGameSmall")
	params:SetText("Parameters: table setup, table zone, number pageId, number setupId, boolean autoLoaded")
	
	local editBox = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "EditBox", dialog, "ZO_DefaultEditMultiLine")
	WWC.editBox = editBox
	editBox:SetDimensions(570, 350)
	editBox:SetAnchor(CENTER, dialog, CENTER, 0, 10)
	editBox:SetMaxInputChars(1000)
	
	local editBoxBackground = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. editBox:GetName() .. "BG", dialog, "ZO_EditBackdrop")
	editBoxBackground:SetDimensions(editBox:GetWidth() + 10, editBox:GetHeight() + 10)
	editBoxBackground:SetAnchor(CENTER, editBox, CENTER, 0, 0)
	editBoxBackground:SetAlpha(0.9)
	
	local saveButton = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "SaveButton", dialog, "ZO_DefaultButton")
	WWC.saveButton = saveButton
	saveButton:SetDimensions(150, 25)
	saveButton:SetAnchor(CENTER, dialog, BOTTOM, 0, -30)
	saveButton:SetText(GetString(WW_BUTTON_SAVE))
	saveButton:SetClickSound(SOUNDS.DIALOG_ACCEPT)
end