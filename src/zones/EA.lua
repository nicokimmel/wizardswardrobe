local WW = WizardsWardrobe
WW.zones["EA"] = {}
local EA = WW.zones["EA"]

EA.name = zo_strformat("<<t:1>>", GetZoneNameById(1436))
EA.tag = "EA"
EA.icon = "/esoui/art/icons/achievement_u40_ed2_defeat_final_boss_50.dds"
EA.priority = 14
EA.id = 1436
EA.node = 550

EA.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_SUB_BOSS),
	},
}

function EA.Init()
	
end

function EA.Reset()
	
end

function EA.OnBossChange(bossName)
	if #bossName > 0 then
		WW.conditions.OnBossChange(GetString(WW_SUB_BOSS))
	else
		WW.conditions.OnBossChange(bossName)
	end
end
