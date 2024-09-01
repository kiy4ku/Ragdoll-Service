--!native
--!optimize 2

local players = game:GetService("Players")
local runService = game:GetService("RunService")

local player = players.LocalPlayer

local shared = script.Parent.Parent.Parent:WaitForChild("Shared")
local packages = shared:WaitForChild("Packages")
local utils = shared:WaitForChild("Utils")

local component = require(packages.component)
local trove = require(packages.trove)

local characterUtil = require(utils.character)
local cameraSpring = require(utils.cameraSpring)

local constants = require(shared:WaitForChild("Constants"))

local camera = workspace.CurrentCamera

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
		return
	end

	self.Instance = self.Instance :: Humanoid

	self.character = self.Instance:FindFirstAncestorOfClass("Model")
	if not self.character or (self.character ~= player.Character and self.character.Name ~= `{player.Name}_Clone`) then
		return
	end

	self.runTimeTrove = trove.new()

	self.Instance:ChangeState(Enum.HumanoidStateType.Physics)

	self.Instance.EvaluateStateMachine = false
	characterUtil:toggleLimbCollisions(self.character, true)

	if constants.RAGDOLL_CAMERA_SPRING then
		self.torso = self.character:FindFirstChild("Torso") or self.character:FindFirstChild("UpperTorso")
		self.head = self.character:FindFirstChild("Head")

		if self.torso and self.head then
			self.cameraSpring = cameraSpring.new()
			self.lastVelocity = Vector3.zero

			self.runTimeTrove:BindToRenderStep("RagdollCameraSpring", Enum.RenderPriority.Camera.Value - 1, function()
				if not self.cameraSpring or not self.torso or not self.head then
					return runService:UnbindFromRenderStep("RagdollCameraSpring")
				end

				local headOffset = (self.torso.Position - self.head.Position)

				local headPosition = self.torso.CFrame:PointToWorldSpace(headOffset)

				local velocity = self.torso:GetVelocityAtPosition(headPosition)
				local relativeVelocity = velocity - self.lastVelocity

				self.cameraSpring:impulse(
					camera.CFrame:vectorToObjectSpace(camera.CFrame.lookVector:Cross(relativeVelocity)) / 12.5
				)

				self.lastVelocity = velocity
			end)
		end
	end

	-- troves
	self.runTimeTrove:Add(function()
		if self.cameraSpring then
			self.cameraSpring:destroy()
		end
	end)

	self.runTimeTrove:Add(function()
		if self.character then
			characterUtil:toggleLimbCollisions(self.character, false)
		end

		self.Instance.EvaluateStateMachine = true
	end)

	self.runTimeTrove:Connect(
		self.Instance.StateChanged,
		function(_: Enum.HumanoidStateType?, new: Enum.HumanoidStateType)
			if new ~= Enum.HumanoidStateType.Physics and new ~= Enum.HumanoidStateType.Dead then
				self.Instance:ChangeState(Enum.HumanoidStateType.Physics)
			end
		end
	)

	self.runTimeTrove:Add(function()
		self.Instance:ChangeState(Enum.HumanoidStateType.GettingUp)
	end)
end

return module
