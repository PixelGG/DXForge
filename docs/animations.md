<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Animations&fontColor=F3EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Motion%20systems%20used%20across%20DXForge%201.0.19&descAlignY=64&descSize=13" alt="Animations" width="100%" />
</p>

[Back to docs](README.md)

## Motion Principles

DXForge uses short transitions instead of heavy effects:

| Area | Motion |
| --- | --- |
| Startup | Fade, scale, glow sweep, progress fill |
| Window | Open / close interpolation |
| Button | Hover glow and press feedback |
| Toggle | Track and knob movement |
| Slider | Value smoothing |
| Dropdown | Open-state interpolation |
| ColorPicker | Popup reveal |
| Notification | Slide and fade |
| Tooltip | Delay before showing |

## Internal Animation Helper

DXForge uses:

```lua
DXForge:Animate(id, target, speed)
```

This stores animation values by ID and interpolates them toward the target.

## Pulse Helper

```lua
local pulse = DXForge:Pulse(4)
```

`Pulse` is used for startup glow and other looping accent states.

## Tuning

Global animation speed:

```lua
DXForge.Config.AnimationSpeed = 15
```

Tooltip delay:

```lua
DXForge.Config.TooltipDelay = 0.25
```

## Best Practices

- keep overlay motion short
- use accent glow for active and meaningful states
- avoid rebuilding the UI every frame, because that resets animation continuity
- call `DXForge:Render()` once per DX9 frame after constructing the UI
