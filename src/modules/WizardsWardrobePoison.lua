WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.poison = {}
local WWP = WW.poison
local WWQ = WW.queue

WWP.poisons = {
	CRAFTED = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:138240|h|h",
	CROWN = "|H0:item:79690:6:1:0:0:0:0:0:0:0:0:0:0:0:1:36:0:1:0:0:0|h|h",
}

function WWP.Init()
	WWP.name = WW.name .. "Poison"
	WWP.lastPoison = nil
	WWP.RegisterEvents()
end

function WWP.RegisterEvents()
	if WW.settings.fillPoisons then
		EVENT_MANAGER:RegisterForEvent( WWP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, WWP.OnInventoryChange )
		EVENT_MANAGER:AddFilterForEvent( WWP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN )
		EVENT_MANAGER:AddFilterForEvent( WWP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON,
			INVENTORY_UPDATE_REASON_DEFAULT )

		-- wait until ui is loaded
		zo_callLater( function()
			WWP.OnInventoryChange( _, _, EQUIP_SLOT_POISON, _, _, _, _ )
			WWP.OnInventoryChange( _, _, EQUIP_SLOT_BACKUP_POISON, _, _, _, _ )
		end, 100 )
	else
		EVENT_MANAGER:UnregisterForEvent( WWP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
	end
end

function WWP.OnInventoryChange( _, _, slotId, _, _, _, _ )
	if slotId == EQUIP_SLOT_POISON or slotId == EQUIP_SLOT_BACKUP_POISON then
		local _, stack, _, _, _, _, _, _ = GetItemInfo( BAG_WORN, slotId )
		if stack == 1 then
			local lookupLink = GetItemLink( BAG_WORN, slotId, LINK_STYLE_DEFAULT )
			WWP.lastPoison = lookupLink
			return
		end
		if stack == 0 and WWP.lastPoison then
			local task = function()
				if not WWP.lastPoison then
					return
				end
				WWP.EquipPoisons( WWP.lastPoison, slotId )
				WWP.lastPoison = nil
			end
			WWQ.Push( task )
		end
	end
end

function WWP.EquipPoisons( itemLink, slotId )
	local poisonSlots = WWP.GetSlotsByItemLink( itemLink )
	if #poisonSlots == 0 then
		local backupLink = WWP.GetBackupPoison( itemLink )
		if not backupLink then
			WW.Log( GetString( WW_MSG_NOPOISONS ), WW.LOGTYPES.ERROR )
			return
		end
		poisonSlots = WWP.GetSlotsByItemLink( backupLink )
		if #poisonSlots == 0 then
			WW.Log( GetString( WW_MSG_NOPOISONS ), WW.LOGTYPES.ERROR )
			return
		end
	end
	local poisonStack = poisonSlots[ #poisonSlots ]
	EquipItem( poisonStack.bag, poisonStack.slot, slotId )
	PlaySound( SOUNDS.DYEING_TOOL_SET_FILL_USED )
end

function WWP.GetSlotsByItemLink( wantedItemLink )
	local itemList = {}
	for slotIndex = 0, GetBagSize( BAG_BACKPACK ) do
		local itemLink = GetItemLink( BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT )
		if itemLink == wantedItemLink then
			local _, stack = GetItemInfo( BAG_BACKPACK, slotIndex )
			itemList[ #itemList + 1 ] = {
				bag = BAG_BACKPACK,
				slot = slotIndex,
				count = stack,
			}
		end
	end
	return itemList
end

function WWP.GetBackupPoison( itemLink )
	if itemLink == WWP.poisons.CRAFTED then
		return WWP.poisons.CROWN
	elseif itemLink == WWP.poisons.CROWN then
		return WWP.poisons.CRAFTED
	else
		return nil
	end
end
