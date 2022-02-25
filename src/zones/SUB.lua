local WW = WizardsWardrobe
WW.zones["SUB"] = {}
local SUB = WW.zones["SUB"]

SUB.name = GetString(WW_SUB_NAME)
SUB.tag = "SUB"
SUB.icon = "/WizardsWardrobe/assets/zones/sub.dds"
SUB.legacyIcon = "/esoui/art/treeicons/achievements_indexicon_prologue_up.dds"
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
	
end