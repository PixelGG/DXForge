<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Feedback&fontColor=F3EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Notifications%2C%20tooltips%2C%20delay%2C%20fade%20and%20readability&descAlignY=64&descSize=13" alt="Feedback" width="100%" />
</p>

[Back to docs](README.md)

## Notifications

```lua
DXForge:Notify({
    Text = "Settings saved.",
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

## Tooltip Basics

Simple tooltip strings still work:

```lua
Tooltip = "Controls the FOV radius.\nHold SHIFT for precision."
```

## Extended Tooltip Syntax

```lua
Tooltip = {
    Text = "Controls the FOV radius.\nHold SHIFT for precision.",
    Keybind = "[SHIFT]",
    MaxWidth = 280
}
```

## Tooltip Behavior In Current DXForge

The tooltip system now supports:

- configurable delay
- smooth fade-in
- multiline text
- automatic line wrapping
- max width control
- screen clamping
- slight mouse-follow smoothing
- optional keybind badge
- curved edge styling when enabled

## Tooltip Config Values

```lua
DXForge.Config.TooltipDelay = 0.25
DXForge.Config.TooltipFadeSpeed = 14
DXForge.Config.TooltipMaxWidth = 260
DXForge.Config.TooltipPadding = 8
DXForge.Config.TooltipOffset = {14, 16}
DXForge.Config.TooltipFollowStrength = 0.18
```

## Automatic Keybind Hints

If a component has a `Keybind` field, DXForge can surface it in the tooltip automatically. You can also provide the keybind explicitly through the extended tooltip table.

## Styling Notes

Tooltips use:

- active theme colors
- premium floating card styling
- curved corners when available
- rectangular fallback when curved edges are disabled
