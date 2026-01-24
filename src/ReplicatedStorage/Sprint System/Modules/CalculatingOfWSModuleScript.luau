--[[
    Sprint Calculator
    Per-player stamina and speed calculation module
]]

local RunService = game:GetService("RunService")

local CalculateWS = {}
CalculateWS.__index = CalculateWS

function CalculateWS.new(config)
    local self = setmetatable({}, CalculateWS)
    config = config or {}

    -- Stamina settings
    self.DURABILITY_MAX = config.DURABILITY_MAX or 100
    self.DURABILITY_OF_EXHAUSTION = config.DURABILITY_OF_EXHAUSTION or 45

    self.DURABILITY_DRAIN_RATE = config.DURABILITY_DRAIN_RATE or 20
    self.DURABILITY_RECOVER_RATE = config.DURABILITY_RECOVER_RATE or 12

    -- Speed settings
    self.MAX_RUNNING_SPEED = config.MAX_RUNNING_SPEED or 24
    self.NORMAL_WALKING_SPEED = config.NORMAL_WALKING_SPEED or 16
    self.LAST_SPEED_SMOOTH_RATE = config.LAST_SPEED_SMOOTH_RATE or 8
    self.MAX_DT = config.MAX_DT or 0.05

    -- Optional input signal
    self._inputSignal = config.InputSignal or nil

    -- Runtime state
    self.lastSpeed = self.NORMAL_WALKING_SPEED
    self.currentDurability = self.DURABILITY_MAX
    self.isSprinting = false
    self.targetSpeed = self.NORMAL_WALKING_SPEED

    -- Internal flags
    self._heartbeatConn = nil
    self._inputConn = nil
    self._manualOverride = false
    self._wasExhausted = false

    -- Events
    self.DurabilityChanged = Instance.new("BindableEvent")
    self.SprintChanged = Instance.new("BindableEvent")
    self.Exhausted = Instance.new("BindableEvent")
    self._lastReportedDurability = self.currentDurability

    return self
end

--// Core calculation: update durability and speed
local function _computeTargetAndSpeed(self, dt)
    -- Update durability
    if self.isSprinting and self.currentDurability > 0 then
        self.currentDurability = self.currentDurability - self.DURABILITY_DRAIN_RATE * dt
    else
        self.currentDurability = self.currentDurability + self.DURABILITY_RECOVER_RATE * dt
    end
    self.currentDurability = math.clamp(self.currentDurability, 0, self.DURABILITY_MAX)

    -- Fire exhaustion event
    if self.currentDurability <= 0 then
        if not self._wasExhausted then
            self._wasExhausted = true
            pcall(function() self.Exhausted:Fire() end)
        end
    else
        self._wasExhausted = false
    end

    -- Calculate target speed
    if self.isSprinting and self.currentDurability > 0 then
        self.targetSpeed = self.MAX_RUNNING_SPEED
        if self.currentDurability < self.DURABILITY_OF_EXHAUSTION then
            local factor = self.currentDurability / self.DURABILITY_OF_EXHAUSTION
            self.targetSpeed = math.max(self.targetSpeed * factor, self.NORMAL_WALKING_SPEED * 0.5)
        end
    else
        self.targetSpeed = self.NORMAL_WALKING_SPEED
    end

    -- Smooth speed transition
    local alpha = math.clamp(self.LAST_SPEED_SMOOTH_RATE * dt, 0, 1)
    self.lastSpeed = self.lastSpeed + (self.targetSpeed - self.lastSpeed) * alpha
end

--// Clamp delta time for lag protection
local function safeDt(self, dt)
    return math.clamp(dt or 0, 0, self.MAX_DT)
end

local function _connectInput(self)
    if not self._inputSignal then
        return
    end

    -- support both BindableEvent (Event property) and Roblox-style :Connect()
    local connectFunc
    if self._inputSignal.Event then
        connectFunc = function(fn) return self._inputSignal.Event:Connect(fn) end
    elseif self._inputSignal.Connect then
        connectFunc = function(fn) return self._inputSignal:Connect(fn) end
    else
        return
    end

    self._inputConn = connectFunc(function(sprinting)
        -- input signal sets sprinting only when not manually overridden
        if self._manualOverride then
            return
        end
        local newState = sprinting and true or false
        if newState ~= self.isSprinting then
            self.isSprinting = newState
            pcall(function() self.SprintChanged:Fire(self.isSprinting) end)
        end
    end)
end

local function _disconnectInput(self)
    if self._inputConn then
        self._inputConn:Disconnect()
        self._inputConn = nil
    end
end

-- core heartbeat callback (internal). Exposed Tick for testing.
local function _onHeartbeat(self, dt)
    _computeTargetAndSpeed(self, dt)

    -- fire durability changed when meaningful change happened (0.5 units or integer step)
    --[[local last = self._lastReportedDurability
    if math.abs(self.currentDurability - last) >= 0.5 or math.floor(self.currentDurability) ~= math.floor(last) then
        self._lastReportedDurability = self.currentDurability
        pcall(function() self.DurabilityChanged:Fire(self.currentDurability) end)
    end]]--
end

-- public: start automatic Heartbeat updates and input binding
function CalculateWS:Start()
    if not self._heartbeatConn then
        self._heartbeatConn = RunService.Heartbeat:Connect(function(dt)
            _onHeartbeat(self, safeDt(self, dt))
        end)
    end
    if not self._inputConn then
        _connectInput(self)
    end
end

-- public: stop updates and unbind input
function CalculateWS:Stop()
    if self._heartbeatConn then
        self._heartbeatConn:Disconnect()
        self._heartbeatConn = nil
    end
    _disconnectInput(self)
end

-- fully destroy instance (events + connections)
function CalculateWS:Destroy()
    self:Stop()
    if self.DurabilityChanged then
        self.DurabilityChanged:Destroy()
        self.DurabilityChanged = nil
    end
    if self.SprintChanged then
        self.SprintChanged:Destroy()
        self.SprintChanged = nil
    end
    if self.Exhausted then
        self.Exhausted:Destroy()
        self.Exhausted = nil
    end
end

-- testable tick (callable from unit tests)
function CalculateWS:Tick(dt)
    _onHeartbeat(self, safeDt(self, dt))
end

-- API getters/setters
function CalculateWS:GetCurrentDurability()
    return self.currentDurability
end

function CalculateWS:IsSprinting()
    return self.isSprinting
end

function CalculateWS:GetCurrentSpeed()
    return self.lastSpeed
end

-- manual override setter: sets sprinting and blocks input signals until ClearManualOverride
function CalculateWS:SetSprinting(state)
    self._manualOverride = true
    local newState = state and true or false
    if newState ~= self.isSprinting then
        self.isSprinting = newState
        pcall(function() self.SprintChanged:Fire(self.isSprinting) end)
    end
end

function CalculateWS:ClearManualOverride()
    self._manualOverride = false
end

function CalculateWS:SetDurability(value)
    self.currentDurability = math.clamp(value or self.currentDurability, 0, self.DURABILITY_MAX)
end

function CalculateWS:Configure(cfg)
    cfg = cfg or {}
    self.DURABILITY_MAX = cfg.DURABILITY_MAX or self.DURABILITY_MAX
    self.DURABILITY_DRAIN_RATE = cfg.DURABILITY_DRAIN_RATE or self.DURABILITY_DRAIN_RATE
    self.DURABILITY_RECOVER_RATE = cfg.DURABILITY_RECOVER_RATE or self.DURABILITY_RECOVER_RATE
    self.MAX_RUNNING_SPEED = cfg.MAX_RUNNING_SPEED or self.MAX_RUNNING_SPEED
    self.NORMAL_WALKING_SPEED = cfg.NORMAL_WALKING_SPEED or self.NORMAL_WALKING_SPEED
    self.LAST_SPEED_SMOOTH_RATE = cfg.LAST_SPEED_SMOOTH_RATE or self.LAST_SPEED_SMOOTH_RATE
    self.MAX_DT = cfg.MAX_DT or self.MAX_DT

    -- clamp current durability to new max
    self.currentDurability = math.clamp(self.currentDurability, 0, self.DURABILITY_MAX)
end

-- convenience: access BindableEvent.Event to connect externally
function CalculateWS:GetDurabilityChangedEvent()
    return self.DurabilityChanged and self.DurabilityChanged.Event or nil
end
function CalculateWS:GetSprintChangedEvent()
    return self.SprintChanged and self.SprintChanged.Event or nil
end
function CalculateWS:GetExhaustedEvent()
    return self.Exhausted and self.Exhausted.Event or nil
end

--// The end of Module
return CalculateWS
