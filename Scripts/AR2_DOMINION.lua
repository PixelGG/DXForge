--[[
    AR2 DOMINION v5.0.0 - Apocalypse Rising 2 DX9WARE Script
    Target: DX9 Cult of Intellect | UI: DXForge v1.0.19
    
    Features:
      - Player ESP (Box, Name, Distance, Health Bar, Tracelines, Skeleton, Snap Lines)
      - Player Aimbot (Smooth, FOV, 11 aim parts, First/Third Person)
      - Zombie ESP (Box, Name, Distance, Type Classification, Health Bar, Tracelines, Skeleton)
      - Zombie Aimbot (independent settings)
      - Zombie Proximity Alert
      - Vehicle ESP (31 vehicle types, categorized)
      - Loot Container ESP
      - Searchable Loot ESP (real map searchables with category filters)
      - World Utility ESP (Fuel Pumps, Water Pumps, Ladders, Switches, Garage Controls)
      - Dead Body ESP (Player + Zombie with X-marker)
      - Corpse Equipment Preview
      - Crosshair (4 styles)
      - Watermark, FPS Counter, Session Timer, Stats Overlay, Location Tag
      - DXForge-powered professional UI
--]]

if _G.AR2_DOMINION_RUNTIME and type(_G.AR2_DOMINION_RUNTIME.renderFrame) == "function" then
    local runtime = _G.AR2_DOMINION_RUNTIME
    if runtime.hooked then
        return
    end
    if runtime.window and runtime.dxforge then
        runtime.lastTick = os.clock()
        local ok, err = pcall(runtime.renderFrame)
        if not ok then
            print("[AR2 DOMINION] RENDER ERROR: " .. tostring(err))
        end
        return
    end
end

-- ============================================================
-- BOOTSTRAP: Full reset on every run
-- ============================================================
print("[AR2 DOMINION] v5.0.0 starting...")
dx9.ShowConsole(true)

-- Destroy any previous DXForge state so the window is rebuilt cleanly
if _G.DXForge then
    _G.DXForge:Destroy()
    _G.DXForge = nil
end
_G.DOMINION_STATE = nil
collectgarbage()

-- ============================================================
-- LOAD DXFORGE
-- ============================================================
local DXForge
do
    local code = dx9.Get("https://raw.githubusercontent.com/PixelGG/DXForge/main/DXForge.lua")
    if not code or code == "" then
        print("[AR2 DOMINION] ERROR: DXForge download failed!")
        return
    end
    -- Strip UTF-8 BOM if present
    if code:byte(1) == 239 and code:byte(2) == 187 and code:byte(3) == 191 then
        code = code:sub(4)
    end
    local fn, err = loadstring(code)
    if not fn then
        print("[AR2 DOMINION] ERROR: DXForge parse error: " .. tostring(err))
        return
    end
    DXForge = fn()
    if not DXForge or type(DXForge) ~= "table" then
        print("[AR2 DOMINION] ERROR: DXForge did not return a valid table!")
        return
    end
    _G.DXForge = DXForge
    print("[AR2 DOMINION] DXForge " .. tostring(DXForge.__DXFORGE_VERSION) .. " loaded")
end

-- ============================================================
-- CONFIGURATION
-- ============================================================
local CFG = {
    VERSION      = "5.0.0",
    SCRIPT_NAME  = "AR2 DOMINION",
    AUTHOR       = "Lorthanyx",
    TOGGLE_KEY   = "[F6]",
    NO_HOTKEY    = "[NONE]",
    CANCEL_KEY   = "[ESC]",

    -- Performance / cache timings (seconds)
    ENTITY_CACHE_SEC     = 1.0,
    VEHICLE_CACHE_SEC    = 4.0,
    ZOMBIE_CACHE_SEC     = 3.0,
    LOOT_CACHE_SEC       = 2.0,
    SEARCHABLE_CACHE_SEC = 8.0,
    UTILITY_CACHE_SEC    = 10.0,
    SCAN_BUDGET          = 3000,  -- max objects scanned per cache refresh
    DEAD_BODY_CACHE_SEC  = 2.0,
    LOCAL_CACHE_SEC      = 0.8,
    LOC_CACHE_SEC        = 2.0,
    SELF_EXCLUDE_DIST    = 4.0,

    -- Skeleton bones (R15)
    SKELETON = {
        {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
        {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"},
        {"RightLowerArm","RightHand"}, {"UpperTorso","LeftUpperArm"},
        {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
        {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"},
        {"RightLowerLeg","RightFoot"}, {"LowerTorso","LeftUpperLeg"},
        {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    },

    AIM_PARTS = {
        "Head", "UpperTorso", "LowerTorso",
        "LeftUpperArm", "RightUpperArm",
        "LeftHand", "RightHand",
        "LeftUpperLeg", "RightUpperLeg",
        "LeftFoot", "RightFoot",
    },
    AIM_MODES    = {"First Person", "Third Person"},
    FOV_SOURCES  = {"Auto", "Player", "Zombie"},
    CROSS_STYLES = {"Cross", "Dot", "Circle", "Cross+Circle"},

    -- AR2 vehicle data
    VEHICLE_NAMES = {
        "Sedan", "Station Wagon", "Chevy Suburban", "Chevy Blazer",
        "Pickup Truck", "Caprice", "Mustang", "Corvette",
        "Jeep", "Tractor", "Quad",
        "Delivery Van", "Cargo Van", "Semi Truck", "StepVan",
        "Box Truck", "Utility Truck",
        "Humvee", "Military Pickup", "Barracks Truck", "Armored Truck",
        "Police CUV", "Police Car", "Ambulance", "Firetruck",
        "Speed Boat", "Swing Keel Boat", "Aluminum Boat",
        "Lifeboat", "Rubber Dinghy", "Patrol Boat",
    },
    VEHICLE_CATEGORY = {
        Sedan="Civilian", ["Station Wagon"]="Civilian",
        ["Chevy Suburban"]="Civilian", ["Chevy Blazer"]="Civilian",
        ["Pickup Truck"]="Civilian", Caprice="Civilian",
        Mustang="Civilian", Corvette="Civilian",
        Jeep="Civilian", Tractor="Civilian", Quad="Civilian",
        ["Delivery Van"]="Commercial", ["Cargo Van"]="Commercial",
        ["Semi Truck"]="Commercial", StepVan="Commercial",
        ["Box Truck"]="Commercial", ["Utility Truck"]="Commercial",
        Humvee="Military", ["Military Pickup"]="Military",
        ["Barracks Truck"]="Military", ["Armored Truck"]="Military",
        ["Police CUV"]="Emergency", ["Police Car"]="Emergency",
        Ambulance="Emergency", Firetruck="Emergency",
        ["Speed Boat"]="Boat", ["Swing Keel Boat"]="Boat",
        ["Aluminum Boat"]="Boat", Lifeboat="Boat",
        ["Rubber Dinghy"]="Boat", ["Patrol Boat"]="Boat",
    },
    VEHICLE_CAT_COLOR = {
        Civilian={180,180,200}, Commercial={200,180,100},
        Military={60,180,60},   Emergency={255,40,40},
        Boat={0,200,220},
    },
    VEHICLE_DISPLAY_NAME = {
        ["Chevy Suburban"]="SUV",
        Corvette="Sports Car",
        Mustang="Muscle Car",
        ["Barracks Truck"]="Army Truck",
        ["Military Pickup"]="Army Pickup",
        Sedan="Sedan",
        Caprice="Luxury Sedan",
        ["Patrol Boat"]="Patrol Boat",
        ["Speed Boat"]="Speed Boat",
        ["Aluminum Boat"]="Aluminum Boat",
        ["Rubber Dinghy"]="Rubber Dinghy",
    },

    -- AR2 loot containers
    LOOT_CONTAINERS = {
        "ChestToolDouble01","ChestFloorWood01","ChestFloorWoodSmall01",
        "ChestFootlocker01","ChestFootlockerMilitary01","ChestMedical01",
        "ChestTreasureUnique01",
        "CrateWeaponSurplusSmugglerShort01","CrateWeaponSurplusSmugglerSmall01",
        "CrateWeaponEnthusiast02","CrateWeaponEnthusiastMarksman01",
        "CrateWeaponEnthusiastSecurity01","CrateWeaponSoviet01",
        "CrateWeaponSovietModern01","CrateWeaponSovietModernSmall01",
        "CrateAmmoSoviet01","CrateAmmoMilitary01","CrateAmmoMilitary03",
        "CrateShippingWood03","CrateShippingWood04","CrateShippingWood05",
        "CrateShippingWood06","CrateShippingWood07",
        "CrateShippingWoodMilitary04","CrateShippingWoodMilitary05",
        "CrateShippingWoodMilitia02","CrateCooler01","CrateCooler02",
        "CaseEquipmentAttachment01","CaseEquipmentEnthusiast01",
        "CaseEquipmentMedical01",
        "BoxToolSmall01","BoxMetalLong01","BoxMetalLongVillager01",
        "CabinetFiling01","CabinetFiling02","CabinetStorage01",
        "BarrelWood01","BarrelMetal01",
    },
    SEARCHABLE_LOOT_NAMES = {
        "BarrelWood01","BoxCardboardOpened05","BoxTackleSmall01",
        "CabinetShelfTallWood01","CabinetTallIndustry01",
        "CanGarbageMetal01","CanGarbageMetal03",
        "CaseEquipmentEnthusiast01","CaseEquipmentMedical01",
        "ClosetTallMetal01","CrateCooler02","CrateShippingWood01",
        "CrateShippingWoodMilitary01","CrateWeaponEnthusiast01",
        "MachineVending02","MachineVending03","MedicalKitCivilian01",
        "VehicleTrunk01",
    },
    SEARCHABLE_CATEGORY = {
        BarrelWood01="Utility",
        BoxCardboardOpened05="Civilian",
        BoxTackleSmall01="Utility",
        CabinetShelfTallWood01="Civilian",
        CabinetTallIndustry01="Industrial",
        CanGarbageMetal01="Civilian",
        CanGarbageMetal03="Civilian",
        CaseEquipmentEnthusiast01="Weapon",
        CaseEquipmentMedical01="Medical",
        ClosetTallMetal01="Industrial",
        CrateCooler02="Food",
        CrateShippingWood01="Industrial",
        CrateShippingWoodMilitary01="Weapon",
        CrateWeaponEnthusiast01="Weapon",
        MachineVending02="Food",
        MachineVending03="Food",
        MedicalKitCivilian01="Medical",
        VehicleTrunk01="Vehicle",
    },
    SEARCHABLE_CATEGORY_COLOR = {
        Medical={80,220,140},
        Weapon={255,120,80},
        Food={255,210,80},
        Vehicle={80,180,255},
        Industrial={210,210,210},
        Utility={180,140,255},
        Civilian={220,220,170},
    },
    UTILITY_TYPE_COLOR = {
        Fuel={255,180,60},
        Water={80,180,255},
        Ladder={220,220,220},
        Switch={255,255,120},
        Garage={255,150,80},
    },

    -- Zombie type classification
    ZOMBIE_TYPES = {
        Military = {"Military","Soldier","Boot Camp","Drill","SWAT","SpecOps","Operator"},
        Police   = {"Police","Security","Prison"},
        Unique   = {"Unique","Cultist","Hazmat","Plague","Caveman","Butcher"},
        Smuggler = {"Smuggler","Miner","Mobster"},
        Civilian = {"Civilian","Resident","Tourist","Student","Hobo","Farmer","Hunter","Camper"},
    },
    ZOMBIE_TYPE_COLOR = {
        Military={60,180,60}, Police={0,120,255},
        Unique={255,50,200},  Smuggler={255,160,0},
        Civilian={200,200,210},
    },
}

-- Build loot lookup set
local LOOT_NAME_SET = {}
for _, n in ipairs(CFG.LOOT_CONTAINERS) do LOOT_NAME_SET[n] = true end
local SEARCHABLE_LOOT_SET = {}
for _, n in ipairs(CFG.SEARCHABLE_LOOT_NAMES) do SEARCHABLE_LOOT_SET[n] = true end

-- ============================================================
-- PERSISTENT STATE
-- ============================================================
_G.DOMINION_STATE = {
    -- Player ESP
    pEsp=false, pBox=true, pBoxC={0,160,255},
    pName=true, pNameC={220,220,230},
    pDist=true, pDistC={180,180,190},
    pTrace=false, pTraceC={0,160,255},
    pSkel=false, pSkelC={200,200,220},
    pHealth=true, pHealthC={0,255,100},
    pSnapLine=false, pSnapC={255,255,0},
    pNearest=false, pNearestC={255,80,80},
    pMaxDist=500,
    -- Player Aimbot
    pAim=false, pAimPart=1, pSmooth=1.5, pSens=2.0,
    pFov=350, pFovC={255,255,255}, pAimMode=1,
    pStickyAim=false,
    -- Zombie ESP
    zEsp=false, zBox=true, zBoxC={255,80,0},
    zName=true, zNameC={255,180,100},
    zDist=true, zDistC={200,160,120},
    zTrace=false, zTraceC={255,80,0},
    zSkel=false, zSkelC={255,180,120},
    zHealth=false, zHealthC={0,255,100},
    zType=true,
    zNearest=false, zNearestC={255,200,80},
    zProxAlert=false, zProxDist=50,
    zMaxDist=800,
    -- Zombie Aimbot
    zAim=false, zAimPart=1, zSmooth=1.2, zSens=2.5,
    zFov=400, zFovC={255,120,0}, zAimMode=1,
    -- Vehicle ESP
    vEsp=false, vBox=false, vBoxC={0,180,255},
    vName=true, vNameC={0,200,255},
    vDist=true, vDistC={0,160,220},
    vTrace=false, vTraceC={0,140,200},
    vMaxDist=1000,
    vNearest=false, vNearestC={0,255,180},
    -- Loot ESP
    lEsp=false, lBox=false, lBoxC={255,200,0},
    lName=true, lNameC={255,220,100},
    lDist=true, lDistC={200,180,100},
    lTrace=false, lTraceC={255,200,0},
    lMaxDist=300,
    -- Searchable Loot ESP
    sEsp=false, sBox=false, sBoxC={180,140,255},
    sName=true, sNameC={220,200,255},
    sDist=true, sDistC={190,170,220},
    sTrace=false, sTraceC={180,140,255},
    sMaxDist=350,
    sShowMedical=true, sShowWeapon=true, sShowFood=true,
    sShowVehicle=true, sShowIndustrial=true, sShowUtility=true,
    sShowCivilian=true,
    -- Utility ESP
    uEsp=false, uBox=false, uBoxC={255,210,100},
    uName=true, uNameC={255,230,150},
    uDist=true, uDistC={220,200,140},
    uTrace=false, uTraceC={255,210,100},
    uMaxDist=450,
    uFuel=true, uWater=true, uLadder=true, uSwitch=true, uGarage=true,
    -- Dead Body ESP
    dEsp=false, dBox=true, dBoxC={150,0,0},
    dName=true, dNameC={180,80,80},
    dDist=true, dDistC={140,60,60},
    dTrace=false, dTraceC={150,0,0},
    dMaxDist=500,
    dShowZombie=true, dShowPlayer=true,
    dGear=true,
    -- Crosshair
    cross=false, crossStyle=1, crossC={0,255,100},
    crossSz=8, crossGap=3, crossDot=true,
    -- Overlays
    wmark=true, fpsCtr=false, statsOv=true, showLocation=true,
    fovCircle=false, fovCircleSource=1, fovCircleC={255,255,255},
    showConsole=false,
    -- Runtime caches
    localPos=nil, localName=nil, camPos=nil, localCharacter=nil,
    localModels={},
    localCacheTime=0,
    entities={}, entityByModel={}, entityCacheTime=0,
    vehicles={}, vehicleCacheTime=0,
    zombies={}, zombieCacheTime=0,
    lootItems={}, lootCacheTime=0,
    searchableLoot={}, searchableCacheTime=0,
    searchableScanQueue=nil, searchableScanIdx=0, searchableScanBuild=nil,
    utilityObjects={}, utilityCacheTime=0,
    utilityScanQueue=nil, utilityScanIdx=0, utilityScanBuild=nil,
    deadBodies={}, deadBodyCacheTime=0,
    -- Aim runtime
    aimX=nil, aimY=nil, aimDist=1e9, aimType=nil,
    aimCallX=nil, aimCallY=nil,
    stickyAimPlayerModel=nil,
    stickyAimPlayerPrev=false,
    nearestPlayerModel=nil, nearestZombieObj=nil,
    -- Proximity alert
    proxAlertLast=0, proxClosest=nil, proxClosestDist=1e9,
    loc="unknown", locTime=0,
    -- FPS
    fps=0, fpsFrames=0, fpsTime=0,
    -- Session
    sessionStart=os.clock(),
    -- Keybind binding UI
    bindTarget=false, bindArmed=false, bindSeedKey="",
}
local S = _G.DOMINION_STATE
pcall(dx9.ShowConsole, S.showConsole)

-- ============================================================
-- MATH HELPERS
-- ============================================================
local floor = math.floor
local sqrt  = math.sqrt
local abs   = math.abs
local huge  = math.huge
local sin   = math.sin
local cos   = math.cos
local pi    = math.pi
local min   = math.min
local max   = math.max

local function clamp(v, lo, hi) return v < lo and lo or v > hi and hi or v end
local function round(v, d) local m = 10^(d or 0); return floor(v*m+0.5)/m end
local function normalizeKeyName(key)
    key = tostring(key or "")
    if key == "" then return CFG.NO_HOTKEY end
    return key:upper()
end

local function dist3d(a, b)
    if not a or not b then return huge end
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return sqrt(dx*dx + dy*dy + dz*dz)
end

-- ============================================================
-- SAFE DX9 HELPERS
-- ============================================================
local function safeGetChildren(obj)
    if not obj or obj == 0 then return {} end
    local ok, r = pcall(dx9.GetChildren, obj)
    return (ok and r) and r or {}
end

local function findChild(parent, name)
    if not parent or parent == 0 then return nil end
    local ok, r = pcall(dx9.FindFirstChild, parent, name)
    if ok and r and r ~= 0 then return r end
    return nil
end

local function safeGetPos(obj)
    if not obj or obj == 0 then return nil end
    local ok, pos = pcall(dx9.GetPosition, obj)
    if ok and pos and pos.x then return pos end
    return nil
end

local safeProp

local function resolveObjectPosition(obj, depth)
    if not obj or obj == 0 or (depth or 0) > 3 then return nil end

    local direct = safeGetPos(obj)
    if direct then return direct end

    local primary = safeProp(obj, "PrimaryPart")
    if primary and primary ~= 0 then
        local primaryPos = safeGetPos(primary)
        if primaryPos then return primaryPos end
    end

    for _, child in ipairs(safeGetChildren(obj)) do
        local childPos = resolveObjectPosition(child, (depth or 0) + 1)
        if childPos then
            return childPos
        end
    end

    return nil
end

local function safeW2S(pos)
    if not pos then return nil end
    local ok, sp = pcall(dx9.WorldToScreen, {pos.x, pos.y, pos.z})
    if ok and sp and sp.x then return sp end
    return nil
end

safeProp = function(obj, prop)
    if not obj or obj == 0 then return nil end
    local ok, v = pcall(dx9.GetProperty, obj, prop)
    return ok and v or nil
end

local function safeGetName(obj)
    if not obj or obj == 0 then return "" end
    local ok, n = pcall(dx9.GetName, obj)
    return (ok and n) and n or ""
end

local function getStringProperty(obj, prop)
    local value = safeProp(obj, prop)
    return type(value) == "string" and value or nil
end

local function cachePart(parts, model, name)
    local part = parts[name]
    if part == nil then
        part = findChild(model, name)
        parts[name] = part
    end
    return part
end

-- Get the game DataModel safely
local function getDataModel()
    local ok, dm = pcall(dx9.GetDataModel)
    if ok and dm and dm ~= 0 then return dm end
    -- fallback alias
    local ok2, dm2 = pcall(dx9.GetDatamodel)
    if ok2 and dm2 and dm2 ~= 0 then return dm2 end
    return nil
end

-- ============================================================
-- LOCAL PLAYER DETECTION
-- ============================================================
-- Identifies the local player node by checking for PlayerGui/PlayerScripts
local function isLocalPlayerNode(playerObj)
    if not playerObj or playerObj == 0 then return false end
    return findChild(playerObj, "PlayerGui") ~= nil
        or findChild(playerObj, "PlayerScripts") ~= nil
end

local function isSelfPosition(pos)
    if not pos or not S.localPos then return false end
    return dist3d(pos, S.localPos) < CFG.SELF_EXCLUDE_DIST
end

local function getLocalDistance(pos)
    if not pos or not S.localPos then return nil end
    return dist3d(pos, S.localPos)
end

local function getAimDistanceOrigin()
    return S.camPos or S.localPos
end

local function resetLocalModelCache()
    S.localModels = {}
    S.localCharacter = nil
end

local function markLocalModel(model)
    if not model or model == 0 then return end
    S.localModels = S.localModels or {}
    S.localModels[model] = true
    if not S.localCharacter then
        S.localCharacter = model
    end
end

local function isLocalModel(model, ownerName)
    if not model or model == 0 then return false end
    if S.localModels and S.localModels[model] then return true end
    if S.localCharacter and model == S.localCharacter then return true end
    if S.localName and ownerName and ownerName ~= "" and ownerName == S.localName then return true end
    if S.localName and safeGetName(model) == S.localName then return true end
    local core = findChild(model, "HumanoidRootPart") or findChild(model, "LowerTorso") or findChild(model, "UpperTorso") or findChild(model, "Head")
    local pos = core and safeGetPos(core)
    return pos and isSelfPosition(pos) or false
end

local function resolveLocalCharacterFromWorkspace(ws)
    local charsFolder = findChild(ws, "Characters")
    if not charsFolder then return end
    for _, c in ipairs(safeGetChildren(charsFolder)) do
        local core = findChild(c, "HumanoidRootPart") or findChild(c, "LowerTorso") or findChild(c, "UpperTorso")
        local pos = core and safeGetPos(core)
        if (pos and isSelfPosition(pos)) or (S.localName and safeGetName(c) == S.localName) then
            markLocalModel(c)
        end
    end
end

local function refreshLocalPlayer(ws, pls, now)
    if now - (S.localCacheTime or 0) < CFG.LOCAL_CACHE_SEC then return end
    S.localCacheTime = now
    resetLocalModelCache()
    local foundPos = false

    -- Try dx9.get_localplayer first
    if dx9.get_localplayer then
        local ok, info = pcall(dx9.get_localplayer)
        if ok and type(info) == "table" then
            local pos = info.position or info.Position
            local meta = info.info or info.Info
            local name = info.name or info.Name or (type(meta) == "table" and (meta.name or meta.Name))
            if name and name ~= "" then
                S.localName = tostring(name)
            end
            if type(pos) == "table" and pos.x and pos.y and pos.z then
                S.localPos = pos
                foundPos = true
            end
        end
    end

    -- Fallback: find local player node in Players service
    if pls then
        for _, p in ipairs(safeGetChildren(pls)) do
            if isLocalPlayerNode(p) then
                S.localName = safeGetName(p)
                local wm = findChild(p, "WorldModel")
                local char = findChild(p, "Character")
                    or (wm and findChild(wm, "StarterCharacter"))
                    or (wm and safeGetChildren(wm)[1])
                if char then
                    markLocalModel(char)
                    if wm then
                        for _, child in ipairs(safeGetChildren(wm)) do
                            markLocalModel(child)
                        end
                    end
                    local hrp = findChild(char, "HumanoidRootPart")
                    local pos = hrp and safeGetPos(hrp)
                    if pos then
                        S.localPos = pos
                        foundPos = true
                    end
                end
            end
        end
    end

    -- Fallback: use Characters folder - pick the character with a PlayerGui sibling
    if pls then
        for _, p in ipairs(safeGetChildren(pls)) do
            if isLocalPlayerNode(p) then
                S.localName = safeGetName(p)
                local charFolder = findChild(ws, "Characters")
                if charFolder then
                    local pName = S.localName
                    for _, c in ipairs(safeGetChildren(charFolder)) do
                        local hrp = findChild(c, "HumanoidRootPart")
                        local pos = hrp and safeGetPos(hrp)
                        if pos then
                            -- Heuristic: the one whose name matches the local player name
                            if safeGetName(c) == pName then
                                markLocalModel(c)
                                S.localPos = pos
                                foundPos = true
                            end
                        end
                    end
                end
            end
        end
    end

    -- Last fallback: camera position keeps ESP/aim filtering alive even when the player API is inconsistent.
    local cam = findChild(ws, "CurrentCamera") or safeProp(ws, "CurrentCamera")
    local camPos = cam and resolveObjectPosition(cam, 0)
    if camPos then
        S.camPos = camPos
        if not foundPos then
            S.localPos = camPos
        end
    end

    resolveLocalCharacterFromWorkspace(ws)
end

-- ============================================================
-- HEALTH HELPER
-- ============================================================
local function getHealth(obj)
    local humanoid = findChild(obj, "Humanoid")
    if not humanoid then return 100, 100 end
    local hp  = safeProp(humanoid, "Health")   or 100
    local mhp = safeProp(humanoid, "MaxHealth") or 100
    return hp, mhp
end

-- ============================================================
-- ZOMBIE TYPE CLASSIFICATION
-- ============================================================
local function classifyZombie(name)
    for typeName, keywords in pairs(CFG.ZOMBIE_TYPES) do
        for _, kw in ipairs(keywords) do
            if name:find(kw) then return typeName end
        end
    end
    return "Civilian"
end

local function categorizeSearchable(name)
    return CFG.SEARCHABLE_CATEGORY[name] or "Civilian"
end

local function isSearchableCategoryEnabled(category)
    if category == "Medical" then return S.sShowMedical end
    if category == "Weapon" then return S.sShowWeapon end
    if category == "Food" then return S.sShowFood end
    if category == "Vehicle" then return S.sShowVehicle end
    if category == "Industrial" then return S.sShowIndustrial end
    if category == "Utility" then return S.sShowUtility end
    return S.sShowCivilian
end

local function collectCorpseEquipmentSummary(corpse)
    local equipment = findChild(corpse, "Equipment")
    if not equipment then return nil end
    local names = {}
    for _, item in ipairs(safeGetChildren(equipment)) do
        local itemName = safeGetName(item)
        if itemName ~= "" then
            names[#names + 1] = itemName
        end
        if #names >= 2 then
            break
        end
    end
    if #names == 0 then return nil end
    return table.concat(names, " | ")
end

local function scanRecursive(folder, depth, maxDepth, visit, budget)
    if not folder or folder == 0 or (depth or 0) > (maxDepth or 4) then return budget end
    budget = budget or CFG.SCAN_BUDGET
    for _, obj in ipairs(safeGetChildren(folder)) do
        if budget <= 0 then return 0 end
        visit(obj, depth or 0)
        budget = budget - 1
        budget = scanRecursive(obj, (depth or 0) + 1, maxDepth, visit, budget)
    end
    return budget
end

-- Collect entire tree into a flat array (called once, then processed in chunks per frame)
local function buildFlatQueue(folder, maxDepth, queue, depth)
    if not folder or folder == 0 or (depth or 0) > (maxDepth or 8) then return end
    for _, obj in ipairs(safeGetChildren(folder)) do
        queue[#queue + 1] = obj
        buildFlatQueue(obj, maxDepth, queue, (depth or 0) + 1)
    end
end

local function detectLocation(ws, now)
    if now - (S.locTime or 0) < CFG.LOC_CACHE_SEC then
        return S.loc or "unknown"
    end
    S.locTime = now

    if findChild(ws, "Body") then
        S.loc = "Lobby"
        return S.loc
    end

    local mapFolder = findChild(ws, "Map")
    if mapFolder then
        local ambient = findChild(mapFolder, "Ambient")
        local regions = ambient and findChild(ambient, "Regions")
        local cityRegions = regions and findChild(regions, "City Regions")
        if cityRegions then
            for _, region in ipairs(safeGetChildren(cityRegions)) do
                local regionName = safeGetName(region)
                if regionName ~= "" then
                    S.loc = regionName
                    return S.loc
                end
            end
            S.loc = "Mainland"
            return S.loc
        end
    end

    if findChild(ws, "Vehicles") then
        S.loc = "In-Game"
        return S.loc
    end

    S.loc = "unknown"
    return S.loc
end

local function clearStickyPlayerTarget()
    S.stickyAimPlayerModel = nil
end

local function refreshPlayerStickyState()
    local aimActive = S.pAim == true
    local stickyEnabled = S.pStickyAim == true
    local prevAimActive = S.stickyAimPlayerPrev == true

    if (not aimActive) or (not stickyEnabled) or (not prevAimActive) then
        clearStickyPlayerTarget()
    end

    S.stickyAimPlayerPrev = aimActive
end

local function resolveEntityFootPart(parts, model)
    local candidates = {"LeftFoot", "RightFoot", "LeftLowerLeg", "RightLowerLeg", "LowerTorso", "HumanoidRootPart"}
    for _, name in ipairs(candidates) do
        local part = cachePart(parts, model, name)
        if part and part ~= 0 then
            return part
        end
    end
    return nil
end

local function resolveEntityCorePart(parts, model)
    local candidates = {"HumanoidRootPart", "Root", "LowerTorso", "UpperTorso", "Head"}
    for _, name in ipairs(candidates) do
        local part = cachePart(parts, model, name)
        if part and part ~= 0 then
            return part
        end
    end
    return nil
end

local function cleanPlayerLabel(text)
    if type(text) ~= "string" then return nil end
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" or text == "NPC" or text == "Player" then return nil end
    if #text > 32 then return nil end
    if text:match("^%d+$") or text:match("^%d+[mM]$") then return nil end
    if not text:match("[%a_]") then return nil end
    return text
end

local function extractBillboardName(node, depth)
    if not node or node == 0 or (depth or 0) > 6 then return nil end

    local text = cleanPlayerLabel(getStringProperty(node, "Text"))
    if text then
        return text
    end

    for _, child in ipairs(safeGetChildren(node)) do
        local found = extractBillboardName(child, (depth or 0) + 1)
        if found then
            return found
        end
    end

    return nil
end

local function resolvePlayerName(model, ownerName)
    if ownerName and ownerName ~= "" then
        return ownerName
    end

    local humanoid = findChild(model, "Humanoid")
    local displayName = cleanPlayerLabel(humanoid and getStringProperty(humanoid, "DisplayName") or nil)
    if displayName then
        return displayName
    end

    local head = findChild(model, "Head")
    local billboard = findChild(model, "BillboardGui") or (head and (findChild(head, "Status") or findChild(head, "BillboardGui")))
    if billboard then
        local billboardName = extractBillboardName(billboard, 0)
        if billboardName then
            return billboardName
        end
    end

    local modelName = safeGetName(model)
    if modelName ~= "" and modelName ~= "StarterCharacter" and modelName ~= "Male" and modelName ~= "Female" and modelName ~= "NB" then
        return modelName
    end

    return "Player"
end

-- ============================================================
-- ENTITY CACHE (Players)
-- ============================================================
local function refreshEntityCache(ws, pls, now)
    if now - (S.entityCacheTime or 0) < CFG.ENTITY_CACHE_SEC then return end
    S.entityCacheTime = now

    local cache = {}
    local seen  = {}

    local function isHumanoidCharacterModel(model)
        if not model or model == 0 then return false end
        if not findChild(model, "Humanoid") then return false end
        if not findChild(model, "Head") then return false end
        if not (findChild(model, "HumanoidRootPart") or findChild(model, "LowerTorso") or findChild(model, "UpperTorso")) then
            return false
        end
        return true
    end

    local function findCharacterModel(container, depth)
        if not container or container == 0 or (depth or 0) > 4 then return nil end
        for _, child in ipairs(safeGetChildren(container)) do
            if isHumanoidCharacterModel(child) then
                return child
            end
        end
        for _, child in ipairs(safeGetChildren(container)) do
            local found = findCharacterModel(child, (depth or 0) + 1)
            if found then
                return found
            end
        end
        return nil
    end

    local function addModel(model, ownerName)
        if not model or model == 0 or seen[model] or not isHumanoidCharacterModel(model) then return end
        seen[model] = true
        if isLocalModel(model, ownerName) then return end
        local parts = {}
        local head = cachePart(parts, model, "Head")
        local core = resolveEntityCorePart(parts, model)
        local foot = resolveEntityFootPart(parts, model)
        if not head or not core or not foot then return end
        local corePos = safeGetPos(core)
        if not corePos then return end
        if isSelfPosition(corePos) then return end
        local resolvedOwnerName = resolvePlayerName(model, ownerName)
        if isLocalModel(model, resolvedOwnerName) then return end
        local d = getLocalDistance(corePos)
        if d and d > S.pMaxDist then return end
        local hp, maxHp = getHealth(model)
        if hp <= 0 then return end
        parts.HumanoidRootPart = parts.HumanoidRootPart or findChild(model, "HumanoidRootPart")
        if S.pSkel or S.pAim then
            for _, conn in ipairs(CFG.SKELETON) do
                cachePart(parts, model, conn[1])
                cachePart(parts, model, conn[2])
            end
        end
        cache[#cache+1] = {
            model=model, head=head, foot=foot, hrp=parts.HumanoidRootPart or core, core=core, parts=parts, isP=true,
            ownerName=resolvedOwnerName,
            hp=hp, maxHp=maxHp, dist=d or huge,
        }
    end

    -- Primary: AR2 keeps live characters in Workspace.Characters, but model names are often all "StarterCharacter".
    local charsFolder = findChild(ws, "Characters")
    if charsFolder then
        for _, c in ipairs(safeGetChildren(charsFolder)) do
            addModel(c, nil)
        end
    end

    -- Fallback: scan character containers under Players in case the workspace folder is empty or incomplete.
    if pls and #cache == 0 then
        for _, p in ipairs(safeGetChildren(pls)) do
            if not isLocalPlayerNode(p) then
                local pName = safeGetName(p)
                local wm = findChild(p, "WorldModel")
                local char = findChild(p, "Character")
                if char then
                    addModel(char, pName)
                elseif wm then
                    local model = findCharacterModel(wm, 0)
                    if model then
                        addModel(model, pName)
                    end
                end
            end
        end
    end

    table.sort(cache, function(a, b) return (a.dist or huge) < (b.dist or huge) end)
    S.entities = cache
    local byModel = {}
    for _, e in ipairs(cache) do byModel[e.model] = e end
    S.entityByModel = byModel
    S.nearestPlayerModel = cache[1] and cache[1].model or nil
end

-- ============================================================
-- ZOMBIE CACHE
-- ============================================================
local function refreshZombieCache(ws, now)
    if now - (S.zombieCacheTime or 0) < CFG.ZOMBIE_CACHE_SEC then return end
    S.zombieCacheTime = now

    local cache = {}
    local zombieFolder = findChild(ws, "Zombies")
    if not zombieFolder then S.zombies = cache; return end

    local proxClosest, proxClosestDist = nil, huge

    for _, z in ipairs(safeGetChildren(zombieFolder)) do
        local hrp  = findChild(z, "HumanoidRootPart")
        local pos  = hrp and safeGetPos(hrp)
        if pos and not isSelfPosition(pos) then
            local hp, maxHp = getHealth(z)
            if hp > 0 then
                local d = getLocalDistance(pos)
                if (not d) or d <= S.zMaxDist then
                    local zName = safeGetName(z)
                    local zType = classifyZombie(zName)

                    local parts = {HumanoidRootPart=hrp}
                    if S.zSkel or S.zAim then
                        parts["Head"] = findChild(z, "Head")
                        for _, conn in ipairs(CFG.SKELETON) do
                            if not parts[conn[1]] then parts[conn[1]] = findChild(z, conn[1]) end
                            if not parts[conn[2]] then parts[conn[2]] = findChild(z, conn[2]) end
                        end
                    end

                    cache[#cache+1] = {
                        obj=z, name=zName, pos=pos, hp=hp, maxHp=maxHp,
                        zType=zType, dist=d or huge, parts=parts, hrp=hrp,
                    }

                    if d and d < proxClosestDist then
                        proxClosestDist = d
                        proxClosest = zName
                    end
                end
            end
        end
    end

    table.sort(cache, function(a, b) return (a.dist or huge) < (b.dist or huge) end)
    S.zombies = cache
    S.proxClosest = proxClosest
    S.proxClosestDist = proxClosestDist
    S.nearestZombieObj = cache[1] and cache[1].obj or nil
end

-- ============================================================
-- VEHICLE CACHE
-- ============================================================
local function refreshVehicleCache(ws, now)
    if now - (S.vehicleCacheTime or 0) < CFG.VEHICLE_CACHE_SEC then return end
    S.vehicleCacheTime = now

    local cache = {}
    local vehicleFolder = findChild(ws, "Vehicles")
    if not vehicleFolder then
        -- AR2 may have vehicles directly in Workspace too
        S.vehicles = cache
        return
    end

    for _, v in ipairs(safeGetChildren(vehicleFolder)) do
        local vName = safeGetName(v)
        local category = CFG.VEHICLE_CATEGORY[vName] or "Unknown"
        if category == "Unknown" then
            -- Try to find the vehicle's primary seat/PrimaryPart
            -- as the name might be a model container
            local primary = safeProp(v, "PrimaryPart") or findChild(v, "VehicleSeat")
            if not primary then
                -- Check direct named children
                for _, vn in ipairs(CFG.VEHICLE_NAMES) do
                    if vName:find(vn) then
                        category = CFG.VEHICLE_CATEGORY[vn] or "Civilian"
                        vName = vn
                        break
                    end
                end
            end
        end

        -- Get position: try PrimaryPart, VehicleSeat, or first child
        local posObj = safeProp(v, "PrimaryPart")
                    or findChild(v, "VehicleSeat")
                    or findChild(v, "HumanoidRootPart")
        if not posObj then
            local children = safeGetChildren(v)
            posObj = children[1]
        end
        local pos = posObj and resolveObjectPosition(posObj, 0)
        if pos then
            local d = getLocalDistance(pos)
            if (not d) or d <= S.vMaxDist then
                local col = CFG.VEHICLE_CAT_COLOR[category] or {180,180,200}
                cache[#cache+1] = {
                    obj=v, name=vName, category=category, pos=pos, dist=d or huge, color=col,
                }
            end
        end
    end

    table.sort(cache, function(a, b) return a.dist < b.dist end)
    S.vehicles = cache
end

-- ============================================================
-- LOOT CACHE
-- ============================================================
local function refreshLootCache(ws, now)
    if now - (S.lootCacheTime or 0) < CFG.LOOT_CACHE_SEC then return end
    S.lootCacheTime = now

    local cache = {}

    local function scanForLoot(folder, depth)
        if not folder or folder == 0 or (depth or 0) > 4 then return end
        for _, obj in ipairs(safeGetChildren(folder)) do
            local n = safeGetName(obj)
            if LOOT_NAME_SET[n] then
                local pos = resolveObjectPosition(obj, 0)
                if pos then
                    local d = getLocalDistance(pos)
                    if (not d) or d <= S.lMaxDist then
                        cache[#cache+1] = {name=n, pos=pos, dist=d or huge}
                    end
                end
            else
                scanForLoot(obj, (depth or 0) + 1)
            end
        end
    end

    -- AR2 stores loot simulation in Workspace["Loot Simulation"]
    local lootFolder = findChild(ws, "Loot Simulation") or findChild(ws, "Loot")
    if lootFolder then
        scanForLoot(lootFolder, 0)
    else
        -- Fallback: scan the full workspace shallowly
        for _, obj in ipairs(safeGetChildren(ws)) do
            local n = safeGetName(obj)
            if LOOT_NAME_SET[n] then
                local pos = resolveObjectPosition(obj, 0)
                if pos then
                    local d = getLocalDistance(pos)
                    if (not d) or d <= S.lMaxDist then
                        cache[#cache+1] = {name=n, pos=pos, dist=d or huge}
                    end
                end
            end
        end
    end

    table.sort(cache, function(a, b) return a.dist < b.dist end)
    S.lootItems = cache
end



-- ============================================================
-- DEAD BODY CACHE
-- ============================================================
local function refreshDeadBodyCache(ws, pls, now)
    if now - (S.deadBodyCacheTime or 0) < CFG.DEAD_BODY_CACHE_SEC then return end
    S.deadBodyCacheTime = now

    local cache = {}
    local seen  = {}

    -- AR2 uses Workspace.Corpses for dead bodies
    local corpsesFolder = findChild(ws, "Corpses")
    if corpsesFolder then
        for _, corpse in ipairs(safeGetChildren(corpsesFolder)) do
            if not seen[corpse] then
                seen[corpse] = true
                local hrp  = findChild(corpse, "HumanoidRootPart")
                local pos  = hrp and safeGetPos(hrp)
                if pos and not isSelfPosition(pos) then
                    local d = getLocalDistance(pos)
                    if (not d) or d <= S.dMaxDist then
                        local cName = safeGetName(corpse)
                        local zType = classifyZombie(cName)
                        -- Is it a zombie corpse? Zombies have no PlayerGui
                        local isZombie = findChild(corpse, "Humanoid") ~= nil
                                      and findChild(corpse, "BillboardGui") == nil
                        local bodyType = isZombie and "Zombie" or "Player"
                        if (bodyType == "Zombie" and S.dShowZombie) or (bodyType == "Player" and S.dShowPlayer) then
                            cache[#cache+1] = {
                                name=cName, pos=pos, dist=d or huge,
                                bodyType=bodyType,
                                zType=isZombie and zType or nil,
                                gear=collectCorpseEquipmentSummary(corpse),
                            }
                        end
                    end
                end
            end
        end
    end

    -- Fallback: dead zombies in Workspace.Zombies (hp <= 0)
    if S.dShowZombie and #cache == 0 then
        local zombieFolder = findChild(ws, "Zombies")
        if zombieFolder then
            for _, z in ipairs(safeGetChildren(zombieFolder)) do
                local humanoid = findChild(z, "Humanoid")
                if humanoid then
                    local hp = safeProp(humanoid, "Health") or 100
                    if hp <= 0 then
                        local hrp = findChild(z, "HumanoidRootPart")
                        local pos = hrp and safeGetPos(hrp)
                        if pos then
                            local d = getLocalDistance(pos)
                            if (not d) or d <= S.dMaxDist then
                                local zName = safeGetName(z)
                                cache[#cache+1] = {
                                    name=zName, pos=pos, dist=d or huge,
                                    bodyType="Zombie",
                                    zType=classifyZombie(zName),
                                    gear=collectCorpseEquipmentSummary(z),
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    -- Fallback: dead players in Characters folder
    if S.dShowPlayer and #cache == 0 then
        local charsFolder = findChild(ws, "Characters")
        if charsFolder then
            for _, c in ipairs(safeGetChildren(charsFolder)) do
                if not seen[c] then
                    local humanoid = findChild(c, "Humanoid")
                    if humanoid then
                        local hp = safeProp(humanoid, "Health") or 100
                        if hp <= 0 then
                            local hrp = findChild(c, "HumanoidRootPart")
                            local pos = hrp and safeGetPos(hrp)
                            if pos and not isSelfPosition(pos) then
                                local d = getLocalDistance(pos)
                                if (not d) or d <= S.dMaxDist then
                                    cache[#cache+1] = {
                                        name=safeGetName(c), pos=pos, dist=d or huge,
                                        bodyType="Player", zType=nil, gear=collectCorpseEquipmentSummary(c),
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(cache, function(a, b) return a.dist < b.dist end)
    S.deadBodies = cache
end

-- ============================================================
-- DRAW HELPERS (all dx9 draw calls use correct API names)
-- ============================================================
local function drawBox(sp1, sp2, col)
    dx9.DrawBox(sp1, sp2, col)
end

local function drawLine(p1, p2, col)
    dx9.DrawLine(p1, p2, col)
end

local function drawString(pos, col, text)
    dx9.DrawString(pos, col, text)
end

local function drawShadowedString(pos, col, text)
    dx9.DrawString({pos[1]+1, pos[2]+1}, {0,0,0}, text)
    dx9.DrawString(pos, col, text)
end

-- Draw a 3-pixel wide health bar to the left of a box
local function drawHealthBar(coreSP, headSP, footSP, hp, maxHp)
    local pct    = clamp(hp / max(maxHp, 1), 0, 1)
    local barH   = abs(footSP.y - headSP.y) + 8
    local halfW  = (abs(footSP.y - headSP.y) * 0.275)
    local barX   = coreSP.x - halfW - 6
    local barTop = headSP.y - 4
    dx9.DrawFilledBox({barX, barTop}, {barX+3, barTop+barH}, {40,40,40})
    local fillH  = floor(barH * pct)
    local hCol   = pct > 0.5 and {0,255,100} or pct > 0.25 and {255,180,0} or {255,50,50}
    dx9.DrawFilledBox({barX, barTop+barH-fillH}, {barX+3, barTop+barH}, hCol)
end

-- ============================================================
-- ESP RENDERING
-- ============================================================
local function drawEntityESP(entity, espType, sw, sh)
    if espType == "player" and isLocalModel(entity.model, entity.ownerName) then return end
    local headObj = entity.head or (entity.parts and entity.parts["Head"])
    local footObj = entity.foot or (entity.parts and entity.parts["LeftFoot"])
    local hrpObj  = entity.hrp  or (entity.parts and entity.parts["HumanoidRootPart"])
    if not hrpObj then return end

    local corePos = safeGetPos(hrpObj)
    if not corePos then return end

    local headPos = (headObj and safeGetPos(headObj)) or corePos
    local footPos = (footObj and safeGetPos(footObj)) or corePos

    local coreSP = safeW2S(corePos)
    if not coreSP then return end
    local headSP = safeW2S(headPos) or coreSP
    local footSP = safeW2S(footPos) or coreSP

    local d = getLocalDistance(corePos)

    local isPlayer = (espType == "player")
    local pfx      = isPlayer and "p" or "z"
    local boxCol   = S[pfx.."BoxC"]
    local nameCol  = S[pfx.."NameC"]
    local distCol  = S[pfx.."DistC"]

    -- Box
    if S[pfx.."Box"] then
        local boxH = abs(footSP.y - headSP.y)
        local boxW = boxH * 0.55
        local bx   = coreSP.x - boxW*0.5
        local by   = headSP.y - 4
        drawBox({bx, by}, {bx+boxW, by+boxH+8}, boxCol)
    end

    -- Skeleton
    if S[pfx.."Skel"] and entity.parts then
        local skelCol = S[pfx.."SkelC"]
        for _, conn in ipairs(CFG.SKELETON) do
            local pA = entity.parts[conn[1]]
            local pB = entity.parts[conn[2]]
            if pA and pA ~= 0 and pB and pB ~= 0 then
                local posA = safeGetPos(pA)
                local posB = safeGetPos(pB)
                if posA and posB then
                    local spA = safeW2S(posA)
                    local spB = safeW2S(posB)
                    if spA and spB then
                        drawLine({spA.x, spA.y}, {spB.x, spB.y}, skelCol)
                    end
                end
            end
        end
    end

    -- Health bar
    if S[pfx.."Health"] then
        drawHealthBar(coreSP, headSP, footSP, entity.hp or 100, entity.maxHp or 100)
    end

    -- Text labels
    local textY = headSP.y - 16
    if S[pfx.."Name"] then
        local label
        if isPlayer then
            label = entity.ownerName or entity.name or "Player"
        else
            local typeStr = (S.zType and entity.zType) and ("["..entity.zType.."] ") or ""
            label = typeStr .. (entity.name or "Zombie")
            local zTypeCol = entity.zType and CFG.ZOMBIE_TYPE_COLOR[entity.zType] or nameCol
            nameCol = zTypeCol
        end
        drawShadowedString({coreSP.x - #label*3, textY}, nameCol, label)
        textY = textY - 12
    end

    if S[pfx.."Dist"] then
        local distStr = d and (round(d, 0).."m") or "--"
        drawShadowedString({coreSP.x - #distStr*3, footSP.y + 6}, distCol, distStr)
    end

    -- Traceline
    if S[pfx.."Trace"] then
        drawLine({sw*0.5, sh}, {coreSP.x, coreSP.y}, S[pfx.."TraceC"])
    end

    -- Snap line (players only)
    if isPlayer and S.pSnapLine then
        drawLine({sw*0.5, sh*0.5}, {coreSP.x, coreSP.y}, S.pSnapC)
    end

    if isPlayer and S.pNearest and entity.model and entity.model == S.nearestPlayerModel then
        local arrow = ">>> NEAREST <<<"
        drawShadowedString({coreSP.x - #arrow*3, headSP.y - 30}, S.pNearestC, arrow)
    end

    if (not isPlayer) and S.zNearest and entity.obj and entity.obj == S.nearestZombieObj then
        local alert = ">>> CLOSEST ZOMBIE <<<"
        drawShadowedString({coreSP.x - #alert*3, headSP.y - 30}, S.zNearestC, alert)
    end
end

local function drawVehicleESP(vehicle, sw, sh)
    if not vehicle.pos then return end
    local sp = safeW2S(vehicle.pos)
    if not sp then return end

    local d   = getLocalDistance(vehicle.pos)
    local col = vehicle.color or {0,180,255}

    if S.vBox then
        local sz = max(10, 50 - (d or 0)*0.03)
        drawBox({sp.x-sz, sp.y-sz*0.5}, {sp.x+sz, sp.y+sz*0.5}, col)
    end

    if S.vName then
        local displayName = CFG.VEHICLE_DISPLAY_NAME[vehicle.name] or vehicle.name
        local label = "["..vehicle.category.."] "..displayName
        drawShadowedString({sp.x - #label*3, sp.y - 20}, col, label)
    end

    if S.vDist then
        local distStr = d and (round(d, 0).."m") or "--"
        drawShadowedString({sp.x - #distStr*3, sp.y + 14}, S.vDistC, distStr)
    end

    if S.vTrace then
        drawLine({sw*0.5, sh}, {sp.x, sp.y}, col)
    end

    if S.vNearest and vehicle == (S.vehicles and S.vehicles[1]) then
        local arrow = ">>> NEAREST <<<"
        drawShadowedString({sp.x - #arrow*3, sp.y - 32}, S.vNearestC, arrow)
    end
end

local function drawLootESP(loot, sw, sh)
    if not loot.pos then return end
    local sp = safeW2S(loot.pos)
    if not sp then return end

    local d = getLocalDistance(loot.pos)

    if S.lBox then
        drawBox({sp.x-6, sp.y-6}, {sp.x+6, sp.y+6}, S.lBoxC)
    end

    if S.lName then
        drawShadowedString({sp.x - #loot.name*3, sp.y - 16}, S.lNameC, loot.name)
    end

    if S.lDist then
        local distStr = d and (round(d, 0).."m") or "--"
        drawShadowedString({sp.x - #distStr*3, sp.y + 10}, S.lDistC, distStr)
    end

    if S.lTrace then
        drawLine({sw*0.5, sh}, {sp.x, sp.y}, S.lTraceC)
    end
end



local function drawDeadBodyESP(body, sw, sh)
    if not body.pos then return end
    local sp = safeW2S(body.pos)
    if not sp then return end

    local d = getLocalDistance(body.pos)

    if S.dBox then
        drawBox({sp.x-8, sp.y-8}, {sp.x+8, sp.y+8}, S.dBoxC)
        -- X marker
        drawLine({sp.x-5, sp.y-5}, {sp.x+5, sp.y+5}, S.dBoxC)
        drawLine({sp.x+5, sp.y-5}, {sp.x-5, sp.y+5}, S.dBoxC)
    end

    if S.dName then
        local typeStr = body.zType and (body.zType.." Zombie") or body.bodyType
        local label   = "[DEAD "..typeStr.."] "..(body.name or "?")
        drawShadowedString({sp.x - #label*3, sp.y - 20}, S.dNameC, label)
        if S.dGear and body.gear then
            drawShadowedString({sp.x - #body.gear*3, sp.y - 34}, {210,170,170}, body.gear)
        end
    end

    if S.dDist then
        local distStr = d and (round(d, 0).."m") or "--"
        drawShadowedString({sp.x - #distStr*3, sp.y + 12}, S.dDistC, distStr)
    end

    if S.dTrace then
        drawLine({sw*0.5, sh}, {sp.x, sp.y}, S.dTraceC)
    end
end

-- ============================================================
-- CROSSHAIR
-- ============================================================
local function drawCrosshair(sw, sh)
    if not S.cross then return end
    local cx, cy = sw*0.5, sh*0.5
    local sz  = S.crossSz
    local gap = S.crossGap
    local col = S.crossC
    local st  = S.crossStyle

    if S.crossDot or st == 2 then
        dx9.DrawFilledBox({cx-1, cy-1}, {cx+2, cy+2}, col)
    end

    if st == 1 or st == 4 then
        drawLine({cx-sz-gap, cy}, {cx-gap, cy}, col)
        drawLine({cx+gap, cy}, {cx+sz+gap, cy}, col)
        drawLine({cx, cy-sz-gap}, {cx, cy-gap}, col)
        drawLine({cx, cy+gap}, {cx, cy+sz+gap}, col)
    end

    if st == 3 or st == 4 then
        local segs = 32
        local r    = sz + gap
        for i = 0, segs-1 do
            local a1 = (i/segs)*pi*2
            local a2 = ((i+1)/segs)*pi*2
            drawLine({cx+cos(a1)*r, cy+sin(a1)*r}, {cx+cos(a2)*r, cy+sin(a2)*r}, col)
        end
    end
end

local function getFovCircleRadius()
    local source = CFG.FOV_SOURCES[S.fovCircleSource] or "Auto"
    if source == "Player" then
        return S.pFov, S.pFovC
    end
    if source == "Zombie" then
        return S.zFov, S.zFovC
    end
    if S.pAim then
        return S.pFov, S.pFovC
    end
    if S.zAim then
        return S.zFov, S.zFovC
    end
    return S.pFov, S.pFovC
end

local function drawFOVCircle(sw, sh)
    if not S.fovCircle then return end
    local radius = getFovCircleRadius()
    if not radius or radius <= 0 then return end
    local cx, cy = sw * 0.5, sh * 0.5
    local col = S.fovCircleC
    local segs = 48
    for i = 0, segs - 1 do
        local a1 = (i / segs) * pi * 2
        local a2 = ((i + 1) / segs) * pi * 2
        drawLine(
            {cx + cos(a1) * radius, cy + sin(a1) * radius},
            {cx + cos(a2) * radius, cy + sin(a2) * radius},
            col
        )
    end
end
-- ============================================================
-- AIMBOT
-- ============================================================
local function projectAimPart(partObj)
    if not partObj or partObj == 0 then return nil, nil end
    local pos = safeGetPos(partObj)
    if not pos then return nil, nil end
    local sp = safeW2S(pos)
    if not sp then return nil, nil end
    return pos, sp
end

local function applyAimTarget(spX, spY, screenDist, aimType, cx, cy)
    S.aimX = spX
    S.aimY = spY
    S.aimCallX = spX
    S.aimCallY = spY
    S.aimDist = screenDist
    S.aimType = aimType
end

local function getPlayerAimCandidate(entity, aimPartName, cx, cy, sw, sh)
    if not entity or not entity.parts then return nil end

    local partObj, pos, sp
    local tried = {}
    local candidateParts = {
        aimPartName,
        "Head",
        "UpperTorso",
        "HumanoidRootPart",
        "LowerTorso",
        "Root",
    }

    for _, partName in ipairs(candidateParts) do
        if partName and not tried[partName] then
            tried[partName] = true
            local candidatePart = cachePart(entity.parts, entity.model, partName)
            local candidatePos, candidateSp = projectAimPart(candidatePart)
            if candidatePos and candidateSp and candidateSp.x >= 0 and candidateSp.x <= sw and candidateSp.y >= 0 and candidateSp.y <= sh then
                partObj, pos, sp = candidatePart, candidatePos, candidateSp
                break
            end
        end
    end

    if (not pos or not sp) and entity.core then
        local corePos, coreSp = projectAimPart(entity.core)
        if corePos and coreSp and coreSp.x >= 0 and coreSp.x <= sw and coreSp.y >= 0 and coreSp.y <= sh then
            partObj, pos, sp = entity.core, corePos, coreSp
        end
    end

    if not pos or not sp then return nil end

    local dx2 = sp.x - cx
    local dy2 = sp.y - cy
    local screenDist = sqrt(dx2*dx2 + dy2*dy2)
    if screenDist >= S.pFov then return nil end

    local worldDist
    local aimOrigin = getAimDistanceOrigin()
    if aimOrigin then
        worldDist = dist3d(pos, aimOrigin)
        if worldDist > (S.pMaxDist or 800) then
            return nil
        end
    end

    return {
        x = sp.x,
        y = sp.y,
        screenDist = screenDist,
        worldDist = worldDist,
    }
end

local function isBetterPlayerCandidate(candidate, bestCandidate)
    if not candidate then return false end
    if not bestCandidate then return true end

    if candidate.worldDist and bestCandidate.worldDist and candidate.worldDist ~= bestCandidate.worldDist then
        return candidate.worldDist < bestCandidate.worldDist
    end

    if candidate.worldDist and not bestCandidate.worldDist then
        return true
    end

    return candidate.screenDist < bestCandidate.screenDist
end

local function selectAimTarget(sw, sh)
    S.aimX, S.aimY, S.aimDist, S.aimType = nil, nil, 1e9, nil
    S.aimCallX, S.aimCallY = nil, nil

    local cx, cy = sw*0.5, sh*0.5

    -- Player Aimbot
    refreshPlayerStickyState()
    if S.pAim then
        local aimPartName = CFG.AIM_PARTS[S.pAimPart] or "Head"
        local stickyEnabled = S.pStickyAim == true

        if stickyEnabled and S.stickyAimPlayerModel then
            local stickyEntity = S.entityByModel and S.entityByModel[S.stickyAimPlayerModel]
            local stickyCandidate = (stickyEntity and not isLocalModel(stickyEntity.model, stickyEntity.ownerName))
                and getPlayerAimCandidate(stickyEntity, aimPartName, cx, cy, sw, sh) or nil
            if stickyCandidate then
                applyAimTarget(stickyCandidate.x, stickyCandidate.y, stickyCandidate.screenDist, "player", cx, cy)
            else
                clearStickyPlayerTarget()
            end
        end

        if not S.aimX then
            local bestEntity, bestCandidate
            for _, entity in ipairs(S.entities or {}) do
                local candidate = (not isLocalModel(entity.model, entity.ownerName))
                    and getPlayerAimCandidate(entity, aimPartName, cx, cy, sw, sh) or nil
                if isBetterPlayerCandidate(candidate, bestCandidate) then
                    bestCandidate = candidate
                    bestEntity = entity
                end
            end

            if bestCandidate then
                applyAimTarget(bestCandidate.x, bestCandidate.y, bestCandidate.screenDist, "player", cx, cy)
                if stickyEnabled and bestEntity and bestEntity.model then
                    S.stickyAimPlayerModel = bestEntity.model
                end
            end
        end
    end

    -- Zombie Aimbot (independent)
    if S.zAim and not S.aimX then
        local aimPartName = CFG.AIM_PARTS[S.zAimPart] or "Head"
        for _, z in ipairs(S.zombies or {}) do
            local partObj = (z.parts and z.parts[aimPartName]) or z.hrp
            if partObj and partObj ~= 0 then
                local pos = safeGetPos(partObj)
                if pos then
                    local sp = safeW2S(pos)
                    if sp and sp.x >= 0 and sp.x <= sw and sp.y >= 0 and sp.y <= sh then
                        local dx2 = sp.x - cx
                        local dy2 = sp.y - cy
                        local sd  = sqrt(dx2*dx2 + dy2*dy2)
                        if sd < S.zFov and sd < S.aimDist then
                            applyAimTarget(sp.x, sp.y, sd, "zombie", cx, cy)
                        end
                    end
                end
            end
        end
    end
end

local function executeAimbot(sw, sh)
    if not S.aimX then return false end
    local smooth = (S.aimType == "player") and S.pSmooth or S.zSmooth
    local sens   = (S.aimType == "player") and S.pSens   or S.zSens
    local mode   = (S.aimType == "player") and S.pAimMode or S.zAimMode
    local cx = floor(sw * 0.5)
    local cy = floor(sh * 0.5)
    local tx = (S.aimCallX or S.aimX) + cx
    local ty = (S.aimCallY or S.aimY) + cy

    local ok = false
    if mode == 2 then
        ok = pcall(dx9.ThirdPersonAim, {tx, ty}, smooth, smooth)
        if not ok then
            ok = pcall(dx9.FirstPersonAim, {tx, ty}, smooth, sens)
        end
    else
        ok = pcall(dx9.FirstPersonAim, {tx, ty}, smooth, sens)
        if not ok then
            ok = pcall(dx9.ThirdPersonAim, {tx, ty}, smooth, smooth)
        end
    end

    return ok
end

-- ============================================================
-- FPS COUNTER
-- ============================================================
local function updateFPS(now)
    S.fpsFrames = (S.fpsFrames or 0) + 1
    if now - (S.fpsTime or 0) >= 1.0 then
        S.fps     = S.fpsFrames
        S.fpsFrames = 0
        S.fpsTime  = now
    end
end

local function updateWatermark(now, ws)
    if not DXForge or not S.wmark then return end
    local sessionMin = round((now - S.sessionStart) / 60, 0)
    local location = S.showLocation and detectLocation(ws, now) or nil
    local text = "AR2 DOMINION  |  DX9 COI"
    if location and location ~= "" and location ~= "unknown" then
        text = text .. "  |  " .. location
    end
    text = text .. "  |  " .. sessionMin .. "m"
    DXForge:SetWatermark({
        Text = text,
        Visible = S.wmark,
    })
end

local function drawStatsOverlay(sw)
    if not S.statsOv then return end
    local playerCount = #(S.entities or {})
    local zombieCount = #(S.zombies or {})
    local vehicleCount = #(S.vehicles or {})
    local searchableCount = #(S.searchableLoot or {})
    local utilityCount = #(S.utilityObjects or {})
    local bodyCount = #(S.deadBodies or {})
    local lines = {
        "P: " .. playerCount,
        "Z: " .. zombieCount,
        "V: " .. vehicleCount,
        "S: " .. searchableCount,
        "U: " .. utilityCount,
        "B: " .. bodyCount,
    }
    local x = sw - 86
    local y = 38
    for i, text in ipairs(lines) do
        dx9.DrawString({x, y + ((i - 1) * 14)}, {180, 180, 190}, text)
    end
end

-- ============================================================
-- BUILD UI (DXForge)
-- ============================================================
local function buildUI()
    local win = DXForge:CreateWindow({
        Title      = "AR2 DOMINION v5.0.0",
        Size       = {620, 500},
        ToggleKey  = "[F6]",
        Resizable  = false,
        Footer     = true,
        Open       = true,
    })

    -- =================== TAB: ESP ===================
    do
        local tab = win:AddTab("ESP")

        local player = tab:AddGroupbox("Player ESP", "left")
        player:AddToggle({ Text="Enable Player ESP",  Default=S.pEsp,   Callback=function(v) S.pEsp=v end })
        player:AddToggle({ Text="Box",                Default=S.pBox,   Callback=function(v) S.pBox=v end })
        player:AddToggle({ Text="Name Tags",          Default=S.pName,  Callback=function(v) S.pName=v end })
        player:AddToggle({ Text="Distance",           Default=S.pDist,  Callback=function(v) S.pDist=v end })
        player:AddToggle({ Text="Health Bar",         Default=S.pHealth,Callback=function(v) S.pHealth=v end })
        player:AddToggle({ Text="Tracelines",         Default=S.pTrace, Callback=function(v) S.pTrace=v end })
        player:AddToggle({ Text="Skeleton",           Default=S.pSkel,  Callback=function(v) S.pSkel=v end })
        player:AddToggle({ Text="Snap Lines",         Default=S.pSnapLine, Callback=function(v) S.pSnapLine=v end })
        player:AddToggle({ Text="Nearest Indicator",  Default=S.pNearest, Callback=function(v) S.pNearest=v end })
        player:AddSlider({ Text="Max Distance", Min=50, Max=2000, Step=50, Default=S.pMaxDist,
            Callback=function(v) S.pMaxDist=v end })
        player:AddColorPicker({ Text="Box Color",  Default=S.pBoxC,   Callback=function(v) S.pBoxC=v end })
        player:AddColorPicker({ Text="Name Color", Default=S.pNameC,  Callback=function(v) S.pNameC=v end })
        player:AddColorPicker({ Text="Trace Color",Default=S.pTraceC, Callback=function(v) S.pTraceC=v end })
        player:AddColorPicker({ Text="Nearest Color",Default=S.pNearestC, Callback=function(v) S.pNearestC=v end })

        local zombie = tab:AddGroupbox("Zombie ESP", "right")
        zombie:AddToggle({ Text="Enable Zombie ESP", Default=S.zEsp,    Callback=function(v) S.zEsp=v end })
        zombie:AddToggle({ Text="Box",               Default=S.zBox,    Callback=function(v) S.zBox=v end })
        zombie:AddToggle({ Text="Name Tags",         Default=S.zName,   Callback=function(v) S.zName=v end })
        zombie:AddToggle({ Text="Distance",          Default=S.zDist,   Callback=function(v) S.zDist=v end })
        zombie:AddToggle({ Text="Health Bar",        Default=S.zHealth, Callback=function(v) S.zHealth=v end })
        zombie:AddToggle({ Text="Tracelines",        Default=S.zTrace,  Callback=function(v) S.zTrace=v end })
        zombie:AddToggle({ Text="Skeleton",          Default=S.zSkel,   Callback=function(v) S.zSkel=v end })
        zombie:AddToggle({ Text="Zombie Type Label", Default=S.zType,   Callback=function(v) S.zType=v end })
        zombie:AddToggle({ Text="Nearest Indicator", Default=S.zNearest, Callback=function(v) S.zNearest=v end })
        zombie:AddSlider({ Text="Max Distance", Min=50, Max=2000, Step=50, Default=S.zMaxDist,
            Callback=function(v) S.zMaxDist=v end })
        zombie:AddColorPicker({ Text="Box Color",  Default=S.zBoxC,   Callback=function(v) S.zBoxC=v end })
        zombie:AddColorPicker({ Text="Name Color", Default=S.zNameC,  Callback=function(v) S.zNameC=v end })
        zombie:AddColorPicker({ Text="Nearest Color", Default=S.zNearestC, Callback=function(v) S.zNearestC=v end })

        local vehicle = tab:AddGroupbox("Vehicle ESP", "left")
        vehicle:AddToggle({ Text="Enable Vehicle ESP", Default=S.vEsp,    Callback=function(v) S.vEsp=v end })
        vehicle:AddToggle({ Text="Box",                Default=S.vBox,    Callback=function(v) S.vBox=v end })
        vehicle:AddToggle({ Text="Name & Category",    Default=S.vName,   Callback=function(v) S.vName=v end })
        vehicle:AddToggle({ Text="Distance",           Default=S.vDist,   Callback=function(v) S.vDist=v end })
        vehicle:AddToggle({ Text="Tracelines",         Default=S.vTrace,  Callback=function(v) S.vTrace=v end })
        vehicle:AddToggle({ Text="Nearest Indicator",  Default=S.vNearest,Callback=function(v) S.vNearest=v end })
        vehicle:AddSlider({ Text="Max Distance", Min=100, Max=3000, Step=100, Default=S.vMaxDist,
            Callback=function(v) S.vMaxDist=v end })
        vehicle:AddColorPicker({ Text="Name Color",    Default=S.vNameC,   Callback=function(v) S.vNameC=v end })
        vehicle:AddColorPicker({ Text="Nearest Color", Default=S.vNearestC,Callback=function(v) S.vNearestC=v end })

        local loot = tab:AddGroupbox("Loot ESP", "right")
        loot:AddToggle({ Text="Enable Loot ESP", Default=S.lEsp,  Callback=function(v) S.lEsp=v end })
        loot:AddToggle({ Text="Box",             Default=S.lBox,  Callback=function(v) S.lBox=v end })
        loot:AddToggle({ Text="Name",            Default=S.lName, Callback=function(v) S.lName=v end })
        loot:AddToggle({ Text="Distance",        Default=S.lDist, Callback=function(v) S.lDist=v end })
        loot:AddToggle({ Text="Tracelines",      Default=S.lTrace,Callback=function(v) S.lTrace=v end })
        loot:AddSlider({ Text="Max Distance", Min=50, Max=1000, Step=25, Default=S.lMaxDist,
            Callback=function(v) S.lMaxDist=v end })
        loot:AddColorPicker({ Text="Box Color",  Default=S.lBoxC,  Callback=function(v) S.lBoxC=v end })
        loot:AddColorPicker({ Text="Name Color", Default=S.lNameC, Callback=function(v) S.lNameC=v end })


        local bodies = tab:AddGroupbox("Dead Body ESP", "full")
        bodies:AddToggle({ Text="Enable Dead Body ESP", Default=S.dEsp,       Callback=function(v) S.dEsp=v end })
        bodies:AddToggle({ Text="Box + X Marker",       Default=S.dBox,       Callback=function(v) S.dBox=v end })
        bodies:AddToggle({ Text="Name",                 Default=S.dName,      Callback=function(v) S.dName=v end })
        bodies:AddToggle({ Text="Distance",             Default=S.dDist,      Callback=function(v) S.dDist=v end })
        bodies:AddToggle({ Text="Tracelines",           Default=S.dTrace,     Callback=function(v) S.dTrace=v end })
        bodies:AddToggle({ Text="Show Equipment",       Default=S.dGear,      Callback=function(v) S.dGear=v end })
        bodies:AddToggle({ Text="Show Dead Zombies",    Default=S.dShowZombie,Callback=function(v) S.dShowZombie=v end })
        bodies:AddToggle({ Text="Show Dead Players",    Default=S.dShowPlayer,Callback=function(v) S.dShowPlayer=v end })
        bodies:AddSlider({ Text="Max Distance", Min=50, Max=2000, Step=50, Default=S.dMaxDist,
            Callback=function(v) S.dMaxDist=v end })
        bodies:AddColorPicker({ Text="Box Color",  Default=S.dBoxC,  Callback=function(v) S.dBoxC=v end })
        bodies:AddColorPicker({ Text="Name Color", Default=S.dNameC, Callback=function(v) S.dNameC=v end })

        local alerts = tab:AddGroupbox("Alerts", "full")
        alerts:AddToggle({ Text="Proximity Alert", Default=S.zProxAlert, Callback=function(v) S.zProxAlert=v end })
        alerts:AddSlider({ Text="Alert Distance", Min=10, Max=200, Step=5, Default=S.zProxDist,
            Callback=function(v) S.zProxDist=v end })
    end

    -- =================== TAB: Aimbot ===================
    do
        local tab = win:AddTab("Aimbot")

        local left = tab:AddGroupbox("Player Aimbot", "left")
        left:AddToggle({ Text="Enable Aimbot",   Default=S.pAim,    Callback=function(v) S.pAim=v end })
        left:AddToggle({ Text="Sticky Aim",      Default=S.pStickyAim, Callback=function(v) S.pStickyAim=v end })
        left:AddSlider({ Text="FOV",    Min=10, Max=1000, Step=10, Default=S.pFov,    Callback=function(v) S.pFov=v end })
        left:AddSlider({ Text="Smooth", Min=1,  Max=20,  Step=0.5, Default=S.pSmooth, Callback=function(v) S.pSmooth=v end })
        left:AddSlider({ Text="Sensitivity", Min=0.5, Max=10, Step=0.5, Default=S.pSens, Callback=function(v) S.pSens=v end })
        left:AddDropdown({ Text="Aim Part", Values=CFG.AIM_PARTS,  Default=CFG.AIM_PARTS[S.pAimPart],
            Callback=function(v)
                for i, p in ipairs(CFG.AIM_PARTS) do if p == v then S.pAimPart=i; break end end
            end })
        left:AddDropdown({ Text="Aim Mode", Values=CFG.AIM_MODES, Default=CFG.AIM_MODES[S.pAimMode],
            Callback=function(v)
                for i, m in ipairs(CFG.AIM_MODES) do if m == v then S.pAimMode=i; break end end
            end })

        local right = tab:AddGroupbox("Zombie Aimbot", "right")
        right:AddToggle({ Text="Enable Zombie Aimbot", Default=S.zAim, Callback=function(v) S.zAim=v end })
        right:AddSlider({ Text="FOV",    Min=10, Max=1000, Step=10, Default=S.zFov,    Callback=function(v) S.zFov=v end })
        right:AddSlider({ Text="Smooth", Min=1,  Max=20,  Step=0.5, Default=S.zSmooth, Callback=function(v) S.zSmooth=v end })
        right:AddSlider({ Text="Sensitivity", Min=0.5, Max=10, Step=0.5, Default=S.zSens, Callback=function(v) S.zSens=v end })
        right:AddDropdown({ Text="Aim Part", Values=CFG.AIM_PARTS, Default=CFG.AIM_PARTS[S.zAimPart],
            Callback=function(v)
                for i, p in ipairs(CFG.AIM_PARTS) do if p == v then S.zAimPart=i; break end end
            end })
        right:AddDropdown({ Text="Aim Mode", Values=CFG.AIM_MODES, Default=CFG.AIM_MODES[S.zAimMode],
            Callback=function(v)
                for i, m in ipairs(CFG.AIM_MODES) do if m == v then S.zAimMode=i; break end end
            end })

        local full = tab:AddGroupbox("FOV Circle", "full")
        full:AddToggle({ Text="Show FOV Circle", Default=S.fovCircle, Callback=function(v) S.fovCircle=v end })
        full:AddDropdown({ Text="FOV Source", Values=CFG.FOV_SOURCES, Default=CFG.FOV_SOURCES[S.fovCircleSource],
            Callback=function(v)
                for i, source in ipairs(CFG.FOV_SOURCES) do if source == v then S.fovCircleSource=i; break end end
            end })
        full:AddColorPicker({ Text="FOV Color", Default=S.fovCircleC, Callback=function(v) S.fovCircleC=v end })
    end

    -- =================== TAB: Visuals ===================
    do
        local tab  = win:AddTab("Visuals")
        local left = tab:AddGroupbox("Crosshair", "left")

        left:AddToggle({ Text="Enable Crosshair", Default=S.cross,    Callback=function(v) S.cross=v end })
        left:AddDropdown({ Text="Style", Values=CFG.CROSS_STYLES, Default=CFG.CROSS_STYLES[S.crossStyle],
            Callback=function(v)
                for i, s in ipairs(CFG.CROSS_STYLES) do if s == v then S.crossStyle=i; break end end
            end })
        left:AddSlider({ Text="Size", Min=2, Max=30, Step=1, Default=S.crossSz,   Callback=function(v) S.crossSz=v end })
        left:AddSlider({ Text="Gap",  Min=0, Max=15, Step=1, Default=S.crossGap,  Callback=function(v) S.crossGap=v end })
        left:AddToggle({ Text="Center Dot", Default=S.crossDot, Callback=function(v) S.crossDot=v end })
        left:AddColorPicker({ Text="Color", Default=S.crossC, Callback=function(v) S.crossC=v end })

        local right = tab:AddGroupbox("Overlays", "right")
        right:AddToggle({ Text="Watermark",   Default=S.wmark,  Callback=function(v) S.wmark=v end })
        right:AddToggle({ Text="FPS Counter", Default=S.fpsCtr, Callback=function(v) S.fpsCtr=v end })
        right:AddToggle({ Text="Stats Overlay", Default=S.statsOv, Callback=function(v) S.statsOv=v end })
        right:AddToggle({ Text="Show Location", Default=S.showLocation, Callback=function(v) S.showLocation=v end })
    end

    -- =================== TAB: Settings ===================
    do
        local tab = win:AddTab("Settings")
        local box = tab:AddGroupbox("General", "full")

        box:AddToggle({ Text="Show Console", Default=S.showConsole, Callback=function(v)
            S.showConsole = v
            pcall(dx9.ShowConsole, v)
        end })
        box:AddDivider("Script Info")
        box:AddLabel("AR2 DOMINION v5.0.0  |  DX9 Cult of Intellect")
        box:AddLabel("UI: DXForge v1.0.19  |  by Lorthanyx")
        box:AddLabel(#CFG.VEHICLE_NAMES .. " Vehicle Types  |  " .. #CFG.LOOT_CONTAINERS .. " Loot Containers")
        box:AddButton({ Text="Reset All Settings", Callback=function()
            _G.DOMINION_STATE = nil
            DXForge:Notify({ Text="Settings reset — please reload the script.", Type="Warning", Duration=5 })
        end })
    end

    -- Watermark
    DXForge:SetWatermark({ Text = "AR2 DOMINION  |  DX9 COI", Visible = S.wmark })

    return win
end

-- Build the UI once
local win = buildUI()
print("[AR2 DOMINION] UI built, starting render loop...")

-- ============================================================
-- MAIN RENDER LOOP
-- Supports both dx9.on_render runtimes and runtimes that re-execute
-- the script continuously.
-- ============================================================
local function renderFrame()
    local now = os.clock()
    if _G.AR2_DOMINION_RUNTIME then
        _G.AR2_DOMINION_RUNTIME.lastTick = now
    end
    -- Get DataModel once per frame
    local dm = getDataModel()
    if not dm then return end

    local ws  = findChild(dm, "Workspace")
    local pls = findChild(dm, "Players")
    if not ws then return end

    -- Refresh local player info
    refreshLocalPlayer(ws, pls, now)

    -- Refresh all entity caches
    if S.pEsp or S.pAim then
        refreshEntityCache(ws, pls, now)
    end
    if S.zEsp or S.zAim or S.zProxAlert then
        refreshZombieCache(ws, now)
    end
    if S.vEsp then
        refreshVehicleCache(ws, now)
    end
    if S.lEsp then
        refreshLootCache(ws, now)
    end

    if S.dEsp then
        refreshDeadBodyCache(ws, pls, now)
    end

    -- Screen dimensions
    local sz_frame = dx9.size()
    local sw = sz_frame.width
    local sh = sz_frame.height

    -- FPS update
    updateFPS(now)

    -- Aimbot target selection
    if S.pAim or S.zAim then
        selectAimTarget(sw, sh)
    end

    -- === ESP DRAWING ===

    -- Player ESP
    if S.pEsp then
        for _, entity in ipairs(S.entities or {}) do
            drawEntityESP(entity, "player", sw, sh)
        end
    end

    -- Zombie ESP
    if S.zEsp then
        for _, z in ipairs(S.zombies or {}) do
            -- Build a compatible entity table for drawEntityESP
            local entity = {
                head=z.parts and z.parts["Head"],
                foot=z.parts and z.parts["LeftFoot"],
                hrp=z.hrp,
                parts=z.parts,
                ownerName=nil,
                name=z.name,
                hp=z.hp,
                maxHp=z.maxHp,
                zType=z.zType,
            }
            drawEntityESP(entity, "zombie", sw, sh)
        end
    end

    -- Vehicle ESP
    if S.vEsp then
        for _, vehicle in ipairs(S.vehicles or {}) do
            drawVehicleESP(vehicle, sw, sh)
        end
    end

    -- Loot ESP
    if S.lEsp then
        for _, loot in ipairs(S.lootItems or {}) do
            drawLootESP(loot, sw, sh)
        end
    end


    -- Dead Body ESP
    if S.dEsp then
        for _, body in ipairs(S.deadBodies or {}) do
            drawDeadBodyESP(body, sw, sh)
        end
    end

    -- Aimbot execution
    if (S.pAim or S.zAim) and S.aimX then
        executeAimbot(sw, sh)
        -- Draw aimbot target crosshair
        dx9.DrawLine({S.aimX-6, S.aimY}, {S.aimX+6, S.aimY}, {255,100,100})
        dx9.DrawLine({S.aimX, S.aimY-6}, {S.aimX, S.aimY+6}, {255,100,100})
    end

    -- Crosshair
    drawCrosshair(sw, sh)
    drawFOVCircle(sw, sh)

    -- Watermark text (DXForge handles the styled watermark via SetWatermark)
    -- Update DXForge watermark visibility each frame
    if DXForge.Watermark then
        DXForge.Watermark.Visible = S.wmark
    end
    updateWatermark(now, ws)

    -- FPS counter overlay (drawn separately over everything)
    if S.fpsCtr then
        local fpsStr = "FPS: " .. (S.fps or 0)
        local sessionStr = "Session: " .. round((now - S.sessionStart)/60, 0) .. "m"
        dx9.DrawString({sw - #fpsStr*7 - 8, 8}, {200,200,200}, fpsStr)
        dx9.DrawString({sw - #sessionStr*7 - 8, 22}, {200,200,200}, sessionStr)
    end
    drawStatsOverlay(sw)

    -- Proximity Alert notification
    if S.zProxAlert and S.proxClosestDist < S.zProxDist then
        if now - (S.proxAlertLast or 0) > 3.0 then
            S.proxAlertLast = now
            DXForge:Notify({
                Text = "PROXIMITY ALERT: " .. (S.proxClosest or "Zombie")
                    .. " (" .. round(S.proxClosestDist, 0) .. "m)",
                Type = "Error",
                Duration = 3,
            })
        end
    end

    -- DXForge UI Render (always last — renders on top of ESP)
    DXForge:Render()
end

_G.AR2_DOMINION_RUNTIME = {
    renderFrame = renderFrame,
    dxforge = DXForge,
    window = win,
    lastBoot = os.clock(),
    lastTick = os.clock(),
}

local hooked = false
if dx9.on_render then
    local okHook, errHook = pcall(dx9.on_render, renderFrame)
    if okHook then
        hooked = true
        _G.AR2_DOMINION_RUNTIME.hooked = true
    else
        print("[AR2 DOMINION] WARNING: dx9.on_render failed: " .. tostring(errHook))
    end
end

if not hooked then
    local okFrame, errFrame = pcall(renderFrame)
    if not okFrame then
        print("[AR2 DOMINION] ERROR: renderFrame failed: " .. tostring(errFrame))
        return
    end
end

print("[AR2 DOMINION] Ready. Press [F6] to toggle UI.")
