<p align="center">
  <img src="assets/DXForgeBanner.png" alt="DXForge banner" width="100%" />
</p>

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=120&section=header&color=0:090A0F,45:B254FF,100:161821&text=DXForge&fontColor=F3EEFF&fontSize=38&fontAlignY=38&animation=fadeIn&desc=Premium%20DX9%20Lua%20UI%20Library&descAlignY=64&descSize=14" alt="DXForge header" width="100%" />
</p>

<p align="center">
  <img src="assets/DXForgeSingle.png" alt="DXForge logo" width="110" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Lua-DX9-1A1B22?style=flat-square&logo=lua&logoColor=white&labelColor=101116&color=B254FF" alt="Lua DX9" />
  <img src="https://img.shields.io/badge/version-1.1.3-1A1B22?style=flat-square&labelColor=101116&color=B254FF" alt="Version" />
  <img src="https://img.shields.io/badge/license-MIT-1A1B22?style=flat-square&labelColor=101116&color=B254FF" alt="License" />
  <img src="https://img.shields.io/badge/author-PixelGG-1A1B22?style=flat-square&labelColor=101116&color=B254FF" alt="Author" />
</p>

<p align="center">
  <sub>Curved edges, component animations, premium tooltips, config persistence, and a polished DX9 overlay workflow.</sub>
</p>

---

## Overview

DXForge is a structured DX9WARE / Cult of Intellect Lua UI library for premium dark-tech overlays. It gives you a reusable window system, polished controls, smooth animation helpers, theme support, tooltips, notifications, overlays, startup branding, and now built-in config persistence with autosave.

## Highlights

| Area | Included |
| --- | --- |
| Interface | Windows, tabs, groupboxes, labels, dividers, buttons, toggles, sliders, dropdowns, multi dropdowns, textboxes, keybinds, color pickers |
| Polish | Curved edges, component hover/focus/active animation system, smooth toggles, upgraded tooltips, startup screen, premium notifications |
| Systems | Theme registry, runtime theme editing, FOV circle, watermark, centralized input handling, z-order management, config save/load, autosave |
| Compatibility | DX9WARE Lua 5.1.4 style workflow, fallback-safe rendering, no external dependencies, backward-compatible API |

## What Is New In The Current Build

| Version | Notable additions |
| --- | --- |
| `1.1.0` | Curved Edges system and rounded render helpers |
| `1.1.1` | Centralized control hover / focus / active animation system |
| `1.1.2` | Better tooltip system with wrapping, fade, delay, mouse-follow, keybind badges |
| `1.1.3` | Built-in config persistence, autosave, stable config IDs, theme/window/component state saving |

## Quick Start

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")

DXForge:SetConfigFolder("DXForge")
DXForge:LoadConfig("ExampleMenu")

local Window = DXForge:CreateWindow({
    Title = "DXForge Example",
    Size = {600, 500},
    ToggleKey = "[INSERT]",
    Theme = "Default",
    Resizable = true
})

local MainTab = Window:AddTab("Main")
local Visuals = MainTab:AddGroupbox("Visuals", "left")

Visuals:AddToggle({
    Text = "Enable ESP",
    ConfigId = "visuals_enable_esp",
    Default = true,
    Tooltip = "Turns the ESP renderer on or off.",
    Callback = function(value)
        print("ESP:", value)
    end
})

Visuals:AddSlider({
    Text = "FOV",
    Min = 10,
    Max = 500,
    Default = 90,
    Step = 1,
    Tooltip = {
        Text = "Controls the visible aimbot radius.\nHold SHIFT for precision adjustments.",
        Keybind = "[SHIFT]"
    }
})

DXForge:EnableAutoSave({
    File = "ExampleMenu.json",
    Interval = 2
})

DXForge:Render()
```

## Core API

| Scope | Method |
| --- | --- |
| Core | `DXForge:CreateWindow(config)` |
| Core | `DXForge:Render()` |
| Core | `DXForge:Notify(config)` |
| Core | `DXForge:SetTheme(name)` |
| Core | `DXForge:SetThemeColor(key, color)` |
| Core | `DXForge:CreateTheme(name, values)` |
| Core | `DXForge:CurvedEdges(value)` |
| Core | `DXForge:SetConfigFolder(folder)` |
| Core | `DXForge:SaveConfig(name)` |
| Core | `DXForge:LoadConfig(name, options)` |
| Core | `DXForge:DeleteConfig(name)` |
| Core | `DXForge:GetConfigList()` |
| Core | `DXForge:EnableAutoSave(options)` |
| Core | `DXForge:DisableAutoSave()` |
| Core | `DXForge:SetWatermark(config)` |
| Core | `DXForge:SetFOVCircle(config)` |

## Included Controls

```text
Window          Tab             Groupbox
Button          Toggle          Slider
Dropdown        MultiDropdown   Textbox
Keybind         ColorPicker     Label
Divider         Tooltip         Notification
Watermark       FOV Circle      Startup Screen
Theme System    Config System   Overlay Helpers
```

## Persistence Support

DXForge can save and restore:

- Toggle, slider, dropdown, multi dropdown, textbox, keybind, and color picker values
- Active theme and runtime theme overrides
- Window position, size, open state, and active tab
- Curved edge state
- Future component states through the same config registry path

## Documentation

| Guide | Description |
| --- | --- |
| [Docs Home](docs/README.md) | Full documentation hub and reading order. |
| [Getting Started](docs/getting-started.md) | Setup, first window, and render loop basics. |
| [API Reference](docs/api-reference.md) | Library, window, tab, and control API map. |
| [Components](docs/components.md) | Real usage examples for every built-in control. |
| [Themes](docs/themes.md) | Theme tokens, editing, and customization workflow. |
| [Animations](docs/animations.md) | Motion behavior and visual polish systems. |
| [Notifications & Tooltips](docs/notifications-tooltips.md) | Feedback UX and hover guidance. |
| [Input & Windowing](docs/input-windowing.md) | Dragging, resizing, focus, z-index, and interaction flow. |
| [DX9 Compatibility](docs/dx9-compatibility.md) | DX9WARE Lua expectations and fallback notes. |
| [Examples](docs/examples.md) | Copy-ready layouts and practical snippets. |

## Scripts In This Repository

| Script | Game | README |
| --- | --- | --- |
| `AR2_DOMINION.lua` | Apocalypse Rising 2 | [Scripts/AR2/README.md](Scripts/AR2/README.md) |
| `BRM5.lua` | Blackhawk Rescue Mission 5 / Ronograd | [Scripts/BRM5/README.md](Scripts/BRM5/README.md) |

## Project Layout

```text
DXForge/
|-- assets/
|-- docs/
|-- Scripts/
|   |-- AR2/
|   `-- BRM5/
|-- DXForge.lua
|-- DXForge.png
|-- LICENSE
`-- README.md
```

## Credits

Created by **PixelGG**.

DXForge is built for DX9 overlay workflows that want structure, polish, and long-term maintainability without giving up fast iteration.

## License

DXForge is licensed under the MIT License. See [LICENSE](LICENSE) for details.

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=88&section=footer&color=0:161821,55:B254FF,100:090A0F&animation=fadeIn" alt="DXForge footer" width="100%" />
</p>
