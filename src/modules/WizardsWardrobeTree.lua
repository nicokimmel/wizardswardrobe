WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe
WW.gui = WW.gui or {}
WW.gui.tree = WW.gui.tree or {}
local WWG = WW.gui
local WWT = WWG.tree
WWT.lastSelectedCategory = nil
local logger = LibDebugLogger:Create( "WizardsWardrobe/Tree" )
local icons = {
    --[[ [ 1 ] = { -- Ouroboros
        up = "/esoui/art/treeicons/ouroboros_indexicon_up.dds",
        down = "/esoui/art/treeicons/ouroboros_indexicon_down.dds",
        over = "/esoui/art/treeicons/ouroboros_indexicon.dds"
    }, ]]
    [ WW.ACTIVITIES.GENERAL ] = {
        up = "/esoui/art/treeicons/tutorial_idexicon_adventuring_up.dds",
        down = "/esoui/art/treeicons/tutorial_idexicon_adventuring_down.dds",
        over = "/esoui/art/treeicons/tutorial_idexicon_adventuring.dds"
    },
    [ WW.ACTIVITIES.TRIALS ] = {
        up = "/esoui/art/treeicons/reconstruction_tabicon_trialgroup_up.dds",
        down = "/esoui/art/treeicons/reconstruction_tabicon_trialgroup_down.dds",
        over = "/esoui/art/treeicons/reconstruction_tabicon_trialgroup_over.dds"
    },
    [ WW.ACTIVITIES.DUNGEONS ] = {
        up = "/esoui/art/treeicons/reconstruction_tabicon_dungeon_up.dds",
        down = "/esoui/art/treeicons/reconstruction_tabicon_dungeon_down.dds",
        over = "/esoui/art/treeicons/reconstruction_tabicon_dungeon_over.dds"
    },
    [ WW.ACTIVITIES.DLC_DUNGEONS ] = {
        up = "/esoui/art/treeicons/store_indexicon_dungdlc_up.dds",
        down = "/esoui/art/treeicons/store_indexicon_dungdlc_down.dds",
        over = "/esoui/art/treeicons/store_indexicon_dungdlc_over.dds"
    },

    [ WW.ACTIVITIES.ARENAS ] = {
        up = "/esoui/art/treeicons/reconstruction_tabicon_arenasolo_up.dds",
        down = "/esoui/art/treeicons/reconstruction_tabicon_arenasolo_down.dds",
        over = "/esoui/art/treeicons/reconstruction_tabicon_arenasolo_over.dds"
    },
    [ WW.ACTIVITIES.ENDLESS ] = {
        up = "/esoui/art/treeicons/tutorial_endlessdungeon_up.dds",
        down = "/esoui/art/treeicons/tutorial_endlessdungeon_down.dds",
        over = "/esoui/art/treeicons/tutorial_endlessdungeon_over.dds"
    },
    [ WW.ACTIVITIES.MISC ] = {
        up = "/esoui/art/treeicons/reconstruction_tabicon_misc_up.dds",
        down = "/esoui/art/treeicons/reconstruction_tabicon_misc_down.dds",
        over = "/esoui/art/treeicons/reconstruction_tabicon_misc_over.dds"
    },

}
local INDENT = 60                -- how far the child entries are from parent
local CHILD_SPACING = 0          --?
local TREE_WIDTH = 300           -- width of the tree
local TEXT_LABEL_MAX_WIDTH = 300 -- max width of the text label




function WWT.GetCategoryName( categoryKey )
    if categoryKey == WW.ACTIVITIES.GENERAL then
        return "General"
    elseif categoryKey == WW.ACTIVITIES.TRIALS then
        return "Trials"
    elseif categoryKey == WW.ACTIVITIES.DUNGEONS then
        return "Dungeons"
    elseif categoryKey == WW.ACTIVITIES.DLC_DUNGEONS then
        return "DLC Dungeons"
    elseif categoryKey == WW.ACTIVITIES.ARENAS then
        return "Arenas"
    elseif categoryKey == WW.ACTIVITIES.MISC then
        return "Misc"
    elseif categoryKey == WW.ACTIVITIES.ENDLESS then
        return "Endless Dungeons"
    end
    --TODO: Translations
end

local function baseTreeHeaderIconSetup( control, data, open )
    local icon = icons[ data.category ]
    control.icon:SetTexture( open and icon.down or icon.up )
    control.iconHighlight:SetTexture( icon.over )
    local ENABLED = true
    local DISABLE_SCALING = false -- should scale icon when selected, currently not working for some reason
    ZO_IconHeader_Setup( control, open, ENABLED, DISABLE_SCALING )
end

local function baseTreeHeaderSetup( control, data, open, isChildless )
    control.text:SetDimensionConstraints( 0, 0, TEXT_LABEL_MAX_WIDTH, 0 )
    control.text:SetModifyTextType( MODIFY_TEXT_TYPE_UPPERCASE )
    if not isChildless then
        control.text:SetText( data.name )
    end

    baseTreeHeaderIconSetup( control, data, open )
end

local function categoryHeaderSetup_Parent( node, control, data, open, userRequested )
    baseTreeHeaderSetup( control, data, open )
    if open and userRequested then
        WWT.tree:SelectFirstChild( node )
    end
end

local function categoryHeaderSetup_Childless( node, control, data, open, userRequested )
    local name = WWT.GetCategoryName( data.category )
    control.text:SetText( name )
    local pages = WW.pages[ data.tag ]
    local t = {}
    -- control:SetText( data.name )
    if pages then
        for k, v in pairs( pages ) do
            t[ #t + 1 ] = v.name
        end
        local tooltip = table.concat( t, "\n" )


        control:SetHandler( "OnMouseEnter", function( self )
            InitializeTooltip( InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT )
            SetTooltipText( InformationTooltip, tooltip )
        end )
        control:SetHandler( "OnMouseExit", function()
            ClearTooltip( InformationTooltip )
        end )
    end
    baseTreeHeaderSetup( control, data, open, true )
end

local function treeEntrySelected( control, data, selected, reselectingDuringRebuild )
    if selected then
        WW.gui.OnZoneSelect( data )
    end
    control:SetSelected( selected )
end

local function treeEntrySelected_Childless( control, data, selected, reselectingDuringRebuild )
    treeEntrySelected( control, data, selected, reselectingDuringRebuild )
    baseTreeHeaderIconSetup( control, data, selected )
end



local function treeEntrySetup( node, control, data, open )
    local pages = WW.pages[ data.tag ]
    local t = {}
    control:SetText( data.name )
    if pages then
        for k, v in pairs( pages ) do
            t[ #t + 1 ] = v.name
        end
        local tooltip = table.concat( t, "\n" )


        control:SetHandler( "OnMouseEnter", function( self )
            InitializeTooltip( InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT )
            SetTooltipText( InformationTooltip, tooltip )
        end )
        control:SetHandler( "OnMouseExit", function()
            ClearTooltip( InformationTooltip )
        end )
    end
end




local function addNodes( tree, categoryKey, entries )
    local headerName = WWT.GetCategoryName( categoryKey )
    logger:Debug( "Adding nodes to category: " .. categoryKey )

    categoryKey = tonumber( categoryKey )


    local headerNode
    if #entries > 1 then
        headerNode = tree:AddNode( "ZO_IconHeader", { name = headerName, category = categoryKey } )
    end
    --TODO: SortSetting?
    table.sort( entries, function( a, b )
        return a.priority < b.priority
    end )
    for entryKey, zone in ipairs( entries ) do
        if #entries == 1 then
            local childNode = tree:AddNode( "ZO_IconChildlessHeader", zone ) -- add childless node
            if childNode then
                logger:Debug( "ChildNode: " .. childNode.data.name )
            end
        else
            logger:Info( "Adding node: " .. zone.name .. " to " .. headerName .. " entryKey = " .. entryKey )
            local childNode = tree:AddNode( "ZO_TreeLabelSubCategory", zone, headerNode ) -- add child node
            if childNode then
                logger:Debug( "ChildNode: " .. childNode.data.name )
            end
        end
    end
    if headerNode then
        headerNode:SetOpen( false, true )
    end
end

local function addCategoriesToTree( tree )
    logger:Info( "Adding categories to tree" )
    local zones = WWG.GetSortedZoneList()

    local sortedCategoryNames = {
        [ 1 ] = {},
        [ 2 ] = {},
        [ 3 ] = {},
        [ 4 ] = {},
        [ 5 ] = {},
    }

    for key, subTable in pairs( zones ) do -- make proper table to use
        logger:Debug( "Adding " .. subTable.name .. " to the tree: category: " .. subTable.category )
        if not sortedCategoryNames[ subTable.category ] then
            sortedCategoryNames[ subTable.category ] = {}
        end

        sortedCategoryNames[ subTable.category ][ # sortedCategoryNames[ subTable.category ] + 1 ] = subTable
    end


    -- Add the categories and nodes to the tree
    for categoryKey, entries in ipairs( sortedCategoryNames ) do
        logger:Warn( "AddCategoriesToTree: Adding category: " .. categoryKey )
        addNodes( tree, categoryKey, entries )
    end
end
function WWT:RefreshTree( tree )
    if not tree then
        logger:Debug( "RefreshTree: No tree" )
        return
    end
    -- Remove all nodes
    tree:Reset()
    -- Add nodes back
    addCategoriesToTree( tree )
    tree:RefreshVisible()
    tree:SetSuspendAnimations( false )
end

local function createTree()
    logger:Debug( "Creating Tree" )
    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual( "WizardsWardrobeWindowZoneScrollContainer",
        WizardsWardrobeWindowZone,
        "ZO_ScrollContainer" )
    scrollContainer:SetAnchor( TOPLEFT, WizardsWardrobeWindowZone, TOPLEFT, 0, 50 )
    scrollContainer:SetAnchor( BOTTOMRIGHT, WizardsWardrobeWindowZone, BOTTOMRIGHT, -200, -20 )
    local scrollContainerWidth = scrollContainer:GetWidth()
    local treeContainer = scrollContainer:GetNamedChild( "ScrollChild" )
    WWT.tree = ZO_Tree:New( treeContainer, INDENT, CHILD_SPACING, scrollContainerWidth ) -- create tree
    local tree = WWT.tree
    if tree then
        logger:Debug( "Tree created" )
    else
        logger:Error( "Tree not created" )
    end
    tree:SetExclusive( true ) -- only one node can be selected at a time
    tree:AddTemplate( "ZO_TreeLabelSubCategory", treeEntrySetup, treeEntrySelected )
    tree:AddTemplate( "ZO_IconHeader", categoryHeaderSetup_Parent )
    tree:AddTemplate( "ZO_IconChildlessHeader", categoryHeaderSetup_Childless, treeEntrySelected_Childless )
    addCategoriesToTree( tree ) -- add categories to tree
    tree:SetOpenAnimation( "ZO_TreeOpenAnimation" )
    tree:Commit()
    tree:SetExclusive( true )
end
function WWT:Initialize()
    logger:Debug( "Initializing Tree" )
    createTree()
end
