WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe
local WWQ = WW.queue

WW.name = "WizardsWardrobe"
WW.simpleName = "Wizard's Wardrobe"
WW.displayName = "|c18bed8W|c26c2d1i|c35c6c9z|c43cac2a|c52cebar|c60d1b3d|c6fd5ab'|c7dd9a4s|c8cdd9d |c9ae195W|ca8e58ea|cb7e986r|cc5ed7fd|cd4f077r|ce2f470o|cf1f868b|cfffc61e|r"
WW.version = "1.9.3"
WW.zones = {}

local cancelAnimation = false
local cpCooldown = 0
local wipeChangeCooldown = false
local bossLastName = "WW"
local blockTrash = nil

function WW.LoadSetup(zone, pageId, index, auto)
	if not zone or not pageId or not index then
		return false
	end
	
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	
	if setup:IsEmpty() then
		if not auto then
			WW.Log(GetString(WW_MSG_EMPTYSETUP), WW.LOGTYPES.INFO)
		end
		return false
	end
	
	if WW.settings.auto.gear then WW.LoadGear(setup) end
	if WW.settings.auto.skills then WW.LoadSkills(setup) end
	if WW.settings.auto.cp then  WW.LoadCP(setup) end
	if WW.settings.auto.food then  WW.EatFood(setup) end
	
	local pageName = WW.pages[zone.tag][pageId].name
	WW.gui.SetPanelText(zone.tag, pageName, setup:GetName())
	
	local logMessage = IsUnitInCombat("player") and GetString(WW_MSG_LOADINFIGHT) or GetString(WW_MSG_LOADSETUP)
	local logColor = IsUnitInCombat("player") and WW.LOGTYPES.INFO or WW.LOGTYPES.NORMAL
	WW.Log(logMessage, logColor, "FFFFFF", setup:GetName(), zone.name)
	
	setup:ExecuteCode(setup, zone, pageId, index, auto)
	
	return true
end

function WW.LoadSetupCurrent(index, auto)
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	WW.LoadSetup(zone, pageId, index, auto)
end

function WW.LoadSetupSubstitute(index)
	if not WW.zones["SUB"] or not WW.pages["SUB"] then return end
	WW.LoadSetup(WW.zones["SUB"], WW.pages["SUB"][0].selected, index, true)
end

function WW.SaveSetup(zone, pageId, index, skip)
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	
	if not skip and not setup:IsEmpty() and WW.settings.overwriteWarning then
		WW.gui.ShowConfirmationDialog("OverwriteConfirmation", string.format(GetString(WW_OVERWRITESETUP_WARNING), setup:GetName()),
		function()
			WW.SaveSetup(zone, pageId, index, true)
		end)
		return
	end
	
	if WW.settings.auto.gear then WW.SaveGear(setup) end
	if WW.settings.auto.skills then WW.SaveSkills(setup) end
	if WW.settings.auto.cp then  WW.SaveCP(setup) end
	if WW.settings.auto.food then  WW.SaveFood(setup) end
	
	setup:ToStorage(zone.tag, pageId, index)
	
	WW.gui.RefreshSetup(WW.gui.GetSetupControl(index), setup)
	
	WW.Log(GetString(WW_MSG_SAVESETUP), WW.LOGTYPES.NORMAL, "FFFFFF", setup:GetName())
end

function WW.DeleteSetup(zone, pageId, index)
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	local setupName = setup:GetName()
	
	if WW.setups[zone.tag]
		and WW.setups[zone.tag][pageId]
		and WW.setups[zone.tag][pageId][index] then
		
		table.remove(WW.setups[zone.tag][pageId], index)
	end
	
	WW.markers.BuildGearList()
	WW.conditions.LoadConditions()
	
	if zone.tag == WW.selection.zone.tag
		and pageId == WW.selection.pageId then
		
		WW.gui.BuildPage(zone, pageId)
	end
	
	WW.Log(GetString(WW_MSG_DELETESETUP), WW.LOGTYPES.NORMAL, "FFFFFF", setupName)
end

function WW.ClearSetup(zone, pageId, index)
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	local setupName = setup:GetName()
	
	setup:Clear()
	setup:SetName(setupName)
	setup:ToStorage(zone.tag, pageId, index)
	
	WW.markers.BuildGearList()
	WW.conditions.LoadConditions()
	
	if zone.tag == WW.selection.zone.tag
		and pageId == WW.selection.pageId then
		
		WW.gui.BuildPage(zone, pageId)
	end
	
	WW.Log(GetString(WW_MSG_DELETESETUP), WW.LOGTYPES.NORMAL, "FFFFFF", setupName)
end

function WW.LoadSkills(setup)
	local skillTask = function()
		local skillTable = setup:GetSkills()
		for hotbarCategory = 0, 1 do
			for slotIndex = 3, 8 do
				local abilityId = skillTable[hotbarCategory][slotIndex]
				if abilityId and abilityId > 0 then
					WW.SlotSkill(hotbarCategory, slotIndex, abilityId)
				else
					if WW.settings.unequipEmpty then
						abilityId = 0
						WW.SlotSkill(hotbarCategory, slotIndex, 0)
					end
				end
			end
		end
	end
	WWQ.Push(skillTask)
	WW.prebuff.cache = {}
end

function WW.SlotSkill(hotbarCategory, slotIndex, abilityId)
	local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarCategory)
	if abilityId and abilityId > 0 then
		local progressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityId)
        if progressionData
			and progressionData:GetSkillData()
			and progressionData:GetSkillData():IsPurchased() then
			
			hotbarData:AssignSkillToSlot(slotIndex, progressionData:GetSkillData())
            return true
		else
			local abilityName = zo_strformat("<<C:1>>", progressionData:GetName())
			WW.Log(GetString(WW_MSG_SKILLENOENT), WW.LOGTYPES.ERROR, "FFFFFF", abilityName)
			return false
        end
	else
		hotbarData:ClearSlot(slotIndex)
		return true
	end
end

function WW.SaveSkills(setup)
	local skillTable = {}
	for hotbarCategory = 0, 1 do
		skillTable[hotbarCategory] = {}
		for slotIndex = 3, 8 do
			local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarCategory)
			local slotData = hotbarData:GetSlotData(slotIndex)
			local abilityId = 0
			if not slotData:IsEmpty() then -- check if there is even a spell
				abilityId = slotData:GetEffectiveAbilityId()
			end
			skillTable[hotbarCategory][slotIndex] = abilityId
		end
	end
	setup:SetSkills(skillTable)
end

function WW.AreSkillsEqual(abilityId1, abilityId2) -- gets base abilityIds first, then compares
	if abilityId1 == abilityId2 then return true end
	
	local baseMorphAbilityId1 = WW.GetBaseAbilityId(previousAbilityId)
	if not baseMorphAbilityId1 then return end
	
	local baseMorphAbilityId2 = WW.GetBaseAbilityId(previousAbilityId)
	if not baseMorphAbilityId2 then return end
	
	if baseMorphAbilityId1 == baseMorphAbilityId2 then
		return true
	end
	return false
end

function WW.GetBaseAbilityId(abilityId)
	if abilityId == 0 then return 0 end
	local playerSkillProgressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityId)
	if not playerSkillProgressionData then
		return nil
	end
	local baseMorphData = playerSkillProgressionData:GetSkillData():GetMorphData(MORPH_SLOT_BASE)
	return baseMorphData:GetAbilityId()
end

function WW.LoadGear(setup)
	if GetNumBagFreeSlots(BAG_BACKPACK) == 0 then
		WW.Log(GetString(WW_MSG_FULLINV), WW.LOGTYPES.INFO)
	end
	
	local itemTaskList = {}
	local inventoryList = WW.GetItemLocation()
	
	-- unequip mythic if needed
	local mythicDelay = 0
	if setup:GetMythic() then
		local mythicSlot = WW.HasMythic()
		local mythicId = Id64ToString(GetItemUniqueId(BAG_WORN, mythicSlot))
		local _, gear = setup:GetMythic()
		if mythicSlot and mythicId ~= gear.id then
			mythicDelay = 500
			table.insert(itemTaskList, {
				sourceBag = BAG_WORN,
				sourceSlot = mythicSlot,
				destBag = BAG_BACKPACK,
				destSlot = nil,
				itemId = mythicId,
			})
		end
	end
	
	for _, gearSlot in ipairs(WW.GEARSLOTS) do
		local gear = setup:GetGearInSlot(gearSlot)
		
		if gear then
			if gearSlot == EQUIP_SLOT_POISON or gearSlot == EQUIP_SLOT_BACKUP_POISON then
				-- handle poisons
				local lookupLink = GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT)
				if lookupLink ~= gear.link then 
					WW.poison.EquipPoisons(gear.link, gearSlot)
				end
			else
				-- equip item (if not already equipped)
				local lookupId = Id64ToString(GetItemUniqueId(BAG_WORN, gearSlot))
				
				if lookupId ~= gear.id then
					if inventoryList[gear.id] then
						local bag, slot = inventoryList[gear.id].bag, inventoryList[gear.id].slot
						
						local delay = WW.IsMythic(bag, slot) and mythicDelay or 0
						local workaround = gearSlot == EQUIP_SLOT_BACKUP_MAIN and slot == EQUIP_SLOT_MAIN_HAND
						if workaround then
							-- Front to back
							-- Be sure to give enough time so backbar can find new location
							delay = delay + 500
						end
						
						table.insert(itemTaskList, {
							sourceBag = bag,
							sourceSlot = slot,
							destBag = BAG_WORN,
							destSlot = gearSlot,
							delay = delay,
							itemId = gear.id,
							workaround = workaround,
						})
					else
						WW.Log(GetString(WW_MSG_GEARENOENT), WW.LOGTYPES.ERROR, nil, WW.ChangeItemLinkStyle(gear.link, LINK_STYLE_BRACKETS))
					end
				end
			end
		else
			-- unequip if option is set to true
			if WW.settings.unequipEmpty then
				table.insert(itemTaskList, {
					sourceBag = BAG_WORN,
					sourceSlot = gearSlot,
					destBag = BAG_BACKPACK,
					destSlot = nil,
				})
			end
		end
	end
	WW.MoveItems(itemTaskList)
end

function WW.GetFreeSlots(bag)
	local freeSlotMap = {}
	for slot in ZO_IterateBagSlots(bag) do
		local itemId = GetItemId(bag, slot)
		if itemId == 0 then
			table.insert(freeSlotMap, slot)
		end
	end
	return freeSlotMap
end

function WW.MoveItems(itemTaskList)
	for _, item in ipairs(itemTaskList) do
		local itemTask = function()
			if not item.destSlot then
				item.destSlot = FindFirstEmptySlotInBag(item.destBag)
			end
			
			if not item.sourceSlot or item.workaround then
				local newLocation = WW.GetItemLocation()[item.itemId]
				if not newLocation then return end
				item.sourceBag = newLocation.bag
				item.sourceSlot = newLocation.slot
			end
			
			if not item.sourceSlot or not item.destSlot then return end
			
			--local itemId = Id64ToString(GetItemUniqueId(item.sourceBag, item.sourceSlot))
			--local itemLink = GetItemLink(item.sourceBag, item.sourceSlot, LINK_STYLE_BRACKETS)
			
			if item.destBag == BAG_WORN then
				EquipItem(item.sourceBag, item.sourceSlot, item.destSlot)
			else
				CallSecureProtected("RequestMoveItem", item.sourceBag, item.sourceSlot, item.destBag, item.destSlot, 1)
			end
		end
		WWQ.Push(itemTask, item.delay)
	end
	WWQ.Push(function()
		INVENTORY_FRAGMENT:FireCallbacks("StateChange", SCENE_FRAGMENT_HIDDEN, SCENE_FRAGMENT_SHOWING)
	end, 500)
end

function WW.HasMythic()
	for _, gearSlot in ipairs(WW.GEARSLOTS) do
		if WW.IsMythic(BAG_WORN, gearSlot) then
			return gearSlot
		end
	end
	return nil
end

function WW.Undress(itemTaskList)
	if GetNumBagFreeSlots(BAG_BACKPACK) == 0 then
		WW.Log(GetString(WW_MSG_FULLINV), WW.LOGTYPES.INFO)
	end
	
	if not itemTaskList or type(itemTaskList) ~= "table" then
		local freeSlotMap = WW.GetFreeSlots(BAG_BACKPACK)
		itemTaskList = {}
		for _, gearSlot in ipairs(WW.GEARSLOTS) do
			local _, stack = GetItemInfo(BAG_WORN, gearSlot)
			if stack > 0 then
				table.insert(itemTaskList, {
					sourceBag = BAG_WORN,
					sourceSlot = gearSlot,
					destBag = BAG_BACKPACK,
					destSlot = table.remove(freeSlotMap),
					f = "m",
				})
			end
		end
	end
	
	WW.MoveItems(itemTaskList)
end

function WW.SaveGear(setup)
	local gearTable = {mythic = nil}
	for _, gearSlot in ipairs(WW.GEARSLOTS) do
		gearTable[gearSlot] = {
			id = Id64ToString(GetItemUniqueId(BAG_WORN, gearSlot)),
			link = GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT),
		}
		if WW.IsMythic(BAG_WORN, gearSlot) then
			gearTable.mythic = gearSlot
		end
		if GetItemLinkItemType(gearTable[gearSlot].link) == ITEMTYPE_TABARD then
			gearTable[gearSlot].creator = GetItemCreatorName(BAG_WORN, gearSlot)
		end
	end
	setup:SetGear(gearTable)
end

function WW.LoadCP(setup)
	if #setup:GetCP() == 0 then
		return
	end
	
	if WW.CompareCP(setup) then
		return
	end
	
	local cpTask = function()
		-- fixes animation call with nil
		if CHAMPION_PERKS_SCENE:GetState() == "shown" then
			CHAMPION_PERKS:PrepareStarConfirmAnimation()
			cancelAnimation = false
		else
			cancelAnimation = true
		end
		PrepareChampionPurchaseRequest()
		for slotIndex = 1, 12 do
			local starId = setup:GetCP()[slotIndex]
			if starId and starId > 0 then
				local skillPoints = GetNumPointsSpentOnChampionSkill(starId)
				if skillPoints > 0 then
					AddHotbarSlotToChampionPurchaseRequest(slotIndex, starId)
				else
					WW.Log(GetString(WW_MSG_CPENOENT), WW.LOGTYPES.ERROR, WW.CPCOLOR[slotIndex], zo_strformat("<<C:1>>", GetChampionSkillName(starId)))
				end
			else
				if WW.settings.unequipEmpty then
					AddHotbarSlotToChampionPurchaseRequest(slotIndex, 0)
				end
			end
		end
		SendChampionPurchaseRequest()
	end
	
	if cpCooldown > 0 then
		zo_callLater(function()
			WWQ.Push(cpTask)
			WW.Log(GetString(WW_MSG_CPCOOLDOWNOVER), WW.LOGTYPES.INFO)
		end, cpCooldown * 1000)
		WW.Log(GetString(WW_MSG_CPCOOLDOWN), WW.LOGTYPES.INFO, nil, tostring(cpCooldown))
		return
	end
	
	WWQ.Push(cpTask)
end

function WW.SaveCP(setup)
	local cpTable = {}
	for slotIndex = 1, 12 do
		cpTable[slotIndex] = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
	end
	setup:SetCP(cpTable)
end

function WW.UpdateCPCooldown()
	if cpCooldown > 0 then
		cpCooldown = cpCooldown - 1
		return
	end
	cpCooldown = 0
	EVENT_MANAGER:UnregisterForUpdate(WW.name .. "CPCooldownLoop")
end

function WW.EatFood(setup)
	local savedFood = setup:GetFood()
	if not savedFood.id then return end
	
	local currentFood = WW.HasFoodRunning()
	if WW.BUFFFOOD[savedFood.id] == currentFood then
		-- same bufffood, dont renew it
		return
	end
	
	local foodChoice = WW.lookupBuffFood[WW.BUFFFOOD[savedFood.id]]
	
	foodTask = function()
		local foodIndex = WW.FindFood(foodChoice)
		if not foodIndex then
			WW.Log(GetString(WW_MSG_FOODENOENT), WW.LOGTYPES.ERROR)
			return
		end
		CallSecureProtected("UseItem", BAG_BACKPACK, foodIndex)
		
		-- check if eaten 
		-- API cannot track sprinting
		zo_callLater(function()
			if not WW.HasFoodIdRunning(savedFood.id) then
				WWQ.Push(foodTask)
			end
		end, 1000)
	end
	WWQ.Push(foodTask)
end

function WW.SaveFood(setup, foodIndex)
	if not foodIndex then
		local currentFood = WW.HasFoodRunning()
		local foodChoice = WW.lookupBuffFood[currentFood]
		foodIndex = WW.FindFood(foodChoice)
		if not foodIndex then
			WW.Log(GetString(WW_MSG_NOFOODRUNNING), WW.LOGTYPES.INFO)
			return
		end
	end
	
	local foodLink = GetItemLink(BAG_BACKPACK, foodIndex, LINK_STYLE_DEFAULT)
	local foodId = GetItemLinkItemId(foodLink)
	
	setup:SetFood({
		link = foodLink,
		id = foodId,
	})
end

function WW.SetupIterator()
	local setupList = {}
	for _, zone in ipairs(WW.gui.GetSortedZoneList()) do
		if WW.setups[zone.tag] then
			for pageId, _ in ipairs(WW.setups[zone.tag]) do
				if WW.setups[zone.tag][pageId] then
					for index, setup in ipairs(WW.setups[zone.tag][pageId]) do
						if setup then
							table.insert(setupList, {zone = zone, pageId = pageId, index = index, setup = setup})
						end
					end
				end
			end
		end
	end
	
	local i = 0
	return function()
		i = i + 1
		return setupList[i]
	end
end

function WW.PageIterator(zone, pageId)
	local setupList = {}
	if WW.setups[zone.tag] and WW.setups[zone.tag][pageId] then
		for index, setup in ipairs(WW.setups[zone.tag][pageId]) do
			if setup then
				table.insert(setupList, {zone = zone, pageId = pageId, index = index, setup = setup})
			end
		end
	end
	
	local i = 0
	return function()
		i = i + 1
		return setupList[i]
	end
end

function WW.OnBossChange(_, isBoss, manualBossName)
	if IsUnitInCombat("player") and not manualBossName then
		return
	end
	
	if WasRaidSuccessful() then
		return
	end
	
	local bossName = GetUnitName("boss1")
	local sideBoss = GetUnitName("boss2")
	
	if manualBossName then
		bossName = manualBossName
	end
	
	if bossName == GetString(WW_TRASH) then
		bossName = ""
	end
	
	if #bossName == 0 and #sideBoss > 0 then
		bossName = sideBoss
	end
	
	if blockTrash and #bossName == 0 then
		--d("Trash is being blocked.")
		return
	end
	
	if #bossName > 0 and not IsUnitInCombat("player") then
		--d("Changed to boss. Block trash for 6s.")
		if blockTrash then
			--d("Boss detected. Remove trash blockade. #" .. bossName)
			zo_removeCallLater(blockTrash)
			blockTrash = nil
		end
		--d("New trash blockade.")
		blockTrash = zo_callLater(function()
			--d("Trash blockade over.")
			blockTrash = nil
			--WW.OnBossChange(_, true, manualBossName)
			WW.OnBossChange(_, true, nil)
		end, 6000)
	end
	
	if bossName == bossLastName then
		return
	end
	
	if wipeChangeCooldown or WW.IsWipe() then
		return
	end
	
	--d("BOSS: " .. bossName)
	
	bossLastName = bossName
	zo_callLater(function()
		WW.currentZone.OnBossChange(bossName)
	end, 500)
end

function WW.OnZoneChange(_, _)
	local isFirstZoneAfterReload = (WW.currentZoneId == 0)
	local zone, x, y, z = GetUnitWorldPosition("player")
	if zone == WW.currentZoneId then
		-- no zone change
		return
	end
	WW.currentZoneId = zone
	
	-- reset old zone
	WW.currentZone.Reset()
	WW.conditions.ResetCache()
	
	if WW.lookupZones[zone] then
		WW.currentZone = WW.lookupZones[zone]
	else
		WW.currentZone = WW.zones["GEN"]
	end
	
	bossLastName = "WW"
	
	zo_callLater(function()
		-- init new zone
		WW.currentZone.Init()
		-- change ui if loaded
		WW.gui.OnZoneSelect(WW.currentZone)
		
		if WW.settings.fixes.surfingWeapons then
			WW.fixes.FixSurfingWeapons()
		end
		
		if WW.settings.autoEquipSetups
			and not isFirstZoneAfterReload
			and WW.currentZone.tag ~= "PVP" then
			
			-- equip first setup
			local firstSetupName = WW.currentZone.bosses[1]
			if firstSetupName then
				WW.OnBossChange(_, false, firstSetupName.name)
			end
		end
	end, 250)
end

function WW.RegisterEvents()
	EVENT_MANAGER:UnregisterForEvent(WW.name, EVENT_ADD_ON_LOADED)
	
	-- repair cp animation
	ZO_PreHook(CHAMPION_PERKS, "StartStarConfirmAnimation", function()
		if cancelAnimation then
			cancelAnimation = false
			return true
		end
	end)
	
	-- cp cooldown
	EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_CHAMPION_PURCHASE_RESULT, function(_, result)
		if result == CHAMPION_PURCHASE_SUCCESS then
			cpCooldown = 31
			EVENT_MANAGER:RegisterForUpdate(WW.name .. "CPCooldownLoop", 1000, WW.UpdateCPCooldown)
		end
	end)
	
	-- check for wipe
	EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag, isDead)
		if not isDead then return end
		if not IsUnitGrouped("player") and unitTag ~= "player" then return end
		if IsUnitGrouped("player") and unitTag:sub(1,1) ~= "g" then return end
		
		if not wipeChangeCooldown and WW.IsWipe() then
			wipeChangeCooldown = true
			zo_callLater(function()
				wipeChangeCooldown = false
			end, 15000)
		end
	end)
	
	EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_PLAYER_ACTIVATED, WW.OnZoneChange)
	EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_BOSSES_CHANGED, WW.OnBossChange)
end

function WW.Init()
	WW.lookupZones = {}
	for _, zone in pairs(WW.zones) do
		zone.lookupBosses = {}
		for i, boss in ipairs(zone.bosses) do
			zone.lookupBosses[boss.name] = i
		end
		
		-- support multiple zones per entry
		if type(zone.id) == "table" then
			for zoneId in pairs(zone.id) do
				WW.lookupZones[zoneId] = zone
			end
		else
			WW.lookupZones[zone.id] = zone
		end
	end
	
	WW.lookupBuffFood = {}
	for itemId, abilityId in pairs(WW.BUFFFOOD) do
		if not WW.lookupBuffFood[abilityId] then
			WW.lookupBuffFood[abilityId] = {}
		end
		table.insert(WW.lookupBuffFood[abilityId], itemId)
	end
	
	for i, trait in ipairs(WW.TRAITS) do
		local char = tostring(WW.PREVIEW.CHARACTERS[i])
		WW.PREVIEW.TRAITS[trait] = char
		WW.PREVIEW.TRAITS[char] = trait
	end
	
	local bufffoodCache = {}
	for food, _ in pairs(WW.BUFFFOOD) do
		table.insert(bufffoodCache, food)
	end
	table.sort(bufffoodCache)
	for i, food in ipairs(bufffoodCache) do
		local char = tostring(WW.PREVIEW.CHARACTERS[i])
		WW.PREVIEW.FOOD[food] = char
		WW.PREVIEW.FOOD[char] = food
	end
	
	WW.currentZone = WW.zones["GEN"]
	WW.currentZoneId = 0
	
	WW.selection = {
		zone = WW.zones["GEN"],
		pageId = 1
	}
end

function WW.OnAddOnLoaded(_, addonName)
	if addonName ~= WW.name then return end
	
	-- Refactor this
	WW.Init()
	WW.menu.Init()
	WW.queue.Init()
	WW.gui.Init()
	WW.conditions.Init()
	WW.transfer.Init()
	WW.repair.Init()
	WW.poison.Init()
	WW.prebuff.Init()
	WW.banking.Init()
	WW.food.Init()
	WW.markers.Init()
	WW.preview.Init()
	WW.code.Init()
	WW.fixes.Init()
	
	WW.RegisterEvents()
end

EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_ADD_ON_LOADED, WW.OnAddOnLoaded)