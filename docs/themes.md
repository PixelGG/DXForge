<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=Themes&fontColor=F2EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Color%20tokens%20and%20custom%20visual%20identity&descAlignY=64&descSize=13" alt="Themes" width="100%" />
</p>

[Back to docs](README.md)

## Default Theme Tokens

| Token | Purpose |
| --- | --- |
| `FontColor` | Main readable text. |
| `MainColor` | Window and top-level surface. |
| `BackgroundColor` | Inner panels and content areas. |
| `AccentColor` | Purple neon highlights and active states. |
| `OutlineColor` | Borders and separators. |
| `ShadowColor` | Shadow layers. |
| `SuccessColor` | Success notification accents. |
| `WarningColor` | Warning notification accents. |
| `ErrorColor` | Error notification accents. |
| `DisabledColor` | Disabled or unavailable states. |
| `HoverColor` | Hovered surfaces. |
| `PanelColor` | Control backgrounds. |
| `TextMutedColor` | Secondary text. |
| `GlowColor` | Startup and energy highlights. |
| `WindowColor` | Outer window fill. |
| `HeaderColor` | Premium header surface. |
| `HeaderDarkColor` | Dark header and footer surface. |
| `SurfaceColor` | Elevated component surface. |
| `SurfaceLightColor` | Top highlight lines. |
| `SurfaceDarkColor` | Recessed surfaces. |
| `BorderSoftColor` | Subtle rails and separators. |
| `BorderStrongColor` | High-emphasis outer borders. |
| `AccentSoftColor` | Soft accent glow. |
| `AccentDimColor` | Muted accent rails. |
| `ActiveColor` | Active control fill. |
| `TextHeaderColor` | High-emphasis header text. |

## Register A Theme

```lua
DXForge:CreateTheme("VioletSteel", {
    Base = "Dark",
    FontColor = {238, 238, 246},
    MainColor = {18, 19, 24},
    BackgroundColor = {8, 9, 13},
    AccentColor = {178, 84, 255},
    OutlineColor = {58, 60, 72},
    ShadowColor = {0, 0, 0},
    SuccessColor = {75, 220, 145},
    WarningColor = {255, 188, 82},
    ErrorColor = {255, 94, 118},
    DisabledColor = {92, 94, 105},
    HoverColor = {35, 36, 45},
    PanelColor = {25, 26, 34},
    TextMutedColor = {150, 152, 166},
    GlowColor = {145, 60, 255},
    WindowColor = {10, 11, 16},
    HeaderColor = {24, 26, 36},
    HeaderDarkColor = {14, 15, 21},
    SurfaceColor = {18, 20, 28},
    SurfaceLightColor = {31, 34, 45},
    SurfaceDarkColor = {9, 10, 15},
    BorderSoftColor = {37, 40, 52},
    BorderStrongColor = {78, 82, 100},
    AccentSoftColor = {86, 45, 135},
    AccentDimColor = {43, 28, 64},
    ActiveColor = {39, 27, 55},
    TextHeaderColor = {255, 255, 255}
})

DXForge:SetTheme("VioletSteel")
```

`CreateTheme` and `RegisterTheme` accept partial token tables. Missing values are inherited from `Default` or from `Base` / `Extends`.

```lua
DXForge:CreateTheme("Ocean", {
    Base = "Dark",
    AccentColor = {80, 180, 255},
    GlowColor = {90, 210, 255}
})

DXForge:SetThemeColor("AccentColor", {210, 92, 255})

local themes = DXForge:GetThemeNames()
```

## Per-Window Theme

```lua
local Window = DXForge:CreateWindow({
    Title = "Themed Window",
    Theme = "VioletSteel"
})
```

## Styling Guidance

Keep the main surfaces dark, outlines visible, and accent color reserved for active states. DXForge looks best when the accent is special, not everywhere.
