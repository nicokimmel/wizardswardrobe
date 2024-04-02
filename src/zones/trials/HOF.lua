local WW = WizardsWardrobe
WW.zones["HOF"] = {}
local HOF = WW.zones["HOF"]

HOF.name = GetString(WW_HOF_NAME)
HOF.tag = "HOF"
HOF.icon = "/esoui/art/icons/achievement_vvardenfel_036.dds"
HOF.priority = 5
HOF.id = 975
HOF.node = 331

HOF.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		displayName = GetString(WW_HOF_HUNTERKILLER_DN),
		name = GetString(WW_HOF_HUNTERKILLER),
	},
	[3] = {
		name = GetString(WW_HOF_FACTOTUM),
	},
	[4] = {
		name = GetString(WW_HOF_SPIDER),
	},
	[5] = {
		displayName = GetString(WW_HOF_COMMITEE_DN),
		name = GetString(WW_HOF_COMMITEE),
	},
	[6] = {
		name = GetString(WW_HOF_GENERAL),
	},
}

HOF.LOCATIONS = {
	HUNTERFACTOTUM = {
		x1 = 40000,
		x2 = 45500,
		y1 = 49800,
		y2 = 55000,
		z1 = 23000,
		z2 = 29000,
	},
	SPIDER = {
		x1 = 67700,
		x2 = 93000,
		y1 = 52000,
		y2 = 53000,
		z1 = 12200,
		z2 = 37500,
	},
	COMMITEE = {
		x1 = 25960,
		x2 = 33030,
		y1 = 52900,
		y2 = 53450,
		z1 = 70700,
		z2 = 75950,
	},
	GENERAL = {
		x1 = 70000,
		x2 = 80000,
		y1 = 54500,
		y2 = 56500,
		z1 = 65000,
		z2 = 75500,
	},
}

function HOF.Init()
	HOF.isHunterkillerDead = false
	EVENT_MANAGER:UnregisterForEvent(WW.name, EVENT_BOSSES_CHANGED)
	EVENT_MANAGER:RegisterForUpdate(WW.name .. HOF.tag .. "MovementLoop", 2000, HOF.OnMovement)
	EVENT_MANAGER:RegisterForEvent(WW.name .. HOF.tag, EVENT_PLAYER_COMBAT_STATE, HOF.OnCombatChange)
	EVENT_MANAGER:RegisterForEvent(WW.name .. HOF.tag, EVENT_UNIT_DEATH_STATE_CHANGED, HOF.OnUnitDeath)
end

function HOF.Reset()
	EVENT_MANAGER:UnregisterForEvent(WW.name .. HOF.tag, EVENT_UNIT_DEATH_STATE_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(WW.name .. HOF.tag, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForUpdate(WW.name .. HOF.tag .. "MovementLoop")
	EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_BOSSES_CHANGED, WW.OnBossChange)
end

function HOF.OnUnitDeath(_, unitTag, isDead)
	if not isDead then return end
	if unitTag:sub(1, 1) ~= "b" then return end
	local bossName = GetUnitName(unitTag)
	if bossName == GetString(WW_HOF_HUNTERKILLER) then
		HOF.isHunterkillerDead = true
	end
end

function HOF.OnMovement()
	local bossName = HOF.GetBossByLocation()
	if not bossName then return end
	WW.OnBossChange(_, true, bossName)
end

function HOF.GetBossByLocation()
	local zone, x, y, z = GetUnitWorldPosition("player")
	
	if zone ~= HOF.id then return nil end
	
	if x > HOF.LOCATIONS.HUNTERFACTOTUM.x1 and x < HOF.LOCATIONS.HUNTERFACTOTUM.x2
		and y > HOF.LOCATIONS.HUNTERFACTOTUM.y1 and y < HOF.LOCATIONS.HUNTERFACTOTUM.y2
		and z > HOF.LOCATIONS.HUNTERFACTOTUM.z1 and z < HOF.LOCATIONS.HUNTERFACTOTUM.z2 then
		
		-- if player reloads/crashes/ports in after hunter killers are dead
		if GetUnitName("boss1") == GetString(WW_HOF_FACTOTUM) then
			HOF.isHunterkillerDead = true
		elseif GetUnitName("boss1") == GetString(WW_HOF_HUNTERKILLER) then
			HOF.isHunterkillerDead = false
		end
		
		if HOF.isHunterkillerDead then
			return GetString(WW_HOF_FACTOTUM)
		else
			return GetString(WW_HOF_HUNTERKILLER)
		end
	
	elseif x > HOF.LOCATIONS.SPIDER.x1 and x < HOF.LOCATIONS.SPIDER.x2
		and y > HOF.LOCATIONS.SPIDER.y1 and y < HOF.LOCATIONS.SPIDER.y2
		and z > HOF.LOCATIONS.SPIDER.z1 and z < HOF.LOCATIONS.SPIDER.z2 then
		
		return GetString(WW_HOF_SPIDER)
		
	elseif x > HOF.LOCATIONS.COMMITEE.x1 and x < HOF.LOCATIONS.COMMITEE.x2
		and y > HOF.LOCATIONS.COMMITEE.y1 and y < HOF.LOCATIONS.COMMITEE.y2
		and z > HOF.LOCATIONS.COMMITEE.z1 and z < HOF.LOCATIONS.COMMITEE.z2 then
		
		return GetString(WW_HOF_COMMITEE)
		
	elseif x > HOF.LOCATIONS.GENERAL.x1 and x < HOF.LOCATIONS.GENERAL.x2
		and y > HOF.LOCATIONS.GENERAL.y1 and y < HOF.LOCATIONS.GENERAL.y2
		and z > HOF.LOCATIONS.GENERAL.z1 and z < HOF.LOCATIONS.GENERAL.z2 then
		
		return GetString(WW_HOF_GENERAL)
		
	else
		
		return ""--GetString(WW_TRASH)
	end
end

function HOF.OnCombatChange(_, inCombat)
	if inCombat then
		EVENT_MANAGER:UnregisterForUpdate(WW.name .. HOF.tag .. "MovementLoop")
	else
		EVENT_MANAGER:RegisterForUpdate(WW.name .. HOF.tag .. "MovementLoop", 2000, HOF.OnMovement)
	end
end

function HOF.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end