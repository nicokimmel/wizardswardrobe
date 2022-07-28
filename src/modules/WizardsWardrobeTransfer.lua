WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.transfer = {}
local WWT = WW.transfer
local WWG = WW.gui

function WWT.Init()
	WWT.name = WW.name .. "Transfer"
	WWT.CreateTransferDialog()
end

function WWT.Export(zone, pageId, index)
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	
	if setup:IsEmpty() then
		return
	end
	
	local exportTable = {}
	
	exportTable.name = setup:GetName()
	
	-- skills
	exportTable.skills = {}
	for hotbar = 0, 1 do
		exportTable.skills[tostring(hotbar)] = {}
		for slot = 3, 8 do
			local abilityId = setup:GetHotbar(hotbar)[slot]
			exportTable.skills[tostring(hotbar)][tostring(slot)] = abilityId
		end
	end
	
	-- gear
	exportTable.gear = {}
	for _, gearSlot in ipairs(WW.GEARSLOTS) do
		local savedGear = setup:GetGearInSlot(gearSlot)
		if savedGear then
			if gearSlot ~= EQUIP_SLOT_POISON
				and gearSlot ~= EQUIP_SLOT_BACKUP_POISON
				and gearSlot ~= EQUIP_SLOT_COSTUME then
				
				exportTable.gear[tostring(gearSlot)] = {
					GetItemLinkEquipType(savedGear.link), -- equipType
					({GetItemLinkSetInfo(savedGear.link, false)})[6], -- setId
					({GetItemLinkTraitInfo(savedGear.link)})[1], -- traitType
				}
			end
		end
	end
	
	-- cp
	exportTable.cp = {}
	for slotIndex = 1, 12 do
		exportTable.cp[tostring(slotIndex)] = setup:GetCP()[slotIndex]
	end
	
	return json.encode(exportTable)
end

function WWT.Import(jsonText, zone, pageId, index)
	
	if not jsonText or #jsonText == 0 then
		return
	end
	
	local importTable = json.decode(jsonText)
	
	if not importTable then
		return
	end
	
	local setup = Setup:New()
	
	setup:SetName(importTable.name)
	
	-- skills
	local skillTable = {}
	for hotbar = 0, 1 do
		skillTable[hotbar] = {}
		for slot = 3, 8 do
			local abilityId = importTable.skills[tostring(hotbar)][tostring(slot)]
			skillTable[hotbar][slot] = abilityId
		end
	end
	setup:SetSkills(skillTable)
	
	--gear
	local gearTable = {mythic = nil}
	local filter = {}
	local missing = false
	for _, gearSlot in ipairs(WW.GEARSLOTS) do
		local gear = importTable.gear[tostring(gearSlot)]
		if gear and gear[1] > 0 then
			local bag, slot = WWT.SearchItem(gear[1], gear[2], gear[3], filter)
			if bag and slot then
				gearTable[gearSlot] = {
					id = Id64ToString(GetItemUniqueId(bag, slot)),
					link = GetItemLink(bag, slot, LINK_STYLE_DEFAULT),
				}
				if WW.IsMythic(bag, slot) then
					gearTable.mythic = gearSlot
				end
			else
				missing = true
			end
		end
	end
	if missing then WW.Log(GetString(WW_MSG_IMPORTGEARENOENT), WW.LOGTYPES.ERROR) else WW.Log(GetString(WW_MSG_IMPORTSUCCESS)) end
	setup:SetGear(gearTable)
	
	--cp
	local cpTable = {}
	for slotIndex = 1, 12 do
		cpTable[slotIndex] = importTable.cp[tostring(slotIndex)]
	end
	setup:SetCP(cpTable)
	
	setup:ToStorage(zone.tag, pageId, index)
	WW.gui.RefreshSetup(WW.gui.GetSetupControl(index), setup)
end

function WWT.SearchItem(equipType, setId, prefTraitType, filter)
	if not equipType or equipType == 0 then return nil end
	if not setId or setId == 0 then return nil end
	if not prefTraitType or prefTraitType == 0 then return nil end
	local itemList = {}
	
	local bagList = {BAG_WORN, BAG_BACKPACK}
	local bankBag = GetBankingBag()
	if IsBankOpen() and not WW.DISABLEDBAGS[bankBag] then
		table.insert(bagList, bankBag)
		if bankBag == BAG_BANK and IsESOPlusSubscriber() then
			table.insert(bagList, BAG_SUBSCRIBER_BANK)
		end
	end
	
	for _, bag in ipairs(bagList) do
		for slot = 0, GetBagSize(bag) do
			local itemLink = GetItemLink(bag, slot, LINK_STYLE_DEFAULT)
			
			local lookupEquipType = GetItemLinkEquipType(itemLink)
			local lookupSetId = ({GetItemLinkSetInfo(itemLink, false)})[6]
			local lookupTraitType = ({GetItemLinkTraitInfo(itemLink)})[1]

			if lookupEquipType == equipType and lookupSetId == setId then
				-- sort out items that were already found before (e.g. first set ring)
				local lookupUniqueId = Id64ToString(GetItemUniqueId(bag, slot))
				if lookupTraitType == prefTraitType and not filter[lookupUniqueId] then
					filter[lookupUniqueId] = true
					return bag, slot -- right trait, return location
				end
				
				-- wrong trait, add to list
				table.insert(itemList, {
					bag = bag,
					slot = slot,
					trait = lookupTraitType,
				})
			end
		end
	end
	for _, item in ipairs(itemList) do
		local lookupUniqueId = Id64ToString(GetItemUniqueId(item.bag, item.slot))
		if not filter[lookupUniqueId] then
			filter[lookupUniqueId] = true
			return item.bag, item.slot
		end
	end
	return nil
end

function WWT.ShowExportDialog(zone, pageId, index)
	local text = WWT.Export(zone, pageId, index)
	WWG.SetTooltip(WWT.helpButton, TOP, GetString(WW_EXPORT_HELP))
	WWT.title:SetText(GetString(WW_EXPORT):upper())
	WWT.editBox:SetText(tostring(text or ""))
	WWT.importButton:SetHidden(true)
	WWT.dialogWindow:SetHidden(false)
	SCENE_MANAGER:SetInUIMode(true, false)
	WWT.editBox:TakeFocus()
	WWT.editBox:SelectAll()
end

function WWT.ShowImportDialog(zone, pageId, index)
	WWG.SetTooltip(WWT.helpButton, TOP, GetString(WW_IMPORT_HELP))
	WWT.title:SetText(GetString(WW_IMPORT):upper())
	WWT.editBox:Clear()
	WWT.importButton:SetHidden(false)
	WWT.dialogWindow:SetHidden(false)
	SCENE_MANAGER:SetInUIMode(true, false)
	WWT.editBox:TakeFocus()
	WWT.importButton:SetHandler("OnClicked", function(self)
		WWT.dialogWindow:SetHidden(true)
		local text = WWT.editBox:GetText()
		WWT.Import(text, zone, pageId, index)
	end)
end

function WWT.CreateTransferDialog()
	local window = WINDOW_MANAGER:CreateTopLevelWindow("WizardsWardrobeTransfer")
	WWT.dialogWindow = window
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
	
	local helpButton = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Help", dialog, CT_BUTTON)
	WWT.helpButton = helpButton
	helpButton:SetDimensions(25, 25)
	helpButton:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -6 -30, 5)
	helpButton:SetState(BSTATE_NORMAL)
	helpButton:SetNormalTexture("/esoui/art/menubar/menubar_help_up.dds")
	helpButton:SetMouseOverTexture("/esoui/art/menubar/menubar_help_over.dds")
	helpButton:SetPressedTexture("/esoui/art/menubar/menubar_help_up.dds")
	
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
	WWT.title = title
	title:SetAnchor(CENTER, dialog, TOP, 0, 25)
	title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	title:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
	title:SetFont("ZoFontWinH1")
	
	local editBox = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "EditBox", dialog, "ZO_DefaultEditMultiLine")
	WWT.editBox = editBox
	editBox:SetDimensions(320, 350)
	editBox:SetAnchor(CENTER, dialog, CENTER, 0, 0)
	editBox:SetMaxInputChars(1000)
	
	local editBoxBackground = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. editBox:GetName() .. "BG", dialog, "ZO_EditBackdrop")
	editBoxBackground:SetDimensions(editBox:GetWidth() + 10, editBox:GetHeight() + 10)
	editBoxBackground:SetAnchor(CENTER, dialog, CENTER, 0, 0)
	editBoxBackground:SetAlpha(0.9)
	
	local importButton = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "ImportButton", dialog, "ZO_DefaultButton")
	WWT.importButton = importButton
	importButton:SetDimensions(150, 25)
	importButton:SetAnchor(CENTER, dialog, BOTTOM, 0, -30)
	importButton:SetText(GetString(WW_IMPORT))
	importButton:SetClickSound(SOUNDS.DIALOG_ACCEPT)
	WWG.SetTooltip(importButton, "TOP", GetString(WW_IMPORT_TT))
end