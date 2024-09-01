--!strict
--!native
--!optimize 2

--@kiy4ku
--last updated: 28.08.2024

local runService = game:GetService('RunService')
return (runService:IsServer() and require(script.Server)) or require(script:WaitForChild('Client'))