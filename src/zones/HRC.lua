local WW = WizardsWardrobe
WW.zones["HRC"] = {}
local HRC = WW.zones["HRC"]

HRC.name = GetString(WW_HRC_NAME)
HRC.tag = "HRC"
HRC.icon = "/esoui/art/icons/achievement_update11_dungeons_001.dds"
HRC.priority = 3
HRC.id = 636

HRC.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_HRC_RAKOTU),
	},
	[3] = {
		name = GetString(WW_HRC_LOWER),
	},
	[4] = {
		name = GetString(WW_HRC_UPPER),
	},
	[5] = {
		name = GetString(WW_HRC_WARRIOR),
	},
}

function HRC.Init()
	
end

function HRC.Reset()
	
end

function HRC.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end