local WW = WizardsWardrobe
WW.zones["KA"] = {}
local KA = WW.zones["KA"]

KA.name = GetString(WW_KA_NAME)
KA.tag = "KA"
KA.icon = "/WizardsWardrobe/assets/zones/ka.dds"
KA.priority = 9
KA.id = 1196

KA.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_KA_YANDIR),
	},
	[3] = {
		name = GetString(WW_KA_VROL),
	},
	[4] = {
		name = GetString(WW_KA_FALGRAVN),
	},
}

function KA.Init()
	
end

function KA.Reset()
	
end

function KA.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end