local WW = WizardsWardrobe
WW.zones["RG"] = {}
local RG = WW.zones["RG"]

RG.name = GetString(WW_RG_NAME)
RG.tag = "RG"
RG.icon = "/WizardsWardrobe/assets/zones/rg.dds"
RG.priority = 10
RG.id = 1263

RG.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_RG_OAXILTSO),
	},
	[3] = {
		name = GetString(WW_RG_BAHSEI),
	},
	[4] = {
		name = GetString(WW_RG_XALVAKKA),
	},
	[5] = {
		name = GetString(WW_RG_SNAKE),
	},
	[6] = {
		name = GetString(WW_RG_ASHTITAN),
	},
}

function RG.Init()
	RG.lastBoss = ""
end

function RG.Reset()
	
end

function RG.OnBossChange(bossName)
	if RG.lastBoss == GetString(WW_RG_ASHTITAN) and bossName == "" then
		-- dont swap back to trash after ash titan
		return
	end
	RG.lastBoss = bossName
	
	WW.conditions.OnBossChange(bossName)
end