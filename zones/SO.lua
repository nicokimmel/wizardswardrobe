local WW = WizardsWardrobe
WW.zones["SO"] = {}
local SO = WW.zones["SO"]

SO.name = GetString(WW_SO_NAME)
SO.tag = "SO"
SO.icon = "/WizardsWardrobe/assets/zones/so.dds"
SO.legacyIcon = "/esoui/art/treeicons/achievements_indexicon_dungeons_up.dds"
SO.priority = 2
SO.id = 639

SO.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_SO_MANTIKORA),
	},
	[3] = {
		name = GetString(WW_SO_TROLL),
	},
	[4] = {
		name = GetString(WW_SO_OZARA),
	},
	[5] = {
		name = GetString(WW_SO_SERPENT),
	},
}

function SO.Init()
	
end

function SO.Reset()
	
end

function SO.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end
	
	local pageId = WW.GetSelectedPage(SO)
	local index = SO.lookupBosses[bossName]
	
	local loaded = WW.LoadSetup(SO, pageId, index, true)
	
	-- load substitute setup
	if loaded == nil then
		index = 2
		if bossName == GetString(WW_TRASH) then
			index = 1
		end
		WW.LoadSetupSubstitute(index)
	end
end