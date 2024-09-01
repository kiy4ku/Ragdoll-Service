--!native
--!optimize 2

local shared = script.Parent:WaitForChild("Shared")
local constants = require(shared:WaitForChild("Constants"))

local ragdollServiceClient = {}

function newComponent(component: ModuleScript)
	if not component:IsA("ModuleScript") then
		return
	end

	require(component)
end

for _, component: ModuleScript in script:WaitForChild("Components"):GetChildren() do
	newComponent(component)
end

script.ChildAdded:Connect(function(component: ModuleScript)
	newComponent(component)
end)

if constants.RENDER_PLAYER_CHARACTERS_ON_CLIENT_AFTER_DIED then
	require(script:WaitForChild("renderCharacters"))
end

return ragdollServiceClient
