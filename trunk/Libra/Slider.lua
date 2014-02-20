local _, Libra = ...

local UIPanelPrototype = CreateFrame("Frame")
local mt = {__index = UIPanelPrototype}

local backdrop = {
	bgFile = [[Interface\Buttons\UI-SliderBar-Background]],
	edgeFile = [[Interface\Buttons\UI-SliderBar-Border]],
	-- tile = true, tileSize = 8, edgeSize = 8,
	insets = {left = 3, right = 3, top = 6, bottom = 6}
}

function Libra:CreateSlider()
	local panel = setmetatable(CreateFrame("Frame", nil, UIParent, "ButtonFrameTemplate"), mt)
	local slider = CreateFrame("Slider", nil, self)
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
	ShowPortrait = ButtonFrameTemplate_ShowPortrait,
	HidePortrait = ButtonFrameTemplate_HidePortrait,
	ShowAttic = ButtonFrameTemplate_ShowAttic,
	HideAttic = ButtonFrameTemplate_HideAttic,
	ShowButtonBar = ButtonFrameTemplate_ShowButtonBar,
	HideButtonBar = ButtonFrameTemplate_HideButtonBar,
}

for k, v in pairs(methods) do
	UIPanelPrototype[k] = v
end

function UIPanelPrototype:SetTitleText(text)
	self.TitleText:SetText(text)
end