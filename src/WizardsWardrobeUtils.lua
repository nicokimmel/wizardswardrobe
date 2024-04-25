WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.gui = WW.gui or {}
local WWG = WW.gui

function WW.GetSelectedPage( zone )
	if WW.pages[ zone.tag ] and WW.pages[ zone.tag ][ 0 ] then
		return WW.pages[ zone.tag ][ 0 ].selected
	end
	return nil
end

function WW.GetBossName( zone, index )
	if zone.bosses
		and zone.bosses[ index ]
		and zone.bosses[ index ].name
		and zone.bosses[ index ].name ~= GetString( WW_EMPTY ) then
		return zone.bosses[ index ].displayName or zone.bosses[ index ].name
	end
	return nil
end

function WW.ChangeItemLinkStyle( itemLink, linkStyle )
	return string.format( "%s%d%s", itemLink:sub( 1, 2 ), linkStyle, itemLink:sub( 4 ) )
end

function WW.GetSlotBoundAbilityId(slotIndex, hotbarIndex)
    local slottedId = GetSlotBoundId(slotIndex, hotbarIndex)
    local actionType = GetSlotType(slotIndex, hotbarIndex)

    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        slottedId = GetAbilityIdForCraftedAbilityId(id)
    end

    return slottedId
end

function WW.CompareCP( setup )
	for slotIndex = 1, 12 do
		local savedSkillId = setup:GetCP()[ slotIndex ]
		local selectedSkilId = WW.GetSlotBoundAbilityId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
		if not savedSkillId or savedSkillId ~= selectedSkilId then
			return false
		end
	end
	return true
end

function WW.CheckGear( zone, pageId )
	local missingTable = {}
	local inventoryList = WW.GetItemLocation()
	for entry in WW.PageIterator( zone, pageId ) do
		local setup = Setup:FromStorage( zone.tag, pageId, entry.index )
		for _, gearSlot in ipairs( WW.GEARSLOTS ) do
			if gearSlot ~= EQUIP_SLOT_POISON and gearSlot ~= EQUIP_SLOT_BACKUP_POISON then
				local gear = setup:GetGearInSlot( gearSlot )
				if gear and gear.id ~= "0" then
					if not inventoryList[ gear.id ] then
						table.insert( missingTable, gear.link )

						-- sorts out duplicates
						inventoryList[ gear.id ] = 0
					end
				end
			end
		end
	end
	return missingTable
end

function WW.GetItemLocation()
	local inventoryList = {}
	for _, bag in ipairs( { BAG_WORN, BAG_BACKPACK } ) do
		for slot = 0, GetBagSize( bag ) do
			local lookupId = Id64ToString( GetItemUniqueId( bag, slot ) )
			inventoryList[ lookupId ] = {
				bag = bag,
				slot = slot,
			}
		end
	end
	return inventoryList
end

function WW.IsMythic( bag, slot )
	local _, _, _, _, _, _, _, _, itemType = GetItemInfo( bag, slot )
	if itemType == 6 then
		return true
	end
	return false
end

function WW.IsWipe()
	if not IsUnitGrouped( "player" ) then
		if IsUnitDeadOrReincarnating( "player" ) then
			return true
		end
		return false
	end
	for i = 1, GetGroupSize() do
		local groupTag = GetGroupUnitTagByIndex( i )
		if IsUnitOnline( groupTag ) then
			if not IsUnitDeadOrReincarnating( groupTag ) then
				return false
			end
		end
	end
	return true
end

function WW.Log( logMessage, logType, formatColor, ... )
	if WW.settings.printMessages == "chat" or WW.settings.printMessages == "alert" or WW.settings.printMessages == "announcement" then
		if not logType then logType = WW.LOGTYPES.NORMAL end
		if not formatColor then formatColor = "FFFFFF" end
		logMessage = string.format( logMessage, ... )
		logMessage = string.gsub( logMessage, "%[", "|c" .. formatColor .. "[" )
		logMessage = string.gsub( logMessage, "%]", "]|c" .. logType )
		logMessage = string.format( "|c18bed8[|c65d3b0W|cb2e789W|cfffc61]|r|c%s %s|r", logType, logMessage )

		if WW.settings.printMessages == "alert" then
			ZO_Alert( UI_ALERT_CATEGORY_ALERT, nil, logMessage )
		elseif WW.settings.printMessages == "announcement" then
			local sound = SOUNDS.NONE
			if logType == WW.LOGTYPES.ERROR then
				sound = SOUNDS.GENERAL_ALERT_ERROR
			end
			local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams( CSA_CATEGORY_MAJOR_TEXT,
																			  sound )
			messageParams:SetText( logMessage )
			messageParams:SetCSAType( CENTER_SCREEN_ANNOUNCE_TYPE_BATTLEGROUND_NEARING_VICTORY )
			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams( messageParams )
		else
			CHAT_ROUTER:AddSystemMessage( logMessage )
		end
	end
end

function WW.GetTableLength( givenTable )
	local count = 0
	for _ in pairs( givenTable ) do
		count = count + 1
	end
	return count
end

-- food
function WW.FindFood( foodChoice )
	if not foodChoice then return nil end
	local consumables = WW.GetConsumableItems()
	for _, itemId in ipairs( foodChoice ) do
		if consumables[ itemId ] then
			return consumables[ itemId ]
		end
	end
	return nil
end

function WW.GetConsumableItems()
	local itemList = {}
	for slotIndex = 0, GetBagSize( BAG_BACKPACK ) do
		local itemType = GetItemType( BAG_BACKPACK, slotIndex )
		if itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_FOOD then
			local itemLink = GetItemLink( BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT )
			local itemId = GetItemLinkItemId( itemLink )
			itemList[ itemId ] = slotIndex
		end
	end
	return itemList
end

function WW.HasFoodIdRunning( itemId )
	for i = 1, GetNumBuffs( "player" ) do
		local abilityId = select( 11, GetUnitBuffInfo( "player", i ) )
		if WW.BUFFFOOD[ itemId ] == abilityId then
			return abilityId
		end
	end
	return false
end

function WW.HasFoodRunning()
	for i = 1, GetNumBuffs( "player" ) do
		local abilityId = select( 11, GetUnitBuffInfo( "player", i ) )
		if WW.lookupBuffFood[ abilityId ] then
			return abilityId
		end
	end
	return false
end

-- gui
function WWG.HidePage( hidden )
	if WWG.zones[ WW.selection.zone.tag ]
		and WWG.zones[ WW.selection.zone.tag ].scrollContainer then
		WWG.zones[ WW.selection.zone.tag ].scrollContainer:SetHidden( hidden )
	end
end

function WWG.SetSetupDisabled( zone, pageId, index, disabled )
	local setup = Setup:FromStorage( zone.tag, pageId, index )
	setup:SetDisabled( disabled )
	setup:ToStorage( zone.tag, pageId, index )
	WWG.RefreshSetup( zone, pageId, index )
end

function WWG.GetSortedZoneList()
	local zoneList = {}
	for _, zone in pairs( WW.zones ) do
		table.insert( zoneList, zone )
	end
	table.sort( zoneList, function( a, b ) return a.priority < b.priority end )
	return zoneList
end

function WWG.GearLinkTableToString( gearLinkTable )
	local gearText = {}
	for _, gear in ipairs( gearLinkTable ) do
		local itemQuality = GetItemLinkDisplayQuality( gear )
		local itemColor = GetItemQualityColor( itemQuality )
		local itemName = LocalizeString( "<<C:1>>", GetItemLinkName( gear ) )
		table.insert( gearText, itemColor:Colorize( itemName ) )
	end
	return table.concat( gearText, "\n" )
end

function WWG.SetTooltip( control, align, text )
	control:SetMouseEnabled( true )
	control:SetHandler( "OnMouseEnter", function( self )
		if text and text ~= "" then
			ZO_Tooltips_ShowTextTooltip( self, align, tostring( text ) )
		end
	end )
	control:SetHandler( "OnMouseExit", function( self )
		ZO_Tooltips_HideTextTooltip()
	end )
end

function WWG.ShowConfirmationDialog( name, dialogText, confirmCallback, cancelCallback )
	local uniqueId = string.format( "%s%s", "WizardsWardrobeDialog", name )
	ESO_Dialogs[ uniqueId ] = {
		canQueue = true,
		uniqueIdentifier = uniqueId,
		title = { text = WW.displayName },
		mainText = { text = dialogText },
		buttons = {
			[ 1 ] = {
				text = SI_DIALOG_CONFIRM,
				callback = function()
					confirmCallback()
				end,
			},
			[ 2 ] = {
				text = SI_DIALOG_CANCEL,
				callback = function()
					if cancelCallback then
						cancelCallback()
					end
				end,
			},
		},
		setup = function() end,
	}
	ZO_Dialogs_ShowDialog( uniqueId, nil, { mainTextParams = {} } )
end

function WWG.ShowEditDialog( name, dialogText, initialText, confirmCallback, cancelCallback )
	local uniqueId = string.format( "%s%s", "WizardsWardrobeDialog", name )
	ESO_Dialogs[ uniqueId ] = {
		canQueue = true,
		uniqueIdentifier = uniqueId,
		title = { text = WW.displayName },
		mainText = { text = dialogText },
		editBox = {},
		buttons = {
			[ 1 ] = {
				text = SI_DIALOG_CONFIRM,
				callback = function( dialog )
					local input = ZO_Dialogs_GetEditBoxText( dialog )
					confirmCallback( input )
				end,
			},
			[ 2 ] = {
				text = SI_DIALOG_CANCEL,
				callback = function()
					if cancelCallback then
						cancelCallback()
					end
				end,
			},
		},
		setup = function() end,
	}
	ZO_Dialogs_ShowDialog( uniqueId, nil, { mainTextParams = {}, initialEditText = initialText } )
end
