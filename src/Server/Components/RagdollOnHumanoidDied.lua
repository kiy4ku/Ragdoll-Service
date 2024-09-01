--!strict
--!native
--!optimize 2

local collectionService = game:GetService("CollectionService")
local debris = game:GetService("Debris")
local players = game:GetService("Players")

local shared = script.Parent.Parent.Parent.Shared
local packages = shared.Packages

local component = require(packages.component)
local trove = require(packages.trove)

local constants = require(shared.Constants)

local module = component.new({
	Tag = "RagdollOnHumanoidDied",
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

	self.player = players:GetPlayerFromCharacter(self.character)

	self.runTimeTrove = trove.new()

	self.Instance.BreakJointsOnDeath = false
	self.Instance:AddTag("Ragdollable")

	-- troves
	self.runTimeTrove:Add(function()
		if self.Instance:GetState() ~= Enum.HumanoidStateType.Dead and self.Instance.Health > 0 then
			self.Instance:RemoveTag("Ragdollable")
		end
	end)

	self.runTimeTrove:Add(function()
		self.Instance.BreakJointsOnDeath = true
	end)

	self.runTimeTrove:Connect(self.Instance.Died, function()
		if constants.RENDER_PLAYER_CHARACTERS_ON_CLIENT_AFTER_DIED and self.player then
			self.player.Character = nil
			debris:AddItem(self.character, 0)
		else
			self.Instance:AddTag("Ragdoll")

			if self.player then
				local rootPart = self.character:FindFirstChild("HumanoidRootPart") or self.character.PrimaryPart
				if rootPart then
					task.wait()
					rootPart:SetNetworkOwner(self.player)
				end
			end
		end
	end)
end

return module
