local WW = WizardsWardrobe
WW.zones["MGF"] = {}
local MGF = WW.zones["MGF"]

MGF.name = GetString(WW_MGF_NAME)
MGF.tag = "MGF"
MGF.icon = "/esoui/art/icons/achievement_u23_dun1_meta.dds"
MGF.priority = 113
MGF.id = 1122

MGF.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_MGF_RISEN_RUINS),
	},
	[3] = {
		name = GetString(WW_MGF_DRO_ZAKAR),
	},
	[4] = {
		name = GetString(WW_MGF_KUJO_KETHBA),
	},
	[5] = {
		name = GetString(WW_MGF_NISAAZDA),
	},
	[6] = {
		name = GetString(WW_MGF_GRUNDWULF),
	},
}

function MGF.Init()

end

function MGF.Reset()

end

function MGF.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = MGF.lookupBosses[bossName]
	WW.LoadSetup(MGF, pageId, index, true)
end
