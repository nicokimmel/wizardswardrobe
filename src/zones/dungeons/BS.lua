local WW = WizardsWardrobe
WW.zones["BS"] = {}
local BS = WW.zones["BS"]

BS.name = GetString(WW_BS_NAME)
BS.tag = "BS"
BS.icon = "/esoui/art/icons/achievement_u37_dun1_vet_bosses.dds"
BS.priority =  126
BS.id = 1389
BS.node = 531

BS.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_BS_B1),
	},
	[3] = {
		name = GetString(WW_BS_B2),
	},
	[4] = {
		name = GetString(WW_BS_B3),
	},
	[5] = {
		name = GetString(WW_BS_SCB),
	},
}

function BS.Init()

end

function BS.Reset()

end

function BS.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = BS.lookupBosses[bossName]
	WW.LoadSetup(BS, pageId, index, true)
end
