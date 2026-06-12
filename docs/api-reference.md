<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=API%20Reference&fontColor=F2EEFF&fontSize=32&fontAlignY=38&animation=fadeIn&desc=Core%2C%20windows%2C%20tabs%2C%20groupboxes%20and%20controls&descAlignY=64&descSize=13" alt="API Reference" width="100%" />
</p>

[Back to docs](README.md)

## Core

| Method | Returns | Description |
| --- | --- | --- |
| `DXForge:CreateWindow(config)` | `Window` | Creates a new UI window. |
| `DXForge:Render()` | `DXForge` | Updates input, renders startup, windows, notifications, watermark, and tooltips. |
| `DXForge:Notify(config)` | `DXForge` | Adds a notification. |
| `DXForge:RegisterTheme(name, values)` | `DXForge` | Registers a custom theme. |
| `DXForge:SetTheme(name)` | `DXForge` | Sets the active global theme. |
| `DXForge:SetWatermark(config)` | `DXForge` | Configures the watermark. |
| `DXForge:SetDebug(value)` | `DXForge` | Enables or disables debug warnings. |
| `DXForge:Destroy()` | `DXForge` | Clears windows, notifications, and animations. |

## CreateWindow Config

| Field | Type | Default |
| --- | --- | --- |
| `Title` | `string` | `"DXForge Window"` |
| `Size` | `{number, number}` | `{600, 500}` |
| `Position` | `{number, number}` | centered |
| `ToggleKey` | `string` | `nil` |
| `Resizable` | `boolean` | `false` |
| `Footer` | `boolean` | `true` |
| `Theme` | `string` | `"Default"` |
| `Startup` | `boolean` | Deprecated/ignored. Branding startup always runs once. |
| `Open` | `boolean` | `true` |

## Window

| Method | Description |
| --- | --- |
| `Window:AddTab(name)` | Creates and returns a tab. |
| `Window:SetOpen(value)` | Opens or closes the window. |
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

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=72&section=footer&color=0:14151C,55:B254FF,100:090A0F&animation=fadeIn" alt="Footer" width="100%" />
</p>
