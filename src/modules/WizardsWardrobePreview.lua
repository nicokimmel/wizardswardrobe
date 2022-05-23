WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.preview = {}
local WWP = WW.preview

function WWP.Init()
	WWP.name = WW.name .. "Preview"
	WWP.CreatePreviewWindow()
	
	LibChatMessage:RegisterCustomChatLink(WW.LINK_TYPES.PREVIEW, function(linkStyle, linkType, data, displayText)
		return ZO_LinkHandler_CreateLinkWithoutBrackets(displayText, nil, WW.LINK_TYPES.PREVIEW, data)
	end)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, WWP.HandleClickEvent)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, WWP.HandleClickEvent)
	
	WWP.chatCache = {}
	EVENT_MANAGER:RegisterForEvent(WWP.name, EVENT_CHAT_MESSAGE_CHANNEL, WWP.OnChatMessage)
end

function WWP.CreatePreviewWindow()
	local window = WINDOW_MANAGER:CreateTopLevelWindow(WWP.name)
	WWP.window = window
	window:SetDimensions(GuiRoot:GetWidth() + 8, GuiRoot:GetHeight() + 8)
	window:SetAnchor(CENTER, GUI_ROOT, CENTER, 0, 0)
	window:SetDrawTier(DT_HIGH)
	window:SetClampedToScreen(false)
	window:SetMouseEnabled(true)
	window:SetMovable(false)
	window:SetHidden(true)
	
	table.insert(WW.gui.dialogList, window)
	
	local fullscreenBackground = WINDOW_MANAGER:CreateControlFromVirtual(window:GetName() .. "BG", window, "ZO_DefaultBackdrop")
	fullscreenBackground:SetAlpha(0.6)
	
	local preview = WINDOW_MANAGER:CreateControl(window:GetName() .. "Preview", window, CT_CONTROL)
	WWP.preview = preview
	preview:SetDimensions(800, 730)
	preview:SetAnchor(CENTER, window, CENTER, 0, 0)
	preview:SetMouseEnabled(true)
	
	local previewBackground = WINDOW_MANAGER:CreateControlFromVirtual(preview:GetName() .. "BG", preview, "ZO_DefaultBackdrop")
	previewBackground:SetAlpha(0.95)
		
	local hideButton = WINDOW_MANAGER:CreateControl(preview:GetName() .. "Hide", preview, CT_BUTTON)
	hideButton:SetDimensions(25, 25)
	hideButton:SetAnchor(TOPRIGHT, preview, TOPRIGHT, -4, 4)
	hideButton:SetState(BSTATE_NORMAL)
	hideButton:SetClickSound(SOUNDS.DIALOG_HIDE)
	hideButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
	hideButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
	hideButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
	hideButton:SetHandler("OnClicked", function(self) window:SetHidden(true) end)
	
	local setupName = WINDOW_MANAGER:CreateControl(preview:GetName() .. "SetupName", preview, CT_LABEL)
	WWP.setupName = setupName
	setupName:SetAnchor(TOPLEFT, preview, TOPLEFT, 10, 5)
	setupName:SetFont("ZoFontWinH1")
	
	local zoneName = WINDOW_MANAGER:CreateControl(preview:GetName() .. "ZoneName", preview, CT_LABEL)
	WWP.zoneName = zoneName
	zoneName:SetAnchor(LEFT, setupName, RIGHT, 6, -4)
	zoneName:SetFont("ZoFontWinH2")
	zoneName:SetVerticalAlignment(TEXT_ALIGN_TOP)
	
	-- GEAR
	WWP.gear = {}
	local gearBox = WINDOW_MANAGER:CreateControl(window:GetName() .. "Gear", preview, CT_CONTROL)
	gearBox:SetDimensions(500, 665)
	gearBox:SetAnchor(TOPLEFT, preview, TOPLEFT, 10, 50)
	local gearBoxBG = WINDOW_MANAGER:CreateControl(gearBox:GetName() .. "BG", gearBox, CT_BACKDROP)
	gearBoxBG:SetCenterColor(1, 1, 1, 0)
	gearBoxBG:SetEdgeColor(1, 1, 1, 1)
	gearBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
	gearBoxBG:SetAnchorFill(gearBox)
	for gearIndex, gearSlot in ipairs(WW.GEARSLOTS) do
		WWP.gear[gearIndex] = {}
		
		local gearIcon = WINDOW_MANAGER:CreateControl(gearBox:GetName() .. "Icon" .. gearIndex, gearBox, CT_TEXTURE)
		WWP.gear[gearIndex].icon = gearIcon
		gearIcon:SetDimensions(36, 36)
		gearIcon:SetAnchor(TOPLEFT, gearBox, TOPLEFT, 10, 10 + (38 * (gearIndex-1)))
		gearIcon:SetTexture(WW.GEARICONS[gearSlot])
		gearIcon:SetMouseEnabled(true)
		gearIcon:SetDrawLevel(2)
		
		local gearFrame = WINDOW_MANAGER:CreateControl(gearBox:GetName() .. "Frame" .. gearIndex, gearBox, CT_TEXTURE)
		gearFrame:SetDimensions(36, 36)
		gearFrame:SetAnchor(CENTER, gearIcon, CENTER, 0, 0)
		gearFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
		gearFrame:SetDrawLevel(3)
		
		local gearLabel = WINDOW_MANAGER:CreateControl(gearBox:GetName() .. "Name" .. gearIndex, gearBox, CT_LABEL)
		WWP.gear[gearIndex].label = gearLabel
		gearLabel:SetAnchor(LEFT, gearIcon, RIGHT, 5, 0)
		gearLabel:SetDimensionConstraints(AUTO_SIZE, AUTO_SIZE, 439, 42)
		gearLabel:SetFont("ZoFontGame")
		gearLabel:SetMouseEnabled(true)
	end
	
	-- SKILLS
	WWP.skills = {[0] = {},	[1] = {}}
	local skillBox = WINDOW_MANAGER:CreateControl(window:GetName() .. "Skills", preview, CT_CONTROL)
	skillBox:SetDimensions(270, 102)
	skillBox:SetAnchor(TOPLEFT, preview, TOPLEFT, 520, 50)
	local skillBoxBG = WINDOW_MANAGER:CreateControl(skillBox:GetName() .. "BG", skillBox, CT_BACKDROP)
	skillBoxBG:SetCenterColor(1, 1, 1, 0)
	skillBoxBG:SetEdgeColor(1, 1, 1, 1)
	skillBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
	skillBoxBG:SetAnchorFill(skillBox)
	for hotbarIndex = 0, 1 do
		for skillIndex = 0, 5 do
			local skillIcon = WINDOW_MANAGER:CreateControl(skillBox:GetName() .. "Icon" .. hotbarIndex .. skillIndex, skillBox, CT_TEXTURE)
			WWP.skills[hotbarIndex][skillIndex+3] = skillIcon
			skillIcon:SetDimensions(40, 40)
			skillIcon:SetAnchor(TOPLEFT, skillBox, TOPLEFT, 10 + (42 * skillIndex), 10 + (42 * hotbarIndex))
			skillIcon:SetTexture("/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds")
			skillIcon:SetMouseEnabled(true)
			skillIcon:SetDrawLevel(2)
			
			local skillFrame = WINDOW_MANAGER:CreateControl(skillBox:GetName() .. "Frame" .. hotbarIndex .. skillIndex, skillBox, CT_TEXTURE)
			skillFrame:SetDimensions(40, 40)
			skillFrame:SetAnchor(CENTER, skillIcon, CENTER, 0, 0)
			skillFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
			skillFrame:SetDrawLevel(3)
		end
	end
	
	-- FOOD
	local foodBox = WINDOW_MANAGER:CreateControl(window:GetName() .. "Food", preview, CT_CONTROL)
	foodBox:SetDimensions(270, 60)
	foodBox:SetAnchor(TOPLEFT, preview, TOPLEFT, 520, 50 + 102 + 10)
	local foodBoxBG = WINDOW_MANAGER:CreateControl(foodBox:GetName() .. "BG", foodBox, CT_BACKDROP)
	foodBoxBG:SetCenterColor(1, 1, 1, 0)
	foodBoxBG:SetEdgeColor(1, 1, 1, 1)
	foodBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
	foodBoxBG:SetAnchorFill(foodBox)
	
	local foodIcon = WINDOW_MANAGER:CreateControl(foodBox:GetName() .. "Icon", foodBox, CT_TEXTURE)
	WWP.foodIcon = foodIcon
	foodIcon:SetDimensions(40, 40)
	foodIcon:SetAnchor(TOPLEFT, foodBox, TOPLEFT, 10, 10)
	foodIcon:SetTexture("/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds")
	foodIcon:SetMouseEnabled(true)
	foodIcon:SetDrawLevel(2)
	
	local foodFrame = WINDOW_MANAGER:CreateControl(foodBox:GetName() .. "Frame", foodBox, CT_TEXTURE)
	foodFrame:SetDimensions(40, 40)
	foodFrame:SetAnchor(CENTER, foodIcon, CENTER, 0, 0)
	foodFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
	foodFrame:SetDrawLevel(3)
	
	local foodLabel = WINDOW_MANAGER:CreateControl(foodBox:GetName() .. "Label", foodBox, CT_LABEL)
	WWP.foodLabel = foodLabel
	foodLabel:SetAnchor(LEFT, foodIcon, RIGHT, 5, 0)
	foodLabel:SetDimensionConstraints(AUTO_SIZE, AUTO_SIZE, 205, 42)
	foodLabel:SetFont("ZoFontGame")
	
	-- CP
	WWP.cp = {}
	local cpBox = WINDOW_MANAGER:CreateControl(window:GetName() .. "CP", preview, CT_CONTROL)
	cpBox:SetDimensions(270, 348)
	cpBox:SetAnchor(TOPLEFT, preview, TOPLEFT, 520, 50 + 102 + 10 + 60 + 10)
	local cpBoxBG = WINDOW_MANAGER:CreateControl(cpBox:GetName() .. "BG", cpBox, CT_BACKDROP)
	cpBoxBG:SetCenterColor(1, 1, 1, 0)
	cpBoxBG:SetEdgeColor(1, 1, 1, 1)
	cpBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
	cpBoxBG:SetAnchorFill(cpBox)
	for cpIndex = 1, 12 do
		local cpIcon = WINDOW_MANAGER:CreateControl(cpBox:GetName() .. "Icon" .. cpIndex, cpBox, CT_TEXTURE)
		cpIcon:SetDimensions(20, 20)
		cpIcon:SetAnchor(TOPLEFT, cpBox, TOPLEFT, 10, 10 + (28 * (cpIndex-1)))
		cpIcon:SetTexture(WW.CPICONS[cpIndex])
		cpIcon:SetDrawLevel(2)
		
		local cpFrame = WINDOW_MANAGER:CreateControl(cpBox:GetName() .. "Frame" .. cpIndex, cpBox, CT_TEXTURE)
		cpFrame:SetDimensions(26, 26)
		cpFrame:SetAnchor(CENTER, cpIcon, CENTER, 0, 0)
		cpFrame:SetTexture("/esoui/art/champion/actionbar/champion_bar_slot_frame.dds")
		cpFrame:SetDrawLevel(3)
		
		local cpLabel = WINDOW_MANAGER:CreateControl(cpBox:GetName() .. "Label" .. cpIndex, cpBox, CT_LABEL)
		WWP.cp[cpIndex] = cpLabel
		cpLabel:SetAnchor(LEFT, cpIcon, RIGHT, 5, 0)
		cpLabel:SetFont("ZoFontGame")
		cpLabel:SetText("CP" .. cpIndex)
	end
	
	-- ICON
	local iconBox = WINDOW_MANAGER:CreateControl(window:GetName() .. "Icon", preview, CT_CONTROL)
	iconBox:SetDimensions(270, 124)
	iconBox:SetAnchor(TOPLEFT, preview, TOPLEFT, 520, 50 + 102 + 10 + 60 + 10 + 346 + 10 + 2)
	local iconBoxBG = WINDOW_MANAGER:CreateControl(iconBox:GetName() .. "BG", iconBox, CT_BACKDROP)
	iconBoxBG:SetCenterColor(1, 1, 1, 0)
	iconBoxBG:SetEdgeColor(1, 1, 1, 1)
	iconBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
	iconBoxBG:SetAnchorFill(iconBox)
	local icon = WINDOW_MANAGER:CreateControl(iconBox:GetName() .. "Icon", iconBox, CT_TEXTURE)
	icon:SetTexture("/WizardsWardrobe/assets/icon128.dds")
	icon:SetDimensions(80, 80)
	icon:SetAnchor(CENTER, iconBox, CENTER, 0, 0)
end

function WWP.ShowPreviewFromSetup(setup, zoneName)
	-- TITLE
	WWP.setupName:SetText(setup:GetName():upper())
	WWP.zoneName:SetText(zoneName:upper())
	
	-- GEAR
	for i, gearSlot in ipairs(WW.GEARSLOTS) do
		local gear = setup:GetGear()[gearSlot]
		if gear and gear.link and #gear.link > 0 then
			local itemName = gear.link
			if gearSlot == EQUIP_SLOT_COSTUME and gear.creator then
				itemName = string.format("%s |c808080(%s)|r", gear.link, gear.creator)
			elseif gearSlot ~= EQUIP_SLOT_POISON and gearSlot ~= EQUIP_SLOT_BACKUP_POISON then
				itemName = string.format("%s |c808080(%s)|r", gear.link, GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(gear.link)))
			end
			
			local function onHover()
				InitializeTooltip(ItemTooltip, WWP.preview, RIGHT, -12, 0, LEFT)
				ItemTooltip:SetLink(gear.link)
			end
			local function OnExit()
				ClearTooltip(ItemTooltip)
			end
			
			local itemLabel = WWP.gear[i].label
			itemLabel:SetText(itemName)
			itemLabel:SetHandler("OnMouseEnter", onHover)
			itemLabel:SetHandler("OnMouseExit", OnExit)
			
			local itemIcon = WWP.gear[i].icon
			itemIcon:SetTexture(GetItemLinkIcon(gear.link))
			itemIcon:SetHandler("OnMouseEnter", onHover)
			itemIcon:SetHandler("OnMouseExit", OnExit)
		else
			local itemLabel = WWP.gear[i].label
			itemLabel:SetText("-/-")
			itemLabel:SetHandler("OnMouseEnter", function() end)
			itemLabel:SetHandler("OnMouseExit", function() end)
				
			local itemIcon = WWP.gear[i].icon
			itemIcon:SetTexture(WW.GEARICONS[gearSlot])
			itemIcon:SetHandler("OnMouseEnter", function() end)
			itemIcon:SetHandler("OnMouseExit", function() end)
		end
	end
	
	-- FOOD
	local food = setup:GetFood()
	if food and food.link and #food.link > 0 then
		WWP.foodLabel:SetText(food.link)
		
		local foodIcon = WWP.foodIcon
		foodIcon:SetTexture(GetItemLinkIcon(food.link))
		foodIcon:SetHandler("OnMouseEnter", function()
			InitializeTooltip(ItemTooltip, WWP.preview, LEFT, 12, 0, RIGHT)
			ItemTooltip:SetLink(food.link)
		end)
		foodIcon:SetHandler("OnMouseExit", function()
			ClearTooltip(ItemTooltip)
		end)
	else
		WWP.foodLabel:SetText("-/-")
		
		local foodIcon = WWP.foodIcon
		foodIcon:SetTexture("/esoui/art/crafting/provisioner_indexicon_meat_disabled.dds")
		foodIcon:SetHandler("OnMouseEnter", function() end)
		foodIcon:SetHandler("OnMouseExit", function() end)
	end
	
	-- CP
	for cpIndex = 1, 12 do
		WWP.cp[cpIndex]:SetText("-/-")
		local cpId = setup:GetCP()[cpIndex]
		if cpId then
			local cpName = zo_strformat("<<C:1>>", GetChampionSkillName(cpId))
			if #cpName > 0 then
				local text = string.format("|c%s%s|r", WW.CPCOLOR[cpIndex], cpName)
				WWP.cp[cpIndex]:SetText(text)
			end
		end
	end
	
	-- SKILLS
	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local abilityId = setup:GetHotbar(hotbarCategory)[slotIndex]
			local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
			if abilityId and abilityId > 0 then
				abilityIcon = GetAbilityIcon(abilityId)
			end
			local skillControl = WWP.skills[hotbarCategory][slotIndex]
			skillControl:SetTexture(abilityIcon)
			if abilityId and abilityId > 0 then
				skillControl:SetHandler("OnMouseEnter", function()
					InitializeTooltip(AbilityTooltip, WWP.preview, LEFT, 12, 0, RIGHT)
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
	
	WWP.window:SetHidden(false)
end

function WWP.ShowPreviewFromString(dataString, setupName)
	local ptr = 1
		
	-- GEAR
	for i, gearSlot in ipairs(WW.GEARSLOTS) do
		if gearSlot ~= EQUIP_SLOT_COSTUME then
			local itemId = dataString:sub(ptr, ptr + 5)
			ptr = ptr + 6
			
			local traitId = 0
			if gearSlot ~= EQUIP_SLOT_POISON
				and gearSlot ~= EQUIP_SLOT_BACKUP_POISON then
				
				traitId = WW.PREVIEWTABLE.TRAITS[dataString:sub(ptr, ptr)]
				ptr = ptr + 1
			end
			
			if tonumber(itemId) > 0 then
				local itemLink = string.format("|H0:item:%d:%d:%d:%d:%d:%d:%d:0:0:0:0:0:0:0:0:%d:%d:%d:%d:%d:%d|h|h", itemId, 30, 50, 26580, 0, 0, traitId, 00, 0, 1, 0, 10000, 0)
				
				local itemName = itemLink
				if tostring(traitId) ~= "0" then
					itemName = string.format("%s |c808080(%s)|r", itemLink, GetString("SI_ITEMTRAITTYPE", traitId))
				end
				
				local function onHover()
					InitializeTooltip(ItemTooltip, WWP.preview, RIGHT, -12, 0, LEFT)
					ItemTooltip:SetLink(itemLink)
				end
				local function OnExit()
					ClearTooltip(ItemTooltip)
				end
				
				local itemLabel = WWP.gear[i].label
				itemLabel:SetText(itemName)
				itemLabel:SetHandler("OnMouseEnter", onHover)
				itemLabel:SetHandler("OnMouseExit", OnExit)
				
				local itemIcon = WWP.gear[i].icon
				itemIcon:SetTexture(GetItemLinkIcon(itemLink))
				itemIcon:SetHandler("OnMouseEnter", onHover)
				itemIcon:SetHandler("OnMouseExit", OnExit)
			else
				local itemLabel = WWP.gear[i].label
				itemLabel:SetText("-/-")
				itemLabel:SetHandler("OnMouseEnter", function() end)
				itemLabel:SetHandler("OnMouseExit", function() end)
				
				local itemIcon = WWP.gear[i].icon
				itemIcon:SetTexture(WW.GEARICONS[gearSlot])
				itemIcon:SetHandler("OnMouseEnter", function() end)
				itemIcon:SetHandler("OnMouseExit", function() end)
			end
		else
			local itemLabel = WWP.gear[i].label
			itemLabel:SetText("-/-")
			itemLabel:SetHandler("OnMouseEnter", function() end)
			itemLabel:SetHandler("OnMouseExit", function() end)
			
			local itemIcon = WWP.gear[i].icon
			itemIcon:SetTexture(WW.GEARICONS[gearSlot])
			itemIcon:SetHandler("OnMouseEnter", function() end)
			itemIcon:SetHandler("OnMouseExit", function() end)
		end
	end
	
	-- SKILLS
	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local abilityId = dataString:sub(ptr, ptr + 5)
			ptr = ptr + 6
			
			local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
			if tonumber(abilityId) > 0 then
				abilityIcon = GetAbilityIcon(abilityId)
			end
			local skillControl = WWP.skills[hotbarCategory][slotIndex]
			skillControl:SetTexture(abilityIcon)
			if tonumber(abilityId) > 0 then
				skillControl:SetHandler("OnMouseEnter", function()
					InitializeTooltip(AbilityTooltip, WWP.preview, LEFT, 12, 0, RIGHT)
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
	
	-- CP
	for cpIndex = 1, 12 do
		local cpId = dataString:sub(ptr, ptr + 2)
		ptr = ptr + 3
		
		WWP.cp[cpIndex]:SetText("-/-")
		if tonumber(cpId) > 0 then
			local cpName = zo_strformat("<<C:1>>", GetChampionSkillName(cpId))
			if #cpName > 0 then
				local text = string.format("|c%s%s|r", WW.CPCOLOR[cpIndex], cpName)
				WWP.cp[cpIndex]:SetText(text)
			end
		end
	end
	
	-- FOOD
	local foodId = WW.PREVIEWTABLE.FOOD[dataString:sub(ptr, ptr)]
	ptr = ptr + 1
	if tonumber(foodId) > 0 then
		local itemLink = string.format("|H0:item:%d:%d:%d:%d:%d:%d:0:0:0:0:0:0:0:0:0:%d:%d:%d:%d:%d:%d|h|h", foodId, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		WWP.foodLabel:SetText(itemLink)
		
		local foodIcon = WWP.foodIcon
		foodIcon:SetTexture(GetItemLinkIcon(itemLink))
		foodIcon:SetHandler("OnMouseEnter", function()
			InitializeTooltip(ItemTooltip, WWP.preview, LEFT, 12, 0, RIGHT)
			ItemTooltip:SetLink(itemLink)
		end)
		foodIcon:SetHandler("OnMouseExit", function()
			ClearTooltip(ItemTooltip)
		end)
	else
		WWP.foodLabel:SetText("-/-")
		
		local foodIcon = WWP.foodIcon
		foodIcon:SetTexture("/esoui/art/crafting/provisioner_indexicon_meat_disabled.dds")
		foodIcon:SetHandler("OnMouseEnter", function() end)
		foodIcon:SetHandler("OnMouseExit", function() end)
	end
	
	-- TITLE
	local name = setupName:sub(2, #setupName-1)
	WWP.setupName:SetText(name:upper())
	local sender = WWP.GetSenderFromCache(dataString)
	WWP.zoneName:SetText(sender:upper())
	
	WWP.window:SetHidden(false)
end

function WWP.PrintPreviewString(zone, pageId, index)
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	
	local data = {}
	
	for _, gearSlot in ipairs(WW.GEARSLOTS) do
		if gearSlot ~= EQUIP_SLOT_COSTUME then
			local gear = setup:GetGearInSlot(gearSlot) or {id = "0", link = ""}
			
			local link = gear.link
			local itemId = GetItemLinkItemId(link)
			table.insert(data, string.format("%06d", itemId))
			
			if gearSlot ~= EQUIP_SLOT_POISON
				and gearSlot ~= EQUIP_SLOT_BACKUP_POISON then
				
				local traitId = GetItemLinkTraitInfo(link)
				table.insert(data, WW.PREVIEWTABLE.TRAITS[traitId])
			end
		end
	end
	
	local skillTable = setup:GetSkills()
	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local abilityId = skillTable[hotbarCategory][slotIndex] or 0
			table.insert(data, string.format("%06d", abilityId))
		end
	end
	
	for slotIndex = 1, 12 do
		local cpId = setup:GetCP()[slotIndex] or 0
		table.insert(data, string.format("%03d", cpId))
	end
	
	table.insert(data, WW.PREVIEWTABLE.FOOD[setup:GetFood().id or 0])
	
	local linkData = table.concat(data, "")
	
	local linkText = setup:GetName()
	if #linkText > 20 then
		linkText = linkText:sub(1, 20)
	end
	
	local previewLink = ZO_LinkHandler_CreateLink(linkText, nil, WW.LINK_TYPES.PREVIEW, linkData)
	CHAT_SYSTEM.textEntry:InsertLink(previewLink)
end

function WWP.OnChatMessage(_, channelType, fromName, text, isCustomerService, fromDisplayName)
	local style, data, name = string.match(text, "||H(%d):" .. WW.LINK_TYPES.PREVIEW .. ":(.-)||h(.-)||h")
	if data and name then
		table.insert(WWP.chatCache, {
			data = data,
			sender = fromDisplayName:sub(2, #fromDisplayName),
		})
		if #WWP.chatCache > 5 then
			table.remove(WWP.chatCache, 1)
		end
	end
end

function WWP.GetSenderFromCache(dataString)
	for _, entry in ipairs(WWP.chatCache) do
		if entry.data == dataString then
			return entry.sender
		end
	end
	return ""
end

function WWP.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, dataString)
	if linkType ~= WW.LINK_TYPES.PREVIEW then return end
	
	if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
		WWP.ShowPreviewFromString(dataString, linkText)
	elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
		ClearMenu()
		AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
			CHAT_SYSTEM.textEntry:InsertLink(rawLink)
		end, MENU_ADD_OPTION_LABEL)
		AddMenuItem(GetString(WW_LINK_IMPORT), function()
			d("soon(tm)")
		end, MENU_ADD_OPTION_LABEL)
		ShowMenu(nil, 2, MENU_TYPE_COMBO_BOX)
	end
	
	return true
end