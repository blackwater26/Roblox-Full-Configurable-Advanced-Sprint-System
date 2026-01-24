--[[
    Sprint Server
    Handles client input and manages sprint calculations server-side
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// Modules
local sprintFolder = ReplicatedStorage:WaitForChild("Sprint System")
local CalculateWS = require(sprintFolder:WaitForChild("Modules"):WaitForChild("CalculatingOfWSModuleScript"))
local Config = require(sprintFolder:WaitForChild("ConfigModule"))

--// RemoteEvents (create if not exists)
local sprintInputEvent = ReplicatedStorage:FindFirstChild("SprintInputEvent") or Instance.new("RemoteEvent")
sprintInputEvent.Name = "SprintInputEvent"
sprintInputEvent.Parent = ReplicatedStorage

local durabilityUpdateEvent = ReplicatedStorage:FindFirstChild("DurabilityUpdateEvent") or Instance.new("RemoteEvent")
durabilityUpdateEvent.Name = "DurabilityUpdateEvent"
durabilityUpdateEvent.Parent = ReplicatedStorage

--// Active player systems
local playerSystems = {}

--// Setup sprint system for player
local function setupPlayer(player)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Create sprint system for this player (using centralized config)
    local sprintSystem = CalculateWS.new(Config.Sprint)
    
    sprintSystem:Start()
    
    -- Store system
    playerSystems[player] = {
        system = sprintSystem,
        humanoid = humanoid,
        character = character
    }
    
    -- Update walkspeed every frame
    local heartbeatConn = RunService.Heartbeat:Connect(function()
        if playerSystems[player] then
            local currentSpeed = sprintSystem:GetCurrentSpeed()
            humanoid.WalkSpeed = currentSpeed
            
            -- Send durability to client for GUI
            durabilityUpdateEvent:FireClient(player, sprintSystem.currentDurability, sprintSystem.DURABILITY_MAX)
        end
    end)
    
    playerSystems[player].heartbeatConn = heartbeatConn
    
    print("Sprint system initialized for", player.Name)
end

--// Cleanup player system
local function cleanupPlayer(player)
    local data = playerSystems[player]
    if data then
        if data.system then
            data.system:Stop()
        end
        if data.heartbeatConn then
            data.heartbeatConn:Disconnect()
        end
        playerSystems[player] = nil
    end
end

--// Handle sprint input from client
sprintInputEvent.OnServerEvent:Connect(function(player, isSprinting)
    local data = playerSystems[player]
    if not data then return end
    
    -- Validate input
    if typeof(isSprinting) ~= "boolean" then return end
    
    -- Set sprinting state
    data.system:SetSprinting(isSprinting)
end)

--// Setup existing players
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        setupPlayer(player)
    end
    
    player.CharacterAdded:Connect(function()
        task.wait(Config.Server.CHARACTER_LOAD_DELAY) -- Wait for character to fully load
        cleanupPlayer(player)
        setupPlayer(player)
    end)
end

--// Setup new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(Config.Server.CHARACTER_LOAD_DELAY)
        setupPlayer(player)
    end)
end)

--// Cleanup on player leave
Players.PlayerRemoving:Connect(function(player)
    cleanupPlayer(player)
end)

print("Sprint Server initialized")
