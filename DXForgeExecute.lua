--[[
    DXForgeExecute - Roblox Luau UI Library for Potassium-style executors
    Version: 2.0.0

    A single-file UI/config/overlay framework built on Roblox Instances.
    It does not depend on any external overlay backend and intentionally
    contains no game manipulation, bypass, or automation features.
]]

local GLOBAL_KEY = "DXForgeExecute"
local env = (type(getgenv) == "function" and getgenv()) or _G

if type(env[GLOBAL_KEY]) == "table" and env[GLOBAL_KEY].Destroy then
    pcall(function()
        env[GLOBAL_KEY]:Destroy()
    end)
end

local DXForgeExecute = {
    __VERSION = "2.0.0",
    Name = "DXForgeExecute",
    Debug = false,
    Windows = {},
    Themes = {},
    ActiveTheme = "DarkTech",
    Flags = {},
    Controls = {},
    ConfigFolder = "DXForgeExecute",
    AutoSave = nil,
    _alive = true,
    _z = 100,
    _themeBindings = {},
    _tweens = {},
    _openDropdown = nil,
    _focusedTextbox = nil,
    _capturingKeybind = nil
}

env[GLOBAL_KEY] = DXForgeExecute
_G[GLOBAL_KEY] = DXForgeExecute

local Services = {}
local function service(name)
    if Services[name] ~= nil then
        return Services[name]
    end
    local ok, result = pcall(function()
        return game:GetService(name)
    end)
    Services[name] = ok and result or false
    return Services[name] or nil
end

local Players = service("Players")
local UserInputService = service("UserInputService")
local RunService = service("RunService")
local TweenService = service("TweenService")
local HttpService = service("HttpService")
local CoreGui = service("CoreGui")
local LocalPlayer = Players and Players.LocalPlayer

local function now()
    return os.clock()
end

local function utcTimestamp()
    local ok, value = pcall(function()
        return os.date("!%Y-%m-%dT%H:%M:%SZ")
    end)
    return ok and value or tostring(os.time())
end

local function warnf(message)
    if DXForgeExecute.Debug then
        warn("[DXForgeExecute] " .. tostring(message))
    end
end

local function safeCall(callback, ...)
    if type(callback) ~= "function" then
        return nil
    end
    local ok, result = pcall(callback, ...)
    if not ok then
        warnf(result)
    end
    return result
end

local function copy(tbl)
    local result = {}
    if type(tbl) == "table" then
        for k, v in pairs(tbl) do
            result[k] = type(v) == "table" and copy(v) or v
        end
    end
    return result
end

local function merge(base, patch)
    local result = copy(base)
    if type(patch) == "table" then
        for k, v in pairs(patch) do
            result[k] = v
        end
    end
    return result
end

local function clamp(value, min, max)
    value = tonumber(value) or min
    if value < min then
        return min
    end
    if value > max then
        return max
    end
    return value
end

local function roundToStep(value, step, precision)
    step = tonumber(step) or 1
    if step > 0 then
        value = math.floor((value / step) + 0.5) * step
    end
    if precision then
        local mul = 10 ^ precision
        value = math.floor(value * mul + 0.5) / mul
    end
    return value
end

local function parseVec2(value, fallback)
    fallback = fallback or {0, 0}
    if typeof(value) == "Vector2" then
        return {value.X, value.Y}
    end
    if type(value) == "table" then
        return {tonumber(value[1] or value.x or value.X) or fallback[1], tonumber(value[2] or value.y or value.Y) or fallback[2]}
    end
    return {fallback[1], fallback[2]}
end

local function parseColor(value, fallback)
    fallback = fallback or Color3.fromRGB(255, 255, 255)
    if typeof(value) == "Color3" then
        return value
    end
    if type(value) == "table" then
        local r = tonumber(value[1] or value.r or value.R)
        local g = tonumber(value[2] or value.g or value.G)
        local b = tonumber(value[3] or value.b or value.B)
        if r and g and b then
            if r <= 1 and g <= 1 and b <= 1 then
                return Color3.new(clamp(r, 0, 1), clamp(g, 0, 1), clamp(b, 0, 1))
            end
            return Color3.fromRGB(clamp(r, 0, 255), clamp(g, 0, 255), clamp(b, 0, 255))
        end
    end
    return fallback
end

local function colorToTable(color, alpha)
    color = parseColor(color)
    local result = {
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    }
    if alpha ~= nil then
        result[4] = alpha
    end
    return result
end

local function keyFromAny(value)
    if typeof(value) == "EnumItem" then
        return value
    end
    if type(value) == "string" then
        local clean = value:gsub("%[", ""):gsub("%]", ""):gsub("Enum.KeyCode.", "")
        return Enum.KeyCode[clean] or Enum.UserInputType[clean]
    end
    return nil
end

local function keyName(key)
    if typeof(key) == "EnumItem" then
        return key.Name
    end
    return tostring(key or "None")
end

local function instance(className, props, parent)
    local obj = Instance.new(className)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

local function disconnectConnection(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({tasks = {}}, Maid)
end

function Maid:Give(task)
    if task ~= nil then
        table.insert(self.tasks, task)
    end
    return task
end

function Maid:Cleanup()
    for i = #self.tasks, 1, -1 do
        local task = self.tasks[i]
        self.tasks[i] = nil
        local t = typeof(task)
        if t == "RBXScriptConnection" then
            pcall(function()
                task:Disconnect()
            end)
        elseif t == "Instance" then
            pcall(function()
                task:Destroy()
            end)
        elseif type(task) == "table" and task.Destroy then
            pcall(function()
                task:Destroy()
            end)
        elseif type(task) == "table" and task.Disconnect then
            pcall(function()
                task:Disconnect()
            end)
        elseif type(task) == "table" and task.Cancel then
            pcall(function()
                task:Cancel()
            end)
        elseif type(task) == "function" then
            pcall(task)
        end
    end
end

function Maid:Destroy()
    self:Cleanup()
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({_handlers = {}, _destroyed = false}, Signal)
end

function Signal:Connect(callback)
    local connection = {Connected = true}
    self._handlers[connection] = callback
    function connection:Disconnect()
        connection.Connected = false
        self._owner._handlers[connection] = nil
    end
    connection._owner = self
    return connection
end

function Signal:Fire(...)
    if self._destroyed then
        return
    end
    for connection, callback in pairs(self._handlers) do
        if connection.Connected then
            safeCall(callback, ...)
        end
    end
end

function Signal:Destroy()
    self._destroyed = true
    table.clear(self._handlers)
end

DXForgeExecute.Events = {
    ThemeChanged = Signal.new(),
    Destroying = Signal.new()
}

local RootMaid = Maid.new()
local Gui = instance("ScreenGui", {
    Name = "DXForgeExecute",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999999
})

local function parentGui()
    local targets = {}
    if CoreGui then
        table.insert(targets, CoreGui)
    end
    if LocalPlayer then
        local ok, pg = pcall(function()
            return LocalPlayer:WaitForChild("PlayerGui", 3)
        end)
        if ok and pg then
            table.insert(targets, pg)
        end
    end
    for _, target in ipairs(targets) do
        local ok = pcall(function()
            Gui.Parent = target
        end)
        if ok then
            return
        end
    end
    warnf("Unable to parent ScreenGui.")
end

parentGui()
RootMaid:Give(Gui)

local OverlayLayer = instance("Frame", {
    Name = "OverlayLayer",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 900000
}, Gui)

local WindowLayer = instance("Frame", {
    Name = "WindowLayer",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 100
}, Gui)

local NotificationLayer = instance("Frame", {
    Name = "NotificationLayer",
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -18, 0, 18),
    Size = UDim2.new(0, 340, 1, -36),
    ZIndex = 800000
}, Gui)
instance("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top
}, NotificationLayer)

local Tooltip = instance("TextLabel", {
    Name = "Tooltip",
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = Color3.fromRGB(16, 18, 24),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Font = Enum.Font.Gotham,
    Text = "",
    TextColor3 = Color3.fromRGB(232, 237, 245),
    TextSize = 13,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Visible = false,
    Size = UDim2.fromOffset(260, 0),
    ZIndex = 950000
}, OverlayLayer)
instance("UICorner", {CornerRadius = UDim.new(0, 7)}, Tooltip)
instance("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10)
}, Tooltip)

local TooltipStroke = instance("UIStroke", {
    Thickness = 1,
    Transparency = 1,
    Color = Color3.fromRGB(70, 81, 98)
}, Tooltip)

local DEFAULT_THEME = {
    Background = Color3.fromRGB(7, 9, 13),
    Surface = Color3.fromRGB(18, 21, 29),
    SurfaceLight = Color3.fromRGB(27, 31, 42),
    SurfaceDark = Color3.fromRGB(11, 13, 18),
    Accent = Color3.fromRGB(118, 180, 255),
    AccentSoft = Color3.fromRGB(44, 82, 124),
    Border = Color3.fromRGB(42, 49, 63),
    BorderStrong = Color3.fromRGB(78, 95, 122),
    Text = Color3.fromRGB(238, 243, 250),
    TextMuted = Color3.fromRGB(150, 160, 176),
    Success = Color3.fromRGB(75, 214, 137),
    Warning = Color3.fromRGB(247, 190, 82),
    Error = Color3.fromRGB(241, 89, 97),
    Shadow = Color3.fromRGB(0, 0, 0)
}

DXForgeExecute.Themes.DarkTech = copy(DEFAULT_THEME)
DXForgeExecute.Themes.Graphite = merge(DEFAULT_THEME, {
    Accent = Color3.fromRGB(173, 222, 196),
    AccentSoft = Color3.fromRGB(57, 91, 74),
    Background = Color3.fromRGB(9, 10, 11),
    Surface = Color3.fromRGB(22, 23, 25)
})
DXForgeExecute.Themes.Obsidian = merge(DEFAULT_THEME, {
    Accent = Color3.fromRGB(221, 154, 97),
    AccentSoft = Color3.fromRGB(95, 60, 37),
    Surface = Color3.fromRGB(17, 17, 20),
    SurfaceLight = Color3.fromRGB(28, 27, 31)
})

local function theme()
    return DXForgeExecute.Themes[DXForgeExecute.ActiveTheme] or DXForgeExecute.Themes.DarkTech
end

local function bindTheme(obj, props)
    if not obj then
        return obj
    end
    table.insert(DXForgeExecute._themeBindings, {Object = obj, Props = props})
    local t = theme()
    for prop, token in pairs(props) do
        if t[token] then
            obj[prop] = t[token]
        end
    end
    return obj
end

local function setThemeProps(obj, props)
    local t = theme()
    for prop, token in pairs(props) do
        if t[token] then
            obj[prop] = t[token]
        end
    end
end

local function applyTheme()
    local t = theme()
    for i = #DXForgeExecute._themeBindings, 1, -1 do
        local binding = DXForgeExecute._themeBindings[i]
        if not binding.Object or binding.Object.Parent == nil then
            table.remove(DXForgeExecute._themeBindings, i)
        else
            for prop, token in pairs(binding.Props) do
                if t[token] then
                    pcall(function()
                        binding.Object[prop] = t[token]
                    end)
                end
            end
        end
    end
    DXForgeExecute.Events.ThemeChanged:Fire(t, DXForgeExecute.ActiveTheme)
end

local function tween(obj, info, props)
    if not TweenService or not obj then
        for k, v in pairs(props) do
            pcall(function()
                obj[k] = v
            end)
        end
        return nil
    end
    local tw = TweenService:Create(obj, info, props)
    DXForgeExecute._tweens[tw] = true
    local completed
    completed = tw.Completed:Connect(function()
        DXForgeExecute._tweens[tw] = nil
        disconnectConnection(completed)
    end)
    tw:Play()
    return tw
end

local function makeShadow(parent, z)
    local shadow = instance("Frame", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.78,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 16, 1, 16),
        ZIndex = z or 0
    }, parent)
    bindTheme(shadow, {BackgroundColor3 = "Shadow"})
    instance("UICorner", {CornerRadius = UDim.new(0, 12)}, shadow)
    return shadow
end

local function addCorner(parent, radius)
    return instance("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, parent)
end

local function addStroke(parent, token, transparency)
    local stroke = instance("UIStroke", {
        Thickness = 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, parent)
    bindTheme(stroke, {Color = token or "Border"})
    return stroke
end

local function label(parent, text, size, bold, z)
    local obj = instance("TextLabel", {
        BackgroundTransparency = 1,
        Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham,
        Text = tostring(text or ""),
        TextSize = size or 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.fromScale(1, 1),
        ZIndex = z or parent.ZIndex + 1
    }, parent)
    bindTheme(obj, {TextColor3 = "Text"})
    return obj
end

local function buttonBase(parent, text, z)
    local b = instance("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamSemibold,
        Text = tostring(text or ""),
        TextSize = 13,
        Size = UDim2.fromScale(1, 1),
        ZIndex = z or parent.ZIndex + 1
    }, parent)
    bindTheme(b, {BackgroundColor3 = "SurfaceLight", TextColor3 = "Text"})
    addCorner(b, 6)
    addStroke(b, "Border", 0.25)
    return b
end

local function getMousePosition()
    if UserInputService then
        return UserInputService:GetMouseLocation()
    end
    return Vector2.new(0, 0)
end

local function viewportSize()
    local camera = workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end
    return Vector2.new(1280, 720)
end

local function isInside(frame, position)
    if not frame or not frame.AbsolutePosition then
        return false
    end
    local p = frame.AbsolutePosition
    local s = frame.AbsoluteSize
    return position.X >= p.X and position.Y >= p.Y and position.X <= p.X + s.X and position.Y <= p.Y + s.Y
end

local function registerTooltip(frame, text, maid)
    local hoverStarted = 0
    local enter = frame.MouseEnter:Connect(function()
        if not text or text == "" then
            return
        end
        hoverStarted = now()
        task.delay(0.55, function()
            if not DXForgeExecute._alive or hoverStarted == 0 or now() - hoverStarted < 0.5 then
                return
            end
            Tooltip.Text = tostring(text)
            Tooltip.Visible = true
            Tooltip.BackgroundTransparency = 1
            TooltipStroke.Transparency = 1
            tween(Tooltip, TweenInfo.new(0.12), {BackgroundTransparency = 0.04})
            tween(TooltipStroke, TweenInfo.new(0.12), {Transparency = 0.2})
        end)
    end)
    local leave = frame.MouseLeave:Connect(function()
        hoverStarted = 0
        if Tooltip.Visible then
            tween(Tooltip, TweenInfo.new(0.1), {BackgroundTransparency = 1})
            tween(TooltipStroke, TweenInfo.new(0.1), {Transparency = 1})
            task.delay(0.11, function()
                if hoverStarted == 0 then
                    Tooltip.Visible = false
                end
            end)
        end
    end)
    if maid then
        maid:Give(enter)
        maid:Give(leave)
    end
end

local function updateTooltipPosition()
    if not Tooltip.Visible then
        return
    end
    local mouse = getMousePosition()
    local screen = viewportSize()
    local size = Tooltip.AbsoluteSize
    local x = math.min(mouse.X + 16, screen.X - size.X - 8)
    local y = math.min(mouse.Y + 18, screen.Y - size.Y - 8)
    Tooltip.Position = UDim2.fromOffset(math.max(8, x), math.max(8, y))
end

local function makeControlBase(group, config, height)
    config = type(config) == "table" and config or {Text = tostring(config or "")}
    local maid = Maid.new()
    local frame = instance("Frame", {
        Name = tostring(config.Flag or config.Text or config.Name or "Control"),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or config.Height or 34),
        Visible = config.Visible ~= false,
        ZIndex = group.Content.ZIndex + 1
    }, group.Content)
    maid:Give(frame)
    registerTooltip(frame, config.Tooltip, maid)
    local control = {
        Type = "Base",
        Flag = config.Flag,
        Text = tostring(config.Text or config.Name or ""),
        Callback = config.Callback,
        Frame = frame,
        Maid = maid,
        Parent = group
    }
    function control:SetVisible(value)
        self.Frame.Visible = value == true
        return self
    end
    function control:Destroy()
        if self.Close then
            pcall(function()
                self:Close()
            end)
        end
        if self.Flag then
            DXForgeExecute.Flags[self.Flag] = nil
            DXForgeExecute.Controls[self.Flag] = nil
        end
        if self.Parent and self.Parent.Controls then
            for i, item in ipairs(self.Parent.Controls) do
                if item == self then
                    table.remove(self.Parent.Controls, i)
                    break
                end
            end
        end
        self.Maid:Destroy()
    end
    function control:GetValue()
        return self.Value
    end
    function control:SetValue(value, silent)
        self.Value = value
        if not silent then
            safeCall(self.Callback, value)
        end
        return self
    end
    if config.Flag then
        DXForgeExecute.Controls[config.Flag] = control
    end
    if group.Controls then
        table.insert(group.Controls, control)
    end
    group:_refresh()
    return control, config
end

local function registerFlag(control, value)
    if control.Flag then
        DXForgeExecute.Flags[control.Flag] = value
    end
end

local function applyButtonFeedback(button, maid)
    local enter = button.MouseEnter:Connect(function()
        tween(button, TweenInfo.new(0.12), {BackgroundTransparency = 0})
        setThemeProps(button, {BackgroundColor3 = "AccentSoft", TextColor3 = "Text"})
    end)
    local leave = button.MouseLeave:Connect(function()
        setThemeProps(button, {BackgroundColor3 = "SurfaceLight", TextColor3 = "Text"})
    end)
    if maid then
        maid:Give(enter)
        maid:Give(leave)
    end
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Group = {}
Group.__index = Group

local function resizeCanvas(scroller)
    local layout = scroller:FindFirstChildOfClass("UIListLayout")
    if layout then
        if layout.FillDirection == Enum.FillDirection.Horizontal then
            scroller.CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X + 12, 0)
        else
            scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
        end
    end
end

function Group:_refresh()
    task.defer(function()
        if self.Content then
            resizeCanvas(self.Content)
        end
    end)
end

function Group:AddLabel(config)
    local control, cfg = makeControlBase(self, config, 26)
    control.Type = "Label"
    local text = label(control.Frame, cfg.Text or cfg.Name or "", 13, false, control.Frame.ZIndex + 1)
    text.TextWrapped = false
    control.Label = text
    control.Value = text.Text
    function control:SetValue(value)
        self.Value = tostring(value or "")
        self.Label.Text = self.Value
        registerFlag(self, self.Value)
        return self
    end
    registerFlag(control, control.Value)
    return control
end

function Group:AddParagraph(config)
    local initial = type(config) == "table" and config or {}
    local control, cfg = makeControlBase(self, config, initial.Height or 62)
    control.Type = "Paragraph"
    local title = label(control.Frame, cfg.Text or cfg.Name or "", 13, true, control.Frame.ZIndex + 1)
    title.Size = UDim2.new(1, 0, 0, 20)
    local body = label(control.Frame, cfg.Content or cfg.Description or cfg.Value or "", 12, false, control.Frame.ZIndex + 1)
    body.Position = UDim2.fromOffset(0, 20)
    body.Size = UDim2.new(1, 0, 1, -20)
    body.TextWrapped = true
    bindTheme(body, {TextColor3 = "TextMuted"})
    control.Body = body
    control.Value = body.Text
    function control:SetValue(value)
        self.Value = tostring(value or "")
        self.Body.Text = self.Value
        registerFlag(self, self.Value)
        return self
    end
    registerFlag(control, control.Value)
    return control
end

function Group:AddDivider(config)
    local text = type(config) == "table" and (config.Text or config.Name) or config
    local control = makeControlBase(self, {Text = text or ""}, 20)
    control.Type = "Divider"
    local line = instance("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = control.Frame.ZIndex + 1
    }, control.Frame)
    bindTheme(line, {BackgroundColor3 = "Border"})
    if text and tostring(text) ~= "" then
        local chip = label(control.Frame, tostring(text), 11, false, control.Frame.ZIndex + 2)
        chip.AnchorPoint = Vector2.new(0.5, 0.5)
        chip.AutomaticSize = Enum.AutomaticSize.X
        chip.BackgroundTransparency = 0
        chip.Position = UDim2.fromScale(0.5, 0.5)
        chip.Size = UDim2.fromOffset(0, 18)
        bindTheme(chip, {BackgroundColor3 = "Surface", TextColor3 = "TextMuted"})
        instance("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, chip)
    end
    return control
end

function Group:AddButton(config)
    local control, cfg = makeControlBase(self, config, 34)
    control.Type = "Button"
    local button = buttonBase(control.Frame, cfg.Text or cfg.Name or "Button")
    applyButtonFeedback(button, control.Maid)
    local debounce = tonumber(cfg.Debounce) or 0
    local last = 0
    control.Button = button
    control.Value = false
    control.Maid:Give(button.MouseButton1Click:Connect(function()
        if debounce > 0 and now() - last < debounce then
            return
        end
        last = now()
        safeCall(control.Callback)
    end))
    function control:SetValue(value, silent)
        self.Value = value
        registerFlag(self, value)
        if not silent and value then
            safeCall(self.Callback)
        end
        return self
    end
    registerFlag(control, false)
    return control
end

function Group:AddToggle(config)
    local control, cfg = makeControlBase(self, config, 36)
    control.Type = "Toggle"
    control.Value = cfg.Default == true
    local name = label(control.Frame, cfg.Text or cfg.Name or "Toggle", 13, false, control.Frame.ZIndex + 1)
    name.Size = UDim2.new(1, -56, 1, 0)
    local hit = instance("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = control.Frame.ZIndex + 3
    }, control.Frame)
    local track = instance("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(42, 22),
        ZIndex = control.Frame.ZIndex + 1
    }, control.Frame)
    bindTheme(track, {BackgroundColor3 = "SurfaceLight"})
    addCorner(track, 11)
    addStroke(track, "Border", 0.25)
    local knob = instance("Frame", {
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(16, 16),
        ZIndex = track.ZIndex + 1
    }, track)
    bindTheme(knob, {BackgroundColor3 = "TextMuted"})
    addCorner(knob, 8)
    local function draw()
        if control.Value then
            setThemeProps(track, {BackgroundColor3 = "AccentSoft"})
            setThemeProps(knob, {BackgroundColor3 = "Accent"})
            tween(knob, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {Position = UDim2.fromOffset(23, 3)})
        else
            setThemeProps(track, {BackgroundColor3 = "SurfaceLight"})
            setThemeProps(knob, {BackgroundColor3 = "TextMuted"})
            tween(knob, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {Position = UDim2.fromOffset(3, 3)})
        end
    end
    function control:SetValue(value, silent)
        self.Value = value == true
        registerFlag(self, self.Value)
        draw()
        if not silent then
            safeCall(self.Callback, self.Value)
        end
        return self
    end
    control.Maid:Give(hit.MouseButton1Click:Connect(function()
        control:SetValue(not control.Value)
    end))
    control.Maid:Give(DXForgeExecute.Events.ThemeChanged:Connect(draw))
    local key = keyFromAny(cfg.Keybind)
    if key and UserInputService then
        control.Maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
            if processed or DXForgeExecute._focusedTextbox then
                return
            end
            if input.KeyCode == key or input.UserInputType == key then
                control:SetValue(not control.Value)
            end
        end))
    end
    draw()
    registerFlag(control, control.Value)
    return control
end

local function makeSliderVisual(parent, z)
    local rail = instance("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -4),
        Size = UDim2.new(1, 0, 0, 5),
        ZIndex = z
    }, parent)
    bindTheme(rail, {BackgroundColor3 = "SurfaceDark"})
    addCorner(rail, 4)
    local fill = instance("Frame", {
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        ZIndex = z + 1
    }, rail)
    bindTheme(fill, {BackgroundColor3 = "Accent"})
    addCorner(fill, 4)
    return rail, fill
end

function Group:AddSlider(config)
    local control, cfg = makeControlBase(self, config, 48)
    control.Type = "Slider"
    local min = tonumber(cfg.Min) or 0
    local max = tonumber(cfg.Max) or 100
    local step = tonumber(cfg.Step) or 1
    local precision = cfg.Precision
    if precision == nil and step < 1 then
        local s = tostring(step)
        precision = #(s:match("%.(%d+)") or "")
    end
    local suffix = tostring(cfg.Suffix or "")
    local title = label(control.Frame, cfg.Text or cfg.Name or "Slider", 13, false, control.Frame.ZIndex + 1)
    title.Size = UDim2.new(1, -90, 0, 24)
    local valueText = label(control.Frame, "", 12, true, control.Frame.ZIndex + 1)
    valueText.AnchorPoint = Vector2.new(1, 0)
    valueText.Position = UDim2.new(1, 0, 0, 0)
    valueText.Size = UDim2.fromOffset(86, 24)
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    bindTheme(valueText, {TextColor3 = "Accent"})
    local rail, fill = makeSliderVisual(control.Frame, control.Frame.ZIndex + 1)
    local dragging = false
    local function pctFromValue(value)
        return (value - min) / math.max(1e-6, max - min)
    end
    local function setFromX(x, silent)
        local pos = rail.AbsolutePosition.X
        local width = math.max(1, rail.AbsoluteSize.X)
        local pct = clamp((x - pos) / width, 0, 1)
        control:SetValue(min + (max - min) * pct, silent)
    end
    function control:SetValue(value, silent)
        value = roundToStep(clamp(tonumber(value) or min, min, max), step, precision)
        self.Value = value
        registerFlag(self, value)
        valueText.Text = tostring(value) .. suffix
        tween(fill, TweenInfo.new(0.08), {Size = UDim2.fromScale(pctFromValue(value), 1)})
        if not silent then
            safeCall(self.Callback, value)
        end
        return self
    end
    local hit = instance("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = control.Frame.ZIndex + 4
    }, control.Frame)
    control.Maid:Give(hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end))
    if UserInputService then
        control.Maid:Give(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                setFromX(input.Position.X)
            end
        end))
        control.Maid:Give(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
    end
    control:SetValue(cfg.Default ~= nil and cfg.Default or min, true)
    return control
end

local function createPopup(control, height)
    if DXForgeExecute._openDropdown and DXForgeExecute._openDropdown ~= control then
        DXForgeExecute._openDropdown:Close()
    end
    if control.Popup then
        control:Close()
        return nil
    end
    DXForgeExecute._openDropdown = control
    local p = control.Frame.AbsolutePosition
    local s = control.Frame.AbsoluteSize
    local screen = viewportSize()
    local popup = instance("Frame", {
        Name = "Popup",
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(math.min(p.X, screen.X - s.X - 12), math.min(p.Y + s.Y + 4, screen.Y - height - 12)),
        Size = UDim2.fromOffset(s.X, 0),
        ZIndex = 850000
    }, OverlayLayer)
    bindTheme(popup, {BackgroundColor3 = "Surface"})
    addCorner(popup, 7)
    addStroke(popup, "BorderStrong", 0.18)
    control.Popup = popup
    control.PopupMaid = Maid.new()
    control.PopupRefreshMaid = Maid.new()
    tween(popup, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(s.X, height)})
    return popup
end

local function closePopup(control)
    local popup = control.Popup
    if not popup then
        return
    end
    control.Popup = nil
    if DXForgeExecute._openDropdown == control then
        DXForgeExecute._openDropdown = nil
    end
    local popupMaid = control.PopupMaid
    local refreshMaid = control.PopupRefreshMaid
    control.PopupMaid = nil
    control.PopupRefreshMaid = nil
    if refreshMaid then
        refreshMaid:Destroy()
    end
    if popupMaid then
        popupMaid:Destroy()
    end
    tween(popup, TweenInfo.new(0.1), {Size = UDim2.fromOffset(popup.AbsoluteSize.X, 0), BackgroundTransparency = 1})
    task.delay(0.12, function()
        pcall(function()
            popup:Destroy()
        end)
    end)
end

function Group:AddDropdown(config)
    local control, cfg = makeControlBase(self, config, 38)
    control.Type = "Dropdown"
    control.Values = type(cfg.Values) == "table" and cfg.Values or {}
    control.Value = cfg.Default or control.Values[1]
    local title = label(control.Frame, cfg.Text or cfg.Name or "Dropdown", 13, false, control.Frame.ZIndex + 1)
    title.Size = UDim2.new(0.42, -8, 1, 0)
    local button = buttonBase(control.Frame, tostring(control.Value or "Select"))
    button.Position = UDim2.new(0.42, 0, 0, 4)
    button.Size = UDim2.new(0.58, 0, 1, -8)
    button.TextXAlignment = Enum.TextXAlignment.Left
    instance("UIPadding", {PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9)}, button)
    control.Button = button
    function control:Close()
        closePopup(self)
    end
    local function redraw(filter)
        local popup = control.Popup
        if not popup then
            return
        end
        if control.PopupRefreshMaid then
            control.PopupRefreshMaid:Destroy()
            control.PopupRefreshMaid = Maid.new()
        end
        for _, child in ipairs(popup:GetChildren()) do
            if child:IsA("GuiObject") and child.Name ~= "Search" then
                child:Destroy()
            end
        end
        local top = cfg.Search and 36 or 6
        local scroller = instance("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromOffset(0, 0),
            Position = UDim2.fromOffset(6, top),
            ScrollBarThickness = 3,
            Size = UDim2.new(1, -12, 1, -top - 6),
            ZIndex = popup.ZIndex + 1
        }, popup)
        if control.PopupRefreshMaid then
            control.PopupRefreshMaid:Give(scroller)
        end
        instance("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, scroller)
        for _, value in ipairs(control.Values) do
            local text = tostring(value)
            if not filter or filter == "" or string.find(string.lower(text), string.lower(filter), 1, true) then
                local opt = buttonBase(scroller, text, popup.ZIndex + 2)
                opt.Size = UDim2.new(1, -2, 0, 28)
                opt.TextXAlignment = Enum.TextXAlignment.Left
                instance("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, opt)
                if control.PopupRefreshMaid then
                    control.PopupRefreshMaid:Give(opt.MouseButton1Click:Connect(function()
                        control:SetValue(value)
                        control:Close()
                    end))
                end
            end
        end
        task.defer(function()
            resizeCanvas(scroller)
        end)
    end
    function control:Open()
        local popup = createPopup(self, cfg.Search and 220 or 184)
        if not popup then
            return
        end
        if cfg.Search then
            local search = instance("TextBox", {
                Name = "Search",
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                Font = Enum.Font.Gotham,
                PlaceholderText = "Search...",
                Text = "",
                TextSize = 12,
                Position = UDim2.fromOffset(6, 6),
                Size = UDim2.new(1, -12, 0, 26),
                ZIndex = popup.ZIndex + 1
            }, popup)
            bindTheme(search, {BackgroundColor3 = "SurfaceLight", TextColor3 = "Text", PlaceholderColor3 = "TextMuted"})
            addCorner(search, 5)
            addStroke(search, "Border", 0.25)
            if control.PopupMaid then
                control.PopupMaid:Give(search:GetPropertyChangedSignal("Text"):Connect(function()
                    redraw(search.Text)
                end))
            end
        end
        redraw("")
    end
    function control:SetValue(value, silent)
        self.Value = value
        self.Button.Text = tostring(value or "Select")
        registerFlag(self, value)
        if not silent then
            safeCall(self.Callback, value)
        end
        return self
    end
    function control:Refresh(values, default)
        self.Values = type(values) == "table" and values or {}
        if default ~= nil then
            self:SetValue(default, true)
        elseif self.Value == nil then
            self:SetValue(self.Values[1], true)
        end
        return self
    end
    control.Maid:Give(button.MouseButton1Click:Connect(function()
        if control.Popup then
            control:Close()
        else
            control:Open()
        end
    end))
    control:SetValue(control.Value, true)
    return control
end

function Group:AddMultiDropdown(config)
    local control = self:AddDropdown(config)
    local cfg = type(config) == "table" and config or {}
    control.Type = "MultiDropdown"
    local selected = {}
    if type(cfg.Default) == "table" then
        for _, value in ipairs(cfg.Default) do
            selected[tostring(value)] = true
        end
    end
    local function selectedList()
        local list = {}
        for _, value in ipairs(control.Values) do
            if selected[tostring(value)] then
                table.insert(list, value)
            end
        end
        return list
    end
    local function updateButton()
        local list = selectedList()
        control.Value = list
        control.Button.Text = #list > 0 and table.concat(list, ", ") or "None"
        registerFlag(control, list)
    end
    function control:SetValue(values, silent)
        selected = {}
        if type(values) == "table" then
            for _, value in ipairs(values) do
                selected[tostring(value)] = true
            end
        end
        updateButton()
        if not silent then
            safeCall(self.Callback, selectedList())
        end
        return self
    end
    function control:Open()
        local popup = createPopup(self, 190)
        if not popup then
            return
        end
        local scroller = instance("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromOffset(0, 0),
            Position = UDim2.fromOffset(6, 6),
            ScrollBarThickness = 3,
            Size = UDim2.new(1, -12, 1, -12),
            ZIndex = popup.ZIndex + 1
        }, popup)
        instance("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, scroller)
        for _, value in ipairs(self.Values) do
            local opt = buttonBase(scroller, tostring(value), popup.ZIndex + 2)
            opt.Size = UDim2.new(1, -2, 0, 28)
            opt.TextXAlignment = Enum.TextXAlignment.Left
            instance("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, opt)
            local function paint()
                setThemeProps(opt, {BackgroundColor3 = selected[tostring(value)] and "AccentSoft" or "SurfaceLight", TextColor3 = "Text"})
            end
            paint()
            if self.PopupMaid then
                self.PopupMaid:Give(opt.MouseButton1Click:Connect(function()
                    selected[tostring(value)] = not selected[tostring(value)]
                    if not selected[tostring(value)] then
                        selected[tostring(value)] = nil
                    end
                    updateButton()
                    paint()
                    safeCall(self.Callback, selectedList())
                end))
            end
        end
        task.defer(function()
            resizeCanvas(scroller)
        end)
    end
    control:SetValue(cfg.Default or {}, true)
    return control
end

function Group:AddTextbox(config)
    local control, cfg = makeControlBase(self, config, 38)
    control.Type = "Textbox"
    local title = label(control.Frame, cfg.Text or cfg.Name or "Textbox", 13, false, control.Frame.ZIndex + 1)
    title.Size = UDim2.new(0.42, -8, 1, 0)
    local box = instance("TextBox", {
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderText = tostring(cfg.Placeholder or ""),
        Text = tostring(cfg.Default or ""),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0.42, 0, 0, 4),
        Size = UDim2.new(0.58, cfg.ClearButton == false and 0 or -30, 1, -8),
        ZIndex = control.Frame.ZIndex + 1
    }, control.Frame)
    bindTheme(box, {BackgroundColor3 = "SurfaceLight", TextColor3 = "Text", PlaceholderColor3 = "TextMuted"})
    addCorner(box, 6)
    addStroke(box, "Border", 0.25)
    instance("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, box)
    control.Box = box
    function control:SetValue(value, silent)
        value = tostring(value or "")
        if cfg.NumericOnly then
            value = value:gsub("[^%d%.%-]", "")
        end
        self.Value = value
        self.Box.Text = value
        registerFlag(self, value)
        if not silent then
            safeCall(self.Callback, value)
        end
        return self
    end
    control.Maid:Give(box.Focused:Connect(function()
        DXForgeExecute._focusedTextbox = control
    end))
    control.Maid:Give(box.FocusLost:Connect(function()
        if DXForgeExecute._focusedTextbox == control then
            DXForgeExecute._focusedTextbox = nil
        end
        control:SetValue(box.Text)
    end))
    if cfg.ClearButton ~= false then
        local clear = buttonBase(control.Frame, "x")
        clear.AnchorPoint = Vector2.new(1, 0)
        clear.Position = UDim2.new(1, 0, 0, 4)
        clear.Size = UDim2.fromOffset(26, control.Frame.Size.Y.Offset - 8)
        control.Maid:Give(clear.MouseButton1Click:Connect(function()
            control:SetValue("")
        end))
    end
    control:SetValue(cfg.Default or "", true)
    return control
end

function Group:AddKeybind(config)
    local control, cfg = makeControlBase(self, config, 38)
    control.Type = "Keybind"
    control.Key = keyFromAny(cfg.Default or cfg.Key) or Enum.KeyCode.Unknown
    control.Mode = cfg.Mode == "Hold" and "Hold" or (cfg.Mode == "Always" and "Always" or "Toggle")
    control.State = control.Mode == "Always"
    local title = label(control.Frame, cfg.Text or cfg.Name or "Keybind", 13, false, control.Frame.ZIndex + 1)
    title.Size = UDim2.new(0.45, -8, 1, 0)
    local button = buttonBase(control.Frame, keyName(control.Key))
    button.Position = UDim2.new(0.45, 0, 0, 4)
    button.Size = UDim2.new(0.35, -4, 1, -8)
    local mode = buttonBase(control.Frame, control.Mode)
    mode.Position = UDim2.new(0.8, 4, 0, 4)
    mode.Size = UDim2.new(0.2, -4, 1, -8)
    function control:SetKey(key, silent)
        self.Key = keyFromAny(key) or self.Key
        button.Text = keyName(self.Key)
        self.Value = {Key = keyName(self.Key), Mode = self.Mode}
        registerFlag(self, self.Value)
        if not silent then
            safeCall(self.Callback, self.Key, self.State)
        end
        return self
    end
    function control:SetValue(value, silent)
        if type(value) == "table" then
            if value.Mode then
                self.Mode = value.Mode
                mode.Text = self.Mode
            end
            return self:SetKey(value.Key or value[1], silent)
        end
        return self:SetKey(value, silent)
    end
    control.Maid:Give(button.MouseButton1Click:Connect(function()
        DXForgeExecute._capturingKeybind = control
        button.Text = "..."
    end))
    control.Maid:Give(mode.MouseButton1Click:Connect(function()
        if control.Mode == "Toggle" then
            control.Mode = "Hold"
        elseif control.Mode == "Hold" then
            control.Mode = "Always"
            control.State = true
        else
            control.Mode = "Toggle"
            control.State = false
        end
        mode.Text = control.Mode
        control:SetKey(control.Key, true)
    end))
    if UserInputService then
        control.Maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
            if processed or DXForgeExecute._focusedTextbox then
                return
            end
            local inputKey = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
            if DXForgeExecute._capturingKeybind == control then
                DXForgeExecute._capturingKeybind = nil
                control:SetKey(inputKey)
                return
            end
            if inputKey == control.Key then
                if control.Mode == "Toggle" then
                    control.State = not control.State
                elseif control.Mode == "Hold" then
                    control.State = true
                else
                    control.State = true
                end
                safeCall(control.Callback, control.Key, control.State)
            end
        end))
        control.Maid:Give(UserInputService.InputEnded:Connect(function(input)
            local inputKey = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
            if inputKey == control.Key and control.Mode == "Hold" then
                control.State = false
                safeCall(control.Callback, control.Key, false)
            end
        end))
    end
    control:SetKey(control.Key, true)
    return control
end

function Group:AddColorPicker(config)
    local control, cfg = makeControlBase(self, config, 40)
    control.Type = "ColorPicker"
    control.Alpha = cfg.Alpha == true
    control.Color = parseColor(cfg.Default, theme().Accent)
    control.AlphaValue = type(cfg.Default) == "table" and (cfg.Default[4] or cfg.Default.a) or 1
    local title = label(control.Frame, cfg.Text or cfg.Name or "Color", 13, false, control.Frame.ZIndex + 1)
    title.Size = UDim2.new(1, -62, 1, 0)
    local preview = buttonBase(control.Frame, "")
    preview.AnchorPoint = Vector2.new(1, 0.5)
    preview.Position = UDim2.new(1, 0, 0.5, 0)
    preview.Size = UDim2.fromOffset(46, 24)
    control.Preview = preview
    local function commit(silent)
        preview.BackgroundColor3 = control.Color
        control.Value = colorToTable(control.Color, control.Alpha and control.AlphaValue or nil)
        registerFlag(control, control.Value)
        if cfg.ThemeKey then
            DXForgeExecute:SetThemeColor(cfg.ThemeKey, control.Color)
        elseif cfg.ApplyToTheme or cfg.ApplyTheme then
            DXForgeExecute:SetThemeColor("Accent", control.Color)
        end
        if not silent then
            safeCall(control.Callback, control.Value)
        end
    end
    local function popupSlider(parent, name, value, changed)
        local row = instance("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), ZIndex = parent.ZIndex + 1}, parent)
        local l = label(row, name, 12, false, row.ZIndex + 1)
        l.Size = UDim2.new(0, 28, 1, 0)
        local rail, fill = makeSliderVisual(row, row.ZIndex + 1)
        rail.Position = UDim2.new(0, 34, 1, -8)
        rail.Size = UDim2.new(1, -34, 0, 5)
        fill.Size = UDim2.fromScale(value, 1)
        local drag = false
        local function set(x)
            local pct = clamp((x - rail.AbsolutePosition.X) / math.max(1, rail.AbsoluteSize.X), 0, 1)
            fill.Size = UDim2.fromScale(pct, 1)
            changed(pct)
        end
        if control.PopupMaid then
            control.PopupMaid:Give(row.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    drag = true
                    set(input.Position.X)
                end
            end))
            control.PopupMaid:Give(row.InputChanged:Connect(function(input)
                if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    set(input.Position.X)
                end
            end))
            control.PopupMaid:Give(row.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    drag = false
                end
            end))
        end
    end
    function control:Close()
        closePopup(self)
    end
    function control:Open()
        local popup = createPopup(self, self.Alpha and 180 or 142)
        if not popup then
            return
        end
        local content = instance("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 8),
            Size = UDim2.new(1, -20, 1, -16),
            ZIndex = popup.ZIndex + 1
        }, popup)
        local h, s, v = control.Color:ToHSV()
        popupSlider(content, "H", h, function(p)
            h = p
            control.Color = Color3.fromHSV(h, s, v)
            commit()
        end)
        popupSlider(content, "S", s, function(p)
            s = p
            control.Color = Color3.fromHSV(h, s, v)
            commit()
        end)
        popupSlider(content, "V", v, function(p)
            v = p
            control.Color = Color3.fromHSV(h, s, v)
            commit()
        end)
        if self.Alpha then
            popupSlider(content, "A", tonumber(control.AlphaValue) or 1, function(p)
                control.AlphaValue = p
                commit()
            end)
        end
        instance("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, content)
    end
    function control:SetValue(value, silent)
        self.Color = parseColor(value, self.Color)
        if type(value) == "table" and value[4] then
            self.AlphaValue = value[4]
        end
        commit(silent)
        return self
    end
    function control:GetValue()
        return self.Value
    end
    control.Maid:Give(preview.MouseButton1Click:Connect(function()
        if control.Popup then
            control:Close()
        else
            control:Open()
        end
    end))
    commit(true)
    return control
end

function Group:Destroy()
    if self.Controls then
        for i = #self.Controls, 1, -1 do
            local control = self.Controls[i]
            if control and control.Destroy then
                control:Destroy()
            end
        end
    end
    if self.Maid then
        self.Maid:Destroy()
    elseif self.Frame then
        pcall(function()
            self.Frame:Destroy()
        end)
    end
end

function Tab:_layoutGroups()
    local hasFull = false
    for _, group in ipairs(self.Groups) do
        local side = group.Side
        local column = side == "right" and self.RightColumn or self.LeftColumn
        if side == "full" or side == "middle" then
            column = self.FullColumn
            hasFull = true
        end
        group.Frame.Parent = column
    end
    self.FullColumn.Visible = hasFull
end

function Tab:Destroy()
    for i = #self.Groups, 1, -1 do
        local group = self.Groups[i]
        if group and group.Destroy then
            group:Destroy()
        end
    end
    if self.Maid then
        self.Maid:Destroy()
    else
        if self.Button then
            pcall(function()
                self.Button:Destroy()
            end)
        end
        if self.Page then
            pcall(function()
                self.Page:Destroy()
            end)
        end
    end
end

function Tab:AddGroupbox(name, side)
    side = tostring(side or "left"):lower()
    if side == "middle" then
        side = "full"
    end
    local maid = Maid.new()
    local frame = instance("Frame", {
        Name = tostring(name or "Groupbox"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 230),
        ZIndex = self.Page.ZIndex + 1
    })
    maid:Give(frame)
    bindTheme(frame, {BackgroundColor3 = "Surface"})
    addCorner(frame, 8)
    addStroke(frame, "Border", 0.2)
    local header = label(frame, tostring(name or "Groupbox"), 13, true, frame.ZIndex + 1)
    header.Position = UDim2.fromOffset(12, 0)
    header.Size = UDim2.new(1, -24, 0, 34)
    bindTheme(header, {TextColor3 = "Text"})
    local content = instance("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ClipsDescendants = true,
        Position = UDim2.fromOffset(12, 36),
        ScrollBarThickness = 3,
        Size = UDim2.new(1, -24, 1, -46),
        ZIndex = frame.ZIndex + 1
    }, frame)
    local layout = instance("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, content)
    maid:Give(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        resizeCanvas(content)
        frame.Size = UDim2.new(1, 0, 0, math.max(104, layout.AbsoluteContentSize.Y + 52))
    end))
    local group = setmetatable({
        Name = tostring(name or "Groupbox"),
        Side = side,
        Frame = frame,
        Content = content,
        Tab = self,
        Maid = maid,
        Controls = {}
    }, Group)
    table.insert(self.Groups, group)
    self:_layoutGroups()
    return group
end

function Tab:AddSection(name, side)
    return self:AddGroupbox(name, side)
end

function Tab:Focus()
    self.Window.SelectedTab = self
    for _, tab in ipairs(self.Window.Tabs) do
        tab.Page.Visible = tab == self
        setThemeProps(tab.Button, {BackgroundColor3 = tab == self and "AccentSoft" or "Surface", TextColor3 = tab == self and "Text" or "TextMuted"})
    end
    return self
end

function Window:_applyResponsiveLayout()
    local compact = self.CompactMode == true or self.Size[1] <= 560
    local stacked = compact or self.Size[1] <= 640
    self.IsCompact = compact
    self.IsStacked = stacked
    if self.Sidebar then
        if compact then
            self.Sidebar.Position = UDim2.fromOffset(10, 52)
            self.Sidebar.Size = UDim2.new(1, -20, 0, 48)
        else
            self.Sidebar.Position = UDim2.fromOffset(10, 52)
            self.Sidebar.Size = UDim2.new(0, 132, 1, -64)
        end
    end
    if self.TabList then
        self.TabList.Position = UDim2.fromOffset(8, 8)
        self.TabList.Size = UDim2.new(1, -16, 1, -16)
        self.TabList.ScrollingDirection = compact and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y
        resizeCanvas(self.TabList)
    end
    if self.TabLayout then
        self.TabLayout.FillDirection = compact and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
        self.TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        self.TabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    end
    for _, tab in ipairs(self.Tabs) do
        if compact then
            tab.Button.Size = UDim2.fromOffset(118, 32)
            tab.Page.Position = UDim2.fromOffset(10, 110)
            tab.Page.Size = UDim2.new(1, -20, 1, -122)
        else
            tab.Button.Size = UDim2.new(1, 0, 0, 32)
            tab.Page.Position = UDim2.fromOffset(152, 52)
            tab.Page.Size = UDim2.new(1, -164, 1, -64)
        end
        if tab.LeftColumn and tab.RightColumn and tab.FullColumn then
            if stacked then
                tab.LeftColumn.Size = UDim2.new(1, 0, 0.5, -5)
                tab.LeftColumn.Position = UDim2.fromOffset(0, 0)
                tab.RightColumn.Size = UDim2.new(1, 0, 0.5, -5)
                tab.RightColumn.Position = UDim2.new(0, 0, 0.5, 5)
                tab.FullColumn.Size = UDim2.fromScale(1, 1)
                tab.FullColumn.Position = UDim2.fromOffset(0, 0)
            else
                tab.LeftColumn.Size = UDim2.new(0.5, -5, 1, 0)
                tab.LeftColumn.Position = UDim2.fromOffset(0, 0)
                tab.RightColumn.Size = UDim2.new(0.5, -5, 1, 0)
                tab.RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
                tab.FullColumn.Size = UDim2.fromScale(1, 1)
                tab.FullColumn.Position = UDim2.fromOffset(0, 0)
            end
            resizeCanvas(tab.LeftColumn)
            resizeCanvas(tab.RightColumn)
            resizeCanvas(tab.FullColumn)
        end
    end
    return self
end

function Window:BringToFront()
    DXForgeExecute._z = DXForgeExecute._z + 10
    self.Frame.ZIndex = DXForgeExecute._z
    self.Shadow.ZIndex = self.Frame.ZIndex - 1
    return self
end

function Window:SetOpen(value)
    self.Open = value == true
    self.Frame.Visible = self.Open
    self.Shadow.Visible = self.Open
    if self.Open then
        self:BringToFront()
        self.Frame.BackgroundTransparency = 1
        tween(self.Frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0})
    end
    return self
end

function Window:Toggle()
    return self:SetOpen(not self.Open)
end

function Window:Resize(width, height)
    width = clamp(tonumber(width) or self.Size[1], self.MinSize[1], self.MaxSize[1])
    height = clamp(tonumber(height) or self.Size[2], self.MinSize[2], self.MaxSize[2])
    self.Size = {width, height}
    self.Frame.Size = UDim2.fromOffset(width, height)
    self.Shadow.Size = UDim2.new(0, width + 16, 0, height + 16)
    self:_applyResponsiveLayout()
    self:SetPosition(self.Position)
    return self
end

function Window:SetSize(size)
    size = parseVec2(size, self.Size)
    return self:Resize(size[1], size[2])
end

function Window:SetPosition(pos)
    pos = parseVec2(pos, self.Position)
    local screen = viewportSize()
    pos[1] = clamp(pos[1], 6, math.max(6, screen.X - self.Size[1] - 6))
    pos[2] = clamp(pos[2], 6, math.max(6, screen.Y - self.Size[2] - 6))
    self.Position = pos
    self.Frame.Position = UDim2.fromOffset(pos[1], pos[2])
    self.Shadow.Position = UDim2.fromOffset(pos[1] + self.Size[1] / 2, pos[2] + self.Size[2] / 2)
    return self
end

function Window:AddTab(name, icon)
    local maid = Maid.new()
    local button = buttonBase(self.TabList, (icon and (tostring(icon) .. " ") or "") .. tostring(name or "Tab"), self.Frame.ZIndex + 4)
    maid:Give(button)
    button.Size = UDim2.new(1, 0, 0, 32)
    button.TextXAlignment = Enum.TextXAlignment.Left
    instance("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8)}, button)
    local page = instance("Frame", {
        Name = tostring(name or "Tab"),
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(152, 52),
        Size = UDim2.new(1, -164, 1, -64),
        Visible = false,
        ZIndex = self.Frame.ZIndex + 2
    }, self.Frame)
    maid:Give(page)
    local columns = instance("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = page.ZIndex + 1
    }, page)
    local left = instance("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 0,
        Size = UDim2.new(0.5, -5, 1, 0),
        ZIndex = columns.ZIndex + 1
    }, columns)
    local right = instance("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        Position = UDim2.new(0.5, 5, 0, 0),
        ScrollBarThickness = 0,
        Size = UDim2.new(0.5, -5, 1, 0),
        ZIndex = columns.ZIndex + 1
    }, columns)
    local full = instance("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ScrollBarThickness = 0,
        ZIndex = columns.ZIndex + 2
    }, columns)
    for _, scroller in ipairs({left, right, full}) do
        local layout = instance("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, scroller)
        maid:Give(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            resizeCanvas(scroller)
        end))
    end
    local tab = setmetatable({
        Name = tostring(name or "Tab"),
        Window = self,
        Button = button,
        Page = page,
        Groups = {},
        LeftColumn = left,
        RightColumn = right,
        FullColumn = full,
        Maid = maid
    }, Tab)
    table.insert(self.Tabs, tab)
    maid:Give(button.MouseButton1Click:Connect(function()
        tab:Focus()
    end))
    self:_applyResponsiveLayout()
    if not self.SelectedTab then
        tab:Focus()
    end
    return tab
end

function Window:Destroy()
    for i, win in ipairs(DXForgeExecute.Windows) do
        if win == self then
            table.remove(DXForgeExecute.Windows, i)
            break
        end
    end
    for i = #self.Tabs, 1, -1 do
        local tab = self.Tabs[i]
        if tab and tab.Destroy then
            tab:Destroy()
        end
    end
    self.Maid:Destroy()
end

local function makeWindow(config)
    config = type(config) == "table" and config or {}
    if config.Theme then
        DXForgeExecute:SetTheme(config.Theme)
    end
    local size = parseVec2(config.Size, {620, 520})
    local minSize = parseVec2(config.MinSize, {420, 320})
    local maxSize = parseVec2(config.MaxSize, {1200, 900})
    local screen = viewportSize()
    local pos = parseVec2(config.Position or config.StartLocation, {math.floor((screen.X - size[1]) / 2), math.floor((screen.Y - size[2]) / 2)})
    local maid = Maid.new()
    local shadow = makeShadow(WindowLayer, DXForgeExecute._z - 1)
    local frame = instance("Frame", {
        Name = tostring(config.Title or "DXForgeExecute Window"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(pos[1], pos[2]),
        Size = UDim2.fromOffset(size[1], size[2]),
        ZIndex = DXForgeExecute._z
    }, WindowLayer)
    bindTheme(frame, {BackgroundColor3 = "Background"})
    addCorner(frame, 10)
    addStroke(frame, "BorderStrong", 0.1)
    shadow.Position = UDim2.fromOffset(pos[1] + size[1] / 2, pos[2] + size[2] / 2)
    shadow.Size = UDim2.new(0, size[1] + 16, 0, size[2] + 16)
    maid:Give(frame)
    maid:Give(shadow)
    local header = instance("Frame", {
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        ZIndex = frame.ZIndex + 1
    }, frame)
    bindTheme(header, {BackgroundColor3 = "Surface"})
    local title = label(header, config.Title or "DXForgeExecute", 15, true, header.ZIndex + 1)
    title.Position = UDim2.fromOffset(16, 0)
    title.Size = UDim2.new(1, -86, 1, 0)
    local close = buttonBase(header, "-", header.ZIndex + 2)
    close.AnchorPoint = Vector2.new(1, 0.5)
    close.Position = UDim2.new(1, -12, 0.5, 0)
    close.Size = UDim2.fromOffset(28, 24)
    local sidebar = instance("Frame", {
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 52),
        Size = UDim2.new(0, 132, 1, -64),
        ZIndex = frame.ZIndex + 1
    }, frame)
    bindTheme(sidebar, {BackgroundColor3 = "Surface"})
    addCorner(sidebar, 8)
    addStroke(sidebar, "Border", 0.3)
    local tabList = instance("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 1, -16),
        ScrollBarThickness = 0,
        ZIndex = sidebar.ZIndex + 1
    }, sidebar)
    local tabLayout = instance("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, tabList)
    maid:Give(tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        resizeCanvas(tabList)
    end))
    local grip = instance("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromScale(1, 1),
        Size = UDim2.fromOffset(26, 26),
        Text = "",
        ZIndex = frame.ZIndex + 20,
        Visible = config.Resizable ~= false
    }, frame)
    local gripLine = instance("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -7, 1, -7),
        Size = UDim2.fromOffset(14, 2),
        Rotation = -45,
        ZIndex = grip.ZIndex + 1
    }, grip)
    bindTheme(gripLine, {BackgroundColor3 = "BorderStrong"})
    local window = setmetatable({
        Title = tostring(config.Title or "DXForgeExecute"),
        Frame = frame,
        Shadow = shadow,
        Header = header,
        Sidebar = sidebar,
        TabList = tabList,
        TabLayout = tabLayout,
        Tabs = {},
        Maid = maid,
        Size = size,
        MinSize = minSize,
        MaxSize = maxSize,
        Position = pos,
        Open = config.Open ~= false,
        CompactMode = config.CompactMode == true or config.Compact == true,
        ToggleKey = keyFromAny(config.ToggleKey)
    }, Window)
    maid:Give(DXForgeExecute.Events.ThemeChanged:Connect(function()
        if window.SelectedTab then
            window.SelectedTab:Focus()
        end
    end))
    maid:Give(close.MouseButton1Click:Connect(function()
        window:Toggle()
    end))
    local drag = false
    local dragStart, startPos
    maid:Give(header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = input.Position
            startPos = Vector2.new(window.Position[1], window.Position[2])
            window:BringToFront()
        end
    end))
    maid:Give(header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end))
    local resizing = false
    local resizeStart, startSize
    maid:Give(grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = Vector2.new(window.Size[1], window.Size[2])
            window:BringToFront()
        end
    end))
    maid:Give(grip.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end))
    if UserInputService then
        maid:Give(UserInputService.InputChanged:Connect(function(input)
            if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                window:SetPosition({startPos.X + delta.X, startPos.Y + delta.Y})
            elseif resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - resizeStart
                window:Resize(startSize.X + delta.X, startSize.Y + delta.Y)
            end
        end))
        if window.ToggleKey then
            maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
                if processed or DXForgeExecute._focusedTextbox then
                    return
                end
                local inputKey = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
                if inputKey == window.ToggleKey then
                    window:Toggle()
                end
            end))
        end
    end
    maid:Give(frame.InputBegan:Connect(function()
        window:BringToFront()
    end))
    table.insert(DXForgeExecute.Windows, window)
    window:_applyResponsiveLayout()
    window:SetOpen(window.Open)
    if config.Startup ~= false then
        DXForgeExecute:_startup(config.StartupDuration)
    end
    return window
end

function DXForgeExecute:SetDebug(value)
    self.Debug = value == true
    return self
end

function DXForgeExecute:RegisterTheme(name, values)
    assert(type(name) == "string" and name ~= "", "theme name must be a non-empty string")
    self.Themes[name] = merge(DEFAULT_THEME, values or {})
    for key, value in pairs(self.Themes[name]) do
        self.Themes[name][key] = parseColor(value, DEFAULT_THEME[key] or Color3.new(1, 1, 1))
    end
    return self
end

function DXForgeExecute:CreateTheme(name, values)
    return self:RegisterTheme(name, values)
end

function DXForgeExecute:SetTheme(name)
    if not self.Themes[name] then
        warnf("Unknown theme: " .. tostring(name))
        return self
    end
    self.ActiveTheme = name
    applyTheme()
    return self
end

function DXForgeExecute:GetTheme(name)
    return copy(self.Themes[name or self.ActiveTheme])
end

function DXForgeExecute:GetThemeNames()
    local names = {}
    for name in pairs(self.Themes) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function DXForgeExecute:SetThemeColor(key, color)
    local active = self.Themes[self.ActiveTheme]
    if active and active[key] then
        active[key] = parseColor(color, active[key])
        applyTheme()
    else
        warnf("Unknown theme token: " .. tostring(key))
    end
    return self
end

function DXForgeExecute:CreateWindow(config)
    return makeWindow(config)
end

function DXForgeExecute:Notify(config)
    config = type(config) == "table" and config or {Text = tostring(config or "")}
    local typ = tostring(config.Type or "Info")
    local token = typ == "Success" and "Success" or typ == "Warning" and "Warning" or typ == "Error" and "Error" or "Accent"
    local maid = Maid.new()
    local card = instance("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 86),
        ZIndex = NotificationLayer.ZIndex + 1
    }, NotificationLayer)
    bindTheme(card, {BackgroundColor3 = "Surface"})
    addCorner(card, 8)
    addStroke(card, "Border", 0.2)
    local accent = instance("Frame", {
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
        ZIndex = card.ZIndex + 1
    }, card)
    bindTheme(accent, {BackgroundColor3 = token})
    local title = label(card, typ, 13, true, card.ZIndex + 1)
    title.Position = UDim2.fromOffset(14, 8)
    title.Size = UDim2.new(1, -46, 0, 20)
    bindTheme(title, {TextColor3 = token})
    local body = label(card, config.Text or "", 12, false, card.ZIndex + 1)
    body.Position = UDim2.fromOffset(14, 30)
    body.Size = UDim2.new(1, -28, 1, -42)
    body.TextWrapped = true
    local progress = instance("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = card.ZIndex + 2
    }, card)
    bindTheme(progress, {BackgroundColor3 = token})
    local close
    local closed = false
    local function remove()
        if closed then
            return
        end
        closed = true
        maid:Cleanup()
        tween(card, TweenInfo.new(0.18), {BackgroundTransparency = 1, Position = UDim2.fromOffset(34, 0)})
        task.delay(0.2, function()
            pcall(function()
                card:Destroy()
            end)
        end)
    end
    if config.ManualClose then
        close = buttonBase(card, "x", card.ZIndex + 3)
        close.AnchorPoint = Vector2.new(1, 0)
        close.Position = UDim2.new(1, -8, 0, 8)
        close.Size = UDim2.fromOffset(22, 22)
        maid:Give(close.MouseButton1Click:Connect(remove))
    end
    tween(card, TweenInfo.new(0.16), {BackgroundTransparency = 0})
    local duration = tonumber(config.Duration or config.Length) or 4
    if not config.ManualClose then
        tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)})
        task.delay(duration, remove)
    end
    return self
end

function DXForgeExecute:_startup(duration)
    if self._startupDone then
        return
    end
    self._startupDone = true
    duration = tonumber(duration) or 1.8
    local splash = instance("Frame", {
        Name = "Startup",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 990000
    }, OverlayLayer)
    local panel = instance("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(360, 150),
        ZIndex = splash.ZIndex + 1
    }, splash)
    bindTheme(panel, {BackgroundColor3 = "Surface"})
    addCorner(panel, 10)
    addStroke(panel, "BorderStrong", 0.25)
    local brand = label(panel, "DXForgeExecute", 24, true, panel.ZIndex + 1)
    brand.Position = UDim2.fromOffset(24, 24)
    brand.Size = UDim2.new(1, -48, 0, 34)
    bindTheme(brand, {TextColor3 = "Text"})
    local sub = label(panel, "Loading interface", 13, false, panel.ZIndex + 1)
    sub.Position = UDim2.fromOffset(24, 62)
    sub.Size = UDim2.new(1, -48, 0, 22)
    bindTheme(sub, {TextColor3 = "TextMuted"})
    local rail = instance("Frame", {
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(24, 106),
        Size = UDim2.new(1, -48, 0, 5),
        ZIndex = panel.ZIndex + 1
    }, panel)
    bindTheme(rail, {BackgroundColor3 = "SurfaceDark"})
    addCorner(rail, 4)
    local fill = instance("Frame", {
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        ZIndex = rail.ZIndex + 1
    }, rail)
    bindTheme(fill, {BackgroundColor3 = "Accent"})
    addCorner(fill, 4)
    tween(splash, TweenInfo.new(0.18), {BackgroundTransparency = 0.2})
    tween(panel, TweenInfo.new(0.18), {BackgroundTransparency = 0})
    tween(fill, TweenInfo.new(math.max(0.2, duration - 0.35), Enum.EasingStyle.Quad), {Size = UDim2.fromScale(1, 1)})
    task.delay(duration, function()
        tween(splash, TweenInfo.new(0.22), {BackgroundTransparency = 1})
        tween(panel, TweenInfo.new(0.22), {BackgroundTransparency = 1})
        task.delay(0.25, function()
            pcall(function()
                splash:Destroy()
            end)
        end)
    end)
end

function DXForgeExecute:SetWatermark(config)
    config = type(config) == "table" and config or {}
    if self._watermarkMaid then
        self._watermarkMaid:Destroy()
        self._watermarkMaid = nil
    end
    if self._watermark then
        self._watermark:Destroy()
        self._watermark = nil
    end
    local maid = Maid.new()
    local pos = parseVec2(config.Position, {14, 14})
    local mark = instance("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamSemibold,
        Text = tostring(config.Text or "DXForgeExecute"),
        TextSize = 13,
        Position = UDim2.fromOffset(pos[1], pos[2]),
        Size = UDim2.fromOffset(190, 30),
        Visible = config.Visible ~= false,
        ZIndex = OverlayLayer.ZIndex + 10
    }, OverlayLayer)
    bindTheme(mark, {BackgroundColor3 = "Surface", TextColor3 = "Text"})
    addCorner(mark, 7)
    addStroke(mark, "Border", 0.2)
    self._watermark = mark
    self._watermarkMaid = maid
    maid:Give(mark)
    if config.Draggable then
        local dragging, start, startPos = false
        maid:Give(mark.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                start = input.Position
                startPos = Vector2.new(mark.Position.X.Offset, mark.Position.Y.Offset)
            end
        end))
        maid:Give(mark.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
        if UserInputService then
            maid:Give(UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - start
                    mark.Position = UDim2.fromOffset(startPos.X + delta.X, startPos.Y + delta.Y)
                end
            end))
        end
    end
    return self
end

function DXForgeExecute:SetFOVCircle(config)
    config = type(config) == "table" and config or {}
    if self._fov and typeof(self._fov) == "Instance" then
        pcall(function()
            self._fov:Destroy()
        end)
    elseif self._fov and self._fov.Remove then
        pcall(function()
            self._fov:Remove()
        end)
    end
    self._fovConfig = {
        Visible = config.Visible == true,
        Radius = tonumber(config.Radius) or 90,
        Color = parseColor(config.Color, theme().Accent),
        Thickness = tonumber(config.Thickness) or 1,
        Segments = tonumber(config.Segments) or 96,
        FollowMouse = config.FollowMouse == true,
        Position = config.Position and parseVec2(config.Position, nil) or nil
    }
    if type(Drawing) == "table" and Drawing.new then
        local circle = Drawing.new("Circle")
        circle.Visible = self._fovConfig.Visible
        circle.Radius = self._fovConfig.Radius
        circle.Color = self._fovConfig.Color
        circle.Thickness = self._fovConfig.Thickness
        circle.NumSides = self._fovConfig.Segments
        circle.Filled = false
        self._fov = circle
        RootMaid:Give(function()
            pcall(function()
                circle:Remove()
            end)
        end)
    else
        local circle = instance("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(self._fovConfig.Radius * 2, self._fovConfig.Radius * 2),
            Visible = self._fovConfig.Visible,
            ZIndex = OverlayLayer.ZIndex + 20
        }, OverlayLayer)
        addCorner(circle, self._fovConfig.Radius)
        local stroke = addStroke(circle, "Accent", 0)
        stroke.Thickness = self._fovConfig.Thickness
        self._fov = circle
    end
    return self
end

local function updateFOV()
    local cfg = DXForgeExecute._fovConfig
    local obj = DXForgeExecute._fov
    if not cfg or not obj then
        return
    end
    local pos = cfg.Position and Vector2.new(cfg.Position[1], cfg.Position[2]) or getMousePosition()
    if not cfg.FollowMouse and not cfg.Position then
        local screen = viewportSize()
        pos = Vector2.new(screen.X / 2, screen.Y / 2)
    end
    if typeof(obj) == "Instance" then
        obj.Visible = cfg.Visible
        obj.Position = UDim2.fromOffset(pos.X - cfg.Radius, pos.Y - cfg.Radius)
    else
        obj.Visible = cfg.Visible
        obj.Position = pos
        obj.Radius = cfg.Radius
        obj.Color = cfg.Color
        obj.Thickness = cfg.Thickness
        obj.NumSides = cfg.Segments
    end
end

local fileApi = {}
local function detectFileApi()
    fileApi.writefile = type(writefile) == "function" and writefile or nil
    fileApi.readfile = type(readfile) == "function" and readfile or nil
    fileApi.isfile = type(isfile) == "function" and isfile or nil
    fileApi.isfolder = type(isfolder) == "function" and isfolder or nil
    fileApi.makefolder = type(makefolder) == "function" and makefolder or nil
    fileApi.delfile = type(delfile) == "function" and delfile or nil
    fileApi.listfiles = type(listfiles) == "function" and listfiles or nil
end
detectFileApi()

local function pathJoin(folder, file)
    folder = tostring(folder or "DXForgeExecute"):gsub("\\", "/"):gsub("^%s+", ""):gsub("%s+$", ""):gsub("/+$", "")
    folder = folder:gsub("%.%.", ""):gsub("[<>:\"|?*]", "_")
    file = tostring(file or "default.json"):gsub("\\", "/")
    file = file:match("([^/]+)$") or "default.json"
    file = file:gsub("%.%.", ""):gsub("[<>:\"|?*]", "_")
    if file == "" or file == ".json" then
        file = "default.json"
    end
    if not file:match("%.json$") then
        file = file .. ".json"
    end
    if folder == "" then
        folder = "DXForgeExecute"
    end
    return folder .. "/" .. file
end

local function normalizeFolder(folder)
    folder = tostring(folder or "DXForgeExecute"):gsub("\\", "/"):gsub("^%s+", ""):gsub("%s+$", ""):gsub("/+$", "")
    folder = folder:gsub("%.%.", ""):gsub("[<>:\"|?*]", "_")
    if folder == "" then
        folder = "DXForgeExecute"
    end
    return folder
end

function DXForgeExecute:SetConfigFolder(folder)
    self.ConfigFolder = normalizeFolder(folder)
    return self
end

function DXForgeExecute:_ensureFolder(requireWrite)
    detectFileApi()
    if requireWrite and not fileApi.writefile then
        warnf("writefile is unavailable; config saving is disabled.")
        return false
    end
    if not requireWrite and not fileApi.readfile then
        warnf("readfile is unavailable; config loading is disabled.")
        return false
    end
    if not fileApi.writefile and not fileApi.readfile then
        warnf("File APIs are unavailable; config persistence is disabled.")
        return false
    end
    if requireWrite and fileApi.isfolder and fileApi.makefolder then
        local ok, exists = pcall(fileApi.isfolder, self.ConfigFolder)
        if ok and not exists then
            pcall(fileApi.makefolder, self.ConfigFolder)
        end
    end
    return true
end

function DXForgeExecute:_snapshot()
    local windows = {}
    for i, window in ipairs(self.Windows) do
        windows[i] = {
            Title = window.Title,
            Position = window.Position,
            Size = window.Size,
            SelectedTab = window.SelectedTab and window.SelectedTab.Name or nil,
            Open = window.Open
        }
    end
    return {
        Version = self.__VERSION,
        SavedAt = utcTimestamp(),
        Theme = self.ActiveTheme,
        Flags = copy(self.Flags),
        Windows = windows,
        AutoSave = self.AutoSave and {
            File = self.AutoSave.File,
            Interval = self.AutoSave.Interval,
            Enabled = self.AutoSave.Enabled == true
        } or nil
    }
end

function DXForgeExecute:SaveConfig(name)
    if not self:_ensureFolder(true) or not HttpService then
        return false
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(self:_snapshot())
    end)
    if not ok then
        warnf(encoded)
        return false
    end
    local path = pathJoin(self.ConfigFolder, name or "default.json")
    local wrote, err = pcall(fileApi.writefile, path, encoded)
    if not wrote then
        warnf(err)
    end
    return wrote
end

function DXForgeExecute:LoadConfig(name)
    if not self:_ensureFolder(false) or not HttpService then
        return false
    end
    local path = pathJoin(self.ConfigFolder, name or "default.json")
    if fileApi.isfile and not fileApi.isfile(path) then
        warnf("Config not found: " .. path)
        return false
    end
    local ok, raw = pcall(fileApi.readfile, path)
    if not ok then
        warnf(raw)
        return false
    end
    local decodedOk, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not decodedOk or type(data) ~= "table" then
        warnf("Invalid config JSON.")
        return false
    end
    if data.Theme and self.Themes[data.Theme] then
        self:SetTheme(data.Theme)
    end
    if type(data.Flags) == "table" then
        for flag, value in pairs(data.Flags) do
            local control = self.Controls[flag]
            if control and control.SetValue then
                safeCall(function()
                    control:SetValue(value, true)
                end)
            end
        end
    end
    if type(data.Windows) == "table" then
        for i, state in ipairs(data.Windows) do
            local window = self.Windows[i]
            if window then
                if state.Size then
                    window:SetSize(state.Size)
                end
                if state.Position then
                    window:SetPosition(state.Position)
                end
                if state.Open ~= nil then
                    window:SetOpen(state.Open)
                end
                if state.SelectedTab then
                    for _, tab in ipairs(window.Tabs) do
                        if tab.Name == state.SelectedTab then
                            tab:Focus()
                            break
                        end
                    end
                end
            end
        end
    end
    return true
end

function DXForgeExecute:DeleteConfig(name)
    detectFileApi()
    if not fileApi.delfile then
        warnf("Delete file API is unavailable.")
        return false
    end
    local path = pathJoin(self.ConfigFolder, name or "default.json")
    local ok, err = pcall(fileApi.delfile, path)
    if not ok then
        warnf(err)
    end
    return ok
end

function DXForgeExecute:ListConfigs()
    detectFileApi()
    if not fileApi.listfiles then
        warnf("List files API is unavailable.")
        return {}
    end
    local ok, files = pcall(fileApi.listfiles, self.ConfigFolder)
    if not ok or type(files) ~= "table" then
        return {}
    end
    local configs = {}
    for _, file in ipairs(files) do
        local name = tostring(file):match("([^/\\]+)%.json$")
        if name then
            table.insert(configs, name .. ".json")
        end
    end
    table.sort(configs)
    return configs
end

function DXForgeExecute:EnableAutoSave(config)
    config = type(config) == "table" and config or {}
    self.AutoSave = {
        File = pathJoin("", config.File or "default.json"):match("([^/]+)$") or "default.json",
        Interval = math.max(0.25, tonumber(config.Interval) or 2),
        Enabled = true,
        Last = now()
    }
    return self
end

function DXForgeExecute:DisableAutoSave()
    self.AutoSave = nil
    return self
end

function DXForgeExecute:Destroy()
    if not self._alive then
        return self
    end
    self._alive = false
    self.AutoSave = nil
    self.Events.Destroying:Fire()
    for i = #self.Windows, 1, -1 do
        local window = self.Windows[i]
        pcall(function()
            window:Destroy()
        end)
    end
    for tw in pairs(self._tweens) do
        pcall(function()
            tw:Cancel()
        end)
        self._tweens[tw] = nil
    end
    if self._watermarkMaid then
        self._watermarkMaid:Destroy()
        self._watermarkMaid = nil
    end
    if self._fov and type(self._fov) == "table" and self._fov.Remove then
        pcall(function()
            self._fov:Remove()
        end)
    end
    RootMaid:Destroy()
    self.Events.ThemeChanged:Destroy()
    self.Events.Destroying:Destroy()
    if env[GLOBAL_KEY] == self then
        env[GLOBAL_KEY] = nil
    end
    if _G[GLOBAL_KEY] == self then
        _G[GLOBAL_KEY] = nil
    end
    return self
end

if UserInputService then
    RootMaid:Give(UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local dropdown = DXForgeExecute._openDropdown
        if dropdown and dropdown.Popup then
            local pos = input.Position
            if not isInside(dropdown.Popup, pos) and not isInside(dropdown.Frame, pos) then
                dropdown:Close()
            end
        end
    end))
end

if RunService then
    RootMaid:Give(RunService.RenderStepped:Connect(function()
        if not DXForgeExecute._alive then
            return
        end
        updateTooltipPosition()
        updateFOV()
        local auto = DXForgeExecute.AutoSave
        if auto and now() - auto.Last >= auto.Interval then
            auto.Last = now()
            if auto.Enabled ~= false then
                DXForgeExecute:SaveConfig(auto.File)
            end
        end
    end))
end

applyTheme()

return DXForgeExecute

--[[
API Example:

local Library = loadstring(game:HttpGet("RAW_LINK_HERE"))()

local Window = Library:CreateWindow({
    Title = "DXForgeExecute Example",
    Size = {620, 520},
    ToggleKey = Enum.KeyCode.Insert,
    Theme = "DarkTech",
    Resizable = true,
    Startup = true
})

local Main = Window:AddTab("Main")
local Combat = Main:AddGroupbox("Combat", "left")

Combat:AddToggle({
    Text = "Example Toggle",
    Flag = "example_toggle",
    Default = false,
    Tooltip = "This is only an example toggle.",
    Callback = function(value)
        print("Toggle:", value)
    end
})

Combat:AddSlider({
    Text = "Example Slider",
    Flag = "example_slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 1,
    Suffix = "%",
    Callback = function(value)
        print("Slider:", value)
    end
})

Combat:AddDropdown({
    Text = "Example Mode",
    Flag = "example_mode",
    Values = {"Default", "Legit", "Custom"},
    Default = "Default",
    Search = true,
    Callback = function(value)
        print("Dropdown:", value)
    end
})

Library:Notify({
    Text = "DXForgeExecute loaded successfully.",
    Type = "Success",
    Duration = 4
})
]]
