WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.conditions = {}
local WWC = WW.conditions

function WWC.Init()
	WWC.name = WW.name .. "Conditions"
	
	WWC.bossList = {}
	WWC.trashList = {}
	
	WWC.ResetCache()
end

function WWC.LoadConditions()
	WWC.bossList = {}
	WWC.trashList = {}
	local zone = WW.selection.zone
	local pageId = WW.selection.pageId
	for entry in WW.PageIterator(zone, pageId) do
		local setup = Setup:FromStorage(zone.tag, pageId, entry.index)
		if setup:HasCondition() then
			local condition = setup:GetCondition()
			if condition.boss == GetString(WW_TRASH) then
				if condition.trash and condition.trash ~= WW.CONDITIONS.NONE then
					WWC.trashList[condition.trash] = {
						zone = zone,
						pageId = pageId,
						index = entry.index
					}
				end
			else
				WWC.bossList[condition.boss] = {
					zone = zone,
					pageId = pageId,
					index = entry.index
				}
			end
			
		end
	end
end

function WWC.ResetCache()
	WWC.cache = {
		boss = WW.CONDITIONS.EVERYWHERE
	}
end

function WWC.OnBossChange(bossName)
	local substitute = false
	if #bossName == 0 then
		local entry = WWC.trashList[WWC.cache.boss] or WWC.trashList[WW.CONDITIONS.EVERYWHERE]
		if entry and WW.settings.autoEquipSetups then
			substitute = WW.LoadSetup(entry.zone, entry.pageId, entry.index, true)
		end
	else
		local entry = WWC.bossList[bossName]
		if entry and WW.settings.autoEquipSetups then
			substitute = WW.LoadSetup(entry.zone, entry.pageId, entry.index, true)
		end
		WWC.cache.boss = bossName
	end
	if not substitute and WW.settings.autoEquipSetups then
		WWC.LoadSubstitute(bossName)
	end
end

function WWC.LoadSubstitute(bossName)
	if WW.currentZone.tag == "GEN"
		and not (WW.settings.substitute.dungeons and GetCurrentZoneDungeonDifficulty() > 0
		or WW.settings.substitute.overland and GetCurrentZoneDungeonDifficulty() == 0) then
		return
	end
	local index = 2
	if #bossName == 0 then index = 1 end
	WW.LoadSetupSubstitute(index)
end