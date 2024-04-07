local WW = WizardsWardrobe
WW.zones["FV"] = {}
local FV = WW.zones["FV"]

FV.name = GetString(WW_FV_NAME)
FV.tag = "FV"
FV.icon = "/esoui/art/icons/achievement_frostvault_vet_bosses.dds"
FV.priority = 110
FV.id = 1080
FV.node = 389

FV.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_FV_ICESTALKER),
	},
	[3] = {
		name = GetString(WW_FV_WARLORD_TZOGVIN),
	},
	[4] = {
		name = GetString(WW_FV_VAULT_PROTECTOR),
	},
	[5] = {
		name = GetString(WW_FV_RIZZUK_BONECHILL),
	},
	[6] = {
		name = GetString(WW_FV_THE_STONEKEEPER),
	},
}

function FV.Init()

end

function FV.Reset()

end

function FV.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = FV.lookupBosses[bossName]
	WW.LoadSetup(FV, pageId, index, true)
end
