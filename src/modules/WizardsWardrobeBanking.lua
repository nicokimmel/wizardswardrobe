WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.banking = {}
local WWB = WW.banking
local WWG = WW.gui

function WWB.Init()
	WWB.name = WW.name .. "Banking"
	WWB.RegisterEvents()
end

function WWB.RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(WWB.name, EVENT_OPEN_BANK, function(_, bankBag)
		if not WW.DISABLEDBAGS[bankBag] then
			WWG.RefreshPage()
		end
	end)
	EVENT_MANAGER:RegisterForEvent(WWB.name, EVENT_CLOSE_BANK, function(_)
		WWG.RefreshPage()
	end)
end

function WWB.WithdrawPage(zone, pageId)
	local bankBag = GetBankingBag()
	if WW.DISABLEDBAGS[bankBag] then return end
	
	local preGearTable = {}
	local amount = 0
	
	for entry in WW.PageIterator(zone, pageId) do
		local setup = Setup:FromStorage(zone.tag, pageId, entry.index)
		for _, gearSlot in ipairs(WW.GEARSLOTS) do
			local gear = setup:GetGearInSlot(gearSlot)
			if gearSlot ~= EQUIP_SLOT_POISON
				and gearSlot ~= EQUIP_SLOT_BACKUP_POISON
				and gearSlot ~= EQUIP_SLOT_COSTUME
				and gear then
				
				if not preGearTable[gear.id] then
					preGearTable[gear.id] = true
					amount = amount + 1
				end
			end
		end
	end
	
	if not IsBankOpen() then return end
	
	local gearTable = WWB.ScanBank(bankBag, preGearTable, amount)
	
	local pageName = WW.pages[zone.tag][pageId].name
	WW.Log(GetString(WW_MSG_WITHDRAW_PAGE), WW.LOGTYPES.NORMAL, "FFFFFF", pageName)
	
	WWB.MoveItems(gearTable, BAG_BACKPACK)
end

function WWB.WithdrawSetup(zone, pageId, index)
	local bankBag = GetBankingBag()
	if WW.DISABLEDBAGS[bankBag] then return end
	
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	
	local preGearTable = {}
	local amount = 0
	for _, gearSlot in ipairs(WW.GEARSLOTS) do
		local gear = setup:GetGearInSlot(gearSlot)
		if gearSlot ~= EQUIP_SLOT_POISON
			and gearSlot ~= EQUIP_SLOT_BACKUP_POISON
			and gearSlot ~= EQUIP_SLOT_COSTUME
			and gear then
			
			if not preGearTable[gear.id] then
				preGearTable[gear.id] = true
				amount = amount + 1
			end
		end
	end
	
	if not IsBankOpen() then return end
	
	local gearTable = WWB.ScanBank(bankBag, preGearTable, amount)
	
	WW.Log(GetString(WW_MSG_WITHDRAW_SETUP), WW.LOGTYPES.NORMAL, "FFFFFF", setup:GetName())
	
	WWB.MoveItems(gearTable, BAG_BACKPACK)
end

function WWB.DepositSetup(zone, pageId, index)
	local bankBag = GetBankingBag()
	if WW.DISABLEDBAGS[bankBag] then return end
	
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	local itemLocationTable = WW.GetItemLocation()
	
	local gearTable = {}
	for _, gearSlot in ipairs(WW.GEARSLOTS) do
		local gear = setup:GetGearInSlot(gearSlot)
		if gearSlot ~= EQUIP_SLOT_POISON
			and gearSlot ~= EQUIP_SLOT_BACKUP_POISON
			and gearSlot ~= EQUIP_SLOT_COSTUME
			and gear then
			
			if itemLocationTable[gear.id] then
				table.insert(gearTable, {
					id = gear.id,
					bag = itemLocationTable[gear.id].bag,
					slot = itemLocationTable[gear.id].slot,
				})
			end
		end
	end
	
	WW.Log(GetString(WW_MSG_DEPOSIT_SETUP), WW.LOGTYPES.NORMAL, "FFFFFF", setup:GetName())
	
	WWB.MoveItems(gearTable, bankBag)
end

function WWB.DepositPage(zone, pageId)
	local bankBag = GetBankingBag()
	if WW.DISABLEDBAGS[bankBag] then return end
	
	local itemLocationTable = WW.GetItemLocation()
	
	local preGearTable = {}
	for entry in WW.PageIterator(zone, pageId) do
		local setup = Setup:FromStorage(zone.tag, pageId, entry.index)
		for _, gearSlot in ipairs(WW.GEARSLOTS) do
			local gear = setup:GetGearInSlot(gearSlot)
			if gearSlot ~= EQUIP_SLOT_POISON
				and gearSlot ~= EQUIP_SLOT_BACKUP_POISON
				and gearSlot ~= EQUIP_SLOT_COSTUME
				and gear then
				
				if itemLocationTable[gear.id] then
					preGearTable[gear.id] = {
						bag = itemLocationTable[gear.id].bag,
						slot = itemLocationTable[gear.id].slot,
					}
				end
			end
		end
	end
	
	local gearTable = {}
	for id, item in pairs(preGearTable) do
		table.insert(gearTable, {
			id = id,
			bag = item.bag,
			slot = item.slot,
		})
	end
	
	local pageName = WW.pages[zone.tag][pageId].name
	WW.Log(GetString(WW_MSG_DEPOSIT_PAGE), WW.LOGTYPES.NORMAL, "FFFFFF", pageName)
	
	WWB.MoveItems(gearTable, bankBag)
end

function WWB.ScanBank(bankBag, itemIdTable, amount)
	local itemTable = {}
	local i = 0
	
	for slot in ZO_IterateBagSlots(bankBag) do
		local lookupId = Id64ToString(GetItemUniqueId(bankBag, slot))
		if lookupId and itemIdTable[lookupId] then
			table.insert(itemTable, {
				id = lookupId,
				bag = bankBag,
				slot = slot,
			})
			i = i + 1
			if i >= amount then
				-- found all items
				return itemTable
			end
		end
	end
	
	if bankBag == BAG_BANK and IsESOPlusSubscriber() then -- straight up torture
		for slot in ZO_IterateBagSlots(BAG_SUBSCRIBER_BANK) do
			local lookupId = Id64ToString(GetItemUniqueId(BAG_SUBSCRIBER_BANK, slot))
			if lookupId and itemIdTable[lookupId] then
				table.insert(itemTable, {
					id = lookupId,
					bag = BAG_SUBSCRIBER_BANK,
					slot = slot,
				})
				i = i + 1
				if i >= amount then
					-- found all items
					return itemTable
				end
			end
		end
	end
	
	-- check if items are already in inventory
	local inventoryList = WW.GetItemLocation()
	for itemId, _ in pairs(inventoryList) do
		if itemId and itemIdTable[itemId] then
			i = i + 1
			if i >= amount then
				-- found all items
				return itemTable
			end
		end
	end
	
	WW.Log(GetString(WW_MSG_WITHDRAW_ENOENT), WW.LOGTYPES.INFO)
	return itemTable
end

function WWB.MoveItems(itemTable, destBag, supressOutput)
	if (destBag == BAG_BANK or destBag == BAG_SUBSCRIBER_BANK) and not IsBankOpen() then return end
	
	if #itemTable == 0 then
		if not supressOutput then
			WW.Log(GetString(WW_MSG_TRANSFER_FINISHED))
		end
		return
	end
	local item = itemTable[1]
	
	local sourceId = item.id
	local sourceBag = item.bag
	local sourceSlot = item.slot
	
	-- check space
	if not DoesBagHaveSpaceFor(destBag, sourceBag, sourceSlot) then
		if destBag == BAG_BACKPACK then
			WW.Log(GetString(WW_MSG_WITHDRAW_FULL), WW.LOGTYPES.ERROR)
		else
			if destBag == BAG_BANK and IsESOPlusSubscriber() then
				WWB.MoveItems(itemTable, BAG_SUBSCRIBER_BANK, supressOutput)
			else
				WW.Log(GetString(WW_MSG_DEPOSIT_FULL), WW.LOGTYPES.ERROR)
			end
		end
		return false
	end
	
	-- get first slot
	local destSlot = FindFirstEmptySlotInBag(destBag)
	if not destSlot then
		return false
	end
	
	-- move item
	CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, destBag, destSlot, 1)
	
	-- check arrival
	local identifier = string.format("WWB_%s", sourceId)
	local i = 1
	EVENT_MANAGER:RegisterForUpdate(identifier, 100, function()
		if (destBag == BAG_BANK or destBag == BAG_SUBSCRIBER_BANK) and not IsBankOpen() then
			EVENT_MANAGER:UnregisterForUpdate(identifier)
			return
		end
		
		local itemId = GetItemId(destBag, destSlot)
		if itemId > 0 then
			EVENT_MANAGER:UnregisterForUpdate(identifier)
			table.remove(itemTable, 1)
			zo_callLater(function()
				WWB.MoveItems(itemTable, destBag, supressOutput)
			end, 100)
			return
		end
		
		i = i + 1
		if i > 30 then -- 3000ms
			EVENT_MANAGER:UnregisterForUpdate(identifier)
			WW.Log(GetString(WW_MSG_TRANSFER_TIMEOUT), WW.LOGTYPES.ERROR)
			return
		end
	end)
end