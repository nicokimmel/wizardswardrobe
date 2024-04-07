local WW = WizardsWardrobe
WW.zones["LOM"] = {}
local LOM = WW.zones["LOM"]

LOM.name = GetString(WW_LOM_NAME)
LOM.tag = "LOM"
LOM.icon = "/esoui/art/icons/achievement_u23_dun2_flavorboss5b.dds"
LOM.priority = 112
LOM.id = 1123
LOM.node = 398

LOM.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_LOM_SELENE),
	},
	[3] = {
		name = GetString(WW_LOM_AZUREBLIGHT_LURCHER),
	},
	[4] = {
		name = GetString(WW_LOM_AZUREBLIGHT_CANCROID),
	},
	[5] = {
		name = GetString(WW_LOM_MAARSELOK),
	},
	[6] = {
		name = GetString(WW_LOM_MAARSELOK_BOSS),
	},
}

LOM.LOCATIONS = {
	FIRST = {
		x1 = 101000, -- porte entrée selene
		x2 = 109000, -- porte sortie selene
		z1 = 27000, -- Z1 corespond pas
		z2 = 35000, -- Z2 corespond pas
	},
	SECOND = {
		x1 = 134000,
		x2 = 143000,
		z1 = 59000, -- Z1 corespond pas
		z2 = 68000, -- Z2 corespond pas
	},
	THIRD = {
		x1 = 70000,
		x2 = 79000,
		z1 = 104300, -- Z1 corespond pas
		z2 = 114200, -- Z2 corespond pas
	},
	FORTH = {
		x1 = 83000,
		x2 = 98000,
		z1 = 141000, -- Z1 corespond pas
		z2 = 150000, -- Z2 corespond pas
	},
	FIFTH = {
		x1 = 128000, --porte entrée
		x2 = 140000, --boss
		z1 = 137000, -- Z1 corespond pas
		z2 = 144000, -- Z2 corespond pas
	}
}

function LOM.Init()
	EVENT_MANAGER:UnregisterForEvent(WW.name, EVENT_BOSSES_CHANGED)
	EVENT_MANAGER:RegisterForUpdate(WW.name .. LOM.tag .. "MovementLoop", 2000, LOM.OnMovement)
	EVENT_MANAGER:RegisterForEvent(WW.name .. LOM.tag, EVENT_PLAYER_COMBAT_STATE, LOM.OnCombatChange)
end

function LOM.Reset()
	EVENT_MANAGER:UnregisterForUpdate(WW.name .. LOM.tag .. "MovementLoop")
	EVENT_MANAGER:RegisterForEvent(WW.name, EVENT_BOSSES_CHANGED, WW.OnBossChange)
end

function LOM.OnCombatChange(_, inCombat)
	if inCombat == true then
		EVENT_MANAGER:UnregisterForUpdate(WW.name .. LOM.tag .. "MovementLoop")
	else
		EVENT_MANAGER:RegisterForUpdate(WW.name .. LOM.tag .. "MovementLoop", 2000, LOM.OnMovement)
	end
end

function LOM.OnMovement()
	local boss = LOM.GetBossByLocation()
	if boss == 0 then
		WW.OnBossChange(_, true, "")
		return
	end
	WW.OnBossChange(_, true, LOM.bosses[boss].name)
end

function LOM.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId

	local index = LOM.lookupBosses[bossName]
	WW.LoadSetup(LOM, pageId, index, true)
end

function LOM.GetBossByLocation()
	local zone, x, y, z = GetUnitWorldPosition("player")

	if x > LOM.LOCATIONS.FIRST.x1 and x < LOM.LOCATIONS.FIRST.x2
		and z > LOM.LOCATIONS.FIRST.z1 and z < LOM.LOCATIONS.FIRST.z2 then
		return 1 + 1

	elseif x > LOM.LOCATIONS.SECOND.x1 and x < LOM.LOCATIONS.SECOND.x2
		and z > LOM.LOCATIONS.SECOND.z1 and z < LOM.LOCATIONS.SECOND.z2 then
		return 2 + 1

	elseif x > LOM.LOCATIONS.THIRD.x1 and x < LOM.LOCATIONS.THIRD.x2
		and z > LOM.LOCATIONS.THIRD.z1 and z < LOM.LOCATIONS.THIRD.z2 then
		return 3 + 1

	elseif x > LOM.LOCATIONS.FORTH.x1 and x < LOM.LOCATIONS.FORTH.x2
		and z > LOM.LOCATIONS.FORTH.z1 and z < LOM.LOCATIONS.FORTH.z2 then
		return 4 + 1

	elseif x > LOM.LOCATIONS.FIFTH.x1 and x < LOM.LOCATIONS.FIFTH.x2
		and z > LOM.LOCATIONS.FIFTH.z1 and z < LOM.LOCATIONS.FIFTH.z2 then
		return 5 + 1

	else
		return 0
	end
end
