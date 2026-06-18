<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Troubleshooting&fontColor=F3EEFF&fontSize=32&fontAlignY=38&animation=fadeIn&desc=Common%20DXForge%20setup%20and%20runtime%20fixes&descAlignY=64&descSize=13" alt="Troubleshooting" width="100%" />
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

```lua
DXForge.Config.StartupDuration = 3.15
```

## You Still See A Newer DXForge Build

The game scripts currently download DXForge from GitHub:

```lua
dx9.Get("https://raw.githubusercontent.com/PixelGG/DXForge/main/DXForge.lua")
```

If you want a local downgraded file to be used, update the script loader or host the desired `DXForge.lua` version at the URL the script loads.

## Tooltips Do Not Appear

Check:

- the component is actually hovered
- `Tooltip` is a string
- `DXForge.Config.TooltipDelay` is not too high
- the UI is not being rebuilt every frame

Rebuilding controls every frame can restart the hover timer and make the tooltip delay feel broken.

## Dropdown Or Scroll Content Feels Stuck

DX9WARE does not document a mouse-wheel API, so DXForge uses draggable scrollbars for long dropdowns and window content.

## Theme Changes Do Not Persist

DXForge `1.0.19` supports runtime theme edits, but it does not include built-in file config persistence. If a script needs persistence, it must implement that separately.

## Debug Callback Errors

Enable debug mode:

```lua
DXForge:SetDebug(true)
```

Callbacks are protected with `pcall`, so a broken callback should not crash the whole UI.
