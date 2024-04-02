local WW = WizardsWardrobe
WW.zones["ERE"] = {}
local ERE = WW.zones["ERE"]

ERE.name = GetString(WW_ERE_NAME)
ERE.tag = "ERE"
ERE.icon = "/esoui/art/icons/achievement_u35_dun1_vet_bosses.dds"
ERE.priority =  124
ERE.id = 1360

ERE.bosses = { [1] = {
		name = GetString(WW_TRASH),
	}, [2] = {
		name = GetString(WW_ERE_B1),
	}, [3] = {
		name = GetString(WW_ERE_B2),
	}, [4] = {
		name = GetString(WW_ERE_B3),
	}, [5] = {
		name = GetString(WW_ERE_SCB1),
	}, [6] = {
		name = GetString(WW_ERE_SCB2),
	},[7] = {
		name = GetString(WW_ERE_SCB3),
	},
}

function ERE.Init()

end

function ERE.Reset()

end

function ERE.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = ERE.lookupBosses[bossName]
	WW.LoadSetup(ERE, pageId, index, true)
end
