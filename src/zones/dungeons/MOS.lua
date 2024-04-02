local WW = WizardsWardrobe
WW.zones["MOS"] = {}
local MOS = WW.zones["MOS"]

MOS.name = GetString(WW_MOS_NAME)
MOS.tag = "MOS"
MOS.icon = "/esoui/art/icons/vmos_vet_bosses.dds"
MOS.priority = 109
MOS.id = 1055

MOS.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_MOS_WYRESS_RANGIFER),
	},
	[3] = {
		name = GetString(WW_MOS_AGHAEDH_OF_THE_SOLSTICE),
	},
	[4] = {
		name = GetString(WW_MOS_DAGRUND_THE_BULKY),
	},
	[5] = {
		name = GetString(WW_MOS_TARCYR),
	},
	[6] = {
		name = GetString(WW_MOS_BALORGH),
	},
}

function MOS.Init()

end

function MOS.Reset()

end

function MOS.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = MOS.lookupBosses[bossName]
	WW.LoadSetup(MOS, pageId, index, true)
end
