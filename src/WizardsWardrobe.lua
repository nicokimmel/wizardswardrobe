WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe
local WWQ = WW.queue
local WWV = WW.validation

WW.name = "WizardsWardrobe"
WW.simpleName = "Wizard's Wardrobe"
WW.displayName =
"|c18bed8W|c26c2d1i|c35c6c9z|c43cac2a|c52cebar|c60d1b3d|c6fd5ab'|c7dd9a4s|c8cdd9d |c9ae195W|ca8e58ea|cb7e986r|cc5ed7fd|cd4f077r|ce2f470o|cf1f868b|cfffc61e|r"
WW.version = "1.21.0"
WW.zones = {}
WW.currentIndex = 0
WW.IsHeavyAttacking = false
local async = LibAsync
local cancelAnimation = false
local cpCooldown = 0
local wipeChangeCooldown = false
local bossLastName = "WW"
local blockTrash = nil
local logger = LibDebugLogger( WW.name )
WW.callbackManager = ZO_CallbackObject:New()



function WW.GetSetupsAmount()
	local count = 0
	for _ in pairs( WW.setups[ WW.selection.zone.tag ][ WW.selection.pageId ] ) do
		count = count + 1
	end
	return count
end

function WW.LoadSetupAdjacent( direct, skipValidation )
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	local newSetupId = WW.currentIndex + direct
	if newSetupId > WW.GetSetupsAmount() then newSetupId = 1 end
	if newSetupId < 1 then newSetupId = WW.GetSetupsAmount() end
	WW.LoadSetup( zone, pageId, newSetupId, false, skipValidation )
end

function WW.IsReadyToSwap()
	return not IsUnitInCombat( "player" ) and not IsUnitDeadOrReincarnating( "player" )
end

local setupTask = async:Create( WW.name .. "SetupTask" )
local validationTask = async:Create( WW.name .. "ValidationTask" )
function WW.LoadSetup( zone, pageId, index, auto, skipValidation )
	if not zone or not pageId or not index then
		return false
	end
	if skipValidation == nil then skipValidation = false end
	local setup = Setup:FromStorage( zone.tag, pageId, index )

	logger:Info( "LoadSetup " .. setup:GetName() )

	if setup:IsEmpty() then
		if not auto then
			WW.Log( GetString( WW_MSG_EMPTYSETUP ), WW.LOGTYPES.INFO )
		end
		return false
	end
	for i = 1, #WW.gui.setupTable do
		local control = WW.gui.GetSetupControl( i )
		control.highlight:SetHidden( i ~= index )
	end

	local areAllItemsInInventory = false
	local isChangingWeapons = false
	setupTask:Call( function()
		local pageName = WW.pages[ zone.tag ][ pageId ].name
		WW.gui.SetPanelText( zone.tag, pageName, setup:GetName() )
		local logMessage = WW.IsReadyToSwap() and GetString( WW_MSG_LOADSETUP ) or GetString( WW_MSG_LOADINFIGHT )
		local logColor = WW.IsReadyToSwap() and WW.LOGTYPES.NORMAL or WW.LOGTYPES.INFO

		WW.Log( logMessage, logColor, "FFFFFF", setup:GetName(), zone.name )

		setupTask:WaitUntil( function()
			return WW.IsReadyToSwap()
		end )

		if WW.settings.auto.gear then
			_, areAllItemsInInventory, isChangingWeapons = WW.LoadGear( setup )
		end
		if areAllItemsInInventory then
			logger:Warn( "73 - All items in inventory" )
		else
			logger:Warn( "75 - Not all items in inventory" )
		end
	end ):Then( function()
		if WW.settings.auto.skills then
			WW.LoadSkills( setup )
		end
	end ):Then( function()
		if WW.settings.auto.cp then
			WW.LoadCP( setup )
		end
	end ):Then( function()
		if WW.settings.auto.food then WW.EatFood( setup ) end
	end ):Then( function()
		setup:ExecuteCode( setup, zone, pageId, index, auto )
		WW.currentIndex = index
		--WWV.SetupFailWorkaround( setup:GetName() ) -- Wait until something actually swapped before doing the workaround
	end ):Then( function()
		if areAllItemsInInventory then
			WWV.SetupFailWorkaround( setup:GetName(), skipValidation, isChangingWeapons )
		end
	end )

	return true
end

function WW.LoadSetupCurrent( index, auto )
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	local DO_NOT_SKIP_VALIDATION = false
	WW.LoadSetup( zone, pageId, index, auto, DO_NOT_SKIP_VALIDATION )
end

function WW.LoadSetupSubstitute( index )
	if not WW.zones[ "SUB" ] or not WW.pages[ "SUB" ] then return end
	local DO_NOT_SKIP_VALIDATION = false
	WW.LoadSetup( WW.zones[ "SUB" ], WW.pages[ "SUB" ][ 0 ].selected, index, true, DO_NOT_SKIP_VALIDATION )
end

function WW.SaveSetup( zone, pageId, index, skip )
	local setup = Setup:FromStorage( zone.tag, pageId, index )

	if not skip and not setup:IsEmpty() and WW.settings.overwriteWarning then
		WW.gui.ShowConfirmationDialog( "OverwriteConfirmation",
			string.format( GetString( WW_OVERWRITESETUP_WARNING ), setup:GetName() ),
			function()
				WW.SaveSetup( zone, pageId, index, true )
			end )
		return
	end

	if WW.settings.auto.gear then WW.SaveGear( setup ) end
	if WW.settings.auto.skills then WW.SaveSkills( setup ) end
	if WW.settings.auto.cp then WW.SaveCP( setup ) end
	if WW.settings.auto.food then WW.SaveFood( setup ) end

	setup:ToStorage( zone.tag, pageId, index )

	WW.gui.RefreshSetup( WW.gui.GetSetupControl( index ), setup )

	WW.Log( GetString( WW_MSG_SAVESETUP ), WW.LOGTYPES.NORMAL, "FFFFFF", setup:GetName() )
end

function WW.DuplicateSetup( zone, pageId, index )
	local setup = Setup:FromStorage( zone.tag, pageId, index )
	local setupName = setup:GetName()
	local newIndex = index + 1

	table.insert(WW.setups[ zone.tag ][ pageId ], newIndex, ZO_DeepTableCopy( setup ))
	WW.setups[ zone.tag ][ pageId ][ newIndex ].name = string.format( GetString( WW_DUPLICATE_NAME ), setupName )
	
	WW.markers.BuildGearList()
	WW.gui.BuildPage( zone, pageId )
end

function WW.DeleteSetup( zone, pageId, index )
	local setup = Setup:FromStorage( zone.tag, pageId, index )
	local setupName = setup:GetName()

	if WW.setups[ zone.tag ]
		and WW.setups[ zone.tag ][ pageId ]
		and WW.setups[ zone.tag ][ pageId ][ index ] then
		table.remove( WW.setups[ zone.tag ][ pageId ], index )
	end

	WW.markers.BuildGearList()
	WW.conditions.LoadConditions()

	if zone.tag == WW.selection.zone.tag
		and pageId == WW.selection.pageId then
		WW.gui.BuildPage( zone, pageId )
	end

	WW.Log( GetString( WW_MSG_DELETESETUP ), WW.LOGTYPES.NORMAL, "FFFFFF", setupName )
end

function WW.ClearSetup( zone, pageId, index )
	local setup = Setup:FromStorage( zone.tag, pageId, index )
	local setupName = setup:GetName()

	setup:Clear()
	setup:SetName( setupName )
	setup:ToStorage( zone.tag, pageId, index )

	WW.markers.BuildGearList()
	WW.conditions.LoadConditions()

	if zone.tag == WW.selection.zone.tag
		and pageId == WW.selection.pageId then
		WW.gui.BuildPage( zone, pageId )
	end

	WW.Log( GetString( WW_MSG_DELETESETUP ), WW.LOGTYPES.NORMAL, "FFFFFF", setupName )
end

function WW.HasCryptCanon()
	local cryptCanonAbilityId = 195031
	local cryptCanonItemId = 194509
	local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar( 1 )
	local slotData = hotbarData:GetSlotData( 8 )
	local itemId = GetItemId( BAG_WORN, EQUIP_SLOT_CHEST )
	return (slotData.abilityId == cryptCanonAbilityId or itemId == cryptCanonItemId)
end

local skillTask = async:Create( WW.name .. "SkillTask" )
function WW.LoadSkills( setup )
	logger:Debug( "LoadSkills" )
	local movedCryptCanon = false
	--skillTask:Cancel()
	local skillTable = setup:GetSkills()
	local gearTable = setup:GetGear()
	skillTask:For( 0, 1 ):Do( function( hotbarCategory )
		skillTask:For( 3, 8 ):Do( function( slotIndex )
			local abilityId = skillTable[ hotbarCategory ][ slotIndex ]
			if not WW.settings.unequipEmpty and (abilityId == 0 or abilityId == nil) then
				return false
			end
			if not WW.settings.unequipEmpty then
				if (abilityId == 0 or abilityId == nil) then
					logger:Debug( "SlotSkill %d %d %d - no skill", hotbarCategory, slotIndex, abilityId )
					return false
				end
			end
			logger:Debug( "SlotSkill %s %s %s (%s)", tostring( hotbarCategory ), tostring( slotIndex ), tostring( abilityId ),
				GetAbilityName( abilityId ) )


			skillTask:WaitUntil( function()
				return WW.IsReadyToSwap()
			end ):Then( function()
				-- check if cryptcanon gets changed
				if slotIndex == 8 and WW.HasCryptCanon() and gearTable[ EQUIP_SLOT_CHEST ].id == 194509 and not movedCryptCanon then
					logger:Debug( "Unequip cryptcanon" )
					local equippedLink = GetItemLink( BAG_WORN, EQUIP_SLOT_CHEST, LINK_STYLE_DEFAULT )


					local slot = FindFirstEmptySlotInBag( BAG_BACKPACK )

					-- unequip cryptcanon to slot ultimate (ultimate passives still work even with cryptcanon)
					if GetItemLinkItemId( equippedLink ) == 194509 then
						CallSecureProtected( "RequestMoveItem", BAG_WORN, EQUIP_SLOT_CHEST, BAG_BACKPACK, slot, 1 )
						logger:Debug( "Unequipped cryptcanon" )
						movedCryptCanon = true
					end


					skillTask:WaitUntil( function()
						return not WW.HasCryptCanon()
					end )
				end

				if abilityId == 38989 or abilityId == 38985 or abilityId == 38993 then
					abilityId = 38984
				end

				WW.SlotSkill( hotbarCategory, slotIndex, abilityId )
			end )
		end )
	end ):Then( function()
		local savedLink
		local doesSetupHaveCryptCanon = false
		if setup:GetGearInSlot( EQUIP_SLOT_CHEST ) then
			savedLink = setup:GetGearInSlot( EQUIP_SLOT_CHEST ).link
			doesSetupHaveCryptCanon = GetItemLinkItemId( savedLink ) == 194509
		end
		if movedCryptCanon and doesSetupHaveCryptCanon then
			-- equip cryptcanon once again if it was equipped and is in the current setup
			local cryptCanonLocation = WW.GetItemLocation()[ setup:GetGearInSlot( EQUIP_SLOT_CHEST ).id ]

			CallSecureProtected( "RequestMoveItem", BAG_BACKPACK, cryptCanonLocation.slot, BAG_WORN, EQUIP_SLOT_CHEST, 1 )
			logger:Debug( "Re-equipped cryptcanon" )
		end
	end )
	--WWV.SetupFailWorkaround()
	WW.prebuff.cache = {}
	return true
end

function WW.SlotSkill( hotbarCategory, slotIndex, abilityId )
	local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar( hotbarCategory )
	logger:Verbose( "SlotSkill %s %s %s (%s) ", tostring( hotbarCategory ), tostring( slotIndex ), tostring( abilityId ), GetAbilityName( abilityId ) )
	-- if using cryptcanon dont slot skill, since cryptcanon does it on its own
	--if not abilityId then return end
	if abilityId == 195031 then
		return
	end
	if WW.HasCryptCanon() and slotIndex == 8 then
		return
	end
	if WW.settings.unequipEmpty and (abilityId == 0 or abilityId == nil) then
		hotbarData:ClearSlot( slotIndex )
		return
	end
	if abilityId and abilityId > 0 then
		local progressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId( abilityId )
		if not progressionData then 		
			WW.Log( zo_strformat( "Scribed Skill not switched, Please save scribed skills new to Wizzards!! <<C:1>>", abilityId ), WW.LOGTYPES.ERROR, "FFFFFF", abilityId )
			return false
		end
		if progressionData:GetSkillData()
			and progressionData:GetSkillData():IsPurchased() then
			hotbarData:AssignSkillToSlotByAbilityId( slotIndex, abilityId )
			return true
		else
			local abilityName = zo_strformat( "<<C:1>>", progressionData:GetName() )
			WW.Log( GetString( WW_MSG_SKILLENOENT ), WW.LOGTYPES.ERROR, "FFFFFF", abilityName )
			return false
		end
	else
		hotbarData:ClearSlot( slotIndex )
		return true
	end
end

function WW.SaveSkills( setup )
	local skillTable = {}

	for hotbarCategory = 0, 1 do
		skillTable[ hotbarCategory ] = {}
		for slotIndex = 3, 8 do
			local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar( hotbarCategory )
			local slotData = hotbarData:GetSlotData( slotIndex )
			local abilityId = 0
			-- Cant save cryptcanons special ult.
			if slotData.abilityId == 195031 then
				abilityId = slotData.abilityId
			elseif
				not slotData:IsEmpty() then -- check if there is even a spell
				if abilityId == 39012 or abilityId == 39018 or abilityId == 39028 then
					abilityId = 39011
				end
				abilityId = slotData:GetEffectiveAbilityId()
			end

			skillTable[ hotbarCategory ][ slotIndex ] = abilityId
		end
	end

	setup:SetSkills( skillTable )
	--end
end

function WW.AreSkillsEqual( abilityId1, abilityId2 ) -- gets base abilityIds first, then compares
	if abilityId1 == abilityId2 then return true end

	local baseMorphAbilityId1 = WW.GetBaseAbilityId( abilityId1 )
	if not baseMorphAbilityId1 then return end

	local baseMorphAbilityId2 = WW.GetBaseAbilityId( abilityId2 )
	if not baseMorphAbilityId2 then return end

	if baseMorphAbilityId1 == baseMorphAbilityId2 then
		return true
	end
	return false
end

function WW.GetBaseAbilityId( abilityId )
	if abilityId == 0 then return 0 end
	local playerSkillProgressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId( abilityId )
	if not playerSkillProgressionData then
		return nil
	end
	local apiVersion = GetAPIVersion()
	if apiVersion >= 101042 then
		if playerSkillProgressionData:GetSkillData():IsCraftedAbility() then
			return abilityId
		end
	end
	local baseMorphData = playerSkillProgressionData:GetSkillData():GetMorphData( MORPH_SLOT_BASE )
	return baseMorphData:GetAbilityId()
end

local runningGearTasks = {}
local gearMoveTask = async:Create( WW.name .. "GearMoveTask" )

local function updateItemLocation( index, item, freeSlotMap )
	if not item.destSlot then
		item.destSlot = freeSlotMap[ index ]
	end

	if not item.sourceSlot or item.workaround then
		local newLocation = WW.GetItemLocation()[ item.itemId ]
		if not newLocation then return end
		item.sourceBag = newLocation.bag
		item.sourceSlot = newLocation.slot
	end
end

local function moveItemToDestination( item )
	logger:Verbose( "moveItemToDestination" )
	if item.destBag == BAG_WORN then
		EquipItem( item.sourceBag, item.sourceSlot, item.destSlot )
	else
		local isSlotEmpty = GetItemId( item.destBag, item.destSlot ) == 0
		item.destSlot = isSlotEmpty and item.destSlot or FindFirstEmptySlotInBag( item.destBag )

		CallSecureProtected( "RequestMoveItem", item.sourceBag, item.sourceSlot, item.destBag, item.destSlot, 1 )
		if WW.IsMythic( item.sourceBag, item.sourceSlot ) then
			gearMoveTask:Suspend()


			gearMoveTask:WaitUntil( function()
				return not WW.HasMythic()
			end ):Then( function()
				gearMoveTask:Resume()
			end )
		end
	end
end

local isMovingItems = false
local itemTaskQueue = {}


function WW.MoveItems( itemTaskList, areAllItemsInInventory, isChangingWeapons )
	if isMovingItems then
		gearMoveTask:Cancel()
		logger:Info( "MoveItems: Queueing %d items, isChangingWeapons = %s", #itemTaskList, tostring( isChangingWeapons ) )
	else
		logger:Info( "MoveItems: Starting to move %d items (no queue), isChangingWeapons = %s", #itemTaskList,
			tostring( isChangingWeapons ) )
	end

	local timeStamp = GetTimeStamp()
	isMovingItems = true
	local hasBeenWarnedAboutBlocking = false
	local freeSlots = WW.GetFreeSlots( BAG_BACKPACK )
	gearMoveTask:WaitUntil( function()
		return WW.IsReadyToSwap()
	end )

	--[[ :WaitUntil( function()--!As soon as i figure out how to see if someone is heavy attacking this will be updated
		logger:Warn( "channeling heavy = " .. tostring( WW.IsHeavyAttacking ) )
		return not WW.IsHeavyAttacking
	end ) ]]:WaitUntil( function()
		if not hasBeenWarnedAboutBlocking and IsBlockActive() then
			hasBeenWarnedAboutBlocking = true
			WW.Log( "Loading setup on hold until block is dropped!", WW.LOGTYPES.CRITICAL )
		end
		return not IsBlockActive()
	end ):Call( function()
		for lineStyle, lineStyleTable in pairs( CENTER_SCREEN_ANNOUNCE.activeLines ) do
			for _, line in ipairs( lineStyleTable ) do
				if line.messageParams.mainText == "CRITICAL ERROR" then
					CENTER_SCREEN_ANNOUNCE:RemoveActiveLine( line )
				end
			end
		end
		if not ArePlayerWeaponsSheathed() and isChangingWeapons then
			TogglePlayerWield()
		end
	end ):WaitUntil( function()
		if GetTimeStamp() > timeStamp + 5000 and not ArePlayerWeaponsSheathed() and isChangingWeapons then
			TogglePlayerWield()
		end
		--? If the user is heavy attacking, the setup will not load, and the user will have to do it manually which is horrible but there is no way to fix it
		--? We cant event check if the user is heavy attacking, so we cant even warn the user about it
		--? The event is only a bandaid fix which isnt ideal but for now it works...........
		--! the above check is only performed if it bugs out and nothing happened after 5 seconds
		return ArePlayerWeaponsSheathed() or not isChangingWeapons
	end ):For( ipairs( itemTaskList ) ):Do( function( index, item )
		updateItemLocation( index, item, freeSlots )

		if not item.sourceSlot or not item.destSlot then return end

		gearMoveTask:WaitUntil( function()
			return WW.IsReadyToSwap()
		end ):WaitUntil( function()
			if not hasBeenWarnedAboutBlocking and IsBlockActive() then
				WW.Log( GetString( WW_MSG_BLOCK_WARN ), WW.LOGTYPES.ERROR )
				hasBeenWarnedAboutBlocking = true
			end
			-- show UI if blocked
			return not IsBlockActive()
		end ):Then( function()
			if not ArePlayerWeaponsSheathed() and isChangingWeapons then
				TogglePlayerWield()
			end
		end ):WaitUntil( function()
			return ArePlayerWeaponsSheathed() or not isChangingWeapons
		end ):Then( function()
			logger:Debug( "Trying to move %s from %d:%d to %d:%d (%s) [%d]",
				GetItemLink( item.sourceBag, item.sourceSlot, LINK_STYLE_DEFAULT ),
				item.sourceBag, item.sourceSlot,
				item.destBag,
				item.destSlot, GetString( "SI_EQUIPSLOT", item.sourceSlot ), #itemTaskList )
			moveItemToDestination( item )
			--[[ gearMoveTask:Delay( 500, function()
				gearMoveTask:Resume()
			end ) ]]
		end )
	end ):Then( function()
		if not areAllItemsInInventory then
			local zone = WW.selection.zone
			local pageId = WW.selection.pageId
			local index = WW.currentIndex

			local setup = Setup:FromStorage( zone.tag, pageId, index )
			WW.SetPanelText( setup:GetName(), "F96417", WW.WARNING.INVENTORY )

			--[[ local warning = "|t100%:t100%:/esoui/art/crafting/crafting_provisioner_inventorycolumn_icon.dds:inheritColor|t"
			local middleText = string.format( "|c%s%s%s|r", "F96417",
				setup:GetName(), warning )

			WizardsWardrobePanelBottomLabel:SetText( middleText ) ]]
		end
		isMovingItems = false

		if #itemTaskQueue > 0 then                  -- if there are tasks in the queue
			WW.MoveItems( table.remove( itemTaskQueue, 1 ) ) -- start the next task
		end
	end )
end

function WW.IsGearInInventory( itemTaskList )
	for _, item in ipairs( itemTaskList ) do
		if item.sourceBag ~= BAG_BACKPACK then
			return false
		end
	end
	return true
end

function WW.LoadGear( setup )
	if GetNumBagFreeSlots( BAG_BACKPACK ) == 0 then
		WW.Log( GetString( WW_MSG_FULLINV ), WW.LOGTYPES.INFO )
	end
	logger:Warn( "LoadGear " .. setup:GetName() )
	local freeSlotMap = WW.GetFreeSlots( BAG_BACKPACK )
	local itemTaskList = {}
	local inventoryList = WW.GetItemLocation()
	local areAllItemsInInventory = true
	local isChangingWeapons = false
	-- unequip mythic if needed
	local mythicDelay = 0
	if setup:GetMythic() then
		local mythicSlot = WW.HasMythic()
		local mythicId = Id64ToString( GetItemUniqueId( BAG_WORN, mythicSlot ) )
		local _, gear = setup:GetMythic()
		if mythicSlot and mythicId ~= gear.id then
			mythicDelay = 500
			table.insert( itemTaskList, {
				sourceBag = BAG_WORN,
				sourceSlot = mythicSlot,
				destBag = BAG_BACKPACK,
				destSlot = nil,
				itemId = mythicId,
			} )
		end
	end

	for index, gearSlot in ipairs( WW.GEARSLOTS ) do
		local gear = setup:GetGearInSlot( gearSlot )

		if gear then
			local lookupId = Id64ToString( GetItemUniqueId( BAG_WORN, gearSlot ) )
			if gearSlot == EQUIP_SLOT_POISON or gearSlot == EQUIP_SLOT_BACKUP_POISON then
				-- handle poisons
				local lookupLink = GetItemLink( BAG_WORN, gearSlot, LINK_STYLE_DEFAULT )
				if lookupLink ~= gear.link then
					WW.poison.EquipPoisons( gear.link, gearSlot )
				end
			else
				-- equip item (if not already equipped)


				if lookupId ~= gear.id then
					if inventoryList[ gear.id ] then
						local bag, slot = inventoryList[ gear.id ].bag, inventoryList[ gear.id ].slot

						local delay = WW.IsMythic( bag, slot ) and mythicDelay or 0
						local workaround = gearSlot == EQUIP_SLOT_BACKUP_MAIN and slot == EQUIP_SLOT_MAIN_HAND
						if workaround then
							-- Front to back
							-- Be sure to give enough time so backbar can find new location
							delay = delay + 500
						end

						if gearSlot == EQUIP_SLOT_MAIN_HAND or gearSlot == EQUIP_SLOT_OFF_HAND or gearSlot == EQUIP_SLOT_BACKUP_MAIN or gearSlot == EQUIP_SLOT_BACKUP_OFF then
							--Check if weapons are being changed, if not dont sheath weapons


							local newWeapon = Id64ToString( GetItemUniqueId( inventoryList[ gear.id ].bag,
								inventoryList[ gear.id ].slot ) )

							if lookupId ~= newWeapon and not isChangingWeapons then
								logger:Info( "Changing weapons: equippedWeapon = %s, newWeapon = %s",
									GetItemLink( BAG_WORN, gearSlot ),
									GetItemLink( inventoryList[ gear.id ].bag, inventoryList[ gear.id ].slot ) )
								isChangingWeapons = true
							end
						end
						table.insert( itemTaskList, {
							sourceBag = bag,
							sourceSlot = slot,
							destBag = BAG_WORN,
							destSlot = gearSlot,
							delay = delay,
							itemId = gear.id,
							workaround = workaround,
						} )
					else
						areAllItemsInInventory = false
						WW.Log( GetString( WW_MSG_GEARENOENT ), WW.LOGTYPES.ERROR, nil,
							WW.ChangeItemLinkStyle( gear.link, LINK_STYLE_BRACKETS ) )
					end
				end
			end
		else
			-- unequip if option is set to true, but ignore tabards if set to do so
			if WW.settings.unequipEmpty and (gearSlot ~= EQUIP_SLOT_COSTUME or ((gearSlot == EQUIP_SLOT_COSTUME) and WW.settings.ignoreTabards == false)) then
				table.insert( itemTaskList, {
					sourceBag = BAG_WORN,
					sourceSlot = gearSlot,
					destBag = BAG_BACKPACK,
					destSlot = nil,
				} )
			end
		end
	end

	if areAllItemsInInventory then
		logger:Warn( "All items in inventory" )
	else
		logger:Warn( "Not all items in inventory" )
	end

	WW.MoveItems( itemTaskList, areAllItemsInInventory, isChangingWeapons )
	return true, areAllItemsInInventory, isChangingWeapons
	--end
end

function WW.GetFreeSlots( bag )
	local freeSlotMap = {}
	for slot in ZO_IterateBagSlots( bag ) do
		local itemId = GetItemId( bag, slot )
		if itemId == 0 then
			table.insert( freeSlotMap, slot )
		end
	end
	return freeSlotMap
end

function WW.HasMythic()
	for _, gearSlot in ipairs( WW.GEARSLOTS ) do
		if WW.IsMythic( BAG_WORN, gearSlot ) then
			return gearSlot
		end
	end
	return nil
end

function WW.Undress( itemTaskList )
	if GetNumBagFreeSlots( BAG_BACKPACK ) == 0 then
		WW.Log( GetString( WW_MSG_FULLINV ), WW.LOGTYPES.INFO )
	end

	if not itemTaskList or type( itemTaskList ) ~= "table" then
		local freeSlotMap = WW.GetFreeSlots( BAG_BACKPACK )
		itemTaskList = {}
		for _, gearSlot in ipairs( WW.GEARSLOTS ) do
			local _, stack = GetItemInfo( BAG_WORN, gearSlot )
			if stack > 0 then
				table.insert( itemTaskList, {
					sourceBag = BAG_WORN,
					sourceSlot = gearSlot,
					destBag = BAG_BACKPACK,
					destSlot = table.remove( freeSlotMap ),
					f = "m",
				} )
			end
		end
	end

	WW.MoveItems( itemTaskList, true )
end

function WW.SaveGear( setup )
	local gearTable = { mythic = nil }
	for _, gearSlot in ipairs( WW.GEARSLOTS ) do
		gearTable[ gearSlot ] = {
			id = Id64ToString( GetItemUniqueId( BAG_WORN, gearSlot ) ),
			link = GetItemLink( BAG_WORN, gearSlot, LINK_STYLE_DEFAULT ),
		}
		if WW.IsMythic( BAG_WORN, gearSlot ) then
			gearTable.mythic = gearSlot
		end
		if GetItemLinkItemType( gearTable[ gearSlot ].link ) == ITEMTYPE_TABARD then
			gearTable[ gearSlot ].creator = GetItemCreatorName( BAG_WORN, gearSlot )
		end
	end
	setup:SetGear( gearTable )
end

local cpTask = async:Create( WW.name .. "CPTask" )
function WW.LoadCP( setup )
	cpTask:Cancel()
	local MAX_CHAMPION_SLOTTABLES = 12
	if #setup:GetCP() == 0 then
		return
	end

	if WW.CompareCP( setup ) then
		return
	end
	cpTask:WaitUntil( function() return WW.IsReadyToSwap() end ):Then( function()
		if cpCooldown > 0 then
			WW.Log( GetString( WW_MSG_CPCOOLDOWN ), WW.LOGTYPES.INFO, WW.LOGTYPES.INFO, tostring( cpCooldown ) )
			EVENT_MANAGER:RegisterForEvent( WW.name .. "CPCooldownWarning", EVENT_CHAMPION_PURCHASE_RESULT,
				function( _, result )
					if result == CHAMPION_PURCHASE_SUCCESS then
						WW.Log( GetString( WW_MSG_CPCOOLDOWNOVER ), WW.LOGTYPES.INFO )
						EVENT_MANAGER:UnregisterForEvent( WW.name .. "CPCooldownWarning", EVENT_CHAMPION_PURCHASE_RESULT )
					end
				end )
		end
		cpTask:WaitUntil( function()
			logger:Verbose( "cooldown = %d", cpCooldown )
			return
				cpCooldown == 0
		end )
	end ):Then( function()
		-- fixes animation call with nil
		if CHAMPION_PERKS_SCENE:GetState() == "shown" then
			CHAMPION_PERKS:PrepareStarConfirmAnimation()
			cancelAnimation = false
		else
			cancelAnimation = true
		end
		PrepareChampionPurchaseRequest()
		cpTask:For( 1, MAX_CHAMPION_SLOTTABLES ):Do( function( slotIndex )
			local starId = setup:GetCP()[ slotIndex ]
			if starId and starId > 0 then
				if CanChampionSkillTypeBeSlotted(GetChampionSkillType(starId)) then
					local skillPoints = GetNumPointsSpentOnChampionSkill( starId )
					if skillPoints > 0 then									
							AddHotbarSlotToChampionPurchaseRequest( slotIndex, starId )
					else
						WW.Log( GetString( WW_MSG_CPENOENT ), WW.LOGTYPES.ERROR, WW.CPCOLOR[ slotIndex ],
							zo_strformat( "<<C:1>>", GetChampionSkillName( starId ) ) )
					end
				else
					WW.Log( GetString( WW_MSG_CPNOTSLOTTABLEINFO ), WW.LOGTYPES.INFO, WW.CPCOLOR[ slotIndex ],
						zo_strformat( "<<C:1>>", GetChampionSkillName( starId ) ) )
				end
			else
				if WW.settings.unequipEmpty then
					AddHotbarSlotToChampionPurchaseRequest( slotIndex, 0 )
				end
			end
		end ):Then( function()
			SendChampionPurchaseRequest()
		end )
	end )
end

function WW.SaveCP( setup )
	local cpTable = {}
	for slotIndex = 1, 12 do
		cpTable[ slotIndex ] = WW.GetSlotBoundAbilityId( slotIndex, HOTBAR_CATEGORY_CHAMPION )
	end
	setup:SetCP( cpTable )
end

function WW.UpdateCPCooldown()
	if cpCooldown > 0 then
		cpCooldown = cpCooldown - 1
		return
	end
	cpCooldown = 0
	EVENT_MANAGER:UnregisterForUpdate( WW.name .. "CPCooldownLoop" )
end

local foodTask = async:Create( WW.name .. "FoodTask" )
function WW.EatFood( setup )
	foodTask:Cancel()
	local savedFood = setup:GetFood()
	if not savedFood.id then return end

	local currentFood = WW.HasFoodRunning()
	if WW.BUFFFOOD[ savedFood.id ] == currentFood then
		-- same bufffood, dont renew it
		return
	end

	local foodChoice = WW.lookupBuffFood[ WW.BUFFFOOD[ savedFood.id ] ]

	foodTask:Call( function()
		foodTask:WaitUntil( function() return WW.IsReadyToSwap() end ):Then( function()
			local foodIndex = WW.FindFood( foodChoice )

			logger:Info( CanInteractWithItem( BAG_BACKPACK, foodIndex ) )
			if not foodIndex then
				WW.Log( GetString( WW_MSG_FOODENOENT ), WW.LOGTYPES.ERROR )
				return
			end
			foodTask:WaitUntil( function()
				return GetItemCooldownInfo( BAG_BACKPACK, foodIndex ) <= 0
			end ):Then( function()
				CallSecureProtected( "UseItem", BAG_BACKPACK, foodIndex )
				if not WW.HasFoodIdRunning( savedFood.id ) then
					zo_callLater( function() WW.EatFood( setup ) end, 1000 )
				end
			end )
		end )
	end )
	-- check if eaten
	-- API cannot track sprinting
end

function WW.SaveFood( setup, foodIndex )
	if not foodIndex then
		local currentFood = WW.HasFoodRunning()
		local foodChoice = WW.lookupBuffFood[ currentFood ]
		foodIndex = WW.FindFood( foodChoice )
		if not foodIndex then
			WW.Log( GetString( WW_MSG_NOFOODRUNNING ), WW.LOGTYPES.INFO )
			return
		end
	end

	local foodLink = GetItemLink( BAG_BACKPACK, foodIndex, LINK_STYLE_DEFAULT )
	local foodId = GetItemLinkItemId( foodLink )

	setup:SetFood( {
		link = foodLink,
		id = foodId,
	} )
end

function WW.SetupIterator()
	local setupList = {}
	for _, zone in ipairs( WW.gui.GetSortedZoneList() ) do
		if WW.setups[ zone.tag ] then
			for pageId, _ in ipairs( WW.setups[ zone.tag ] ) do
				if WW.setups[ zone.tag ][ pageId ] then
					for index, setup in ipairs( WW.setups[ zone.tag ][ pageId ] ) do
						if setup then
							table.insert( setupList, { zone = zone, pageId = pageId, index = index, setup = setup } )
						end
					end
				end
			end
		end
	end

	local i = 0
	return function()
		i = i + 1
		return setupList[ i ]
	end
end

function WW.PageIterator( zone, pageId )
	local setupList = {}
	if WW.setups[ zone.tag ] and WW.setups[ zone.tag ][ pageId ] then
		for index, setup in ipairs( WW.setups[ zone.tag ][ pageId ] ) do
			if setup then
				table.insert( setupList, { zone = zone, pageId = pageId, index = index, setup = setup } )
			end
		end
	end

	local i = 0
	return function()
		i = i + 1
		return setupList[ i ]
	end
end

function WW.CancelAllTasks()
	foodTask:Cancel()
	cpTask:Cancel()
	gearMoveTask:Cancel()
	WW.validation.validationTask:Cancel()
end

function WW.OnBossChange( _, isBoss, manualBossName )
	if IsUnitInCombat( "player" ) and not manualBossName then
		return
	end

	if WasRaidSuccessful() then
		return
	end

	local bossName = GetUnitName( "boss1" )
	local sideBoss = GetUnitName( "boss2" )

	if manualBossName then
		bossName = manualBossName
	end

	if bossName == GetString( WW_TRASH ) then
		bossName = ""
	end

	if #bossName == 0 and #sideBoss > 0 then
		bossName = sideBoss
	end

	if blockTrash and #bossName == 0 then
		--d("Trash is being blocked.")
		return
	end

	if #bossName > 0 and not IsUnitInCombat( "player" ) then
		--d("Changed to boss. Block trash for 6s.")
		if blockTrash then
			--d("Boss detected. Remove trash blockade. #" .. bossName)
			zo_removeCallLater( blockTrash )
			blockTrash = nil
		end
		--d("New trash blockade.")
		blockTrash = zo_callLater( function()
			--d("Trash blockade over.")
			blockTrash = nil
			--WW.OnBossChange(_, true, manualBossName)
			WW.OnBossChange( _, true, nil )
		end, 6000 )
	end

	if bossName == bossLastName then
		return
	end

	if wipeChangeCooldown or WW.IsWipe() then
		return
	end

	--d("BOSS: " .. bossName)

	bossLastName = bossName
	zo_callLater( function()
		WW.currentZone.OnBossChange( bossName )
	end, 500 )
end

function WW.OnZoneChange( _, _ )
	local isFirstZoneAfterReload = (WW.currentZoneId == 0)
	local zone, x, y, z = GetUnitWorldPosition( "player" )
	if zone == WW.currentZoneId then
		-- no zone change
		return
	end
	WW.currentZoneId = zone

	-- reset old zone
	WW.currentZone.Reset()
	WW.conditions.ResetCache()

	if WW.lookupZones[ zone ] then
		WW.currentZone = WW.lookupZones[ zone ]
	else
		WW.currentZone = WW.zones[ "GEN" ]
	end

	bossLastName = "WW"

	zo_callLater( function()
		-- init new zone
		WW.currentZone.Init()

		-- only swap according to user settings
		local shouldSelectInstance = WW.settings.autoSelectInstance and WW.currentZone.tag ~= "GEN"
		local shouldSelectGeneral = WW.settings.autoSelectGeneral and WW.currentZone.tag == "GEN"
		local shouldSelectCurrent = shouldSelectInstance or shouldSelectGeneral
		if isFirstZoneAfterReload then
			if shouldSelectCurrent then
				WW.gui.OnZoneSelect(WW.currentZone)
			else
				-- select the last selected zone before reload
				WW.gui.OnZoneSelect(WW.zones[WW.storage.selectedZoneTag])
			end
		elseif shouldSelectCurrent then
			WW.gui.OnZoneSelect(WW.currentZone)
		end

		if WW.settings.fixes.surfingWeapons then
			WW.fixes.FixSurfingWeapons()
		end

		if WW.settings.autoEquipSetups
			and not isFirstZoneAfterReload
			and WW.currentZone.tag ~= "PVP" then
			-- equip first setup
			local firstSetupName = WW.currentZone.bosses[ 1 ]
			if firstSetupName then
				WW.OnBossChange( _, false, firstSetupName.name )
			end
		end
	end, 250 )
end

function WW.RegisterEvents()
	EVENT_MANAGER:UnregisterForEvent( WW.name, EVENT_ADD_ON_LOADED )



	-- repair cp animation
	ZO_PreHook( CHAMPION_PERKS, "StartStarConfirmAnimation", function()
		if cancelAnimation then
			cancelAnimation = false
			return true
		end
	end )

	-- cp cooldown
	EVENT_MANAGER:RegisterForEvent( WW.name, EVENT_CHAMPION_PURCHASE_RESULT, function( _, result )
		if result == CHAMPION_PURCHASE_SUCCESS then
			cpCooldown = 31
			EVENT_MANAGER:RegisterForUpdate( WW.name .. "CPCooldownLoop", 1000, WW.UpdateCPCooldown )
		end
	end )

	-- check for wipe
	EVENT_MANAGER:RegisterForEvent( WW.name, EVENT_UNIT_DEATH_STATE_CHANGED, function( eventCode, unitTag, isDead )
		if not isDead then return end
		if not IsUnitGrouped( "player" ) and unitTag ~= "player" then return end
		if IsUnitGrouped( "player" ) and unitTag:sub( 1, 1 ) ~= "g" then return end

		if not wipeChangeCooldown and WW.IsWipe() then
			wipeChangeCooldown = true
			zo_callLater( function()
				wipeChangeCooldown = false
			end, 15000 )
		end
	end )

	EVENT_MANAGER:RegisterForEvent( WW.name, EVENT_PLAYER_ACTIVATED, WW.OnZoneChange )
	EVENT_MANAGER:RegisterForEvent( WW.name, EVENT_BOSSES_CHANGED, WW.OnBossChange )
end

function WW.Init()
	WW.lookupZones = {}
	for _, zone in pairs( WW.zones ) do
		zone.lookupBosses = {}
		for i, boss in ipairs( zone.bosses ) do
			zone.lookupBosses[ boss.name ] = i
		end

		-- support multiple zones per entry
		if type( zone.id ) == "table" then
			for zoneId in pairs( zone.id ) do
				WW.lookupZones[ zoneId ] = zone
			end
		else
			WW.lookupZones[ zone.id ] = zone
		end
	end

	WW.lookupBuffFood = {}
	for itemId, abilityId in pairs( WW.BUFFFOOD ) do
		if not WW.lookupBuffFood[ abilityId ] then
			WW.lookupBuffFood[ abilityId ] = {}
		end
		table.insert( WW.lookupBuffFood[ abilityId ], itemId )
	end

	for i, trait in ipairs( WW.TRAITS ) do
		local char = tostring( WW.PREVIEW.CHARACTERS[ i ] )
		WW.PREVIEW.TRAITS[ trait ] = char
		WW.PREVIEW.TRAITS[ char ] = trait
	end

	local bufffoodCache = {}
	for food, _ in pairs( WW.BUFFFOOD ) do
		table.insert( bufffoodCache, food )
	end
	table.sort( bufffoodCache )
	for i, food in ipairs( bufffoodCache ) do
		local char = tostring( WW.PREVIEW.CHARACTERS[ i ] )
		WW.PREVIEW.FOOD[ food ] = char
		WW.PREVIEW.FOOD[ char ] = food
	end

	WW.currentZone = WW.zones[ "GEN" ]
	WW.currentZoneId = 0

	WW.selection = {
		zone = WW.zones[ "GEN" ],
		pageId = 1
	}
end

function WW.OnAddOnLoaded( _, addonName )
	if addonName ~= WW.name then return end

	-- Refactor this
	WW.Init()
	WW.menu.Init()
	--WW.queue.Init()
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
	WizardsWardrobeWindowVersion:SetText( "v" .. WW.version )
	WizardsWardrobeWindowTopMenuButtonsZoneSelect:SetHidden( WW.settings.legacyZoneSelection )
end

EVENT_MANAGER:RegisterForEvent( WW.name, EVENT_ADD_ON_LOADED, WW.OnAddOnLoaded )
