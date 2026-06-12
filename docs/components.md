<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=Components&fontColor=F2EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Every%20control%20DXForge%20ships%20with&descAlignY=64&descSize=13" alt="Components" width="100%" />
</p>

[Back to docs](README.md)

## Labels And Dividers

```lua
Box:AddLabel({Text = "Combat Settings"})
Box:AddDivider("Main")
```

Use labels for passive information and dividers for visual grouping.

## Button

```lua
Box:AddButton({
    Text = "Execute",
    Tooltip = "Runs the configured action.",
    Callback = function()
        print("Executed")
    end
})
```

## Toggle

```lua
Box:AddToggle({
    Text = "Enable Feature",
    Default = false,
    Keybind = "[F]",
    Callback = function(value)
        print("Enabled:", value)
    end
})
```

## Slider

```lua
Box:AddSlider({
    Text = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 1,
    Callback = function(value)
        print("Speed:", value)
    end
})
```

## Dropdown

```lua
Box:AddDropdown({
    Text = "Mode",
    Values = {"Default", "Aggressive", "Silent"},
    Default = "Default",
    Callback = function(value)
        print("Selected:", value)
    end
})
```

## MultiDropdown

```lua
Box:AddMultiDropdown({
    Text = "Targets",
    Values = {"Players", "NPCs", "Objects"},
    Default = {"Players"},
    Callback = function(values)
        print("Selected count:", #values)
    end
})
```

## Textbox

```lua
Box:AddTextbox({
    Text = "Profile Name",
    Placeholder = "Enter name...",
    Default = "",
    Callback = function(text)
        print("Text:", text)
    end
})
```

## Keybind

```lua
Box:AddKeybind({
    Text = "Menu Key",
    Default = "[INSERT]",
    Mode = "Toggle",
    Callback = function(key, state)
        print("Key:", key, "State:", state)
    end
})
```

Modes:

| Mode | Behavior |
| --- | --- |
| `Toggle` | Pressing the key flips state. |
| `Hold` | State is active while the key is held. |

## ColorPicker

```lua
Box:AddColorPicker({
    Text = "Accent Color",
    Default = {180, 70, 255},
    ApplyToTheme = true,
    Tooltip = "Pick a menu accent color.",
    Callback = function(color)
        print(color[1], color[2], color[3])
    end
})
```

Use `ApplyToTheme = true` to update the active theme `AccentColor` directly. For another theme token, pass `ThemeKey = "GlowColor"` or any registered color token.

## Tooltips

Most controls accept a `Tooltip` field:

```lua
Box:AddToggle({
    Text = "Smart Mode",
    Tooltip = "Explains what this setting does.",
    Callback = function(value) end
})
```
