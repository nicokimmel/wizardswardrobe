local WW = WizardsWardrobe
WW.zones["SG"] = {}
local SG = WW.zones["SG"]

SG.name = GetString(WW_SG_NAME)
SG.tag = "SG"
SG.icon = "/esoui/art/icons/achievement_u27_dun1_vetbosses.dds"
SG.priority = 116
SG.id = 1197
SG.node = 433

SG.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_SG_EXARCH_KRAGLEN),
	},
	[3] = {
		name = GetString(WW_SG_STONE_BEHEMOTH),
	},
	[4] = {
		name = GetString(WW_SG_ARKASIS_THE_MAD_ALCHEMIST),
	},
}

function SG.Init()

end

function SG.Reset()

end

function SG.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = SG.lookupBosses[bossName]
	WW.LoadSetup(SG, pageId, index, true)
end
