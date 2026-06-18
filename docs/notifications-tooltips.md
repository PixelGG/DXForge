<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Feedback&fontColor=F3EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Notifications%2C%20tooltips%2C%20delay%20and%20readability&descAlignY=64&descSize=13" alt="Feedback" width="100%" />
</p>

[Back to docs](README.md)

## Notifications

```lua
DXForge:Notify({
    Text = "Settings updated.",
    Type = "Success",
    Duration = 4
})
```

| Type | Accent |
| --- | --- |
| `Info` | Theme accent |
| `Success` | Success color |
| `Warning` | Warning color |
| `Error` | Error color |

Manual close:

```lua
DXForge:Notify({
    Text = "Review this important state.",
    Type = "Warning",
    ManualClose = true
})
```

Multiline notifications work through `\n`.

## Shorthand Notification

```lua
DXForge:Notify("Ready")
DXForge:Notify("Saved", 3, "Success")
```

## Tooltip Basics

Simple tooltip strings are supported:

```lua
Box:AddSlider({
    Text = "FOV",
    Tooltip = "Controls the FOV radius."
})
```

## Tooltip Behavior In Current DXForge

The `1.0.19` tooltip system supports:

- configurable delay
- multiline text through newline characters
- active theme colors
- screen-space rendering above the UI

## Tooltip Config Values

```lua
DXForge.Config.TooltipDelay = 0.25
```

Extended tooltip tables with keybind badges, max-width wrapping, fade tuning, and mouse-follow smoothing are not part of the downgraded `1.0.19` file.
