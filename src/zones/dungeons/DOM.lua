local WW = WizardsWardrobe
WW.zones["DOM"] = {}
local DOM = WW.zones["DOM"]

DOM.name = GetString(WW_DOM_NAME)
DOM.tag = "DOM"
DOM.icon = "/esoui/art/icons/achievement_depthsofmalatar_vet_bosses.dds"
DOM.priority = 111
DOM.id = 1081
DOM.node = 390

DOM.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_DOM_THE_SCAVENGING_MAW),
	},
	[3] = {
		name = GetString(WW_DOM_THE_WEEPING_WOMAN),
	},
	[4] = {
		name = GetString(WW_DOM_DARK_ORB),
	},
	[5] = {
		name = GetString(WW_DOM_KING_NARILMOR),
	},
	[6] = {
		name = GetString(WW_DOM_SYMPHONY_OF_BLADE),
	},
}

function DOM.Init()

end

function DOM.Reset()

end

function DOM.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = DOM.lookupBosses[bossName]
	WW.LoadSetup(DOM, pageId, index, true)
end
