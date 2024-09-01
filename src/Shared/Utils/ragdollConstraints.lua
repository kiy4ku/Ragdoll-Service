--!native
--!optimize 2

local shared = script.Parent.Parent
local utils = shared.Utils

local characterUtil = require(utils:WaitForChild("character"))
local assert = require(utils:WaitForChild("assert"))

local constants = require(shared:WaitForChild("Constants"))

export type attachmentMapType = { [string]: { Attachment }? }
export type constraintInfoValue = {
	["Constraint"]: string,
	["Limits"]: { [string]: number },
}
export type constraintInfo = {
	[string]: constraintInfoValue,
}

local ragdollConstraints = {
	rootMotor6DNames = { "RootJoint", "Root" },
}

local function defaultConstraints(jointInfo, parent: Folder, folder: Folder)
	local ballSocketConstraint = Instance.new("BallSocketConstraint")
	ballSocketConstraint.Attachment0 = jointInfo.attachment0
	ballSocketConstraint.Attachment1 = jointInfo.attachment1

	ballSocketConstraint.LimitsEnabled = true
	ballSocketConstraint.TwistLimitsEnabled = true

	ballSocketConstraint.Name = tostring(string.gsub(jointInfo.joint.Name, "%s+", "")) .. ballSocketConstraint.Name
	ballSocketConstraint.Parent = parent

	if constants.CREATE_NO_COLLISION_CONSTRAINTS_AUTO then
		local noCollisionConstraint = Instance.new("NoCollisionConstraint")
		noCollisionConstraint.Part0 = jointInfo.joint.Part0
		noCollisionConstraint.Part1 = jointInfo.joint.Part1

		noCollisionConstraint.Name = `{jointInfo.joint.Part0.Name}<->{jointInfo.joint.Part1.Name}`
		noCollisionConstraint.Parent = folder
	end

	if constants.CREATE_NO_COLLISION_CONSTRAINTS_ROOT then
		local root = jointInfo.character:FindFirstChild("HumanoidRootPart") or jointInfo.character.PrimaryPart

		local noCollisionConstraint = Instance.new("NoCollisionConstraint")
		noCollisionConstraint.Part0 = root
		noCollisionConstraint.Part1 = jointInfo.joint.Part1

		noCollisionConstraint.Name = `{root.Name}<->{jointInfo.joint.Part1.Name}`
		noCollisionConstraint.Parent = folder
	end
end

function ragdollConstraints:rig(attachmentMap: attachmentMapType, folder: Folder, customConstraintInfo: constraintInfo?)
	for jointName, info in attachmentMap do
		local formattedJointName = self:matchJointName(jointName)
		local parent = folder:FindFirstChild(formattedJointName)
		if not parent then
			parent = Instance.new("Folder")
			parent.Name = formattedJointName
			parent.Parent = folder
		end

		if constants.USE_DEFAULT_CONSTRAINT_INFO then
			assert(constants.DEFAULT_CONSTRAINT_INFO, "Constraint info not provided")

			local jointConstraintInfo: constraintInfoValue
			if not customConstraintInfo then
				jointConstraintInfo = constants.DEFAULT_CONSTRAINT_INFO[formattedJointName]
			else
				jointConstraintInfo = customConstraintInfo[formattedJointName]
			end

			if
				(constants.USE_AUTO_CREATED_CONSTRAINTS_IF_JOINT_NOT_PROVIDED_IN_INFO and not jointConstraintInfo)
				or (constants.USE_AUTO_CREATED_CONSTRAINTS_IF_JOINT_PROVIDED_IN_INFO and jointConstraintInfo)
			then
				defaultConstraints(info, parent, folder)
				return
			end

			local success: boolean, constraint: Constraint | NoCollisionConstraint = pcall(function()
				return Instance.new(jointConstraintInfo.Constraint)
			end)
			assert(constraint and success, "Invalid constraint name provided in constraint info")

			for property, value in jointConstraintInfo.Limits do
				constraint[property] = value
			end

			constraint.Name = tostring(string.gsub(info.joint.Name, "%s+", "")) .. constraint.Name
			constraint.Parent = parent
		else
			defaultConstraints(info, parent, folder)
		end
	end
end

function ragdollConstraints:getAttachmentMap(character: Model): attachmentMapType
	assert(character:IsA("Model"), "Invalid character")
	assert(characterUtil:loaded(character), "An error occured on load character")

	local attachmentMap = {}

	for _, joint: Motor6D in pairs(character:GetDescendants()) do
		if not joint:IsA("Motor6D") or table.find(self.rootMotor6DNames, joint.Name) then
			continue
		end

		local part0, part1 = joint.Part0, joint.Part1
		if not part0 or not part1 then
			continue
		end

		local jointNameWithoutSpaces = tostring(string.gsub(joint.Name, "%s+", ""))

		local attachment0: Attachment = part0:FindFirstChild(`{jointNameWithoutSpaces}RigAttachment`)
		local attachment1: Attachment = part1:FindFirstChild(`{jointNameWithoutSpaces}RigAttachment`)

		if not attachment0 or not attachment1 then
			if attachment0 then
				attachment0:Destroy()
			end

			if attachment1 then
				attachment1:Destroy()
			end

			attachment0 = Instance.new("Attachment")
			attachment1 = Instance.new("Attachment")

			attachment0.Parent = part0
			attachment1.Parent = part1

			attachment0.Name = `{jointNameWithoutSpaces}RigAttachment`
			attachment1.Name = `{jointNameWithoutSpaces}RigAttachment`

			attachment1.Position = joint.C1.Position
			attachment0.WorldPosition = attachment1.WorldPosition
		end

		if not attachment0 or not attachment1 then
			continue
		end

		attachmentMap[joint.Name] = {
			character = character,
			joint = joint,

			attachment0 = attachment0,
			attachment1 = attachment1,
		}
	end

	return attachmentMap
end

function ragdollConstraints:matchJointName(jointName: string): string
	assert(jointName and type(jointName) == "string", "Joint Name invalid")
	return jointName:match("[A-Z]?%l*$")
end

return ragdollConstraints
