local WW = WizardsWardrobe
WW.zones["FH"] = {}
local FH = WW.zones["FH"]

FH.name = GetString(WW_FH_NAME)
FH.tag = "FH"
FH.icon = "/esoui/art/icons/achievement_update15_008.dds"
FH.priority = 104
FH.id = 974

FH.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_FH_MORRIGH_BULLBLOOD),
	},
	[3] = {
		name = GetString(WW_FH_SIEGE_MAMMOTH),
	},
	[4] = {
		name = GetString(WW_FH_CERNUNNON),
	},
	[5] = {
		name = GetString(WW_FH_DEATHLORD_BJARFRUD_SKJORALMOR),
	},
	[6] = {
		name = GetString(WW_FH_DOMIHAUS_THE_BLOODY_HORNED),
	},
}

function FH.Init()

end

function FH.Reset()

end

function FH.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = FH.lookupBosses[bossName]
	WW.LoadSetup(FH, pageId, index, true)
end
