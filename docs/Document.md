# Sprint System for Roblox

A complete server-authoritative sprint system with stamina management, smooth speed transitions, and GUI feedback.

## 📁 Project Structure

```
ReplicatedStorage/
└── Sprint System/
    ├── ConfigModule.luau          # Centralized configuration
    └── Modules/
        ├── CalculatingOfWSModuleScript.luau  # Core stamina/speed calculator
        ├── FreshBodyModuleScript.luau        # GUI controller
        └── InputModuleScript.luau            # Alternative input handler (optional)

ServerScriptService/
└── Sprint System/
    └── SprintServer.luau          # Server-side sprint logic

StarterPlayer/
└── StarterPlayerScripts/
    └── main.luau                  # Client input & GUI bridge
```

## 🚀 Installation

### Step 1: Setup Folders in Roblox Studio

1. In **ReplicatedStorage**, create a folder named `Sprint System`
2. In **ServerScriptService**, create a folder named `Sprint System`
3. In **StarterPlayer > StarterPlayerScripts**, this is where client scripts go

### Step 2: Add Scripts

| Script | Location | Type |
|--------|----------|------|
| `ConfigModule.luau` | ReplicatedStorage/Sprint System | ModuleScript |
| `CalculatingOfWSModuleScript.luau` | ReplicatedStorage/Sprint System/Modules | ModuleScript |
| `FreshBodyModuleScript.luau` | ReplicatedStorage/Sprint System/Modules | ModuleScript |
| `InputModuleScript.luau` | ReplicatedStorage/Sprint System/Modules | ModuleScript |
| `SprintServer.luau` | ServerScriptService/Sprint System | Script |
| `main.luau` | StarterPlayer/StarterPlayerScripts | LocalScript |

### Step 3: Create Sprint GUI

Create a ScreenGui in **StarterGui** with this structure:

```
StarterGui/
└── SprintGui (ScreenGui)
    └── Background (Frame)
        └── Body (Frame)
```

**Recommended GUI Properties:**

```lua
-- SprintGui
SprintGui.ResetOnSpawn = false
SprintGui.IgnoreGuiInset = true

-- Background (the bar container)
Background.Size = UDim2.new(0.3, 0, 0, 20)
Background.Position = UDim2.new(0.35, 0, 0.95, 0)
Background.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Background.BackgroundTransparency = 1  -- Hidden by default

-- Body (the stamina fill)
Body.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Body.BorderSizePixel = 0
```

## ⚙️ Configuration

All settings are in `ConfigModule.luau`:

### Sprint Mechanics
```lua
Config.Sprint = {
    DURABILITY_MAX = 100,              -- Maximum stamina
    DURABILITY_OF_EXHAUSTION = 45,     -- Speed reduction threshold
    DURABILITY_DRAIN_RATE = 20,        -- Stamina drain per second
    DURABILITY_RECOVER_RATE = 12,      -- Stamina recovery per second
    
    MAX_RUNNING_SPEED = 24,            -- Sprint speed
    NORMAL_WALKING_SPEED = 16,         -- Walk speed
    
    LAST_SPEED_SMOOTH_RATE = 8,        -- Speed lerp rate
    MAX_DT = 0.05,                     -- Delta time cap (lag protection)
}
```

### GUI Settings
```lua
Config.GUI = {
    TWEEN_DURATION = 0.3,              -- Fade animation duration
    TWEEN_EASING_STYLE = Enum.EasingStyle.Quad,
    TWEEN_EASING_DIRECTION = Enum.EasingDirection.Out,
    GUI_WAIT_TIMEOUT = 5,              -- Seconds to wait for GUI
}

Config.Bar = {
    SIDE_PADDING = 10,                 -- Left/right padding (pixels)
    TOP_BOTTOM_PADDING = 3,            -- Top/bottom padding (pixels)
    ANCHOR_POINT = Vector2.new(0, 0.5), -- Body anchor point
    POSITION_Y = 0.5,                  -- Body Y position (0-1 scale)
    TRANSPARENCY_HIDDEN = 1,           -- Background transparency when hidden
    TRANSPARENCY_VISIBLE = 0,          -- Background transparency when visible
}

Config.Elements = {
    SPRINT_GUI = "SprintGui",          -- ScreenGui name in PlayerGui
    BACKGROUND = "Background",         -- Background frame name
    BODY = "Body",                     -- Stamina bar frame name
}
```

## 🎮 How It Works

### Architecture (Server-Authoritative)

```
┌─────────────────┐     Input Events      ┌─────────────────┐
│   Client        │ ────────────────────► │   Server        │
│   (main.luau)   │                       │ (SprintServer)  │
│                 │ ◄──────────────────── │                 │
│   - Input       │   Durability Updates  │ - Calculation   │
│   - GUI Display │                       │ - WalkSpeed Set │
└─────────────────┘                       └─────────────────┘
```

### Flow

1. **Player presses Left Shift** → Client sends `SprintInputEvent` to server
2. **Server receives input** → Updates player's sprint state
3. **Server calculates** → Drains/recovers stamina, calculates speed
4. **Server applies** → Sets `Humanoid.WalkSpeed` directly
5. **Server sends feedback** → Fires `DurabilityUpdateEvent` to client
6. **Client updates GUI** → Stamina bar reflects current value

### Sprint Behavior

- **Start Sprint**: Hold `LeftShift` while moving
- **Stop Sprint**: Release `LeftShift` OR stop moving
- **Exhaustion**: When stamina drops below `DURABILITY_OF_EXHAUSTION`, speed gradually decreases
- **Empty Stamina**: Player returns to walking speed
- **Recovery**: Stamina recovers when not sprinting

## 📚 Module API Reference

### CalculatingOfWSModuleScript

The core calculation module that can be used independently.

```lua
local CalculateWS = require(path.to.CalculatingOfWSModuleScript)

-- Create new instance
local sprintSystem = CalculateWS.new({
    DURABILITY_MAX = 100,
    MAX_RUNNING_SPEED = 24,
    -- ... other config options
})

-- Start automatic updates
sprintSystem:Start()

-- Manual control
sprintSystem:SetSprinting(true)   -- Enable sprinting
sprintSystem:SetSprinting(false)  -- Disable sprinting
sprintSystem:ClearManualOverride() -- Allow input signals again

-- Getters
sprintSystem:GetCurrentDurability()  -- Returns: number
sprintSystem:IsSprinting()           -- Returns: boolean
sprintSystem:GetCurrentSpeed()       -- Returns: number

-- Events
sprintSystem.SprintChanged.Event:Connect(function(isSprinting)
    print("Sprint state:", isSprinting)
end)

sprintSystem.Exhausted.Event:Connect(function()
    print("Player exhausted!")
end)

-- Cleanup
sprintSystem:Stop()    -- Stop updates
sprintSystem:Destroy() -- Full cleanup
```

### FreshBodyModuleScript (GUI Controller)

```lua
local BodyMover = require(path.to.FreshBodyModuleScript)

-- Initialize with a sprint system reference
BodyMover:Initialize(sprintSystem)

-- Cleanup when done
BodyMover:Cleanup()
```

## 🔧 Customization Examples

### Change Sprint Key

In `main.luau`, modify the KeyCode:

```lua
-- Change from LeftShift to LeftControl
if input.KeyCode == Enum.KeyCode.LeftControl then
```

### Add Sprint Sound

In `SprintServer.luau`, after setting up player:

```lua
sprintSystem.SprintChanged.Event:Connect(function(isSprinting)
    if isSprinting then
        -- Play sprint start sound
    else
        -- Play sprint stop sound
    end
end)
```

### Add Exhaustion Effect

```lua
sprintSystem.Exhausted.Event:Connect(function()
    -- Screen shake, sound effect, etc.
end)
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| GUI not showing | Ensure `SprintGui` exists in StarterGui with correct hierarchy |
| Sprint not working | Check if `SprintInputEvent` exists in ReplicatedStorage |
| Speed not changing | Verify server script is running (check Output for "Sprint Server initialized") |
| Stamina not recovering | Make sure player releases LeftShift or stops moving |

## 📝 RemoteEvents Created

The system automatically creates these RemoteEvents in ReplicatedStorage:

- `SprintInputEvent` - Client → Server sprint state
- `DurabilityUpdateEvent` - Server → Client stamina updates

## ⚠️ Notes

- The system is **server-authoritative** for anti-cheat purposes
- All speed changes happen on the server
- Client only handles input and GUI display
- `InputModuleScript.luau` is an optional alternative to direct input handling in `main.luau`

## 📄 License

Free to use and modify for your Roblox projects.
