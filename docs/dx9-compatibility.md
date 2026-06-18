<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=DX9%20Compatibility&fontColor=F3EEFF&fontSize=31&fontAlignY=38&animation=fadeIn&desc=Cult%20of%20Intellect%20DX9WARE%20API%20expectations%20and%20fallbacks&descAlignY=64&descSize=13" alt="DX9 Compatibility" width="100%" />
</p>

[Back to docs](README.md)

## Runtime Model

DXForge targets DX9WARE's vanilla Lua `5.1.4` environment with the additional `dx9` library. It is not a Roblox GUI library and does not rely on Roblox `Instance`, `game`, or `game:HttpGet`.

## Required DX9 Functions

| Function | Used for |
| --- | --- |
| `dx9.size()` | Screen width and height |
| `dx9.GetMouse()` | Mouse position |
| `dx9.isLeftClickHeld()` | Click, drag, slider, dropdown, and picker input |
| `dx9.GetKey()` | Toggle keys, keybinds, and textbox input |
| `dx9.CalcTextWidth(text)` | Text trimming and layout |
| `dx9.DrawString(pos, color, text)` | Text rendering |
| `dx9.DrawFilledBox(pos1, pos2, color)` | Panels, controls, fills, logo fallback |
| `dx9.DrawLine(pos1, pos2, color)` | Dividers, markers, fallback circles |

## Optional DX9 Functions

| Function | Fallback |
| --- | --- |
| `dx9.DrawImage(...)` | Startup logo falls back to embedded raster rendering |
| `dx9.DrawCircle(...)` | FOV circle falls back to segmented line rendering |

## Optional File APIs

DXForge `1.0.19` uses optional file APIs only for startup-logo cache helpers when available. Built-in user config persistence is not part of the current library file.

| Function | Used for |
| --- | --- |
| `writefile` | Logo cache writes |
| `isfile` | Logo source existence checks |

## Rendering Compatibility

DXForge uses standard DX9 primitives for rectangular surfaces, lines, text, circles, and image fallback paths. Rounded-edge helpers and curved-edge toggles are not part of this downgraded `1.0.19` file.

## Correct Loading Pattern

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")
```

## Notes

- DXForge wraps many DX9 calls with protected execution where practical
- coordinates are normalized and clamped before rendering
- draggable scrollbars are used because no official mouse-wheel API is documented
- script-specific state is handled by the individual game scripts, not by DXForge config files
