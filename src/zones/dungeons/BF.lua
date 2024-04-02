local WW = WizardsWardrobe
WW.zones["BF"] = {}
local BF = WW.zones["BF"]

BF.name = GetString(WW_BF_NAME)
BF.tag = "BF"
BF.icon = "/esoui/art/icons/achievement_update15_002.dds"
BF.priority = 105
BF.id = 973

BF.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_BF_MATHGAMAIN),
	},
	[3] = {
		name = GetString(WW_BF_CAILLAOIFE),
	},
	[4] = {
		name = GetString(WW_BF_STONEHEARTH),
	},
	[5] = {
		name = GetString(WW_BF_GALCHOBHAR),
	},
	[6] = {
		name = GetString(WW_BF_GHERIG_BULLBLOOD),
	},
	[7] = {
		name = GetString(WW_BF_EARTHGORE_AMALGAM),
	},
}

function BF.Init()

end

function BF.Reset()

end

function BF.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = BF.lookupBosses[bossName]
	WW.LoadSetup(BF, pageId, index, true)
end
