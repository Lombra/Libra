local Libra = LibStub("Libra")
local Type, Version = "ScrollFrame", 1
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local ScrollFrame = Libra.modules[Type]

ScrollFrame.FauxPrototype = ScrollFrame.FauxPrototype or CreateFrame("ScrollFrame")
ScrollFrame.HybridPrototype = ScrollFrame.HybridPrototype or CreateFrame("ScrollFrame")

local fauxMT = {__index = ScrollFrame.FauxPrototype}
local hybridMT = {__index = ScrollFrame.HybridPrototype}

local function fauxOnVerticalScroll(self, offset)
	self.Scrollbar:SetValue(offset)
	self.offset = floor((offset / self.buttonHeight) + 0.5)
	self:Update()
end

local function constructor(self, type, parent, name)
	local scrollFrame
	if type == "Faux" then
		scrollFrame = setmetatable(CreateFrame("ScrollFrame", name, parent, "FauxScrollFrameTemplate"), fauxMT)
		scrollFrame:SetScript("OnVerticalScroll", fauxOnVerticalScroll)
	end
	if type == "Hybrid" then
		name = name or Libra:GetWidgetName(self.name)
		scrollFrame = setmetatable(CreateFrame("ScrollFrame", name, parent, "HybridScrollFrameTemplate"), hybridMT)
		scrollFrame.scrollBar = CreateFrame("Slider", nil, scrollFrame, "HybridScrollBarTemplate")
	end
	
	return scrollFrame
end


local fauxMethods = {
	Update = FauxScrollFrame_Update,
	SetOffset = FauxScrollFrame_SetOffset,
	GetOffset = FauxScrollFrame_GetOffset,
}

for k, v in pairs(fauxMethods) do
	ScrollFrame.FauxPrototype[k] = v
end

local hybridMethods = {
	-- Update = HybridScrollFrame_Update,
	-- SetOffset = HybridScrollFrame_SetOffset,
	GetOffset = HybridScrollFrame_GetOffset,
}

for k, v in pairs(hybridMethods) do
	ScrollFrame.HybridPrototype[k] = v
end

Libra:RegisterModule(Type, Version, constructor)