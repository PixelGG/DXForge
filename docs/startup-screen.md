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

- Dark full-screen intro backdrop
- Centered premium panel
- DXForge logo image when supported by the DX9 environment
- Text fallback when image rendering is unavailable
- Animated sweep lines
- Progress indicator
- Loading messages
- `PixelGG` signature

## Logo Source

The library references:

```text
https://raw.githubusercontent.com/PixelGG/DXForge/main/DXForge.png
```

If `dx9.DrawImage` or remote asset loading is not available, DXForge gracefully falls back to text branding.

## Duration

```lua
DXForge.Config.StartupDuration = 3.15
```

This value controls the branded intro duration. The startup itself remains mandatory.
