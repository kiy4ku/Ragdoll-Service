--!strict
--!native
--!optimize 2

--@kiy4ku

local runService = game:GetService("RunService")
return (runService:IsServer() and require(script.Server)) or require(script:WaitForChild("Client"))
