local WW = WizardsWardrobe
WW.zones["RG"] = {}
local RG = WW.zones["RG"]

RG.name = GetString(WW_RG_NAME)
RG.tag = "RG"
RG.icon = "/esoui/art/icons/achievement_u30_vtrial_meta.dds"
RG.priority = 10
RG.id = 1263

RG.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_RG_OAXILTSO),
	},
	[3] = {
		name = GetString(WW_RG_BAHSEI),
	},
	[4] = {
		name = GetString(WW_RG_XALVAKKA),
	},
	[5] = {
		name = GetString(WW_RG_SNAKE),
	},
	[6] = {
		name = GetString(WW_RG_ASHTITAN),
	},
}

RG.LOCATIONS = {
	OAXILTSO = {
		x1 = 86200,
		x2 = 94000,
		y1 = 35000,
		y2 = 36500,
		z1 = 76700,
		z2 = 83600,
	},
	BAHSEI = {
		x1 = 96500,
		x2 = 103800,
		y1 = 42000,
		y2 = 43100,
		z1 = 96000,
		z2 = 103200,
	},
	XALVAKKA = {
		x1 = 149400,
		x2 = 168000,
		y1 = 30000,
		y2 = 39000,
		z1 = 150000,
		z2 = 168000,
	},
	SNAKE = {
		x1 = 100400,
		x2 = 117000,
		y1 = 32500,
		y2 = 34500,
		z1 = 50200,
		z2 = 54580,
	},
	ASHTITAN = {
		x1 = 163900,
		x2 = 172500,
		y1 = 29800,
		y2 = 31800,
		z1 = 141000,
		z2 = 150300,
	},
}

function RG.Init()
	EVENT_MANAGER:UnregisterForEvent(WW.name, EVENT_BOSSES_CHANGED)
	EVENT_MANAGER:RegisterForUpdate(WW.name .. RG.tag .. "MovementLoop", 2000, RG.OnMovement)
	EVENT_MANAGER:RegisterForEvent(WW.name .. RG.tag, EVENT_PLAYER_COMBAT_STATE, RG.OnCombatChange)
	RG.lastBoss = ""
end

function RG.Reset()
	EVENT_MANAGER:UnregisterForEvent(WW.name .. RG.tag, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForUpdate(WW.name .. RG.tag .. "MovementLoop")
	EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_BOSSES_CHANGED, WW.OnBossChange)
end

function RG.OnCombatChange(_, inCombat)
	if inCombat then
		EVENT_MANAGER:UnregisterForUpdate(WW.name .. RG.tag .. "MovementLoop")
	else
		EVENT_MANAGER:RegisterForUpdate(WW.name .. RG.tag .. "MovementLoop", 2000, RG.OnMovement)
	end
end

function RG.OnMovement()
	local bossName = RG.GetBossByLocation()
	if not bossName then return end
	WW.OnBossChange(_, true, bossName)
end

function RG.GetBossByLocation()
	local zone, x, y, z = GetUnitWorldPosition("player")
	
	if zone ~= RG.id then return nil end
	
	if x > RG.LOCATIONS.OAXILTSO.x1 and x < RG.LOCATIONS.OAXILTSO.x2
		and y > RG.LOCATIONS.OAXILTSO.y1 and y < RG.LOCATIONS.OAXILTSO.y2
		and z > RG.LOCATIONS.OAXILTSO.z1 and z < RG.LOCATIONS.OAXILTSO.z2 then
		
		return GetString(WW_RG_OAXILTSO)
		
	elseif x > RG.LOCATIONS.BAHSEI.x1 and x < RG.LOCATIONS.BAHSEI.x2
		and y > RG.LOCATIONS.BAHSEI.y1 and y < RG.LOCATIONS.BAHSEI.y2
		and z > RG.LOCATIONS.BAHSEI.z1 and z < RG.LOCATIONS.BAHSEI.z2 then
		
		return GetString(WW_RG_BAHSEI)
	
	elseif x > RG.LOCATIONS.XALVAKKA.x1 and x < RG.LOCATIONS.XALVAKKA.x2
		and y > RG.LOCATIONS.XALVAKKA.y1 and y < RG.LOCATIONS.XALVAKKA.y2
		and z > RG.LOCATIONS.XALVAKKA.z1 and z < RG.LOCATIONS.XALVAKKA.z2 then
		
		return GetString(WW_RG_XALVAKKA)
	
	elseif x > RG.LOCATIONS.SNAKE.x1 and x < RG.LOCATIONS.SNAKE.x2
		and y > RG.LOCATIONS.SNAKE.y1 and y < RG.LOCATIONS.SNAKE.y2
		and z > RG.LOCATIONS.SNAKE.z1 and z < RG.LOCATIONS.SNAKE.z2 then
	
		return GetString(WW_RG_SNAKE)

	elseif x > RG.LOCATIONS.ASHTITAN.x1 and x < RG.LOCATIONS.ASHTITAN.x2
		and y > RG.LOCATIONS.ASHTITAN.y1 and y < RG.LOCATIONS.ASHTITAN.y2
		and z > RG.LOCATIONS.ASHTITAN.z1 and z < RG.LOCATIONS.ASHTITAN.z2 then

		return GetString(WW_RG_ASHTITAN)
		
	else
		return GetString(WW_TRASH)
	end
end

function RG.OnBossChange(bossName)
	if RG.lastBoss == GetString(WW_RG_ASHTITAN) and bossName == "" then
		-- dont swap back to trash after ash titan
		return
	end
	RG.lastBoss = bossName
	
	WW.conditions.OnBossChange(bossName)
end