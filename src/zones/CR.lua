local WW = WizardsWardrobe
WW.zones["CR"] = {}
local CR = WW.zones["CR"]

CR.name = GetString(WW_CR_NAME)
CR.tag = "CR"
CR.icon = "/WizardsWardrobe/assets/zones/cr.dds"
CR.legacyIcon = "/esoui/art/treeicons/tutorial_idexicon_summerset_up.dds.dds"
CR.priority = 7
CR.id = 1051

CR.bosses = {
	[1] = {
		name = GetString(WW_CR_ZMAJA),
	},
	[2] = {
		name = GetString(WW_CR_GALENWE),
	},
	[3] = {
		name = GetString(WW_CR_SIRORIA),
	},
	[4] = {
		name = GetString(WW_CR_RELEQUEN),
	},
}

function CR.Init()
	CR.lastBoss1 = ""
	CR.lastBoss2 = ""
	CR.lastBoss3 = ""
end

function CR.Reset()
	
end

function CR.OnBossChange(bossName)
	CR.lastBoss3 = CR.lastBoss2
	CR.lastBoss2 = CR.lastBoss1
	CR.lastBoss1 = bossName
	
	-- dont change if boss - trash - boss
	if CR.lastBoss1 == CR.lastBoss3 and CR.lastBoss2 == "" then
		return
	end
	
	-- no trash setup in CR
	if #bossName == 0 then
		return
	end
	
	local pageId = WW.GetSelectedPage(CR)
	local index = CR.lookupBosses[bossName]
	
	local loaded = WW.LoadSetup(CR, pageId, index, true)
	
	-- load substitute setup
	if loaded == nil then
		index = 2
		WW.LoadSetupSubstitute(index)
	end
end