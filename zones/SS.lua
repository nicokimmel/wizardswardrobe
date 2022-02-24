local WW = WizardsWardrobe
WW.zones["SS"] = {}
local SS = WW.zones["SS"]

SS.name = GetString(WW_SS_NAME)
SS.tag = "SS"
SS.icon = "/WizardsWardrobe/assets/zones/ss.dds"
SS.legacyIcon = "/esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds"
SS.priority = 8
SS.id = 1121

SS.bosses = {
	[1] = {
		name = GetString(WW_TRASH),
	},
	[2] = {
		name = GetString(WW_SS_LOKKESTIIZ),
	},
	[3] = {
		name = GetString(WW_SS_YOLNAHKRIIN),
	},
	[4] = {
		name = GetString(WW_SS_NAHVIINTAAS),
	},
}

function SS.Init()
	SS.lastBoss = ""
end

function SS.Reset()
	
end

function SS.OnBossChange(bossName)
	if SS.lastBoss == GetString(WW_SS_NAHVIINTAAS) and bossName == "" then
		-- might be a portal bug
		return
	end
	SS.lastBoss = bossName
	
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end
	
	local pageId = WW.GetSelectedPage(SS)
	local index = SS.lookupBosses[bossName]
	
	local loaded = WW.LoadSetup(SS, pageId, index, true)
	
	-- load substitute setup
	if loaded == nil then
		index = 2
		if bossName == GetString(WW_TRASH) then
			index = 1
		end
		WW.LoadSetupSubstitute(index)
	end
end