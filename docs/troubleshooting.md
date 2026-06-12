<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=Troubleshooting&fontColor=F2EEFF&fontSize=32&fontAlignY=38&animation=fadeIn&desc=Common%20DXForge%20setup%20and%20runtime%20fixes&descAlignY=64&descSize=13" alt="Troubleshooting" width="100%" />
</p>

[Back to docs](README.md)

## The UI Does Not Show

Check that `DXForge:Render()` is called every frame/script tick.

```lua
DXForge:Render()
```

Also confirm that the window was created before rendering:

```lua
local Window = DXForge:CreateWindow({Title = "Menu"})
```

## Startup Shows But Menu Does Not Appear

Startup hides the window until the intro completes. This is intentional DXForge branding behavior and cannot be disabled through `CreateWindow` config. Wait for `DXForge.Config.StartupDuration`.

## Logo Does Not Render

Some DX9 environments do not expose `dx9.DrawImage`; the official DX9WARE drawing docs list line/string/circle/box drawing, but not image drawing. DXForge tries local and cached logo sources first, then falls back to an embedded 160x160 logo raster rendered with `dx9.DrawFilledBox`. Text branding is only used if even that primitive-rendered raster cannot be drawn.

## Startup Feels Heavy

The embedded logo fallback is only used during startup. After the intro completes, DXForge releases the startup logo runtime state and cached embedded logo runs. If the UI still feels delayed after startup, check expensive callbacks or repeated script-side UI reconstruction.

## Clicks Hit The Wrong Window

Make sure only one DXForge instance is being rendered. DXForge blocks click-through by selecting the top hovered window each frame.

## Textbox Does Not Type Every Character

Textbox support depends on the key strings returned by `dx9.GetKey()`. Common keys and single-character keys are handled; unusual layouts may need environment-specific mapping.

## Dropdown Stays Open

Click the dropdown header again or select an item. MultiDropdown intentionally stays open so multiple values can be selected.

## Cannot Scroll Content

DX9WARE does not document a mouse-wheel API, so DXForge uses draggable scrollbars for window content and long dropdown lists. Drag the slim scrollbar on the right side of the content panel or dropdown popup.

## Theme Or Color Picker Does Not Change The UI

Use registered theme names such as `Default`, `Dark`, or a custom name created with `DXForge:CreateTheme`. Dropdowns named like `Theme` or `Select Theme` switch themes automatically. Color pickers named `Primary Color` or `Accent Color` infer theme tokens automatically; for explicit behavior use `ThemeKey = "AccentColor"` or `ApplyToTheme = true`.

## Debug Callback Errors

Enable debug output:

```lua
DXForge:SetDebug(true)
```

Callback errors are caught with `pcall`, so one broken callback should not crash the entire UI.
