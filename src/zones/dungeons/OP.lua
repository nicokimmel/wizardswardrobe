local WW = WizardsWardrobe
WW.zones["OP"] = {}
local OP = WW.zones["OP"]

OP.name = GetString(WW_OP_NAME)
OP.tag = "OP"
OP.icon = "/esoui/art/icons/achievement_u41_dun1_vet_bosses.dds"
OP.priority =  129
OP.id = 1470

OP.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_OP_B1),
	},
	[3] = {
		name = GetString(WW_OP_B2),
	},
	[4] = {
		name = GetString(WW_OP_B3),
	},
	[5] = {
		name = GetString(WW_OP_MB1),
	},[6] = {
		name = GetString(WW_OP_MB2),
	},[7] = {
		name = GetString(WW_OP_MB3),
	},
}

function OP.Init()

end

function OP.Reset()

end

function OP.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = OP.lookupBosses[bossName]
	WW.LoadSetup(OP, pageId, index, true)
end
