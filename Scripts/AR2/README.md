<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=120&section=header&color=0:090A0F,45:FF4747,100:161821&text=AR2%20DOMINION&fontColor=F3EEFF&fontSize=38&fontAlignY=38&animation=fadeIn&desc=Apocalypse%20Rising%202%20DX9WARE%20Script&descAlignY=64&descSize=14" alt="AR2 DOMINION header" width="100%" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Lua-DX9-1A1B22?style=flat-square&logo=lua&logoColor=white&labelColor=101116&color=FF4747" alt="Lua DX9" />
  <img src="https://img.shields.io/badge/script-AR2%20DOMINION-1A1B22?style=flat-square&labelColor=101116&color=FF4747" alt="Script" />
  <img src="https://img.shields.io/badge/game-Apocalypse%20Rising%202-1A1B22?style=flat-square&labelColor=101116&color=FF4747" alt="Game" />
  <img src="https://img.shields.io/badge/UI-DXForge%201.1.3-1A1B22?style=flat-square&labelColor=101116&color=FF4747" alt="DXForge UI" />
  <img src="https://img.shields.io/badge/author-PixelGG-1A1B22?style=flat-square&labelColor=101116&color=FF4747" alt="Author" />
</p>

<p align="center">
  <sub>Full-spectrum AR2 ESP, dual aimbot flow, polished overlays, and the current DXForge UI feature set.</sub>
</p>

---

## Overview

`AR2_DOMINION.lua` is the Apocalypse Rising 2-focused DX9WARE script in this repository. It combines wide ESP coverage, separate player and zombie aimbot handling, configurable overlays, and a DXForge-powered premium menu with current-generation UI features like curved edges, animated controls, better tooltips, and built-in config persistence.

## Key Systems

| Category | Included |
| --- | --- |
| Player ESP | Box, name, distance, health, tracelines, skeleton, snap lines, nearest indicator |
| Zombie ESP | Box, name, distance, health, tracelines, skeleton, type labels, nearest indicator, proximity alerts |
| World ESP | Vehicles, loot containers, searchable loot, world utility, dead bodies |
| Aimbot | Player aimbot, zombie aimbot, FOV controls, smoothness, sensitivity, aim-part selection, sticky aim |
| Overlays | Crosshair, watermark, FPS counter, session timer, stats overlay, location tag |
| UI | DXForge 1.1.3 with curved edges, control animations, upgraded tooltips, config save/load, autosave |

## Install

```lua
loadstring(dx9.Get("https://raw.githubusercontent.com/PixelGG/DXForge/main/Scripts/AR2/AR2_DOMINION.lua"))()
```

## Suggested Runtime Flow

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")

DXForge:SetConfigFolder("DXForge")
DXForge:LoadConfig("AR2_DOMINION")
DXForge:EnableAutoSave({
    File = "AR2_DOMINION.json",
    Interval = 2
})
```

## UI Layout

| Tab | Groupbox | Main controls |
| --- | --- | --- |
| ESP | Player ESP | Enable, box, names, distance, health, tracelines, skeleton, snap lines, nearest indicator, max distance, color controls |
| ESP | Zombie ESP | Enable, box, names, distance, health, tracelines, skeleton, zombie type label, nearest indicator, max distance, color controls |
| ESP | Vehicle ESP | Enable, box, names, category label, distance, tracelines, nearest indicator, max distance |
| ESP | Loot ESP | Enable, box, names, distance, tracelines, max distance, color controls |
| ESP | Dead Body ESP | Enable, box marker, names, distance, tracelines, equipment visibility, player/zombie corpse filters |
| ESP | Alerts | Zombie proximity alert, alert distance |
| Aimbot | Player Aimbot | Enable, sticky aim, FOV, smooth, sensitivity, aim part, aim mode |
| Aimbot | Zombie Aimbot | Enable, FOV, smooth, sensitivity, aim part, aim mode |
| Aimbot | FOV Circle | Show FOV, source mode, color |
| Visuals | Crosshair | Enable, style, size, gap, center dot, color |
| Visuals | Overlays | Watermark, FPS counter, stats overlay, location display |
| Settings | General | Console, script info, reset behavior, config-facing settings |

## Vehicle Categories

| Category | Vehicles |
| --- | --- |
| Civilian | Sedan, Station Wagon, Chevy Suburban, Chevy Blazer, Pickup Truck, Caprice, Mustang, Corvette, Jeep, Tractor, Quad |
| Commercial | Delivery Van, Cargo Van, Semi Truck, StepVan, Box Truck, Utility Truck |
| Military | Humvee, Military Pickup, Barracks Truck, Armored Truck |
| Emergency | Police CUV, Police Car, Ambulance, Firetruck |
| Boat | Speed Boat, Swing Keel Boat, Aluminum Boat, Lifeboat, Rubber Dinghy, Patrol Boat |

## Searchable Loot Categories

```text
Medical
Weapon
Food
Vehicle
Industrial
Utility
Civilian
```

## Zombie Type Groups

| Type | Keywords |
| --- | --- |
| Military | Military, Soldier, Boot Camp, Drill, SWAT, SpecOps, Operator |
| Police | Police, Security, Prison |
| Unique | Unique, Cultist, Hazmat, Plague, Caveman, Butcher |
| Smuggler | Smuggler, Miner, Mobster |
| Civilian | Civilian, Resident, Tourist, Student, Hobo, Farmer, Hunter, Camper |

## Aimbot Reference

| Setting | Range | Player default | Zombie default |
| --- | --- | --- | --- |
| FOV | `10 - 1000` | `350` | `400` |
| Smooth | `1 - 20` | `1.5` | `1.2` |
| Sensitivity | `0.5 - 10` | `2.0` | `2.5` |
| Aim Part | `Head` to `RightFoot` | `Head` | `Head` |
| Aim Mode | `First Person / Third Person` | `First Person` | `First Person` |
| Sticky Aim | Toggle | `Off` | `-` |

## Crosshair Styles

| Style | Meaning |
| --- | --- |
| `1` | Cross |
| `2` | Dot |
| `3` | Circle |
| `4` | Cross + Circle |

## Visual Standard

This README now follows the same presentation level as the root DXForge docs:

- same badge style
- same section rhythm
- same dark-tech visual direction
- same current DXForge version reference

## Related Docs

| File | Purpose |
| --- | --- |
| [../../README.md](../../README.md) | Main DXForge overview |
| [../../docs/README.md](../../docs/README.md) | Documentation hub |
| [../BRM5/README.md](../BRM5/README.md) | BRM5 sister script |

## Credits

Created by **PixelGG**.  
UI powered by **DXForge 1.1.3**.

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=88&section=footer&color=0:161821,55:FF4747,100:090A0F&animation=fadeIn" alt="AR2 DOMINION footer" width="100%" />
</p>
