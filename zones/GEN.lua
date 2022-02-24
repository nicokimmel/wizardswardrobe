local WW = WizardsWardrobe
WW.zones["GEN"] = {}
local GEN = WW.zones["GEN"]

GEN.name = GetString(WW_GENERAL)
GEN.tag = "GEN"
GEN.icon = "/WizardsWardrobe/assets/zones/gen.dds"
GEN.legacyIcon = "/esoui/art/treeicons/achievements_indexicon_general_up.dds"
GEN.priority = -2
GEN.id = -1

GEN.bosses = {
	[1] = {
		name = GetString(WW_EMPTY),
	},
	[2] = {
		name = GetString(WW_EMPTY),
	},
	[3] = {
		name = GetString(WW_EMPTY),
	},
	[4] = {
		name = GetString(WW_EMPTY),
	},
	[5] = {
		name = GetString(WW_EMPTY),
	},
	[6] = {
		name = GetString(WW_EMPTY),
	},
	[7] = {
		name = GetString(WW_EMPTY),
	},
	[8] = {
		name = GetString(WW_EMPTY),
	},
}

function GEN.Init()
	
end

function GEN.Reset()
	
end

function GEN.OnBossChange(bossName)
	-- load substitute setup
	if WW.settings.substitute.dungeons and GetCurrentZoneDungeonDifficulty() > 0
		or WW.settings.substitute.overland and GetCurrentZoneDungeonDifficulty() == 0 then
		
		index = 2
		if bossName == "" then
			index = 1
		end
		WW.LoadSetupSubstitute(index)
	end
end