local WW = WizardsWardrobe
WW.zones[ "IA" ] = {}
local IA = WW.zones[ "IA" ]

IA.name = zo_strformat( "<<t:1>>", GetZoneNameById( 1436 ) )
IA.tag = "IA"
IA.icon = "/esoui/art/icons/achievement_u40_ed2_defeat_final_boss_50.dds"
IA.priority = 14
IA.id = 1436
IA.node = 550
IA.category = WW.ACTIVITIES.ENDLESS

IA.bosses = {
	[ 1 ] = {
		name = GetString( WW_TRASH ),
	},
	[ 2 ] = {
		name = GetString( WW_SUB_BOSS ),
	},
}

function IA.Init()

end

function IA.Reset()

end

function IA.OnBossChange( bossName )
	if #bossName > 0 then
		WW.conditions.OnBossChange( GetString( WW_SUB_BOSS ) )
	else
		WW.conditions.OnBossChange( bossName )
	end
end
