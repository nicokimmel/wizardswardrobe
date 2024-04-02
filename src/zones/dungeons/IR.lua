local WW = WizardsWardrobe
WW.zones["IR"] = {}
local IR = WW.zones["IR"]

IR.name = GetString(WW_IR_NAME)
IR.tag = "IR"
IR.icon = "/esoui/art/icons/achievement_u25_dun1_vet_bosses.dds"
IR.priority = 114
IR.id = 1152

IR.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_IR_KJARG_THE_TUSKSCRAPER),
	},
	[3] = {
		name = GetString(WW_IR_SISTER_SKELGA),
	},
	[4] = {
		name = GetString(WW_IR_VEAROGH_THE_SHAMBLER),
	},
	[5] = {
		name = GetString(WW_IR_STORMBOND_REVENANT),
	},
	[6] = {
		name = GetString(WW_IR_ICEREACH_COVEN),
	},
}

function IR.Init()

end

function IR.Reset()

end

function IR.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = IR.lookupBosses[bossName]
	WW.LoadSetup(IR, pageId, index, true)
end
