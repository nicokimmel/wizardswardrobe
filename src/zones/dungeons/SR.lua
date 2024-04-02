local WW = WizardsWardrobe
WW.zones["SR"] = {}
local SR = WW.zones["SR"]

SR.name = GetString(WW_SR_NAME)
SR.tag = "SR"
SR.icon = "/esoui/art/icons/u33_dun2_vet_bosses.dds"
SR.priority = 123
SR.id = 1302

SR.bosses = { [1] = {
		name = GetString(WW_TRASH),
	}, [2] = {
		name = GetString(WW_SR_B1),
	}, [3] = {
		name = GetString(WW_SR_B2),
	}, [4] = {
		name = GetString(WW_SR_B3),
	}, [5] = {
		name = GetString(WW_SR_SCB1),
	}, [6] = {
		name = GetString(WW_SR_SCB2),
	},[7] = {
		name = GetString(WW_SR_SCB3),
	},
}

function SR.Init()

end

function SR.Reset()

end

function SR.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(WW_TRASH)
	end

	local pageId = WW.selection.pageId
	local index = SR.lookupBosses[bossName]
	WW.LoadSetup(SR, pageId, index, true)
end
