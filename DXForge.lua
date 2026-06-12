--[[
    DXForge - Modern DX9 Lua UI Library

    A structured DX9 overlay UI framework with windows, tabs, sections,
    common controls, theme support, animations, notifications, tooltips,
    watermark rendering, and a polished startup screen.

    Recommended usage:

        local DXForge = _G.DXForge or loadstring(dx9.Get(".../DXForge.lua"))()

        local Window = DXForge:CreateWindow({
            Title = "DXForge Example",
            Size = {600, 500},
            ToggleKey = "[INSERT]"
        })

        local Tab = Window:AddTab("Main")
        local Box = Tab:AddGroupbox("Combat", "left")

        Box:AddToggle({
            Text = "Enable Feature",
            Default = false,
            Callback = function(value)
                print("Toggle:", value)
            end
        })

        -- Call once per DX9 frame/script tick after the UI has been created.
        DXForge:Render()
]]

local DXForge = _G.DXForge
if DXForge and DXForge.__DXFORGE_VERSION == "1.0.1" then
    return DXForge
end

---@alias DXForgeColor table<number, number> RGB color table in the form `{r, g, b}` or `{r, g, b, a}`.
---@alias DXForgeVector2 table<number, number> Position or size table in the form `{x, y}`.
---@alias DXForgeSide '"left"'|'"right"'|'"full"'|'"middle"'
---@alias DXForgeNotificationType '"Info"'|'"Success"'|'"Warning"'|'"Error"'
---@alias DXForgeKeyMode '"Toggle"'|'"Hold"'

---@class DXForgeTheme
---@field FontColor DXForgeColor Main readable text color.
---@field MainColor DXForgeColor Primary window surface color.
---@field BackgroundColor DXForgeColor Inner content background color.
---@field AccentColor DXForgeColor Active neon/accent color.
---@field OutlineColor DXForgeColor Border and separator color.
---@field ShadowColor DXForgeColor Shadow color.
---@field SuccessColor DXForgeColor Success notification color.
---@field WarningColor DXForgeColor Warning notification color.
---@field ErrorColor DXForgeColor Error notification color.
---@field DisabledColor DXForgeColor Disabled state color.
---@field HoverColor DXForgeColor Hover surface color.
---@field PanelColor DXForgeColor Control panel color.
---@field TextMutedColor DXForgeColor Secondary text color.
---@field GlowColor DXForgeColor Startup glow/accent color.

---@class DXForgeWindowConfig
---@field Title string|nil Window title.
---@field Size DXForgeVector2|nil Window size in pixels.
---@field Position DXForgeVector2|nil Window position in pixels.
---@field StartLocation DXForgeVector2|nil Legacy alias for `Position`.
---@field MinSize DXForgeVector2|nil Minimum size when resizing.
---@field ToggleKey string|nil DX9 key string used to toggle the window.
---@field Resizable boolean|nil Enables bottom-right resizing.
---@field Footer boolean|nil Shows or hides the footer.
---@field Theme string|nil Theme name.
---@field Startup boolean|nil Deprecated/ignored. DXForge always runs its branded startup screen once.
---@field Open boolean|nil Initial open state.

---@class DXForgeBaseComponentConfig
---@field Text string|number|nil Visible label text.
---@field Name string|number|nil Alternative label text.
---@field Tooltip string|nil Tooltip shown on hover.
---@field Callback function|nil Callback invoked by the component.
---@field Height number|nil Optional custom row height.
---@field Visible boolean|nil Initial visibility.

---@class DXForgeButtonConfig: DXForgeBaseComponentConfig

---@class DXForgeToggleConfig: DXForgeBaseComponentConfig
---@field Default boolean|nil Initial toggle value.
---@field Keybind string|nil Optional key that toggles the value.

---@class DXForgeSliderConfig: DXForgeBaseComponentConfig
---@field Min number|nil Minimum value.
---@field Max number|nil Maximum value.
---@field Default number|nil Initial value.
---@field Step number|nil Step size.

---@class DXForgeDropdownConfig: DXForgeBaseComponentConfig
---@field Values table List of selectable values.
---@field Default any Initial selected value.

---@class DXForgeMultiDropdownConfig: DXForgeBaseComponentConfig
---@field Values table List of selectable values.
---@field Default table|nil Initial selected values.

---@class DXForgeTextboxConfig: DXForgeBaseComponentConfig
---@field Placeholder string|nil Placeholder text.
---@field Default string|nil Initial text value.
---@field ClearButton boolean|nil Reserved for clear button behavior.

---@class DXForgeKeybindConfig: DXForgeBaseComponentConfig
---@field Default string|nil Initial DX9 key string.
---@field Mode DXForgeKeyMode|nil Keybind behavior mode.

---@class DXForgeColorPickerConfig: DXForgeBaseComponentConfig
---@field Default DXForgeColor|nil Initial color.
---@field Alpha boolean|nil Enables alpha-aware color storage.

---@class DXForgeNotificationConfig
---@field Text string Notification text. Supports newline characters.
---@field Duration number|nil Lifetime in seconds.
---@field Length number|nil Legacy alias for `Duration`.
---@field Type DXForgeNotificationType|nil Notification accent type.
---@field ManualClose boolean|nil Reserved for manual close behavior.

---@class DXForgeWatermarkConfig
---@field Text string|nil Watermark text.
---@field Visible boolean|nil Watermark visibility.
---@field Position DXForgeVector2|nil Watermark position.

---@class DXForge
---@field __DXFORGE_VERSION string
---@field Name string
---@field Author string
---@field Signature string
---@field Debug boolean
---@field Config table
---@field Themes table<string, DXForgeTheme>

DXForge = {
    __DXFORGE_VERSION = "1.0.1",
    Name = "DXForge",
    Author = "PixelGG",
    Signature = "PixelGG",
    Debug = false,
    Windows = {},
    WindowOrder = {},
    Themes = {},
    ActiveTheme = "Default",
    Notifications = {},
    TextCache = {},
    Animations = {},
    Runtime = {
        StartedAt = os.clock(),
        LastFrame = os.clock(),
        Delta = 0,
        ZCounter = 0,
        ActiveWindow = nil,
        InputWindow = nil,
        HoveredTooltip = nil,
        PopupOwner = nil,
        StartupQueued = false,
        StartupCompleted = false
    },
    Logo = {
        Source = "https://raw.githubusercontent.com/PixelGG/DXForge/main/DXForge.png",
        Asset = nil,
        TriedLoad = false
    },
    Config = {
        FontHeight = 16,
        RowHeight = 25,
        HeaderHeight = 28,
        TabHeight = 27,
        Padding = 10,
        GroupPadding = 9,
        AnimationSpeed = 14,
        StartupDuration = 3.15,
        TooltipDelay = 0.25
    }
}

--// Helpers / Utilities -------------------------------------------------------

local function clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function lerp(a, b, t)
    return a + (b - a) * clamp(t, 0, 1)
end

local function round(value, step)
    step = step or 1
    return math.floor((value / step) + 0.5) * step
end

local function copyColor(color, alpha)
    if type(color) ~= "table" then return {255, 255, 255} end
    return {color[1] or 255, color[2] or 255, color[3] or 255}
end

local function blend(a, b, t)
    return {
        math.floor(lerp(a[1] or 0, b[1] or 0, t)),
        math.floor(lerp(a[2] or 0, b[2] or 0, t)),
        math.floor(lerp(a[3] or 0, b[3] or 0, t)),
        math.floor(lerp(a[4] or 255, b[4] or 255, t))
    }
end

local function easeOutCubic(t)
    t = clamp(t, 0, 1)
    return 1 - ((1 - t) * (1 - t) * (1 - t))
end

local function easeInOut(t)
    t = clamp(t, 0, 1)
    if t < 0.5 then
        return 4 * t * t * t
    end
    return 1 - math.pow(-2 * t + 2, 3) / 2
end

local function isArray(value)
    return type(value) == "table" and value[1] ~= nil
end

local function safeCall(name, callback, ...)
    if type(callback) ~= "function" then return end
    local ok, err = pcall(callback, ...)
    if not ok and DXForge.Debug then
        print("[DXForge] Callback error in " .. tostring(name) .. ": " .. tostring(err))
    end
end

local function assertType(name, value, expected, allowNil)
    if value == nil and allowNil then return end
    assert(type(value) == expected, "[DXForge] " .. name .. " must be " .. expected .. ", got " .. type(value))
end

local function normalizeVec2(value, fallback)
    fallback = fallback or {0, 0}
    if type(value) ~= "table" then return {fallback[1], fallback[2]} end
    return {tonumber(value[1]) or fallback[1], tonumber(value[2]) or fallback[2]}
end

local function normalizeColor(value, fallback)
    fallback = fallback or {255, 255, 255}
    if type(value) ~= "table" then return copyColor(fallback) end
    return {
        clamp(tonumber(value[1]) or fallback[1], 0, 255),
        clamp(tonumber(value[2]) or fallback[2], 0, 255),
        clamp(tonumber(value[3]) or fallback[3], 0, 255),
        clamp(tonumber(value[4]) or fallback[4] or 255, 0, 255)
    }
end

local function rgbToHex(color)
    return string.format("#%02X%02X%02X", math.floor(color[1] or 0), math.floor(color[2] or 0), math.floor(color[3] or 0))
end

local function keyToChar(key)
    if type(key) ~= "string" then return nil end
    if #key == 1 then return key end
    local named = {
        ["[SPACE]"] = " ",
        ["[PERIOD]"] = ".",
        ["[COMMA]"] = ",",
        ["[MINUS]"] = "-",
        ["[PLUS]"] = "+",
        ["[SLASH]"] = "/",
        ["[BACKSLASH]"] = "\\"
    }
    if named[key] then return named[key] end
    local inner = string.match(key, "^%[([A-Z0-9])%]$")
    return inner
end

local function hsvToRgb(h, s, v)
    h = (h % 1) * 6
    local c = v * s
    local x = c * (1 - math.abs((h % 2) - 1))
    local m = v - c
    local r, g, b = 0, 0, 0

    if h < 1 then r, g, b = c, x, 0
    elseif h < 2 then r, g, b = x, c, 0
    elseif h < 3 then r, g, b = 0, c, x
    elseif h < 4 then r, g, b = 0, x, c
    elseif h < 5 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end

    return {
        math.floor((r + m) * 255),
        math.floor((g + m) * 255),
        math.floor((b + m) * 255)
    }
end

local function rgbToHsv(color)
    local r, g, b = (color[1] or 0) / 255, (color[2] or 0) / 255, (color[3] or 0) / 255
    local maxValue = math.max(r, g, b)
    local minValue = math.min(r, g, b)
    local delta = maxValue - minValue
    local h = 0

    if delta ~= 0 then
        if maxValue == r then
            h = ((g - b) / delta) % 6
        elseif maxValue == g then
            h = ((b - r) / delta) + 2
        else
            h = ((r - g) / delta) + 4
        end
        h = h / 6
    end

    local s = maxValue == 0 and 0 or delta / maxValue
    return h, s, maxValue
end

local function splitLines(text)
    text = tostring(text or "")
    local lines = {}
    for line in string.gmatch(text .. "\n", "([^\n]*)\n") do
        table.insert(lines, line)
    end
    if #lines == 0 then lines[1] = text end
    return lines
end

--// Theme System --------------------------------------------------------------

DXForge.Themes.Default = {
    FontColor = {235, 236, 244},
    MainColor = {19, 20, 25},
    BackgroundColor = {10, 11, 15},
    AccentColor = {178, 84, 255},
    OutlineColor = {52, 54, 65},
    ShadowColor = {0, 0, 0},
    SuccessColor = {75, 220, 145},
    WarningColor = {255, 188, 82},
    ErrorColor = {255, 94, 118},
    DisabledColor = {92, 94, 105},
    HoverColor = {35, 36, 45},
    PanelColor = {24, 25, 32},
    TextMutedColor = {145, 147, 160},
    GlowColor = {145, 60, 255}
}

--[[
    Registers a reusable DXForge theme.

    @param name string
        Unique theme name used by DXForge:SetTheme or CreateWindow({Theme = name}).
    @param values table
        Partial or complete theme token table. Missing values fall back to Default.
    @return table
        Returns the DXForge instance for chaining.
]]
---@param name string
---@param values table<string, DXForgeColor>
---@return DXForge
function DXForge:RegisterTheme(name, values)
    assertType("RegisterTheme.name", name, "string")
    assertType("RegisterTheme.values", values, "table")

    local base = self.Themes.Default
    local theme = {}
    for key, value in pairs(base) do
        theme[key] = copyColor(value)
    end
    for key, value in pairs(values) do
        theme[key] = normalizeColor(value, base[key])
    end

    self.Themes[name] = theme
    return self
end

--[[
    Sets the global active theme.

    @param name string
        Name of a registered theme.
    @return table
        Returns the DXForge instance for chaining.
]]
---@param name string
---@return DXForge
function DXForge:SetTheme(name)
    assert(self.Themes[name], "[DXForge] Unknown theme: " .. tostring(name))
    self.ActiveTheme = name
    return self
end

--[[
    Resolves a theme table by name.

    @param name string|nil
        Theme name. Uses the active theme when omitted.
    @return table
        Returns the resolved theme table.
]]
---@param name string|nil
---@return DXForgeTheme
function DXForge:GetTheme(name)
    return self.Themes[name or self.ActiveTheme] or self.Themes.Default
end

--// Render Utilities ----------------------------------------------------------

local Render = {}

local function dxSafeCall(fn, ...)
    if type(fn) ~= "function" then return false, nil end
    local ok, result = pcall(fn, ...)
    return ok, result
end

local function point(x, y)
    return {math.floor(tonumber(x) or 0), math.floor(tonumber(y) or 0)}
end

local function rectPoints(a, b)
    local x1 = math.floor(tonumber(a[1]) or 0)
    local y1 = math.floor(tonumber(a[2]) or 0)
    local x2 = math.floor(tonumber(b[1]) or 0)
    local y2 = math.floor(tonumber(b[2]) or 0)
    if x2 < x1 then x1, x2 = x2, x1 end
    if y2 < y1 then y1, y2 = y2, y1 end
    return {x1, y1}, {x2, y2}
end

function Render.screen()
    if dx9 and dx9.size then
        local ok, size = dxSafeCall(dx9.size)
        if ok and type(size) == "table" then
            return tonumber(size.width) or 1920, tonumber(size.height) or 1080
        end
    end
    return 1920, 1080
end

function Render.textWidth(text)
    text = tostring(text or "")
    local cached = DXForge.TextCache[text]
    if cached then return cached end
    local width = 0
    if dx9 and dx9.CalcTextWidth then
        local ok, result = dxSafeCall(dx9.CalcTextWidth, text)
        width = ok and tonumber(result) or 0
    else
        width = #text * 7
    end
    if width <= 0 then width = #text * 7 end
    DXForge.TextCache[text] = width
    return width
end

function Render.trimText(text, width)
    text = tostring(text or "")
    if Render.textWidth(text) <= width then return text end
    local suffix = "..."
    local out = text
    while #out > 0 and Render.textWidth(out .. suffix) > width do
        out = string.sub(out, 1, #out - 1)
    end
    return out .. suffix
end

function Render.filled(a, b, color)
    if dx9 and dx9.DrawFilledBox then
        local p1, p2 = rectPoints(a, b)
        dxSafeCall(dx9.DrawFilledBox, p1, p2, copyColor(color))
    end
end

function Render.box(a, b, color)
    if dx9 and dx9.DrawBox then
        local p1, p2 = rectPoints(a, b)
        dxSafeCall(dx9.DrawBox, p1, p2, copyColor(color))
    else
        Render.filled(a, {b[1], a[2] + 1}, color)
        Render.filled({a[1], b[2] - 1}, b, color)
        Render.filled(a, {a[1] + 1, b[2]}, color)
        Render.filled({b[1] - 1, a[2]}, b, color)
    end
end

function Render.line(a, b, color)
    if dx9 and dx9.DrawLine then
        dxSafeCall(dx9.DrawLine, point(a[1], a[2]), point(b[1], b[2]), copyColor(color))
    end
end

function Render.text(pos, color, text)
    if dx9 and dx9.DrawString then
        dxSafeCall(dx9.DrawString, point(pos[1], pos[2]), copyColor(color), tostring(text or ""))
    end
end

function Render.panel(x, y, w, h, theme, accent)
    Render.filled({x + 3, y + 4}, {x + w + 3, y + h + 4}, {0, 0, 0, 170})
    Render.filled({x, y}, {x + w, y + h}, theme.OutlineColor)
    Render.filled({x + 1, y + 1}, {x + w - 1, y + h - 1}, theme.MainColor)
    Render.filled({x + 2, y + 2}, {x + w - 2, y + h - 2}, theme.PanelColor)
    if accent then
        Render.filled({x + 2, y + 2}, {x + w - 2, y + 4}, theme.AccentColor)
    end
end

function Render.image(source, x, y, w, h, color)
    if not (dx9 and dx9.DrawImage) then return false end
    if not DXForge.Logo.Asset and not DXForge.Logo.TriedLoad and dx9.Get then
        DXForge.Logo.TriedLoad = true
        local ok, asset = dxSafeCall(dx9.Get, source)
        if ok then DXForge.Logo.Asset = asset end
    end
    if DXForge.Logo.Asset then
        local ok = dxSafeCall(dx9.DrawImage, DXForge.Logo.Asset, point(x, y), point(x + w, y + h), copyColor(color or {255, 255, 255}))
        return ok
    end
    return false
end

--// Input System --------------------------------------------------------------

local Input = {
    Mouse = {x = 0, y = 0},
    LastMouse = {x = 0, y = 0},
    MouseDown = false,
    LastMouseDown = false,
    ClickStarted = false,
    ClickReleased = false,
    Key = "[None]",
    LastKey = "[None]",
    KeyPressed = false,
    Claimed = false,
    ClaimId = nil,
    ActiveId = nil,
    FocusText = nil,
    Drag = nil
}

function Input:update()
    local mouse = {x = 0, y = 0}
    if dx9 and dx9.GetMouse then
        local ok, result = dxSafeCall(dx9.GetMouse)
        if ok and type(result) == "table" then
            mouse = result
        end
    end
    self.LastMouse.x, self.LastMouse.y = self.Mouse.x, self.Mouse.y
    self.Mouse.x, self.Mouse.y = mouse.x or 0, mouse.y or 0
    self.LastMouseDown = self.MouseDown
    if dx9 and dx9.isLeftClickHeld then
        local ok, result = dxSafeCall(dx9.isLeftClickHeld)
        self.MouseDown = ok and result == true
    else
        self.MouseDown = false
    end
    self.ClickStarted = self.MouseDown and not self.LastMouseDown
    self.ClickReleased = (not self.MouseDown) and self.LastMouseDown
    self.LastKey = self.Key
    if dx9 and dx9.GetKey then
        local ok, result = dxSafeCall(dx9.GetKey)
        self.Key = ok and tostring(result or "[None]") or "[None]"
    else
        self.Key = "[None]"
    end
    self.KeyPressed = self.Key ~= "[None]" and self.Key ~= "[Unknown]" and self.Key ~= self.LastKey
    self.Claimed = false
    self.ClaimId = nil
end

function Input:hover(x, y, w, h)
    local mx, my = self.Mouse.x, self.Mouse.y
    return mx >= x and my >= y and mx <= x + w and my <= y + h
end

function Input:canClaim(id)
    return not self.Claimed or self.ClaimId == id or self.ActiveId == id
end

function Input:claim(id)
    if self:canClaim(id) then
        self.Claimed = true
        self.ClaimId = id
        return true
    end
    return false
end

function Input:clicked(id, x, y, w, h)
    if self.ClickStarted and self:hover(x, y, w, h) and self:claim(id) then
        self.ActiveId = id
        return true
    end
    return false
end

function Input:release(id)
    if self.ClickReleased and self.ActiveId == id then
        self.ActiveId = nil
        return true
    end
    return false
end

DXForge.Input = Input

--// Animation System ----------------------------------------------------------

--[[
    Interpolates a named animation value toward a target.

    @param id string
        Stable animation id.
    @param target number
        Target value.
    @param speed number|nil
        Optional interpolation speed. Uses Config.AnimationSpeed when omitted.
    @return number
        Smoothed animation value.
]]
---@param id string
---@param target number
---@param speed number|nil
---@return number
function DXForge:Animate(id, target, speed)
    local current = self.Animations[id]
    if current == nil then current = target end
    local delta = self.Runtime.Delta > 0 and self.Runtime.Delta or 1 / 60
    current = lerp(current, target, 1 - math.exp(-(speed or self.Config.AnimationSpeed) * delta))
    self.Animations[id] = current
    return current
end

--[[
    Returns a looping 0..1 pulse value.

    @param speed number|nil
        Pulse speed multiplier.
    @return number
        Current pulse value between 0 and 1.
]]
---@param speed number|nil
---@return number
function DXForge:Pulse(speed)
    return (math.sin((os.clock() - self.Runtime.StartedAt) * (speed or 3)) + 1) / 2
end

--// Component Base ------------------------------------------------------------

local Component = {}
Component.__index = Component

function Component:new(kind, groupbox, config)
    config = config or {}
    local object = setmetatable({
        Kind = kind,
        Id = kind .. ":" .. tostring(math.random(100000, 999999)) .. ":" .. tostring(os.clock()),
        Groupbox = groupbox,
        Text = tostring(config.Text or config.Name or kind),
        Tooltip = config.Tooltip,
        Callback = config.Callback,
        Height = config.Height or DXForge.Config.RowHeight,
        Visible = config.Visible ~= false,
        Bounds = {0, 0, 0, 0},
        Hovered = false
    }, self)
    return object
end

--[[
    Sets or replaces the tooltip text for a component.

    @param text string
        Tooltip text. Newline characters create multiline tooltips.
    @return table
        Returns the component instance for chaining.
]]
---@param text string
---@return table
function Component:SetTooltip(text)
    self.Tooltip = text
    return self
end

--[[
    Updates component visibility.

    @param value boolean
        True to show the component, false to hide it.
    @return table
        Returns the component instance for chaining.
]]
---@param value boolean
---@return table
function Component:SetVisible(value)
    self.Visible = value == true
    return self
end

function Component:layout(x, y, w)
    self.Bounds = {x, y, w, self.Height}
    return self.Height
end

function Component:updateHover()
    local b = self.Bounds
    self.Hovered = Input:hover(b[1], b[2], b[3], b[4])
    if self.Hovered and self.Tooltip then
        DXForge.Runtime.HoveredTooltip = {Text = self.Tooltip, Since = self.TooltipSince or os.clock()}
        self.TooltipSince = self.TooltipSince or os.clock()
    else
        self.TooltipSince = nil
    end
end

--// Individual Components -----------------------------------------------------

local Label = setmetatable({}, Component)
Label.__index = Label

function Label:new(groupbox, config)
    local object = Component.new(self, "Label", groupbox, config)
    object.Height = config.Height or 20
    object.Color = config.Color
    return object
end

function Label:render(theme)
    self:updateHover()
    local b = self.Bounds
    Render.text({b[1], b[2] + 2}, self.Color or theme.FontColor, Render.trimText(self.Text, b[3] - 4))
end

local Divider = setmetatable({}, Component)
Divider.__index = Divider

function Divider:new(groupbox, config)
    local object = Component.new(self, "Divider", groupbox, config)
    object.Height = 16
    return object
end

function Divider:render(theme)
    local b = self.Bounds
    local mid = b[2] + 8
    Render.line({b[1], mid}, {b[1] + b[3], mid}, theme.OutlineColor)
    if self.Text ~= "Divider" and self.Text ~= "" then
        local tw = Render.textWidth(self.Text)
        Render.filled({b[1] + 8, mid - 8}, {b[1] + 16 + tw, mid + 8}, theme.BackgroundColor)
        Render.text({b[1] + 12, mid - 8}, theme.TextMutedColor, self.Text)
    end
end

local Button = setmetatable({}, Component)
Button.__index = Button

function Button:new(groupbox, config)
    local object = Component.new(self, "Button", groupbox, config)
    object.Height = config.Height or 28
    return object
end

function Button:render(theme)
    self:updateHover()
    local b = self.Bounds
    local pressed = Input.ActiveId == self.Id
    if Input:clicked(self.Id, b[1], b[2], b[3], b[4]) then
        safeCall("Button:" .. self.Text, self.Callback)
    end
    Input:release(self.Id)

    local hover = DXForge:Animate(self.Id .. ":hover", self.Hovered and 1 or 0, 16)
    local fill = blend(theme.PanelColor, theme.HoverColor, hover)
    if pressed then fill = blend(fill, theme.AccentColor, 0.22) end
    Render.filled({b[1], b[2]}, {b[1] + b[3], b[2] + b[4]}, theme.OutlineColor)
    Render.filled({b[1] + 1, b[2] + 1}, {b[1] + b[3] - 1, b[2] + b[4] - 1}, fill)
    Render.text({b[1] + 8, b[2] + 6}, theme.FontColor, Render.trimText(self.Text, b[3] - 16))
end

local Toggle = setmetatable({}, Component)
Toggle.__index = Toggle

function Toggle:new(groupbox, config)
    local object = Component.new(self, "Toggle", groupbox, config)
    object.Value = config.Default == true
    object.Keybind = config.Keybind
    return object
end

--[[
    Updates a toggle value.

    @param value boolean
        New boolean state.
    @param silent boolean|nil
        When true, the callback is not invoked.
    @return table
        Returns the toggle instance.
]]
---@param value boolean
---@param silent boolean|nil
---@return table
function Toggle:SetValue(value, silent)
    value = value == true
    if self.Value ~= value then
        self.Value = value
        if not silent then safeCall("Toggle:" .. self.Text, self.Callback, self.Value) end
    end
    return self
end

function Toggle:render(theme)
    self:updateHover()
    local b = self.Bounds

    if Input:clicked(self.Id, b[1], b[2], b[3], b[4]) then
        self:SetValue(not self.Value)
    end
    Input:release(self.Id)

    if self.Keybind and Input.KeyPressed and Input.Key == self.Keybind then
        self:SetValue(not self.Value)
    end

    local t = DXForge:Animate(self.Id .. ":value", self.Value and 1 or 0, 18)
    local hover = DXForge:Animate(self.Id .. ":hover", self.Hovered and 1 or 0, 15)
    Render.text({b[1], b[2] + 5}, self.Value and theme.FontColor or theme.TextMutedColor, Render.trimText(self.Text, b[3] - 56))

    local sx, sy, sw, sh = b[1] + b[3] - 42, b[2] + 6, 36, 15
    Render.filled({sx, sy}, {sx + sw, sy + sh}, theme.OutlineColor)
    Render.filled({sx + 1, sy + 1}, {sx + sw - 1, sy + sh - 1}, blend(theme.BackgroundColor, theme.HoverColor, hover))
    Render.filled({sx + 2, sy + 2}, {sx + 2 + (sw - 4) * t, sy + sh - 2}, theme.AccentColor)
    local knob = sx + 3 + (sw - 13) * t
    Render.filled({knob, sy + 3}, {knob + 9, sy + sh - 3}, theme.FontColor)
end

local Slider = setmetatable({}, Component)
Slider.__index = Slider

function Slider:new(groupbox, config)
    local object = Component.new(self, "Slider", groupbox, config)
    object.Min = tonumber(config.Min) or 0
    object.Max = tonumber(config.Max) or 100
    object.Step = tonumber(config.Step) or 1
    object.Value = clamp(tonumber(config.Default) or object.Min, object.Min, object.Max)
    object.DisplayValue = object.Value
    object.Height = config.Height or 38
    return object
end

--[[
    Updates a slider value and clamps it to Min/Max.

    @param value number
        New numeric value.
    @param silent boolean|nil
        When true, the callback is not invoked.
    @return table
        Returns the slider instance.
]]
---@param value number
---@param silent boolean|nil
---@return table
function Slider:SetValue(value, silent)
    local nextValue = clamp(round(tonumber(value) or self.Min, self.Step), self.Min, self.Max)
    if self.Value ~= nextValue then
        self.Value = nextValue
        if not silent then safeCall("Slider:" .. self.Text, self.Callback, self.Value) end
    end
    return self
end

function Slider:render(theme)
    self:updateHover()
    local b = self.Bounds
    local label = self.Text .. ": " .. tostring(self.Value)
    Render.text({b[1], b[2] + 2}, theme.FontColor, Render.trimText(label, b[3]))

    local bx, by, bw, bh = b[1], b[2] + 22, b[3], 8
    if Input:clicked(self.Id, bx, by - 5, bw, bh + 10) or Input.ActiveId == self.Id then
        if Input.MouseDown then
            Input:claim(self.Id)
            local pct = clamp((Input.Mouse.x - bx) / bw, 0, 1)
            self:SetValue(self.Min + (self.Max - self.Min) * pct)
        end
    end
    Input:release(self.Id)

    self.DisplayValue = lerp(self.DisplayValue, self.Value, 1 - math.exp(-18 * DXForge.Runtime.Delta))
    local pct = (self.DisplayValue - self.Min) / (self.Max - self.Min)
    Render.filled({bx, by}, {bx + bw, by + bh}, theme.OutlineColor)
    Render.filled({bx + 1, by + 1}, {bx + bw - 1, by + bh - 1}, theme.BackgroundColor)
    Render.filled({bx + 1, by + 1}, {bx + 1 + (bw - 2) * pct, by + bh - 1}, theme.AccentColor)
    local knob = bx + bw * pct
    Render.filled({knob - 2, by - 3}, {knob + 2, by + bh + 3}, theme.FontColor)
end

local Dropdown = setmetatable({}, Component)
Dropdown.__index = Dropdown

function Dropdown:new(groupbox, config, multi)
    local object = Component.new(self, multi and "MultiDropdown" or "Dropdown", groupbox, config)
    object.Values = type(config.Values) == "table" and config.Values or {}
    object.Multi = multi == true
    object.Open = false
    object.Height = 30
    object.Selected = object.Multi and {} or (config.Default or object.Values[1])
    if object.Multi and type(config.Default) == "table" then
        for _, value in pairs(config.Default) do object.Selected[value] = true end
    end
    return object
end

function Dropdown:displayText()
    if not self.Multi then return tostring(self.Selected or "") end
    local out = {}
    for _, value in ipairs(self.Values) do
        if self.Selected[value] then table.insert(out, tostring(value)) end
    end
    if #out == 0 then return "None" end
    return table.concat(out, ", ")
end

function Dropdown:setSelected(value)
    if self.Multi then
        self.Selected[value] = not self.Selected[value]
        local selected = {}
        for _, item in ipairs(self.Values) do
            if self.Selected[item] then table.insert(selected, item) end
        end
        safeCall("MultiDropdown:" .. self.Text, self.Callback, selected)
    else
        self.Selected = value
        self.Open = false
        DXForge.Runtime.PopupOwner = nil
        safeCall("Dropdown:" .. self.Text, self.Callback, self.Selected)
    end
end

function Dropdown:render(theme)
    self:updateHover()
    local b = self.Bounds
    local headerId = self.Id .. ":header"

    Render.text({b[1], b[2] + 1}, theme.FontColor, Render.trimText(self.Text, b[3]))
    local bx, by, bw, bh = b[1], b[2] + 17, b[3], 20
    if Input:clicked(headerId, bx, by, bw, bh) then
        self.Open = not self.Open
        DXForge.Runtime.PopupOwner = self.Open and self or nil
    end
    Input:release(headerId)

    local openAmount = DXForge:Animate(self.Id .. ":open", self.Open and 1 or 0, 18)
    Render.filled({bx, by}, {bx + bw, by + bh}, theme.OutlineColor)
    Render.filled({bx + 1, by + 1}, {bx + bw - 1, by + bh - 1}, theme.PanelColor)
    Render.text({bx + 6, by + 3}, theme.TextMutedColor, Render.trimText(self:displayText(), bw - 23))
    Render.text({bx + bw - 14, by + 2}, theme.AccentColor, self.Open and "^" or "v")

    if openAmount > 0.02 then
        local itemHeight = 20
        local visibleCount = math.min(#self.Values, 8)
        local ph = visibleCount * itemHeight * openAmount
        Render.filled({bx, by + bh + 2}, {bx + bw, by + bh + 2 + ph}, theme.OutlineColor)
        Render.filled({bx + 1, by + bh + 3}, {bx + bw - 1, by + bh + 1 + ph}, theme.BackgroundColor)
        if self.Open then
            Input:claim(self.Id)
            for index = 1, visibleCount do
                local value = self.Values[index]
                local iy = by + bh + 3 + (index - 1) * itemHeight
                local itemId = self.Id .. ":item:" .. tostring(index)
                local hovered = Input:hover(bx + 1, iy, bw - 2, itemHeight)
                if hovered then
                    Render.filled({bx + 2, iy}, {bx + bw - 2, iy + itemHeight}, theme.HoverColor)
                end
                local selected = self.Multi and self.Selected[value] or self.Selected == value
                Render.text({bx + 7, iy + 3}, selected and theme.AccentColor or theme.FontColor, Render.trimText(tostring(value), bw - 14))
                if Input:clicked(itemId, bx + 1, iy, bw - 2, itemHeight) then
                    self:setSelected(value)
                end
                Input:release(itemId)
            end
        end
    end
end

function Dropdown:layout(x, y, w)
    self.Bounds = {x, y, w, self.Open and (48 + math.min(#self.Values, 8) * 20) or 42}
    return self.Bounds[4]
end

local Textbox = setmetatable({}, Component)
Textbox.__index = Textbox

function Textbox:new(groupbox, config)
    local object = Component.new(self, "Textbox", groupbox, config)
    object.Placeholder = tostring(config.Placeholder or "Enter text...")
    object.Value = tostring(config.Default or "")
    object.ClearButton = config.ClearButton ~= false
    object.Height = 42
    return object
end

--[[
    Updates textbox text.

    @param value string
        New text value.
    @param silent boolean|nil
        When true, the callback is not invoked.
    @return table
        Returns the textbox instance.
]]
---@param value string
---@param silent boolean|nil
---@return table
function Textbox:SetValue(value, silent)
    self.Value = tostring(value or "")
    if not silent then safeCall("Textbox:" .. self.Text, self.Callback, self.Value) end
    return self
end

function Textbox:render(theme)
    self:updateHover()
    local b = self.Bounds
    Render.text({b[1], b[2] + 1}, theme.FontColor, Render.trimText(self.Text, b[3]))
    local bx, by, bw, bh = b[1], b[2] + 18, b[3], 20
    if Input:clicked(self.Id, bx, by, bw, bh) then
        Input.FocusText = self
    end
    Input:release(self.Id)

    if Input.FocusText == self and Input.KeyPressed then
        local key = Input.Key
        if key == "[ENTER]" then
            Input.FocusText = nil
            safeCall("Textbox:" .. self.Text, self.Callback, self.Value)
        elseif key == "[BACKSPACE]" then
            self.Value = string.sub(self.Value, 1, math.max(0, #self.Value - 1))
            safeCall("Textbox:" .. self.Text, self.Callback, self.Value)
        elseif key == "[ESCAPE]" then
            Input.FocusText = nil
        elseif keyToChar(key) then
            self.Value = self.Value .. keyToChar(key)
            safeCall("Textbox:" .. self.Text, self.Callback, self.Value)
        end
    end

    local active = Input.FocusText == self
    Render.filled({bx, by}, {bx + bw, by + bh}, active and theme.AccentColor or theme.OutlineColor)
    Render.filled({bx + 1, by + 1}, {bx + bw - 1, by + bh - 1}, theme.PanelColor)
    local shown = self.Value ~= "" and self.Value or self.Placeholder
    Render.text({bx + 6, by + 3}, self.Value ~= "" and theme.FontColor or theme.TextMutedColor, Render.trimText(shown, bw - 14))
end

local Keybind = setmetatable({}, Component)
Keybind.__index = Keybind

function Keybind:new(groupbox, config)
    local object = Component.new(self, "Keybind", groupbox, config)
    object.Key = tostring(config.Default or "[None]")
    object.Mode = tostring(config.Mode or "Toggle")
    object.Reading = false
    object.State = false
    return object
end

--[[
    Updates a keybind key.

    @param key string
        DX9 key string such as "[INSERT]" or "[F4]".
    @param silent boolean|nil
        When true, the callback is not invoked.
    @return table
        Returns the keybind instance.
]]
---@param key string
---@param silent boolean|nil
---@return table
function Keybind:SetKey(key, silent)
    self.Key = tostring(key or "[None]")
    if not silent then safeCall("Keybind:" .. self.Text, self.Callback, self.Key, self.State) end
    return self
end

function Keybind:render(theme)
    self:updateHover()
    local b = self.Bounds
    Render.text({b[1], b[2] + 5}, theme.FontColor, Render.trimText(self.Text, b[3] - 82))
    local bx, by, bw, bh = b[1] + b[3] - 78, b[2] + 3, 76, 20
    if Input:clicked(self.Id, bx, by, bw, bh) then
        self.Reading = true
    end
    Input:release(self.Id)

    if self.Reading and Input.KeyPressed and Input.Key ~= "[LBUTTON]" then
        self:SetKey(Input.Key)
        self.Reading = false
    elseif (not self.Reading) and self.Key ~= "[None]" and Input.KeyPressed and Input.Key == self.Key then
        if self.Mode == "Hold" then
            self.State = true
        else
            self.State = not self.State
        end
        safeCall("Keybind:" .. self.Text, self.Callback, self.Key, self.State)
    elseif self.Mode == "Hold" and self.State and Input.Key ~= self.Key then
        self.State = false
        safeCall("Keybind:" .. self.Text, self.Callback, self.Key, self.State)
    end

    Render.filled({bx, by}, {bx + bw, by + bh}, self.Reading and theme.AccentColor or theme.OutlineColor)
    Render.filled({bx + 1, by + 1}, {bx + bw - 1, by + bh - 1}, theme.PanelColor)
    Render.text({bx + 5, by + 3}, self.State and theme.AccentColor or theme.TextMutedColor, Render.trimText(self.Reading and "Press key" or self.Key, bw - 10))
end

local ColorPicker = setmetatable({}, Component)
ColorPicker.__index = ColorPicker

function ColorPicker:new(groupbox, config)
    local object = Component.new(self, "ColorPicker", groupbox, config)
    object.Value = normalizeColor(config.Default, DXForge:GetTheme().AccentColor)
    object.Hue, object.Sat, object.Val = rgbToHsv(object.Value)
    object.Alpha = object.Value[4] or 255
    object.Open = false
    object.WithAlpha = config.Alpha == true
    object.Height = 30
    return object
end

function ColorPicker:SetColor(color, silent)
    self.Value = normalizeColor(color, self.Value)
    self.Hue, self.Sat, self.Val = rgbToHsv(self.Value)
    self.Alpha = self.Value[4] or self.Alpha
    if not silent then safeCall("ColorPicker:" .. self.Text, self.Callback, self.Value) end
    return self
end

function ColorPicker:updateColor(silent)
    local rgb = hsvToRgb(self.Hue, self.Sat, self.Val)
    rgb[4] = self.Alpha
    self.Value = rgb
    if not silent then safeCall("ColorPicker:" .. self.Text, self.Callback, self.Value) end
end

function ColorPicker:render(theme)
    self:updateHover()
    local b = self.Bounds
    Render.text({b[1], b[2] + 5}, theme.FontColor, Render.trimText(self.Text, b[3] - 76))

    local sx, sy, sw, sh = b[1] + b[3] - 65, b[2] + 4, 26, 16
    Render.filled({sx - 1, sy - 1}, {sx + sw + 1, sy + sh + 1}, self.Open and theme.AccentColor or theme.OutlineColor)
    Render.filled({sx, sy}, {sx + sw, sy + sh}, self.Value)
    Render.text({sx + sw + 7, sy - 1}, theme.TextMutedColor, "...")

    if Input:clicked(self.Id, sx - 2, sy - 2, 64, 22) then
        self.Open = not self.Open
        DXForge.Runtime.PopupOwner = self.Open and self or nil
    end
    Input:release(self.Id)

    local open = DXForge:Animate(self.Id .. ":open", self.Open and 1 or 0, 18)
    if open > 0.02 then
        local px, py = b[1], b[2] + 28
        local pw, ph = b[3], (self.WithAlpha and 124 or 106) * open
        Render.filled({px, py}, {px + pw, py + ph}, theme.OutlineColor)
        Render.filled({px + 1, py + 1}, {px + pw - 1, py + ph - 1}, theme.BackgroundColor)

        if self.Open then
            Input:claim(self.Id)
            local areaX, areaY, areaW, areaH = px + 8, py + 9, pw - 26, 72
            local hueX, hueY, hueW, hueH = px + pw - 13, py + 9, 5, 72
            local currentHue = hsvToRgb(self.Hue, 1, 1)

            local steps = 16
            for ix = 0, steps - 1 do
                for iy = 0, 7 do
                    local sat = ix / (steps - 1)
                    local val = 1 - (iy / 7)
                    local color = hsvToRgb(self.Hue, sat, val)
                    local cx = areaX + (areaW / steps) * ix
                    local cy = areaY + (areaH / 8) * iy
                    Render.filled({cx, cy}, {cx + areaW / steps + 1, cy + areaH / 8 + 1}, color)
                end
            end

            for i = 0, 35 do
                local color = hsvToRgb(i / 35, 1, 1)
                local hy = hueY + (hueH / 36) * i
                Render.filled({hueX, hy}, {hueX + hueW, hy + hueH / 36 + 1}, color)
            end

            if Input.MouseDown and Input:hover(areaX, areaY, areaW, areaH) then
                Input:claim(self.Id .. ":sv")
                self.Sat = clamp((Input.Mouse.x - areaX) / areaW, 0, 1)
                self.Val = 1 - clamp((Input.Mouse.y - areaY) / areaH, 0, 1)
                self:updateColor()
            elseif Input.MouseDown and Input:hover(hueX - 3, hueY, hueW + 6, hueH) then
                Input:claim(self.Id .. ":hue")
                self.Hue = clamp((Input.Mouse.y - hueY) / hueH, 0, 1)
                self:updateColor()
            end

            local markerX = areaX + self.Sat * areaW
            local markerY = areaY + (1 - self.Val) * areaH
            Render.box({markerX - 2, markerY - 2}, {markerX + 2, markerY + 2}, theme.FontColor)
            Render.line({hueX - 3, hueY + self.Hue * hueH}, {hueX + hueW + 3, hueY + self.Hue * hueH}, theme.FontColor)

            Render.filled({px + 8, py + 88}, {px + pw - 8, py + 105}, theme.PanelColor)
            Render.text({px + 13, py + 90}, currentHue, rgbToHex(self.Value) .. "  RGB(" .. math.floor(self.Value[1]) .. ", " .. math.floor(self.Value[2]) .. ", " .. math.floor(self.Value[3]) .. ")")
        end
    end
end

function ColorPicker:layout(x, y, w)
    self.Bounds = {x, y, w, self.Open and (self.WithAlpha and 154 or 136) or 30}
    return self.Bounds[4]
end

--// Groupbox / Section System -------------------------------------------------

local Groupbox = {}
Groupbox.__index = Groupbox

function Groupbox:new(tab, title, side)
    return setmetatable({
        Tab = tab,
        Title = tostring(title or "Section"),
        Side = side or "left",
        Components = {},
        Bounds = {0, 0, 0, 0},
        Visible = true
    }, self)
end

function Groupbox:add(component)
    table.insert(self.Components, component)
    return component
end

--[[
    Adds a label to the groupbox.

    @param config table|string
        Label config table or direct text string.
    @return table
        Returns the label component.
]]
---@param config DXForgeBaseComponentConfig|string
---@return table
function Groupbox:AddLabel(config)
    if type(config) ~= "table" then config = {Text = tostring(config or "Label")} end
    return self:add(Label:new(self, config))
end

--[[
    Adds a divider line to the groupbox.

    @param text string|table|nil
        Optional divider label or config table.
    @return table
        Returns the divider component.
]]
---@param text string|table|nil
---@return table
function Groupbox:AddDivider(text)
    local config = type(text) == "table" and text or {Text = text or ""}
    return self:add(Divider:new(self, config))
end

--[[
    Adds a clickable button.

    @param config table
        Button config with Text, Tooltip, Callback, and optional layout fields.
    @return table
        Returns the button component.
]]
---@param config DXForgeButtonConfig
---@return table
function Groupbox:AddButton(config)
    assertType("AddButton.config", config, "table")
    return self:add(Button:new(self, config))
end

--[[
    Adds a boolean toggle switch.

    @param config table
        Toggle config with Text, Default, Keybind, Tooltip, and Callback.
    @return table
        Returns the toggle component.
]]
---@param config DXForgeToggleConfig
---@return table
function Groupbox:AddToggle(config)
    assertType("AddToggle.config", config, "table")
    return self:add(Toggle:new(self, config))
end

--[[
    Adds a numeric slider.

    @param config table
        Slider config with Text, Min, Max, Default, Step, Tooltip, and Callback.
    @return table
        Returns the slider component.
]]
---@param config DXForgeSliderConfig
---@return table
function Groupbox:AddSlider(config)
    assertType("AddSlider.config", config, "table")
    return self:add(Slider:new(self, config))
end

--[[
    Adds a single-select dropdown.

    @param config table
        Dropdown config with Text, Values, Default, Tooltip, and Callback.
    @return table
        Returns the dropdown component.
]]
---@param config DXForgeDropdownConfig
---@return table
function Groupbox:AddDropdown(config)
    assertType("AddDropdown.config", config, "table")
    return self:add(Dropdown:new(self, config, false))
end

--[[
    Adds a multi-select dropdown.

    @param config table
        MultiDropdown config with Text, Values, Default, Tooltip, and Callback.
    @return table
        Returns the multi-dropdown component.
]]
---@param config DXForgeMultiDropdownConfig
---@return table
function Groupbox:AddMultiDropdown(config)
    assertType("AddMultiDropdown.config", config, "table")
    return self:add(Dropdown:new(self, config, true))
end

--[[
    Adds a textbox input.

    @param config table
        Textbox config with Text, Placeholder, Default, Tooltip, and Callback.
    @return table
        Returns the textbox component.
]]
---@param config DXForgeTextboxConfig
---@return table
function Groupbox:AddTextbox(config)
    assertType("AddTextbox.config", config, "table")
    return self:add(Textbox:new(self, config))
end

--[[
    Adds a keybind selector.

    @param config table
        Keybind config with Text, Default, Mode, Tooltip, and Callback.
    @return table
        Returns the keybind component.
]]
---@param config DXForgeKeybindConfig
---@return table
function Groupbox:AddKeybind(config)
    assertType("AddKeybind.config", config, "table")
    return self:add(Keybind:new(self, config))
end

--[[
    Adds an RGB color picker.

    @param config table
        ColorPicker config with Text, Default, Alpha, Tooltip, and Callback.
    @return table
        Returns the color picker component.
]]
---@param config DXForgeColorPickerConfig
---@return table
function Groupbox:AddColorPicker(config)
    assertType("AddColorPicker.config", config, "table")
    return self:add(ColorPicker:new(self, config))
end

function Groupbox:measure(width)
    local height = 28
    for _, component in ipairs(self.Components) do
        if component.Visible then
            height = height + component:layout(0, 0, width - 18) + 6
        end
    end
    return math.max(height + 4, 44)
end

function Groupbox:render(theme, x, y, w)
    if not self.Visible then return 0 end
    local h = self:measure(w)
    self.Bounds = {x, y, w, h}
    Render.filled({x, y}, {x + w, y + h}, theme.OutlineColor)
    Render.filled({x + 1, y + 1}, {x + w - 1, y + 3}, theme.AccentColor)
    Render.filled({x + 1, y + 4}, {x + w - 1, y + h - 1}, theme.BackgroundColor)
    Render.text({x + 10, y + 7}, theme.FontColor, Render.trimText(self.Title, w - 20))

    local cursor = y + 28
    for _, component in ipairs(self.Components) do
        if component.Visible then
            local rowHeight = component:layout(x + 9, cursor, w - 18)
            component:render(theme)
            cursor = cursor + rowHeight + 6
        end
    end
    return h
end

--// Tab System ----------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Tab:new(window, name)
    return setmetatable({
        Window = window,
        Name = tostring(name or "Tab"),
        Groupboxes = {},
        Layout = {Left = 0, Right = 0, Full = 0}
    }, self)
end

--[[
    Adds a groupbox/section to a tab.

    @param name string
        Section title.
    @param side string|nil
        Layout side: "left", "right", "full", or "middle".
    @return table
        Returns the groupbox instance.
]]
---@param name string
---@param side DXForgeSide|nil
---@return table
function Tab:AddGroupbox(name, side)
    side = tostring(side or "left"):lower()
    if side == "middle" then side = "full" end
    if side ~= "left" and side ~= "right" and side ~= "full" then side = "left" end
    local groupbox = Groupbox:new(self, name, side)
    table.insert(self.Groupboxes, groupbox)
    return groupbox
end

--[[
    Adds a left-column groupbox.

    @param name string
        Section title.
    @return table
        Returns the groupbox instance.
]]
---@param name string
---@return table
function Tab:AddLeftGroupbox(name)
    return self:AddGroupbox(name, "left")
end

--[[
    Adds a right-column groupbox.

    @param name string
        Section title.
    @return table
        Returns the groupbox instance.
]]
---@param name string
---@return table
function Tab:AddRightGroupbox(name)
    return self:AddGroupbox(name, "right")
end

--[[
    Adds a full-width groupbox.

    @param name string
        Section title.
    @return table
        Returns the groupbox instance.
]]
---@param name string
---@return table
function Tab:AddMiddleGroupbox(name)
    return self:AddGroupbox(name, "full")
end

--[[
    Makes this tab the active tab on its parent window.

    @return table
        Returns the tab instance.
]]
---@return table
function Tab:Focus()
    self.Window.ActiveTab = self
    return self
end

function Tab:render(theme, x, y, w, h)
    local gutter = 10
    local columnW = math.floor((w - gutter) / 2)
    local leftY, rightY, fullY = y, y, y

    for _, groupbox in ipairs(self.Groupboxes) do
        if groupbox.Side == "full" then
            local gy = math.max(leftY, rightY, fullY)
            local gh = groupbox:render(theme, x, gy, w)
            leftY, rightY, fullY = gy + gh + gutter, gy + gh + gutter, gy + gh + gutter
        elseif groupbox.Side == "right" then
            local gh = groupbox:render(theme, x + columnW + gutter, rightY, columnW)
            rightY = rightY + gh + gutter
        else
            local gh = groupbox:render(theme, x, leftY, columnW)
            leftY = leftY + gh + gutter
        end
    end
end

--// Window System -------------------------------------------------------------

local Window = {}
Window.__index = Window

function Window:new(config)
    assertType("CreateWindow.config", config, "table")
    assertType("CreateWindow.Title", config.Title, "string", true)

    local sw, sh = Render.screen()
    local size = normalizeVec2(config.Size, {600, 500})
    local position = normalizeVec2(config.Position or config.StartLocation, {math.floor((sw - size[1]) / 2), math.floor((sh - size[2]) / 2)})
    DXForge.Runtime.ZCounter = DXForge.Runtime.ZCounter + 1
    local requiresStartup = not DXForge.Runtime.StartupQueued and not DXForge.Runtime.StartupCompleted

    local object = setmetatable({
        Title = config.Title or "DXForge Window",
        Position = position,
        Size = {math.max(360, size[1]), math.max(260, size[2])},
        MinSize = normalizeVec2(config.MinSize, {360, 260}),
        ToggleKey = config.ToggleKey,
        Resizable = config.Resizable == true,
        Footer = config.Footer ~= false,
        ThemeName = config.Theme or DXForge.ActiveTheme,
        Open = config.Open ~= false,
        Visible = config.Open ~= false,
        Tabs = {},
        ActiveTab = nil,
        Dragging = false,
        Resizing = false,
        DragOffset = {0, 0},
        ZIndex = DXForge.Runtime.ZCounter,
        Alpha = 1,
        Scale = 1,
        Startup = requiresStartup,
        Id = "Window:" .. tostring(math.random(100000, 999999)) .. ":" .. tostring(os.clock())
    }, self)

    if object.Startup then
        DXForge.Runtime.StartupQueued = true
        DXForge.Startup = {
            StartedAt = os.clock(),
            Done = false,
            Window = object
        }
        object.Visible = false
    end

    return object
end

--[[
    Adds a tab to the window.

    @param name string
        Tab display name.
    @return table
        Returns the created tab instance.
]]
---@param name string
---@return table
function Window:AddTab(name)
    local tab = Tab:new(self, name)
    table.insert(self.Tabs, tab)
    if not self.ActiveTab then self.ActiveTab = tab end
    return tab
end

--[[
    Sets window open state.

    @param value boolean
        True to open, false to close.
    @return table
        Returns the window instance.
]]
---@param value boolean
---@return table
function Window:SetOpen(value)
    self.Open = value == true
    return self
end

--[[
    Toggles window open state.

    @return table
        Returns the window instance.
]]
---@return table
function Window:Toggle()
    self.Open = not self.Open
    return self
end

--[[
    Raises the window above other DXForge windows.

    @return table
        Returns the window instance.
]]
---@return table
function Window:BringToFront()
    DXForge.Runtime.ZCounter = DXForge.Runtime.ZCounter + 1
    self.ZIndex = DXForge.Runtime.ZCounter
    DXForge.Runtime.ActiveWindow = self
    return self
end

function Window:contentRect()
    return self.Position[1] + 13, self.Position[2] + 62, self.Size[1] - 26, self.Size[2] - (self.Footer and 76 or 50)
end

function Window:handleInput(theme)
    if self.ToggleKey and Input.KeyPressed and Input.Key == self.ToggleKey then
        self:Toggle()
    end

    local x, y = self.Position[1], self.Position[2]
    local w, h = self.Size[1], self.Size[2]
    local id = self.Id

    if Input.ClickStarted and Input:hover(x, y, w, h) and DXForge.Runtime.InputWindow == self then
        self:BringToFront()
    end

    if DXForge.Runtime.InputWindow ~= self and not self.Dragging and not self.Resizing then
        return
    end

    if Input:clicked(id .. ":drag", x, y, w, DXForge.Config.HeaderHeight) then
        self:BringToFront()
        self.Dragging = true
        self.DragOffset = {Input.Mouse.x - x, Input.Mouse.y - y}
    end

    if self.Resizable and Input:clicked(id .. ":resize", x + w - 14, y + h - 14, 14, 14) then
        self:BringToFront()
        self.Resizing = true
    end

    if not Input.MouseDown then
        self.Dragging = false
        self.Resizing = false
    end

    if self.Dragging then
        Input:claim(id .. ":drag")
        local sw, sh = Render.screen()
        self.Position[1] = clamp(Input.Mouse.x - self.DragOffset[1], 0, sw - 60)
        self.Position[2] = clamp(Input.Mouse.y - self.DragOffset[2], 0, sh - 35)
    elseif self.Resizing then
        Input:claim(id .. ":resize")
        self.Size[1] = math.max(self.MinSize[1], Input.Mouse.x - x)
        self.Size[2] = math.max(self.MinSize[2], Input.Mouse.y - y)
    end
end

function Window:renderTabs(theme)
    local x, y = self.Position[1] + 10, self.Position[2] + 31
    local cursor = x
    local maxX = self.Position[1] + self.Size[1] - 10

    for index, tab in ipairs(self.Tabs) do
        local tw = math.min(Render.textWidth(tab.Name) + 22, 120)
        if cursor + tw > maxX then break end
        local active = self.ActiveTab == tab
        local id = self.Id .. ":tab:" .. tostring(index)
        if Input:clicked(id, cursor, y, tw, DXForge.Config.TabHeight) then
            self.ActiveTab = tab
        end
        Input:release(id)

        local t = DXForge:Animate(id .. ":active", active and 1 or 0, 15)
        Render.filled({cursor, y}, {cursor + tw, y + DXForge.Config.TabHeight}, theme.OutlineColor)
        Render.filled({cursor + 1, y + 1}, {cursor + tw - 1, y + DXForge.Config.TabHeight - 1}, blend(theme.PanelColor, theme.BackgroundColor, t))
        if active then
            Render.filled({cursor + 1, y + 1}, {cursor + tw - 1, y + 3}, theme.AccentColor)
        end
        Render.text({cursor + 10, y + 6}, active and theme.FontColor or theme.TextMutedColor, Render.trimText(tab.Name, tw - 18))
        cursor = cursor + tw + 5
    end
end

function Window:renderFooter(theme)
    if not self.Footer then return end
    local x, y = self.Position[1], self.Position[2]
    local w, h = self.Size[1], self.Size[2]
    local footerY = y + h - 25
    Render.filled({x + 5, footerY - 1}, {x + w - 5, footerY}, theme.OutlineColor)
    Render.text({x + 10, footerY + 5}, theme.TextMutedColor, "DXForge " .. DXForge.__DXFORGE_VERSION)
    local keyText = self.ToggleKey and ("Toggle: " .. self.ToggleKey) or "Ready"
    Render.text({x + w - Render.textWidth(keyText) - 10, footerY + 5}, theme.TextMutedColor, keyText)
end

function Window:render()
    local theme = DXForge:GetTheme(self.ThemeName)
    self:handleInput(theme)

    self.Alpha = DXForge:Animate(self.Id .. ":open", self.Open and 1 or 0, 14)
    if self.Alpha <= 0.01 then return end

    local x, y = self.Position[1], self.Position[2]
    local w, h = self.Size[1], self.Size[2]
    Render.panel(x, y, w, h, theme, true)
    Render.filled({x + 1, y + 1}, {x + w - 1, y + DXForge.Config.HeaderHeight}, theme.MainColor)
    Render.text({x + 11, y + 7}, theme.FontColor, Render.trimText(self.Title, w - 26))

    self:renderTabs(theme)

    local cx, cy, cw, ch = self:contentRect()
    Render.filled({cx - 1, cy - 1}, {cx + cw + 1, cy + ch + 1}, theme.OutlineColor)
    Render.filled({cx, cy}, {cx + cw, cy + ch}, theme.MainColor)

    if self.ActiveTab then
        self.ActiveTab:render(theme, cx + 10, cy + 10, cw - 20, ch - 20)
    end

    if self.Resizable then
        Render.filled({x + w - 10, y + h - 10}, {x + w - 4, y + h - 4}, theme.AccentColor)
    end

    self:renderFooter(theme)
end

--[[
    Creates a new DXForge window.

    @param config table
        Required:
            - Title: string
        Optional:
            - Size: table<number, number>
            - Position: table<number, number>
            - ToggleKey: string
            - Resizable: boolean
            - Footer: boolean
            - Theme: string
            - Startup: deprecated/ignored. DXForge always runs its branded startup once.

    @return table
        Returns the created window instance.
]]
---@param config DXForgeWindowConfig
---@return table
function DXForge:CreateWindow(config)
    local window = Window:new(config or {})
    table.insert(self.Windows, window)
    table.insert(self.WindowOrder, window)
    return window
end

--// Notifications -------------------------------------------------------------

--[[
    Creates a slide/fade notification.

    @param config table|string
        Notification config table or direct text string.
    @param length number|nil
        Legacy duration argument used when config is a string.
    @param kind string|nil
        Legacy notification type argument used when config is a string.
    @return table
        Returns the DXForge instance for chaining.
]]
---@param config DXForgeNotificationConfig|string
---@param length number|nil
---@param kind DXForgeNotificationType|nil
---@return DXForge
function DXForge:Notify(config, length, kind)
    if type(config) ~= "table" then
        config = {Text = tostring(config or ""), Duration = length, Type = kind}
    end

    table.insert(self.Notifications, {
        Text = tostring(config.Text or ""),
        Duration = tonumber(config.Duration) or tonumber(config.Length) or 3,
        Type = tostring(config.Type or "Info"),
        CreatedAt = os.clock(),
        ManualClose = config.ManualClose == true,
        Id = "Notification:" .. tostring(math.random(100000, 999999))
    })
    return self
end

function DXForge:renderNotifications(theme)
    local sw = Render.screen()
    local y = 78
    local now = os.clock()
    local kept = {}

    for _, notification in ipairs(self.Notifications) do
        local age = now - notification.CreatedAt
        if age <= notification.Duration then
            table.insert(kept, notification)
            local lines = splitLines(notification.Text)
            local width = 230
            for _, line in ipairs(lines) do
                width = math.max(width, Render.textWidth(line) + 34)
            end
            width = math.min(width, 420)
            local height = 26 + (#lines - 1) * 17
            local enter = easeOutCubic(clamp(age / 0.32, 0, 1))
            local leave = 1 - easeOutCubic(clamp((age - notification.Duration + 0.35) / 0.35, 0, 1))
            local alpha = math.min(enter, leave)
            local x = sw - 20 - width + (1 - alpha) * 42
            local color = theme.AccentColor
            if notification.Type == "Success" then color = theme.SuccessColor
            elseif notification.Type == "Warning" then color = theme.WarningColor
            elseif notification.Type == "Error" then color = theme.ErrorColor end

            Render.filled({x, y}, {x + width, y + height}, theme.OutlineColor)
            Render.filled({x + 1, y + 1}, {x + width - 1, y + height - 1}, theme.PanelColor)
            Render.filled({x + 1, y + 1}, {x + 4, y + height - 1}, color)
            local progress = clamp(age / notification.Duration, 0, 1)
            Render.filled({x + 4, y + height - 3}, {x + 4 + (width - 5) * (1 - progress), y + height - 1}, color)

            for index, line in ipairs(lines) do
                Render.text({x + 12, y + 6 + (index - 1) * 17}, index == 1 and theme.FontColor or theme.TextMutedColor, Render.trimText(line, width - 22))
            end
            y = y + height + 8
        end
    end

    self.Notifications = kept
end

--// Tooltips ------------------------------------------------------------------

function DXForge:renderTooltip(theme)
    local tooltip = self.Runtime.HoveredTooltip
    if not tooltip or not tooltip.Text then return end
    if os.clock() - tooltip.Since < self.Config.TooltipDelay then return end

    local lines = splitLines(tooltip.Text)
    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(width, Render.textWidth(line))
    end
    width = width + 14
    local height = 10 + #lines * 16
    local sw, sh = Render.screen()
    local x = clamp(Input.Mouse.x + 14, 4, sw - width - 4)
    local y = clamp(Input.Mouse.y + 16, 4, sh - height - 4)

    Render.filled({x, y}, {x + width, y + height}, theme.AccentColor)
    Render.filled({x + 1, y + 1}, {x + width - 1, y + height - 1}, theme.BackgroundColor)
    for index, line in ipairs(lines) do
        Render.text({x + 7, y + 5 + (index - 1) * 16}, theme.FontColor, line)
    end
end

--// Watermark -----------------------------------------------------------------

--[[
    Configures the DXForge watermark.

    @param config table|string
        Watermark config table or direct text string.
    @return table
        Returns the DXForge instance for chaining.
]]
---@param config DXForgeWatermarkConfig|string
---@return DXForge
function DXForge:SetWatermark(config)
    if type(config) ~= "table" then
        config = {Text = tostring(config or "")}
    end
    self.Watermark = {
        Visible = config.Visible ~= false,
        Text = tostring(config.Text or "DXForge"),
        Position = normalizeVec2(config.Position, {12, 12})
    }
    return self
end

DXForge:SetWatermark({Text = "DXForge", Visible = true, Position = {12, 12}})

function DXForge:renderWatermark(theme)
    if not self.Watermark or not self.Watermark.Visible then return end
    local text = self.Watermark.Text
    local x, y = self.Watermark.Position[1], self.Watermark.Position[2]
    local w = Render.textWidth(text) + 22
    Render.filled({x, y}, {x + w, y + 24}, theme.OutlineColor)
    Render.filled({x + 1, y + 1}, {x + w - 1, y + 23}, theme.PanelColor)
    Render.filled({x + 1, y + 1}, {x + 4, y + 23}, theme.AccentColor)
    Render.text({x + 11, y + 5}, theme.FontColor, text)
end

--// Startup Screen ------------------------------------------------------------

function DXForge:renderStartup(theme)
    local startup = self.Startup
    if not startup or startup.Done then return false end

    local now = os.clock()
    local age = now - startup.StartedAt
    local duration = self.Config.StartupDuration
    local sw, sh = Render.screen()
    local intro = easeOutCubic(clamp(age / 0.65, 0, 1))
    local outro = 1 - easeInOut(clamp((age - duration + 0.55) / 0.55, 0, 1))
    local alpha = math.min(intro, outro)
    local scale = 0.92 + 0.08 * intro - 0.04 * (1 - outro)

    if age >= duration then
        startup.Done = true
        self.Runtime.StartupCompleted = true
        if startup.Window then startup.Window.Visible = true end
        return false
    end

    local bw, bh = 390 * scale, 174 * scale
    local x, y = (sw - bw) / 2, (sh - bh) / 2
    local pulse = self:Pulse(4)
    local sweep = ((age * 115) % (bw + 80)) - 40

    Render.filled({0, 0}, {sw, sh}, {3, 4, 8, math.floor(220 * alpha)})
    Render.filled({x - 8, y - 8}, {x + bw + 8, y + bh + 8}, {0, 0, 0, math.floor(125 * alpha)})
    Render.panel(x, y, bw, bh, theme, true)
    Render.box({x - 1, y - 1}, {x + bw + 1, y + bh + 1}, blend(theme.OutlineColor, theme.GlowColor, pulse))

    Render.line({x + sweep, y + 3}, {x + sweep + 46, y + 3}, theme.GlowColor)
    Render.line({x + bw - sweep, y + bh - 4}, {x + bw - sweep - 46, y + bh - 4}, theme.AccentColor)

    local logoDrawn = Render.image(self.Logo.Source, x + 62 * scale, y + 34 * scale, 266 * scale, 58 * scale, {255, 255, 255, math.floor(255 * alpha)})
    if not logoDrawn then
        Render.text({x + (bw / 2) - 48, y + 46 * scale}, theme.FontColor, "DXForge")
        Render.text({x + (bw / 2) - 49, y + 46 * scale}, theme.AccentColor, "DX")
    end

    local messages = {"Initializing DXForge...", "Loading Interface...", "Preparing UI Components..."}
    local message = messages[math.floor(clamp(age / duration, 0, 0.99) * #messages) + 1]
    Render.text({x + 24, y + bh - 50}, theme.TextMutedColor, message)
    Render.text({x + bw - Render.textWidth("PixelGG") - 24, y + bh - 50}, theme.AccentColor, "PixelGG")
    Render.filled({x + 24, y + bh - 24}, {x + bw - 24, y + bh - 17}, theme.OutlineColor)
    Render.filled({x + 25, y + bh - 23}, {x + bw - 25, y + bh - 18}, theme.BackgroundColor)
    Render.filled({x + 25, y + bh - 23}, {x + 25 + (bw - 50) * clamp(age / duration, 0, 1), y + bh - 18}, theme.AccentColor)
    return true
end

--// DXForge Core --------------------------------------------------------------

function DXForge:sortWindows()
    table.sort(self.WindowOrder, function(a, b)
        return a.ZIndex < b.ZIndex
    end)
end

function DXForge:beginFrame()
    local now = os.clock()
    self.Runtime.Delta = clamp(now - (self.Runtime.LastFrame or now), 0, 0.05)
    self.Runtime.LastFrame = now
    self.Runtime.HoveredTooltip = nil
    Input:update()
end

--[[
    Updates input and renders the full DXForge frame.

    Call this once per DX9 frame/script tick after constructing the UI.

    @return table
        Returns the DXForge instance for chaining.
]]
---@return DXForge
function DXForge:Render()
    self:beginFrame()
    local theme = self:GetTheme()

    if self:renderStartup(theme) then
        self:renderNotifications(theme)
        return self
    end

    self:renderWatermark(theme)
    self:sortWindows()
    self.Runtime.InputWindow = nil
    for index = #self.WindowOrder, 1, -1 do
        local window = self.WindowOrder[index]
        if window.Visible ~= false and window.Open and Input:hover(window.Position[1], window.Position[2], window.Size[1], window.Size[2]) then
            self.Runtime.InputWindow = window
            break
        end
    end
    for _, window in ipairs(self.WindowOrder) do
        if window.Visible ~= false then
            window:render()
        end
    end
    self:renderNotifications(theme)
    self:renderTooltip(theme)
    return self
end

--[[
    Clears all DXForge runtime UI state.

    Removes windows, notifications, and animation cache entries.

    @return table
        Returns the DXForge instance for chaining.
]]
---@return DXForge
function DXForge:Destroy()
    self.Windows = {}
    self.WindowOrder = {}
    self.Notifications = {}
    self.Animations = {}
    return self
end

--// Debug / Logging -----------------------------------------------------------

--[[
    Enables or disables debug logging.

    @param value boolean
        True to enable debug warnings and callback error output.
    @return table
        Returns the DXForge instance for chaining.
]]
---@param value boolean
---@return DXForge
function DXForge:SetDebug(value)
    self.Debug = value == true
    return self
end

--[[
    Emits a debug warning when debug mode is enabled.

    @param message any
        Message to print.
]]
---@param message any
function DXForge:Warn(message)
    if self.Debug then
        print("[DXForge] " .. tostring(message))
    end
end

_G.DXForge = DXForge
return DXForge
