# DXForgeExecute

DXForgeExecute is the Roblox Luau / Potassium-compatible successor track for DXForge. It is a single-file UI, overlay, theme, and config framework built on Roblox `ScreenGui` instances, with optional `Drawing` support only for simple visual overlays.

It is intentionally separate from the DX9 version. It does not use DX9 overlay API calls, and it does not include game automation, bypass, anti-detection, or gameplay manipulation features.

## Loading

```lua
local sourceUrl = "https://example.com/path/to/DXForgeExecute.lua"
local Library = loadstring(game:HttpGet(sourceUrl))()
```

Replace `sourceUrl` with the actual URL where you host `DXForgeExecute.lua`. For local development, execute `DXForgeExecute.lua` through your Roblox/Potassium script workflow and use the returned table as `Library`.

## Window

```lua
local Window = Library:CreateWindow({
    Title = "DXForgeExecute Example",
    Size = {680, 560},
    MinSize = {520, 380},
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "DarkTech",
    Resizable = true,
    CompactMode = false,
    Startup = true
})
```

Useful window methods:

```lua
Window:SetOpen(true)
Window:Toggle()
Window:BringToFront()
Window:Resize(620, 520)
Window:SetSize({680, 560})
Window:SetPosition({24, 24})
Window:Destroy()
```

Responsive state:

```lua
print(Window.IsCompact)
print(Window.IsStacked)
```

`IsCompact` becomes true for compact windows or windows at `<= 560px` width. `IsStacked` becomes true for compact windows or windows at `<= 640px` width, stacking left/right group columns vertically.

## Controls

```lua
local Main = Window:AddTab("Main")
local Left = Main:AddGroupbox("Controls", "left")
local Right = Main:AddGroupbox("Inputs", "right")
local Full = Main:AddSection("Status", "full")

local Toggle = Left:AddToggle({
    Text = "Enabled",
    Flag = "enabled",
    Default = true,
    Tooltip = "Example boolean setting.",
    Callback = function(value)
        print("Enabled:", value)
    end
})

local Slider = Left:AddSlider({
    Text = "Strength",
    Flag = "strength",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 1,
    Suffix = "%",
    Callback = function(value)
        print("Strength:", value)
    end
})

local Dropdown = Left:AddDropdown({
    Text = "Mode",
    Flag = "mode",
    Values = {"Default", "Focused", "Custom"},
    Default = "Default",
    Search = true
})

local Multi = Left:AddMultiDropdown({
    Text = "Channels",
    Flag = "channels",
    Values = {"Info", "Warnings", "Errors"},
    Default = {"Info", "Warnings"}
})

local Textbox = Right:AddTextbox({
    Text = "Profile",
    Flag = "profile",
    Placeholder = "name",
    Default = "default",
    ClearButton = true
})

local Numeric = Right:AddTextbox({
    Text = "Limit",
    Flag = "limit",
    Default = "25",
    NumericOnly = true
})

local Keybind = Right:AddKeybind({
    Text = "Action",
    Flag = "action_key",
    Default = Enum.KeyCode.K,
    Mode = "Toggle"
})

local Color = Right:AddColorPicker({
    Text = "Accent",
    Flag = "accent",
    Default = {118, 180, 255, 1},
    Alpha = true,
    ThemeKey = "Accent"
})

local Label = Full:AddLabel({
    Text = "Ready",
    Flag = "status_label"
})

local Paragraph = Full:AddParagraph({
    Text = "Notes",
    Flag = "notes",
    Content = "Multiline status text can live here."
})

Full:AddDivider("Actions")

Left:AddButton({
    Text = "Notify",
    Debounce = 0.5,
    Callback = function()
        Library:Notify({
            Text = "Button pressed.",
            Type = "Success",
            Duration = 3
        })
    end
})
```

Every public control supports:

```lua
control:SetValue(value, silent)
local value = control:GetValue()
control:SetVisible(true)
control:Destroy()
```

Some controls expose extra methods such as `Dropdown:Refresh(values, default)` and `Keybind:SetKey(key, silent)`.

## Themes

Built-in themes currently include `DarkTech`, `Graphite`, and `Obsidian`.

```lua
Library:RegisterTheme("Terminal", {
    Background = {7, 10, 9},
    Surface = {15, 21, 19},
    SurfaceLight = {24, 34, 31},
    SurfaceDark = {8, 12, 11},
    Accent = {75, 214, 137},
    AccentSoft = {38, 86, 61},
    Border = {44, 64, 57},
    BorderStrong = {82, 126, 108},
    Text = {235, 245, 240},
    TextMuted = {145, 168, 158},
    Success = {75, 214, 137},
    Warning = {247, 190, 82},
    Error = {241, 89, 97},
    Shadow = {0, 0, 0}
})

Library:SetTheme("Terminal")
Library:SetThemeColor("Accent", Color3.fromRGB(118, 180, 255))
```

Theme token names:

```text
Background, Surface, SurfaceLight, SurfaceDark, Accent, AccentSoft,
Border, BorderStrong, Text, TextMuted, Success, Warning, Error, Shadow
```

## Configs

Configs use optional executor file APIs when available. The library degrades gracefully when file APIs are missing.

```lua
Library:SetConfigFolder("DXForgeExecute")

Library:SaveConfig("default.json")
Library:LoadConfig("default.json")
Library:DeleteConfig("old.json")

for _, fileName in ipairs(Library:ListConfigs()) do
    print(fileName)
end
```

Autosave:

```lua
Library:EnableAutoSave({
    File = "default.json",
    Interval = 10
})

Library:DisableAutoSave()
```

Saved config data includes version, save timestamp, active theme, flagged control values, window positions/sizes/open state, selected tab, and autosave metadata when enabled.

Optional file APIs used defensively:

```text
writefile, readfile, isfile, isfolder, makefolder, delfile, listfiles
```

## Notifications And Overlays

```lua
Library:Notify({
    Text = "DXForgeExecute loaded.",
    Type = "Success",
    Duration = 4
})

Library:SetWatermark({
    Text = "DXForgeExecute",
    Visible = true,
    Position = {14, 14},
    Draggable = true
})

Library:SetFOVCircle({
    Visible = true,
    Radius = 120,
    Color = {118, 180, 255},
    Thickness = 1,
    Segments = 96,
    FollowMouse = true
})
```

The FOV circle is only a visual overlay component. It does not implement aiming, targeting, automation, or gameplay behavior.

## Smoke Harness

The smoke harness at `tests/DXForgeExecute_SMOKE.lua` creates each supported control, exercises common public methods, touches theme/config/autosave APIs, and checks responsive layout flags.

It still needs to be executed in a real Roblox/Potassium runtime.
