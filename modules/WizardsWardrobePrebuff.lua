WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.prebuff = {}
local WWP = WW.prebuff
local WWQ = WW.queue
local WWG = WW.gui

function WWP.Init()
	WWP.name = WW.name .. "Prebuff"
	WWP.cache = {}
	
	WWP.CreatePrebuffTable()
	WWP.CreatePrebuffWindow()
	
	EVENT_MANAGER:RegisterForEvent(WWP.name, EVENT_ACTION_SLOT_ABILITY_USED, WWP.OnPrebuffed)
	EVENT_MANAGER:RegisterForEvent(WWP.name, EVENT_PLAYER_DEAD, function() WWP.cache = {} end)
end

function WWP.Prebuff(index)
	if IsUnitInCombat("player") then return	end
	
	local skillTable = WWP.GetPrebuffSkills(index)
	
	if #skillTable == 0 then
		return
	end
	
	local isToggle = WW.prebuffs[index][0].toggle
	
	-- restore if the same prebuff button is pressed twice
	if WWP.cache.index == index then
		WWP.RestoreHotbar()
		return
	end
	
	-- prevents multiple prebuffs from overlapping
	if WWP.cache.spells then
		WWP.RestoreHotbar()
	end
	
	local prebuffTask = function()
		WWP.cache = {
			index = index,
			hotbar = GetActiveHotbarCategory(),
			spells = WWP.GetCurrentHotbar(),
			toggle = isToggle,
		}
		
		for _, skill in ipairs(skillTable) do
			WW.SlotSkill(WWP.cache.hotbar, skill.slot, skill.id)
		end
		
		if not isToggle then
			WWP.cache.spell = skillTable[1]
			WWP.cache.delay = WW.prebuffs[index][0].delay
		end
	end
	WWQ.Push(prebuffTask)
end

function WWP.OnPrebuffed(_, slotIndex)
	if not WWP.cache and not WWP.cache.spell then return end
	if WWP.cache.toggle then return end
	if WWP.cache.hotbar ~= GetActiveHotbarCategory() then return end
	if WWP.cache.spell.slot ~= slotIndex then return end
	
	-- skill already gone
	if not WW.AreSkillsEqual(WWP.cache.spell.id, GetSlotBoundId(slotIndex, GetActiveHotbarCategory())) then
		WWP.cache = {}
		return
	end
	
	local weaponDelay = 0
	if ArePlayerWeaponsSheathed() then
		weaponDelay = 1000
	end
	
	zo_callLater(function()
		WWQ.Push(function()
			WWP.RestoreHotbar()
		end)
	end, WWP.cache.delay + weaponDelay + GetLatency())
end

function WWP.RestoreHotbar()
	if not WWP.cache and not WWP.cache.spells then return end
	WWQ.Push(function()
		for slot = 3, 8 do
			local abilityId = WWP.cache.spells[slot]
			WW.SlotSkill(WWP.cache.hotbar, slot, abilityId)
		end
		WWP.cache = {}
	end)
end

function WWP.GetCurrentHotbar()
	local skillTable = {}
	for slot = 3, 8 do
		local hotbarCategory = GetActiveHotbarCategory()
		local abilityId = GetSlotBoundId(slot, hotbarCategory)
		local baseId = WW.GetBaseAbilityId(abilityId)
		skillTable[slot] = baseId
	end
	return skillTable
end

function WWP.GetPrebuffSkills(index)
	local skillTable = {} 
	for slot = 3, 8 do
		local abilityId = WW.prebuffs[index][slot]
		if abilityId and abilityId > 0 then
			table.insert(skillTable, {slot = slot, id = abilityId})
		end
	end
	return skillTable
end

function WWP.CreatePrebuffTable()
	if #WW.prebuffs == 0 then
		for i = 1, 5 do
			WW.prebuffs[i] = {
				[0] = {
					toggle = false,
					delay = 500,
				}
			}
		end
	end
end

function WWP.CreatePrebuffWindow()
	local dialog = WINDOW_MANAGER:CreateTopLevelWindow(WWP.name)
	WWP.dialog = dialog
	dialog:SetDimensions(600, 395)
	dialog:SetAnchor(CENTER, GUI_ROOT, CENTER, 0, 0)
	dialog:SetDrawTier(DT_HIGH)
	dialog:SetClampedToScreen(false)
	dialog:SetMouseEnabled(true)
	dialog:SetMovable(true)
	dialog:SetHidden(true)
	
	SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
		if scene:GetName() ~= "hud" and scene:GetName() ~= "hudui" then return end
		if newState ~= SCENE_SHOWING then return end
		dialog:SetHidden(true)
	end)
	
	local background = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "BG", dialog, "ZO_DefaultBackdrop")
	background:SetAlpha(0.95)
	
	local title = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Title", dialog, CT_LABEL)
	title:SetAnchor(CENTER, dialog, TOP, 0, 25)
	title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	title:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
	title:SetFont("ZoFontWinH1")
	title:SetText("PREBUFF")
	
	local hideButton = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Hide", dialog, CT_BUTTON)
	hideButton:SetDimensions(25, 25)
	hideButton:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -4, 4)
	hideButton:SetState(BSTATE_NORMAL)
	hideButton:SetClickSound(SOUNDS.DIALOG_HIDE)
	hideButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
	hideButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
	hideButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
	hideButton:SetHandler("OnClicked", function(self) dialog:SetHidden(true) end)
	
	local helpButton = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Help", dialog, CT_BUTTON)
	helpButton:SetDimensions(25, 25)
	helpButton:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -6 -30, 3)
	helpButton:SetState(BSTATE_NORMAL)
	helpButton:SetNormalTexture("/esoui/art/menubar/menubar_help_up.dds")
	helpButton:SetMouseOverTexture("/esoui/art/menubar/menubar_help_over.dds")
	helpButton:SetPressedTexture("/esoui/art/menubar/menubar_help_up.dds")
	WWG.SetTooltip(helpButton, TOP, GetString(WW_PREBUFF_HELP))
	
	for i = 1, 5 do
		local prebuffBox = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Box" .. i, dialog, CT_CONTROL)
		prebuffBox:SetDimensions(500, 60)
		prebuffBox:SetAnchor(CENTER, preview, TOP, 0, 65 * i + 20)
		local prebuffBoxBG = WINDOW_MANAGER:CreateControl(prebuffBox:GetName() .. "BG", prebuffBox, CT_BACKDROP)
		prebuffBoxBG:SetCenterColor(1, 1, 1, 0)
		prebuffBoxBG:SetEdgeColor(1, 1, 1, 1)
		prebuffBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
		prebuffBoxBG:SetAnchorFill(prebuffBox)
		
		local prebuffLabel = WINDOW_MANAGER:CreateControl(prebuffBox:GetName() .. "Label", prebuffBox, CT_LABEL)
		prebuffLabel:SetAnchor(CENTER, prebuffBox, LEFT, 25, 0)
		prebuffLabel:SetFont("ZoFontWinH1")
		prebuffLabel:SetText(i)
		
		local editBox = WINDOW_MANAGER:CreateControlFromVirtual(prebuffBox:GetName() .. "EditBox", prebuffBox, "ZO_DefaultEdit")
		editBox:SetDimensions(35, 20)
		editBox:SetAnchor(CENTER, prebuffBox, LEFT, 425, 0)
		editBox:SetTextType(TEXT_TYPE_NUMERIC_UNSIGNED_INT)
		editBox:SetHandler("OnTextChanged", function(self)
			WW.prebuffs[i][0].delay = tonumber(editBox:GetText()) or 0
		end)
		editBox:SetText(WW.prebuffs[i][0].delay)
		
		local editBoxBackground = WINDOW_MANAGER:CreateControlFromVirtual(editBox:GetName() .. "BG", editBox, "ZO_EditBackdrop")
		editBoxBackground:SetDimensions(editBox:GetWidth() + 10, editBox:GetHeight() + 10)
		editBoxBackground:SetAnchor(CENTER, editBox, CENTER, 0, 0)
		
		local editBoxLabel = WINDOW_MANAGER:CreateControl(editBox:GetName() .. "Label", prebuffBox, CT_LABEL)
		editBox.ctlabel = editBoxLabel
		editBoxLabel:SetAnchor(LEFT, editBox, RIGHT, 10, 2)
		editBoxLabel:SetFont("ZoFontGameSmall")
		editBoxLabel:SetText("Delay")
		
		local checkBox = WINDOW_MANAGER:CreateControlFromVirtual(prebuffBox:GetName() .. "CheckBox", prebuffBox, "ZO_CheckButton")
		checkBox:SetAnchor(CENTER, prebuffBox, LEFT, 330, 0)
		checkBox:SetHandler("OnClicked", function(self)
			local state = not ZO_CheckButton_IsChecked(self)
			WW_DefaultEdit_SetEnabled(editBox, not state)
			WW_CheckButton_SetCheckState(checkBox, state)
			WW.prebuffs[i][0].toggle = state
		end)
		
		local checkBoxLabel = WINDOW_MANAGER:CreateControl(checkBox:GetName() .. "Label", prebuffBox, CT_LABEL)
		checkBox.ctlabel = checkBoxLabel
		checkBoxLabel:SetAnchor(LEFT, checkBox, RIGHT, 5, 2)
		checkBoxLabel:SetFont("ZoFontGameSmall")
		checkBoxLabel:SetText("Toggle")		
		
		for slot = 1, 6 do
			local skill = WINDOW_MANAGER:CreateControl(prebuffBox:GetName() .. "Skill" .. slot, prebuffBox, CT_TEXTURE)
			skill:SetDimensions(40, 40)
			skill:SetAnchor(CENTER, prebuffBox, LEFT, 25 + slot * 42, 0)
			skill:SetMouseEnabled(true)
			skill:SetDrawLevel(2)
			local function OnSkillDragStart(self)
				if IsUnitInCombat("player") then return	end -- would fail at protected call anyway
				if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then return end
				
				local abilityId = WW.prebuffs[i][slot+2]
				if not abilityId then return end
				
				local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityId)
				if not progression then return end
				
				local skillType, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(progression:GetAbilityId())
				if CallSecureProtected("PickupAbilityBySkillLine", skillType, skillLine, skillIndex) then
					WW.prebuffs[i][slot+2] = 0
					local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
					skill:SetTexture(abilityIcon)
					
					WWP.CheckToggleCondition(i, checkBox, editBox)
				end
			end
			local function OnSkillDragReceive(self)
				if GetCursorContentType() ~= MOUSE_CONTENT_ACTION then return end
				local abilityId = GetCursorAbilityId()
				
				local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityId)
				if not progression then return end
				
				if progression:IsUltimate() and slot < 6 or
					not progression:IsUltimate() and slot > 5 then
					-- Prevent ult on normal slot and vice versa
					return
				end
				
				if progression:IsChainingAbility() then
					abilityId = GetEffectiveAbilityIdForAbilityOnHotbar(abilityId, hotbar)
				end
				
				ClearCursor()
				
				local previousAbilityId = WW.prebuffs[i][slot+2]
				WW.prebuffs[i][slot+2] = abilityId
				
				local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
				if abilityId and abilityId > 0 then
					abilityIcon = GetAbilityIcon(abilityId)
				end
				skill:SetTexture(abilityIcon)
				
				WWP.CheckToggleCondition(i, checkBox, editBox)
				
				if previousAbilityId and previousAbilityId > 0 then
					local previousProgression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(previousAbilityId)
					if not previousProgression then return end
					local skillType, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(previousProgression:GetAbilityId())
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
			local abilityId = WW.prebuffs[i][slot+2]
			local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
			if abilityId and abilityId > 0 then
				abilityIcon = GetAbilityIcon(abilityId)
			end
			skill:SetTexture(abilityIcon)
			
			local frame = WINDOW_MANAGER:CreateControl(skill:GetName() .. "Frame", skill, CT_TEXTURE)
			frame:SetDimensions(40, 40)
			frame:SetAnchor(CENTER, skill, CENTER, 0, 0)
			frame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
			frame:SetDrawLevel(3)
			
			WWP.CheckToggleCondition(i, checkBox, editBox)
		end
	end
end

function WWP.CheckToggleCondition(index, checkBox, editBox)
	local function Check()
		local i = 0
		for slot = 1, 6 do
			if WW.prebuffs[index][slot+2]
				and WW.prebuffs[index][slot+2] > 0 then
				i = i + 1
			end
			if i > 1 then
				return true
			end
		end
		return false
	end
	
	local state = Check()
	
	WW_CheckButton_SetCheckState(checkBox, WW.prebuffs[index][0].toggle)
	WW_DefaultEdit_SetEnabled(editBox, not WW.prebuffs[index][0].toggle)
	
	-- its always a toggle if there is more then 1 spell
	if state then
		WW_CheckButton_SetCheckState(checkBox, true)
		WW_CheckButton_SetEnableState(checkBox, false)
		WW_DefaultEdit_SetEnabled(editBox, false)
		WW.prebuffs[index][0].toggle = true
	end
end

function WW_DefaultEdit_SetEnabled(editBox, state)
	ZO_DefaultEdit_SetEnabled(editBox, state)
	if editBox.ctlabel then
		local color = state and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT
		editBox.ctlabel:SetColor(color:UnpackRGBA())
	end
end

function WW_CheckButton_SetEnableState(checkBox, state)
	ZO_CheckButton_SetEnableState(checkBox, state)
	if checkBox.ctlabel then
		local color = state and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT
		checkBox.ctlabel:SetColor(color:UnpackRGBA())
	end
end

function WW_CheckButton_SetCheckState(checkBox, state)
	ZO_CheckButton_SetCheckState(checkBox, state)
	if checkBox.ctlabel then
		checkBox.ctlabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
	end
end