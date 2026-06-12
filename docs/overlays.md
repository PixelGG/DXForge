<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=Overlays&fontColor=F2EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=FOV%20circle%20and%20lightweight%20DX9%20helpers&descAlignY=64&descSize=13" alt="Overlays" width="100%" />
</p>

[Back to docs](README.md)

## FOV Circle

DXForge includes an optional FOV circle overlay for scripts that need a clean visual radius indicator.

```lua
DXForge:SetFOVCircle({
    Visible = true,
    Radius = 120,
    Color = {184, 94, 255},
    Thickness = 1,
    Segments = 96,
    FollowMouse = false,
    Outline = true
})
```

Options:

| Field | Description |
| --- | --- |
| `Visible` | Shows or hides the FOV circle. |
| `Radius` | Radius in pixels. |
| `Color` | RGB/RGBA color table. |
| `Thickness` | Line thickness. |
| `Segments` | Line fallback segment count, clamped from `24` to `192`. |
| `Position` | Fixed center position. Defaults to screen center. |
| `FollowMouse` | Centers the circle on the mouse. |
| `Outline` | Draws a subtle dark outline for contrast. |

DXForge tries `dx9.DrawCircle` when available. If the runtime does not expose it, the circle is drawn with `dx9.DrawLine` segments.

## Hide The Circle

```lua
DXForge:SetFOVCircle(false)
```

The FOV circle is cleared by `DXForge:Destroy()`.

