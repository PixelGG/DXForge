<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Themes&fontColor=F3EEFF&fontSize=34&fontAlignY=38&animation=fadeIn&desc=Tokens%2C%20runtime%20editing%2C%20and%20persistence&descAlignY=64&descSize=13" alt="Themes" width="100%" />
</p>

[Back to docs](README.md)

## Default Theme Tokens

| Token | Purpose |
| --- | --- |
| `FontColor` | Main readable text |
| `MainColor` | Window and top-level surface |
| `BackgroundColor` | Inner panels and content areas |
| `AccentColor` | Active highlight color |
| `OutlineColor` | Borders and separators |
| `ShadowColor` | Shadow layers |
| `SuccessColor` | Success notification accent |
| `WarningColor` | Warning accent |
| `ErrorColor` | Error accent |
| `DisabledColor` | Disabled / unavailable state |
| `HoverColor` | Hovered surfaces |
| `PanelColor` | Control backgrounds |
| `TextMutedColor` | Secondary text |
| `GlowColor` | Accent glow |
| `WindowColor` | Outer window fill |
| `HeaderColor` | Header surface |
| `HeaderDarkColor` | Dark header / footer surface |
| `SurfaceColor` | Elevated component surface |
| `SurfaceLightColor` | Top highlight lines |
| `SurfaceDarkColor` | Recessed surfaces |
| `BorderSoftColor` | Subtle rails and separators |
| `BorderStrongColor` | High-emphasis outer borders |
| `AccentSoftColor` | Soft accent glow |
| `AccentDimColor` | Muted accent rail |
| `ActiveColor` | Active control fill |
| `TextHeaderColor` | Strong header text |

## Register A Theme

```lua
DXForge:CreateTheme("VioletSteel", {
    Base = "Dark",
    FontColor = {238, 238, 246},
    MainColor = {18, 19, 24},
    BackgroundColor = {8, 9, 13},
    AccentColor = {178, 84, 255},
    OutlineColor = {58, 60, 72},
    PanelColor = {25, 26, 34},
    TextMutedColor = {150, 152, 166},
    GlowColor = {145, 60, 255}
})

DXForge:SetTheme("VioletSteel")
```

## Runtime Theme Editing

```lua
DXForge:SetThemeColor("AccentColor", {210, 92, 255})

DXForge:UpdateTheme("VioletSteel", {
    PanelColor = {22, 23, 30},
    OutlineColor = {66, 69, 84}
})
```

## Automatic Theme Controls

Dropdowns named like `Theme` or `Select Theme` can switch themes automatically:

```lua
Menu:AddDropdown({
    Text = "Select Theme",
    Values = DXForge:GetThemeNames(),
    Default = "Dark"
})
```

Color pickers named like `Primary Color` and `Accent Color` can infer matching theme tokens automatically:

```lua
Menu:AddColorPicker({Text = "Primary Color"})
Menu:AddColorPicker({Text = "Accent Color"})
```

For exact behavior, use `ThemeKey`:

```lua
Menu:AddColorPicker({
    Text = "Glow",
    ThemeKey = "GlowColor"
})
```

## Theme Persistence

DXForge `1.1.3` persists:

- active theme name
- runtime-edited theme colors
- theme changes from `SetThemeColor`
- theme changes from color pickers that apply to the theme

This means custom in-menu theme editing survives config save/load automatically.
