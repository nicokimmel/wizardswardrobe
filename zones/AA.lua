local WW = WizardsWardrobe
WW.zones["AA"] = {}
local AA = WW.zones["AA"]

AA.name = GetString(WW_AA_NAME)
AA.tag = "AA"
AA.icon = "/WizardsWardrobe/assets/zones/aa.dds"
AA.legacyIcon = "/esoui/art/treeicons/achievements_indexicon_dungeons_up.dds"
AA.priority = 1
AA.id = 638

AA.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_AA_STORMATRO),
	},
	[3] = {
		name = GetString(WW_AA_STONEATRO),
	},
	[4] = {
		name = GetString(WW_AA_VALARIEL),
	},
	[5] = {
		name = GetString(WW_AA_MAGE),
	},
}

function AA.Init()
	
end

function AA.Reset()
	
end

function AA.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end
	
	local pageId = WW.GetSelectedPage(AA)
	local index = AA.lookupBosses[bossName]
	
	local loaded = WW.LoadSetup(AA, pageId, index, true)
	
	-- load substitute setup
	if loaded == nil then
		index = 2
		if bossName == GetString(WW_TRASH) then
			index = 1
		end
		WW.LoadSetupSubstitute(index)
	end
end