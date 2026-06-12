<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=DX9%20Compatibility&fontColor=F2EEFF&fontSize=31&fontAlignY=38&animation=fadeIn&desc=Cult-of-Intellect%20DX9%20API%20expectations%20and%20fallbacks&descAlignY=64&descSize=13" alt="DX9 Compatibility" width="100%" />
</p>

[Back to docs](README.md)

## Required DX9 Functions

DXForge is written around the common Cult-of-Intellect-style DX9 Lua API surface:

| Function | Used for |
| --- | --- |
| `dx9.size()` | Screen width and height. |
| `dx9.GetMouse()` | Mouse position. |
| `dx9.isLeftClickHeld()` | Click, drag, slider, dropdown, and picker input. |
| `dx9.GetKey()` | Toggle keys, keybinds, and textbox input. |
| `dx9.CalcTextWidth(text)` | Text trimming and layout. |
| `dx9.DrawString(pos, color, text)` | Text rendering. |
| `dx9.DrawFilledBox(pos1, pos2, color)` | Panels, controls, and fills. |
| `dx9.DrawBox(pos1, pos2, color)` | Borders. |
| `dx9.DrawLine(pos1, pos2, color)` | Dividers, sweeps, and markers. |

## Optional DX9 Functions

| Function | Fallback |
| --- | --- |
| `dx9.DrawImage(...)` | Startup logo falls back to text branding. |
| `dx9.Get(url)` | Remote logo loading is skipped if unavailable or incompatible. |

## Compatibility Notes

- DXForge wraps DX9 draw/input calls with protected calls where practical.
- Coordinates are rounded and rectangle points are normalized before drawing.
- Colors are passed as `{r, g, b}` tables for broad DX9 compatibility.
- If image rendering is unsupported, the mandatory startup screen still shows DXForge text and the `PixelGG` signature.
- Textbox typing depends on the key strings returned by `dx9.GetKey()`.

## Quick Sanity Test

```lua
print(dx9.size().width, dx9.size().height)
print(dx9.GetMouse().x, dx9.GetMouse().y)
print(dx9.GetKey())
```

If those functions work in your environment, the core DXForge UI path should render.
