<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=120&section=header&color=0:090A0F,45:FF3C3C,100:161821&text=BRM5%20WARZONE&fontColor=F3EEFF&fontSize=38&fontAlignY=38&animation=fadeIn&desc=Ronograd%20DX9WARE%20Script&descAlignY=64&descSize=14" alt="BRM5 WARZONE header" width="100%" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Lua-DX9-1A1B22?style=flat-square&logo=lua&logoColor=white&labelColor=101116&color=FF3C3C" alt="Lua DX9" />
  <img src="https://img.shields.io/badge/script-BRM5%20WARZONE-1A1B22?style=flat-square&labelColor=101116&color=FF3C3C" alt="Script" />
  <img src="https://img.shields.io/badge/game-Ronograd-1A1B22?style=flat-square&labelColor=101116&color=FF3C3C" alt="Game" />
  <img src="https://img.shields.io/badge/UI-DXForge%201.0.19-1A1B22?style=flat-square&labelColor=101116&color=FF3C3C" alt="DXForge UI" />
  <img src="https://img.shields.io/badge/author-PixelGG-1A1B22?style=flat-square&labelColor=101116&color=FF3C3C" alt="Author" />
</p>

<p align="center">
  <sub>Ronograd ESP, player and NPC aimbot flows, recoil assistance, polished overlays, and DXForge 1.0.19 UI.</sub>
</p>

---

## Overview

`BRM5.lua` is the Ronograd / BRM5-focused DX9WARE script in this repository. It combines player and NPC ESP, world ESP, configurable aimbot behavior, recoil assistance, overlay utilities, and a DXForge-driven five-tab menu.

## Key Systems

| Category | Included |
| --- | --- |
| Player ESP | Box, name, distance, health, tracers, skeleton, head dot, snap line |
| NPC ESP | Box, name, distance, health, tracers, skeleton, head dot |
| World ESP | Vehicles, loot, ammo, spawners |
| Aimbot | Player aimbot, NPC aimbot, FOV controls, smoothness, sensitivity, aim-part selection |
| Combat Utility | Counter recoil with configurable power |
| Overlays | Crosshair, watermark, FPS counter, stat tracker, debug display |
| UI | DXForge 1.0.19 with Players, NPCs, World, Visuals, and Settings tabs |

## Install

```lua
loadstring(dx9.Get("https://raw.githubusercontent.com/PixelGG/DXForge/main/Scripts/BRM5/BRM5.lua"))()
```

## Runtime Notes

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")
```

The script downloads and initializes DXForge itself, then stores runtime state in `_G.WARZONE`. Built-in file config save/load is not part of the current DXForge `1.0.19` file.

## UI Layout

| Tab | Groupbox | Main controls |
| --- | --- | --- |
| Players | Player ESP | Enable, box, name, head dot, dot radius, distance, tracers, skeleton, health bar, snap line, colors |
| Players | Player Aimbot | Enable, aim part, aim mode, sensitivity, smooth, FOV, show FOV, counter recoil, recoil power |
| NPCs | NPC ESP | Enable, box, name, head dot, dot radius, distance, tracers, skeleton, health bar, colors |
| NPCs | NPC Aimbot | Enable, aim part, aim mode, sensitivity, smooth, FOV, show FOV |
| World | Vehicle ESP | Enable, box, name, distance, tracers, colors |
| World | Loot & Ammo ESP | Enable, box, name, distance, tracers, max distance, colors |
| World | Spawner ESP | Enable, box, name, distance, tracers, colors |
| Visuals | Crosshair | Enable, style, center dot, size, gap, color |
| Visuals | Overlays | Watermark, FPS counter, stat tracker, debug mode, show console |
| Settings | General | Place info, UI info, cache reset, state reset |

## Vehicle Groups

| Category | Vehicles |
| --- | --- |
| Wheeled Light | M998, Humvee, Humvee M1152, Humvee M1165, Humvee RET, Tigr SPM, Tigr RWS, SRTV, PVP, Jeep |
| Wheeled Heavy | FMTV Truck, LMTV Truck, Ural 4320, Ural 43206, Ural 4320 AI |
| Armored | BTR-70 APC, BRDM-2 Scout Car, Stryker APC, Cougar HE, VBMR, VAB APC, BMP-2 IFV, BMP-2 Turret |
| Armor | T-72A Tank |
| Aircraft | CH-47D Chinook, CH-53, MD500, MH-60S, Mi-8 AI, Mi-8 MTV-3, NH90, UH-60, UH-60K |
| Utility | Mech Cart 1, Mech Cart 2, Mech Cart 3 |

## Loot And Spawner Coverage

| Area | Included |
| --- | --- |
| Ammo | 7.62mm Ammo, .50 Cal Ammo, Long Ammo Box, Ammo Box, Ammo Can, Quest Ammo |
| Weapon / Storage | Weapon Cabinets, Weapon Crates, Equipment Cases, Storage Cabinets, Coolers |
| AI Magazines | AR, AK, SVD, RPK, PKM, PP19, UMP45 mags |
| Spawner keywords | `Spawner`, `Vendor`, `Company`, `FOB`, `Heli`, `Garage`, `MotorPool`, `Armory`, `Supply`, `Depot`, `Spawn` |

## Aimbot Reference

| Setting | Range | Player default | NPC default |
| --- | --- | --- | --- |
| FOV | `50 - 500` | `350` | `400` |
| Smooth | `1 - 10` | `1.5` | `1.5` |
| Sensitivity | `1 - 10` | `2.0` | `2.0` |
| Aim Part | `Head` to `RightFoot` | `Head` | `Head` |
| Aim Mode | `First Person / Third Person` | `First Person` | `First Person` |
| Recoil Power | `1 - 20` | `4.0` | `-` |
| Counter Recoil | Toggle + hotkey | `Off` | `-` |

## Aim Parts

```text
Head
UpperTorso
LowerTorso
LeftUpperArm
RightUpperArm
LeftHand
RightHand
LeftUpperLeg
RightUpperLeg
LeftFoot
RightFoot
```

## Crosshair Styles

| Style | Meaning |
| --- | --- |
| `1` | Cross |
| `2` | Dot |
| `3` | Circle |
| `4` | Cross + Circle |

## Visual Standard

This README is now aligned with the rest of the repository:

- same badge language
- same layout density
- same current DXForge 1.0.19 version reference
- same premium dark-tech presentation standard

## Related Docs

| File | Purpose |
| --- | --- |
| [../../README.md](../../README.md) | Main DXForge overview |
| [../../docs/README.md](../../docs/README.md) | Documentation hub |
| [../AR2/README.md](../AR2/README.md) | AR2 sister script |

## Credits

Created by **PixelGG**.  
UI powered by **DXForge 1.0.19**.

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=88&section=footer&color=0:161821,55:FF3C3C,100:090A0F&animation=fadeIn" alt="BRM5 WARZONE footer" width="100%" />
</p>
