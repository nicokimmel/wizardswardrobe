local WW = WizardsWardrobe
WW.zones["ROM"] = {}
local ROM = WW.zones["ROM"]

ROM.name = GetString(WW_ROM_NAME)
ROM.tag = "ROM"
ROM.icon = "/esoui/art/icons/achievement_u30_groupboss6.dss"
ROM.priority = 102
ROM.id = 843
ROM.node = 260

ROM.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_ROM_MIGHTY_CHUDAN),
	},
	[3] = {
		name = GetString(WW_ROM_XAL_NUR_THE_SLAVER),
	},
	[4] = {
		name = GetString(WW_ROM_TREE_MINDER_NA_KESH),
	},
}

function ROM.Init()

end

function ROM.Reset()

end

function ROM.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = ROM.lookupBosses[bossName]
	WW.LoadSetup(ROM, pageId, index, true)
end
