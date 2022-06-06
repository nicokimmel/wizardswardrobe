local WW = WizardsWardrobe
WW.zones["AA"] = {}
local AA = WW.zones["AA"]

AA.name = GetString(WW_AA_NAME)
AA.tag = "AA"
AA.icon = "/esoui/art/icons/achievement_update11_dungeons_002.dds"
AA.priority = 1
AA.id = 638

AA.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_AA_STORMATRO),
	},
	[3] = {
		name = GetString(WW_AA_STONEATRO),
	},
	[4] = {
		name = GetString(WW_AA_VARLARIEL),
	},
	[5] = {
		name = GetString(WW_AA_MAGE),
	},
}

function AA.Init()
	
end

function AA.Reset()
	
end

function AA.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end