<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=Animations&fontColor=F2EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Smooth%20motion%20without%20messy%20effects&descAlignY=64&descSize=13" alt="Animations" width="100%" />
</p>

[Back to docs](README.md)

## Motion Principles

DXForge motion is built around short, consistent transitions:

| Area | Motion |
| --- | --- |
| Startup | Fade, scale, glow sweep, progress fill |
| Window | Open/close interpolation |
| Button | Hover and press feedback |
| Toggle | Smooth switch movement |
| Slider | Value smoothing |
| Dropdown | Expansion/collapse |
| ColorPicker | Reveal/collapse |
| Notification | Slide and fade |
| Tooltip | Delayed fade-in feel |

## Internal Animation Helper

DXForge uses:

```lua
DXForge:Animate(id, target, speed)
```

This stores animation values by `id` and interpolates toward `target`.

## Startup Performance

The startup logo is rendered only while the branded intro is active. When the intro finishes, DXForge releases the loaded logo reference and embedded raster run cache, so the normal UI path does not keep paying startup-logo cost.

## Tuning

Global animation speed lives in:

```lua
DXForge.Config.AnimationSpeed = 14
```

Higher values feel snappier. Lower values feel softer.

## Best Practices

- Keep transitions short for overlay UI.
- Use accent glow only for startup, active tabs, selected controls, and important feedback.
- Avoid stacking too many open dropdowns or pickers at once.
- Prefer consistent speeds over dramatic one-off effects.
