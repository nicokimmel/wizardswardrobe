local WW = WizardsWardrobe
WW.zones["MOL"] = {}
local MOL = WW.zones["MOL"]

MOL.name = GetString(WW_MOL_NAME)
MOL.tag = "MOL"
MOL.icon = "/esoui/art/icons/achievement_thievesguild_004.dds"
MOL.priority = 4
MOL.id = 725

MOL.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_MOL_ZHAJHASSA),
	},
	[3] = {
		name = GetString(WW_MOL_TWINS),
	},
	[4] = {
		name = GetString(WW_MOL_RAKKHAT),
	},
}

MOL.LOCATIONS = {
	ZHAJHASSA = {
		x1 = 100000,
		x2 = 105800,
		y1 = 45500,
		y2 = 46500,
		z1 = 125500,
		z2 = 130900,
	},
	TWINS = {
		x1 = 76800,
		x2 = 81700,
		y1 = 45650,
		y2 = 45900,
		z1 = 144200,
		z2 = 149600,
	},
	RAKKHAT = {
		x1 = 0,
		x2 = 57500,
		y1 = 61400,
		y2 = 62000,
		z1 = 171000,
		z2 = 208000,
	},
}

function MOL.Init()
	EVENT_MANAGER:UnregisterForEvent(WW.name, EVENT_BOSSES_CHANGED)
	EVENT_MANAGER:RegisterForUpdate(WW.name .. MOL.tag .. "MovementLoop", 2000, MOL.OnMovement)
	EVENT_MANAGER:RegisterForEvent(WW.name .. MOL.tag, EVENT_PLAYER_COMBAT_STATE, MOL.OnCombatChange)
end

function MOL.Reset()
	EVENT_MANAGER:UnregisterForEvent(WW.name .. MOL.tag, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForUpdate(WW.name .. MOL.tag .. "MovementLoop")
	EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_BOSSES_CHANGED, WW.OnBossChange)
end

function MOL.OnCombatChange(_, inCombat)
	if inCombat then
		EVENT_MANAGER:UnregisterForUpdate(WW.name .. MOL.tag .. "MovementLoop")
	else
		EVENT_MANAGER:RegisterForUpdate(WW.name .. MOL.tag .. "MovementLoop", 2000, MOL.OnMovement)
	end
end

function MOL.OnMovement()
	local bossName = MOL.GetBossByLocation()
	if not bossName then return end
	WW.OnBossChange(_, true, bossName)
end

function MOL.GetBossByLocation()
	local zone, x, y, z = GetUnitWorldPosition("player")
	
	if zone ~= MOL.id then return nil end
	
	if x > MOL.LOCATIONS.ZHAJHASSA.x1 and x < MOL.LOCATIONS.ZHAJHASSA.x2
		and y > MOL.LOCATIONS.ZHAJHASSA.y1 and y < MOL.LOCATIONS.ZHAJHASSA.y2
		and z > MOL.LOCATIONS.ZHAJHASSA.z1 and z < MOL.LOCATIONS.ZHAJHASSA.z2 then
		
		return GetString(WW_MOL_ZHAJHASSA)
		
	elseif x > MOL.LOCATIONS.TWINS.x1 and x < MOL.LOCATIONS.TWINS.x2
		and y > MOL.LOCATIONS.TWINS.y1 and y < MOL.LOCATIONS.TWINS.y2
		and z > MOL.LOCATIONS.TWINS.z1 and z < MOL.LOCATIONS.TWINS.z2 then
		
		return GetString(WW_MOL_TWINS)
	
	elseif x > MOL.LOCATIONS.RAKKHAT.x1 and x < MOL.LOCATIONS.RAKKHAT.x2
		and y > MOL.LOCATIONS.RAKKHAT.y1 and y < MOL.LOCATIONS.RAKKHAT.y2
		and z > MOL.LOCATIONS.RAKKHAT.z1 and z < MOL.LOCATIONS.RAKKHAT.z2 then
		
		return GetString(WW_MOL_RAKKHAT)
	
	else
		return GetString(WW_TRASH)
	end
end

function MOL.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end