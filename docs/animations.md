<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Animations&fontColor=F3EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Motion%20systems%20used%20across%20DXForge%201.1.x&descAlignY=64&descSize=13" alt="Animations" width="100%" />
</p>

[Back to docs](README.md)

## Motion Principles

DXForge uses short, coherent transitions instead of heavy effects:

| Area | Motion |
| --- | --- |
| Startup | Fade, scale, glow sweep, progress fill |
| Window | Open / close interpolation |
| Button | Hover glow and press feedback |
| Toggle | Animated track and knob movement |
| Slider | Value smoothing and handle growth |
| Dropdown | Open-state interpolation |
| Textbox | Hover and focus feedback |
| Keybind | Recording-state pulse |
| ColorPicker | Popup reveal |
| Notification | Slide and fade |
| Tooltip | Delay, fade-in, soft follow |

## Internal Animation Helper

DXForge uses:

```lua
DXForge:Animate(id, target, speed)
```

This stores animation values by ID and interpolates them toward the target.

## Shared Component Animation State

Configurable controls now use a shared internal animation table:

```lua
component.Anim = {
    Hover = 0,
    Active = 0,
    Focus = 0,
    Open = 0,
    Recording = 0
}
```

Internal helpers:

```lua
DXForge:InitComponentAnim(component)
DXForge:UpdateComponentAnim(component, states, speed)
DXForge:GetComponentAnim(component, key)
```

## Curved Edge Integration

Animation polish works in both styles:

- curved-edge mode
- sharp rectangular fallback mode

That means toggles, sliders, dropdowns, textboxes, and keybinds still animate even when `DXForge:CurvedEdges(false)` is used.

## Tuning

Global animation speed:

```lua
DXForge.Config.AnimationSpeed = 15
```

Tooltip fade speed:

```lua
DXForge.Config.TooltipFadeSpeed = 14
```

## Best Practices

- keep overlay motion short
- use accent glow for active and meaningful states
- let the shared animation system do the work instead of adding one-off effects
- avoid rebuilding the UI every frame, because that resets animation continuity
