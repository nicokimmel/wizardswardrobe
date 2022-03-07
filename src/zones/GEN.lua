local WW = WizardsWardrobe
WW.zones["GEN"] = {}
local GEN = WW.zones["GEN"]

GEN.name = GetString(WW_GENERAL)
GEN.tag = "GEN"
GEN.icon = "/WizardsWardrobe/assets/zones/gen.dds"
GEN.priority = -2
GEN.id = -1

GEN.bosses = {}

function GEN.Init()
	
end

function GEN.Reset()
	
end

function GEN.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end