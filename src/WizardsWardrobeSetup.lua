WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe
local async = LibAsync
Setup = {
	name = GetString( WW_EMPTY ),
	disabled = false,
	condition = {},
	code = "",
	skills = {
		[ 0 ] = {},
		[ 1 ] = {},
	},
	gear = {
		mythic = nil,
	},
	cp = {},
	food = {},
}

function Setup:New( data )
	data = data or {}
	setmetatable( data, self )
	self.__index = self
	return data
end

function Setup:FromStorage( tag, pageId, index )
	local data = {
		name = GetString( WW_EMPTY ),
		disabled = false,
		condition = {},
		code = "",
		skills = {
			[ 0 ] = {},
			[ 1 ] = {},
		},
		gear = {
			mythic = nil,
		},
		cp = {},
		food = {},
	}
	if WW.setups[ tag ]
		and WW.setups[ tag ][ pageId ]
		and WW.setups[ tag ][ pageId ][ index ] then
		data = ZO_DeepTableCopy( WW.setups[ tag ][ pageId ][ index ] )
	end
	setmetatable( data, self )
	self.__index = self
	return data
end

function Setup:ToStorage( tag, pageId, index )
	if not WW.setups[ tag ] then
		WW.setups[ tag ] = {}
	end
	if not WW.setups[ tag ][ pageId ] then
		WW.setups[ tag ][ pageId ] = {}
	end
	if not WW.setups[ tag ][ pageId ][ index ] then
		WW.setups[ tag ][ pageId ][ index ] = {}
	end
	WW.setups[ tag ][ pageId ][ index ] = ZO_DeepTableCopy( self:GetData() )
end

function Setup:Clear()
	self.name = GetString( WW_EMPTY )
	self.disabled = false
	self.condition = {}
	self.code = ""
	self.skills = {
		[ 0 ] = {},
		[ 1 ] = {},
	}
	self.gear = {
		mythic = nil,
	}
	self.cp = {}
	self.food = {}
end

function Setup:GetData()
	return {
		name = self.name,
		disabled = self.disabled,
		condition = self.condition,
		code = self.code,
		skills = self.skills,
		gear = self.gear,
		cp = self.cp,
		food = self.food,
	}
end

function Setup:IsEmpty()
	local i = 0
	if next( self.skills[ 0 ] ) then i = i + 1 end
	if next( self.skills[ 1 ] ) then i = i + 1 end
	if next( self.cp ) then i = i + 1 end
	if next( self.gear ) then i = i + 1 end
	if next( self.food ) then i = i + 1 end
	if #self.code > 0 then i = i + 1 end
	return i == 0
end

function Setup:IsDisabled()
	return self.disabled
end

function Setup:SetDisabled( disabled )
	self.disabled = disabled
end

function Setup:GetName()
	return self.name
end

function Setup:SetName( name )
	self.name = name or GetString( WW_UNNAMED )
end

function Setup:HasCondition()
	if self.condition and self.condition.boss then
		return true
	end
	return false
end

function Setup:GetCondition()
	return self.condition
end

function Setup:SetCondition( conditionTable )
	self.condition = conditionTable
end

function Setup:GetCode()
	return self.code
end

function Setup:SetCode( code )
	self.code = code
end

local codeTask = async:Create( "WizardsWardrobeCustomCodeTask" )
local logger = LibDebugLogger( "WizardsWardrobe" )
function Setup:ExecuteCode( setup, zone, pageId, index, auto )
	local chat = LibChatMessage( "WW/" .. setup:GetName(), "WW" )
	logger = logger:Create( zone.name .. " -- " .. setup:GetName() )
	if not self.code then return end

	local stringTable = {}
	for match in self.code:gmatch( "<<(.-)>>" ) do
		table.insert( stringTable, match )
	end

	local immediateCode = self.code:gsub( "<<.->>", "" )

	local immediateFunc = zo_loadstring( "return function(setup, zone, pageId, index, auto, codeTask, chat, logger) " ..
		immediateCode .. " end" )
	if immediateFunc then
		immediateFunc()( setup, zone, pageId, index, auto, codeTask, chat, logger )
	end

	for i = 1, #stringTable do
		local afterCombatFunc = zo_loadstring( "return function(setup, zone, pageId, index, auto, codeTask, chat, logger) " ..
			stringTable[ i ] .. " end" )
		if afterCombatFunc then
			codeTask:WaitUntil( function() return not IsUnitInCombat( "player" ) end )
			codeTask:Then( function( task )
				afterCombatFunc()( setup, zone, pageId, index, auto, codeTask, chat, logger )
			end )
		end
	end
end

function Setup:GetSkills()
	return self.skills
end

function Setup:SetSkills( skillTable )
	self.skills = skillTable
end

function Setup:SetSkill( hotbar, slot, abilityId )
	self.skills[ hotbar ][ slot ] = abilityId
end

function Setup:GetHotbar( hotbarCategory )
	return self.skills[ hotbarCategory ]
end

function Setup:GetSkillsText()
	if not next( self.skills[ 0 ] ) and not next( self.skills[ 1 ] ) then return GetString( WW_BUTTON_SKILLS ) end
	local skillsText = {}
	for hotbar = 0, 1 do
		for slot = 3, 8 do
			local abilityId = self:GetHotbar( hotbar )[ slot ]
			if abilityId and abilityId > 0 then
				local abilityName = zo_strformat( "<<C:1>>", GetAbilityName( abilityId ) )
				table.insert( skillsText, abilityName )
			end
		end
	end
	return table.concat( skillsText, "\n" )
end

function Setup:GetGear()
	return self.gear
end

function Setup:SetGear( gearTable )
	self.gear = gearTable
	WW.markers.BuildGearList()
end

function Setup:GetGearInSlot( gearSlot )
	if self.gear[ gearSlot ] and self.gear[ gearSlot ].id ~= "0" then
		return self.gear[ gearSlot ]
	end
	return nil
end

function Setup:GetMythic()
	return self.gear.mythic, self:GetGearInSlot( self.gear.mythic )
end

function Setup:SetMythic( gearSlot )
	self.gear.mythic = gearSlot
end

function Setup:GetGearText()
	if not next( self.gear ) then return GetString( WW_BUTTON_GEAR ) end
	local gearText = {}
	for _, gearSlot in ipairs( WW.GEARSLOTS ) do
		if self.gear[ gearSlot ] then
			local link = self.gear[ gearSlot ].link
			if link and #link > 0 then
				local itemQuality = GetItemLinkDisplayQuality( link )
				local itemColor = GetItemQualityColor( itemQuality )
				local itemName = LocalizeString( "<<C:1>>", GetItemLinkName( link ) )
				if self.gear[ gearSlot ].creator then
					itemName = string.format( "%s (%s)", itemName, self.gear[ gearSlot ].creator )
				end
				table.insert( gearText, itemColor:Colorize( itemName ) )
			end
		end
	end
	return table.concat( gearText, "\n" )
end

function Setup:GetCP()
	return self.cp
end

function Setup:SetCP( cpTable )
	self.cp = cpTable
end

function Setup:GetCPText()
	if not next( self.cp ) then return GetString( WW_BUTTON_CP ) end
	local cpText = {}
	for slotIndex = 1, 12 do
		local skillId = self.cp[ slotIndex ]
		if skillId then
			local skillName = zo_strformat( "<<C:1>>", GetChampionSkillName( skillId ) )
			if #skillName > 0 then
				local line = string.format( "|c%s%s|r", WW.CPCOLOR[ slotIndex ], skillName )
				table.insert( cpText, line )
			end
		end
	end
	return table.concat( cpText, "\n" )
end

function Setup:GetFood()
	return self.food
end

function Setup:SetFood( foodTable )
	self.food = foodTable
end

function WW.MigrateSkills()
	local setupCounter = 0
	local migratedCounter = 0
	for entry in WW.SetupIterator() do
		local setup = entry.setup
		if setup.skills and type( setup.skills[ 0 ][ 3 ] ) == "table" then
			for hotbar = 0, 1 do
				for slot = 3, 8 do
					local abilityId = setup.skills[ hotbar ][ slot ].id
					setup.skills[ hotbar ][ slot ] = tonumber( abilityId )
				end
			end
			migratedCounter = migratedCounter + 1
		end
		setupCounter = setupCounter + 1
	end
	local messagePattern = "Looped through %d setups and migrated %d of them."
	WW.Log( messagePattern, WW.LOGTYPES.INFO, "FFFFFF", setupCounter, migratedCounter )
end
