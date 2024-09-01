--!strict
--!native
--!optimize 2

local collectionService = game:GetService("CollectionService")

local shared = script.Parent.Parent.Parent.Shared
local packages = shared.Packages
local utils = shared.Utils

local component = require(packages.component)
local trove = require(packages.trove)

local ragdollConstraintsUtil = require(utils.ragdollConstraints)
local characterUtil = require(utils.character)

local module = component.new({
	Tag = "Ragdollable",
})

function module:Stop()
	if not self.Instance:IsA("Humanoid") then
		return
	end

	self.runTimeTrove:Clean()
end

function module:Start()
	if not self.Instance:IsA("Humanoid") then
		return collectionService:RemoveTag(self.Instance, self.Tag)
	end

	self.Instance = self.Instance :: Humanoid

	local character = self.Instance:FindFirstAncestorOfClass("Model")
	if not character or character:FindFirstChild("_ragdollConstraints") then
		return collectionService:RemoveTag(self.Instance, self.Tag)
	end

	self.constraintsFolder = Instance.new("Folder")
	self.constraintsFolder.Name = "_ragdollConstraints"
	self.constraintsFolder.Parent = character

	self.rootWeld = characterUtil:getRootWeld(character) or characterUtil:weldRoot(character)

	self.runTimeTrove = trove.new()
	self.runTimeTrove:Add(self.constraintsFolder)
	self.runTimeTrove:Add(self.rootWeld)

	ragdollConstraintsUtil:rig(ragdollConstraintsUtil:getAttachmentMap(character), self.constraintsFolder)
end

return module
