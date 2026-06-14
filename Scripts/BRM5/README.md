<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=120&section=header&color=0:090A0F,45:FF3C3C,100:14151C&text=BRM5+WARZONE&fontColor=F2EEFF&fontSize=38&fontAlignY=38&animation=fadeIn&desc=Ronograd+%E2%80%94+DX9WARE+Script&descAlignY=64&descSize=14" alt="BRM5 WARZONE animated header" width="100%" />
</p>

<p align="center">
  <a href="https://git.io/typing-svg">
    <img src="https://readme-typing-svg.demolab.com?font=Inter&weight=600&size=20&duration=2600&pause=700&color=FF3C3C&center=true&vCenter=true&width=820&lines=Player+%26+NPC+ESP+with+aimbot+%26+10+aim+parts;Vehicle%2C+Loot+%26+Spawner+ESP+for+Ronograd;Counter+recoil%2C+FOV+circle+%26+4-style+crosshair;Powered+by+DXForge+%E2%80%94+premium+DX9+UI" alt="Animated BRM5 WARZONE description" />
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Lua-DX9-1A1B22?style=flat-square&logo=lua&logoColor=white&labelColor=101116&color=FF3C3C" alt="Lua DX9" />
  <img src="https://img.shields.io/badge/version-3.0.0-1A1B22?style=flat-square&labelColor=101116&color=FF3C3C" alt="Version" />
  <img src="https://img.shields.io/badge/game-Ronograd-1A1B22?style=flat-square&labelColor=101116&color=FF3C3C" alt="Game" />
  <img src="https://img.shields.io/badge/UI-DXForge%20v1.0.19-1A1B22?style=flat-square&labelColor=101116&color=FF3C3C" alt="DXForge" />
  <img src="https://img.shields.io/badge/author-Lorthanyx-1A1B22?style=flat-square&labelColor=101116&color=FF3C3C" alt="Author" />
</p>

<p align="center">
  <sub>Full-spectrum ESP. Smooth aimbot. Counter recoil. Premium DXForge UI.</sub>
</p>

---

## Overview

BRM5 WARZONE is a full-featured DX9WARE script for Ronograd. It covers player ESP, NPC ESP, vehicle ESP, loot & ammo ESP, and spawner ESP — paired with a dual-target aimbot featuring counter recoil, a four-style crosshair, live overlay counters, and a DXForge-powered UI.

## Feature Grid

| ESP | Aimbot | Visuals & Overlays |
| --- | --- | --- |
| Player Box, Name, Distance | Player smooth aimbot | 4-style crosshair |
| Player Health Bar | Player FOV circle | Watermark |
| Player Tracers & Skeleton | 10 selectable aim parts | FPS counter |
| Player Head Dot & Snap Line | First / Third Person mode | Stat tracker |
| NPC Box, Name, Distance | Counter recoil (hotkey) | Debug mode |
| NPC Health Bar & Skeleton | NPC smooth aimbot | DXForge UI |
| NPC Tracers & Head Dot | Independent NPC FOV | — |
| Vehicle ESP (34 types) | — | — |
| Loot & Ammo ESP | — | — |
| Spawner ESP (FOB, Vendor, …) | — | — |

## Components

```text
Player ESP          NPC ESP             Vehicle ESP
Loot & Ammo ESP     Spawner ESP
Player Aimbot       NPC Aimbot          FOV Circle
Counter Recoil      Crosshair           Watermark
FPS Counter         Stat Tracker
```

## Install

```lua
loadstring(dx9.Get("https://raw.githubusercontent.com/PixelGG/DXForge/main/Scripts/BRM5/BRM5.lua"))()
```

---

## UI Layout

| Tab | Groupbox | Controls |
| --- | --- | --- |
| Players | Player ESP | Enable, Box, Name, Head Dot, Dot Radius, Distance, Tracers, Skeleton, Health Bar, Snap Line, Box / Name / Tracer Color |
| Players | Player Aimbot | Enable, Aim Part, Aim Mode, Sensitivity, Smooth, FOV, Show FOV, Counter Recoil, Recoil Power |
| NPCs | NPC ESP | Enable, Box, Name, Head Dot, Dot Radius, Distance, Tracers, Skeleton, Health Bar, Box / Name Color |
| NPCs | NPC Aimbot | Enable, Aim Part, Aim Mode, Sensitivity, Smooth, FOV, Show FOV |
| World | Vehicle ESP | Enable, Box, Name, Distance, Tracers, Box / Name Color |
| World | Loot & Ammo ESP | Enable, Box, Name, Distance, Tracers, Max Distance, Box / Name Color |
| World | Spawner ESP | Enable, Box, Name, Distance, Tracers, Box / Name Color |
| Visuals | Crosshair | Enable, Style, Center Dot, Size, Gap, Color |
| Visuals | Overlays | Watermark, FPS Counter, Stat Tracker, Debug Mode |
| Settings | General | Show Console, Reset All Settings, Script Info |

---

## Vehicle List

| Category | Vehicles |
| --- | --- |
| Wheeled (Light) | M998, Humvee, Humvee M1152, Humvee M1165, Humvee RET, Tigr SPM, Tigr RWS, SRTV, PVP, Jeep |
| Wheeled (Heavy) | FMTV Truck, LMTV Truck, Ural 4320, Ural 43206, Ural 4320 AI |
| Armored | BTR-70 APC, BRDM-2 Scout Car, Stryker APC, Cougar HE, VBMR, VAB APC, BMP-2 IFV, BMP-2 Turret |
| Armor / Tank | T-72A Tank |
| Aircraft | CH-47D Chinook, CH-53, MD500, MH-60S, Mi-8 AI, Mi-8 MTV-3, NH90, UH-60, UH-60K |
| Utility | Mech Cart 1, Mech Cart 2, Mech Cart 3 |

## Loot & Ammo Items

| Type | Items |
| --- | --- |
| Ammo | 7.62mm Ammo, .50 Cal Ammo, Long Ammo Box, Ammo Box, Ammo Can, Quest Ammo |
| Crates | Ammo Crate, Ammo Crates |
| AI Mags | AR Mag, AK Mag, SVD Mag, RPK Mag, PKM Mag, PP19 Mag, UMP45 Mag |
| Containers | Weapon Cab 1–4, Weapon Crate, Ammo Crate, Cooler Crate, Equipment Case, Storage Cabinet |

## Spawner Keywords

```text
Spawner  Vendor  Company  FOB  Heli  Garage  MotorPool
Armory   Supply  Depot    Spawn
```

---

## Aimbot Reference

| Setting | Range | Default (Player) | Default (NPC) |
| --- | --- | --- | --- |
| FOV | 50 – 500 | 350 | 400 |
| Smooth | 1 – 10 | 1.5 | 1.5 |
| Sensitivity | 1 – 10 | 2.0 | 2.0 |
| Aim Part | Head … RightFoot (10) | Head | Head |
| Aim Mode | First Person / Third Person | First Person | First Person |
| Recoil Power | 1 – 20 | 4.0 | — |
| Counter Recoil | Toggle + Hotkey | Off | — |

## Aim Parts

```text
Head          UpperTorso    LowerTorso
LeftUpperArm  RightUpperArm
LeftHand      RightHand
LeftUpperLeg  RightUpperLeg
LeftFoot      RightFoot
```

## Crosshair Styles

```text
1  Cross          — four-line crosshair
2  Dot            — single center dot
3  Circle         — full circle
4  Cross+Circle   — four-line crosshair with circle
```

---

## Credits

Created by **Lorthanyx**.  
UI powered by [DXForge](../../README.md) by **PixelGG**.

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=90&section=footer&color=0:14151C,55:FF3C3C,100:090A0F&animation=fadeIn" alt="BRM5 WARZONE animated footer" width="100%" />
</p>
