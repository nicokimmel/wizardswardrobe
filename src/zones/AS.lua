local WW = WizardsWardrobe
WW.zones[ "AS" ] = {}
local AS = WW.zones[ "AS" ]

AS.name = GetString( WW_AS_NAME )
AS.tag = "AS"
AS.icon = "/esoui/art/icons/achievement_update16_029.dds"
AS.priority = 6
AS.id = 1000
AS.node = 346
AS.category = WW.ACTIVITIES.TRIALS

AS.bosses = {
	[ 1 ] = {
		name = GetString( WW_AS_OLMS ),
	},
	[ 2 ] = {
		name = GetString( WW_AS_FELMS ),
	},
	[ 3 ] = {
		name = GetString( WW_AS_LLOTHIS ),
	},
}

function AS.Init()
	EVENT_MANAGER:UnregisterForEvent( WW.name, EVENT_BOSSES_CHANGED )
	EVENT_MANAGER:RegisterForUpdate( WW.name .. AS.tag .. "MovementLoop", 2000, AS.OnMovement )
	EVENT_MANAGER:RegisterForEvent( WW.name .. AS.tag, EVENT_PLAYER_COMBAT_STATE, AS.OnCombatChange )
end

function AS.Reset()
	EVENT_MANAGER:UnregisterForEvent( WW.name .. AS.tag, EVENT_PLAYER_COMBAT_STATE )
	EVENT_MANAGER:UnregisterForUpdate( WW.name .. AS.tag .. "MovementLoop" )
	EVENT_MANAGER:RegisterForEvent( WW.name, EVENT_BOSSES_CHANGED, WW.OnBossChange )
end

function AS.OnCombatChange( _, inCombat )
	if inCombat then
		EVENT_MANAGER:UnregisterForUpdate( WW.name .. AS.tag .. "MovementLoop" )
	else
		EVENT_MANAGER:RegisterForUpdate( WW.name .. AS.tag .. "MovementLoop", 2000, AS.OnMovement )
	end
end

function AS.OnMovement()
	local _, x, y, z = GetUnitWorldPosition( "player" )
	local bossName = GetString( WW_AS_OLMS )
	if y > 65000 then -- upper part of AS
		bossName = GetString( WW_AS_LLOTHIS )
		if z > 100000 then
			bossName = GetString( WW_AS_FELMS )
		end
	end
	WW.OnBossChange( _, true, bossName )
end

function AS.OnBossChange( bossName )
	-- no trash setup in AS
	if #bossName == 0 then
		return
	end

	WW.conditions.OnBossChange( bossName )
end
