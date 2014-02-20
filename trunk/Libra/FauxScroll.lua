local Libra = LibStub("Libra")
local ScrollFrame = Libra:GetModule("ScrollFrame", 1)
if not ScrollFrame then return end

local FauxScrollPrototype = CreateFrame("Frame")
local mt = {__index = FauxScrollPrototype}

local function onVerticalScroll(self, offset)
	self.Scrollbar:SetValue(offset)
	self.offset = floor((offset / self.buttonHeight) + 0.5)
	self:Update()
end

local function constructor(self, parent)
	local scroll = setmetatable(CreateFrame("ScrollFrame", nil, parent, "FauxScrollFrameTemplate"), mt)
	
	scroll:SetScript("OnVerticalScroll", onVerticalScroll)
	
	return scroll
end

ScrollFrame.constructor = constructor
Libra.CreateScrollFrame = constructor

local methods = {
	Update = FauxScrollFrame_Update,
	SetOffset = FauxScrollFrame_SetOffset,
	GetOffset = FauxScrollFrame_GetOffset,
}

for k, v in pairs(methods) do
	FauxScrollPrototype[k] = v
end
