--!strict
--!native
--!optimize 2

local collectionService = game:GetService("CollectionService")

local shared = script.Parent.Parent.Parent.Shared

local classes = shared.Classes
local packages = shared.Packages

local component = require(packages.component)
local trove = require(packages.trove)

local ragdollClass = require(classes.ragdoll)

local module = component.new({
	Tag = "Ragdoll",
})

function module:Stop()
	if not self.Instance:IsA("Humanoid") then
		return
	end

	if self.runTimeTrove then
		self.runTimeTrove:Clean()
	end
end

function module:Start()
	if not self.Instance:IsA("Humanoid") then
		return collectionService:RemoveTag(self.Instance, self.Tag)
	end

	self.Instance = self.Instance :: Humanoid

	self.character = self.Instance:FindFirstAncestorOfClass("Model")
	if not self.character then
		return collectionService:RemoveTag(self.Instance, self.Tag)
	end

	if not self.character:FindFirstChild("_ragdollConstraints") then
		collectionService:AddTag(self.Instance, "Ragdollable")
		task.wait()
	end

	self.runTimeTrove = trove.new()
	self.ragdoll = ragdollClass.new(self.character)

	self.runTimeTrove:Add(function()
		self.ragdoll:destroy()
	end)
end

return module
