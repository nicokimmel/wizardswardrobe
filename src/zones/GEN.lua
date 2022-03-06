local WW = WizardsWardrobe
WW.zones["GEN"] = {}
local GEN = WW.zones["GEN"]

GEN.name = GetString(WW_GENERAL)
GEN.tag = "GEN"
GEN.icon = "/WizardsWardrobe/assets/zones/gen.dds"
GEN.priority = -2
GEN.id = -1

GEN.bosses = {}

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