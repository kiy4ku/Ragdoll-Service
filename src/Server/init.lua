--!native
--!optimize 2

local ragdollServiceServer = {}

for _, component: ModuleScript in script.Components:GetChildren() do
	if not component:IsA("ModuleScript") then
		continue
	end

	require(component)
end

return ragdollServiceServer
