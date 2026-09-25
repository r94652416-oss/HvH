-- ============================================================
-- EXO UNITED  •  HVH
-- Owner: @kp3g
-- RightShift = Menu
-- ============================================================
print("[EXO] Loading...")

-- ============================================================
-- ADONIS BYPASS LOADER
-- ============================================================
print("[EXO] Loading Adonis Bypass...")
local bypassOk, bypassErr = pcall(function()
    local src = game:HttpGet("https://rawscripts.net/raw/Universal-Script-Adonis-Bypass-241508")
    local fn = loadstring(src)
    if not fn then error("Adonis Bypass: loadstring returned nil") end
    return fn()
end)
if bypassOk then
    print("[EXO] Adonis Bypass loaded")
else
    warn("[EXO] Adonis Bypass failed: " .. tostring(bypassErr))
end
task.wait(0.5)

local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local VirtualInputManager= game:GetService("VirtualInputManager")
local VirtualUser        = game:GetService("VirtualUser")
local CoreGui            = game:GetService("CoreGui")
local Workspace          = game:GetService("Workspace")
local Drawing            = Drawing

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LP:GetMouse()

local MENU_KEY         = Enum.KeyCode.RightShift
local DEFAULT_TOGGLE   = Enum.KeyCode.F6
local DISCORD_INVITE   = "https://discord.gg/J3XAyXzap6"
local CONFIG_FOLDER    = "EXO_HVH_Configs"

-- ============================================================
-- CONFIG
-- ============================================================
local function defaultConfig()
    return {
        Settings = {
            StickyAim = true,
            KnockCheck = false,
            VisibleCheck = false,
        },
        Keybinds = {
            StickyAim = { Key = "Q", Mode = "Toggle" },
            AutoFire = { Key = "T", Mode = "Toggle" },
            SilentAim = "R",
            AimAssist = "G",
            Speed = "C",
            ESP = "U",
            SuperJump = "Z",
        },
        FOV = {
            Enabled = false,
            Size = 150,
            Thickness = 2,
            Color = Color3.fromRGB(255, 255, 255),
        },
        SilentAim = {
            Enabled = false,
            HitPart = "Head",
            UsePrediction = false,
            PredX = 0.133,
            PredY = 0.133,
            PredZ = 0.133,
            ShowTracer = true,
            ShowBox = true,
        },
        AimAssist = {
            Enabled = false,
            HitPart = "Closest Part",
            Smoothing = 0,
            UsePrediction = false,
            Prediction = 0.133,
        },
        AutoFire = {
            Enabled = false,
            Delay = 0.01,
            SpecificWeapons = false,
            Weapons = { "[Double-Barrel SG]", "[Revolver]", "[TacticalShotgun]" },
        },
        Spread = {
            Enabled = false,
            Amount = 1,
            SpecificWeapons = true,
            Weapons = { "[Double-Barrel SG]", "[TacticalShotgun]" },
        },
        Speed = { Enabled = false, Multiplier = 35, AntiFling = false },
        Visual = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            TargetColor = Color3.fromRGB(255, 60, 60),
        },
        SuperJump = { Enabled = false, Power = 500, Cooldown = 0.1, Key = "Z" },
        RapidFire = {
            Enabled = false,
            Delay = 0.01,
            SpecificWeapons = false,
            Weapons = { "[Revolver]", "[Double-Barrel SG]" },
        },
        TeleportBehind = {
            Enabled = false,
            Key = "V",
            Distance = 7,
        },
        Grab = {
            Enabled = false,
            Key = "H",
            Duration = 1,
        },
        ESP = {
            Tracers = false,
            TracerFollowMouse = false,
            Box = false,
            Skeleton = false,
            Name = false,
            Distance = false,
            Health = false,
            Color = Color3.fromRGB(0, 162, 255),
            HighlightColor = Color3.fromRGB(0, 162, 255),
            HighlightEnabled = false,
        },
    }
end

local Config = defaultConfig()

local VoidHeight       = 10000
local VoidCircleRadius = 1000
local VoidCircleSpeed  = 100
local BehindDistance   = 7
local VoidOnReload     = false
local BehindOnReady    = false
local LockViewHVH      = false
local StopHPPercent    = 5
local AntiAimEnabled   = false
local AntiAimSpeed     = 60
local AntiAimAxis      = "Y"
local AntiAimDuringVoid= false

local MENU_W = 420
local MENU_H = 620

local ManualTarget     = nil
local CurrentTarget    = nil
local ShotsFired       = 0
local isVoided         = false
local voidCircleAngle  = 0
local antiAimAngle     = 0
local camLockConn      = nil
local storedGround     = nil
local StoppedForTarget = false
local ToggleKey        = DEFAULT_TOGGLE
local GrabMode         = false
local GrabReturnPos    = nil
local PlayerRows       = {}
local TabFrames        = {}
local GunList          = {"[Double-Barrel SG]", "[TacticalShotgun]", "[Revolver]"}
local ESPData          = {}
local ESPEnabled       = false
local Enabled          = false

local isLocking            = false
local triggerEnabled       = false
local SpeedEnabled         = false
local BaseSpeed            = 16
local lastVisibleTarget    = nil
local lastTriggerClick     = 0
local lastSuperJump        = 0
local rapidFireActive      = false
local espLabels            = {}
local espDrawings          = {}

local aimTracer   = nil
local fovCircle   = nil
local aimBox      = nil

_G.EXO_DraggingSlider = false

local hasDrawing = (typeof(Drawing) == "table" and typeof(Drawing.new) == "function")

-- ============================================================
-- FULL RESET ON LOAD
-- ============================================================
local function resetEverything()
    VoidOnReload     = false
    BehindOnReady    = false
    LockViewHVH      = false
    AntiAimEnabled   = false
    AntiAimSpeed     = 60
    AntiAimAxis      = "Y"
    AntiAimDuringVoid= false
    Enabled          = false
    ESPEnabled       = false
    GrabMode         = false
    isVoided         = false
    StoppedForTarget = false
    SpeedEnabled     = false
    BaseSpeed        = 16
    isLocking        = false
    triggerEnabled   = false
    rapidFireActive  = false
    ManualTarget     = nil
    CurrentTarget    = nil
    ShotsFired       = 0
    voidCircleAngle  = 0
    antiAimAngle     = 0
    storedGround     = nil
    GrabReturnPos    = nil
    lastVisibleTarget= nil
    lastTriggerClick = 0
    lastSuperJump    = 0
    PlayerRows       = {}
    TabFrames        = {}
    ESPData          = {}
    espLabels        = {}
    espDrawings      = {}
    if aimTracer then aimTracer.Visible = false end
    if fovCircle then fovCircle.Visible = false end
    if aimBox then aimBox.Visible = false end
    ToggleKey = DEFAULT_TOGGLE
end

resetEverything()

local function getGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, pg = pcall(function() return LP:FindFirstChildOfClass("PlayerGui") end)
    if ok2 and pg then return pg end
    return CoreGui
end

local function getMousePos()
    local loc = UserInputService:GetMouseLocation()
    return Vector2.new(loc.X, loc.Y)
end

-- ============================================================
-- LOADING SCREEN
-- ============================================================
local function showLoadingScreen(onDone)
    local parent = getGuiParent()
    local gui = Instance.new("ScreenGui")
    gui.Name = "EXO_Loading"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.Parent = parent

    local root = Instance.new("Frame")
    root.Size = UDim2.fromScale(1, 1)
    root.BackgroundColor3 = Color3.fromRGB(10, 5, 12)
    root.BorderSizePixel = 0
    root.Parent = gui

    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(40, 8, 12)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(12, 6, 20)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(20, 15, 35)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(15, 15, 18)),
    })
    bgGrad.Rotation = 45
    bgGrad.Parent = root

    for i = 1, 25 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4))
        dot.BackgroundColor3 = (i % 3 == 0) and Color3.fromRGB(200, 40, 60) or Color3.fromRGB(130, 70, 180)
        dot.BackgroundTransparency = 0.4
        dot.Position = UDim2.fromScale(math.random(), math.random())
        dot.BorderSizePixel = 0
        dot.Parent = root
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = dot
        task.spawn(function()
            while dot.Parent do
                local t = math.random(3, 8)
                TweenService:Create(dot, TweenInfo.new(t, Enum.EasingStyle.Linear), {
                    Position = UDim2.fromScale(math.random(), math.random()),
                    BackgroundTransparency = math.random(20, 70) / 100
                }):Play()
                task.wait(t)
            end
        end)
    end

    local glow = Instance.new("ImageLabel")
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.fromScale(0.5, 0.42)
    glow.Size = UDim2.fromOffset(600, 600)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = Color3.fromRGB(180, 30, 50)
    glow.ImageTransparency = 0.75
    glow.Parent = root
    task.spawn(function()
        while glow.Parent do
            TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.5, Size = UDim2.fromOffset(680, 680)
            }):Play()
            task.wait(2)
            TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.85, Size = UDim2.fromOffset(600, 600)
            }):Play()
            task.wait(2)
        end
    end)

    local logo = Instance.new("Frame")
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.fromScale(0.5, 0.42)
    logo.Size = UDim2.fromOffset(360, 130)
    logo.BackgroundTransparency = 1
    logo.Parent = root

    local hL = Instance.new("TextLabel")
    hL.AnchorPoint = Vector2.new(0.5, 0.5)
    hL.Position = UDim2.new(-0.3, 0, 0.5, 0)
    hL.Size = UDim2.fromOffset(110, 130)
    hL.BackgroundTransparency = 1
    hL.Font = Enum.Font.GothamBlack
    hL.Text = "H"
    hL.TextColor3 = Color3.fromRGB(220, 30, 60)
    hL.TextScaled = true
    hL.TextStrokeTransparency = 0.3
    hL.TextStrokeColor3 = Color3.fromRGB(120, 10, 25)
    hL.TextTransparency = 1
    hL.Parent = logo

    local vM = Instance.new("TextLabel")
    vM.AnchorPoint = Vector2.new(0.5, 0.5)
    vM.Position = UDim2.new(0.5, 0, 0.5, 0)
    vM.Size = UDim2.fromOffset(0, 0)
    vM.BackgroundTransparency = 1
    vM.Font = Enum.Font.GothamBlack
    vM.Text = "V"
    vM.TextColor3 = Color3.fromRGB(255, 255, 255)
    vM.TextScaled = true
    vM.TextStrokeTransparency = 0.3
    vM.TextStrokeColor3 = Color3.fromRGB(60, 60, 70)
    vM.TextTransparency = 1
    vM.Parent = logo

    local hR = Instance.new("TextLabel")
    hR.AnchorPoint = Vector2.new(0.5, 0.5)
    hR.Position = UDim2.new(1.3, 0, 0.5, 0)
    hR.Size = UDim2.fromOffset(110, 130)
    hR.BackgroundTransparency = 1
    hR.Font = Enum.Font.GothamBlack
    hR.Text = "H"
    hR.TextColor3 = Color3.fromRGB(220, 30, 60)
    hR.TextScaled = true
    hR.TextStrokeTransparency = 0.3
    hR.TextStrokeColor3 = Color3.fromRGB(120, 10, 25)
    hR.TextTransparency = 1
    hR.Parent = logo

    local title = Instance.new("TextLabel")
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Position = UDim2.fromScale(0.5, 0.56)
    title.Size = UDim2.fromOffset(360, 26)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "EXO UNITED  •  HVH"
    title.TextColor3 = Color3.fromRGB(220, 220, 230)
    title.TextSize = 16
    title.TextTransparency = 1
    title.Parent = root

    local sub = Instance.new("TextLabel")
    sub.AnchorPoint = Vector2.new(0.5, 0.5)
    sub.Position = UDim2.fromScale(0.5, 0.62)
    sub.Size = UDim2.fromOffset(360, 18)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "loading modules..."
    sub.TextColor3 = Color3.fromRGB(180, 160, 200)
    sub.TextSize = 12
    sub.TextTransparency = 1
    sub.Parent = root

    local creditsFrame = Instance.new("Frame")
    creditsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    creditsFrame.Position = UDim2.fromScale(0.5, 0.72)
    creditsFrame.Size = UDim2.fromOffset(300, 70)
    creditsFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 30)
    creditsFrame.BackgroundTransparency = 1
    creditsFrame.BorderSizePixel = 0
    creditsFrame.Parent = root
    local cfC = Instance.new("UICorner"); cfC.CornerRadius = UDim.new(0, 10); cfC.Parent = creditsFrame
    local cfS = Instance.new("UIStroke"); cfS.Color = Color3.fromRGB(200, 40, 60); cfS.Thickness = 1; cfS.Transparency = 1; cfS.Parent = creditsFrame

    local function credit(text, color, y)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 20)
        l.Position = UDim2.fromOffset(0, y)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamMedium
        l.Text = text
        l.TextColor3 = color
        l.TextSize = 12
        l.TextTransparency = 1
        l.Parent = creditsFrame
        return l
    end

    local c1 = credit("Owner • Coder • Developer • Modeler", Color3.fromRGB(255, 220, 140), 4)
    local c2 = credit("@kp3g", Color3.fromRGB(255, 140, 160), 24)
    local c3 = credit("HVH Loader", Color3.fromRGB(180, 180, 200), 44)

    local barBg = Instance.new("Frame")
    barBg.AnchorPoint = Vector2.new(0.5, 0.5)
    barBg.Position = UDim2.fromScale(0.5, 0.88)
    barBg.Size = UDim2.fromOffset(320, 8)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 15, 25)
    barBg.BorderSizePixel = 0
    barBg.BackgroundTransparency = 1
    barBg.Parent = root
    local bbC = Instance.new("UICorner"); bbC.CornerRadius = UDim.new(1,0); bbC.Parent = barBg

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromScale(0, 1)
    bar.BackgroundColor3 = Color3.fromRGB(220, 30, 60)
    bar.BorderSizePixel = 0
    bar.Parent = barBg
    local bC = Instance.new("UICorner"); bC.CornerRadius = UDim.new(1,0); bC.Parent = bar
    local bGrad = Instance.new("UIGradient")
    bGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 20, 50)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 60, 90)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 20, 50)),
    })
    bGrad.Parent = bar

    task.spawn(function()
        task.wait(0.1)
        local fadeTargets = {
            {obj = title,  prop = "TextTransparency", to = 0},
            {obj = sub,    prop = "TextTransparency", to = 0},
            {obj = c1,     prop = "TextTransparency", to = 0},
            {obj = c2,     prop = "TextTransparency", to = 0},
            {obj = c3,     prop = "TextTransparency", to = 0},
            {obj = barBg,  prop = "BackgroundTransparency", to = 0},
            {obj = cfS,    prop = "Transparency", to = 0.5},
            {obj = creditsFrame, prop = "BackgroundTransparency", to = 0.3},
        }
        for _, t in ipairs(fadeTargets) do
            TweenService:Create(t.obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {[t.prop] = t.to}):Play()
        end
        task.wait(0.2)
        TweenService:Create(hL, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.3, 0, 0.5, 0), TextTransparency = 0
        }):Play()
        task.wait(0.15)
        TweenService:Create(hR, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.7, 0, 0.5, 0), TextTransparency = 0
        }):Play()
        task.wait(0.3)
        TweenService:Create(vM, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(110, 130), TextTransparency = 0
        }):Play()
    end)

    local startT = tick()
    local DURATION = 3.0
    local finished = false
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local p = math.clamp((tick() - startT) / DURATION, 0, 1)
        bar.Size = UDim2.fromScale(p, 1)
        if p < 0.3 then sub.Text = "initializing..."
        elseif p < 0.6 then sub.Text = "loading modules..."
        elseif p < 0.85 then sub.Text = "injecting..."
        else sub.Text = "ready." end
        if p >= 1 and not finished then
            finished = true
            conn:Disconnect()
            task.wait(0.4)
            TweenService:Create(root, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("TextLabel") then
                    TweenService:Create(d, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
                elseif d:IsA("Frame") then
                    pcall(function() TweenService:Create(d, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play() end)
                elseif d:IsA("ImageLabel") then
                    TweenService:Create(d, TweenInfo.new(0.6), {ImageTransparency = 1}):Play()
                elseif d:IsA("UIStroke") then
                    TweenService:Create(d, TweenInfo.new(0.6), {Transparency = 1}):Play()
                end
            end
            task.wait(0.7)
            gui:Destroy()
            if onDone then onDone() end
        end
    end)
end

-- ============================================================
-- UTILITIES
-- ============================================================
local function getHitbox(p)
    local c = p and p.Character
    if not c then return nil end
    local r = c:FindFirstChild("HumanoidRootPart")
    if not r then return nil end
    local a = r:FindFirstChild("RootAttachment")
    if a then
        local hb = a:FindFirstChild("Hitbox")
        if hb then return hb end
    end
    return r
end

local function getTorso(target)
    if not target or not target.Character then return nil end
    local c = target.Character
    return c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("HumanoidRootPart")
end

local function getEquippedGun()
    local char = LP.Character
    if not char then return nil end
    local eq = char:FindFirstChildOfClass("Tool")
    if eq then
        for _, n in ipairs(GunList) do if eq.Name == n then return eq end end
    end
    return nil
end

local function getAmmo()
    local g = getEquippedGun()
    if not g then return 0, 0 end
    local a = g:FindFirstChild("Ammo")
    local m = g:FindFirstChild("MaxAmmo")
    return a and a.Value or 0, m and m.Value or 0
end

local function isReloading()
    local a, _ = getAmmo()
    return a <= 0
end

local function getGunWithAmmo()
    local char = LP.Character
    if not char then return nil end
    local backpack = LP:FindFirstChildOfClass("Backpack")
    local priority = {"[Double-Barrel SG]", "[TacticalShotgun]", "[Revolver]"}
    for _, n in ipairs(priority) do
        local c1 = char:FindFirstChild(n)
        if c1 then
            local a = c1:FindFirstChild("Ammo")
            if a and a.Value > 0 then return c1 end
        end
        if backpack then
            local c2 = backpack:FindFirstChild(n)
            if c2 then
                local a = c2:FindFirstChild("Ammo")
                if a and a.Value > 0 then return c2 end
            end
        end
    end
    return nil
end

local function forceEquipDB()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local bp = LP:FindFirstChildOfClass("Backpack")
    local db = char:FindFirstChild("[Double-Barrel SG]") or (bp and bp:FindFirstChild("[Double-Barrel SG]"))
    if db and db.Parent ~= char then hum:EquipTool(db) end
end

local function getTargetHPPercent(target)
    if not target or not target.Character then return nil end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    if hum.MaxHealth <= 0 then return nil end
    return (hum.Health / hum.MaxHealth) * 100
end

-- ============================================================
-- TELEPORT BEHIND
-- ============================================================
local function teleportBehindTarget()
    local target = ManualTarget
    if not target or not target.Character then
        local closest = findClosestTarget()
        if closest then
            target = Players:GetPlayerFromCharacter(closest.Parent)
        end
    end
    if not target or not target.Character then return end

    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return end

    local look = tRoot.CFrame.LookVector
    local goal = tRoot.Position - look * Config.TeleportBehind.Distance
    myRoot.CFrame = CFrame.new(goal, tRoot.Position)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    myRoot.AssemblyAngularVelocity = Vector3.zero
end

-- ============================================================
-- ACCURACY HELPERS
-- ============================================================
local function isPlayerKnockedOrKO(player)
    if not Config.Settings.KnockCheck then return false end
    if player and player.Character then
        local be = player.Character:FindFirstChild("BodyEffects")
        if be then
            local ko = be:FindFirstChild("K.O")
            if ko and ko.Value == true then return true end
            local kn = be:FindFirstChild("Knocked")
            if kn and kn.Value == true then return true end
        end
    end
    return false
end

local function isSelfKnocked()
    if LP.Character then
        local be = LP.Character:FindFirstChild("BodyEffects")
        if be then
            local ko = be:FindFirstChild("K.O")
            if ko and ko.Value == true then return true end
        end
    end
    return false
end

local function canSeeTarget(part)
    if not Config.Settings.VisibleCheck then return true end
    if not part or not part.Parent then return false end
    local character = part.Parent
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LP.Character, character}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true
    local res = Workspace:Raycast(origin, direction, rp)
    return res == nil or res.Instance:IsDescendantOf(character)
end

local function getClosestBodyPart(character)
    local closest, shortest = nil, math.huge
    local parts = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("UpperTorso"),
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChild("LowerTorso"),
        character:FindFirstChild("LeftUpperArm"),
        character:FindFirstChild("RightUpperArm"),
        character:FindFirstChild("LeftLowerArm"),
        character:FindFirstChild("RightLowerArm"),
        character:FindFirstChild("LeftHand"),
        character:FindFirstChild("RightHand"),
        character:FindFirstChild("LeftUpperLeg"),
        character:FindFirstChild("RightUpperLeg"),
        character:FindFirstChild("LeftLowerLeg"),
        character:FindFirstChild("RightLowerLeg"),
        character:FindFirstChild("LeftFoot"),
        character:FindFirstChild("RightFoot"),
    }
    local center = getMousePos()
    for _, part in pairs(parts) do
        if part then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and pos.Z > 0 then
                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if d < shortest then shortest = d closest = part end
            end
        end
    end
    return closest
end

local function isPartInFOV(part)
    if not Config.FOV.Enabled then return true end
    if not part then return false end
    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen or pos.Z <= 0 then return false end
    local mouseVec = getMousePos()
    local dist = (Vector2.new(pos.X, pos.Y) - mouseVec).Magnitude
    return dist <= Config.FOV.Size
end

function findClosestTarget()
    local closestTarget, shortestDistance = nil, math.huge
    local mouseVec = getMousePos()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not isPlayerKnockedOrKO(player) then
                local targetPart
                if Config.SilentAim.HitPart == "Closest Part" then
                    targetPart = getClosestBodyPart(player.Character)
                else
                    targetPart = player.Character:FindFirstChild(Config.SilentAim.HitPart)
                end
                if targetPart and canSeeTarget(targetPart) and isPartInFOV(targetPart) then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen and pos.Z > 0 then
                        local dist = (Vector2.new(pos.X, pos.Y) - mouseVec).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

local function getPredictedPosition(part)
    if not part then return nil end
    if not Config.SilentAim.UsePrediction then return part.Position end
    local vel = part.AssemblyLinearVelocity or part.Velocity or Vector3.new()
    return part.Position + Vector3.new(
        vel.X * Config.SilentAim.PredX,
        vel.Y * Config.SilentAim.PredY,
        vel.Z * Config.SilentAim.PredZ
    )
end

local function getSilentAimPart()
    if ManualTarget and ManualTarget.Character then
        local char = ManualTarget.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            if Config.SilentAim.HitPart == "Closest Part" then
                return getClosestBodyPart(char)
            else
                return char:FindFirstChild(Config.SilentAim.HitPart)
            end
        end
    end
    return findClosestTarget()
end

-- ============================================================
-- DRAWINGS
-- ============================================================
pcall(function()
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Thickness = Config.FOV.Thickness
    fovCircle.Color = Config.FOV.Color
    fovCircle.Filled = false
    fovCircle.Radius = Config.FOV.Size
    fovCircle.NumSides = 80
    fovCircle.Transparency = 1

    aimTracer = Drawing.new("Line")
    aimTracer.Visible = false
    aimTracer.Thickness = 1.5
    aimTracer.Color = Config.Visual.TargetColor
    aimTracer.Transparency = 1
    aimTracer.From = Vector2.new(0, 0)
    aimTracer.To = Vector2.new(0, 0)

    aimBox = Drawing.new("Square")
    aimBox.Visible = false
    aimBox.Thickness = 1.5
    aimBox.Color = Color3.fromRGB(255, 255, 255)
    aimBox.Filled = false
    aimBox.Size = Vector2.new(0, 0)
end)

local function updateFOVCircle()
    if not fovCircle then return end
    if not Config.FOV.Enabled then
        fovCircle.Visible = false
        return
    end
    fovCircle.Position = getMousePos()
    fovCircle.Radius = Config.FOV.Size
    fovCircle.Thickness = Config.FOV.Thickness
    fovCircle.Color = Config.FOV.Color
    fovCircle.Visible = true
end

local function updateAimVisuals()
    if not aimTracer or not aimBox then return end
    if not Config.SilentAim.Enabled then
        aimTracer.Visible = false
        aimBox.Visible = false
        return
    end
    local usePart = getSilentAimPart()
    if not usePart or not usePart.Parent then
        aimTracer.Visible = false
        aimBox.Visible = false
        return
    end
    local char = usePart.Parent
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or root

    if Config.SilentAim.ShowTracer and torso then
        local torsoPos, onScr = Camera:WorldToViewportPoint(torso.Position)
        if onScr and torsoPos.Z > 0 then
            aimTracer.From = getMousePos()
            aimTracer.To = Vector2.new(torsoPos.X, torsoPos.Y)
            aimTracer.Color = Config.Visual.TargetColor
            aimTracer.Visible = true
        else
            aimTracer.Visible = false
        end
    else
        aimTracer.Visible = false
    end

    if Config.SilentAim.ShowBox and head and root then
        local headPos, hOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos, lOn = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        if hOn and lOn then
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height / 2
            local rootPos = Camera:WorldToViewportPoint(root.Position)
            local padding = 6
            aimBox.Size = Vector2.new(width + padding * 2, height + padding * 2)
            aimBox.Position = Vector2.new(rootPos.X - width/2 - padding, headPos.Y - padding)
            aimBox.Color = Color3.fromRGB(255, 255, 255)
            aimBox.Visible = true
        else
            aimBox.Visible = false
        end
    else
        aimBox.Visible = false
    end
end

-- ============================================================
-- AIM ASSIST
-- ============================================================
local function applyAimAssist()
    if not Config.AimAssist.Enabled then return end
    if isSelfKnocked() then return end

    local target = nil
    if ManualTarget and ManualTarget.Character then
        local char = ManualTarget.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            if Config.AimAssist.HitPart == "Closest Part" then
                target = getClosestBodyPart(char)
            else
                target = char:FindFirstChild(Config.AimAssist.HitPart)
            end
        end
    end
    if not target then
        target = findClosestTarget()
    end
    if not target then return end

    local targetPos = target.Position
    if Config.AimAssist.UsePrediction then
        local vel = target.AssemblyLinearVelocity or target.Velocity or Vector3.new()
        targetPos = target.Position + vel * Config.AimAssist.Prediction
    end

    local camCF = Camera.CFrame
    local tgtCF = CFrame.new(camCF.Position, targetPos)

    local smooth = Config.AimAssist.Smoothing
    if smooth <= 0 then
        Camera.CFrame = tgtCF
    else
        local alpha = math.clamp(1 / smooth, 0.01, 1)
        Camera.CFrame = camCF:Lerp(tgtCF, alpha)
    end
end

-- ============================================================
-- AUTO-FIRE
-- ============================================================
local function AutoFire()
    if not Config.AutoFire.Enabled or not triggerEnabled then return end
    if tick() - lastTriggerClick < Config.AutoFire.Delay then return end
    local tgt = nil
    if ManualTarget and ManualTarget.Character then
        local p = ManualTarget.Character:FindFirstChild(Config.SilentAim.HitPart) or ManualTarget.Character:FindFirstChild("Head")
        if p then tgt = p end
    end
    if not tgt then tgt = findClosestTarget() end
    if not tgt then return end
    local character = tgt.Parent
    if not character then return end
    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end
    if isPlayerKnockedOrKO(player) then return end
    if not canSeeTarget(tgt) then return end
    local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    if Config.AutoFire.SpecificWeapons then
        local valid = false
        for _, w in ipairs(Config.AutoFire.Weapons) do
            if tool.Name == w then valid = true break end
        end
        if not valid then return end
    end
    tool:Activate()
    lastTriggerClick = tick()
end

-- ============================================================
-- SILENT AIM HOOK
-- ============================================================
pcall(function()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if checkcaller() then return oldIndex(self, key) end
        if not Config.SilentAim.Enabled then return oldIndex(self, key) end
        if self ~= Mouse then return oldIndex(self, key) end

        if key == "Hit" or key == "Target" then
            local usePart = getSilentAimPart()
            if not usePart then return oldIndex(self, key) end
            local character = usePart.Parent
            if not character then return oldIndex(self, key) end
            local player = Players:GetPlayerFromCharacter(character)
            if player and isPlayerKnockedOrKO(player) then return oldIndex(self, key) end
            if not canSeeTarget(usePart) then return oldIndex(self, key) end
            local predPos = getPredictedPosition(usePart)
            if key == "Hit" then return CFrame.new(predPos) end
            if key == "Target" then return usePart end
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)
end)

-- ============================================================
-- SPREAD HOOK
-- ============================================================
pcall(function()
    local oldRandom
    oldRandom = hookfunction(math.random, function(...)
        local args = {...}
        if checkcaller() then return oldRandom(...) end
        if not Config.Spread.Enabled then return oldRandom(...) end
        local isSpread = (#args == 0) or (args[1] == -0.05 and args[2] == 0.05) or (args[1] == -0.1) or (args[1] == -0.05)
        if isSpread then
            local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
            if Config.Spread.SpecificWeapons then
                if tool then
                    for _, w in ipairs(Config.Spread.Weapons) do
                        if tool.Name == w then
                            return oldRandom(...) * (Config.Spread.Amount / 100)
                        end
                    end
                end
                return oldRandom(...)
            else
                return oldRandom(...) * (Config.Spread.Amount / 100)
            end
        end
        return oldRandom(...)
    end)
end)

-- ============================================================
-- HIGHLIGHTS
-- ============================================================
local function makeESP(player, color)
    if not player or not player.Character then return end
    if ESPData[player] and ESPData[player].highlight and ESPData[player].highlight.Parent then
        ESPData[player].highlight.FillColor = color
        return
    end
    if ESPData[player] then ESPData[player] = nil end
    local hl = Instance.new("Highlight")
    hl.Name = "EXO_ESP"
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = player.Character
    hl.Parent = player.Character
    ESPData[player] = {highlight = hl}
end

local function removeESP(player)
    if ESPData[player] then
        if ESPData[player].highlight and ESPData[player].highlight.Parent then
            ESPData[player].highlight:Destroy()
        end
        ESPData[player] = nil
    end
end

local function updateESPFor(player)
    if not ESPEnabled then removeESP(player) return end
    if not player.Character then return end
    if player == ManualTarget then
        makeESP(player, Config.Visual.TargetColor)
    else
        makeESP(player, Config.ESP.HighlightColor)
    end
end

local function hookCharacter(player)
    player.CharacterRemoving:Connect(function()
        if ESPData[player] then
            if ESPData[player].highlight and ESPData[player].highlight.Parent then
                ESPData[player].highlight:Destroy()
            end
            ESPData[player] = nil
        end
    end)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPEnabled then updateESPFor(player) end
    end)
end

Players.PlayerAdded:Connect(function(p)
    hookCharacter(p)
    if p.Character then updateESPFor(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
    if espDrawings[p] then
        for _, obj in pairs(espDrawings[p]) do
            if typeof(obj) == "table" then
                for _, line in pairs(obj) do pcall(function() line:Remove() end) end
            else
                pcall(function() obj:Remove() end)
            end
        end
        espDrawings[p] = nil
    end
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then hookCharacter(p) end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if ESPEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and (not ESPData[p] or not ESPData[p].highlight or not ESPData[p].highlight.Parent) then
                    updateESPFor(p)
                end
            end
        end
    end
end)

-- ============================================================
-- ESP DRAWINGS
-- ============================================================
local skeletonPairs = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function initESPDrawings(player)
    if not hasDrawing then return end
    espDrawings[player] = {
        Tracer = Drawing.new("Line"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
        Skeleton = {}
    }
    for i = 1, #skeletonPairs do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1.5
        espDrawings[player].Skeleton[i] = line
    end
    local d = espDrawings[player]
    d.Tracer.Visible = false
    d.Tracer.Thickness = 1.5
    d.Box.Visible = false
    d.Box.Filled = false
    d.Box.Thickness = 1.5
    d.Name.Visible = false
    d.Name.Size = 13
    d.Name.Center = true
    d.Name.Outline = true
    d.Distance.Visible = false
    d.Distance.Size = 13
    d.Distance.Center = true
    d.Distance.Outline = true
    d.HealthBar.Visible = false
    d.HealthBar.Filled = true
    d.HealthText.Visible = false
    d.HealthText.Size = 12
    d.HealthText.Center = true
    d.HealthText.Outline = true
end

local function updateESP()
    if not hasDrawing then return end
    local tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    if Config.ESP.TracerFollowMouse then
        tracerOrigin = getMousePos()
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            if not espDrawings[player] then initESPDrawings(player) end
            local drawings = espDrawings[player]
            if drawings then
                local character = player.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                if character and rootPart and humanoid and humanoid.Health > 0 then
                    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local headPart = character:FindFirstChild("Head")
                        local topVector = headPart and Camera:WorldToViewportPoint(headPart.Position + Vector3.new(0, 0.5, 0)) or vector
                        local legVector = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(topVector.Y - legVector.Y)
                        local width = height / 2

                        if Config.ESP.Box then
                            drawings.Box.Visible = true
                            drawings.Box.Size = Vector2.new(width, height)
                            drawings.Box.Position = Vector2.new(vector.X - width / 2, topVector.Y)
                            drawings.Box.Color = Config.ESP.Color
                        else drawings.Box.Visible = false end

                        if Config.ESP.Name then
                            drawings.Name.Visible = true
                            drawings.Name.Text = player.DisplayName or player.Name
                            drawings.Name.Position = Vector2.new(vector.X, legVector.Y + 4)
                            drawings.Name.Color = Config.ESP.Color
                        else drawings.Name.Visible = false end

                        if Config.ESP.Distance then
                            local localRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if localRoot then
                                local dist = math.floor((localRoot.Position - rootPart.Position).Magnitude)
                                drawings.Distance.Visible = true
                                drawings.Distance.Text = "[" .. dist .. "m]"
                                drawings.Distance.Position = Vector2.new(vector.X, (Config.ESP.Name and legVector.Y + 18 or legVector.Y + 4))
                                drawings.Distance.Color = Config.ESP.Color
                            else drawings.Distance.Visible = false end
                        else drawings.Distance.Visible = false end

                        if Config.ESP.Health then
                            local hp = humanoid.Health / humanoid.MaxHealth
                            local barHeight = height
                            drawings.HealthBar.Visible = true
                            drawings.HealthBar.Size = Vector2.new(3, barHeight * hp)
                            drawings.HealthBar.Position = Vector2.new(vector.X - width/2 - 6, topVector.Y + barHeight * (1 - hp))
                            drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - hp)
                            drawings.HealthText.Visible = true
                            drawings.HealthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                            drawings.HealthText.Position = Vector2.new(vector.X, topVector.Y - 16)
                            drawings.HealthText.Color = Color3.fromRGB(255, 255, 255)
                        else
                            drawings.HealthBar.Visible = false
                            drawings.HealthText.Visible = false
                        end

                        if Config.ESP.Tracers then
                            drawings.Tracer.Visible = true
                            drawings.Tracer.From = tracerOrigin
                            drawings.Tracer.To = Vector2.new(vector.X, legVector.Y)
                            drawings.Tracer.Color = Config.ESP.Color
                        else drawings.Tracer.Visible = false end

                        if Config.ESP.Skeleton then
                            for i, pair in ipairs(skeletonPairs) do
                                local partA = character:FindFirstChild(pair[1])
                                local partB = character:FindFirstChild(pair[2])
                                local line = drawings.Skeleton[i]
                                if partA and partB and line then
                                    local posA, onA = Camera:WorldToViewportPoint(partA.Position)
                                    local posB, onB = Camera:WorldToViewportPoint(partB.Position)
                                    if onA or onB then
                                        line.Visible = true
                                        line.From = Vector2.new(posA.X, posA.Y)
                                        line.To = Vector2.new(posB.X, posB.Y)
                                        line.Color = Config.ESP.Color
                                    else line.Visible = false end
                                elseif line then
                                    line.Visible = false
                                end
                            end
                        else
                            for _, line in pairs(drawings.Skeleton) do line.Visible = false end
                        end
                    else
                        drawings.Tracer.Visible = false
                        drawings.Box.Visible = false
                        drawings.Name.Visible = false
                        drawings.Distance.Visible = false
                        drawings.HealthBar.Visible = false
                        drawings.HealthText.Visible = false
                        for _, line in pairs(drawings.Skeleton) do line.Visible = false end
                    end
                else
                    drawings.Tracer.Visible = false
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                    drawings.Distance.Visible = false
                    drawings.HealthBar.Visible = false
                    drawings.HealthText.Visible = false
                    for _, line in pairs(drawings.Skeleton) do line.Visible = false end
                end
            end
        end
    end
end

-- ============================================================
-- GRAB / ANTI-AIM / VOID
-- ============================================================
local function pressG()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
    end)
end

local function startGrab()
    if GrabMode then return end
    if not ManualTarget or not ManualTarget.Character then return end
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local theirTorso = getTorso(ManualTarget)
    if not myRoot or not theirTorso then return end
    GrabReturnPos = myRoot.CFrame
    GrabMode = true
    myRoot.CFrame = CFrame.new(theirTorso.Position + Vector3.new(0, 0.5, 0), theirTorso.Position)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    myRoot.AssemblyAngularVelocity = Vector3.zero
    task.spawn(function()
        task.wait(0.15)
        if not GrabMode then return end
        pressG()
        task.wait(Config.Grab.Duration)
        if not GrabMode then return end
        local curRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if curRoot and GrabReturnPos then
            curRoot.CFrame = GrabReturnPos
            curRoot.AssemblyLinearVelocity = Vector3.zero
            curRoot.AssemblyAngularVelocity = Vector3.zero
        end
        task.wait(0.05)
        pressG()
        GrabMode = false
        GrabReturnPos = nil
    end)
end

local function applyAntiAim(dt)
    if not AntiAimEnabled then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    antiAimAngle = antiAimAngle + AntiAimSpeed * dt
    if antiAimAngle > math.pi * 2 then antiAimAngle = antiAimAngle - math.pi * 2 end
    local cf
    if AntiAimAxis == "X" then cf = CFrame.Angles(antiAimAngle, 0, 0)
    elseif AntiAimAxis == "Y" then cf = CFrame.Angles(0, antiAimAngle, 0)
    elseif AntiAimAxis == "Z" then cf = CFrame.Angles(0, 0, antiAimAngle)
    elseif AntiAimAxis == "XYZ" then cf = CFrame.Angles(antiAimAngle, antiAimAngle * 1.3, antiAimAngle * 0.7)
    else cf = CFrame.Angles(0, antiAimAngle, 0) end
    root.CFrame = CFrame.new(root.Position) * cf
    root.AssemblyAngularVelocity = Vector3.zero
end

local function voidDrift(dt)
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    if not isVoided then isVoided = true voidCircleAngle = 0 end
    voidCircleAngle = voidCircleAngle + VoidCircleSpeed * dt
    local offset = Vector3.new(math.cos(voidCircleAngle) * VoidCircleRadius, 0, math.sin(voidCircleAngle) * VoidCircleRadius)
    local goal = Vector3.new(myRoot.Position.X + offset.X * dt * 4, VoidHeight, myRoot.Position.Z + offset.Z * dt * 4)
    myRoot.CFrame = CFrame.new(goal)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    myRoot.AssemblyAngularVelocity = Vector3.zero
end

local function exitVoid() isVoided = false voidCircleAngle = 0 end

local function goBehind(target)
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return end
    local look = tRoot.CFrame.LookVector
    myRoot.CFrame = CFrame.new(tRoot.Position - look * BehindDistance, tRoot.Position)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    myRoot.AssemblyAngularVelocity = Vector3.zero
end

local function returnToGround()
    if storedGround then
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            myRoot.CFrame = storedGround
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end
    end
    storedGround = nil
    exitVoid()
    antiAimAngle = 0
end

local function tryShoot(target)
    if not target or not target.Character then return false end
    local a, _ = getAmmo()
    if a <= 0 then return false end
    local myChar = LP.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHum then return false end
    local gun = getGunWithAmmo()
    if not gun then return false end
    if gun.Parent ~= myChar then myHum:EquipTool(gun) task.wait(0.05) end
    local ok = pcall(function() gun:Activate() end)
    if ok then ShotsFired = ShotsFired + 1 return true end
    return false
end

local function startLockView()
    if camLockConn then return end
    camLockConn = RunService.RenderStepped:Connect(function()
        if not Enabled then return end
        if not ManualTarget or isVoided or StoppedForTarget or GrabMode then return end
        local hb = getHitbox(ManualTarget)
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hb or not myRoot then return end
        local eye = myRoot.Position + Vector3.new(0, 1.5, 0)
        Camera.CFrame = CFrame.new(eye, hb.Position)
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end)
end

local function stopLockView()
    if camLockConn then camLockConn:Disconnect() camLockConn = nil end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraSubject = hum
            Camera.CameraType = Enum.CameraType.Custom
        end
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    pcall(updateFOVCircle)
    pcall(updateAimVisuals)
    pcall(updateESP)
    pcall(AutoFire)

    if Config.AimAssist.Enabled then pcall(applyAimAssist) end

    if SpeedEnabled and Config.Speed.Enabled then
        local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
        if hum then
            local target = BaseSpeed * Config.Speed.Multiplier
            if hum.WalkSpeed ~= target then hum.WalkSpeed = target end
        end
        if Config.Speed.AntiFling then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local v = hrp.Velocity
                if v.Y > 50 or v.Y < -50 then hrp.Velocity = Vector3.new(v.X, 0, v.Z) end
            end
        end
    end

    if Config.SuperJump.Enabled then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if hum and root then
            local keyCode = Enum.KeyCode[Config.SuperJump.Key]
            local holding = keyCode and UserInputService:IsKeyDown(keyCode)
            local onGround = (hum.FloorMaterial ~= Enum.Material.Air)
            if holding and onGround and (tick() - lastSuperJump) >= Config.SuperJump.Cooldown then
                root.Velocity = Vector3.new(root.Velocity.X, Config.SuperJump.Power, root.Velocity.Z)
                lastSuperJump = tick()
            end
        end
    end

    if not Enabled then
        CurrentTarget = nil
        if isVoided then exitVoid() end
        return
    end

    if GrabMode then
        if AntiAimEnabled then pcall(applyAntiAim, dt) end
        return
    end

    if not ManualTarget or not ManualTarget.Parent or not ManualTarget.Character then
        CurrentTarget = nil
        if isVoided then returnToGround() end
        if camLockConn then stopLockView() end
        return
    end

    local hum = ManualTarget.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        CurrentTarget = nil
        if isVoided then returnToGround() end
        if camLockConn then stopLockView() end
        return
    end

    local hpPct = getTargetHPPercent(ManualTarget)
    if hpPct and hpPct <= StopHPPercent then
        if not StoppedForTarget then
            StoppedForTarget = true
            stopLockView()
            if isVoided then returnToGround() end
        end
        CurrentTarget = nil
        return
    end

    if StoppedForTarget and hpPct and hpPct > StopHPPercent then
        StoppedForTarget = false
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then storedGround = myRoot.CFrame end
    end

    CurrentTarget = ManualTarget
    pcall(forceEquipDB)

    if isReloading() then
        if VoidOnReload then pcall(voidDrift, dt) end
        if camLockConn then stopLockView() end
        pcall(tryShoot, CurrentTarget)
        if AntiAimEnabled and AntiAimDuringVoid then pcall(applyAntiAim, dt) end
    else
        if isVoided then exitVoid() end
        if BehindOnReady then pcall(goBehind, CurrentTarget) end
        if LockViewHVH then if not camLockConn then startLockView() end end
        pcall(tryShoot, CurrentTarget)
        if AntiAimEnabled then pcall(applyAntiAim, dt) end
    end
end)

LP.CharacterAdded:Connect(function()
    stopLockView()
    CurrentTarget = nil
    isVoided = false
    voidCircleAngle = 0
    storedGround = nil
    StoppedForTarget = false
    GrabMode = false
    GrabReturnPos = nil
    antiAimAngle = 0
end)

-- ============================================================
-- RAPID FIRE
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then rapidFireActive = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then rapidFireActive = false end
end)

RunService.Heartbeat:Connect(function()
    if not Config.RapidFire.Enabled or not rapidFireActive then return end
    local char = LP.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    if Config.RapidFire.SpecificWeapons then
        local valid = false
        for _, w in ipairs(Config.RapidFire.Weapons) do
            if tool.Name == w then valid = true break end
        end
        if not valid then return end
    end
    tool:Activate()
    task.wait(Config.RapidFire.Delay)
end)

-- ============================================================
-- TOUCH FLING SYSTEM
-- ============================================================
local TouchFlingEnabled = false
local TouchFlingPower = 500

local function setupTouchFling()
    if not LP.Character then return end
    
    local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    if myRoot:FindFirstChild("TouchFlingDetector") then
        myRoot:FindFirstChild("TouchFlingDetector"):Destroy()
    end
    
    local detector = Instance.new("Part")
    detector.Name = "TouchFlingDetector"
    detector.Shape = Enum.PartType.Ball
    detector.Size = Vector3.new(3, 3, 3)
    detector.Transparency = 1
    detector.CanCollide = false
    detector.Parent = myRoot
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = myRoot
    weld.Part1 = detector
    weld.Parent = detector
    
    detector.Touched:Connect(function(hit)
        if not TouchFlingEnabled then return end
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid and hit.Parent ~= LP.Character then
            local target = Players:FindFirstChild(hit.Parent.Name)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                local direction = (hrp.Position - myRoot.Position).Unit
                hrp.AssemblyLinearVelocity = direction * TouchFlingPower + Vector3.new(0, TouchFlingPower / 2, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(
                    math.random(-50, 50),
                    math.random(-50, 50),
                    math.random(-50, 50)
                )
            end
        end
    end)
end

LP.CharacterAdded:Connect(setupTouchFling)
setupTouchFling()

-- ============================================================
-- EXPLOITER TAG SYSTEM (F7 & F12)
-- ============================================================
local ExploiterTagsEnabled = false
local OwnerTagsEnabled = false
local ExploiterTags = {}

local EXPLOITER_LIST = {
    ["kp3g"] = "Owner",
    ["trusted_user"] = "Co-Owner",
    -- Add more here as needed
}

local function createExploiterTag(player, tagType)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    if ExploiterTags[player.Name] then
        pcall(function() ExploiterTags[player.Name]:Destroy() end)
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EXO_Tag_" .. tagType
    billboard.Size = UDim2.fromOffset(100, 24)
    billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
    billboard.MaxDistance = math.huge
    billboard.StudsOffset = Vector3.new(0, -4, 0)
    billboard.Parent = player.Character
    
    local tagLabel = Instance.new("TextLabel")
    tagLabel.BackgroundColor3 = Color3.fromRGB(220, 40, 70)
    tagLabel.BackgroundTransparency = 0.15
    tagLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    tagLabel.TextScaled = true
    tagLabel.Font = Enum.Font.GothamBlack
    tagLabel.Text = tagType
    tagLabel.TextSize = 12
    tagLabel.Size = UDim2.fromScale(1, 1)
    tagLabel.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = tagLabel
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 100, 120)
    stroke.Thickness = 1.5
    stroke.Parent = tagLabel
    
    ExploiterTags[player.Name] = billboard
end

local function removeAllTags(playerName)
    if ExploiterTags[playerName] then
        pcall(function() ExploiterTags[playerName]:Destroy() end)
        ExploiterTags[playerName] = nil
    end
end

local function updateExploiterTags()
    if not ExploiterTagsEnabled and not OwnerTagsEnabled then
        for playerName, tag in pairs(ExploiterTags) do
            pcall(function() tag:Destroy() end)
        end
        ExploiterTags = {}
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and EXPLOITER_LIST[player.Name] then
            if OwnerTagsEnabled then
                createExploiterTag(player, EXPLOITER_LIST[player.Name])
            elseif ExploiterTagsEnabled and EXPLOITER_LIST[player.Name] == "Exploiter" then
                createExploiterTag(player, "Exploiter")
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    if player ~= LP and EXPLOITER_LIST[player.Name] then
        updateExploiterTags()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeAllTags(player.Name)
end)

-- ============================================================
-- COMMAND SYSTEM
-- ============================================================
local COMMAND_PREFIX = "!"
local CommandHandlers = {}

local function registerCommand(name, callback)
    CommandHandlers[name] = callback
end

local function parseCommand(message)
    if not message:sub(1, 1) == COMMAND_PREFIX then return nil end
    local parts = message:sub(2):split(" ")
    local cmd = parts[1]:lower()
    table.remove(parts, 1)
    return cmd, parts
end

registerCommand("fling", function(player, args)
    TouchFlingEnabled = not TouchFlingEnabled
    setupTouchFling()
    print("[EXO] Touch Fling: " .. (TouchFlingEnabled and "ON" or "OFF"))
end)

registerCommand("flingpower", function(player, args)
    if not args[1] then
        print("[EXO] Fling Power: " .. TouchFlingPower)
        return
    end
    local newPower = tonumber(args[1])
    if newPower then
        TouchFlingPower = math.clamp(newPower, 100, 2000)
        print("[EXO] Fling Power: " .. TouchFlingPower)
    end
end)

registerCommand("exptags", function(player, args)
    ExploiterTagsEnabled = not ExploiterTagsEnabled
    updateExploiterTags()
    print("[EXO] Exploiter Tags: " .. (ExploiterTagsEnabled and "ON" or "OFF"))
end)

registerCommand("ownertags", function(player, args)
    OwnerTagsEnabled = not OwnerTagsEnabled
    updateExploiterTags()
    print("[EXO] Owner/Co-Owner Tags: " .. (OwnerTagsEnabled and "ON" or "OFF"))
end)

registerCommand("addwhitelist", function(player, args)
    if not args[1] then return end
    local name = args[1]
    table.remove(args, 1)
    local role = table.concat(args, " ") or "Exploiter"
    EXPLOITER_LIST[name] = role
    print("[EXO] Added " .. name .. " as " .. role)
end)

registerCommand("cmds", function(player, args)
    print("[EXO] ========== COMMAND LIST ==========")
    print("!" .. "fling - Toggle touch fling")
    print("!" .. "flingpower <100-2000> - Set fling power")
    print("!" .. "exptags - Toggle exploiter tags")
    print("!" .. "ownertags - Toggle owner/co-owner tags")
    print("!" .. "addwhitelist <player> <role> - Add player to whitelist")
    print("!" .. "cmds - Show this list")
    print("[EXO] ===================================")
end)

LP.Chatted:Connect(function(message)
    local cmd, args = parseCommand(message)
    if cmd and CommandHandlers[cmd] then
        CommandHandlers[cmd](LP, args)
    end
end)

-- ============================================================
-- CONFIG SAVE / LOAD
-- ============================================================
local function ensureConfigFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(CONFIG_FOLDER) then pcall(makefolder, CONFIG_FOLDER) end
    return isfolder(CONFIG_FOLDER)
end

local function serializeValue(v)
    if type(v) == "string" then return string.format("%q", v)
    elseif type(v) == "boolean" or type(v) == "number" then return tostring(v)
    elseif type(v) == "table" then
        local parts = {}
        for k, val in pairs(v) do
            parts[#parts+1] = string.format("[%q]=%s", tostring(k), serializeValue(val))
        end
        return "{" .. table.concat(parts, ",") .. "}"
    else
        return "nil"
    end
end

local function saveConfig(name)
    if not ensureConfigFolder() then return false, "No file API" end
    if not name or name == "" then return false, "No name" end
    local path = CONFIG_FOLDER .. "/" .. name .. ".txt"
    local data = "return " .. serializeValue(Config)
    local ok, err = pcall(function() if writefile then writefile(path, data) end end)
    if ok then return true end
    return false, tostring(err)
end

local function listConfigs()
    if not ensureConfigFolder() or not listfiles then return {} end
    local ok, files = pcall(listfiles, CONFIG_FOLDER)
    if not ok then return {} end
    local names = {}
    for _, f in ipairs(files) do
        local n = f:match("([^/\\]+)%.txt$")
        if n then names[#names+1] = n end
    end
    return names
end

local function loadConfigByName(name)
    if not ensureConfigFolder() or not readfile then return false, "No readfile" end
    if not name or name == "" then return false, "No name" end
    local path = CONFIG_FOLDER .. "/" .. name .. ".txt"
    if isfile and not isfile(path) then return false, "Not found" end
    local ok, contents = pcall(readfile, path)
    if not ok then return false, tostring(contents) end
    local fn, err = loadstring(contents)
    if not fn then return false, "Parse error: " .. tostring(err) end
    local ok2, data = pcall(fn)
    if not ok2 or type(data) ~= "table" then return false, "Invalid data" end
    local function merge(dst, src)
        for k, v in pairs(src) do
            if type(v) == "table" and type(dst[k]) == "table" then
                merge(dst[k], v)
            else
                dst[k] = v
            end
        end
    end
    merge(Config, data)
    return true
end

local function deleteConfigByName(name)
    if not name or name == "" then return false, "No name" end
    if not delfile then return false, "No delfile" end
    local path = CONFIG_FOLDER .. "/" .. name .. ".txt"
    local ok, err = pcall(delfile, path)
    if ok then return true end
    return false, tostring(err)
end

-- ============================================================
-- UI HELPERS
-- ============================================================
local THEME = {
    bg          = Color3.fromRGB(13, 10, 20),
    panel       = Color3.fromRGB(20, 15, 30),
    panelAlt    = Color3.fromRGB(26, 20, 38),
    accent      = Color3.fromRGB(220, 40, 70),
    accentDim   = Color3.fromRGB(120, 30, 50),
    textPrimary = Color3.fromRGB(235, 230, 245),
    textMuted   = Color3.fromRGB(150, 140, 170),
    onColor     = Color3.fromRGB(70, 180, 110),
    stroke      = Color3.fromRGB(90, 40, 65),
}

local COLOR_PALETTE = {
    {name = "White",     color = Color3.fromRGB(255, 255, 255)},
    {name = "Red",       color = Color3.fromRGB(255, 60, 60)},
    {name = "Orange",    color = Color3.fromRGB(255, 140, 60)},
    {name = "Yellow",    color = Color3.fromRGB(255, 220, 80)},
    {name = "Lime",      color = Color3.fromRGB(80, 220, 80)},
    {name = "Green",     color = Color3.fromRGB(40, 180, 90)},
    {name = "Cyan",      color = Color3.fromRGB(0, 200, 220)},
    {name = "Blue",      color = Color3.fromRGB(0, 162, 255)},
    {name = "Purple",    color = Color3.fromRGB(160, 80, 255)},
    {name = "Pink",      color = Color3.fromRGB(255, 100, 180)},
    {name = "Brown",     color = Color3.fromRGB(150, 90, 50)},
    {name = "Black",     color = Color3.fromRGB(0, 0, 0)},
}

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
    return c
end

local function stroke(parent, col, thick, transp)
    local s = Instance.new("UIStroke")
    s.Color = col or THEME.stroke
    s.Thickness = thick or 1
    s.Transparency = transp or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function pad(parent, all, lr, tb)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, lr or all or 0)
    p.PaddingRight = UDim.new(0, lr or all or 0)
    p.PaddingTop = UDim.new(0, tb or all or 0)
    p.PaddingBottom = UDim.new(0, tb or all or 0)
    p.Parent = parent
    return p
end

-- ============================================================
-- MENU BUILD
-- ============================================================
local function buildMenu()
    local parent = getGuiParent()
    local gui = Instance.new("ScreenGui")
    gui.Name = "EXO_HVH"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999997
    gui.Parent = parent

    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(MENU_W, MENU_H)
    main.Position = UDim2.new(0.5, -MENU_W/2, 0.5, -MENU_H/2)
    main.BackgroundColor3 = THEME.bg
    main.BorderSizePixel = 0
    main.Visible = true
    main.Parent = gui
    corner(main, 14)
    stroke(main, THEME.accent, 1.5, 0.35)

    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if _G.EXO_DraggingSlider then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    main.InputChanged:Connect(function(input)
        if _G.EXO_DraggingSlider then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if _G.EXO_DraggingSlider then return end
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            _G.EXO_DraggingSlider = false
        end
    end)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundTransparency = 1
    header.Parent = main

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 0, 26)
    accentBar.Position = UDim2.fromOffset(16, 11)
    accentBar.BackgroundColor3 = THEME.accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = header
    corner(accentBar, 2)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 0, 20)
    title.Position = UDim2.fromOffset(28, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "EXO UNITED"
    title.TextColor3 = THEME.textPrimary
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -70, 0, 14)
    subtitle.Position = UDim2.fromOffset(28, 26)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "HVH  •  @kp3g"
    subtitle.TextColor3 = THEME.textMuted
    subtitle.TextSize = 10
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(26, 26)
    closeBtn.Position = UDim2.new(1, -36, 0, 11)
    closeBtn.BackgroundColor3 = THEME.panelAlt
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = THEME.textMuted
    closeBtn.TextSize = 16
    closeBtn.Parent = header
    corner(closeBtn, 6)
    stroke(closeBtn, THEME.stroke, 1, 0.5)
    closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -24, 0, 32)
    tabBar.Position = UDim2.fromOffset(12, 50)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = main
    local tbl = Instance.new("UIListLayout")
    tbl.FillDirection = Enum.FillDirection.Horizontal
    tbl.SortOrder = Enum.SortOrder.LayoutOrder
    tbl.Padding = UDim.new(0, 6)
    tbl.Parent = tabBar

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -24, 1, -110)
    content.Position = UDim2.fromOffset(12, 90)
    content.BackgroundTransparency = 1
    content.Parent = main

    local tabButtons = {}
    local function makeTab(name, order)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(0, 32)
        b.AutomaticSize = Enum.AutomaticSize.X
        b.BackgroundColor3 = THEME.panel
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.Text = "  " .. name .. "  "
        b.TextColor3 = THEME.textMuted
        b.TextSize = 11
        b.LayoutOrder = order
        b.Parent = tabBar
        corner(b, 8)
        stroke(b, THEME.stroke, 1, 0.5)
        tabButtons[name] = b
    end
    makeTab("Main", 1)
    makeTab("Aim", 2)
    makeTab("Visuals", 3)
    makeTab("Players", 4)
    makeTab("Config", 5)
    makeTab("Scripts", 6)

    local function switchTab(name)
        for n, b in pairs(tabButtons) do
            if n == name then
                b.BackgroundColor3 = THEME.accent
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                b.BackgroundColor3 = THEME.panel
                b.TextColor3 = THEME.textMuted
            end
        end
        for n, f in pairs(TabFrames) do f.Visible = (n == name) end
    end
    tabButtons.Main.MouseButton1Click:Connect(function() switchTab("Main") end)
    tabButtons.Aim.MouseButton1Click:Connect(function() switchTab("Aim") end)
    tabButtons.Visuals.MouseButton1Click:Connect(function() switchTab("Visuals") end)
    tabButtons.Players.MouseButton1Click:Connect(function() switchTab("Players") end)
    tabButtons.Config.MouseButton1Click:Connect(function() switchTab("Config") end)
    tabButtons.Scripts.MouseButton1Click:Connect(function() switchTab("Scripts") end)

    local function newScrollingTab()
        local sf = Instance.new("ScrollingFrame")
        sf.Size = UDim2.fromScale(1, 1)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.ScrollBarThickness = 3
        sf.ScrollBarImageColor3 = THEME.accent
        sf.Parent = content
        pad(sf, 0, 4, 4)
        local l = Instance.new("UIListLayout")
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.Padding = UDim.new(0, 6)
        l.Parent = sf
        l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sf.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 12)
        end)
        return sf
    end

    local function section(txt, order, parentFrame)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, 0, 0, 22)
        holder.BackgroundTransparency = 1
        holder.LayoutOrder = order
        holder.Parent = parentFrame

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 0, 14)
        bar.Position = UDim2.fromOffset(0, 4)
        bar.BackgroundColor3 = THEME.accent
        bar.BorderSizePixel = 0
        bar.Parent = holder
        corner(bar, 2)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 1, 0)
        lbl.Position = UDim2.fromOffset(10, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = string.upper(txt)
        lbl.TextColor3 = THEME.textPrimary
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = holder
    end

    local function makeToggle(label, getter, setter, order, parent, onChanged)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 32)
        b.BackgroundColor3 = THEME.panel
        b.BorderSizePixel = 0
        b.Text = ""
        b.LayoutOrder = order
        b.Parent = parent
        corner(b, 8)
        stroke(b, THEME.stroke, 1, 0.5)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -70, 1, 0)
        lbl.Position = UDim2.fromOffset(12, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = label
        lbl.TextColor3 = THEME.textPrimary
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = b

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.fromOffset(40, 20)
        indicator.Position = UDim2.new(1, -50, 0.5, -10)
        indicator.BackgroundColor3 = getter() and THEME.onColor or Color3.fromRGB(50, 40, 60)
        indicator.BorderSizePixel = 0
        indicator.Parent = b
        corner(indicator, 10)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(16, 16)
        knob.Position = getter() and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = indicator
        corner(knob, 8)

        local function refresh()
            local on = getter()
            TweenService:Create(indicator, TweenInfo.new(0.15), {
                BackgroundColor3 = on and THEME.onColor or Color3.fromRGB(50, 40, 60)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = on and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
            }):Play()
        end

        b.MouseButton1Click:Connect(function()
            setter(not getter())
            refresh()
            if onChanged then onChanged(getter()) end
        end)
        return {btn = b, refresh = refresh}
    end

    local function makeSlider(label, getter, setter, minV, maxV, order, parent, fmt)
        fmt = fmt or "%.0f"
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, 0, 0, 42)
        holder.BackgroundTransparency = 1
        holder.LayoutOrder = order
        holder.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 14)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = label
        lbl.TextColor3 = THEME.textPrimary
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = holder

        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0, 60, 0, 14)
        val.Position = UDim2.new(1, -60, 0, 0)
        val.BackgroundTransparency = 1
        val.Font = Enum.Font.GothamBold
        val.Text = string.format(fmt, getter())
        val.TextColor3 = THEME.accent
        val.TextSize = 11
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.Parent = holder

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 6)
        track.Position = UDim2.new(0, 0, 0, 22)
        track.BackgroundColor3 = Color3.fromRGB(38, 30, 50)
        track.BorderSizePixel = 0
        track.Parent = holder
        corner(track, 3)

        local initRel = math.clamp((getter() - minV) / (maxV - minV), 0, 1)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.fromScale(initRel, 1)
        fill.BackgroundColor3 = THEME.accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        corner(fill, 3)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(14, 14)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(initRel, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = track
        corner(knob, 7)
        stroke(knob, THEME.accent, 2, 0)

        local dragging = false
        local function upd(input)
            local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = minV + relX * (maxV - minV)
            setter(v)
            fill.Size = UDim2.fromScale(relX, 1)
            knob.Position = UDim2.new(relX, 0, 0.5, 0)
            val.Text = string.format(fmt, v)
        end
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                _G.EXO_DraggingSlider = true
                upd(i)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                upd(i)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                if dragging then
                    dragging = false
                    _G.EXO_DraggingSlider = false
                end
            end
        end)
    end

    local function makeKeybind(label, getter, setter, order, parent)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 32)
        b.BackgroundColor3 = THEME.panel
        b.BorderSizePixel = 0
        b.Text = ""
        b.LayoutOrder = order
        b.Parent = parent
        corner(b, 8)
        stroke(b, THEME.stroke, 1, 0.5)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -90, 1, 0)
        lbl.Position = UDim2.fromOffset(12, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = label
        lbl.TextColor3 = THEME.textPrimary
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = b

        local keyBtn = Instance.new("TextButton")
        keyBtn.Size = UDim2.fromOffset(70, 22)
        keyBtn.Position = UDim2.new(1, -78, 0.5, -11)
        keyBtn.BackgroundColor3 = THEME.panelAlt
        keyBtn.BorderSizePixel = 0
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.Text = tostring(getter())
        keyBtn.TextColor3 = THEME.accent
        keyBtn.TextSize = 11
        keyBtn.Parent = b
        corner(keyBtn, 6)
        stroke(keyBtn, THEME.stroke, 1, 0.5)

        _G.EXO_KeybindWaiters = _G.EXO_KeybindWaiters or {}
        keyBtn.MouseButton1Click:Connect(function()
            _G.EXO_KeybindWaiters[keyBtn] = function(keyCode)
                setter(keyCode)
                keyBtn.Text = keyCode.Name
            end
            keyBtn.Text = "..."
            keyBtn.TextColor3 = THEME.textMuted
        end)
    end

    local function makeActionBtn(label, col, order, parent, onClick)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 34)
        b.BackgroundColor3 = col or THEME.panel
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.Text = label
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 12
        b.LayoutOrder = order
        b.Parent = parent
        corner(b, 8)
        stroke(b, THEME.stroke, 1, 0.5)
        local hoverCol = col and Color3.new(math.min(col.R*1.15,1), math.min(col.G*1.15,1), math.min(col.B*1.15,1)) or THEME.panelAlt
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = hoverCol}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = col or THEME.panel}):Play()
        end)
        b.MouseButton1Click:Connect(function() onClick(b) end)
        return b
    end

    local function makeColorPalette(label, getter, setter, order, parent)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, 0, 0, 66)
        holder.BackgroundTransparency = 1
        holder.LayoutOrder = order
        holder.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -80, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = label
        lbl.TextColor3 = THEME.textPrimary
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = holder

        local preview = Instance.new("Frame")
        preview.Size = UDim2.fromOffset(30, 16)
        preview.Position = UDim2.new(1, -32, 0, 0)
        preview.BackgroundColor3 = getter()
        preview.BorderSizePixel = 0
        preview.Parent = holder
        corner(preview, 4)
        stroke(preview, Color3.fromRGB(255,255,255), 1, 0.4)

        local paletteRow = Instance.new("Frame")
        paletteRow.Size = UDim2.new(1, 0, 0, 34)
        paletteRow.Position = UDim2.fromOffset(0, 24)
        paletteRow.BackgroundTransparency = 1
        paletteRow.Parent = holder

        local pList = Instance.new("UIListLayout")
        pList.FillDirection = Enum.FillDirection.Horizontal
        pList.SortOrder = Enum.SortOrder.LayoutOrder
        pList.Padding = UDim.new(0, 6)
        pList.Parent = paletteRow

        local swatches = {}
        for i, entry in ipairs(COLOR_PALETTE) do
            local sw = Instance.new("TextButton")
            sw.Size = UDim2.fromOffset(26, 26)
            sw.BackgroundColor3 = entry.color
            sw.BorderSizePixel = 0
            sw.Text = ""
            sw.LayoutOrder = i
            sw.Parent = paletteRow
            corner(sw, 6)
            local s = stroke(sw, Color3.fromRGB(255,255,255), 2, 0.85)
            swatches[entry] = {btn = sw, stroke = s}
            sw.MouseButton1Click:Connect(function()
                setter(entry.color)
                preview.BackgroundColor3 = entry.color
                for e, data in pairs(swatches) do
                    data.stroke.Transparency = (e == entry) and 0 or 0.85
                end
            end)
        end

        for e, data in pairs(swatches) do
            local current = getter()
            if math.abs(e.color.R - current.R) < 0.01 and math.abs(e.color.G - current.G) < 0.01 and math.abs(e.color.B - current.B) < 0.01 then
                data.stroke.Transparency = 0
            else
                data.stroke.Transparency = 0.85
            end
        end
    end

    -- MAIN TAB
    local mainTab = newScrollingTab()
    TabFrames.Main = mainTab

    section("Rage Bot", 1, mainTab)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, 0, 0, 40)
    toggle.BackgroundColor3 = THEME.panel
    toggle.BorderSizePixel = 0
    toggle.Font = Enum.Font.GothamBold
    toggle.Text = ""
    toggle.LayoutOrder = 2
    toggle.Parent = mainTab
    corner(toggle, 10)
    stroke(toggle, THEME.accentDim, 1.5, 0.3)

    local toggleLbl = Instance.new("TextLabel")
    toggleLbl.Size = UDim2.new(1, -12, 0, 16)
    toggleLbl.Position = UDim2.fromOffset(12, 5)
    toggleLbl.BackgroundTransparency = 1
    toggleLbl.Font = Enum.Font.GothamBold
    toggleLbl.Text = "RAGE BOT"
    toggleLbl.TextColor3 = THEME.textPrimary
    toggleLbl.TextSize = 13
    toggleLbl.TextXAlignment = Enum.TextXAlignment.Left
    toggleLbl.Parent = toggle

    local toggleState = Instance.new("TextLabel")
    toggleState.Size = UDim2.new(1, -12, 0, 12)
    toggleState.Position = UDim2.fromOffset(12, 22)
    toggleState.BackgroundTransparency = 1
    toggleState.Font = Enum.Font.Gotham
    toggleState.Text = "OFF  •  " .. ToggleKey.Name
    toggleState.TextColor3 = THEME.textMuted
    toggleState.TextSize = 10
    toggleState.TextXAlignment = Enum.TextXAlignment.Left
    toggleState.Parent = toggle

    local function updToggle()
        toggleState.Text = (Enabled and "ON" or "OFF") .. "  •  " .. ToggleKey.Name
        toggleState.TextColor3 = Enabled and THEME.onColor or THEME.textMuted
        toggle.BackgroundColor3 = Enabled and Color3.fromRGB(30, 45, 35) or THEME.panel
    end
    toggle.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        if not Enabled then
            stopLockView()
            if isVoided or storedGround then returnToGround() end
            antiAimAngle = 0
        else
            local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then storedGround = myRoot.CFrame end
            StoppedForTarget = false
        end
        updToggle()
    end)
    _G.EXO_UpdToggle = updToggle
    makeKeybind("Rage Bot Key", function() return ToggleKey.Name end, function(k)
        ToggleKey = k
        updToggle()
    end, 3, mainTab)

    section("Anti-Aim (Spin)", 10, mainTab)
    makeToggle("Anti-Aim Enabled", function() return AntiAimEnabled end, function(v) AntiAimEnabled = v end, 11, mainTab)
    makeToggle("Anti-Aim During Void", function() return AntiAimDuringVoid end, function(v) AntiAimDuringVoid = v end, 12, mainTab)
    makeSlider("Anti-Aim Speed", function() return AntiAimSpeed end, function(v) AntiAimSpeed = v end, 5, 300, 13, mainTab)

    local axisBtn = Instance.new("TextButton")
    axisBtn.Size = UDim2.new(1, 0, 0, 32)
    axisBtn.BackgroundColor3 = THEME.panel
    axisBtn.BorderSizePixel = 0
    axisBtn.Text = ""
    axisBtn.LayoutOrder = 14
    axisBtn.Parent = mainTab
    corner(axisBtn, 8)
    stroke(axisBtn, THEME.stroke, 1, 0.5)

    local axLbl = Instance.new("TextLabel")
    axLbl.Size = UDim2.new(1, -90, 1, 0)
    axLbl.Position = UDim2.fromOffset(12, 0)
    axLbl.BackgroundTransparency = 1
    axLbl.Font = Enum.Font.GothamMedium
    axLbl.Text = "Anti-Aim Axis"
    axLbl.TextColor3 = THEME.textPrimary
    axLbl.TextSize = 12
    axLbl.TextXAlignment = Enum.TextXAlignment.Left
    axLbl.Parent = axisBtn

    local axVal = Instance.new("TextLabel")
    axVal.Size = UDim2.new(0, 80, 1, 0)
    axVal.Position = UDim2.new(1, -88, 0, 0)
    axVal.BackgroundTransparency = 1
    axVal.Font = Enum.Font.GothamBold
    axVal.Text = AntiAimAxis
    axVal.TextColor3 = THEME.accent
    axVal.TextSize = 11
    axVal.TextXAlignment = Enum.TextXAlignment.Right
    axVal.Parent = axisBtn

    local axisCycle = {"Y", "X", "Z", "XYZ"}
    axisBtn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, v in ipairs(axisCycle) do if v == AntiAimAxis then idx = i break end end
        idx = idx % #axisCycle + 1
        AntiAimAxis = axisCycle[idx]
        axVal.Text = AntiAimAxis
    end)

    section("Behavior", 20, mainTab)
    makeToggle("Lock View on Target", function() return LockViewHVH end, function(v) LockViewHVH = v end, 21, mainTab)
    makeToggle("Void During Reload", function() return VoidOnReload end, function(v) VoidOnReload = v end, 22, mainTab)
    makeToggle("Auto Backstab (During Rage Bot)", function() return BehindOnReady end, function(v) BehindOnReady = v end, 23, mainTab)

    section("Teleport Behind", 30, mainTab)
    makeToggle("Enable Teleport Behind", function() return Config.TeleportBehind.Enabled end, function(v)
        Config.TeleportBehind.Enabled = v
    end, 31, mainTab)
    makeKeybind("Teleport Behind Key", function() return Config.TeleportBehind.Key end, function(k) Config.TeleportBehind.Key = k.Name end, 32, mainTab)
    makeSlider("Behind Distance", function() return Config.TeleportBehind.Distance end, function(v) Config.TeleportBehind.Distance = v end, 3, 20, 33, mainTab)

    section("Grab", 40, mainTab)
    makeToggle("Enable Grab", function() return Config.Grab.Enabled end, function(v) Config.Grab.Enabled = v end, 41, mainTab)
    makeKeybind("Grab Key", function() return Config.Grab.Key end, function(k) Config.Grab.Key = k.Name end, 42, mainTab)
    makeSlider("Grab Duration", function() return Config.Grab.Duration end, function(v) Config.Grab.Duration = v end, 0.25, 3, 43, mainTab, "%.2f")

    section("Status", 50, mainTab)
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 90)
    status.BackgroundColor3 = THEME.panel
    status.BackgroundTransparency = 0.3
    status.BorderSizePixel = 0
    status.Font = Enum.Font.Code
    status.Text = "..."
    status.TextColor3 = THEME.textMuted
    status.TextSize = 10
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextYAlignment = Enum.TextYAlignment.Top
    status.LayoutOrder = 51
    status.Parent = mainTab
    corner(status, 8)
    stroke(status, THEME.stroke, 1, 0.6)
    pad(status, 8)

    task.spawn(function()
        while status.Parent do
            local a, m = getAmmo()
            local label = ManualTarget and ManualTarget.Name or "none"
            local hpPct = ManualTarget and getTargetHPPercent(ManualTarget)
            local hpStr = hpPct and string.format("%.0f%%", hpPct) or "?"
            local state = GrabMode and "GRAB" or isVoided and "VOID" or StoppedForTarget and "STOP" or (a <= 0 and "RELOAD" or "READY")
            status.Text = string.format(
                "Ammo %d/%d  •  %s\nTarget: %s (%s)\nShots: %d  •  AA: %.0f %s\nRF: %s  •  SA: %s  •  FOV: %s  •  AAim: %s",
                a, m, state, label, hpStr, ShotsFired, AntiAimSpeed, AntiAimAxis,
                rapidFireActive and "ON" or "off",
                Config.SilentAim.Enabled and "ON" or "off",
                Config.FOV.Enabled and "ON" or "off",
                Config.AimAssist.Enabled and "ON" or "off"
            )
            task.wait(0.25)
        end
    end)

    -- AIM TAB
    local aimTab = newScrollingTab()
    aimTab.Visible = false
    TabFrames.Aim = aimTab

    section("Silent Aim", 1, aimTab)
    makeToggle("Silent Aim", function() return Config.SilentAim.Enabled end, function(v) Config.SilentAim.Enabled = v end, 2, aimTab)
    makeKeybind("Silent Aim Key", function() return tostring(Config.Keybinds.SilentAim) end, function(k) Config.Keybinds.SilentAim = k.Name end, 3, aimTab)

    local hitPartBtn = Instance.new("TextButton")
    hitPartBtn.Size = UDim2.new(1, 0, 0, 32)
    hitPartBtn.BackgroundColor3 = THEME.panel
    hitPartBtn.BorderSizePixel = 0
    hitPartBtn.Text = ""
    hitPartBtn.LayoutOrder = 4
    hitPartBtn.Parent = aimTab
    corner(hitPartBtn, 8)
    stroke(hitPartBtn, THEME.stroke, 1, 0.5)

    local hpLbl = Instance.new("TextLabel")
    hpLbl.Size = UDim2.new(1, -90, 1, 0)
    hpLbl.Position = UDim2.fromOffset(12, 0)
    hpLbl.BackgroundTransparency = 1
    hpLbl.Font = Enum.Font.GothamMedium
    hpLbl.Text = "Hit Part"
    hpLbl.TextColor3 = THEME.textPrimary
    hpLbl.TextSize = 12
    hpLbl.TextXAlignment = Enum.TextXAlignment.Left
    hpLbl.Parent = hitPartBtn

    local hpVal = Instance.new("TextLabel")
    hpVal.Size = UDim2.new(0, 80, 1, 0)
    hpVal.Position = UDim2.new(1, -88, 0, 0)
    hpVal.BackgroundTransparency = 1
    hpVal.Font = Enum.Font.GothamBold
    hpVal.Text = Config.SilentAim.HitPart
    hpVal.TextColor3 = THEME.accent
    hpVal.TextSize = 11
    hpVal.TextXAlignment = Enum.TextXAlignment.Right
    hpVal.Parent = hitPartBtn

    local hitParts = {"Head", "UpperTorso", "HumanoidRootPart", "Closest Part"}
    hitPartBtn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, v in ipairs(hitParts) do if v == Config.SilentAim.HitPart then idx = i break end end
        idx = idx % #hitParts + 1
        Config.SilentAim.HitPart = hitParts[idx]
        hpVal.Text = Config.SilentAim.HitPart
    end)

    makeToggle("Prediction", function() return Config.SilentAim.UsePrediction end, function(v) Config.SilentAim.UsePrediction = v end, 5, aimTab)
    makeSlider("Pred X", function() return Config.SilentAim.PredX end, function(v) Config.SilentAim.PredX = v end, 0, 0.5, 6, aimTab, "%.3f")
    makeSlider("Pred Y", function() return Config.SilentAim.PredY end, function(v) Config.SilentAim.PredY = v end, 0, 0.5, 7, aimTab, "%.3f")
    makeSlider("Pred Z", function() return Config.SilentAim.PredZ end, function(v) Config.SilentAim.PredZ = v end, 0, 0.5, 8, aimTab, "%.3f")
    makeToggle("Visible Check", function() return Config.Settings.VisibleCheck end, function(v) Config.Settings.VisibleCheck = v end, 9, aimTab)
    makeToggle("Knock Check", function() return Config.Settings.KnockCheck end, function(v) Config.Settings.KnockCheck = v end, 10, aimTab)
    makeToggle("Show Tracer", function() return Config.SilentAim.ShowTracer end, function(v) Config.SilentAim.ShowTracer = v end, 11, aimTab)
    makeToggle("Show Target Box", function() return Config.SilentAim.ShowBox end, function(v) Config.SilentAim.ShowBox = v end, 12, aimTab)

    section("FOV Circle (follows mouse)", 15, aimTab)
    makeToggle("FOV Circle", function() return Config.FOV.Enabled end, function(v)
        Config.FOV.Enabled = v
        if fovCircle then fovCircle.Visible = v end
    end, 16, aimTab)
    makeSlider("FOV Size", function() return Config.FOV.Size end, function(v) Config.FOV.Size = v end, 5, 800, 17, aimTab)
    makeSlider("FOV Thickness", function() return Config.FOV.Thickness end, function(v) Config.FOV.Thickness = v end, 1, 5, 18, aimTab)

    section("Aim Assist (Camera)", 20, aimTab)
    makeToggle("Aim Assist", function() return Config.AimAssist.Enabled end, function(v) Config.AimAssist.Enabled = v end, 21, aimTab)
    makeKeybind("Aim Assist Key", function() return tostring(Config.Keybinds.AimAssist) end, function(k) Config.Keybinds.AimAssist = k.Name end, 22, aimTab)
    makeSlider("Smoothing (0 = hard lock)", function() return Config.AimAssist.Smoothing end, function(v) Config.AimAssist.Smoothing = v end, 0, 100, 23, aimTab)
    makeToggle("Aim Assist Prediction", function() return Config.AimAssist.UsePrediction end, function(v) Config.AimAssist.UsePrediction = v end, 24, aimTab)

    section("Auto-Fire", 30, aimTab)
    makeToggle("Auto-Fire", function() return Config.AutoFire.Enabled end, function(v) Config.AutoFire.Enabled = v end, 31, aimTab)
    makeKeybind("Auto-Fire Key", function() return tostring(Config.Keybinds.AutoFire.Key) end, function(k) Config.Keybinds.AutoFire.Key = k.Name end, 32, aimTab)
    makeSlider("Auto-Fire Delay", function() return Config.AutoFire.Delay end, function(v) Config.AutoFire.Delay = v end, 0.01, 1, 33, aimTab, "%.2f")

    section("Spread", 40, aimTab)
    makeToggle("Spread Reducer", function() return Config.Spread.Enabled end, function(v) Config.Spread.Enabled = v end, 41, aimTab)
    makeSlider("Spread Amount %", function() return Config.Spread.Amount end, function(v) Config.Spread.Amount = v end, 0, 100, 42, aimTab)
    makeToggle("Specific Weapons", function() return Config.Spread.SpecificWeapons end, function(v) Config.Spread.SpecificWeapons = v end, 43, aimTab)

    section("Speed Hack", 50, aimTab)
    makeToggle("Speed Hack", function() return Config.Speed.Enabled end, function(v) Config.Speed.Enabled = v end, 51, aimTab)
    makeKeybind("Speed Key", function() return tostring(Config.Keybinds.Speed) end, function(k) Config.Keybinds.Speed = k.Name end, 52, aimTab)
    makeSlider("Speed Multiplier", function() return Config.Speed.Multiplier end, function(v) Config.Speed.Multiplier = v end, 1, 100, 53, aimTab)
    makeToggle("Anti Fling", function() return Config.Speed.AntiFling end, function(v) Config.Speed.AntiFling = v end, 54, aimTab)

    section("Super Jump", 60, aimTab)
    makeToggle("Super Jump", function() return Config.SuperJump.Enabled end, function(v) Config.SuperJump.Enabled = v end, 61, aimTab)
    makeKeybind("Super Jump Key", function() return tostring(Config.SuperJump.Key) end, function(k) Config.SuperJump.Key = k.Name end, 62, aimTab)
    makeSlider("Jump Power", function() return Config.SuperJump.Power end, function(v) Config.SuperJump.Power = v end, 100, 1000, 63, aimTab)
    makeSlider("Jump Cooldown", function() return Config.SuperJump.Cooldown end, function(v) Config.SuperJump.Cooldown = v end, 0, 1, 64, aimTab, "%.2f")

    section("Rapid Fire (Hold LMB)", 70, aimTab)
    makeToggle("Rapid Fire", function() return Config.RapidFire.Enabled end, function(v) Config.RapidFire.Enabled = v end, 71, aimTab)
    makeSlider("Rapid Fire Delay", function() return Config.RapidFire.Delay end, function(v) Config.RapidFire.Delay = v end, 0.01, 0.5, 72, aimTab, "%.2f")

    -- VISUALS TAB
    local visualsTab = newScrollingTab()
    visualsTab.Visible = false
    TabFrames.Visuals = visualsTab

    section("Player ESP", 1, visualsTab)
    if hasDrawing then
        makeToggle("Tracers", function() return Config.ESP.Tracers end, function(v) Config.ESP.Tracers = v end, 2, visualsTab)
        makeToggle("Tracers Follow Mouse", function() return Config.ESP.TracerFollowMouse end, function(v) Config.ESP.TracerFollowMouse = v end, 3, visualsTab)
        makeToggle("2D Box ESP", function() return Config.ESP.Box end, function(v) Config.ESP.Box = v end, 4, visualsTab)
        makeToggle("Skeleton ESP", function() return Config.ESP.Skeleton end, function(v) Config.ESP.Skeleton = v end, 5, visualsTab)
        makeToggle("Name ESP", function() return Config.ESP.Name end, function(v) Config.ESP.Name = v end, 6, visualsTab)
        makeToggle("Distance Indicators", function() return Config.ESP.Distance end, function(v) Config.ESP.Distance = v end, 7, visualsTab)
        makeToggle("Health Bar ESP", function() return Config.ESP.Health end, function(v) Config.ESP.Health = v end, 8, visualsTab)
    else
        local warnLbl = Instance.new("TextLabel")
        warnLbl.Size = UDim2.new(1, 0, 0, 30)
        warnLbl.BackgroundTransparency = 1
        warnLbl.Text = "⚠ Drawing library not supported"
        warnLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
        warnLbl.TextSize = 12
        warnLbl.Font = Enum.Font.GothamMedium
        warnLbl.LayoutOrder = 2
        warnLbl.Parent = visualsTab
    end

    section("Highlights (Player Outline)", 10, visualsTab)
    makeToggle("Enable Highlights", function() return Config.ESP.HighlightEnabled end, function(v)
        Config.ESP.HighlightEnabled = v
        ESPEnabled = v
        if not v then
            for p in pairs(ESPData) do removeESP(p) end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then updateESPFor(p) end
            end
        end
    end, 11, visualsTab)

    section("Color Palette", 20, visualsTab)
    makeColorPalette("ESP Drawings Color", function() return Config.ESP.Color end, function(c)
        Config.ESP.Color = c
    end, 21, visualsTab)
    makeColorPalette("Highlight Color", function() return Config.ESP.HighlightColor end, function(c)
        Config.ESP.HighlightColor = c
        for p, data in pairs(ESPData) do
            if data.highlight and data.highlight.Parent and p ~= ManualTarget then
                data.highlight.FillColor = c
            end
        end
    end, 22, visualsTab)
    makeColorPalette("Target Highlight Color", function() return Config.Visual.TargetColor end, function(c)
        Config.Visual.TargetColor = c
        if ManualTarget then updateESPFor(ManualTarget) end
    end, 23, visualsTab)

    -- PLAYERS TAB
    local playersTab = Instance.new("Frame")
    playersTab.Size = UDim2.fromScale(1, 1)
    playersTab.BackgroundTransparency = 1
    playersTab.Visible = false
    playersTab.Parent = content
    TabFrames.Players = playersTab

    local manualStatus = Instance.new("TextLabel")
    manualStatus.Size = UDim2.new(1, 0, 0, 34)
    manualStatus.BackgroundColor3 = THEME.panel
    manualStatus.BorderSizePixel = 0
    manualStatus.Font = Enum.Font.GothamBold
    manualStatus.Text = "Target: none"
    manualStatus.TextColor3 = THEME.textMuted
    manualStatus.TextSize = 11
    manualStatus.Parent = playersTab
    corner(manualStatus, 8)
    stroke(manualStatus, THEME.stroke, 1, 0.5)

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 1, -42)
    list.Position = UDim2.fromOffset(0, 42)
    list.BackgroundColor3 = THEME.panel
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ScrollBarThickness = 3
    list.ScrollBarImageColor3 = THEME.accent
    list.Parent = playersTab
    corner(list, 10)
    stroke(list, THEME.stroke, 1, 0.5)
    pad(list, 0, 6, 6)
    local ll = Instance.new("UIListLayout")
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding = UDim.new(0, 5)
    ll.Parent = list
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        list.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 12)
    end)

    local function updateManualStatus()
        if ManualTarget then
            manualStatus.Text = "Target: " .. ManualTarget.DisplayName
            manualStatus.TextColor3 = THEME.accent
        else
            manualStatus.Text = "Target: none"
            manualStatus.TextColor3 = THEME.textMuted
        end
    end

    local function buildRow(plr)
        if plr == LP then return end
        if PlayerRows[plr] and PlayerRows[plr].row.Parent then return end

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundColor3 = THEME.panelAlt
        row.BorderSizePixel = 0
        row.Parent = list
        corner(row, 8)
        stroke(row, THEME.stroke, 1, 0.6)

        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.fromOffset(30, 30)
        avatar.Position = UDim2.fromOffset(5, 5)
        avatar.BackgroundColor3 = Color3.fromRGB(20, 12, 22)
        avatar.BorderSizePixel = 0
        avatar.Parent = row
        corner(avatar, 15)
        pcall(function()
            avatar.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
        end)

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -180, 0, 14)
        nameLbl.Position = UDim2.fromOffset(42, 4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.Text = plr.DisplayName
        nameLbl.TextColor3 = THEME.textPrimary
        nameLbl.TextSize = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.Parent = row

        local hpLbl = Instance.new("TextLabel")
        hpLbl.Size = UDim2.new(1, -180, 0, 12)
        hpLbl.Position = UDim2.fromOffset(42, 20)
        hpLbl.BackgroundTransparency = 1
        hpLbl.Font = Enum.Font.GothamMedium
        hpLbl.Text = "100%"
        hpLbl.TextColor3 = THEME.onColor
        hpLbl.TextSize = 10
        hpLbl.TextXAlignment = Enum.TextXAlignment.Left
        hpLbl.Parent = row

        task.spawn(function()
            while hpLbl.Parent do
                local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.MaxHealth > 0 then
                    local pct = (hum.Health / hum.MaxHealth) * 100
                    hpLbl.Text = string.format("%.0f%%", pct)
                    if pct > 60 then hpLbl.TextColor3 = THEME.onColor
                    elseif pct > 30 then hpLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
                    else hpLbl.TextColor3 = Color3.fromRGB(255, 80, 80) end
                else
                    hpLbl.Text = "?"
                end
                task.wait(0.3)
            end
        end)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(70, 26)
        btn.Position = UDim2.new(1, -76, 0.5, -13)
        btn.BackgroundColor3 = THEME.panel
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.Text = "SELECT"
        btn.TextColor3 = THEME.textPrimary
        btn.TextSize = 10
        btn.Parent = row
        corner(btn, 6)
        stroke(btn, THEME.stroke, 1, 0.5)

        local function upd()
            if ManualTarget == plr then
                btn.Text = "LOCKED"
                btn.BackgroundColor3 = THEME.accent
                btn.TextColor3 = Color3.fromRGB(255,255,255)
            else
                btn.Text = "SELECT"
                btn.BackgroundColor3 = THEME.panel
                btn.TextColor3 = THEME.textPrimary
            end
        end

        btn.MouseButton1Click:Connect(function()
            if ManualTarget == plr then
                ManualTarget = nil
                stopLockView()
                if isVoided or storedGround then returnToGround() end
                antiAimAngle = 0
            else
                ManualTarget = plr
                StoppedForTarget = false
                local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then storedGround = myRoot.CFrame end
            end
            for _, r in pairs(PlayerRows) do if r.upd then r.upd() end end
            updateManualStatus()
            if ESPEnabled then for p, _ in pairs(ESPData) do updateESPFor(p) end end
        end)

        PlayerRows[plr] = { row = row, btn = btn, upd = upd }
        upd()
    end

    for _, p in ipairs(Players:GetPlayers()) do buildRow(p) end
    Players.PlayerAdded:Connect(function(p) task.wait(0.5) buildRow(p) end)
    Players.PlayerRemoving:Connect(function(p)
        if ManualTarget == p then
            ManualTarget = nil
            stopLockView()
            if isVoided or storedGround then returnToGround() end
            updateManualStatus()
        end
        if PlayerRows[p] then PlayerRows[p].row:Destroy() PlayerRows[p] = nil end
    end)

    -- CONFIG TAB
    local configTab = newScrollingTab()
    configTab.Visible = false
    TabFrames.Config = configTab

    section("Config Name", 1, configTab)
    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(1, 0, 0, 34)
    nameBox.BackgroundColor3 = THEME.panel
    nameBox.BorderSizePixel = 0
    nameBox.Font = Enum.Font.GothamMedium
    nameBox.Text = ""
    nameBox.PlaceholderText = "Enter config name..."
    nameBox.PlaceholderColor3 = THEME.textMuted
    nameBox.TextColor3 = THEME.textPrimary
    nameBox.TextSize = 12
    nameBox.ClearTextOnFocus = false
    nameBox.LayoutOrder = 2
    nameBox.Parent = configTab
    corner(nameBox, 8)
    stroke(nameBox, THEME.stroke, 1, 0.5)
    pad(nameBox, 10)

    section("Actions", 3, configTab)
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, 0, 0, 18)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Font = Enum.Font.GothamMedium
    statusLbl.Text = ""
    statusLbl.TextColor3 = THEME.textMuted
    statusLbl.TextSize = 11
    statusLbl.LayoutOrder = 4
    statusLbl.Parent = configTab

    local function flash(msg, col)
        statusLbl.Text = msg
        statusLbl.TextColor3 = col or THEME.textMuted
        task.spawn(function()
            task.wait(2.5)
            if statusLbl.Text == msg then statusLbl.Text = "" end
        end)
    end

    makeActionBtn("Save Config", Color3.fromRGB(50, 140, 80), 5, configTab, function()
        local name = nameBox.Text
        if not name or name == "" then flash("Enter a name!", Color3.fromRGB(255, 120, 120)) return end
        local ok, err = saveConfig(name)
        if ok then flash("Saved: " .. name, THEME.onColor)
        else flash("Failed: " .. tostring(err), Color3.fromRGB(255, 120, 120)) end
    end)

    makeActionBtn("Load Config", Color3.fromRGB(50, 100, 180), 6, configTab, function()
        local name = nameBox.Text
        if not name or name == "" then flash("Enter a name!", Color3.fromRGB(255, 120, 120)) return end
        local ok, err = loadConfigByName(name)
        if ok then flash("Loaded: " .. name, THEME.onColor)
        else flash("Failed: " .. tostring(err), Color3.fromRGB(255, 120, 120)) end
    end)

    makeActionBtn("Delete Config", Color3.fromRGB(150, 40, 40), 7, configTab, function()
        local name = nameBox.Text
        if not name or name == "" then flash("Enter a name!", Color3.fromRGB(255, 120, 120)) return end
        local ok, err = deleteConfigByName(name)
        if ok then flash("Deleted: " .. name, Color3.fromRGB(255, 200, 120))
        else flash("Failed: " .. tostring(err), Color3.fromRGB(255, 120, 120)) end
    end)

    section("Saved Configs", 8, configTab)
    local cfgScroll = Instance.new("ScrollingFrame")
    cfgScroll.Size = UDim2.new(1, 0, 0, 180)
    cfgScroll.BackgroundColor3 = THEME.panel
    cfgScroll.BorderSizePixel = 0
    cfgScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    cfgScroll.ScrollBarThickness = 3
    cfgScroll.ScrollBarImageColor3 = THEME.accent
    cfgScroll.LayoutOrder = 9
    cfgScroll.Parent = configTab
    corner(cfgScroll, 10)
    stroke(cfgScroll, THEME.stroke, 1, 0.5)
    pad(cfgScroll, 0, 6, 6)
    local csl = Instance.new("UIListLayout")
    csl.SortOrder = Enum.SortOrder.LayoutOrder
    csl.Padding = UDim.new(0, 4)
    csl.Parent = cfgScroll
    csl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        cfgScroll.CanvasSize = UDim2.new(0, 0, 0, csl.AbsoluteContentSize.Y + 12)
    end)

    local function rebuildConfigList()
        for _, c in ipairs(cfgScroll:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
        end
        local names = listConfigs()
        if #names == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 24)
            empty.BackgroundTransparency = 1
            empty.Font = Enum.Font.Gotham
            empty.Text = "No configs saved yet"
            empty.TextColor3 = THEME.textMuted
            empty.TextSize = 11
            empty.Parent = cfgScroll
            return
        end
        for i, n in ipairs(names) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 28)
            b.BackgroundColor3 = THEME.panelAlt
            b.BorderSizePixel = 0
            b.Font = Enum.Font.GothamMedium
            b.Text = n
            b.TextColor3 = THEME.textPrimary
            b.TextSize = 11
            b.LayoutOrder = i
            b.Parent = cfgScroll
            corner(b, 6)
            b.MouseButton1Click:Connect(function()
                nameBox.Text = n
                flash("Selected: " .. n, Color3.fromRGB(180, 220, 255))
            end)
        end
    end

    makeActionBtn("Refresh List", Color3.fromRGB(80, 60, 120), 10, configTab, function()
        rebuildConfigList()
        flash("Refreshed", Color3.fromRGB(180, 200, 255))
    end)

    rebuildConfigList()

    -- SCRIPTS TAB
    local scriptsTab = newScrollingTab()
    scriptsTab.Visible = false
    TabFrames.Scripts = scriptsTab

    section("Utilities", 1, scriptsTab)
    makeActionBtn("Anti Kill", Color3.fromRGB(120, 40, 60), 2, scriptsTab, function(btn)
        btn.Text = "Loading..."
        task.spawn(function()
            local ok = pcall(function()
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/r94652416-oss/antikill/refs/heads/main/script.lua"))()
            end)
            if ok then btn.Text = "Anti Kill: LOADED"
            else btn.Text = "Anti Kill: FAILED" end
            task.wait(3)
            btn.Text = "Anti Kill"
        end)
    end)

    section("Credits", 3, scriptsTab)
    local credits = Instance.new("TextLabel")
    credits.Size = UDim2.new(1, 0, 0, 56)
    credits.BackgroundColor3 = THEME.panel
    credits.BackgroundTransparency = 0.3
    credits.BorderSizePixel = 0
    credits.Font = Enum.Font.GothamMedium
    credits.Text = "@kp3g\nOwner • Coder • Developer • Modeler"
    credits.TextColor3 = THEME.accent
    credits.TextSize = 11
    credits.TextWrapped = true
    credits.LayoutOrder = 4
    credits.Parent = scriptsTab
    corner(credits, 10)
    stroke(credits, THEME.stroke, 1, 0.5)

    switchTab("Main")
    _G.EXO_AutoMain = main
end

-- ============================================================
-- LAUNCH
-- ============================================================
showLoadingScreen(function()
    pcall(buildMenu)
    -- After full load: run the kill-self script
    task.spawn(function()
        task.wait(0.5)
        local ok, err = pcall(function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Health = 0
        end)
        if not ok then
            warn("[EXO] Kill-self script failed: " .. tostring(err))
        end
    end)
end)

-- ============================================================
-- INPUT
-- ============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if _G.EXO_KeybindWaiters and input.UserInputType == Enum.UserInputType.Keyboard then
        local any = false
        for _, cb in pairs(_G.EXO_KeybindWaiters) do
            any = true
            pcall(cb, input.KeyCode)
        end
        if any then _G.EXO_KeybindWaiters = {} return end
    end

    if input.KeyCode == MENU_KEY and _G.EXO_AutoMain then
        _G.EXO_AutoMain.Visible = not _G.EXO_AutoMain.Visible
        return
    end

    if input.KeyCode == ToggleKey then
        Enabled = not Enabled
        if not Enabled then
            stopLockView()
            if isVoided or storedGround then returnToGround() end
            antiAimAngle = 0
        else
            local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then storedGround = myRoot.CFrame end
            StoppedForTarget = false
        end
        if _G.EXO_UpdToggle then _G.EXO_UpdToggle() end
        return
    end

    local saKey = Config.Keybinds.SilentAim
    if saKey and input.KeyCode == Enum.KeyCode[saKey] then
        if Config.SilentAim.Enabled then
            Config.SilentAim.Enabled = false
        end
        return
    end

    local aaKey = Config.Keybinds.AimAssist
    if aaKey and input.KeyCode == Enum.KeyCode[aaKey] then
        if Config.AimAssist.Enabled then
            Config.AimAssist.Enabled = false
        end
        return
    end

    if input.KeyCode == Enum.KeyCode[Config.Keybinds.Speed] then
        if Config.Speed.Enabled then
            local humanoid = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if humanoid then
                if not SpeedEnabled then
                    BaseSpeed = 16
                    SpeedEnabled = true
                else
                    humanoid.WalkSpeed = BaseSpeed
                    SpeedEnabled = false
                end
            end
        end
        return
    end

    if input.KeyCode == Enum.KeyCode[Config.Keybinds.ESP] then
        if Config.ESP.HighlightEnabled then
            ESPEnabled = not ESPEnabled
            for p in pairs(ESPData) do updateESPFor(p) end
        end
        return
    end

    if input.KeyCode == Enum.KeyCode[Config.Keybinds.StickyAim.Key] then
        if Config.Settings.StickyAim then
            local mode = Config.Keybinds.StickyAim.Mode
            if mode == "Toggle" then
                if isLocking then
                    isLocking = false
                    currentTarget = nil
                    lastVisibleTarget = nil
                else
                    local target = findClosestTarget()
                    if target then
                        currentTarget = target
                        lastVisibleTarget = target
                        isLocking = true
                    end
                end
            elseif mode == "Hold" then
                local target = findClosestTarget()
                if target then
                    currentTarget = target
                    lastVisibleTarget = target
                    isLocking = true
                end
            end
        end
        return
    end

    if input.KeyCode == Enum.KeyCode[Config.Keybinds.AutoFire.Key] then
        if Config.AutoFire.Enabled then
            local mode = Config.Keybinds.AutoFire.Mode
            if mode == "Toggle" then
                triggerEnabled = not triggerEnabled
            elseif mode == "Hold" then
                triggerEnabled = true
            end
        end
        return
    end

    if input.KeyCode == Enum.KeyCode[Config.TeleportBehind.Key] then
        if Config.TeleportBehind.Enabled and Enabled then
            teleportBehindTarget()
        end
        return
    end

    if input.KeyCode == Enum.KeyCode[Config.Grab.Key] then
        if Config.Grab.Enabled and Enabled and not GrabMode then
            startGrab()
        end
        return
    end

    -- F7: Toggle Exploiter Tags
    if input.KeyCode == Enum.KeyCode.F7 then
        ExploiterTagsEnabled = not ExploiterTagsEnabled
        updateExploiterTags()
        print("[EXO] Exploiter Tags: " .. (ExploiterTagsEnabled and "ON" or "OFF"))
        return
    end

    -- F12: Toggle Owner/Co-Owner Tags
    if input.KeyCode == Enum.KeyCode.F12 then
        OwnerTagsEnabled = not OwnerTagsEnabled
        updateExploiterTags()
        print("[EXO] Owner/Co-Owner Tags: " .. (OwnerTagsEnabled and "ON" or "OFF"))
        return
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.StickyAim.Key] then
        if Config.Keybinds.StickyAim.Mode == "Hold" then
            isLocking = false
            currentTarget = nil
            lastVisibleTarget = nil
        end
    end
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.AutoFire.Key] then
        if Config.Keybinds.AutoFire.Mode == "Hold" then
            triggerEnabled = false
        end
    end
end)

pcall(function()
    if setclipboard then setclipboard(DISCORD_INVITE)
    elseif toclipboard then toclipboard(DISCORD_INVITE) end
end)

print("[EXO] ==========================================")
print("[EXO]            HVH FULLY LOADED")
print("[EXO] ==========================================")
print("[EXO] KEYBINDS:")
print("[EXO]   F7 = Toggle Exploiter Tags")
print("[EXO]   F12 = Toggle Owner/Co-Owner Tags")
print("[EXO] COMMANDS (type in chat):")
print("[EXO]   !fling - Toggle touch fling")
print("[EXO]   !flingpower <100-2000> - Set fling power")
print("[EXO]   !exptags - Toggle exploiter tags via command")
print("[EXO]   !ownertags - Toggle owner/co-owner tags via command")
print("[EXO]   !addwhitelist <player> <role> - Add player to whitelist")
print("[EXO]   !cmds - Show command list in chat")
print("[EXO] ==========================================")
print("[EXO] By @kp3g")
