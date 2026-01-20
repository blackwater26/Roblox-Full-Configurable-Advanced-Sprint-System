--[[
    Sprint System Configuration
    Centralized settings for sprint mechanics, GUI, and server behavior
]]

local Config = {}

--// Sprint Mechanics
Config.Sprint = {
    DURABILITY_MAX = 100,              -- Max stamina
    DURABILITY_OF_EXHAUSTION = 45,     -- Speed reduction threshold
    DURABILITY_DRAIN_RATE = 20,        -- Stamina drain/sec while sprinting
    DURABILITY_RECOVER_RATE = 12,      -- Stamina recovery/sec
    
    MAX_RUNNING_SPEED = 24,            -- Sprint speed
    NORMAL_WALKING_SPEED = 16,         -- Walk speed
    
    LAST_SPEED_SMOOTH_RATE = 8,        -- Speed lerp rate (higher = faster)
    MAX_DT = 0.05,                     -- Delta time cap (lag protection)
}

--// GUI Animation
Config.GUI = {
    TWEEN_DURATION = 0.3,
    TWEEN_EASING_STYLE = Enum.EasingStyle.Quad,
    TWEEN_EASING_DIRECTION = Enum.EasingDirection.Out,
    GUI_WAIT_TIMEOUT = 5,
}

--// GUI Bar Appearance
Config.Bar = {
    SIDE_PADDING = 10,                 -- Left/right padding (pixels)
    TOP_BOTTOM_PADDING = 3,            -- Top/bottom padding (pixels)
}

--// Server
Config.Server = {
    CHARACTER_LOAD_DELAY = 0.1,        -- Delay after spawn (seconds)
}

return Config
