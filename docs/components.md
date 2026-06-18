<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Components&fontColor=F3EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Every%20control%20DXForge%20ships%20with%20today&descAlignY=64&descSize=13" alt="Components" width="100%" />
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

Buttons use the control animation system automatically for hover and press feedback.

## Toggle

```lua
Box:AddToggle({
    Text = "Enable Feature",
    ConfigId = "enable_feature",
    Default = false,
    Keybind = "[F]",
    Callback = function(value)
        print("Enabled:", value)
    end
})
```

Notes:

- curved toggle style is used when curved edges are enabled
- rectangular fallback is used when curved edges are disabled
- keybind-based toggling still works
- value is config-persistent when config saving is used

## Slider

```lua
Box:AddSlider({
    Text = "Speed",
    ConfigId = "speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 1,
    Callback = function(value)
        print("Speed:", value)
    end
})
```

Sliders now use animated handles and preserve `Min`, `Max`, and `Step` behavior exactly.

## Dropdown

```lua
Box:AddDropdown({
    Text = "Mode",
    ConfigId = "mode",
    Values = {"Default", "Aggressive", "Silent"},
    Default = "Default",
    Callback = function(value)
        print("Selected:", value)
    end
})
```

Notes:

- long dropdowns use a draggable popup scrollbar
- open state is animated through the shared component animation system
- dropdowns named like `Theme` or `Select Theme` can switch DXForge themes automatically

## MultiDropdown

```lua
Box:AddMultiDropdown({
    Text = "Targets",
    ConfigId = "targets",
    Values = {"Players", "NPCs", "Objects"},
    Default = {"Players"},
    Callback = function(values)
        print("Selected count:", #values)
    end
})
```

MultiDropdown selection tables are config-persistent and keep the same callback contract.

## Textbox

```lua
Box:AddTextbox({
    Text = "Profile Name",
    ConfigId = "profile_name",
    Placeholder = "Enter name...",
    Default = "",
    ClearButton = true,
    Callback = function(text)
        print("Text:", text)
    end
})
```

Notes:

- clear button still works
- focus state now has visual animation feedback
- saved text can be restored through config loading

## Keybind

```lua
Box:AddKeybind({
    Text = "Menu Key",
    ConfigId = "menu_key",
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

Keybind recording now has dedicated recording-state animation.

## ColorPicker

```lua
Box:AddColorPicker({
    Text = "Accent Color",
    ConfigId = "accent_color",
    Default = {180, 70, 255},
    Alpha = true,
    ApplyToTheme = true,
    Tooltip = "Pick a menu accent color.",
    Callback = function(color)
        print(color[1], color[2], color[3], color[4])
    end
})
```

Notes:

- `Alpha = true` shows the alpha slider
- `ApplyToTheme = true` updates the active theme directly
- `ThemeKey = "GlowColor"` targets a specific token
- runtime theme edits are now persisted by the config system

## Tooltips

Simple tooltip:

```lua
Box:AddToggle({
    Text = "Smart Mode",
    Tooltip = "Explains what this setting does."
})
```

Extended tooltip:

```lua
Box:AddSlider({
    Text = "FOV",
    Tooltip = {
        Text = "Controls the field of view.\nHold SHIFT for precision.",
        Keybind = "[SHIFT]",
        MaxWidth = 280
    }
})
```

## Config IDs

If you want stable config keys independent of visible text, use `ConfigId`:

```lua
Box:AddToggle({
    Text = "Enable ESP",
    ConfigId = "visuals_enable_esp",
    Default = true
})
```
