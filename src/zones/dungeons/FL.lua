local WW = WizardsWardrobe
WW.zones["FL"] = {}
local FL = WW.zones["FL"]

FL.name = GetString(WW_FL_NAME)
FL.tag = "FL"
FL.icon = "/esoui/art/icons/achievement_fanglairpeak_veteran.dds"
FL.priority = 106
FL.id = 1009
FL.node = 341

FL.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_FL_LIZABET_CHARNIS),
	},
	[3] = {
		name = GetString(WW_FL_CADAVEROUS_BEAR),
	},
	[4] = {
		name = GetString(WW_FL_CALUURION),
	},
	[5] = {
		name = GetString(WW_FL_ULFNOR),
	},
	[6] = {
		name = GetString(WW_FL_THURVOKUN),
	},
}

function FL.Init()

end

function FL.Reset()

end

function FL.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = FL.lookupBosses[bossName]
	WW.LoadSetup(FL, pageId, index, true)
end
