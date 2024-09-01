--!native
--!optimize 2

local runService = game:GetService("RunService")

local shared = script.Parent.Parent
local utils = shared:WaitForChild("Utils")
local packages = shared:WaitForChild("Packages")

local springUtil = require(utils:WaitForChild("spring"))
local assert = require(utils:WaitForChild("assert"))

local trove = require(packages:WaitForChild("trove"))

local constants = require(shared:WaitForChild("Constants"))

local random = math.random
local RANDOM_AXIS_MULTIPLIER = 3

local camera = workspace.CurrentCamera

local cameraSpring = {}
cameraSpring.__index = cameraSpring

function cameraSpring.new()
	local self = setmetatable({
		__index = function(t, i)
			if i == "Damper" or i == "Speed" or i == "Spring" then
				return t.spring[i]
			end

			return rawget(t, i)
		end,
	}, cameraSpring)

	self.spring = springUtil.new(Vector3.zero)
	self.spring.Damper = constants.RAGDOLL_CAMERA_SPRING_DAMPER
	self.spring.Speed = constants.RAGDOLL_CAMERA_SPRING_SPEED

	self.runTimeTrove = trove.new()

	self.runTimeTrove:Connect(runService.RenderStepped, function(_: number)
		local position = self.spring.Position

		camera.CFrame *= CFrame.Angles(0, position.y, 0) * CFrame.Angles(position.x, 0, 0) * CFrame.Angles(
			0,
			0,
			position.z
		)
	end)

	return self
end

function cameraSpring:destroy()
	self.runTimeTrove:Clean()
end

function cameraSpring:impulse(velocity: Vector3, speed: number, damper: number)
	assert(type(damper) == "number" or damper == nil, "Invalid damper")
	assert(type(speed) == "number" or speed == nil, "Invalid speed")
	assert(typeof(velocity) == "Vector3", "Invalid velocity")

	self.spring:Impulse(velocity)
end

function cameraSpring:impulseRandomly(velocity, speed, damper)
	assert(type(damper) == "number" or damper == nil, "Invalid damper")
	assert(type(speed) == "number" or speed == nil, "Invalid speed")
	assert(typeof(velocity) == "Vector3", "Invalid velocity")

	local randomVelocity = Vector3.new(
		random() * RANDOM_AXIS_MULTIPLIER,
		random() * RANDOM_AXIS_MULTIPLIER,
		random() * RANDOM_AXIS_MULTIPLIER
	)

	return self:impulse(velocity * randomVelocity, speed, damper)
end

return cameraSpring
