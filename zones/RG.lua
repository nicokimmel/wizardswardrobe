local WW = WizardsWardrobe
WW.zones["RG"] = {}
local RG = WW.zones["RG"]

RG.name = GetString(WW_RG_NAME)
RG.tag = "RG"
RG.icon = "/WizardsWardrobe/assets/zones/rg.dds"
RG.legacyIcon = "/esoui/art/treeicons/tutorial_idexicon_blackwood_up.dds"
RG.priority = 10
RG.id = 1263

RG.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_RG_OAXILTSO),
	},
	[3] = {
		name = GetString(WW_RG_BAHSEI),
	},
	[4] = {
		name = GetString(WW_RG_XALVAKKA),
	},
	[5] = {
		name = GetString(WW_RG_SNAKE),
	},
	[6] = {
		name = GetString(WW_RG_ASHTITAN),
	},
}

function RG.Init()
	RG.lastBoss = ""
end

function RG.Reset()
	
end

function RG.OnBossChange(bossName)
	if RG.lastBoss == GetString(WW_RG_ASHTITAN) and bossName == "" then
		-- dont swap back to trash after ash titan
		return
	end
	RG.lastBoss = bossName
	
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end
	
	local pageId = WW.GetSelectedPage(RG)
	local index = RG.lookupBosses[bossName]
	
	local loaded = WW.LoadSetup(RG, pageId, index, true)
	
	-- load substitute setup
	if loaded == nil then
		index = 2
		if bossName == GetString(WW_TRASH) then
			index = 1
		end
		WW.LoadSetupSubstitute(index)
	end
end