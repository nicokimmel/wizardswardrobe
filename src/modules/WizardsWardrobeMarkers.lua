WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.markers = {}
local WWM = WW.markers

function WWM.Init()
	WWM.name = WW.name .. "Markers"
	WWM.gearList = {}
	WWM.markList = {}
	
	if not WW.settings.inventoryMarker then return end
	
	WWM.BuildGearList()
	WWM.HookInventories()
end

function WWM.BuildGearList()
	if not WW.settings.inventoryMarker then return end
	WWM.gearList = {}
	for entry in WW.SetupIterator() do
		local setup = entry.setup
		for _, gearSlot in ipairs(WW.GEARSLOTS) do
			local item = setup.gear[gearSlot]
			if item then
				if not WWM.gearList[item.id] then
					WWM.gearList[item.id] = {}
				end
				table.insert(WWM.gearList[item.id], {tag = entry.zone.tag, pageId = entry.pageId, index = entry.index})
			end
		end
	end
end

function WWM.HookInventories()
	for i, inventory in ipairs(WW.MARKINVENTORIES) do
		SecurePostHook(inventory.dataTypes[1], "setupCallback", function(control, slot)
			WWM.AddMark(control)
		end)
	end
end

function WWM.GetTooltip(itemData)
	local text = {}
	for _, data in ipairs(itemData) do
		if data and data.tag and data.pageId and data.index then
			local pageName = WW.pages[data.tag][data.pageId].name
			local setupName = WW.setups[data.tag][data.pageId][data.index].name
			table.insert(text, string.format("%s (%s, %s)", setupName, data.tag, pageName))
		end
	end
	return table.concat(text, "\n")
end

function WWM.AddMark(control)
	local slot = control.dataEntry.data
	local mark = WWM.GetMark(control)
	
	local lookupId = Id64ToString(GetItemUniqueId(slot.bagId, slot.slotIndex))
	local itemData = WWM.gearList[lookupId]
	mark:SetHidden(not itemData)
	
	mark:SetHandler("OnMouseEnter", function(self)
		if itemData then
			ZO_Tooltips_ShowTextTooltip(self, RIGHT, WWM.GetTooltip(itemData))
		end
	end)
	mark:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end)
end

function WWM.GetMark(control)
	local name = control:GetName()
	local mark = WWM.markList[name]
	if not mark then
		mark = WINDOW_MANAGER:CreateControl(name .. "WizardsWardrobeMarker", control, CT_TEXTURE)
		WWM.markList[name] = mark
		mark:SetTexture("/WizardsWardrobe/assets/mark.dds")
		mark:SetColor(0.09, 0.75, 0.85, 1)
		mark:SetDrawLayer(3)
		mark:SetHidden(true)
		mark:SetDimensions(12, 12)
		mark:SetAnchor(RIGHT, control, LEFT, 38)
		mark:SetMouseEnabled(true)
	end
	return mark
end