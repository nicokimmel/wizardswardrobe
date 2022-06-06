local WW = WizardsWardrobe
WW.zones["SUB"] = {}
local SUB = WW.zones["SUB"]

SUB.name = GetString(WW_SUB_NAME)
SUB.tag = "SUB"
SUB.icon = "/esoui/art/icons/achievement_u23_skillmaster_darkbrotherhood.dds"
SUB.priority = -1
SUB.id = -1

SUB.bosses = {
	[1] = {
		name = GetString(WW_SUB_TRASH),
	},
	[2] = {
		name = GetString(WW_SUB_BOSS),
	},
}

function SUB.Init()
	
end

function SUB.Reset()
	
end

function SUB.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end