local WW = WizardsWardrobe
WW.zones["COS"] = {}
local COS = WW.zones["COS"]

COS.name = GetString(WW_COS_NAME)
COS.tag = "COS"
COS.icon = "/esoui/art/icons/achievement_update11_dungeons_034.dds"
COS.priority = 103
COS.id = 848

COS.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_COS_KHEPHIDAEN),
	},
	[3] = {
		name = GetString(WW_COS_DRANOS_VELEADOR),
	},
	[4] = {
		name = GetString(WW_COS_VELIDRETH),
	},
}

function COS.Init()

end

function COS.Reset()

end

function COS.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = COS.lookupBosses[bossName]
	WW.LoadSetup(COS, pageId, index, true)
end
