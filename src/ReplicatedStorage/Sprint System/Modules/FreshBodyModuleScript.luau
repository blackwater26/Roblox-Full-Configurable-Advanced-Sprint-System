--[[
    Sprint Bar GUI Controller
    Handles stamina bar display and animations
]]

--// Services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

--// Modules
local Config = require(script.Parent.Parent.ConfigModule)

--// Get SprintGui with timeout
local SprintGui = Players.LocalPlayer.PlayerGui:WaitForChild(Config.Elements.SPRINT_GUI, Config.GUI.GUI_WAIT_TIMEOUT)
if not SprintGui then
	warn(Config.Elements.SPRINT_GUI .. " not found - GUI disabled")
	return { Initialize = function() end, Cleanup = function() end }
end

--// GUI Elements
local Background = SprintGui:WaitForChild(Config.Elements.BACKGROUND)
local SprintBody = Background:WaitForChild(Config.Elements.BODY)

--// Bar padding from config
local sidePadding = Config.Bar.SIDE_PADDING
local topBottomPadding = Config.Bar.TOP_BOTTOM_PADDING

--// Initial body setup (runs once)
SprintBody.AnchorPoint = Config.Bar.ANCHOR_POINT
SprintBody.Position = UDim2.new(0, sidePadding, Config.Bar.POSITION_Y, 0)

--// Tween settings
local tweenInfo = TweenInfo.new(
	Config.GUI.TWEEN_DURATION,
	Config.GUI.TWEEN_EASING_STYLE,
	Config.GUI.TWEEN_EASING_DIRECTION
)

--// State
local BodyMover = {}
local heartbeatConnection = nil
local sprintSystemInstance = nil
local maxBodyWidth = nil

--// Update bar width based on durability
local function updateBar()
	if not sprintSystemInstance then return end
	
	-- Cache max width on first run
	if not maxBodyWidth then
		maxBodyWidth = Background.AbsoluteSize.X - (sidePadding * 2)
	end
	
	local percent = sprintSystemInstance.currentDurability / sprintSystemInstance.DURABILITY_MAX
	SprintBody.Size = UDim2.new(0, maxBodyWidth * percent, 1, -topBottomPadding * 2)
end

--// Fade out background
local function hideGUI()
	TweenService:Create(Background, tweenInfo, {BackgroundTransparency = Config.Bar.TRANSPARENCY_HIDDEN}):Play()
end

--// Fade in background
local function showGUI()
	TweenService:Create(Background, tweenInfo, {BackgroundTransparency = Config.Bar.TRANSPARENCY_VISIBLE}):Play()
end

--// Initialize with sprint system reference
function BodyMover:Initialize(sprintSystem)
	sprintSystemInstance = sprintSystem
	
	-- Toggle GUI visibility on sprint state change
	sprintSystem.SprintChanged.Event:Connect(function()
		if sprintSystem.isSprinting then
			showGUI()
		else
			hideGUI()
		end
	end)
	
	-- Update bar every frame
	heartbeatConnection = RunService.Heartbeat:Connect(updateBar)
end

--// Cleanup connections
function BodyMover:Cleanup()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

return BodyMover
