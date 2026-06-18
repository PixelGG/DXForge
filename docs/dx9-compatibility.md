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
| `dx9.DrawFilledBox(pos1, pos2, color)` | Panels, controls, fills, rounded fallback composition |
| `dx9.DrawLine(pos1, pos2, color)` | Dividers, markers, fallback circles |

## Optional DX9 Functions

| Function | Fallback |
| --- | --- |
| `dx9.DrawImage(...)` | Startup logo falls back to embedded raster rendering |
| `dx9.DrawCircle(...)` | FOV circle falls back to segmented line rendering |

## Optional File APIs For Config Persistence

DXForge `1.1.3` can use optional file APIs if the environment exposes them:

| Function | Used for |
| --- | --- |
| `writefile` | Save configs |
| `readfile` | Load configs |
| `isfile` | Existence checks |
| `isfolder` | Folder checks |
| `makefolder` | Config folder creation |
| `listfiles` | Config listing |
| `delfile` | Config deletion |

If these functions are missing, DXForge does not crash. Saving and loading simply fail gracefully, with debug output only when `DXForge.Debug == true`.

## Rounded UI Compatibility

DXForge does not assume native rounded rectangle support. Rounded surfaces are composed from lightweight filled-box passes, so curved edges stay compatible with DX9-style drawing primitives.

## Correct Loading Pattern

```lua
local DXForge = _G.DXForge or dofile("DXForge.lua")
```

## Notes

- DXForge wraps many DX9 calls with protected execution where practical
- coordinates are normalized and clamped before rendering
- draggable scrollbars are used because no official mouse-wheel API is documented
- config persistence depends on optional file APIs, not on the `dx9` library itself
