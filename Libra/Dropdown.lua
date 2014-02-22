local Libra = LibStub("Libra")
local Type, Version = "Dropdown", 1
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local Dropdown = Libra.modules[Type]
Dropdown.Prototype = Dropdown.Prototype or CreateFrame("Frame")
Dropdown.objects = Dropdown.objects or {}

local Prototype = Dropdown.Prototype
local mt = {__index = Prototype}

local function setHeight() end

local function constructor(self, type, parent, name)
	local dropdown
	if type == "Menu" then
		-- adding a SetHeight dummy lets us use a simple table instead of a frame, no side effects noticed so far
		dropdown = {}
		dropdown.SetHeight = setHeight
	end
	if type == "Frame" then
		name = name or Libra:GetWidgetName(self.name)
		dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
		dropdown.label = dropdown:CreateFontString(name.."Label", "BACKGROUND", "GameFontNormalSmall")
		dropdown.label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
	end
	
	setmetatable(dropdown, mt)
	Dropdown.objects[dropdown] = true
	
	return dropdown
end


local methods = {
	Enable = UIDropDownMenu_EnableDropDown,
	Disable = UIDropDownMenu_DisableDropDown,
	IsEnabled = UIDropDownMenu_IsEnabled,
	JustifyText = UIDropDownMenu_JustifyText,
	SetSelectedValue = UIDropDownMenu_SetSelectedValue,
	SetText = UIDropDownMenu_SetText,
	GetText = UIDropDownMenu_GetText,
	Refresh = UIDropDownMenu_Refresh,
}

for k, v in pairs(methods) do
	Prototype[k] = v
end

function Prototype:ToggleMenu(value, level, ...)
	ToggleDropDownMenu(level, value, self, ...)
end

function Prototype:HideMenu(level)
	if UIDropDownMenu_GetCurrentDropDown() == self then
		HideDropDownMenu(level)
	end
end

function Prototype:CloseMenus(level)
	if UIDropDownMenu_GetCurrentDropDown() == self then
		CloseDropDownMenus(level)
	end
end

function Prototype:AddButton(info, level)
	self.displayMode = self._displayMode
	self.selectedValue = self._selectedValue
	UIDropDownMenu_AddButton(info, level)
	self.displayMode = nil
	self.selectedValue = nil
end

function Prototype:SetSelectedValue(value, useValue)
	self._selectedValue = value
	self.selectedValue = value
	self:Refresh(useValue)
	self.selectedValue = nil
end

function Prototype:GetSelectedValue()
	return self._selectedValue
end

function Prototype:Rebuild()
	if UIDropDownMenu_GetCurrentDropDown() == self then
		level = level or 1
		local listFrame = _G["DropDownList"..level]
		local point, relativeTo, relativePoint, xOffset, yOffset = listFrame:GetPoint()
		self:HideMenu(level)
		self:ToggleMenu(listFrame.value, level)
		listFrame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
	end
end

local setWidth = Prototype.SetWidth

function Prototype:SetWidth(width, padding)
	_G[self:GetName().."Middle"]:SetWidth(width)
	local defaultPadding = 25
	if padding then
		setWidth(self, width + padding)
		_G[self:GetName().."Text"]:SetWidth(width)
	else
		setWidth(self, width + defaultPadding + defaultPadding)
		_G[self:GetName().."Text"]:SetWidth(width - defaultPadding)
	end
	self.noResize = 1
end

function Prototype:SetLabel(text)
	self.label:SetText(text)
end

function Prototype:SetEnabled(enable)
	if enable then
		self:Enable()
	else
		self:Disable()
	end
end

function Prototype:SetDisplayMode(mode)
	self._displayMode = mode
end


local function createScrollButtons(listFrame)
	local scrollUp = listFrame.scrollUp or CreateFrame("Button", nil, listFrame)
	scrollUp:SetSize(16, 16)
	scrollUp:SetPoint("TOP")
	scrollUp:SetScript("OnClick", scroll)
	scrollUp.delta = -1
	scrollUp._owner = listFrame
	listFrame.scrollUp = scrollUp

	local scrollUpTex = scrollUp:CreateTexture()
	scrollUpTex:SetAllPoints()
	scrollUpTex:SetTexture([[Interface\Calendar\MoreArrow]])
	scrollUpTex:SetTexCoord(0, 1, 1, 0)

	local scrollDown = listFrame.scrollDown or CreateFrame("Button", nil, listFrame)
	scrollDown:SetSize(16, 16)
	scrollDown:SetPoint("BOTTOM")
	scrollDown:SetScript("OnClick", scroll)
	scrollDown.delta = 1
	scrollDown._owner = listFrame
	listFrame.scrollDown = scrollDown

	local scrollDownTex = scrollDown:CreateTexture()
	scrollDownTex:SetAllPoints()
	scrollDownTex:SetTexture([[Interface\Calendar\MoreArrow]])
end

Dropdown.scrollButtons = Dropdown.scrollButtons or setmetatable({}, {
	__index = function(self, level)
		local listFrame = _G["DropDownList"..level]
		createScrollButtons(listFrame)
		self[level] = {
			up = listFrame.scrollUp,
			down = listFrame.scrollDown,
		}
		return self[level]
	end,
})

local numShownButtons

local function update(self, level)
	for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
		local button = _G["DropDownList"..level.."Button"..i]
		local _, _, _, x, y = button:GetPoint()
		local y = -((button:GetID() - 1 - self._scroll) * UIDROPDOWNMENU_BUTTON_HEIGHT) - UIDROPDOWNMENU_BORDER_HEIGHT
		button:SetPoint("TOPLEFT", x, y)
		button:SetShown(i > self._scroll and i <= (numShownButtons + self._scroll))
	end
	Dropdown.scrollButtons[level].up:SetShown(self._scroll > 0)
	Dropdown.scrollButtons[level].down:SetShown(self._scroll < _G["DropDownList"..level].numButtons - numShownButtons)
end

local function scroll(self, delta)
	self._owner._scroll = self._owner._scroll - (delta or self.delta)
	self._owner._scroll = min(self._owner._scroll, self.numButtons - numShownButtons)
	self._owner._scroll = max(self._owner._scroll, 0)
	update(self._owner, self:GetID())
end

function Dropdown:ToggleDropDownMenuHook(level, value, dropdownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
	level = level or 1
	if level ~= 1 then
		dropdownFrame = dropdownFrame or UIDROPDOWNMENU_OPEN_MENU
	end
	if not self.objects[dropdownFrame] then return end
	local listFrameName = "DropDownList"..level
	local listFrame = _G[listFrameName]
	if dropdownFrame and dropdownFrame._displayMode == "MENU" then
		_G[listFrameName.."Backdrop"]:Hide()
		_G[listFrameName.."MenuBackdrop"]:Show()
	end
	
	listFrame.value = value
	numShownButtons = floor((UIParent:GetHeight() - UIDROPDOWNMENU_BORDER_HEIGHT * 2) / UIDROPDOWNMENU_BUTTON_HEIGHT)
	local scrollable = numShownButtons < listFrame.numButtons
	if scrollable then
		-- make scrollable
		dropdownFrame._scroll = 0
		listFrame._owner = dropdownFrame
		listFrame:SetScript("OnMouseWheel", scroll)
		listFrame:SetHeight((numShownButtons * UIDROPDOWNMENU_BUTTON_HEIGHT) + (UIDROPDOWNMENU_BORDER_HEIGHT * 2))
		local point, anchorFrame, relativePoint, x, y = listFrame:GetPoint()
		local offTop = (GetScreenHeight() - listFrame:GetTop())-- / listFrame:GetScale()
		listFrame:SetPoint(point, anchorFrame, relativePoint, x, y + offTop)
		update(dropdownFrame, level)
	else
		if listFrame:GetTop() > GetScreenHeight() then
			local point, anchorFrame, relativePoint, x, y = listFrame:GetPoint()
			local offTop = (GetScreenHeight() - listFrame:GetTop())-- / listFrame:GetScale()
			listFrame:SetPoint(point, anchorFrame, relativePoint, x, y + offTop)
		end
		listFrame:SetScript("OnMouseWheel", nil)
		self.scrollButtons[level].up:Hide()
		self.scrollButtons[level].down:Hide()
	end
end

if not Dropdown.hookToggleDropDownMenu then
	hooksecurefunc("ToggleDropDownMenu", function(...)
		Dropdown:ToggleDropDownMenuHook(...)
	end)
	Dropdown.hookToggleDropDownMenu = true
end

Libra:RegisterModule(Type, Version, constructor)