local Libra = LibStub("Libra")
local Type, Version = "Slider", 1
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local Slider = Libra.modules[Type]
Slider.Prototype = Slider.Prototype or CreateFrame("Slider")

local Prototype = Slider.Prototype
local mt = {__index = Prototype}

local backdrop = {
	bgFile = [[Interface\Buttons\UI-SliderBar-Background]],
	edgeFile = [[Interface\Buttons\UI-SliderBar-Border]],
	-- tile = true, tileSize = 8, edgeSize = 8,
	insets = {left = 3, right = 3, top = 6, bottom = 6}
}

local function constructor(self, parent)
	local slider = setmetatable(CreateFrame("Slider", nil, parent), mt)
	slider:SetSize(144, 17)
	slider:SetBackdrop(backdrop)
	slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Horizontal]])
	
	slider.text = slider:CreateFontString(nil, nil, "GameFontNormal")
	slider.text:SetPoint("BOTTOM", slider, "TOP")
	
	slider.min = slider:CreateFontString(nil, nil, "GameFontHighlightSmall")
	slider.min:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", -4, 3)
	
	slider.max = slider:CreateFontString(nil, nil, "GameFontHighlightSmall")
	slider.max:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 4, 3)
	
	slider.currentValue = slider:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	slider.currentValue:SetPoint("CENTER", 0, -15)
	
	return slider
end


local methods = {
}

for k, v in pairs(methods) do
	Prototype[k] = v
end

-- function Prototype:SetTitleText(text)
	-- self.TitleText:SetText(text)
-- end

Libra:RegisterModule(Type, Version, constructor)