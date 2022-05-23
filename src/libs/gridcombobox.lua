local function CreateLabel(parent)
    local label = WINDOW_MANAGER:CreateControl(parent:GetName() .. "Label", parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, -4)
    label:SetFont("ZoFontGame")    
    return label
end

local function CreateBackdrop(parent)
    return WINDOW_MANAGER:CreateControlFromVirtual(parent:GetName() .. "Backdrop", parent, "ZO_DefaultBackdrop")
end

local function CreateButton(parent, callback)
    local button = WINDOW_MANAGER:CreateControl(parent:GetName() .. "Button", parent, CT_BUTTON)
    button:SetDimensions(16, 16)
    button:SetAnchor(CENTER, parent, RIGHT, -6, 0)
    button:SetNormalTexture("/esoui/art/buttons/scrollbox_downarrow_up.dds")
	button:SetMouseOverTexture("/esoui/art/buttons/scrollbox_downarrow_over.dds")
	button:SetPressedTexture("/esoui/art/buttons/scrollbox_downarrow_down.dds")
    button:SetClickSound(SOUNDS.DEFAULT_CLICK)
    button:SetState(BSTATE_NORMAL)
    button:SetHandler("OnClicked", callback)
    return button
end

local function CreateDropdown(control, parent)
    local dropdown = WINDOW_MANAGER:CreateControl(control:GetName() .. "Dropdown", control, CT_CONTROL)
    dropdown:SetDrawTier(DT_HIGH)
    dropdown:SetWidth(control:SetWidth())
    dropdown:SetHidden(true)
    dropdown.Toggle = function(self) self:SetHidden(not self:IsHidden()) end
    dropdown:SetAnchor(TOPLEFT, control, BOTTOMLEFT, 0, 15)
    dropdown:SetMouseEnabled(true)
    CreateBackdrop(dropdown)
    return dropdown
end

local function CreateControl(name, parent)
    local control = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    control.controls = {
        label = CreateLabel(control),
        backdrop = CreateBackdrop(control),
        button = CreateButton(control, function() control.controls.dropdown:Toggle() end),
        dropdown = CreateDropdown(control, parent),
    }
    
    control.controls.backdrop:SetMouseEnabled(true)
    control.controls.backdrop:SetHandler("OnMouseUp", function(self, mouseButton)
        if MouseIsOver(self, 0, 0, 0, 0) and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			control.controls.dropdown:Toggle()
		end
    end)
    
    return control
end

GridComboBox = {
    items = {},
    selected = nil,
    control = nil,
    dropdown = nil,
    itemsPerRow = 4,
    itemSize = 61,
    itemSpacing = 3,
    tooltips = false,
}

function GridComboBox:New(name, parent)
	data = {}
	setmetatable(data, self)
	self.__index = self
    self.control = CreateControl(name, parent)
    
    local dropdown = self.control.controls.dropdown
    local function FactoryItem()
        local item = WINDOW_MANAGER:CreateControl(nil, dropdown, CT_BUTTON)
        item.tag = WINDOW_MANAGER:CreateControl(nil, dropdown, CT_LABEL)
        item.frame = WINDOW_MANAGER:CreateControl(nil, dropdown, CT_TEXTURE)
        return item
    end
    local function ResetItem(item)
        item:SetHidden(true)
        item.tag:SetHidden(true)
        item.frame:SetHidden(true)
    end
    
    self.pool = ZO_ObjectPool:New(FactoryItem, ResetItem)
    
	return data
end

function GridComboBox:GetAnchor()
    return self.control.GetAnchor()
end

function GridComboBox:SetAnchor(point, anchorTargetControl, relativePoint, offsetX, offsetY)
    self.control:ClearAnchors()
    self.control:SetAnchor(point, anchorTargetControl, relativePoint, offsetX, offsetY)
end

function GridComboBox:GetDimensions()
    return self.control:GetDimensions()
end

function GridComboBox:SetDimensions(width, height)
    self.control:SetDimensions(width, height)
    self.control.controls.dropdown:SetWidth(width)
end

function GridComboBox:SetHidden(hidden)
    self.control:SetHidden(hidden)
    self.control.controls.dropdown:SetHidden(hidden)
end

function GridComboBox:SetItemsPerRow(itemsPerRow)
    self.itemsPerRow = itemsPerRow
end

function GridComboBox:SetItemSize(itemSize)
    self.itemSize = itemSize
end

function GridComboBox:SetItemSpacing(itemSpacing)
    self.itemSpacing = itemSpacing
end

function GridComboBox:SetTooltips(tooltips)
    self.tooltips = tooltips
end

function GridComboBox:AddItem(data)
    local item, key = self.pool:AcquireObject()
    
    local index = #self.items + 1
    
    item:SetDimensions(self.itemSize, self.itemSize)
    item:SetNormalTexture(data.icon)
	item:SetMouseOverTexture(data.icon)
	item:SetPressedTexture(data.icon)
    item:SetClickSound(SOUNDS.DEFAULT_CLICK)
    item:SetState(BSTATE_NORMAL)
    item:SetHandler("OnClicked", function() self:Select(index) end)
    item:SetDrawLayer(DL_CONTROLS)
	item:SetDrawLevel(2)
	
    item.tag:SetHidden(false)
    item.tag:SetAnchor(CENTER, item, CENTER, 0, 0)
    item.tag:SetText(data.tag)
    item.tag:SetFont("ZoFontWinH2")
    item.tag:SetDrawLayer(DL_CONTROLS)
	item.tag:SetDrawLevel(3)
	
    item.frame:SetHidden(false)
	item.frame:SetDimensions(self.itemSize, self.itemSize)
	item.frame:SetAnchor(CENTER, item, CENTER, 0, 0)
	item.frame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
    item.frame:SetDrawLayer(DL_CONTROLS)
	item.frame:SetDrawLevel(4)
	
    item.data = data
    
    table.insert(self.items, key)

    self:Refresh()
end

function GridComboBox:RemoveItem(index)
    local key = self.items[index]
    self.pool:ReleaseObject(key)
    table.remove(self.items, index)
    self:Refresh()
end

function GridComboBox:ClearItems()
    for i = 1, #self.items do
        local key = self.items[i]
        self.pool:ReleaseObject(key)

    end
    self.items = {}
    self:Refresh()
end

function GridComboBox:Refresh()
    local itemCount = #self.items
    
    for i = 1, itemCount do
        local item = self.pool:AcquireObject(self.items[i])
        
        i = i - 1
        
        local x = (i % self.itemsPerRow) * (self.itemSize + self.itemSpacing) - 1
        local y = zo_floor(i / self.itemsPerRow) * (self.itemSize + self.itemSpacing)
        
        item:SetAnchor(TOPLEFT, item:GetParent(), TOPLEFT, x, y)
    end
    
    local dropdownHeight = (zo_floor(itemCount / self.itemsPerRow) + 1) * (self.itemSize + self.itemSpacing)
    self.control.controls.dropdown:SetHeight(dropdownHeight)
    local dropdownWidth = self.itemsPerRow * self.itemSize + (self.itemsPerRow - 1) * self.itemSpacing
    if dropdownWidth > self.control:GetWidth() then
        self.control.controls.dropdown:SetWidth(dropdownWidth)
    end
end

function GridComboBox:ToggleDropdown()
    self.control.controls.dropdown:Toggle()
end

function GridComboBox:Select(index)
    local item = self.pool:AcquireObject(self.items[index])
    self.control.controls.label:SetText(tostring(item.data.label))
    self.control.controls.dropdown:SetHidden(true)
    item.data.callback()
end

function GridComboBox:SetLabel(text)
    self.control.controls.label:SetText(tostring(text))
end