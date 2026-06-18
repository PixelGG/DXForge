<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Troubleshooting&fontColor=F3EEFF&fontSize=32&fontAlignY=38&animation=fadeIn&desc=Common%20DXForge%20setup%2C%20runtime%20and%20config%20fixes&descAlignY=64&descSize=13" alt="Troubleshooting" width="100%" />
</p>

[Back to docs](README.md)

## The UI Does Not Show

Make sure `DXForge:Render()` is called every frame:

```lua
DXForge:Render()
```

Also confirm the window is created before rendering.

## Startup Shows But Menu Does Not Appear

The branded startup intro intentionally hides the first window until the intro finishes. Wait for `DXForge.Config.StartupDuration`.

## Curved Edges Do Not Change

Check that you are calling:

```lua
DXForge:CurvedEdges(true)
DXForge:CurvedEdges(false)
```

If nothing changes, make sure you are using the current DXForge build and not an older cached `_G.DXForge` instance.

## Tooltips Do Not Appear

Check:

- the component is actually hovered
- `Tooltip` is present
- `DXForge.Config.TooltipDelay` is not too high
- the UI is not being rebuilt every frame

Rebuilding controls every frame can restart the hover owner and make the tooltip delay feel broken.

## Config Save Does Not Work

DXForge uses optional executor file functions such as:

```text
writefile
readfile
isfile
isfolder
makefolder
listfiles
delfile
```

If those APIs are unavailable in your environment, DXForge fails safely instead of crashing.

Enable debug output:

```lua
DXForge:SetDebug(true)
```

## Config Load Does Not Restore Values

Common causes:

- config was loaded before controls existed, but the script never created those controls later
- `ConfigId` or visible text changed, so the saved key no longer matches
- file path or filename is different from what you expect

If you rename controls often, use explicit `ConfigId` values.

## Theme Changes Do Not Persist

Theme persistence only works when you:

- call `DXForge:SaveConfig(...)`
- use autosave
- change colors through `SetThemeColor`, `UpdateTheme`, or theme-bound color pickers

## Dropdown Or Scroll Content Feels Stuck

DX9WARE does not document a mouse-wheel API, so DXForge uses draggable scrollbars for long dropdowns and window content.

## Debug Callback Errors

Enable debug mode:

```lua
DXForge:SetDebug(true)
```

Callbacks are protected with `pcall`, so a broken callback should not crash the whole UI.
