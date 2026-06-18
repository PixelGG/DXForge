<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=API%20Reference&fontColor=F3EEFF&fontSize=32&fontAlignY=38&animation=fadeIn&desc=Core%2C%20windows%2C%20tabs%2C%20controls%2C%20themes%20and%20overlays&descAlignY=64&descSize=13" alt="API Reference" width="100%" />
</p>

[Back to docs](README.md)

## Core

| Method | Returns | Description |
| --- | --- | --- |
| `DXForge:CreateWindow(config)` | `Window` | Creates and registers a UI window. |
| `DXForge:Render()` | `DXForge` | Updates input, startup, overlays, windows, notifications, and tooltips. |
| `DXForge:Notify(config)` | `DXForge` | Adds a notification card. |
| `DXForge:SetWatermark(config)` | `DXForge` | Configures the watermark overlay. |
| `DXForge:SetFOVCircle(config)` | `DXForge` | Configures the optional FOV circle overlay. |
| `DXForge:Destroy()` | `DXForge` | Clears windows, notifications, animations, and overlay state. |
| `DXForge:SetDebug(value)` | `DXForge` | Enables or disables debug warnings. |

## Theme API

| Method | Returns | Description |
| --- | --- | --- |
| `DXForge:RegisterTheme(name, values)` | `DXForge` | Registers a theme table. |
| `DXForge:CreateTheme(name, values)` | `DXForge` | Friendly alias for registering a theme. |
| `DXForge:UpdateTheme(name, values)` | `DXForge` | Patches an existing theme. |
| `DXForge:SetTheme(name)` | `DXForge` | Sets the active global theme. |
| `DXForge:SetThemeColor(key, color)` | `DXForge` | Updates one token on the active theme. |
| `DXForge:GetThemeNames()` | `table` | Returns all registered theme names. |
| `DXForge:GetTheme(name)` | `table` | Returns a resolved theme table. |

## Animation Helpers

| Method | Returns | Description |
| --- | --- | --- |
| `DXForge:Animate(id, target, speed)` | `number` | Interpolates and stores a value by ID. |
| `DXForge:Pulse(speed)` | `number` | Returns a looping pulse value from `0` to `1`. |

## CreateWindow Config

| Field | Type | Default |
| --- | --- | --- |
| `Title` | `string` | `"DXForge Window"` |
| `Size` | `{number, number}` | `{600, 500}` |
| `Position` | `{number, number}` | centered |
| `StartLocation` | `{number, number}` | legacy alias for `Position` |
| `MinSize` | `{number, number}` | `{420, 320}` |
| `ToggleKey` | `string` | `nil` |
| `Resizable` | `boolean` | `false` |
| `Footer` | `boolean` | `true` |
| `Theme` | `string` | active theme |
| `Open` | `boolean` | `true` |
| `Startup` | `boolean` | deprecated / ignored in `1.0.19` |

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
| `Groupbox:AddColorPicker(config)` | Adds RGB/RGBA color selection. |

## Shared Component Fields

| Field | Purpose |
| --- | --- |
| `Text` / `Name` | Display label |
| `Tooltip` | Tooltip string shown on hover |
| `Callback` | Invoked when the value changes or button is pressed |
| `Visible` | Initial visibility |
| `Height` | Optional custom row height |

## Component Helpers

| Method | Components | Purpose |
| --- | --- | --- |
| `component:SetVisible(value)` | all components | Shows or hides a component. |
| `component:SetTooltip(text)` | all components | Replaces tooltip text. |
| `toggle:SetValue(value, silent)` | toggle | Updates boolean state. |
| `slider:SetValue(value, silent)` | slider | Updates numeric value. |
| `textbox:SetValue(value, silent)` | textbox | Updates text value. |
| `keybind:SetKey(key, silent)` | keybind | Updates recorded key. |
| `colorPicker:SetColor(color, silent)` | color picker | Updates selected color. |

## Notification Config

| Field | Description |
| --- | --- |
| `Text` | Notification body. Supports newlines. |
| `Type` | `Info`, `Success`, `Warning`, or `Error`. |
| `Duration` / `Length` | Lifetime in seconds. |
| `ManualClose` | Keeps the card open until the close button is pressed. |

## Overlay Config

```lua
DXForge:SetWatermark({
    Text = "DXForge",
    Visible = true,
    Position = {12, 12}
})

DXForge:SetFOVCircle({
    Visible = true,
    Radius = 120,
    Color = {184, 94, 255},
    Thickness = 1,
    Segments = 96
})
```
