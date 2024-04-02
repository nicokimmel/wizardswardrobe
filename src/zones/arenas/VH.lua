local WW = WizardsWardrobe
WW.zones["VH"] = {}
local VH = WW.zones["VH"]

VH.name = GetString(WW_VH_NAME)
VH.tag = "VH"
VH.icon = "/esoui/art/icons/achievement_u28_varena_veteran.dds"
VH.priority = 53
VH.id = 1227
VH.node = 457

VH.bosses = {
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

function VH.Init()

end

function VH.Reset()

end

function VH.OnBossChange(bossName)

end
