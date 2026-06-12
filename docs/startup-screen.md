<p align="center">
  <img src="../assets/DXForgeSingle.png" alt="DXForge logo" width="104" />
</p>

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=Startup%20Screen&fontColor=F2EEFF&fontSize=32&fontAlignY=38&animation=fadeIn&desc=Logo%2C%20loading%20motion%2C%20progress%20and%20PixelGG%20signature&descAlignY=64&descSize=13" alt="Startup Screen" width="100%" />
</p>

[Back to docs](README.md)

## Mandatory Startup

```lua
local Window = DXForge:CreateWindow({
    Title = "DXForge"
})
```

DXForge always runs its branded startup screen once when the first window is created. This is part of the library identity and is not controlled by user config.

`Startup = false` is ignored intentionally.

## What It Renders

- Centered premium panel only, without a fullscreen black backdrop
- Local `DXForge.png` logo image inside the loading panel when supported by the DX9 environment
- Embedded raster logo fallback rendered with `dx9.DrawFilledBox` when image APIs are unavailable
- Controlled logo loading state before the UI continues
- Premium text fallback when image rendering is unavailable
- Animated sweep lines
- Progress indicator
- Loading messages
- `PixelGG` signature

## Logo Source

The library tries these logo sources:

```text
DXForge.png
./DXForge.png
DXForgeLogoCache.png
assets/DXForgeSingle.png
assets/DXForgeBanner.png
https://raw.githubusercontent.com/PixelGG/DXForge/main/DXForge.png
```

Keep `DXForge.png` next to `DXForge.lua` for the intended startup logo. DXForge tests whether the source can actually be rendered before treating it as loaded.

If the runtime does not support image rendering, DXForge falls back to an embedded 32x32 logo raster drawn with standard DX9 filled boxes. Text branding is only the final fallback if even the embedded raster path cannot render.

## Duration

```lua
DXForge.Config.StartupDuration = 3.15
```

This value controls the branded intro duration. The startup itself remains mandatory.
