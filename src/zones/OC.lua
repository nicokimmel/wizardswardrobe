local WW = WizardsWardrobe
WW.zones[ "OC" ] = {}
local OC = WW.zones[ "OC" ]

OC.name = GetString( WW_OC_NAME )
OC.tag = "OC"
OC.icon = "/esoui/art/icons/achievement_u46_vtrial_meta.dds"
OC.priority = 14
OC.id = 1548
OC.node = 589
OC.category = WW.ACTIVITIES.TRIALS

OC.bosses = {
	[ 1 ] = {
		name = GetString( WW_TRASH ),
	},
	[ 2 ] = {
		name = GetString( WW_OC_RED_WITCH_GEDNA_RELVEL ),
	},
	[ 3 ] = {
		displayName = GetString( WW_OC_HALL_OF_FLESHCRAFT ),
		name = "Shaper of Flesh",
	},
	[ 4 ] = {
		name = GetString( WW_OC_TORTURED_RANYU ),
	},
	[ 5 ] = {
		displayName = GetString( WW_OC_JYNORAH_AND_SKORKHIF ),
		name = "Jynorah",
	},
	[ 6 ] = {
		name = GetString( WW_OC_BLOOD_DRINKER_THISA ),
	},
	[ 7 ] = {
		name = GetString( WW_OC_OVERFIEND_KAZPIAN ),
	},
}

function OC.Init()

end

function OC.Reset()

end

function OC.OnBossChange( bossName )
	WW.conditions.OnBossChange( bossName )
end
