local WW = WizardsWardrobe
WW.zones["DSA"] = {}
local DSA = WW.zones["DSA"]

DSA.name = GetString(WW_DSA_NAME)
DSA.tag = "DSA"
DSA.icon = "/esoui/art/icons/achievement_026.dds"
DSA.priority = 50
DSA.id = 635

DSA.bosses = {
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

function DSA.Init()

end

function DSA.Reset()

end

function DSA.OnBossChange(bossName)

end
