WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.food = {}
local WWF = WW.food
local WWQ = WW.queue

function WWF.Init()
	WWF.name = WW.name .. "Food"
	WWF.RegisterEvents()
end

function WWF.RegisterEvents()
	if WW.settings.eatBuffFood then
		EVENT_MANAGER:RegisterForEvent( WWF.name, EVENT_EFFECT_CHANGED, WWF.OnBuffFoodEnd )
		EVENT_MANAGER:AddFilterForEvent( WWF.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player" )
	else
		EVENT_MANAGER:UnregisterForEvent( WWF.name, EVENT_EFFECT_CHANGED )
	end
end

local foodTask
function WWF.OnBuffFoodEnd( _, changeType, _, effectName, _, _, _, _, _, _, _, _, _, _, _, abilityId, _ )
	if changeType ~= EFFECT_RESULT_FADED then return end
	if not IsUnitInDungeon( "player" ) and not IsPlayerInRaid() then return end
	if WasRaidSuccessful() then return end
	if not WW.lookupBuffFood[ abilityId ] then return end
	if WW.HasFoodRunning() then return end

	local foodChoice = WW.lookupBuffFood[ abilityId ]
	local foodIndex = WW.FindFood( foodChoice )

	if not foodIndex then
		WW.Log( GetString( WW_MSG_NOFOOD ), WW.LOGTYPES.ERROR )
		return
	end

	local foodLink = GetItemLink( BAG_BACKPACK, foodIndex, LINK_STYLE_DEFAULT )
	if IsUnitInCombat( "player" ) then
		WW.Log( GetString( WW_MSG_FOOD_COMBAT ), WW.LOGTYPES.INFO, nil, foodLink )
	else
		WW.Log( GetString( WW_MSG_FOOD_FADED ), WW.LOGTYPES.NORMAL, nil, foodLink )
	end

	foodTask = function()
		if WW.HasFoodRunning() then return end
		CallSecureProtected( "UseItem", BAG_BACKPACK, foodIndex )

		-- check if eaten
		-- API cannot track sprinting
		zo_callLater( function()
			if not WW.HasFoodRunning() then
				WWQ.Push( foodTask )
			end
		end, 1000 )
	end
	WWQ.Push( foodTask )
end
