--!native
--!optimize 2

local players = game:GetService("Players")

local shared = script.Parent.Parent
local utils = shared:WaitForChild("Utils")
local packages = shared:WaitForChild("Packages")

local assert = require(utils:WaitForChild("assert"))
local characterUtil = require(utils:WaitForChild("character"))

local trove = require(packages:WaitForChild("trove"))

local module = {}
module.__index = module

function module:destroy()
	if self.runTimeTrove then
		self.runTimeTrove:Clean()
	end
end

function module.new(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	assert(humanoid, "Invalid humanoid")

	local self = setmetatable({}, module)

	self.character = character
	self.player = players:GetPlayerFromCharacter(self.character)
	self.humanoid = humanoid

	self.runTimeTrove = trove.new()

	self.rootWeld = characterUtil:getRootWeld(self.character)
	if self.rootWeld then
		self.rootWeld.Enabled = true
	end

	characterUtil:toggleJoints(self.character, false)
	self.runTimeTrove:Add(function()
		characterUtil:toggleJoints(self.character, true)
	end)

	self.oldPhysicalProperties = characterUtil:disableRootPartCollision(self.character)

	local head = self.character:FindFirstChild("Head") :: BasePart
	if head then
		head.CanCollide = true
	end

	self.humanoid.AutoRotate = false

	-- troves
	self.runTimeTrove:Add(function()
		self.humanoid.AutoRotate = true
	end)

	if not self.player then
		self.humanoid:ChangeState(Enum.HumanoidStateType.Physics)

		self.runTimeTrove:Connect(
			self.humanoid.StateChanged,
			function(_: Enum.HumanoidStateType?, new: Enum.HumanoidStateType)
				if new ~= Enum.HumanoidStateType.Physics and new ~= Enum.HumanoidStateType.Dead then
					self.humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				end
			end
		)

		self.runTimeTrove:Add(function()
			if self.humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
				self.humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end

	self.runTimeTrove:Add(function()
		if self.character then
			local humanoidRootPart = self.character:FindFirstChild("HumanoidRootPart") :: BasePart?

			if humanoidRootPart then
				humanoidRootPart.CustomPhysicalProperties = self.oldPhysicalProperties
				humanoidRootPart.CanCollide = true
			end

			if head then
				head.CanCollide = false
			end
		end
	end)

	self.runTimeTrove:Add(function()
		if self.rootWeld then
			self.rootWeld.Enabled = false
		end
	end)

	return self
end

return module
