WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.fixes = {}
local WWF = WW.fixes

function WWF.Init()
	WWF.name = WW.name .. "Fixes"
	WWF.flippingShoulders = false
end

function WWF.FlipShoulders()
	if WWF.flippingShoulders then return end
	WWF.flippingShoulders = true
	
	local itemId = GetItemId(BAG_WORN, EQUIP_SLOT_SHOULDERS)
	local itemLink = GetItemLink(BAG_WORN, EQUIP_SLOT_SHOULDERS)
	if not itemId or itemId == 0 then 
		WWF.flippingShoulders = false
		return
	end
	
	if not DoesBagHaveSpaceFor(BAG_BACKPACK, BAG_WORN, EQUIP_SLOT_SHOULDERS) then
		WW.Log(GetString(WW_MSG_WITHDRAW_FULL), WW.LOGTYPES.ERROR)
		WWF.flippingShoulders = false
		return
	end
	
	local slot = FindFirstEmptySlotInBag(BAG_BACKPACK)
	if not slot then
		WWF.flippingShoulders = false
		return
	end
		
	CallSecureProtected("RequestMoveItem", BAG_WORN, EQUIP_SLOT_SHOULDERS, BAG_BACKPACK, slot, 1)
	
	local i = 1
	EVENT_MANAGER:RegisterForUpdate(WWF.name .. "FlipShoulders", 100, function()
		local lookupId = GetItemId(BAG_BACKPACK, slot)
		if lookupId == itemId then
			EVENT_MANAGER:UnregisterForUpdate(WWF.name .. "FlipShoulders")
			zo_callLater(function()
				CallSecureProtected( "RequestEquipItem", BAG_BACKPACK, slot, BAG_WORN, EQUIP_SLOT_SHOULDERS )
			end, 500)
			WWF.flippingShoulders = false
			return
		end
		
		i = i + 1
		if i > 30 then -- 3000ms
			EVENT_MANAGER:UnregisterForUpdate(WWF.name .. "FlipShoulders")
			WW.Log(GetString(WW_MSG_GEARSTUCK), WW.LOGTYPES.ERROR, nil, itemLink)
			WWF.flippingShoulders = false
			return
		end
	end)
end

function WWF.FixSurfingWeapons()	
	local collectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT)
	if collectibleId == 0 then collectibleId = 5002 end
	
	UseCollectible(collectibleId)
	
	zo_callLater(function()
		UseCollectible(collectibleId)	
	end, 1500 + GetLatency())
end