local WW = WizardsWardrobe
WW.zones["WGT"] = {}
local WGT = WW.zones["WGT"]

WGT.name = GetString(WW_WGT_NAME)
WGT.tag = "WGT"
WGT.icon = "/esoui/art/icons/achievement_ic_027_heroic.dds"
WGT.priority = 100
WGT.id = 688

WGT.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_WGT_THE_ADJUDICATOR),
	},
	[3] = {
		name = GetString(WW_WGT_THE_PLANAR_INHIBITOR),
	},
	[4] = {
		name = GetString(WW_WGT_MOLAG_KENA),
	},
}

function WGT.Init()

end

function WGT.Reset()

end

function WGT.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = WGT.lookupBosses[bossName]
	WW.LoadSetup(WGT, pageId, index, true)
end
