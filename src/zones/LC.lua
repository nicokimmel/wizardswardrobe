local WW = WizardsWardrobe
WW.zones[ "LC" ] = {}
local LC = WW.zones[ "LC" ]

LC.name = GetString( WW_LC_NAME )
LC.tag = "LC"
LC.icon = "/esoui/art/icons/achievement_u42_tri_vtrial_meta.dds"
LC.priority = 13
LC.id = 1478
LC.node = 568
LC.category = WW.ACTIVITIES.TRIALS

LC.bosses = {
    [ 1 ] = {
        name = GetString( WW_TRASH ),
    },
    [ 2 ] = {
        name = GetString( WW_LC_RYELAZ ),
    },
    [ 3 ] = {
        name = GetString( WW_LC_CAVOT_AGNAN ),
    },
    [ 4 ] = {
        name = GetString( WW_LC_ORPHIC ),
    },
    [ 5 ] = {
        name = GetString( WW_LC_KNOT ),
    },

}

LC.LOCATIONS = {
    RYELAZ = {
        x1 = 121600,
        x2 = 129250,
        y1 = 33450,
        y2 = 34450,
        z1 = 132000,
        z2 = 134000,
    },
    CAVOT_AGNAN = {
        x1 = 93000,
        x2 = 107000,
        y1 = 14000,
        y2 = 37500,
        z1 = 100000,
        z2 = 125000,
    },
    ORPHIC = {
        x1 = 136000,
        x2 = 162500,
        y1 = 21700,
        y2 = 23900,
        z1 = 83500,
        z2 = 93000,
    },

    XORYN = {
        x1 = 136000,
        x2 = 162500,
        y1 = 21700,
        y2 = 23900,
        z1 = 83500,
        z2 = 93000,
    },
}

function LC.Init()
    EVENT_MANAGER:UnregisterForEvent( WW.name, EVENT_BOSSES_CHANGED )
    EVENT_MANAGER:RegisterForUpdate( WW.name .. LC.tag .. "MovementLoop", 2000, LC.OnMovement )
    EVENT_MANAGER:RegisterForEvent( WW.name .. LC.tag, EVENT_PLAYER_COMBAT_STATE, LC.OnCombatChange )
    LC.lastBoss = ""
end

function LC.Reset()
    EVENT_MANAGER:UnregisterForEvent( WW.name .. LC.tag, EVENT_PLAYER_COMBAT_STATE )
    EVENT_MANAGER:UnregisterForUpdate( WW.name .. LC.tag .. "MovementLoop" )
    EVENT_MANAGER:RegisterForEvent( WW.name, EVENT_BOSSES_CHANGED, WW.OnBossChange )
end

function LC.OnCombatChange( _, inCombat )
    if inCombat then
        EVENT_MANAGER:UnregisterForUpdate( WW.name .. LC.tag .. "MovementLoop" )
    else
        EVENT_MANAGER:RegisterForUpdate( WW.name .. LC.tag .. "MovementLoop", 2000, LC.OnMovement )
    end
end

function LC.OnMovement()
    local bossName = LC.GetBossByLocation()
    if not bossName then return end
    WW.OnBossChange( _, true, bossName )
end

function LC.GetBossByLocation()
    local zone, x, y, z = GetUnitWorldPosition( "player" )

    if zone ~= LC.id then return nil end

    if x > LC.LOCATIONS.RYELAZ.x1 and x < LC.LOCATIONS.RYELAZ.x2
        and y > LC.LOCATIONS.RYELAZ.y1 and y < LC.LOCATIONS.RYELAZ.y2
        and z > LC.LOCATIONS.RYELAZ.z1 and z < LC.LOCATIONS.RYELAZ.z2 then
		if DoesUnitExist('boss1') and not IsUnitDead('boss1') then
        return GetString( WW_LC_RYELAZ )
		end
    elseif x > LC.LOCATIONS.CAVOT_AGNAN.x1 and x < LC.LOCATIONS.CAVOT_AGNAN.x2
        and y > LC.LOCATIONS.CAVOT_AGNAN.y1 and y < LC.LOCATIONS.CAVOT_AGNAN.y2
        and z > LC.LOCATIONS.CAVOT_AGNAN.z1 and z < LC.LOCATIONS.CAVOT_AGNAN.z2 then
		if DoesUnitExist('boss1') and not IsUnitDead('boss1') then
        return GetString( WW_LC_CAVOT_AGNAN )
		end
    elseif x > LC.LOCATIONS.ORPHIC.x1 and x < LC.LOCATIONS.ORPHIC.x2
        and y > LC.LOCATIONS.ORPHIC.y1 and y < LC.LOCATIONS.ORPHIC.y2
        and z > LC.LOCATIONS.ORPHIC.z1 and z < LC.LOCATIONS.ORPHIC.z2 then
        if GetUnitName( "boss1" ) == "" then
            return GetString( WW_LC_KNOT )
        else
            return GetString( WW_LC_ORPHIC )
        end
    else
        return GetString( WW_TRASH )
    end
end

function LC.OnBossChange( bossName )
    if LC.lastBoss == GetString( WW_LC_ORPHIC ) and bossName == "" then
        -- dont swap back to trash after ash titan
        return
    end
    LC.lastBoss = bossName

    WW.conditions.OnBossChange( bossName )
end
