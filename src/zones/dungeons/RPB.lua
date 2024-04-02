local WW = WizardsWardrobe
WW.zones["RPB"] = {}
local RPB = WW.zones["RPB"]

RPB.name = GetString(WW_RPB_NAME)
RPB.tag = "RPB"
RPB.icon = "/esoui/art/icons/achievement_u31_dun1_vet_bosses.dds"
RPB.priority = 120
RPB.id = 1267

RPB.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_RPB_ROGERAIN_THE_SLY),
	},
	[3] = {
		name = GetString(WW_RPB_ELIAM_MERICK),
	},
	[4] = {
		name = GetString(WW_RPB_PRIOR_THIERRIC_SARAZEN),
	},
	[5] = {
		name = GetString(WW_RPB_WRAITH_OF_CROWS),
	},
	[6] = {
		name = GetString(WW_RPB_SPIDER_DEADRA),
	},
	[7] = {
		name = GetString(WW_RPB_GRIEVIOUS_TWILIGHT),
	},
}

function RPB.Init()

end

function RPB.Reset()

end

function RPB.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = RPB.lookupBosses[bossName]
	WW.LoadSetup(RPB, pageId, index, true)
end
