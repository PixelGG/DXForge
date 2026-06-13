<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=120&section=header&color=0:090A0F,45:FF4444,100:14151C&text=AR2+DOMINION&fontColor=F2EEFF&fontSize=38&fontAlignY=38&animation=fadeIn&desc=Apocalypse+Rising+2+%E2%80%94+DX9WARE+Script&descAlignY=64&descSize=14" alt="AR2 DOMINION animated header" width="100%" />
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
  <img src="https://img.shields.io/badge/author-PixelGG-1A1B22?style=flat-square&labelColor=101116&color=FF4444" alt="Author" />
</p>

<p align="center">
  <sub>Full-spectrum ESP. Smooth aimbot. Premium DXForge UI.</sub>
</p>

---

## Overview

AR2 DOMINION is a full-featured DX9WARE script for Apocalypse Rising 2. It covers player ESP, zombie ESP, vehicle ESP, loot container ESP, searchable loot ESP, world utility ESP, and dead body ESP — paired with a dual-target aimbot, a four-style crosshair, live overlay counters, and a DXForge-powered UI.

## Feature Grid

| ESP | Aimbot | Visuals & Overlays |
| --- | --- | --- |
| Player Box, Name, Distance | Player smooth aimbot | 4-style crosshair |
| Player Health Bar | Player FOV circle | Watermark |
| Player Tracelines & Skeleton | Sticky aim | FPS counter |
| Player Snap Lines | 11 selectable aim parts | Stats overlay |
| Player Nearest Indicator | First / Third Person mode | Session timer |
| Zombie Box, Name, Distance | Zombie smooth aimbot | Location tag |
| Zombie Type Classification | Independent zombie FOV | Show Console toggle |
| Zombie Health Bar & Skeleton | FOV source: Auto / Player / Zombie | DXForge UI |
| Zombie Nearest Indicator | — | — |
| Zombie Proximity Alert | — | — |
| Vehicle ESP (31 types, 5 categories) | — | — |
| Loot Container ESP | — | — |

## Components

```text
Player ESP          Zombie ESP          Vehicle ESP
Loot Container ESP  Searchable Loot ESP World Utility ESP
Dead Body ESP       Zombie Proximity Alert
Player Aimbot       Zombie Aimbot       FOV Circle
Crosshair           Watermark           Stats Overlay
FPS Counter         Session Timer       Location Tag
```

## Install

```lua
loadstring(dx9.Get("https://raw.githubusercontent.com/PixelGG/DXForge/main/Scripts/AR2/AR2_DOMINION.lua"))()
```

---

## UI Layout

| Tab | Groupbox | Controls |
| --- | --- | --- |
| ESP | Player ESP | Enable, Box, Name Tags, Distance, Health Bar, Tracelines, Skeleton, Snap Lines, Nearest Indicator, Max Distance, Box / Name / Trace / Nearest Color |
| ESP | Zombie ESP | Enable, Box, Name Tags, Distance, Health Bar, Tracelines, Skeleton, Zombie Type Label, Nearest Indicator, Max Distance, Box / Name / Nearest Color |
| ESP | Vehicle ESP | Enable, Box, Name & Category, Distance, Tracelines, Nearest Indicator, Max Distance, Name / Nearest Color |
| ESP | Loot ESP | Enable, Box, Name, Distance, Tracelines, Max Distance, Box / Name Color |
| ESP | Dead Body ESP | Enable, Box + X Marker, Name, Distance, Tracelines, Show Equipment, Show Dead Zombies, Show Dead Players, Max Distance, Box / Name Color |
| ESP | Alerts | Proximity Alert, Alert Distance |
| Aimbot | Player Aimbot | Enable, Sticky Aim, FOV, Smooth, Sensitivity, Aim Part, Aim Mode |
| Aimbot | Zombie Aimbot | Enable, FOV, Smooth, Sensitivity, Aim Part, Aim Mode |
| Aimbot | FOV Circle | Show FOV Circle, FOV Source, FOV Color |
| Visuals | Crosshair | Enable, Style, Size, Gap, Center Dot, Color |
| Visuals | Overlays | Watermark, FPS Counter, Stats Overlay, Show Location |
| Settings | General | Show Console, Script Info, Reset All Settings |

---

## Vehicle Categories

| Category | Vehicles |
| --- | --- |
| Civilian | Sedan, Station Wagon, Chevy Suburban, Chevy Blazer, Pickup Truck, Caprice, Mustang, Corvette, Jeep, Tractor, Quad |
| Commercial | Delivery Van, Cargo Van, Semi Truck, StepVan, Box Truck, Utility Truck |
| Military | Humvee, Military Pickup, Barracks Truck, Armored Truck |
| Emergency | Police CUV, Police Car, Ambulance, Firetruck |
| Boat | Speed Boat, Swing Keel Boat, Aluminum Boat, Lifeboat, Rubber Dinghy, Patrol Boat |

## Searchable Loot Categories

| Category |
| --- |
| Medical |
| Weapon |
| Food |
| Vehicle |
| Industrial |
| Utility |
| Civilian |

## Zombie Types

| Type | Classification Keywords |
| --- | --- |
| Military | Military, Soldier, Boot Camp, Drill, SWAT, SpecOps, Operator |
| Police | Police, Security, Prison |
| Unique | Unique, Cultist, Hazmat, Plague, Caveman, Butcher |
| Smuggler | Smuggler, Miner, Mobster |
| Civilian | Civilian, Resident, Tourist, Student, Hobo, Farmer, Hunter, Camper |

---

## Aimbot Reference

| Setting | Range | Default (Player) | Default (Zombie) |
| --- | --- | --- | --- |
| FOV | 10 – 1000 | 350 | 400 |
| Smooth | 1 – 20 | 1.5 | 1.2 |
| Sensitivity | 0.5 – 10 | 2.0 | 2.5 |
| Aim Part | Head … RightFoot (11) | Head | Head |
| Aim Mode | First Person / Third Person | First Person | First Person |
| Sticky Aim | Toggle | Off | — |

## Crosshair Styles

```text
1  Cross          — four-line crosshair
2  Dot            — single center dot
3  Circle         — full circle
4  Cross+Circle   — four-line crosshair with circle
```

---

## Credits

Created by **PixelGG**.  
UI powered by [DXForge](../../README.md) by **PixelGG**.

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=90&section=footer&color=0:14151C,55:FF4444,100:090A0F&animation=fadeIn" alt="AR2 DOMINION animated footer" width="100%" />
</p>
