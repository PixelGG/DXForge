<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=Examples&fontColor=F2EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Copy-ready%20DXForge%20layouts&descAlignY=64&descSize=13" alt="Examples" width="100%" />
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
    Default = true,
    Callback = function(value) print(value) end
})

Left:AddSlider({
    Text = "Strength",
    Min = 0,
    Max = 100,
    Default = 35,
    Callback = function(value) print(value) end
})

Right:AddColorPicker({
    Text = "Accent",
    Default = {178, 84, 255},
    Callback = function(color) print(color[1], color[2], color[3]) end
})
```

## Settings Tab

```lua
local Settings = Window:AddTab("Settings")
local Menu = Settings:AddGroupbox("Menu", "full")

Menu:AddKeybind({
    Text = "Menu Toggle",
    Default = "[INSERT]",
    Mode = "Toggle",
    Callback = function(key, state)
        print("Key:", key, "State:", state)
    end
})

Menu:AddDropdown({
    Text = "Theme",
    Values = {"Default", "VioletSteel"},
    Default = "Default",
    Callback = function(theme)
        DXForge:SetTheme(theme)
    end
})
```

## Notification Buttons

```lua
local Feedback = Main:AddGroupbox("Feedback", "full")

Feedback:AddButton({
    Text = "Success",
    Callback = function()
        DXForge:Notify({Text = "Operation completed.", Type = "Success"})
    end
})

Feedback:AddButton({
    Text = "Warning",
    Callback = function()
        DXForge:Notify({Text = "Check your settings.", Type = "Warning"})
    end
})
```
