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

Some DX9 environments do not expose `dx9.DrawImage`; the official DX9WARE drawing docs list line/string/circle/box drawing, but not image drawing. DXForge tries local and fallback logo sources first, then falls back to text branding automatically.

## Clicks Hit The Wrong Window

Make sure only one DXForge instance is being rendered. DXForge blocks click-through by selecting the top hovered window each frame.

## Textbox Does Not Type Every Character

Textbox support depends on the key strings returned by `dx9.GetKey()`. Common keys and single-character keys are handled; unusual layouts may need environment-specific mapping.

## Dropdown Stays Open

Click the dropdown header again or select an item. MultiDropdown intentionally stays open so multiple values can be selected.

## Debug Callback Errors

Enable debug output:

```lua
DXForge:SetDebug(true)
```

Callback errors are caught with `pcall`, so one broken callback should not crash the entire UI.
