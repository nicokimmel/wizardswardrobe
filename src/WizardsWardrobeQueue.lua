WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.queue = {}
local WWQ = WW.queue
WWQ.list = { first = 0, last = -1 }
local WWL = WWQ.list

function WWQ.Init()
	WWQ.name = WW.name .. "Queue"
	WWQ.queueRunning = false
	EVENT_MANAGER:RegisterForEvent( WWQ.name, EVENT_PLAYER_COMBAT_STATE, WWQ.StartQueue )
	EVENT_MANAGER:RegisterForEvent( WWQ.name, EVENT_PLAYER_REINCARNATED, WWQ.StartQueue ) -- no longer ghost
	EVENT_MANAGER:RegisterForEvent( WWQ.name, EVENT_PLAYER_ALIVE, WWQ.StartQueue )     -- revive at wayshrine
end

function WWQ.Run()
	if WWQ.queueRunning then
		return
	end

	WWQ.queueRunning = true
	while WWQ.Size() > 0
		and not IsUnitInCombat( "player" )
		and not IsUnitDeadOrReincarnating( "player" ) do
		local task = WWQ.Pop()
		task()
	end
	WWQ.queueRunning = false
end

function WWQ.Push( task, delay )
	if delay and delay > 0 then
		local delayedFunction = function()
			zo_callLater( task, delay )
		end
		WWQ.Push( delayedFunction )
		return
	end

	local last = WWL.last + 1
	WWL.last = last
	WWL[ last ] = task

	WWQ.Run()
end

function WWQ.Pop()
	if WWQ.Size() < 1 then return nil end
	local first = WWL.first
	local task = WWL[ first ]
	WWL[ first ] = nil
	WWL.first = first + 1
	return task
end

function WWQ.Size()
	return WWL.last - WWL.first + 1
end

function WWQ.Reset()
	WWL = { first = 0, last = -1 }
end

function WWQ.StartQueue()
	zo_callLater( function()
					  if WWQ.Size() > 0 and not IsUnitInCombat( "player" ) then
						  WWQ.Run()
					  end
				  end, 800 )
end
