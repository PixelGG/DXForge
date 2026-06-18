<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Examples&fontColor=F3EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Copy-ready%20DXForge%201.0.19%20layouts&descAlignY=64&descSize=13" alt="Examples" width="100%" />
</p>

[Back to docs](README.md)

## Two-Column Menu

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")

local Window = DXForge:CreateWindow({
    Title = "Two Column Layout",
    Size = {640, 520},
    ToggleKey = "[INSERT]"
})

local Main = Window:AddTab("Main")
local Left = Main:AddGroupbox("General", "left")
local Right = Main:AddGroupbox("Visuals", "right")

Left:AddToggle({
    Text = "Enabled",
    Default = true
})

Left:AddSlider({
    Text = "Strength",
    Min = 0,
    Max = 100,
    Default = 35
})

Right:AddColorPicker({
    Text = "Accent",
    ThemeKey = "AccentColor",
    Default = {178, 84, 255}
})
```

## Theme And Tooltip Setup

```lua
DXForge:CreateTheme("Ocean", {
    Base = "Dark",
    AccentColor = {80, 180, 255},
    GlowColor = {90, 210, 255}
})

DXForge:SetTheme("Ocean")

Left:AddSlider({
    Text = "FOV",
    Min = 40,
    Max = 180,
    Default = 90,
    Tooltip = "Controls the visible aim radius."
})
```

## Notifications And Overlays

```lua
local Feedback = Main:AddGroupbox("Feedback", "full")

Feedback:AddButton({
    Text = "Show Notification",
    Callback = function()
        DXForge:Notify({
            Text = "Settings updated.",
            Type = "Success",
            Duration = 3
        })
    end
})

DXForge:SetWatermark({
    Text = "Example Menu",
    Visible = true,
    Position = {12, 12}
})

DXForge:SetFOVCircle({
    Visible = true,
    Radius = 120,
    Color = {80, 180, 255}
})
```

## Full Render Loop

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")

local Window = DXForge:CreateWindow({
    Title = "DXForge Example",
    Size = {600, 460},
    ToggleKey = "[F6]"
})

local Tab = Window:AddTab("Main")
local Box = Tab:AddGroupbox("Controls", "left")

Box:AddButton({
    Text = "Ping",
    Callback = function()
        DXForge:Notify("Pong")
    end
})

DXForge:Render()
```
