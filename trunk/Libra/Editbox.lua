local Libra = LibStub("Libra")
local Type, Version = "Editbox", 1
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local Editbox = Libra.modules[Type]

local function constructor(self, parent)
	local name = Libra:GetWidgetName(self.name)
	local editbox = CreateFrame("EditBox", name, parent, "SearchBoxTemplate")
	_G[name] = nil
	return editbox
end

Libra:RegisterModule(Type, Version, constructor)