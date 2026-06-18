<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Components&fontColor=F3EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Every%20control%20DXForge%201.0.19%20ships%20with&descAlignY=64&descSize=13" alt="Components" width="100%" />
</p>

[Back to docs](README.md)

## Labels And Dividers

```lua
Box:AddLabel({Text = "Combat Settings"})
Box:AddDivider("Main")
```

Use labels for passive information and dividers for structure.

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

Buttons use hover and press animation through `DXForge:Animate`.

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

Notes:

- `Default = true` starts enabled
- `Keybind` toggles the value when the component is visible
- callbacks receive the new boolean value

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

Sliders clamp to `Min` / `Max` and round to `Step`.

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

Notes:

- long dropdowns use a draggable popup scrollbar
- dropdowns named like `Theme` or `Select Theme` can switch DXForge themes automatically

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

The callback receives an ordered table of selected values.

## Textbox

```lua
Box:AddTextbox({
    Text = "Profile Name",
    Placeholder = "Enter name...",
    Default = "",
    ClearButton = true,
    Callback = function(text)
        print("Text:", text)
    end
})
```

Notes:

- `ClearButton = false` hides the clear button
- text commits through typed key input and common confirm/backspace behavior

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

| Mode | Behavior |
| --- | --- |
| `Toggle` | Pressing the key flips state |
| `Hold` | State is active while the key is held |

## ColorPicker

```lua
Box:AddColorPicker({
    Text = "Accent Color",
    Default = {180, 70, 255},
    Alpha = true,
    ApplyToTheme = true,
    Callback = function(color)
        print(color[1], color[2], color[3], color[4])
    end
})
```

Notes:

- `Alpha = true` enables alpha editing
- `ApplyToTheme = true` applies the selected color to a theme token
- `ThemeKey = "GlowColor"` targets a specific token

## Tooltips

```lua
Box:AddToggle({
    Text = "Smart Mode",
    Tooltip = "Explains what this setting does."
})
```

DXForge `1.0.19` supports simple tooltip strings with newline text. Extended tooltip tables are not part of the current file.
