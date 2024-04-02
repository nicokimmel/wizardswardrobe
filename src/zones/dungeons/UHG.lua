local WW = WizardsWardrobe
WW.zones["UHG"] = {}
local UHG = WW.zones["UHG"]

UHG.name = GetString(WW_UHG_NAME)
UHG.tag = "UHG"
UHG.icon = "/esoui/art/icons/achievement_u25_dun2_bosses.dds"
UHG.priority = 115
UHG.id = 1153

UHG.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_UHG_HAKGRYM_THE_HOWLER),
	},
	[3] = {
		name = GetString(WW_UHG_KEEPER_OF_THE_KILN),
	},
	[4] = {
		name = GetString(WW_UHG_ETERNAL_AEGIS),
	},
	[5] = {
		name = GetString(WW_UHG_ONDAGORE_THE_MAD),
	},
	[6] = {
		name = GetString(WW_UHG_KJALNAR_TOMBSKALD),
	},
	[7] = {
		name = GetString(WW_UHG_NABOR_THE_FORGOTTEN),
	},
	[8] = {
		name = GetString(WW_UHG_VORIA_THE_HEARTH_THIEF),
	},
	[9] = {
		name = GetString(WW_UHG_VORIAS_MASTERPIECE),
	},
}

function UHG.Init()

end

function UHG.Reset()

end

function UHG.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = UHG.lookupBosses[bossName]
	WW.LoadSetup(UHG, pageId, index, true)
end
