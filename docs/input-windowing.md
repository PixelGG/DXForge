<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=105&section=header&color=0:090A0F,45:B254FF,100:161821&text=Input%20%26%20Windowing&fontColor=F3EEFF&fontSize=31&fontAlignY=38&animation=fadeIn&desc=Focus%2C%20z-index%2C%20dragging%2C%20resizing%20and%20clipping&descAlignY=64&descSize=13" alt="Input and Windowing" width="100%" />
</p>

[Back to docs](README.md)

## Central Input State

DXForge reads mouse and key state once per render call:

```lua
DXForge:Render()
```

That keeps controls from fighting over the same click or key state.

## Click Ownership

DXForge resolves the top hovered window before rendering controls. Only that window processes interaction for the frame, which prevents most click-through issues.

## Dragging And Resizing

Windows can be dragged by the header and resized when `Resizable = true`:

```lua
local Window = DXForge:CreateWindow({
    Title = "Resizable",
    Resizable = true,
    MinSize = {420, 320}
})
```

## Toggle Keys

Set `ToggleKey` on the window config:

```lua
local Window = DXForge:CreateWindow({
    Title = "Menu",
    ToggleKey = "[F6]"
})
```

When `DXForge:Render()` sees that key, the window toggles open or closed.

## Scrolling

DXForge uses draggable scrollbars instead of mouse-wheel input.

- window content gets a right-side scrollbar when needed
- long dropdown lists get their own popup scrollbar
- clipped controls do not receive hover or click input

## Focus Rules

- clicking a window brings it to front
- child controls can still consume that same click
- dragging and resizing continue while the mouse is held
- popups, dropdowns, and color pickers claim input while active
- textboxes hold focus until commit, clear, or escape-style exit
