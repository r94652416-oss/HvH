-- ============================================================
-- ADMIN CHAT COMMANDS — prefix "!"
-- Partial names work ("!kill kp" matches "kp3g")
-- No name = ALL non-admin script users in the server
-- Commands broadcast cross-client via hidden chat channel
-- ============================================================
do
    local ADMIN_IDS = EXO_ADMIN_IDS
    local CMD_PREFIX = EXO_CMD_PREFIX
    local BCAST_PREFIX = "!EXO_CMD_"

    local frozenSet = {}
    local ADMIN_VOID_HEIGHT = 10000
    local savedPositions = {}

    local function myRoot()
        return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    end
    local function adminRoot(admin)
        return admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
    end
    local function setVelocity(v)
        local r = myRoot()
        if r then
            r.AssemblyLinearVelocity = v
            r.AssemblyAngularVelocity = Vector3.zero
        end
    end
    local function isAdminPlayer(p) return ADMIN_IDS[p.UserId] == true end

    local function localMatchesQuery(query)
        if not query or query == "" then
            return not isAdminPlayer(LP)
        end
        local q = query:lower()
        if LP.Name:lower() == q or LP.DisplayName:lower() == q then return true end
        if LP.Name:lower():find(q, 1, true) or LP.DisplayName:lower():find(q, 1, true) then
            return true
        end
        return false
    end

    local function broadcastCommand(cmd, query, arg)
        local payload = BCAST_PREFIX .. cmd .. "|" .. tostring(query or "") .. "|" .. tostring(arg or "")
        pcall(function()
            local tcs = game:GetService("TextChatService")
            if tcs and tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                local channels = tcs:FindFirstChild("TextChannels")
                if channels then
                    local rb = channels:FindFirstChild("RBXGeneral") or channels:FindFirstChildOfClass("TextChannel")
                    if rb then rb:SendAsync(payload) return end
                end
            end
            local replicated = game:GetService("ReplicatedStorage")
            local defaultChat = replicated:FindFirstChild("DefaultChatSystemChatEvents")
            if defaultChat then
                local sayMsg = defaultChat:FindFirstChild("SayMessageRequest")
                if sayMsg then sayMsg:FireServer(payload, "All") end
            end
        end)
    end

    local function getLocalHumanoid()
        return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    end
    local function getLocalRoot()
        return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    end
    local function getGuiParentLocal()
        local ok, hui = pcall(function() return gethui and gethui() end)
        if ok and hui then return hui end
        local ok2, pg = pcall(function() return LP:FindFirstChildOfClass("PlayerGui") end)
        if ok2 and pg then return pg end
        return CoreGui
    end

    local EXEC = {}

    -- ===== Basic =====
    EXEC.kill = function()
        local hum = getLocalHumanoid()
        if hum then
            hum.Health = 0
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
        end
        task.spawn(function()
            task.wait(0.5)
            local h2 = getLocalHumanoid()
            if h2 and h2.Health > 0 then
                local r = myRoot()
                if r then
                    r.CFrame = CFrame.new(r.Position.X, ADMIN_VOID_HEIGHT, r.Position.Z)
                    r.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end)
    end

    EXEC.damage = function(arg)
        local amt = tonumber(arg) or 25
        local hum = getLocalHumanoid()
        if hum then hum:TakeDamage(amt) end
    end

    EXEC.freeze = function()
        frozenSet[LP] = true
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local r = myRoot()
        if hum then
            hum.WalkSpeed = 0; hum.JumpPower = 0; hum.JumpHeight = 0; hum.AutoRotate = false
        end
        if r then r.Anchored = true; setVelocity(Vector3.zero) end
        task.spawn(function()
            while frozenSet[LP] do
                local c = LP.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                local rr = c and c:FindFirstChild("HumanoidRootPart")
                if h then h.WalkSpeed = 0; h.JumpPower = 0; h.JumpHeight = 0; h.AutoRotate = false end
                if rr then rr.Anchored = true end
                task.wait(0.5)
            end
        end)
    end

    EXEC.unfreeze = function()
        frozenSet[LP] = false
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local r = myRoot()
        if hum then
            hum.WalkSpeed = 16; hum.JumpPower = 50; hum.JumpHeight = 7.2; hum.AutoRotate = true
        end
        if r then r.Anchored = false end
    end

    EXEC.fling = function()
        local r = myRoot()
        if not r then return end
        r.Anchored = false
        local dir = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
        if dir.Magnitude < 0.1 then dir = Vector3.new(1, 0, 0) end
        setVelocity(dir.Unit * 300 + Vector3.new(0, 200, 0))
        r.AssemblyAngularVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
        task.spawn(function()
            for _ = 1, 30 do
                if frozenSet[LP] then break end
                local rr = myRoot()
                if rr then rr.AssemblyAngularVelocity = Vector3.new(math.random(-40, 40), math.random(-40, 40), math.random(-40, 40)) end
                task.wait(0.05)
            end
        end)
    end

    -- !fing — fling the target hard into the sky with a spin
    EXEC.fing = function()
        local r = myRoot()
        if not r then return end
        r.Anchored = false
        local dir = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
        if dir.Magnitude < 0.1 then dir = Vector3.new(1, 0, 0) end
        dir = dir.Unit
        r.AssemblyLinearVelocity = dir * 400 + Vector3.new(0, 800, 0)
        r.AssemblyAngularVelocity = Vector3.new(200, 200, 200)
        task.spawn(function()
            for _ = 1, 60 do
                if frozenSet[LP] then break end
                local rr = myRoot()
                if rr then rr.AssemblyAngularVelocity = Vector3.new(math.random(-150, 150), math.random(-150, 150), math.random(-150, 150)) end
                task.wait(0.05)
            end
        end)
    end

    EXEC.void = function()
        local r = myRoot()
        if r then
            savedPositions[LP] = r.CFrame
            r.CFrame = CFrame.new(r.Position.X, ADMIN_VOID_HEIGHT, r.Position.Z)
            r.AssemblyLinearVelocity = Vector3.zero
        end
    end

    EXEC.unvoid = function()
        local r = myRoot()
        if r then
            r.CFrame = CFrame.new(r.Position.X, 50, r.Position.Z)
            r.AssemblyLinearVelocity = Vector3.zero
        end
    end

    EXEC.return = function()
        local saved = savedPositions[LP]
        local r = myRoot()
        if saved and r then
            r.CFrame = saved
            r.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- ===== Movement =====
    EXEC.jump = function()
        local r = myRoot()
        if r then
            r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 200, r.AssemblyLinearVelocity.Z)
        end
    end

    EXEC.spin = function(arg)
        local speed = tonumber(arg) or 30
        local r = myRoot()
        if r then
            task.spawn(function()
                local endAt = tick() + 3
                while tick() < endAt do
                    if not r.Parent then break end
                    r.AssemblyAngularVelocity = Vector3.new(0, speed, 0)
                    task.wait(0.05)
                end
                if r and r.Parent then r.AssemblyAngularVelocity = Vector3.zero end
            end)
        end
    end

    EXEC.speed = function(arg)
        local mult = tonumber(arg) or 5
        local hum = getLocalHumanoid()
        if hum then
            hum.WalkSpeed = 16 * mult
            task.spawn(function()
                task.wait(10)
                local h = getLocalHumanoid()
                if h then h.WalkSpeed = 16 end
            end)
        end
    end

    EXEC.slow = function(arg)
        local mult = tonumber(arg) or 3
        local hum = getLocalHumanoid()
        if hum then
            hum.WalkSpeed = 16 / mult
            task.spawn(function()
                task.wait(10)
                local h = getLocalHumanoid()
                if h then h.WalkSpeed = 16 end
            end)
        end
    end

    EXEC.jumppower = function(arg)
        local p = tonumber(arg) or 500
        local hum = getLocalHumanoid()
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = p
        end
    end

    EXEC.hipheight = function(arg)
        local h = tonumber(arg) or 10
        local hum = getLocalHumanoid()
        if hum then hum.HipHeight = h end
    end

    EXEC.freezevel = function()
        local r = myRoot()
        if r then
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- ===== Combat =====
    EXEC.shoot = function()
        local char = LP.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
    end

    EXEC.rapid = function()
        local char = LP.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            task.spawn(function()
                local endAt = tick() + 3
                while tick() < endAt do
                    local c = LP.Character
                    local t = c and c:FindFirstChildOfClass("Tool")
                    if t then pcall(function() t:Activate() end) end
                    task.wait(0.05)
                end
            end)
        end
    end

    EXEC.equip = function(arg)
        local name = tostring(arg or "")
        if name == "" then return end
        local hum = getLocalHumanoid()
        local bp = LP:FindFirstChildOfClass("Backpack")
        if not hum or not bp then return end
        local tool = bp:FindFirstChild(name) or (LP.Character and LP.Character:FindFirstChild(name))
        if tool then pcall(function() hum:EquipTool(tool) end) end
    end

    EXEC.unequip = function()
        local hum = getLocalHumanoid()
        if hum then hum:UnequipTools() end
    end

    -- ===== Position =====
    EXEC.sit = function()
        local hum = getLocalHumanoid()
        if hum then hum.Sit = true end
    end

    EXEC.unsit = function()
        local hum = getLocalHumanoid()
        if hum then hum.Sit = false end
    end

    EXEC.climb = function()
        local hum = getLocalHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Climbing) end
    end

    EXEC.ragdoll = function()
        local hum = getLocalHumanoid()
        if hum then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
            for _, m in ipairs(hum:GetChildren()) do
                if m:IsA("Motor6D") then
                    local socket = Instance.new("BallSocketConstraint")
                    local a0 = Instance.new("Attachment"); a0.Parent = m.Part0
                    local a1 = Instance.new("Attachment"); a1.Parent = m.Part1
                    socket.Attachment0 = a0
                    socket.Attachment1 = a1
                    socket.Parent = m.Part0
                    m.Enabled = false
                end
            end
        end
    end

    -- ===== Effects (fun client-side visuals/sounds) =====
    EXEC.flash = function()
        local gui = Instance.new("ScreenGui")
        gui.IgnoreGuiInset = true
        gui.Name = "EXO_FLASH"
        gui.Parent = getGuiParentLocal()
        for _ = 1, 6 do
            local f = Instance.new("Frame")
            f.Size = UDim2.fromScale(1, 1)
            f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            f.BackgroundTransparency = 0.2
            f.BorderSizePixel = 0
            f.ZIndex = 10
            f.Parent = gui
            task.spawn(function() task.wait(0.08) f:Destroy() end)
            task.wait(0.15)
        end
        task.wait(1)
        gui:Destroy()
    end

    EXEC.rainbow = function()
        local gui = Instance.new("ScreenGui")
        gui.IgnoreGuiInset = true
        gui.Name = "EXO_RAINBOW"
        gui.Parent = getGuiParentLocal()
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromScale(1, 1)
        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        frame.BackgroundTransparency = 0.7
        frame.BorderSizePixel = 0
        frame.ZIndex = 5
        frame.Parent = gui
        task.spawn(function()
            local endAt = tick() + 5
            while tick() < endAt do
                if not frame.Parent then break end
                frame.BackgroundColor3 = Color3.fromHSV(tick() % 1, 1, 1)
                task.wait(0.03)
            end
            gui:Destroy()
        end)
    end

    EXEC.shake = function()
        task.spawn(function()
            local cam = workspace.CurrentCamera
            if not cam then return end
            local orig = cam.CFrame
            local endAt = tick() + 3
            while tick() < endAt do
                if not cam then break end
                local offset = Vector3.new(
                    math.random(-15, 15) / 10,
                    math.random(-15, 15) / 10,
                    math.random(-15, 15) / 10
                )
                cam.CFrame = orig * CFrame.new(offset)
                task.wait(0.02)
            end
            if cam then cam.CFrame = orig end
        end)
    end

    EXEC.spin_cam = function()
        task.spawn(function()
            local cam = workspace.CurrentCamera
            if not cam then return end
            local endAt = tick() + 5
            while tick() < endAt do
                if not cam then break end
                cam.CFrame = cam.CFrame * CFrame.Angles(0, 0.15, 0)
                task.wait(0.02)
            end
        end)
    end

    EXEC.flip = function()
        task.spawn(function()
            local cam = workspace.CurrentCamera
            if not cam then return end
            local orig = cam.CFrame
            local endAt = tick() + 2
            while tick() < endAt do
                if not cam then break end
                cam.CFrame = orig * CFrame.Angles(0, 0, math.rad(180))
                task.wait(0.02)
            end
            if cam then cam.CFrame = orig end
        end)
    end

    EXEC.blind = function()
        local gui = Instance.new("ScreenGui")
        gui.IgnoreGuiInset = true
        gui.Name = "EXO_BLIND"
        gui.Parent = getGuiParentLocal()
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromScale(1, 1)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.ZIndex = 100
        frame.Parent = gui
        task.spawn(function()
            task.wait(4)
            for i = 1, 20 do
                frame.BackgroundTransparency = i / 20
                task.wait(0.05)
            end
            gui:Destroy()
        end)
    end

    EXEC.earrape = function()
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://904831714"
            s.Volume = 10
            s.Parent = getGuiParentLocal()
            s:Play()
            task.wait(1.5)
            s:Destroy()
        end)
    end

    EXEC.fireworks = function()
        task.spawn(function()
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local attach = Instance.new("Attachment")
            attach.Parent = root
            for _ = 1, 5 do
                local emitter = Instance.new("ParticleEmitter")
                emitter.Texture = "rbxassetid://243660364"
                emitter.Rate = 0
                emitter.Lifetime = NumberRange.new(1, 2)
                emitter.Speed = NumberRange.new(20, 40)
                emitter.SpreadAngle = Vector2.new(180, 180)
                emitter.Color = ColorSequence.new(Color3.fromHSV(math.random(), 1, 1))
                emitter.Size = NumberSequence.new(1.5)
                emitter.Parent = attach
                emitter:Emit(60)
                task.wait(0.4)
            end
            task.wait(2)
            attach:Destroy()
        end)
    end

    EXEC.explode = function()
        task.spawn(function()
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _ = 1, 8 do
                local ex = Instance.new("Explosion")
                ex.Position = root.Position + Vector3.new(
                    math.random(-15, 15),
                    math.random(0, 15),
                    math.random(-15, 15)
                )
                ex.BlastRadius = 5
                ex.BlastPressure = 0
                ex.DestroyJointRadiusPercent = 0
                ex.Parent = workspace
                task.wait(0.1)
            end
        end)
    end

    EXEC.smoke = function()
        task.spawn(function()
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local attach = Instance.new("Attachment")
            attach.Parent = root
            local emitter = Instance.new("ParticleEmitter")
            emitter.Texture = "rbxassetid://243660364"
            emitter.Rate = 60
            emitter.Lifetime = NumberRange.new(1.5, 2.5)
            emitter.Speed = NumberRange.new(3, 8)
            emitter.SpreadAngle = Vector2.new(180, 180)
            emitter.Color = ColorSequence.new(Color3.fromRGB(80, 80, 80))
            emitter.Size = NumberSequence.new(3)
            emitter.Transparency = NumberSequence.new(0.4)
            emitter.Parent = attach
            task.wait(5)
            emitter.Enabled = false
            task.wait(3)
            attach:Destroy()
        end)
    end

    EXEC.fly = function(arg)
        local hum = getLocalHumanoid()
        if not hum then return end
        local speed = tonumber(arg) or 100
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local root = myRoot()
            if not root or not LP.Character then conn:Disconnect() return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            if dir.Magnitude > 0 then
                root.AssemblyLinearVelocity = dir.Unit * speed
            end
        end)
        task.spawn(function()
            task.wait(15)
            pcall(function() conn:Disconnect() end)
        end)
    end

    EXEC.noclip = function()
        task.spawn(function()
            local endAt = tick() + 10
            while tick() < endAt do
                local char = LP.Character
                if char then
                    for _, d in ipairs(char:GetDescendants()) do
                        if d:IsA("BasePart") and d.CanCollide then
                            d.CanCollide = false
                        end
                    end
                end
                task.wait(0.1)
            end
            local char = LP.Character
            if char then
                for _, d in ipairs(char:GetDescendants()) do
                    if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                        d.CanCollide = true
                    end
                end
            end
        end)
    end

    EXEC.respawn = function()
        local hum = getLocalHumanoid()
        if hum then hum.Health = 0 end
    end

    -- ============================================================
    -- Command table
    -- ============================================================
    local COMMANDS = {
        -- Basic
        kill       = {arg = false, exec = "kill"},
        damage     = {arg = true,  exec = "damage"},
        freeze     = {arg = false, exec = "freeze"},
        unfreeze   = {arg = false, exec = "unfreeze"},
        fling      = {arg = false, exec = "fling"},
        fing       = {arg = false, exec = "fing"},
        void       = {arg = false, exec = "void"},
        unvoid     = {arg = false, exec = "unvoid"},
        return     = {arg = false, exec = "return"},

        -- Movement
        jump       = {arg = false, exec = "jump"},
        spin       = {arg = true,  exec = "spin"},
        speed      = {arg = true,  exec = "speed"},
        slow       = {arg = true,  exec = "slow"},
        jumppower  = {arg = true,  exec = "jumppower"},
        hipheight  = {arg = true,  exec = "hipheight"},
        freezevel  = {arg = false, exec = "freezevel"},
        fly        = {arg = true,  exec = "fly"},
        noclip     = {arg = false, exec = "noclip"},

        -- Combat
        shoot      = {arg = false, exec = "shoot"},
        rapid      = {arg = false, exec = "rapid"},
        equip      = {arg = true,  exec = "equip"},
        unequip    = {arg = false, exec = "unequip"},

        -- Position
        sit        = {arg = false, exec = "sit"},
        unsit      = {arg = false, exec = "unsit"},
        climb      = {arg = false, exec = "climb"},
        ragdoll    = {arg = false, exec = "ragdoll"},

        -- Effects
        flash      = {arg = false, exec = "flash"},
        rainbow    = {arg = false, exec = "rainbow"},
        shake      = {arg = false, exec = "shake"},
        spincam    = {arg = false, exec = "spin_cam"},
        flip       = {arg = false, exec = "flip"},
        blind      = {arg = false, exec = "blind"},
        earrape    = {arg = false, exec = "earrape"},
        fireworks  = {arg = false, exec = "fireworks"},
        explode    = {arg = false, exec = "explode"},
        smoke      = {arg = false, exec = "smoke"},

        -- Lifecycle
        respawn    = {arg = false, exec = "respawn"},
    }

    -- ============================================================
    -- Incoming payload handler
    -- ============================================================
    local function isPayload(s)
        return type(s) == "string" and s:sub(1, #BCAST_PREFIX) == BCAST_PREFIX
    end

    local function resolveSenderPlayer(senderName)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == senderName or p.DisplayName == senderName then return p end
        end
        return nil
    end

    local function handleCommandPayload(senderName, payload)
        if not isPayload(payload) then return end
        local sender = resolveSenderPlayer(senderName)
        if not sender or not ADMIN_IDS[sender.UserId] then return end

        local body = payload:sub(#BCAST_PREFIX + 1)
        local cmd, query, arg = body:match("^([^|]*)|([^|]*)|(.*)$")
        if not cmd then return end
        cmd = cmd:lower()

        local info = COMMANDS[cmd]
        if not info then return end

        if not localMatchesQuery(query) then return end

        local fn = EXEC[info.exec]
        if not fn then return end
        print("[EXO CMD] " .. cmd .. (query ~= "" and (" (" .. query .. ")") or " (all)") .. (arg ~= "" and (" arg=" .. arg) or ""))
        pcall(fn, arg)
    end

    pcall(function()
        Players.PlayerChatted:Connect(function(_, plr, msg)
            if isPayload(msg) then handleCommandPayload(plr.Name, msg) end
        end)
    end)
    pcall(function()
        local tcs = game:GetService("TextChatService")
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            tcs.MessageReceived:Connect(function(msg)
                if msg.Status ~= Enum.TextChatMessageStatus.Success then return end
                if not msg.TextSource then return end
                local text = msg.Text or ""
                if isPayload(text) then
                    handleCommandPayload(msg.TextSource.Name, text)
                end
            end)
        end
    end)

    -- ============================================================
    -- Admin-side command entry
    -- ============================================================
    local function onChat(plr, msg)
        if type(msg) ~= "string" then return end
        if not ADMIN_IDS[plr.UserId] then return end
        if msg:sub(1, 1) ~= CMD_PREFIX then return end

        local body = msg:sub(#CMD_PREFIX + 1)
        local cmd, rest = body:match("^(%S+)%s*(.*)$")
        if not cmd then return end
        cmd = cmd:lower()
        rest = rest and rest:gsub("^%s+", ""):gsub("%s+$", "") or ""

        if cmd == "cmds" or cmd == "help" then
            print("[EXO ADMIN] ─── Commands ───")
            print("  Basic:     !kill !damage [n] !freeze !unfreeze !fling !fing")
            print("             !void !unvoid !return")
            print("  Movement:  !jump !spin [spd] !speed [x] !slow [x]")
            print("             !jumppower [n] !hipheight [n] !freezevel")
            print("             !fly [speed] !noclip")
            print("  Combat:    !shoot !rapid !equip [tool] !unequip")
            print("  Position:  !sit !unsit !climb !ragdoll")
            print("  Effects:   !flash !rainbow !shake !spincam !flip")
            print("             !blind !earrape !fireworks !explode !smoke")
            print("  Lifecycle: !respawn")
            print("  No name = ALL script users | Partial names OK")
            return
        end

        local info = COMMANDS[cmd]
        if not info then return end

        local query, arg = "", ""
        if info.arg then
            local parts = {}
            for token in rest:gmatch("%S+") do table.insert(parts, token) end
            if #parts == 0 then
                query = ""; arg = ""
            elseif #parts == 1 then
                if tonumber(parts[1]) then query = ""; arg = parts[1]
                else query = parts[1]; arg = "" end
            else
                arg = parts[#parts]
                table.remove(parts, #parts)
                query = table.concat(parts, " ")
            end
        else
            query = rest
        end

        print("[EXO ADMIN] " .. plr.Name .. " → " .. CMD_PREFIX .. cmd ..
              (query ~= "" and (" '" .. query .. "'") or " (all)") ..
              (arg ~= "" and (" arg=" .. arg) or ""))

        broadcastCommand(cmd, query, arg)
        handleCommandPayload(plr.Name, BCAST_PREFIX .. cmd .. "|" .. query .. "|" .. arg)
    end

    pcall(function()
        Players.PlayerChatted:Connect(function(_, plr, msg) onChat(plr, msg) end)
    end)
    pcall(function()
        local tcs = game:GetService("TextChatService")
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            tcs.MessageReceived:Connect(function(msg)
                if msg.Status ~= Enum.TextChatMessageStatus.Success then return end
                if not msg.TextSource then return end
                local text = msg.Text or ""
                if text:sub(1, 1) == CMD_PREFIX then
                    local plr = nil
                    local ok, num = pcall(tonumber, msg.TextSource.Name)
                    if ok and num then plr = Players:GetPlayerByUserId(num) end
                    if not plr then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p.Name == msg.TextSource.Name or p.DisplayName == msg.TextSource.Name then plr = p break end
                        end
                    end
                    if plr then onChat(plr, text) end
                end
            end)
        end
    end)

    LP.CharacterAdded:Connect(function() frozenSet[LP] = false end)

    print("[EXO] (HvH loaded)")
end
