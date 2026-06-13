<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=120&section=header&color=0:090A0F,45:FF4444,100:14151C&text=AR2+DOMINION&fontColor=F2EEFF&fontSize=36&fontAlignY=38&animation=fadeIn&desc=Apocalypse+Rising+2+%E2%80%94+DX9WARE+Script&descAlignY=64&descSize=14" alt="AR2 DOMINION animated header" width="100%" />
</p>

<p align="center">
  <a href="https://git.io/typing-svg">
    <img src="https://readme-typing-svg.demolab.com?font=Inter&weight=600&size=20&duration=2600&pause=700&color=FF4444&center=true&vCenter=true&width=820&lines=Full-spectrum+ESP+for+players%2C+zombies%2C+vehicles+%26+loot;Smooth+aimbot+with+FOV%2C+sticky+aim+%26+11+aim+parts;Powered+by+DXForge+%E2%80%94+premium+DX9+UI" alt="Animated AR2 DOMINION description" />
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Lua-DX9-1A1B22?style=flat-square&logo=lua&logoColor=white&labelColor=101116&color=FF4444" alt="Lua DX9" />
  <img src="https://img.shields.io/badge/version-5.0.0-1A1B22?style=flat-square&labelColor=101116&color=FF4444" alt="Version" />
  <img src="https://img.shields.io/badge/game-Apocalypse%20Rising%202-1A1B22?style=flat-square&labelColor=101116&color=FF4444" alt="Game" />
  <img src="https://img.shields.io/badge/UI-DXForge%20v1.0.19-1A1B22?style=flat-square&labelColor=101116&color=FF4444" alt="DXForge" />
  <img src="https://img.shields.io/badge/author-Lorthanyx-1A1B22?style=flat-square&labelColor=101116&color=FF4444" alt="Author" />
</p>

<p align="center">
  <sub>Full-spectrum ESP. Smooth aimbot. Premium DXForge UI. Built for AR2 on DX9 Cult of Intellect.</sub>
</p>

---

## Overview

AR2 DOMINION is a full-featured DX9WARE script for Apocalypse Rising 2. It is built around a modular ESP system covering players, zombies, vehicles, loot containers, searchable objects, world utilities, and dead bodies — paired with a dual-target aimbot, a four-style crosshair, live overlay counters, and a DXForge-powered professional UI that loads cleanly on every script execution.

## Feature Grid

| ESP | Aimbot | Visuals & Overlays |
| --- | --- | --- |
| Player Box, Name, Distance | Player smooth aimbot | 4-style crosshair |
| Player Health Bar | Player FOV circle | Watermark + location tag |
| Player Skeleton & Tracelines | Sticky aim | FPS counter |
| Player Snap Lines | 11 selectable aim parts | Stats overlay (P/Z/V/S/U/B) |
| Zombie Box, Name, Distance | First / Third Person mode | Session timer |
| Zombie Type Classification | Zombie smooth aimbot | DXForge startup screen |
| Zombie Health Bar & Skeleton | Independent zombie FOV | Configurable UI toggle key |
| Vehicle ESP (31 types, 5 categories) | FOV circle (Auto / Player / Zombie) | DX9 Cult of Intellect target |
| Loot Container ESP (40+ containers) | — | — |
| Searchable Loot ESP (7 categories) | — | — |
| World Utility ESP (5 types) | — | — |
| Dead Body ESP + X-marker | — | — |
| Corpse Equipment Preview | — | — |
| Zombie Proximity Alert | — | — |
| Nearest entity indicators | — | — |

## Components

```text
Player ESP          Zombie ESP          Vehicle ESP
Loot Container ESP  Searchable Loot ESP World Utility ESP
Dead Body ESP       Corpse Gear Preview Proximity Alert
Player Aimbot       Zombie Aimbot       FOV Circle
Crosshair           Watermark           Stats Overlay
FPS Counter         Session Timer       Location Tag
```

## Install

Paste the script into DX9 Cult of Intellect. DXForge is fetched automatically on every run.

```lua
-- Run inside DX9WARE (Cult of Intellect)
-- DXForge is downloaded and bootstrapped automatically.
-- Toggle the menu with F6.
dofile("AR2_DOMINION.lua")
```

DX9WARE executes Lua every frame. AR2 DOMINION guards against double-initialization via `_G.AR2_DOMINION_RUNTIME` so only one live instance runs at a time.

## Quick Start

```lua
-- AR2 DOMINION self-bootstraps. On first run it will:
--   1. Destroy any previous DXForge / state
--   2. Download DXForge from GitHub
--   3. Build the full DXForge window
--   4. Enter the render loop automatically

-- Toggle menu:  F6
-- All settings persist in _G.DOMINION_STATE across re-runs.
```

## UI Layout

| Tab | Groupboxes | Key Controls |
| --- | --- | --- |
| ESP | Player ESP | Box, Name, Health Bar, Skeleton, Tracelines, Snap Lines, Nearest |
| ESP | Zombie ESP | Box, Name, Type Label, Health Bar, Skeleton, Tracelines, Nearest |
| ESP | Vehicle ESP | Box, Name & Category, Distance, Tracelines, Nearest, Max Distance |
| ESP | Loot ESP | Box, Name, Distance, Tracelines, Max Distance |
| ESP | Dead Body ESP | Box + X Marker, Name, Distance, Equipment, Show Dead Zombies/Players |
| ESP | Alerts | Proximity Alert toggle + Alert Distance slider |
| Aimbot | Player Aimbot | Enable, Sticky Aim, FOV, Smooth, Sensitivity, Aim Part, Aim Mode |
| Aimbot | Zombie Aimbot | Enable, FOV, Smooth, Sensitivity, Aim Part, Aim Mode |
| Aimbot | FOV Circle | Show, FOV Source (Auto/Player/Zombie), Color |
| Visuals | Crosshair | Enable, Style (Cross/Dot/Circle/Cross+Circle), Size, Gap, Center Dot, Color |
| Visuals | Overlays | Watermark, FPS Counter, Stats Overlay, Show Location |
| Settings | General | Show Console, Script Info labels, Reset All Settings |

## Vehicle Categories

| Category | Vehicles |
| --- | --- |
| Civilian | Sedan, Station Wagon, Chevy Suburban, Chevy Blazer, Pickup Truck, Caprice, Mustang, Corvette, Jeep, Tractor, Quad |
| Commercial | Delivery Van, Cargo Van, Semi Truck, StepVan, Box Truck, Utility Truck |
| Military | Humvee, Military Pickup, Barracks Truck, Armored Truck |
| Emergency | Police CUV, Police Car, Ambulance, Firetruck |
| Boat | Speed Boat, Swing Keel Boat, Aluminum Boat, Lifeboat, Rubber Dinghy, Patrol Boat |

## Searchable Loot Categories

| Category | Color |
| --- | --- |
| Medical | Green |
| Weapon | Orange-Red |
| Food | Yellow |
| Vehicle | Blue |
| Industrial | Light Grey |
| Utility | Purple |
| Civilian | Tan |

Each searchable category can be individually toggled in the ESP tab. Objects include barrels, cabinets, crates, vending machines, medical kits, vehicle trunks, and more.

## World Utilities

| Type | Color |
| --- | --- |
| Fuel Pump | Amber |
| Water Pump | Blue |
| Ladder | Grey |
| Switch | Yellow |
| Garage Control | Orange |

## Zombie Types

| Type | Color |
| --- | --- |
| Military | Green |
| Police | Blue |
| Unique | Pink |
| Smuggler | Orange |
| Civilian | Light Grey |

Zombie type is auto-classified from the model name and displayed as a colored prefix tag in the ESP label (e.g. `[Military] Drill Sergeant`).

## Aimbot Reference

| Setting | Range | Default | Description |
| --- | --- | --- | --- |
| FOV | 10 – 1000 | 350 (P) / 400 (Z) | Screen-space aim circle radius |
| Smooth | 1 – 20 | 1.5 (P) / 1.2 (Z) | Mouse interpolation strength |
| Sensitivity | 0.5 – 10 | 2.0 (P) / 2.5 (Z) | Per-frame correction scale |
| Aim Part | 11 parts | Head | Target bone selection |
| Aim Mode | First / Third Person | First Person | Camera perspective mode |
| Sticky Aim | Toggle | Off | Locks target between frames (players only) |

## Crosshair Styles

```text
Cross          ─ Classic four-line crosshair
Dot            ─ Single center dot
Circle         ─ Full circle at configured radius
Cross+Circle   ─ Four-line crosshair inside a circle
```

All styles support an optional center dot, configurable size, gap, and color.

## Stats Overlay

A compact live counter rendered in the top-right corner of the screen:

```text
P: <players>      — visible player ESP entries
Z: <zombies>      — visible zombie ESP entries
V: <vehicles>     — visible vehicle ESP entries
S: <searchables>  — visible searchable loot entries
U: <utilities>    — visible world utility entries
B: <bodies>       — visible dead body entries
```

## Performance Defaults

| Cache | Interval |
| --- | --- |
| Entity (Players) | 1.0 s |
| Zombies | 3.0 s |
| Vehicles | 4.0 s |
| Loot Containers | 2.0 s |
| Searchable Loot | 8.0 s |
| World Utilities | 10.0 s |
| Dead Bodies | 2.0 s |
| Local Player | 0.8 s |
| Location Detection | 2.0 s |
| Max Scan Budget | 3000 objects/refresh |

## Project Layout

```text
Scripts/AR2/
└── AR2_DOMINION.lua
```

DXForge is fetched at runtime from `raw.githubusercontent.com/PixelGG/DXForge/main/DXForge.lua` and cached in `_G.DXForge` for the lifetime of the script.

## Credits

Script by **Lorthanyx**.  
UI powered by [DXForge](../../README.md) by **PixelGG**.  
Target platform: **DX9 Cult of Intellect** for Roblox.

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=90&section=footer&color=0:14151C,55:FF4444,100:090A0F&animation=fadeIn" alt="AR2 DOMINION animated footer" width="100%" />
</p>
