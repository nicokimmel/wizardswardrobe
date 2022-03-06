local WW = WizardsWardrobe
WW.zones["SS"] = {}
local SS = WW.zones["SS"]

SS.name = GetString(WW_SS_NAME)
SS.tag = "SS"
SS.icon = "/WizardsWardrobe/assets/zones/ss.dds"
SS.priority = 8
SS.id = 1121

SS.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_SS_LOKKESTIIZ),
	},
	[3] = {
		name = GetString(WW_SS_YOLNAHKRIIN),
	},
	[4] = {
		name = GetString(WW_SS_NAHVIINTAAS),
	},
}

function SS.Init()
	SS.lastBoss = ""
end

function SS.Reset()
	
end

function SS.OnBossChange(bossName)
	if SS.lastBoss == GetString(WW_SS_NAHVIINTAAS) and bossName == "" then
		-- might be a portal bug
		return
	end
	SS.lastBoss = bossName
	
	WW.conditions.OnBossChange(bossName)
end