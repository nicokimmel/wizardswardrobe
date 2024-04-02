local WW = WizardsWardrobe
WW.zones["DSR"] = {}
local DSR = WW.zones["DSR"]

DSR.name = GetString(WW_DSR_NAME)
DSR.tag = "DSR"
DSR.icon = "/esoui/art/icons/u34_vtrial_meta.dds"
DSR.priority = 11
DSR.id = 1344
DSR.node = 488

DSR.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		displayName = GetString(WW_DSR_LYLANARTURLASSIL_DN),
		name = GetString(WW_DSR_LYLANARTURLASSIL),
	},
	[3] = {
		name = GetString(WW_DSR_GUARDIAN),
	},
	[4] = {
		name = GetString(WW_DSR_TALERIA),
	},
	[5] = {
		name = GetString(WW_DSR_SAILRIPPER),
	},
	[6] = {
		name = GetString(WW_DSR_BOWBREAKER),
	},
}

DSR.LOCATIONS = {
	LYLANARTURLASSIL = {
		x1 = 60100,
		x2 = 73700,
		y1 = 35000,
		y2 = 39800,
		z1 = 76300,
		z2 = 94700,
	},
	GUARDIAN = {
		x1 = 163000,
		x2 = 182000,
		y1 = 35000,
		y2 = 41000,
		z1 = 74000,
		z2 = 90600,
	},
	TALERIA = {
		x1 = 159000,
		x2 = 180500,
		y1 = 35000,
		y2 = 41500,
		z1 = 18000,
		z2 = 38200,
	},
	SAILRIPPER = {
		x1 = 164600,
		x2 = 175000,
		y1 = 39700,
		y2 = 41700,
		z1 = 154800,
		z2 = 165200,
	},
	BOWBREAKER = {
		x1 = 57000,
		x2 = 67100,
		y1 = 35000,
		y2 = 37600,
		z1 = 41700,
		z2 = 52200,
	},
}

function DSR.Init()
	EVENT_MANAGER:UnregisterForEvent(WW.name, EVENT_BOSSES_CHANGED)
	EVENT_MANAGER:RegisterForUpdate(WW.name .. DSR.tag .. "MovementLoop", 2000, DSR.OnMovement)
	EVENT_MANAGER:RegisterForEvent(WW.name .. DSR.tag, EVENT_PLAYER_COMBAT_STATE, DSR.OnCombatChange)
end

function DSR.Reset()
	EVENT_MANAGER:UnregisterForEvent(WW.name .. DSR.tag, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForUpdate(WW.name .. DSR.tag .. "MovementLoop")
	EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_BOSSES_CHANGED, WW.OnBossChange)
end

function DSR.OnCombatChange(_, inCombat)
	if inCombat then
		EVENT_MANAGER:UnregisterForUpdate(WW.name .. DSR.tag .. "MovementLoop")
	else
		EVENT_MANAGER:RegisterForUpdate(WW.name .. DSR.tag .. "MovementLoop", 2000, DSR.OnMovement)
	end
end

function DSR.OnMovement()
	local bossName = DSR.GetBossByLocation()
	if not bossName then return end
	WW.OnBossChange(_, true, bossName)
end

function DSR.GetBossByLocation()
	local zone, x, y, z = GetUnitWorldPosition("player")
	
	if zone ~= DSR.id then return nil end
	
	if x > DSR.LOCATIONS.LYLANARTURLASSIL.x1 and x < DSR.LOCATIONS.LYLANARTURLASSIL.x2
		and y > DSR.LOCATIONS.LYLANARTURLASSIL.y1 and y < DSR.LOCATIONS.LYLANARTURLASSIL.y2
		and z > DSR.LOCATIONS.LYLANARTURLASSIL.z1 and z < DSR.LOCATIONS.LYLANARTURLASSIL.z2 then
		
		return GetString(WW_DSR_LYLANARTURLASSIL)
		
	elseif x > DSR.LOCATIONS.GUARDIAN.x1 and x < DSR.LOCATIONS.GUARDIAN.x2
		and y > DSR.LOCATIONS.GUARDIAN.y1 and y < DSR.LOCATIONS.GUARDIAN.y2
		and z > DSR.LOCATIONS.GUARDIAN.z1 and z < DSR.LOCATIONS.GUARDIAN.z2 then
		
		return GetString(WW_DSR_GUARDIAN)
		
	elseif x > DSR.LOCATIONS.TALERIA.x1 and x < DSR.LOCATIONS.TALERIA.x2
		and y > DSR.LOCATIONS.TALERIA.y1 and y < DSR.LOCATIONS.TALERIA.y2
		and z > DSR.LOCATIONS.TALERIA.z1 and z < DSR.LOCATIONS.TALERIA.z2 then
		
		return GetString(WW_DSR_TALERIA)
		
	elseif x > DSR.LOCATIONS.SAILRIPPER.x1 and x < DSR.LOCATIONS.SAILRIPPER.x2
		and y > DSR.LOCATIONS.SAILRIPPER.y1 and y < DSR.LOCATIONS.SAILRIPPER.y2
		and z > DSR.LOCATIONS.SAILRIPPER.z1 and z < DSR.LOCATIONS.SAILRIPPER.z2 then
		
		return GetString(WW_DSR_SAILRIPPER)
		
	elseif x > DSR.LOCATIONS.BOWBREAKER.x1 and x < DSR.LOCATIONS.BOWBREAKER.x2
		and y > DSR.LOCATIONS.BOWBREAKER.y1 and y < DSR.LOCATIONS.BOWBREAKER.y2
		and z > DSR.LOCATIONS.BOWBREAKER.z1 and z < DSR.LOCATIONS.BOWBREAKER.z2 then
		
		return GetString(WW_DSR_BOWBREAKER)
		
	else
		return GetString(WW_TRASH)
	end
end

function DSR.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end