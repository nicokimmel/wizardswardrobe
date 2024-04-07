local WW = WizardsWardrobe
WW.zones["MA"] = {}
local MA = WW.zones["MA"]

MA.name = GetString(WW_MA_NAME)
MA.tag = "MA"
MA.icon = "/esoui/art/icons/store_orsiniumdlc_maelstromarena.dds"
MA.priority = 52
MA.id = 677
MA.node = 249

MA.bosses = {
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
	[8] = {
		name = GetString(WW_EMPTY),
	},
}

function MA.Init()

end

function MA.Reset()

end

function MA.OnBossChange(bossName)

end
