local WW = WizardsWardrobe
WW.zones["CT"] = {}
local CT = WW.zones["CT"]

CT.name = GetString(WW_CT_NAME)
CT.tag = "CT"
CT.icon = "/esoui/art/icons/achievement_u27_dun2_vetbosses.dds"
CT.priority = 117
CT.id = 1201
CT.node = 436

CT.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_CT_DREAD_TINDULRA),
	},
	[3] = {
		name = GetString(WW_CT_BLOOD_TWILIGHT),
	},
	[4] = {
		name = GetString(WW_CT_VADUROTH),
	},
	[5] = {
		name = GetString(WW_CT_TALFYG),
	},
	[6] = {
		name = GetString(WW_CT_LADY_THORN),
	},
}

function CT.Init()

end

function CT.Reset()

end

function CT.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = CT.lookupBosses[bossName]
	WW.LoadSetup(CT, pageId, index, true)
end
