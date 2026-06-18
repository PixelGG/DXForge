<p align="center">
  <img src="../assets/DXForgeSingle.png" alt="DXForge logo" width="96" />
</p>

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=rect&height=92&color=0:090A0F,100:161821&text=Getting%20Started&fontColor=F3EEFF&fontSize=30&animation=fadeIn&desc=Install%2C%20create%20a%20window%2C%20render%2C%20persist%20settings&descSize=13&descAlignY=70" alt="Getting Started" width="100%" />
</p>

[Back to docs](README.md)

## Install

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")
```

DX9WARE runs Lua every frame, so `_G.DXForge` avoids rebuilding the library repeatedly. Keep `DXForge.lua` local in the workspace and load it with `dofile`.

## Recommended Startup Pattern

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")

DXForge:SetConfigFolder("DXForge")
DXForge:LoadConfig("StarterMenu")
```

This is optional, but it is the cleanest way to let saved settings apply as soon as controls get created.

## Create Your First Window

```lua
local Window = DXForge:CreateWindow({
    Title = "DXForge Menu",
    Size = {600, 500},
    ToggleKey = "[INSERT]",
    Resizable = true,
    Theme = "Default"
})
```

## Add A Tab And Groupbox

```lua
local MainTab = Window:AddTab("Main")
local MainBox = MainTab:AddGroupbox("General", "left")
```

| Side | Behavior |
| --- | --- |
| `left` | Left column |
| `right` | Right column |
| `full` | Full-width section |
| `middle` | Alias for `full` |

## Add Controls

```lua
MainBox:AddToggle({
    Text = "Enabled",
    ConfigId = "general_enabled",
    Default = true,
    Tooltip = {
        Text = "Turns the example feature on or off.\nSaved automatically if config persistence is enabled.",
        Keybind = "[F]"
    },
    Keybind = "[F]",
    Callback = function(value)
        print("Enabled:", value)
    end
})

MainBox:AddSlider({
    Text = "Speed",
    ConfigId = "general_speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 1
})
```

## Optional Visual Systems

```lua
DXForge:CurvedEdges(true)
DXForge:SetTheme("Default")
```

DXForge `1.1.x` includes:

- curved edges
- centralized control animations
- upgraded tooltips
- built-in config persistence

## Enable Autosave

```lua
DXForge:EnableAutoSave({
    File = "StarterMenu.json",
    Interval = 2
})
```

## Render Loop

Call this once per DX9 frame / script tick:

```lua
DXForge:Render()
```

## Minimal Complete Example

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")

DXForge:SetConfigFolder("DXForge")
DXForge:LoadConfig("StarterMenu")

local Window = DXForge:CreateWindow({
    Title = "DXForge Starter",
    Size = {560, 420},
    ToggleKey = "[INSERT]",
    Resizable = true
})

local Tab = Window:AddTab("Main")
local Box = Tab:AddGroupbox("Controls", "left")

Box:AddLabel({Text = "Welcome to DXForge"})

Box:AddButton({
    Text = "Send Notification",
    Tooltip = "Shows a test notification card.",
    Callback = function()
        DXForge:Notify({
            Text = "Hello from DXForge.",
            Type = "Info",
            Duration = 3
        })
    end
})

Box:AddTextbox({
    Text = "Profile Name",
    ConfigId = "profile_name",
    Placeholder = "Enter a name..."
})

DXForge:EnableAutoSave({
    File = "StarterMenu.json",
    Interval = 2
})

DXForge:Render()
```
