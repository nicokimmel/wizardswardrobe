local WW = WizardsWardrobe
WW.zones["DSR"] = {}
local DSR = WW.zones["DSR"]

DSR.name = GetString(WW_DSR_NAME)
DSR.tag = "DSR"
DSR.icon = "/esoui/art/icons/u34_vtrial_meta.dds"
DSR.priority = 11
DSR.id = 1344

DSR.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		displayName = GetString(WW_DSR_LYLANARTURLASSIL_DN),
		name = GetString(WW_DSR_LYLANARTURLASSIL),
	},
	[3] = {
		name = GetString(WW_DSR_GUARDIAN),
	},
	[4] = {
		name = GetString(WW_DSR_TALERIA),
	},
	[5] = {
		name = GetString(WW_DSR_SAILRIPPER),
	},
	[6] = {
		name = GetString(WW_DSR_BOWBREAKER),
	},
}

function DSR.Init()
	
end

function DSR.Reset()
	
end

function DSR.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end