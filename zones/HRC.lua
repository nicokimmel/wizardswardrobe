local WW = WizardsWardrobe
WW.zones["HRC"] = {}
local HRC = WW.zones["HRC"]

HRC.name = GetString(WW_HRC_NAME)
HRC.tag = "HRC"
HRC.icon = "/WizardsWardrobe/assets/zones/hrc.dds"
HRC.legacyIcon = "/esoui/art/treeicons/achievements_indexicon_dungeons_up.dds"
HRC.priority = 3
HRC.id = 636

HRC.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_HRC_RAKOTU),
	},
	[3] = {
		name = GetString(WW_HRC_LOWER),
	},
	[4] = {
		name = GetString(WW_HRC_UPPER),
	},
	[5] = {
		name = GetString(WW_HRC_WARRIOR),
	},
}

function HRC.Init()
	
end

function HRC.Reset()
	
end

function HRC.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end
	
	local pageId = WW.GetSelectedPage(HRC)
	local index = HRC.lookupBosses[bossName]
	
	local loaded = WW.LoadSetup(HRC, pageId, index, true)
	
	-- load substitute setup
	if loaded == nil then
		index = 2
		if bossName == GetString(WW_TRASH) then
			index = 1
		end
		WW.LoadSetupSubstitute(index)
	end
end