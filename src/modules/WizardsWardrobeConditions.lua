WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.conditions = {}
local WWC = WW.conditions

function WWC.Init()
	WWC.name = WW.name .. "Conditions"
	
	WWC.bossList = {}
	WWC.trashList = {}
	
	WWC.cache = {
		boss = WW.CONDITIONS.EVERYWHERE
	}
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

function WWC.OnBossChange(bossName)
	if #bossName == 0 then
		local entry = WWC.trashList[WWC.cache.boss] or WWC.trashList[WW.CONDITIONS.EVERYWHERE]
		if entry and WW.settings.autoEquipSetups then
			WW.LoadSetup(entry.zone, entry.pageId, entry.index, true)
		end
	else
		local entry = WWC.bossList[bossName]
		if entry and WW.settings.autoEquipSetups then
			WW.LoadSetup(entry.zone, entry.pageId, entry.index, true)
		end
		WWC.cache.boss = bossName
	end
end