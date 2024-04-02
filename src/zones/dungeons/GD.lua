local WW = WizardsWardrobe
WW.zones["GD"] = {}
local GD = WW.zones["GD"]

GD.name = GetString(WW_GD_NAME)
GD.tag = "GD"
GD.icon = "/esoui/art/icons/achievement_u35_dun2_vet_bosses.dds"
GD.priority =  125
GD.id = 1361

GD.bosses = { [1] = {
		name = GetString(WW_TRASH),
	}, [2] = {
		name = GetString(WW_GD_B1),
	}, [3] = {
		name = GetString(WW_GD_B2),
	}, [4] = {
		name = GetString(WW_GD_B3),
	}, [5] = {
		name = GetString(WW_GD_SCB1),
	}, [6] = {
		name = GetString(WW_GD_SCB2),
	},[7] = {
		name = GetString(WW_GD_SCB3),
	},
}

function GD.Init()

end

function GD.Reset()

end

function GD.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = GD.lookupBosses[bossName]
	WW.LoadSetup(GD, pageId, index, true)
end
