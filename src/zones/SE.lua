----------
--This file was created by @JN_Slevin with help from @Ghostbane
---------
local WW = WizardsWardrobe
WW.zones[ "SE" ] = {}
local SE = WW.zones[ "SE" ]

SE.name = GetString( WW_SE_NAME )
SE.tag = "SE"
SE.icon = "/esoui/art/icons/achievement_u38_vtrial_meta.dds"
SE.priority = 12
SE.id = 1427
SE.node = 568
SE.category = WW.ACTIVITIES.TRIALS

SE.bosses = {
    [ 1 ] = {
        name = GetString( WW_TRASH ),
    },
    [ 2 ] = {
        name = GetString( WW_SE_DESCENDER ), -- Appears randomly, therefore no postition saved
    },
    [ 3 ] = {
        name = GetString( WW_SE_YASEYLA ),
    },
    [ 4 ] = {
        name = GetString( WW_SE_TWELVANE ), --
    },
    [ 5 ] = {
        name = GetString( WW_SE_ANSUUL ),
    },

}

SE.LOCATIONS = {
    YASEYLA = {
        x1 = 83530,
        x2 = 89530,
        y1 = 12637,
        y2 = 17637,
        z1 = 31077,
        z2 = 45277,
    },
    TWELVANE = {
        x1 = 181951,
        x2 = 197951,
        y1 = 37840,
        y2 = 42840,
        z1 = 216024,
        z2 = 225224,
    },
    ANSUUL = {
        x1 = 196953,
        x2 = 202953,
        y1 = 29699,
        y2 = 30699,
        z1 = 33632,
        z2 = 42832,
    },
}

function SE.Init()
    EVENT_MANAGER:UnregisterForEvent( WW.name, EVENT_BOSSES_CHANGED )
    EVENT_MANAGER:RegisterForUpdate( WW.name .. SE.tag .. "MovementLoop", 2000, SE.OnMovement )
    EVENT_MANAGER:RegisterForEvent( WW.name .. SE.tag, EVENT_PLAYER_COMBAT_STATE, SE.OnCombatChange )
end

function SE.Reset()
    EVENT_MANAGER:UnregisterForEvent( WW.name .. SE.tag, EVENT_PLAYER_COMBAT_STATE )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. SE.tag .. "MovementLoop" )
    EVENT_MANAGER:RegisterForEvent( WW.name, EVENT_BOSSES_CHANGED, WW.OnBossChange )
end

function SE.OnCombatChange( _, inCombat )
    if inCombat then
        EVENT_MANAGER:UnregisterForUpdate( WW.name .. SE.tag .. "MovementLoop" )
    else
        EVENT_MANAGER:RegisterForUpdate( WW.name .. SE.tag .. "MovementLoop", 2000, SE.OnMovement )
    end
end

function SE.OnMovement()
    local bossName = SE.GetBossByLocation()
    if not bossName then return end
    WW.OnBossChange( _, true, bossName )
end

function SE.GetBossByLocation()
    local zone, x, y, z = GetUnitWorldPosition( "player" )

    if zone ~= SE.id then return nil end

    if x > SE.LOCATIONS.YASEYLA.x1 and x < SE.LOCATIONS.YASEYLA.x2
        and y > SE.LOCATIONS.YASEYLA.y1 and y < SE.LOCATIONS.YASEYLA.y2
        and z > SE.LOCATIONS.YASEYLA.z1 and z < SE.LOCATIONS.YASEYLA.z2 then
        return GetString( WW_SE_YASEYLA )
    elseif x > SE.LOCATIONS.TWELVANE.x1 and x < SE.LOCATIONS.TWELVANE.x2
        and y > SE.LOCATIONS.TWELVANE.y1 and y < SE.LOCATIONS.TWELVANE.y2
        and z > SE.LOCATIONS.TWELVANE.z1 and z < SE.LOCATIONS.TWELVANE.z2 then
        return GetString( WW_SE_TWELVANE )
    elseif x > SE.LOCATIONS.ANSUUL.x1 and x < SE.LOCATIONS.ANSUUL.x2
        and y > SE.LOCATIONS.ANSUUL.y1 and y < SE.LOCATIONS.ANSUUL.y2
        and z > SE.LOCATIONS.ANSUUL.z1 and z < SE.LOCATIONS.ANSUUL.z2 then
        return GetString( WW_SE_ANSUUL )
    else
        return GetString( WW_TRASH )
    end
end

function SE.OnBossChange( bossName )
    WW.conditions.OnBossChange( bossName )
end
