<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=API%20Reference&fontColor=F3EEFF&fontSize=32&fontAlignY=38&animation=fadeIn&desc=Core%2C%20windows%2C%20tabs%2C%20controls%2C%20configs%20and%20tooltips&descAlignY=64&descSize=13" alt="API Reference" width="100%" />
</p>

[Back to docs](README.md)

## Core

| Method | Returns | Description |
| --- | --- | --- |
| `DXForge:CreateWindow(config)` | `Window` | Creates a new UI window. |
| `DXForge:Render()` | `DXForge` | Updates input, autosave, overlays, startup, windows, notifications, and tooltips. |
| `DXForge:Notify(config)` | `DXForge` | Adds a notification card. |
| `DXForge:CreateTheme(name, values)` | `DXForge` | Registers a custom theme with inheritance support. |
| `DXForge:RegisterTheme(name, values)` | `DXForge` | Low-level theme registration helper. |
| `DXForge:UpdateTheme(name, values)` | `DXForge` | Patches an existing theme. |
| `DXForge:SetTheme(name)` | `DXForge` | Sets the active global theme. |
| `DXForge:SetThemeColor(key, color)` | `DXForge` | Updates one token on the active theme. |
| `DXForge:GetThemeNames()` | `table` | Returns all registered theme names. |
| `DXForge:CurvedEdges(value)` | `DXForge` or `boolean` | Enables/disables curved rendering, or returns the current state when `value == nil`. |
| `DXForge:SetCurvedEdges(value)` | `DXForge` or `boolean` | Internal/alternate curved-edge setter. |
| `DXForge:SetWatermark(config)` | `DXForge` | Configures the watermark. |
| `DXForge:SetFOVCircle(config)` | `DXForge` | Configures the optional FOV circle overlay. |
| `DXForge:SetConfigFolder(folder)` | `DXForge` | Sets the config folder and tries to create it when supported. |
| `DXForge:SaveConfig(name)` | `boolean` | Saves config data to a JSON-style file. |
| `DXForge:LoadConfig(name, options)` | `boolean` | Loads config data and applies it safely. |
| `DXForge:DeleteConfig(name)` | `boolean` | Deletes a config file. |
| `DXForge:GetConfigList()` | `table` | Returns available config filenames. |
| `DXForge:EnableAutoSave(options)` | `DXForge` | Enables timed autosave. |
| `DXForge:DisableAutoSave()` | `DXForge` | Disables autosave. |
| `DXForge:SetDebug(value)` | `DXForge` | Enables or disables debug warnings. |
| `DXForge:Destroy()` | `DXForge` | Clears windows, notifications, animations, and config registries. |

## CreateWindow Config

| Field | Type | Default |
| --- | --- | --- |
| `Title` | `string` | `"DXForge Window"` |
| `Size` | `{number, number}` | `{600, 500}` |
| `Position` | `{number, number}` | centered |
| `ToggleKey` | `string` | `nil` |
| `Resizable` | `boolean` | `false` |
| `Footer` | `boolean` | `true` |
| `Theme` | `string` | active theme |
| `MinSize` | `{number, number}` | `{420, 320}` |
| `Open` | `boolean` | `true` |
| `ConfigId` | `string` | `nil` |
| `Startup` | `boolean` | deprecated / ignored |

## Window

| Method | Description |
| --- | --- |
| `Window:AddTab(name)` | Creates and returns a tab. |
| `Window:SetOpen(value)` | Opens or closes the window. |
| `Window:Resize(width, height)` | Resizes the window and respects `MinSize`. |
| `Window:SetSize({width, height})` | Table-based resize alias. |
| `Window:SetMinSize({width, height})` | Updates minimum resize bounds. |
| `Window:Toggle()` | Toggles open state. |
| `Window:BringToFront()` | Moves the window above other windows. |

## Tab

| Method | Description |
| --- | --- |
| `Tab:AddGroupbox(name, side)` | Creates a section. |
| `Tab:AddLeftGroupbox(name)` | Shortcut for left section. |
| `Tab:AddRightGroupbox(name)` | Shortcut for right section. |
| `Tab:AddMiddleGroupbox(name)` | Shortcut for full-width section. |
| `Tab:Focus()` | Makes the tab active. |

## Groupbox

| Method | Description |
| --- | --- |
| `Groupbox:AddLabel(config)` | Adds read-only text. |
| `Groupbox:AddDivider(text)` | Adds a separator. |
| `Groupbox:AddButton(config)` | Adds a clickable button. |
| `Groupbox:AddToggle(config)` | Adds a boolean switch. |
| `Groupbox:AddSlider(config)` | Adds numeric input. |
| `Groupbox:AddDropdown(config)` | Adds single-select values. |
| `Groupbox:AddMultiDropdown(config)` | Adds multi-select values. |
| `Groupbox:AddTextbox(config)` | Adds text input. |
| `Groupbox:AddKeybind(config)` | Adds key selection/state. |
| `Groupbox:AddColorPicker(config)` | Adds RGB color selection. |

## Shared Config Fields

Most controls support:

| Field | Purpose |
| --- | --- |
| `Text` | Display label |
| `Tooltip` | String or extended tooltip table |
| `Callback` | Invoked when the value changes |
| `Visible` | Initial visibility |
| `Height` | Optional custom row height |
| `ConfigId` | Stable manual config identifier |

## Component Value Helpers

The following patterns now exist across configurable controls:

| Method | Purpose |
| --- | --- |
| `component:GetValue()` | Returns the current user-facing value |
| `component:SetValue(value, silent)` | Updates the component, optionally without callback |
| `component:GetConfigValue()` | Returns the value used for persistence |
| `component:SetConfigValue(value, silent)` | Applies persisted values safely |

## Tooltip API

### Simple

```lua
Tooltip = "Controls the FOV radius.\nHold SHIFT for precision."
```

### Extended

```lua
Tooltip = {
    Text = "Controls the FOV radius.\nHold SHIFT for precision.",
    Keybind = "[SHIFT]",
    MaxWidth = 280
}
```

## Config API

```lua
DXForge:SetConfigFolder("DXForge")
DXForge:SaveConfig("ProfileA")
DXForge:LoadConfig("ProfileA", {Callbacks = false})
DXForge:DeleteConfig("ProfileA")
DXForge:GetConfigList()
```

## Autosave API

```lua
DXForge:EnableAutoSave({
    File = "ProfileA.json",
    Interval = 2
})

DXForge:DisableAutoSave()
```
