local WW = WizardsWardrobe
WW.zones["SO"] = {}
local SO = WW.zones["SO"]

SO.name = GetString(WW_SO_NAME)
SO.tag = "SO"
SO.icon = "/WizardsWardrobe/assets/zones/so.dds"
SO.priority = 2
SO.id = 639

SO.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_SO_MANTIKORA),
	},
	[3] = {
		name = GetString(WW_SO_TROLL),
	},
	[4] = {
		name = GetString(WW_SO_OZARA),
	},
	[5] = {
		name = GetString(WW_SO_SERPENT),
	},
}

function SO.Init()
	
end

function SO.Reset()
	
end

function SO.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end