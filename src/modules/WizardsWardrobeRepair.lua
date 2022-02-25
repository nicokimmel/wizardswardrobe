WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.repair = {}
local WWR = WW.repair
local WWQ = WW.queue

WWR.REPAIRTHRESHOLD = 15
WWR.REPKITID = GetItemLinkItemId("|H0:item:44879:121:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")

WWR.CHARGETHRESHOLD = 2
WWR.SOULGEMID = GetItemLinkItemId("|H0:item:33271:31:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")
WWR.CHARGEITEMS = {
	EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
	EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

function WWR.Init()
	WWR.name = WW.name .. "Repair"
	WWR.repairName = WWR.name .. "Armor"
	WWR.chargeName = WWR.name .. "Weapons"
	
	WWR.logCooldown = false
	WWR.repairCooldown = {}
	
	WWR.RegisterRepairEvents()
	WWR.RegisterChargeEvents()
end

function WWR.RegisterRepairEvents()
	if WW.settings.repairArmor then
		EVENT_MANAGER:RegisterForEvent(WWR.repairName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, WWR.RepairSingleWithKit) -- during fights
		EVENT_MANAGER:AddFilterForEvent(WWR.repairName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
		EVENT_MANAGER:AddFilterForEvent(WWR.repairName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DURABILITY_CHANGE)
		EVENT_MANAGER:RegisterForEvent(WWR.repairName, EVENT_PLAYER_REINCARNATED, WWR.RepairAllWithKit) -- no longer ghost
		EVENT_MANAGER:RegisterForEvent(WWR.repairName, EVENT_PLAYER_ALIVE, WWR.RepairAllWithKit) -- revive at wayshrine
		EVENT_MANAGER:RegisterForEvent(WWR.repairName, EVENT_OPEN_STORE, WWR.OnOpenStore)
		-- wait until ui is loaded
		zo_callLater(function()
			WWR.RepairAllWithKit()
		end, 100)
	else
		EVENT_MANAGER:UnregisterForEvent(WWR.repairName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(WWR.repairName, EVENT_PLAYER_REINCARNATED)
		EVENT_MANAGER:UnregisterForEvent(WWR.repairName, EVENT_PLAYER_ALIVE)
		EVENT_MANAGER:UnregisterForEvent(WWR.repairName, EVENT_OPEN_STORE)
	end
end

function WWR.RegisterChargeEvents()
	if WW.settings.chargeWeapons then
		EVENT_MANAGER:RegisterForEvent(WWR.chargeName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, WWR.ChargeWeapon)
		EVENT_MANAGER:AddFilterForEvent(WWR.chargeName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
		EVENT_MANAGER:AddFilterForEvent(WWR.chargeName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_ITEM_CHARGE)
		-- wait until ui is loaded
		zo_callLater(function()
			WWR.ChargeAll()
		end, 100)
	else
		EVENT_MANAGER:UnregisterForEvent(WWR.chargeName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	end
end

function WWR.OnOpenStore()
	RepairAll()
end

function WWR.RepairSingleWithKit(_, bagId, slotId, _, _, inventoryUpdateReason, _)
	local task = function()
		local repairKey = string.format("%d%d", bagId, slotId)
		if WWR.repairCooldown[repairKey] then
			return -- event gets triggered 2 times
		end
		if DoesItemHaveDurability(bagId, slotId) then
			local condition = GetItemCondition(bagId, slotId)
			if condition < WWR.REPAIRTHRESHOLD then
				local kitSlots = WWR.GetSlotsByItemId(WWR.REPKITID)
				if #kitSlots == 0 then
					WWR.LogDirty(GetString(WW_MSG_NOREPKITS), WW.LOGTYPES.ERROR)
					return
				end
				local kitStack = kitSlots[#kitSlots]
				RepairItemWithRepairKit(bagId, slotId, kitStack.bag, kitStack.slot)
				WWR.repairCooldown[repairKey] = true
				zo_callLater(function()
					WWR.repairCooldown[repairKey] = nil
				end, 2000)
				--d("Repaired " .. GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT) .. condition)
			end
		end
	end
	WWQ.Push(task)
end

function WWR.RepairAllWithKit()
	if IsUnitDeadOrReincarnating("player") then
		return
	end
	local task = function()
		local kitSlots = WWR.GetSlotsByItemId(WWR.REPKITID)
		for slotIndex = 0, GetBagSize(BAG_WORN) do
			if DoesItemHaveDurability(BAG_WORN, slotIndex) then
				local repairKey = string.format("%d%d", BAG_WORN, slotIndex)
				if WWR.repairCooldown[repairKey] then
					return -- event gets triggered 2 times
				end
				
				local condition = GetItemCondition(BAG_WORN, slotIndex)
				if condition < WWR.REPAIRTHRESHOLD then
					if #kitSlots == 0 then
						WW.Log(GetString(WW_MSG_NOREPKITS), WW.LOGTYPES.ERROR)
						return
					end
					local kitStack = kitSlots[#kitSlots]
					if not kitStack then
						WW.Log(GetString(WW_MSG_NOTENOUGHREPKITS), WW.LOGTYPES.ERROR)
						return
					end
					RepairItemWithRepairKit(BAG_WORN, slotIndex, kitStack.bag, kitStack.slot)
					WWR.repairCooldown[repairKey] = true
					zo_callLater(function()
						WWR.repairCooldown[repairKey] = nil
					end, 2000)
					kitStack.count = kitStack.count - 1
					if kitStack.count <= 0 then
						kitSlots[#kitSlots] = nil
					end
					--d("Repaired " .. GetItemLink(BAG_WORN, slotIndex, LINK_STYLE_DEFAULT) .. condition)
				end
			end
		end
	end
	WWQ.Push(task)
end

function WWR.ChargeWeapon(_, bagId, slotId, _, _, inventoryUpdateReason, _)
	local task = function()
		local itemType = GetItemType(bagId, slotId)
		if IsItemChargeable(bagId, slotId) and itemType == ITEMTYPE_WEAPON then
			local charges, maxCharges = GetChargeInfoForItem(bagId , slotId)
			if charges < WWR.CHARGETHRESHOLD then
				local gemSlots = WWR.GetSlotsByItemId(WWR.SOULGEMID)
				if #gemSlots == 0 then
					WW.Log(GetString(WW_MSG_NOSOULGEMS), WW.LOGTYPES.ERROR)
					return
				end
				local gemStack = gemSlots[#gemSlots]
				ChargeItemWithSoulGem(bagId, slotId, gemStack.bag, gemStack.slot)
				--d("Charged " .. GetItemLink(BAG_WORN, slotId, LINK_STYLE_DEFAULT))
			end
		end
	end
	-- WWQ.Push(task)
	-- since it can be done in combat
	task()
end

function WWR.ChargeAll()
	local task = function()
		local gemSlots = WWR.GetSlotsByItemId(WWR.SOULGEMID)
		for _, gearSlot in ipairs(WWR.CHARGEITEMS) do
			local itemType = GetItemType(BAG_WORN, gearSlot)
			if IsItemChargeable(BAG_WORN, gearSlot) and itemType == ITEMTYPE_WEAPON then
				local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, gearSlot)
				if charges < WWR.CHARGETHRESHOLD then
					if #gemSlots == 0 then
						WW.Log(GetString(WW_MSG_NOSOULGEMS), WW.LOGTYPES.ERROR)
						return
					end
					local gemStack = gemSlots[#gemSlots]
					if gemStack == nil then
						WW.Log(GetString(WW_MSG_NOTENOUGHSOULGEMS), WW.LOGTYPES.ERROR)
						return
					end
					ChargeItemWithSoulGem(BAG_WORN, gearSlot, gemStack.bag, gemStack.slot)
					--d("Charged " .. GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT))
					gemStack.count = gemStack.count - 1
					if gemStack.count <= 0 then
						gemSlots[#gemSlots] = nil
					end
				end
			end
		end
	end
	-- WWQ.Push(task)
	-- since it can be done in combat
	task()
end

function WWR.GetSlotsByItemId(wantedItemId)
	local itemList = {}
	for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
		local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
		local itemId = GetItemLinkItemId(itemLink)
		if itemId == wantedItemId then
			local _, stack = GetItemInfo(BAG_BACKPACK, slotIndex)
			itemList[#itemList + 1] = {
				bag = BAG_BACKPACK,
				slot = slotIndex,
				count = stack,
			}
		end
	end
	return itemList
end

function WWR.LogDirty(...)
	if not WWR.logCooldown then
		WW.Log(...)
		WWR.logCooldown = true
		zo_callLater(function()
			WWR.logCooldown = false
		end, 1000)
	end
end