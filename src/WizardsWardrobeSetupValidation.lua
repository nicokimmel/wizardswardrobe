WizardsWardrobe               = WizardsWardrobe or {}
local WW                      = WizardsWardrobe
WW.validation                 = WW.validation or {}
local WWV                     = WW.validation
WW.name                       = "WizardsWardrobe"
WW.simpleName                 = "Wizard's Wardrobe"
WW.displayName                =
"|c18bed8W|c26c2d1i|c35c6c9z|c43cac2a|c52cebar|c60d1b3d|c6fd5ab'|c7dd9a4s|c8cdd9d |c9ae195W|ca8e58ea|cb7e986r|cc5ed7fd|cd4f077r|ce2f470o|cf1f868b|cfffc61e|r"

local logger                  = LibDebugLogger( WW.name )
local async                   = LibAsync
local validationTask          = async:Create( WW.name .. "Validation" )
local setupName               = ""
local validationDelay         = 1500
local WORKAROUND_INITIAL_CALL = 0
local WORKAROUND_ONE          = 1
local WORKAROUND_TWO          = 2
local WORKAROUND_THREE        = 3
local WORKAROUND_FOUR         = 4



function WWV.CompareItemLinks( linkEquipped, linkSaved, uniqueIdEquipped, uniqueIdSaved )
    local traitEquipped               = GetItemLinkTraitInfo( linkEquipped )
    local traitSaved                  = GetItemLinkTraitInfo( linkSaved )
    local weaponTypeEquipped          = GetItemLinkWeaponType( linkEquipped )
    local weaponTypeSaved             = GetItemLinkWeaponType( linkSaved )
    local _, _, _, _, _, setIdEquipped = GetItemLinkSetInfo( linkEquipped )
    local _, _, _, _, _, setIdSaved   = GetItemLinkSetInfo( linkSaved )

    if WW.settings.comparisonDepth == 1 then -- easy
        if traitEquipped ~= traitSaved or weaponTypeEquipped ~= weaponTypeSaved or setIdEquipped ~= setIdSaved then
            return false
        end
        return true
    end
    local qualityEquipped = GetItemLinkDisplayQuality( linkEquipped )
    local enchantEquipped = GetItemLinkEnchantInfo( linkEquipped )
    local qualitySaved = GetItemLinkDisplayQuality( linkSaved )
    local enchantSaved = GetItemLinkEnchantInfo( linkSaved )

    if WW.settings.comparisonDepth == 2 then -- detailed
        if (traitEquipped ~= traitSaved) or (weaponTypeEquipped ~= weaponTypeSaved) or (setIdEquipped ~= setIdSaved) or (qualityEquipped ~= qualitySaved) then
            return false
        end
        return true
    end


    if WW.settings.comparisonDepth == 3 then -- thorough
        if (traitEquipped ~= traitSaved) or (weaponTypeEquipped ~= weaponTypeSaved) or (setIdEquipped ~= setIdSaved) or (qualityEquipped ~= qualitySaved) or (enchantEquipped ~= enchantSaved) then
            return false
        end
        return true
    end

    if WW.settings.comparisonDepth == 4 then -- strict
        if uniqueIdEquipped ~= uniqueIdSaved then
            return false
        end
        return true
    end
end

--TODO: untangle this mess. should prob make a metamethod to compare setups instead of this
function WWV.DidSetupSwapCorrectly( workAround )
    local zone        = WW.selection.zone
    local tag         = zone.tag
    local pageId      = WW.selection.pageId
    local index       = WW.currentIndex
    local setupTable  = Setup:FromStorage( tag, pageId, index )
    local check       = nil
    local t           = {}
    local timeStamp   = GetTimeStamp()
    local inCombat    = IsUnitInCombat( "player" )
    local worldName   = GetWorldName()
    local characterId = GetCurrentCharacterId()
    local pageName    = zone.name
    local zoneName    = GetPlayerActiveZoneName()
    local isBlocking  = IsBlockActive()
    local subZone     = GetPlayerActiveSubzoneName()
    local failedT     = {}
    local db          = WW.settings
    local key         = GetWorldName() .. GetDisplayName() .. GetCurrentCharacterId() .. os.date( "%Y%m%d%H" ) .. index
    if not db.failedSwapLog then db.failedSwapLog = {} end
    db = db.failedSwapLog

    if setupTable and setupTable.gear then
        setupName = setupTable.name
        for _, equipSlot in pairs( WW.GEARSLOTS ) do
            if setupTable.gear[ equipSlot ] then
                local equippedLink = GetItemLink( BAG_WORN, equipSlot, LINK_STYLE_DEFAULT )
                local savedLink    = setupTable.gear[ equipSlot ].link
                local equippedUId  = Id64ToString( GetItemUniqueId( BAG_WORN, equipSlot ) )
                local savedUId     = setupTable.gear[ equipSlot ].id
                local success      = nil
                logger:Debug( " equipSlot: %s, %s // %s", GetString( "SI_EQUIPSLOT", equipSlot ), equippedLink, savedLink )
                if WWV.CompareItemLinks( equippedLink, savedLink, equippedUId, savedUId ) then
                    success = true
                else
                    success = false
                    failedT[ # failedT + 1 ] = GetString( "SI_EQUIPSLOT", equipSlot )
                    logger:Info( "Equipped %s // saved %s", equippedLink, savedLink )
                    if workAround > 0 then
                        if not db[ equipSlot ] then db[ equipSlot ] = {} end
                        --No need to log for each workaround, just log the last
                        EVENT_MANAGER:RegisterForUpdate( WW.name .. "Throttle" .. equipSlot, 5000, function()
                            if not db[ equipSlot ][ key ] then db[ equipSlot ][ key ] = {} end
                            db[ equipSlot ][ key ] = {
                                timeStamp    = timeStamp,
                                inCombat     = inCombat,
                                worldName    = worldName,
                                characterId  = characterId,
                                pageName     = pageName,
                                zone         = zoneName,
                                subzone      = subZone,
                                pageId       = pageId,
                                setupName    = setupName,
                                equippedLink = equippedLink,
                                savedLink    = savedLink,
                                settings     = {
                                    gear   = WW.settings.auto.gear,
                                    skills = WW.settings.auto.skills,
                                    cp     = WW.settings.auto.cp,
                                    food   = WW.settings.auto.food,
                                },
                                workAround   = workAround,
                                isBlocking   = isBlocking

                            }
                            EVENT_MANAGER:UnregisterForUpdate( WW.name .. "Throttle" .. equipSlot )
                        end )
                    end
                end
                t[ equipSlot ] = success
            end

            for eqSlot, success in pairs( t ) do
                if not success then
                    check = false
                    break
                else
                    check = true
                end
            end
        end
    end
    return check, failedT
end

local function failureFunction()
    validationTask:Cancel()
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "Throttle" )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "Throttle2" )
    EVENT_MANAGER:UnregisterForEvent( WW.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundOne" )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundTwo" )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundThree" )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundFour", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundTFour" )
    WW.Log( GetString( WW_MSG_SWAP_FIX_FAIL ), WW.LOGTYPES.ERROR )
end
local function successFunction()
    -- Cancel everything in case swap worked out sooner than expected to avoid having situations where some function gets called endlessly
    validationTask:Cancel()
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "Throttle" )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "Throttle2" )
    EVENT_MANAGER:UnregisterForEvent( WW.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundOne" )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundTwo" )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundThree" )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundFour", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundTFour" )
    WW.Log( GetString( WW_MSG_SWAPSUCCESS ), WW.LOGTYPES.NORMAL )
    local middleText = string.format( "|c%s%s|r", WW.LOGTYPES.NORMAL, setupName )
    WizardsWardrobePanelBottomLabel:SetText( middleText )
end


--[[ Last ditch effort, I have in all my testing never seen that anything other than weapons got stuck.
 So this should never happen, we still have it in case something odd is happening ]]

local function workaroundFour()
    logger:Info( "workaround four got called" )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundThree" )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )

    -- Redundancy in case everything is stuck and no event triggers. This will hopefully always be unregistered before it actually gets called
    EVENT_MANAGER:RegisterForUpdate( WW.name .. "Throttle2", 5000,
                                     function()
                                         failureFunction() -- If all swaps have failed.
                                     end )

    if not WWV.DidSetupSwapCorrectly( WORKAROUND_FOUR ) then
        validationTask:Call( function()
            WW.Undress()
        end ):WaitUntil( function() -- Wait until every worn item is in the bag
            local isNotEmpty = nil
            for _, equipSlot in pairs( WW.GEARSLOTS ) do
                if Id64ToString( GetItemUniqueId( BAG_WORN, equipSlot ) ) ~= "0" then
                    isNotEmpty = true
                elseif Id64ToString( GetItemUniqueId( BAG_WORN, equipSlot ) ) == "0" and not isNotEmpty then
                    isNotEmpty = false
                end
            end
            return not isNotEmpty
        end ):Then( function()
            WW.LoadSetupAdjacent( 0 ) -- reload current setup
        end ):Call( function()
            EVENT_MANAGER:RegisterForEvent( WW.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
                EVENT_MANAGER:RegisterForUpdate( WW.name .. "Throttle", validationDelay / 2, function()
                    if WWV.DidSetupSwapCorrectly( WORKAROUND_FOUR ) then
                        successFunction()
                    else
                        failureFunction()
                    end
                    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
                    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "Throttle" )
                end )
            end )
        end )
    else
        successFunction()
    end
end

-- Unequip weapons and reload setup
local function workaroundThree()
    logger:Info( "workaround three got called" )
    local t = {
        EQUIP_SLOT_MAIN_HAND,
        EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_BACKUP_MAIN,
        EQUIP_SLOT_BACKUP_OFF
    }


    Setup:GetData()
    local moveTask = async:Create( WW.name .. "Move" )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundTwo" )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:RegisterForEvent( WW.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                    function()
                                        moveTask:Resume() -- continue loop
                                        EVENT_MANAGER:RegisterForUpdate( WW.name .. "ThrottleWorkaroundThree",
                                                                         validationDelay / 2,
                                                                         function()
                                                                             workaroundFour()
                                                                         end )
                                    end )
    EVENT_MANAGER:AddFilterForEvent( WW.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_BAG_ID,
                                     BAG_WORN )

    EVENT_MANAGER:AddFilterForEvent( WW.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_INVENTORY_UPDATE_REASON,
                                     INVENTORY_UPDATE_REASON_DEFAULT )



    moveTask:Call( function()
        if not WWV.DidSetupSwapCorrectly( WORKAROUND_THREE ) then
            moveTask:For( 1, #t ):Do( function( index )
                local emptySlot = FindFirstEmptySlotInBag( BAG_BACKPACK )
                local equipSlot = t[ index ]
                local weaponType = GetItemWeaponType( BAG_WORN, equipSlot )
                local link = GetItemLink( BAG_WORN, equipSlot, LINK_STYLE_DEFAULT )

                if weaponType ~= WEAPONTYPE_NONE then
                    CallSecureProtected( "RequestMoveItem", BAG_WORN, equipSlot, BAG_BACKPACK, emptySlot, 1 )
                    moveTask:Suspend() -- Suspend loop until item has actually moved
                end
            end ):Then( function() WW.LoadSetupAdjacent( 0 ) end )
        else
            successFunction()
        end
    end )
    EVENT_MANAGER:RegisterForUpdate( WW.name .. "ThrottleWorkaroundThree", validationDelay, workaroundFour ) -- If no item moved, move on to workaround four
end

-- Reload setup
local function workaroundTwo()
    logger:Info( "workaroundTwo got called" )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "ThrottleWorkaroundOne" )
    EVENT_MANAGER:UnregisterForEvent( WW.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    validationTask:Call( function()
        EVENT_MANAGER:RegisterForEvent( WW.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
            if WWV.DidSetupSwapCorrectly( WORKAROUND_TWO ) then
                successFunction()
            else
                EVENT_MANAGER:RegisterForUpdate( WW.name .. "ThrottleWorkaroundTwo", validationDelay / 2, workaroundThree )
            end
        end )
        EVENT_MANAGER:AddFilterForEvent( WW.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                         REGISTER_FILTER_BAG_ID,
                                         BAG_WORN )

        EVENT_MANAGER:AddFilterForEvent( WW.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                         REGISTER_FILTER_INVENTORY_UPDATE_REASON,
                                         INVENTORY_UPDATE_REASON_DEFAULT )
        if not WWV.DidSetupSwapCorrectly( WORKAROUND_TWO ) then
            WW.LoadSetupAdjacent( 0 )
        else
            successFunction()
        end
        EVENT_MANAGER:RegisterForUpdate( WW.name .. "ThrottleWorkaroundTwo", validationDelay, workaroundThree ) -- wait for the gear swap event, if it doesnt happen then try workaround three
    end )
end

-- Sheathe weapons and see if it fixes itself
local function workaroundOne()
    validationDelay = WW.settings.validationDelay
    logger:Info( "workaround one got called" )
    EVENT_MANAGER:RegisterForEvent( WW.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
        if WWV.DidSetupSwapCorrectly( WORKAROUND_ONE ) then
            successFunction()
        else
            EVENT_MANAGER:RegisterForUpdate( WW.name .. "ThrottleWorkaroundOne", validationDelay / 2, workaroundTwo ) -- throttle to call workaround after the last event
        end
    end )
    EVENT_MANAGER:AddFilterForEvent( WW.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_BAG_ID, BAG_WORN )

    EVENT_MANAGER:AddFilterForEvent( WW.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_INVENTORY_UPDATE_REASON,
                                     INVENTORY_UPDATE_REASON_DEFAULT )
    validationTask:Call( function()
        if not WWV.DidSetupSwapCorrectly( WORKAROUND_ONE ) then
            if not ArePlayerWeaponsSheathed() then
                TogglePlayerWield()
            end
            EVENT_MANAGER:RegisterForUpdate( WW.name .. "ThrottleWorkaroundOne", validationDelay, workaroundTwo ) -- we wait for the gear swap event, if it does not happen we try workaround two
        else
            successFunction()
        end
    end )
end
-- Make function accessible via keybind
WWV.WorkAroundOne = workaroundOne

local function handleSettings()
    logger:Info( "handle settings has been called" )

    EVENT_MANAGER:UnregisterForUpdate( WW.name .. "Throttle" )
    EVENT_MANAGER:UnregisterForEvent( WW.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE )

    validationTask:Call( function()
        local success, failedT = WWV.DidSetupSwapCorrectly( WORKAROUND_INITIAL_CALL )

        local failedSlotNames = table.concat( failedT, ", " )
        if success then
            successFunction()
        else
            -- Warn user regardless of the setting
            local middleText = string.format( "|c%s%s|r", WW.LOGTYPES.ERROR, setupName )
            WizardsWardrobePanelBottomLabel:SetText( middleText )
            if WW.settings.fixGearSwap then
                WW.Log( GetString( WW_MSG_SWAPFAIL ), WW.LOGTYPES.ERROR, "FFFFFF", failedSlotNames )
                if IsUnitInCombat( "player" ) then
                    validationTask:WaitUntil( function() return not IsUnitInCombat( "player" ) end ):Then( workaroundOne )
                else
                    validationTask:Call( workaroundOne )
                end
            else
                WW.Log( GetString( WW_MSG_SWAPFAIL_DISABLED ), WW.LOGTYPES.ERROR, "FFFFFF", failedSlotNames )
            end
        end
    end )
end
-- Function gets called once on setup swap
function WWV.SetupFailWorkaround()
    validationDelay = WW.settings.validationDelay
    local function throttle()
        -- throttle continously while swapping takes place until its done, so we don't have to call the workaround for every piece of gear we swap
        EVENT_MANAGER:RegisterForUpdate( WW.name .. "Throttle", validationDelay, handleSettings )
    end

    EVENT_MANAGER:RegisterForEvent( WW.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, throttle )
    EVENT_MANAGER:AddFilterForEvent( WW.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_BAG_ID, BAG_WORN )

    EVENT_MANAGER:AddFilterForEvent( WW.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_INVENTORY_UPDATE_REASON,
                                     INVENTORY_UPDATE_REASON_DEFAULT )
end

-- Suspend all tasks when in combat and resume once we are out
local function combatFunction( _, inCombat )
    if inCombat then
        validationTask:Suspend()
    else
        validationTask:Resume()
    end
end


EVENT_MANAGER:RegisterForEvent( WW.name, EVENT_PLAYER_COMBAT_STATE, function( _, inCombat ) combatFunction( _, inCombat ) end )
