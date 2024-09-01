--!native
--!optimize 2

local shared = script.Parent.Shared
local constants = require(shared.Constants)

local ragdollServiceClient = {}

for _, component: ModuleScript in script.Components:GetChildren() do
    if not component:IsA('ModuleScript') then
        continue
    end

    require(component)
end

if constants.RENDER_PLAYER_CHARACTERS_ON_CLIENT_AFTER_DIED then
    require(script.RenderCharacters)
end

return ragdollServiceClient