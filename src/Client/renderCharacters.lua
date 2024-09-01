--!native
--!optimize 2

local players = game:GetService("Players")
local debris = game:GetService("Debris")

local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local shared = script.Parent.Parent:WaitForChild("Shared")

local classes = shared:WaitForChild("Classes")
local ragdollClass = require(classes:WaitForChild("ragdoll"))

local renderCharacters = {}

function onCharacterRemoving(_: Player, oldCharacter: Model)
	if not oldCharacter:FindFirstChild("Humanoid") or not oldCharacter:FindFirstChild("HumanoidRootPart") then
		return
	end

	oldCharacter.Archivable = true

	local character = oldCharacter:Clone()
	character.Name ..= "_Clone"
	character:RemoveTag("Ragdoll")

	character.Parent = workspace

	local humanoid = character:FindFirstChild("Humanoid")

	debris:addItem(oldCharacter, 0)

	if oldCharacter.Name == localPlayer.Name then
		localPlayer.Character = nil
		camera.CameraSubject = humanoid
	end

	humanoid:AddTag("Ragdoll")

	ragdollClass.new(character)

	for _, v: BasePart in character:GetDescendants() do
		if not v:IsA("BasePart") then
			continue
		end

		v:AddTag("ignoreCamera")
	end

	task.delay(players.RespawnTime, function()
		ragdollClass:destroy()
		debris:addItem(character, 0)
	end)
end

function onPlayerAdded(player: Player)
	player.CharacterRemoving:Connect(function(...)
		onCharacterRemoving(player, ...)
	end)
end

for _, player: Player in players:GetPlayers() do
	onPlayerAdded(player)
end

players.PlayerAdded:Connect(onPlayerAdded)

return renderCharacters
