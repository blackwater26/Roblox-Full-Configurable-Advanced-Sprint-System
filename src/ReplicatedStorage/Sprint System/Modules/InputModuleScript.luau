--[[
    Input Module
    Handles sprint input signals (alternative to main.luau direct input)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Signal = require(game.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))

local InputModule = {}
InputModule.SprintSignal = Signal.new()

--// Bind sprint input to signal
function InputModule:Sprint()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftShift and humanoid.Velocity.Magnitude > 0 then
            self.SprintSignal:Fire(true)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftShift and humanoid.Velocity.Magnitude > 0 then
            self.SprintSignal:Fire(false)
        end
    end)
end

return InputModule
