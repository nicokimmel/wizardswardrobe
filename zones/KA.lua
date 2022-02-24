local WW = WizardsWardrobe
WW.zones["KA"] = {}
local KA = WW.zones["KA"]

KA.name = GetString(WW_KA_NAME)
KA.tag = "KA"
KA.icon = "/WizardsWardrobe/assets/zones/ka.dds"
KA.legacyIcon = "/esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds"
KA.priority = 9
KA.id = 1196

KA.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_KA_YANDIR),
	},
	[3] = {
		name = GetString(WW_KA_VROL),
	},
	[4] = {
		name = GetString(WW_KA_FALGRAVN),
	},
}

function KA.Init()
	
end

function KA.Reset()
	
end

function KA.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end
	
	local pageId = WW.GetSelectedPage(KA)
	local index = KA.lookupBosses[bossName]
	
	local loaded = WW.LoadSetup(KA, pageId, index, true)
	
	-- load substitute setup
	if loaded == nil then
		index = 2
		if bossName == GetString(WW_TRASH) then
			index = 1
		end
		WW.LoadSetupSubstitute(index)
	end
end