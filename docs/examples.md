<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Examples&fontColor=F3EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Copy-ready%20DXForge%20layouts%20with%20modern%20features&descAlignY=64&descSize=13" alt="Examples" width="100%" />
</p>

[Back to docs](README.md)

## Two-Column Menu

```lua
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
    ConfigId = "enabled",
    Default = true
})

Left:AddSlider({
    Text = "Strength",
    ConfigId = "strength",
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

## Config-Backed Menu

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")

DXForge:SetConfigFolder("DXForge")
DXForge:LoadConfig("ExampleProfile")

local Window = DXForge:CreateWindow({
    Title = "Config Example",
    Size = {620, 460},
    ToggleKey = "[INSERT]"
})

local Tab = Window:AddTab("Main")
local Box = Tab:AddGroupbox("Settings", "left")

Box:AddToggle({
    Text = "Enable ESP",
    ConfigId = "visuals_enable_esp",
    Default = true
})

Box:AddDropdown({
    Text = "Mode",
    ConfigId = "combat_mode",
    Values = {"Default", "Aggressive", "Silent"},
    Default = "Default"
})

DXForge:EnableAutoSave({
    File = "ExampleProfile.json",
    Interval = 2
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
DXForge:CurvedEdges(true)

Box:AddSlider({
    Text = "FOV",
    Min = 40,
    Max = 180,
    Default = 90,
    Tooltip = {
        Text = "Controls the visible aim radius.\nHold SHIFT for precision adjustments.",
        Keybind = "[SHIFT]",
        MaxWidth = 280
    }
})
```

## Notification Buttons

```lua
local Feedback = Main:AddGroupbox("Feedback", "full")

Feedback:AddButton({
    Text = "Save Config",
    Callback = function()
        DXForge:SaveConfig("ExampleProfile")
    end
})

Feedback:AddButton({
    Text = "Load Config",
    Callback = function()
        DXForge:LoadConfig("ExampleProfile", {Callbacks = false})
    end
})
```
