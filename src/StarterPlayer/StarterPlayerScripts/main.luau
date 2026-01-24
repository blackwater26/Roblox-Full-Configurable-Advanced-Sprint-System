--[[
    Sprint Client
    Handles input, sends to server, and updates GUI
]]

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Modules
local SprintSystem = ReplicatedStorage:WaitForChild("Sprint System")
local Config = require(SprintSystem:WaitForChild("ConfigModule"))
local BodyMover = require(SprintSystem:WaitForChild("Modules"):WaitForChild("FreshBodyModuleScript"))

--// RemoteEvents
local sprintInputEvent = ReplicatedStorage:WaitForChild("SprintInputEvent")
local durabilityUpdateEvent = ReplicatedStorage:WaitForChild("DurabilityUpdateEvent")

--// Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

--// State
local isSprinting = false

--// Mock system for GUI (receives server data)
local mockSprintSystem = {
    currentDurability = Config.Sprint.DURABILITY_MAX,
    DURABILITY_MAX = Config.Sprint.DURABILITY_MAX,
    isSprinting = false,
    SprintChanged = {
        Event = { Connect = function() return {Disconnect = function() end} end },
        Fire = function() end
    }
}

--// Init GUI
task.spawn(function()
    BodyMover:Initialize(mockSprintSystem)
end)

--// Auto-stop sprint when player stops moving
RunService.Heartbeat:Connect(function()
    if isSprinting and humanoid.MoveDirection.Magnitude == 0 then
        isSprinting = false
        mockSprintSystem.isSprinting = false
        sprintInputEvent:FireServer(false)
    end
end)

--// Sprint input (LeftShift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift and humanoid.MoveDirection.Magnitude > 0 then
        isSprinting = true
        mockSprintSystem.isSprinting = true
        sprintInputEvent:FireServer(true)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift and isSprinting then
        isSprinting = false
        mockSprintSystem.isSprinting = false
        sprintInputEvent:FireServer(false)
    end
end)

--// Receive durability from server
durabilityUpdateEvent.OnClientEvent:Connect(function(durability, maxDurability)
    mockSprintSystem.currentDurability = durability
    mockSprintSystem.DURABILITY_MAX = maxDurability
end)

--// Handle respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    isSprinting = false
    mockSprintSystem.isSprinting = false
end)

print("Sprint Client initialized for", player.Name)
