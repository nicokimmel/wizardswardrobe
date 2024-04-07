local WW = WizardsWardrobe
WW.zones["SCP"] = {}
local SCP = WW.zones["SCP"]

SCP.name = GetString(WW_SCP_NAME)
SCP.tag = "SCP"
SCP.icon = "/esoui/art/icons/achievement_scalecaller_veteran.dds"
SCP.priority = 107
SCP.id = 1010
SCP.node = 363

SCP.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_SCP_ORZUN_THE_FOUL_SMELLING),
	},
	[3] = {
		name = GetString(WW_SCP_DOYLEMISH_IRONHEARTH),
	},
	[4] = {
		name = GetString(WW_SCP_MATRIACH_ALDIS),
	},
	[5] = {
		name = GetString(WW_SCP_PLAGUE_CONCOCTER_MORTIEU),
	},
	[6] = {
		name = GetString(WW_SCP_ZAAN_THE_SCALECALLER),
	},
}

function SCP.Init()

end

function SCP.Reset()

end

function SCP.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = SCP.lookupBosses[bossName]
	WW.LoadSetup(SCP, pageId, index, true)
end
