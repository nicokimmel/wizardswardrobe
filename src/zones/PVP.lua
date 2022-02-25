local WW = WizardsWardrobe
WW.zones["PVP"] = {}
local PVP = WW.zones["PVP"]

PVP.name = GetString(WW_PVP_NAME)
PVP.tag = "PVP"
PVP.icon = "/WizardsWardrobe/assets/zones/pvp.dds"
PVP.legacyIcon = "/esoui/art/treeicons/achievements_indexicon_alliancewar_up.dds"
PVP.priority = 0
PVP.id = {
	[181] = true,	-- Cyrodiil
	[643] = true,	-- Imperial City
	[508] = true,	-- Foyada Quarry
	[509] = true,	-- Ald Carac
	[510] = true,	-- Ularra
	[511] = true,	-- Arcane University
	[512] = true,	-- Deeping Drome
	[513] = true,	-- Mor Khazgur Mine
	[514] = true,	-- Istirus Outpost
	[515] = true,	-- Istirus Outpost Arena (?)
	[517] = true,	-- Eld Angavar
	[518] = true,	-- Eld Angavar (?)
}

PVP.bosses = {
	[1] = {
		name = GetString(WW_EMPTY),
	},
	[2] = {
		name = GetString(WW_EMPTY),
	},
	[3] = {
		name = GetString(WW_EMPTY),
	},
	[4] = {
		name = GetString(WW_EMPTY),
	},
	[5] = {
		name = GetString(WW_EMPTY),
	},
	[6] = {
		name = GetString(WW_EMPTY),
	},
	[7] = {
		name = GetString(WW_EMPTY),
	},
	[8] = {
		name = GetString(WW_EMPTY),
	},
}

function PVP.Init()
	
end

function PVP.Reset()
	
end

function PVP.OnBossChange(bossName)
	
end