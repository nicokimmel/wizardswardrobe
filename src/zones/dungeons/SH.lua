local WW = WizardsWardrobe
WW.zones["SH"] = {}
local SH = WW.zones["SH"]

SH.name = GetString(WW_SH_NAME)
SH.tag = "SH"
SH.icon = "/esoui/art/icons/u37_dun2_vet_bosses.dds"
SH.priority =  127
SH.id = 1390

SH.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_SH_B1),
	},
	[3] = {
		name = GetString(WW_SH_B2),
	},
	[4] = {
		name = GetString(WW_SH_B3),
	},
}

function SH.Init()

end

function SH.Reset()

end

function SH.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = SH.lookupBosses[bossName]
	WW.LoadSetup(SH, pageId, index, true)
end
