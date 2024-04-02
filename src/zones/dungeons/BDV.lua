local WW = WizardsWardrobe
WW.zones["BDV"] = {}
local BDV = WW.zones["BDV"]

BDV.name = GetString(WW_BDV_NAME)
BDV.tag = "BDV"
BDV.icon = "/esoui/art/icons/achievement_u29_dun1_vet_bosses.dds"
BDV.priority = 118
BDV.id = 1228

BDV.bosses = { [1] = {
		name = GetString(WW_TRASH),
	}, [2] = {
		name = GetString(WW_BDV_KINRAS_IRONEYE),
	}, [3] = {
		name = GetString(WW_BDV_CAPTAIN_GEMINUS),
	}, [4] = {
		name = GetString(WW_BDV_PYROTURGE_ENCRATIS),
	}, [5] = {
		name = GetString(WW_BDV_AVATAR_OF_ZEAL),
	}, [6] = {
		name = GetString(WW_BDV_AVATAR_OF_VIGOR),
	}, [7] = {
		name = GetString(WW_BDV_AVATAR_OF_FORTITUDE),
	}, [8] = {
		name = GetString(WW_BDV_SENTINEL_AKSALAZ),
	},
}

function BDV.Init()

end

function BDV.Reset()

end

function BDV.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = BDV.lookupBosses[bossName]
	WW.LoadSetup(BDV, pageId, index, true)
end
