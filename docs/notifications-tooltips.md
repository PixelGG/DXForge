<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=Feedback&fontColor=F2EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Notifications%20and%20tooltips%20that%20stay%20readable&descAlignY=64&descSize=13" alt="Feedback" width="100%" />
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

Types:

| Type | Accent |
| --- | --- |
| `Info` | Theme accent |
| `Success` | Success color |
| `Warning` | Warning color |
| `Error` | Error color |

## Multiline Notifications

```lua
DXForge:Notify({
    Text = "Profile loaded.\nAll controls were restored.",
    Type = "Info",
    Duration = 5
})
```

## Tooltips

Add `Tooltip` to supported component configs:

```lua
Box:AddSlider({
    Text = "FOV",
    Min = 40,
    Max = 120,
    Default = 90,
    Tooltip = "Controls the field of view value.",
    Callback = function(value) end
})
```

Tooltip delay:

```lua
DXForge.Config.TooltipDelay = 0.25
```

Tooltips automatically clamp to the screen so they do not render offscreen.

