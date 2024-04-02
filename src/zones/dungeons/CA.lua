local WW = WizardsWardrobe
WW.zones["CA"] = {}
local CA = WW.zones["CA"]

CA.name = GetString(WW_CA_NAME)
CA.tag = "CA"
CA.icon = "/esoui/art/icons/u33_dun1_vet_bosses.dds"
CA.priority =  122
CA.id = 1301
CA.node = 497

CA.bosses = { [1] = {
		name = GetString(WW_TRASH),
	},[2] = {
		name = GetString(WW_CA_B1),
	},[3] = {
		name = GetString(WW_CA_B2),
	},[4] = {
		name = GetString(WW_CA_B3),
	},[5] = {
		name = GetString(WW_CA_SCB1),
	},[6] = {
		name = GetString(WW_CA_SCB2),
	},[7] = {
		name = GetString(WW_CA_SCB3),
	},[8] = {
		name = GetString(WW_CA_SCB4),
	},
}

function CA.Init()

end

function CA.Reset()

end

function CA.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(TRASH)
	end

	local pageId = WW.selection.pageId
	local index = CA.lookupBosses[bossName]
	WW.LoadSetup(CA, pageId, index, true)
end
