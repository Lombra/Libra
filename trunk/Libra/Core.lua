local MAJOR, MINOR = "Libra", 2
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

lib.modules = lib.modules or {}
lib.moduleVersions = lib.moduleVersions or {}
lib.embeds = lib.embeds or {}
lib.controls = lib.controls or {}
lib.namespaces = lib.namespaces or {}

function lib:RegisterModule(object, version, constructor)
	self.moduleVersions[object] = version
	if constructor then
		self.controls[object] = constructor
		self["Create"..object] = constructor
		for k in pairs(self.embeds) do
			k["Create"..object] = constructor
		end
	end
end

function lib:GetModuleVersion(module)
	return self.moduleVersions[module] or 0
end

function lib:Create(objectType, ...)
	return lib.controls[objectType](self, ...)
end

function lib:GetWidgetName(name)
	name = name or "Generic"
	local namespace = self.namespaces[name]
	if not namespace then
		local n = 0
		namespace = function()
			n = n + 1
			return format("%sLibraWidget%d", name, n)
		end
		self.namespaces[name] = namespace
	end
	return namespace()
end

local mixins = {
	"Create",
}

function lib:Embed(target)
	-- for i, v in ipairs(mixins) do
		-- target[v] = self[v]
	-- end
	for k, v in pairs(self.controls) do
		target["Create"..k] = v
	end
	self.embeds[target] = true
end

lib.EmbedWidgets = lib.Embed

for k in pairs(lib.embeds) do
	lib:Embed(k)
end