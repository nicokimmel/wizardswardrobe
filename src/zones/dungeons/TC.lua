local WW = WizardsWardrobe
WW.zones["TC"] = {}
local TC = WW.zones["TC"]

TC.name = GetString(WW_TC_NAME)
TC.tag = "TC"
TC.icon = "/esoui/art/icons/achievement_u29_dun2_vet_bosses.dds"
TC.priority = 119
TC.id = 1229
TC.node = 454

TC.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_TC_OXBLOOD_THE_DEPRAVED),
	},
	[3] = {
		name = GetString(WW_TC_TASKMASTER_VICCIA),
	},
	[4] = {
		name = GetString(WW_TC_MOLTEN_GUARDIAN),
	},
	[5] = {
		name = GetString(WW_TC_DAEDRIC_SHIELD),
	},
	[6] = {
		name = GetString(WW_TC_BARON_ZAULDRUS),
	},
}

function TC.Init()

end

function TC.Reset()

end

function TC.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = TC.lookupBosses[bossName]
	WW.LoadSetup(TC, pageId, index, true)
end
