<p align="center">
  <img src="../assets/DXForgeSingle.png" alt="DXForge logo" width="96" />
</p>

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=rect&height=92&color=0:090A0F,100:14151C&text=Getting%20Started&fontColor=F2EEFF&fontSize=30&animation=fadeIn&desc=Install%2C%20create%20a%20window%2C%20render%20the%20UI&descSize=13&descAlignY=70" alt="Getting Started" width="100%" />
</p>

[Back to docs](README.md)

## Install

```lua
local DXForge = loadstring(game:HttpGet("https://raw.githubusercontent.com/PixelGG/DXForge/main/DXForge.lua"))()
```

For local testing, load `DXForge.lua` through your DX9 Lua environment.

## Create Your First Window

```lua
local Window = DXForge:CreateWindow({
    Title = "DXForge Menu",
    Size = {600, 500},
    ToggleKey = "[INSERT]",
    Resizable = true
})
```

## Add A Tab And Section

```lua
local MainTab = Window:AddTab("Main")
local MainBox = MainTab:AddGroupbox("General", "left")
```

Groupbox sides:

| Side | Behavior |
| --- | --- |
| `left` | Left column |
| `right` | Right column |
| `full` | Full-width section |
| `middle` | Alias for `full` |

## Add Controls

```lua
MainBox:AddButton({
    Text = "Run Action",
    Callback = function()
        print("Clicked")
    end
})

MainBox:AddToggle({
    Text = "Enabled",
    Default = true,
    Callback = function(value)
        print("Enabled:", value)
    end
})
```

## Render Loop

DXForge does not install hidden global hooks. Call the render method once per DX9 frame/script tick:

```lua
DXForge:Render()
```

If your environment runs the script repeatedly every frame, place UI creation behind your loader setup and call only `DXForge:Render()` in the repeated path.

## Minimal Complete Example

```lua
local DXForge = loadstring(game:HttpGet("https://raw.githubusercontent.com/PixelGG/DXForge/main/DXForge.lua"))()

local Window = DXForge:CreateWindow({
    Title = "DXForge Starter",
    Size = {560, 420},
    ToggleKey = "[INSERT]"
})

local Tab = Window:AddTab("Main")
local Box = Tab:AddGroupbox("Controls", "left")

Box:AddLabel({Text = "Welcome to DXForge"})
Box:AddButton({
    Text = "Send Notification",
    Callback = function()
        DXForge:Notify({
            Text = "Hello from DXForge.",
            Type = "Info",
            Duration = 3
        })
    end
})

DXForge:Render()
```
