--!native
--!optimize 2

local runService = game:GetService("RunService")
local players = game:GetService("Players")
local contentProvider = game:GetService("ContentProvider")
local debris = game:GetService("Debris")

local shared = script.Parent.Parent

local utils = shared:WaitForChild("Utils")
local assert = require(utils:WaitForChild("assert"))

local isServer = runService:IsServer()

local characterUtil = {}

function characterUtil:toggleLimbCollisions(character: Model, enabled: boolean)
	assert(character and character:IsA("Model"), "Invalid character")

	for _, limb: BasePart in character:GetChildren() do
		local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

		if not limb:IsA("BasePart") or root and limb == root then
			continue
		end
		limb.CanCollide = enabled
	end
end

function characterUtil:disableRootPartCollision(character: Model): PhysicalProperties
	assert(character and character:IsA("Model"), "Invalid character")

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	local oldProperties = humanoidRootPart.CustomPhysicalProperties
	local current = oldProperties or PhysicalProperties.new(humanoidRootPart.Material)

	humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(
		0.001,
		current.Friction,
		current.Elasticity,
		current.FrictionWeight,
		current.ElasticityWeight
	)

	humanoidRootPart.CanCollide = false

	return oldProperties
end

function characterUtil:breakJoints(character: Model)
	assert(character and character:IsA("Model"), "Invalid character")

	for _, joint: Motor6D in character:GetDescendants() do
		if joint:IsA("Motor6D") then
			joint:Destroy()
		end
	end
end

function characterUtil:toggleJoints(character: Model, enabled: boolean)
	assert(character and character:IsA("Model"), "Invalid character")

	for _, joint: Motor6D in character:GetDescendants() do
		if joint:IsA("Motor6D") then
			joint.Enabled = enabled
		end
	end
end

function characterUtil:weldRoot(character: Model): WeldConstraint
	assert(character and character:IsA("Model"), "Invalid character")
	assert(not self:getRootWeld(character), "HumanoidRootPart already welded")

	local torso = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	local rootWeld = Instance.new("WeldConstraint")
	rootWeld.Name = "_rootWeld"

	rootWeld.Part0 = humanoidRootPart
	rootWeld.Part1 = torso

	rootWeld.Enabled = false
	rootWeld.Parent = character

	return rootWeld
end

function characterUtil:getRootWeld(character: Model): WeldConstraint
	assert(character and character:IsA("Model"), "Invalid character")

	local rootWeld = character:FindFirstChild("_rootWeld")
	return rootWeld
end

function characterUtil:destroyRootWeld(character: Model)
	assert(character and character:IsA("Model"), "Invalid character")

	local rootWeld = self:getRootWeld(character)
	debris:addItem(rootWeld, 0)
end

function characterUtil:loaded(character: Model)
	assert(character and character:IsA("Model"), "Invalid character")

	local player = players:GetPlayerFromCharacter(character)
	if player then
		if not player.Character then
			return false
		end

		if player:HasAppearanceLoaded() then
			return true
		end

		if runService:IsServer() then
			player.CharacterAppearanceLoaded:Wait()
		else
			repeat
				task.wait()
			until player:HasAppearanceLoaded()
		end

		return true
	else
		if not isServer then
			contentProvider:PreloadAsync({ character })
		end

		return true
	end
end

return characterUtil
