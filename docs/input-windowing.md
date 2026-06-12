<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:14151C&text=Input%20%26%20Windowing&fontColor=F2EEFF&fontSize=31&fontAlignY=38&animation=fadeIn&desc=Focus%2C%20z-index%2C%20dragging%2C%20resizing%20and%20click%20blocking&descAlignY=64&descSize=13" alt="Input and Windowing" width="100%" />
</p>

[Back to docs](README.md)

## Central Input State

DXForge reads mouse and key state once per render call:

```lua
DXForge:Render()
```

This keeps components from fighting over clicks.

## Click Blocking

DXForge resolves the top hovered window before rendering controls. Only that window can process interaction for the frame, which helps prevent click-through bugs with overlapping windows.

## Dragging

Windows can be dragged by the header area.

```lua
local Window = DXForge:CreateWindow({
    Title = "Draggable",
    Size = {600, 500}
})
```

## Resizing

Enable resizing with:

```lua
local Window = DXForge:CreateWindow({
    Title = "Resizable",
    Resizable = true,
    MinSize = {420, 320}
})
```

Resize from code with:

```lua
Window:Resize(720, 540)
Window:SetSize({640, 480})
Window:SetMinSize({420, 320})
```

## Clipping

DXForge clips rendering and hitboxes through nested container bounds:

- Window bounds clip tabs, content, footer, and resize visuals.
- Content bounds clip tab groupboxes and controls.
- Groupbox bounds clip section controls.
- Controls that are clipped out do not receive hover, click, textbox, dropdown, color picker, or keybind input.

## Toggle Key

```lua
local Window = DXForge:CreateWindow({
    Title = "Menu",
    ToggleKey = "[INSERT]"
})
```

## Focus Rules

- Clicking a window brings it to front.
- Child controls can still receive the same click.
- Dragging and resizing continue even if the mouse leaves the window.
- Popups, dropdowns, and color pickers claim input while open.
