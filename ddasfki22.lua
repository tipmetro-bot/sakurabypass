local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ENV = _G
do
    local okg, g = pcall(function() return getgenv and getgenv() end)
    if okg and type(g) == "table" then ENV = g end
end

if ENV.SakuraRivalsUnload then pcall(ENV.SakuraRivalsUnload) end
if ENV.SakuraBypassUnload then pcall(ENV.SakuraBypassUnload) end
do
    local KEY_SITE = "https://tipmetro-bot.github.io/keysystemsakura.github.io/"
    local KEY_DAYS = 10
    local KEY_FILE = "sakura_bypass_key.json"
    local HASHES = {
        ["22a15dd0bf3ceff2"] = true,
        ["73c23989580e9b0d"] = true,
        ["37379129c35d3532"] = true,
        ["27632f99c3582329"] = true,
        ["756a5888390a1179"] = true,
        ["9e7afde459b434c2"] = true,
        ["02bfbbcaaa895901"] = true,
        ["e8d61b5569e37220"] = true,
        ["10ec658411c34a9a"] = true,
        ["b4b95548525c3b06"] = true,
        ["056d8b5277347ba0"] = true,
        ["7e129adc8f4571f2"] = true,
        ["03d7302ab9d9eb2a"] = true,
        ["94248aa302adf835"] = true,
        ["bd28a432dc81f4aa"] = true,
        ["8592afc3816635b7"] = true,
        ["96249274ca4eadbb"] = true,
        ["65994845c3a3ed9c"] = true,
        ["2471e33b96972c92"] = true,
        ["2748140ca375c15b"] = true,
        ["888d723804d7f0a8"] = true,
        ["080dc3d4bff85fd4"] = true,
        ["2751a5049187fb70"] = true,
        ["6e25f01128229812"] = true,
        ["90cf964a9d10b09c"] = true,
        ["3a42e5f0bf868705"] = true,
        ["3f60490eb517ad13"] = true,
        ["a204ac54ec7f3162"] = true,
        ["5b580c5028e2aa7a"] = true,
        ["b85d1057509288d5"] = true,
        ["abe8c2b4202d82a6"] = true,
        ["7f015ee193144d3e"] = true,
        ["6be7bafdc1e992f2"] = true,
        ["fc5fe1abbe189114"] = true,
        ["c4f7e116e154e125"] = true,
        ["aad4feaa8846a663"] = true,
        ["60b023784f35c170"] = true,
        ["1281069411203b79"] = true,
        ["d78527f24ca4b721"] = true,
        ["91fee9105fbb7cb1"] = true,
        ["dc87674892f450f8"] = true,
        ["20b11f2223d88703"] = true,
        ["c5f6094a64a72d12"] = true,
        ["3593a7a4d933cb5f"] = true,
        ["60e6ea84eefdec6c"] = true,
        ["4802632b38d91194"] = true,
        ["bf9ae5d30a8549b4"] = true,
        ["d38abdd4f4574c6c"] = true,
        ["0bcb4c3c81e5aa5b"] = true,
        ["6f6816b0e46394b9"] = true,
        ["b3695efce4e3326b"] = true,
        ["e97d7be7e18b77f1"] = true,
        ["202c34e4e7236304"] = true,
        ["7d334c695a613042"] = true,
        ["a2a04b2097235095"] = true,
        ["3e24213a183c90e9"] = true,
        ["4c38a0add619d21d"] = true,
        ["588618c591686095"] = true,
        ["170e8475722f8868"] = true,
        ["23a6079f785b2db8"] = true
    }
    local HttpService = game:GetService("HttpService")

    local function hashKey(k)
        local h1, h2 = 5381, 52711
        local s = "sk1|" .. k
        for i = 1, #s do
            local b = string.byte(s, i)
            h1 = (h1 * 131 + b) % 4294967291
            h2 = (h2 * 137 + b * 7 + 1) % 4294967279
        end
        return string.format("%08x%08x", h1, h2)
    end

    local function readSave()
        local save = ENV.SakuraKeySave
        if type(save) == "table" then return save end
        save = {used = {}}
        if type(isfile) == "function" and type(readfile) == "function" then
            pcall(function()
                if isfile(KEY_FILE) then
                    local d = HttpService:JSONDecode(readfile(KEY_FILE))
                    if type(d) == "table" then
                        save.key = type(d.key) == "string" and d.key or nil
                        save.used = type(d.used) == "table" and d.used or {}
                    end
                end
            end)
        end
        ENV.SakuraKeySave = save
        return save
    end
    local function writeSave(save)
        ENV.SakuraKeySave = save
        if type(writefile) == "function" then
            pcall(function() writefile(KEY_FILE, HttpService:JSONEncode({key = save.key, used = save.used})) end)
        end
    end

    local function check(raw)
        local key = string.lower((tostring(raw or ""):gsub("%s+", "")))
        if not string.match(key, "^key%-%w+%-%w+%-%w+%-%w+$") then return "format" end
        local h = hashKey(key)
        if not HASHES[h] then return "bad" end
        local save = readSave()
        local t0 = tonumber(save.used[h])
        local now = os.time()
        if not t0 then
            t0 = now
            save.used[h] = t0
        end
        if now - t0 >= KEY_DAYS * 86400 then return "expired" end
        save.key = key
        writeSave(save)
        return "ok", t0
    end

    local function ask()
        local gui = Instance.new("ScreenGui")
        gui.Name = "sakura.bypass.key"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 1000
        local parented = false
        if gethui then
            local s, h = pcall(gethui)
            if s and h then gui.Parent = h parented = true end
        end
        if not parented then parented = pcall(function() gui.Parent = CoreGui end) end
        if not parented or not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

        local pink = Color3.fromRGB(255, 128, 176)
        local box = Instance.new("Frame")
        box.AnchorPoint = Vector2.new(0.5, 0.5)
        box.Position = UDim2.fromScale(0.5, 0.5)
        box.Size = UDim2.fromOffset(360, 232)
        box.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
        box.BorderSizePixel = 0
        box.Parent = gui
        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(0, 10)
        cr.Parent = box
        local st = Instance.new("UIStroke")
        st.Color = pink
        st.Thickness = 1.5
        st.Parent = box
        local sc = Instance.new("UIScale")
        sc.Parent = box
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        sc.Scale = math.clamp(math.min((vp.X - 20) / 360, (vp.Y - 20) / 232), 0.5, 1)

        local function lbl(text, y, size, color, bold)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Position = UDim2.fromOffset(16, y)
            l.Size = UDim2.new(1, -32, 0, size + 4)
            l.Text = text
            l.TextColor3 = color
            l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
            l.TextSize = size
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextWrapped = true
            l.Parent = box
            return l
        end
        lbl("sakura.bypass", 14, 20, pink, true)
        lbl("Key system. Get a free key on the website, it lasts " .. KEY_DAYS .. " days.", 42, 13, Color3.fromRGB(170, 170, 178), false)

        local input = Instance.new("TextBox")
        input.Position = UDim2.fromOffset(16, 82)
        input.Size = UDim2.new(1, -32, 0, 36)
        input.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
        input.BorderSizePixel = 0
        input.Text = ""
        input.PlaceholderText = "key-xxxxxxx-xxxxx-xxxxxx-xxxxx"
        input.PlaceholderColor3 = Color3.fromRGB(100, 100, 108)
        input.TextColor3 = Color3.fromRGB(235, 235, 240)
        input.Font = Enum.Font.Code
        input.TextSize = 14
        input.ClearTextOnFocus = false
        input.Parent = box
        local ic = Instance.new("UICorner")
        ic.CornerRadius = UDim.new(0, 6)
        ic.Parent = input

        local status = lbl("", 124, 13, Color3.fromRGB(170, 170, 178), false)
        status.Size = UDim2.new(1, -32, 0, 34)
        status.TextYAlignment = Enum.TextYAlignment.Top

        local result = nil
        local info = nil
        local function button(text, x, w, fill, cb)
            local b = Instance.new("TextButton")
            b.Position = UDim2.new(0, x, 1, -48)
            b.Size = UDim2.new(0, w, 0, 34)
            b.BackgroundColor3 = fill
            b.BorderSizePixel = 0
            b.Text = text
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 14
            b.AutoButtonColor = true
            b.Parent = box
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 6)
            c.Parent = b
            b.MouseButton1Click:Connect(cb)
            return b
        end
        local function submit()
            local res, t0 = check(input.Text)
            if res == "ok" then
                local left = math.max(0, KEY_DAYS * 86400 - (os.time() - t0))
                info = string.format("%.1f", left / 86400)
                status.TextColor3 = Color3.fromRGB(120, 230, 140)
                status.Text = "Key accepted. Days left: " .. info
                task.wait(0.6)
                result = "ok"
            elseif res == "expired" then
                status.TextColor3 = Color3.fromRGB(255, 110, 110)
                status.Text = "This key has expired. Get a new one on the website."
            elseif res == "format" then
                status.TextColor3 = Color3.fromRGB(255, 110, 110)
                status.Text = "Wrong format. Expected key-xxxxxxx-xxxxx-xxxxxx-xxxxx"
            else
                status.TextColor3 = Color3.fromRGB(255, 110, 110)
                status.Text = "Invalid key."
            end
        end
        button("Check key", 16, 150, pink, function() task.spawn(submit) end)
        button("Get key", 176, 100, Color3.fromRGB(44, 44, 52), function()
            local ok = false
            if type(setclipboard) == "function" then ok = pcall(setclipboard, KEY_SITE) end
            status.TextColor3 = Color3.fromRGB(170, 170, 178)
            status.Text = ok and ("Link copied, open it in a browser: " .. KEY_SITE) or ("Open in a browser: " .. KEY_SITE)
        end)
        button("Close", 286, 58, Color3.fromRGB(44, 44, 52), function() result = "closed" end)
        input.FocusLost:Connect(function(enter)
            if enter then task.spawn(submit) end
        end)

        local prefill = readSave().key
        if prefill then input.Text = prefill end

        while not result and gui.Parent do task.wait(0.1) end
        local ok = result == "ok"
        local save = readSave()
        local t0 = nil
        if ok then
            local h = hashKey(string.lower((input.Text:gsub("%s+", ""))))
            t0 = save.used[h]
        end
        pcall(function() gui:Destroy() end)
        return ok, t0
    end

    local passed, t0 = false, nil
    local saved = readSave().key
    if saved then
        local res, t = check(saved)
        if res == "ok" then passed, t0 = true, t end
    end
    if not passed then passed, t0 = ask() end
    if not passed then
        warn("[sakura.bypass] key was not entered, script stopped")
        return
    end
    if t0 then
        task.spawn(function()
            while true do
                task.wait(30)
                if os.time() - t0 >= KEY_DAYS * 86400 then
                    warn("[sakura.bypass] key expired")
                    if ENV.SakuraBypassUnload then pcall(ENV.SakuraBypassUnload) end
                    return
                end
            end
        end)
    end
end

local S = {
    Aim = {
        Enabled = false, Mode = "Silent", Activation = UserInputService.TouchEnabled and "Always" or "Hold LMB", TeamCheck = true, VisCheck = true,
        Part = "Head", Fov = 250, ShowFov = true, HitChance = 100, MaxDist = 1500, Smooth = 6, Gain = 1, Deadzone = 2, AutoShot = false, ShotDelay = 90,
        AssistFov = 80, AssistStrength = 12, AssistMaxStep = 4, AssistNeedMove = true,
    },
    Spin = {Enabled = false, Speed = 360, Direction = "Left", Visual = false},
    ESP = {
        Enabled = false, Box = true, BoxStyle = "Corner", Filled = false, Chams = true, Health = true, Skeleton = false, Name = true, Info = true,
        Tracers = false, TracerFrom = "Bottom", Npc = false, AutoRefresh = true, Interval = 3, TeamCheck = true, Color = "Sakura", MaxDist = 2000,
    },
    Win = {Enabled = false, TeamCheck = true, Part = "Head", Fire = true, VisOnly = true, Walk = true, Stop = 20, Smooth = 1, MaxDist = 800},
    Weapon = {Enabled = false, Recoil = true, RecoilPct = 100, Spread = true, SpreadPct = 100, Rescan = 0, Deep = false},
    Win2 = {Enabled = false, TeamCheck = true, Noclip = true, Fire = true, Dist = 8, Height = 0, Speed = 120, FireRange = 80, MaxDist = 2000},
    Skins = {Enabled = false, ShowAll = false},
    God = {Enabled = false, Health = true, AntiRagdoll = true, AntiKnock = true, VoidSave = true},
    Bhop = {Enabled = false, Mode = "Legit", Max = 40, Accel = 18, Turn = 6},
    Jump = {Enabled = false, Method = "Velocity", Power = 60, Infinite = false},
    Speed = {Enabled = false, Method = "CFrame", Speed = 32, Activation = "Always"},
    Bypass = {Enabled = false, AntiKick = true, BlockRemotes = true, SpoofSpeed = false},
    Anti = {Freeze = false, FreezeSpeed = true, Flash = false, Smoke = false, AFK = false},
    View = {FovOn = false, Fov = 100, Fullbright = false},
    Device = {Mode = "Auto", Interval = 3},
    UI = {Watermark = true, Accent = "Skeet", Notify = true, MobileBtn = UserInputService.TouchEnabled},
}

local State = {MenuOpen = false}
local Conns = {}
local Alive = true
local Unloaders = {}

local ESP_COLORS = {
    Sakura = Color3.fromRGB(255, 128, 176),
    White = Color3.fromRGB(255, 255, 255),
    Red = Color3.fromRGB(255, 70, 80),
    Cyan = Color3.fromRGB(0, 200, 255),
    Green = Color3.fromRGB(80, 255, 130),
}


local function conn(sig, fn)
    local c = sig:Connect(fn)
    Conns[#Conns + 1] = c
    return c
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do
        local ok, err = pcall(function() o[k] = v end)
        if not ok then warn("[sakura.bypass] " .. class .. "." .. tostring(k) .. ": " .. tostring(err)) end
    end
    if parent then o.Parent = parent end
    return o
end

local FONT = Enum.Font.SourceSansSemibold
local FONTB = Enum.Font.SourceSansBold
local BLACK = Color3.fromRGB(0, 0, 0)

local ACCENTS = {
    Skeet = {main = Color3.fromRGB(159, 202, 43), g = {Color3.fromRGB(55, 177, 218), Color3.fromRGB(203, 61, 211), Color3.fromRGB(201, 227, 58)}},
    Sakura = {main = Color3.fromRGB(255, 128, 176), g = {Color3.fromRGB(255, 128, 176), Color3.fromRGB(255, 214, 230), Color3.fromRGB(255, 128, 176)}},
    Ice = {main = Color3.fromRGB(80, 170, 255), g = {Color3.fromRGB(80, 170, 255), Color3.fromRGB(150, 230, 255), Color3.fromRGB(80, 170, 255)}},
    Orange = {main = Color3.fromRGB(255, 150, 40), g = {Color3.fromRGB(255, 90, 40), Color3.fromRGB(255, 200, 60), Color3.fromRGB(255, 90, 40)}},
}
local T = {
    Accent = ACCENTS.Skeet.main,
    Grad = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ACCENTS.Skeet.g[1]), ColorSequenceKeypoint.new(0.5, ACCENTS.Skeet.g[2]), ColorSequenceKeypoint.new(1, ACCENTS.Skeet.g[3]),
    }),
    Bg = Color3.fromRGB(17, 17, 17),
    Dark = Color3.fromRGB(10, 10, 10),
    Line = Color3.fromRGB(42, 42, 42),
    Ctl = Color3.fromRGB(34, 34, 34),
    Text = Color3.fromRGB(205, 205, 205),
    Dim = Color3.fromRGB(115, 115, 115),
}
local accentFns = {}
local function onAccent(fn)
    accentFns[#accentFns + 1] = fn
    fn(T.Accent)
end
local function setAccent(name)
    local a = ACCENTS[name] or ACCENTS.Skeet
    T.Accent = a.main
    T.Grad = ColorSequence.new({ColorSequenceKeypoint.new(0, a.g[1]), ColorSequenceKeypoint.new(0.5, a.g[2]), ColorSequenceKeypoint.new(1, a.g[3])})
    for _, f in ipairs(accentFns) do pcall(f, a.main) end
end

local function stroke(o, c, th, tr) return new("UIStroke", {Color = c, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o) end
local function pad(o, t, r, b, l)
    return new("UIPadding", {PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b), PaddingLeft = UDim.new(0, l)}, o)
end
local function hex(c)
    return string.format("#%02x%02x%02x", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function makeGui(name, order)
    local g = Instance.new("ScreenGui")
    g.Name = name
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    g.DisplayOrder = order
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local ok = false
    if gethui then
        local s, h = pcall(gethui)
        if s and h then g.Parent = h ok = true end
    end
    if not ok then ok = pcall(function() g.Parent = CoreGui end) end
    if not ok or not g.Parent then g.Parent = LP:WaitForChild("PlayerGui") end
    return g
end

local Gui = makeGui("sakura.bypass", 900)
local EspGui = makeGui("sakura.bypass.esp", 5)

local hasDrawing = pcall(function()
    local l = Drawing.new("Line")
    l:Remove()
end)

local function newLine()
    if hasDrawing then
        local l = Drawing.new("Line")
        l.Visible = false
        l.ZIndex = 2
        return {
            set = function(a, b, c, th) l.From = a l.To = b l.Color = c l.Thickness = th l.Visible = true end,
            hide = function() l.Visible = false end,
            kill = function() pcall(function() l:Remove() end) end,
        }
    end
    local f = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Visible = false}, EspGui)
    return {
        set = function(a, b, c, th)
            local d = b - a
            f.Size = UDim2.fromOffset(d.Magnitude + 1, th)
            f.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
            f.Rotation = math.deg(math.atan2(d.Y, d.X))
            f.BackgroundColor3 = c
            f.Visible = true
        end,
        hide = function() f.Visible = false end,
        kill = function() f:Destroy() end,
    }
end

local function newText()
    if hasDrawing then
        local t = Drawing.new("Text")
        t.Visible = false
        t.Size = 13
        t.Center = true
        t.Outline = true
        t.ZIndex = 3
        return {
            set = function(str, pos, c) t.Text = str t.Position = pos t.Color = c t.Visible = true end,
            hide = function() t.Visible = false end,
            kill = function() pcall(function() t:Remove() end) end,
        }
    end
    local l = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Size = UDim2.fromOffset(200, 14), TextSize = 12,
        Font = Enum.Font.GothamMedium, TextStrokeTransparency = 0, Visible = false,
    }, EspGui)
    return {
        set = function(str, pos, c) l.Text = str l.Position = UDim2.fromOffset(pos.X, pos.Y) l.TextColor3 = c l.Visible = true end,
        hide = function() l.Visible = false end,
        kill = function() l:Destroy() end,
    }
end



local Errors = {}
local function guard(name, fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then Errors[name] = tostring(err) end
    end
end

local HBList = {}
local hbTicks = 0
local function onHB(name, fn) HBList[#HBList + 1] = guard(name, fn) end
conn(RunService.Heartbeat, function(dt)
    hbTicks = hbTicks + 1
    for _, f in ipairs(HBList) do f(dt) end
end)

conn(RunService.RenderStepped, function()
    local c = Workspace.CurrentCamera
    if c and c ~= Camera then Camera = c end
end)

local function hasRoot(m)
    return m ~= nil and m.Parent ~= nil and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart) ~= nil
end
local function myChar() return LP.Character end

local extraList, extraAt = {}, 0
local function scanExtras(me)
    local now = os.clock()
    if now - extraAt < 1 then return end
    extraAt = now
    local list = {}
    local function consider(m)
        if m:IsA("Model") and m ~= me and m.Name ~= "ViewModel" and m.Name ~= LP.Name and m:FindFirstChildOfClass("Humanoid") then
            local owner = nil
            pcall(function() owner = Players:GetPlayerFromCharacter(m) end)
            if not owner then list[#list + 1] = m end
        end
    end
    for _, m in ipairs(Workspace:GetChildren()) do
        if m:IsA("Model") then
            consider(m)
        elseif m:IsA("Folder") then
            for _, m2 in ipairs(m:GetChildren()) do
                if m2:IsA("Model") then consider(m2) end
            end
        end
    end
    extraList = list
end

local function collect(npc)
    local out, seen = {}, {}
    local me = myChar()
    for _, plr in ipairs(Players:GetPlayers()) do
        local c = plr.Character
        if plr ~= LP and c and c ~= me and c.Parent then
            out[#out + 1] = {char = c, plr = plr}
            seen[c] = true
        end
    end
    if npc then
        scanExtras(me)
        for _, m in ipairs(extraList) do
            if m.Parent and not seen[m] and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart) then
                out[#out + 1] = {char = m, plr = nil}
                seen[m] = true
            end
        end
    end
    local f = Workspace:FindFirstChild("Characters")
    if f then
        local function add(m)
            if m:IsA("Model") and m ~= me and not seen[m] and m.Name ~= LP.Name and m:FindFirstChild("HumanoidRootPart") then
                local p = nil
                pcall(function() p = Players:GetPlayerFromCharacter(m) end)
                out[#out + 1] = {char = m, plr = p}
                seen[m] = true
            end
        end
        for _, m in ipairs(f:GetChildren()) do
            if m:IsA("Folder") then
                for _, m2 in ipairs(m:GetChildren()) do add(m2) end
            else
                add(m)
            end
        end
    end
    return out
end

local teamMixAt, teamMixed = 0, true
local function teamsMixed()
    local now = os.clock()
    if now - teamMixAt > 1 then
        teamMixAt = now
        teamMixed = false
        local first = nil
        for _, p in ipairs(Players:GetPlayers()) do
            local t = p.Team or false
            if first == nil then
                first = t
            elseif t ~= first then
                teamMixed = true
                break
            end
        end
    end
    return teamMixed
end

local function neutralTeam(t)
    if not t then return true end
    local n = string.lower(t.Name)
    return string.find(n, "lobby", 1, true) or string.find(n, "spectat", 1, true) or string.find(n, "neutral", 1, true)
        or string.find(n, "wait", 1, true) or string.find(n, "none", 1, true) or string.find(n, "dead", 1, true)
end



local collectRaw = collect
local collectCache = {}
collect = function(npc)
    local now = os.clock()
    local idx = npc and 1 or 2
    local c = collectCache[idx]
    if c and now - c.t < 0.2 then return c.list end
    local list = collectRaw(npc)
    collectCache[idx] = {t = now, list = list}
    return list
end

local TEAM_ATTRS = {"Team", "TeamId", "TeamID", "TeamName"}
local function isAlly(plr, char)
    if not plr or plr == LP then return false end
    for _, a in ipairs(TEAM_ATTRS) do
        local mv, pv = LP:GetAttribute(a), plr:GetAttribute(a)
        if mv ~= nil and pv ~= nil then return mv == pv end
    end
    if not teamsMixed() then return false end
    local mt, pt = LP.Team, plr.Team
    if neutralTeam(mt) or neutralTeam(pt) then return false end
    return mt == pt
end

local function alive(char)
    if char:GetAttribute("Dead") then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health > 0 end
    local hp = char:GetAttribute("Health")
    if hp ~= nil then return hp > 0 end
    return true
end

local function baseIgnore(me)
    local l = {me, Camera}
    local vm = Workspace:FindFirstChild("ViewModel")
    if vm then l[#l + 1] = vm end
    return l
end

local function aimDir(ref)
    local r = Camera:ViewportPointToRay(ref.X, ref.Y)
    return r.Direction.Unit
end

local function healthOf(char)
    local hp = char:GetAttribute("Health")
    local mx = char:GetAttribute("MaxHealth")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hp == nil and hum then hp = hum.Health end
    if mx == nil then mx = hum and hum.MaxHealth or 100 end
    if mx <= 0 then mx = 100 end
    return hp or 100, mx
end




local function aimRef()
    local vs = Camera.ViewportSize
    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then return vs / 2 end
    local ml = UserInputService:GetMouseLocation()
    if ml.X < 0 or ml.Y < 0 or ml.X > vs.X or ml.Y > vs.Y then return vs / 2 end
    return ml
end

local rayP = RaycastParams.new()
rayP.FilterType = Enum.RaycastFilterType.Exclude
rayP.IgnoreWater = true
pcall(function() rayP.RespectCanCollide = true end)

local function shotOrigin() return Camera.CFrame.Position end

local function cast(origin, dir, char, ignore)
    local list = {}
    for i = 1, #ignore do list[i] = ignore[i] end
    for _ = 1, 10 do
        rayP.FilterDescendantsInstances = list
        local res = Workspace:Raycast(origin, dir, rayP)
        if not res then return nil, nil end
        local inst = res.Instance
        if char and inst:IsDescendantOf(char) then return true, inst end
        if inst.Transparency >= 0.9 or not inst.CanCollide then
            list[#list + 1] = inst
        else
            return false, inst
        end
    end
    return false, nil
end

local function rayHit(origin, dir, maxDist, char, ignore)
    local ok, inst = cast(origin, dir * maxDist, char, ignore)
    return ok == true, maxDist, inst
end

local function canHit(part, char, ignore)
    local origin = shotOrigin()
    local off = part.Position - origin
    local dist = off.Magnitude
    if dist < 0.1 then return true end
    local ok = cast(origin, off.Unit * (dist + 2), char, ignore)
    return ok == nil or ok == true
end



local SKEL = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

local espEntries = {}

local function makeEntry()
    local e = {box = {}, skel = {}}
    for i = 1, 8 do e.box[i] = newLine() end
    e.hpBg = newLine()
    e.hpFill = newLine()
    e.tracer = newLine()
    for i = 1, #SKEL do e.skel[i] = newLine() end
    e.name = newText()
    e.info = newText()
    e.fill = new("Frame", {BorderSizePixel = 0, Visible = false, BackgroundTransparency = 0.85}, EspGui)
    return e
end

local function hideEntry(e)
    for _, l in ipairs(e.box) do l.hide() end
    for _, l in ipairs(e.skel) do l.hide() end
    e.hpBg.hide()
    e.hpFill.hide()
    e.tracer.hide()
    e.name.hide()
    e.info.hide()
    e.fill.Visible = false
    if e.hl then e.hl.Enabled = false end
end

local function killEntry(e)
    for _, l in ipairs(e.box) do l.kill() end
    for _, l in ipairs(e.skel) do l.kill() end
    e.hpBg.kill()
    e.hpFill.kill()
    e.tracer.kill()
    e.name.kill()
    e.info.kill()
    pcall(function() e.fill:Destroy() end)
    if e.hl then pcall(function() e.hl:Destroy() end) end
end

local function updateEntry(e, plr, char)
    local E = S.ESP
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    local head = char and char:FindFirstChild("Head")
    if not (char and hrp and char.Parent and alive(char)) then hideEntry(e) return end
    if E.TeamCheck then
        local t = os.clock()
        if not e.allyAt or t - e.allyAt > 0.5 then
            e.allyAt = t
            e.ally = isAlly(plr, char)
        end
        if e.ally then hideEntry(e) return end
    end
    local camPos = Camera.CFrame.Position
    local dist = (hrp.Position - camPos).Magnitude
    if dist > E.MaxDist then hideEntry(e) return end
    local col = ESP_COLORS[E.Color] or T.Accent
    if E.Chams then
        if not e.hl then
            local h = Instance.new("Highlight")
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillTransparency = 0.55
            h.OutlineTransparency = 0
            h.OutlineColor = Color3.new(1, 1, 1)
            h.Adornee = char
            h.Parent = EspGui
            e.hl = h
        end
        e.hl.Adornee = char
        e.hl.FillColor = col
        e.hl.Enabled = true
    elseif e.hl then
        e.hl.Enabled = false
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local topY = head and (head.Position.Y + head.Size.Y / 2 + 0.15) or (hrp.Position.Y + 2.7)
    local drop = 3
    if hum and hum.RigType == Enum.HumanoidRigType.R15 then drop = hum.HipHeight + hrp.Size.Y / 2 end
    local top = Camera:WorldToViewportPoint(Vector3.new(hrp.Position.X, topY, hrp.Position.Z))
    local bot = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, drop, 0))
    if top.Z <= 0 or bot.Z <= 0 then
        for _, l in ipairs(e.box) do l.hide() end
        for _, l in ipairs(e.skel) do l.hide() end
        e.hpBg.hide() e.hpFill.hide() e.tracer.hide() e.name.hide() e.info.hide()
        e.fill.Visible = false
        return
    end
    local h = bot.Y - top.Y
    if h < 4 then
        for _, l in ipairs(e.box) do l.hide() end
        e.fill.Visible = false
        return
    end
    local w = h * 0.55
    local x = (top.X + bot.X) / 2
    local x1, x2, y1, y2 = x - w / 2, x + w / 2, top.Y, bot.Y
    if E.Box then
        local tl, tr, bl, br = Vector2.new(x1, y1), Vector2.new(x2, y1), Vector2.new(x1, y2), Vector2.new(x2, y2)
        if E.BoxStyle == "Corner" then
            local cw, ch = w * 0.28, h * 0.2
            e.box[1].set(tl, tl + Vector2.new(cw, 0), col, 1.5)
            e.box[2].set(tl, tl + Vector2.new(0, ch), col, 1.5)
            e.box[3].set(tr, tr - Vector2.new(cw, 0), col, 1.5)
            e.box[4].set(tr, tr + Vector2.new(0, ch), col, 1.5)
            e.box[5].set(bl, bl + Vector2.new(cw, 0), col, 1.5)
            e.box[6].set(bl, bl - Vector2.new(0, ch), col, 1.5)
            e.box[7].set(br, br - Vector2.new(cw, 0), col, 1.5)
            e.box[8].set(br, br - Vector2.new(0, ch), col, 1.5)
        else
            e.box[1].set(tl, tr, col, 1.5)
            e.box[2].set(tr, br, col, 1.5)
            e.box[3].set(br, bl, col, 1.5)
            e.box[4].set(bl, tl, col, 1.5)
            for i = 5, 8 do e.box[i].hide() end
        end
    else
        for _, l in ipairs(e.box) do l.hide() end
    end
    if E.Filled then
        e.fill.Position = UDim2.fromOffset(x1, y1)
        e.fill.Size = UDim2.fromOffset(w, h)
        e.fill.BackgroundColor3 = col
        e.fill.Visible = true
    else
        e.fill.Visible = false
    end
    local hp, mx = healthOf(char)
    if E.Health then
        local frac = math.clamp(hp / mx, 0, 1)
        local bx = x1 - 5
        e.hpBg.set(Vector2.new(bx, y2 + 1), Vector2.new(bx, y1 - 1), Color3.new(0, 0, 0), 4)
        e.hpFill.set(Vector2.new(bx, y2), Vector2.new(bx, y2 - h * frac), Color3.fromRGB(255, 60, 60):Lerp(Color3.fromRGB(80, 255, 110), frac), 2)
    else
        e.hpBg.hide()
        e.hpFill.hide()
    end
    if E.Tracers then
        local vs = Camera.ViewportSize
        local from = E.TracerFrom == "Center" and Vector2.new(vs.X / 2, vs.Y / 2) or (E.TracerFrom == "Top" and Vector2.new(vs.X / 2, 0) or Vector2.new(vs.X / 2, vs.Y))
        e.tracer.set(from, Vector2.new(x, y2), col, 1)
    else
        e.tracer.hide()
    end
    if E.Skeleton and dist < 300 then
        for i, pair in ipairs(SKEL) do
            local a, b = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
            if a and b then
                local pa, pb = Camera:WorldToViewportPoint(a.Position), Camera:WorldToViewportPoint(b.Position)
                if pa.Z > 0 and pb.Z > 0 then
                    e.skel[i].set(Vector2.new(pa.X, pa.Y), Vector2.new(pb.X, pb.Y), Color3.new(1, 1, 1), 1)
                else
                    e.skel[i].hide()
                end
            else
                e.skel[i].hide()
            end
        end
    else
        for _, l in ipairs(e.skel) do l.hide() end
    end
    if E.Name then e.name.set(plr and plr.DisplayName or ("[NPC] " .. char.Name), Vector2.new(x, y1 - 16), Color3.new(1, 1, 1)) else e.name.hide() end
    if E.Info then
        e.info.set(string.format("%d hp  |  %dm", math.floor(hp + 0.5), math.floor(dist / 3.5)), Vector2.new(x, y2 + 2), col)
    else
        e.info.hide()
    end
    return true
end

local espStat = {n = 0, shown = 0, rebuilt = 0}
local espLast = os.clock()

local espHidden = false
conn(RunService.RenderStepped, guard("esp", function()
    if not S.ESP.Enabled or not Camera then
        if not espHidden then
            for _, e in pairs(espEntries) do hideEntry(e) end
            espHidden = true
        end
        return
    end
    espHidden = false
    local nowT = os.clock()
    if S.ESP.AutoRefresh and nowT - espLast >= S.ESP.Interval then
        espLast = nowT
        espStat.rebuilt = espStat.rebuilt + 1
        for char, e in pairs(espEntries) do
            pcall(killEntry, e)
            espEntries[char] = nil
        end
    end
    local used = {}
    local list = collect(S.ESP.Npc)
    local shown = 0
    for _, item in ipairs(list) do
        local char = item.char
        used[char] = true
        local e = espEntries[char]
        if not e then
            e = makeEntry()
            espEntries[char] = e
        end
        local ok, res = pcall(updateEntry, e, item.plr, char)
        if not ok then
            hideEntry(e)
            Errors.esp = tostring(res)
        elseif res then
            shown = shown + 1
        end
    end
    espStat.n, espStat.shown = #list, shown
    for char, e in pairs(espEntries) do
        if not used[char] then
            killEntry(e)
            espEntries[char] = nil
        end
    end
end))

local espRefreshPending = false
local function refreshEsp()
    if espRefreshPending then return end
    espRefreshPending = true
    task.delay(1, function()
        espRefreshPending = false
        for char, e in pairs(espEntries) do
            pcall(killEntry, e)
            espEntries[char] = nil
        end
        espLast = os.clock()
    end)
end

do
    local watched = setmetatable({}, {__mode = "k"})
    local function watchChar(char)
        if watched[char] then return end
        watched[char] = true
        task.spawn(function()
            local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 10)
            if hum then conn(hum.Died, refreshEsp) end
        end)
    end
    local function track(plr)
        conn(plr.CharacterAdded, function(c) refreshEsp() watchChar(c) end)
        conn(plr.CharacterRemoving, refreshEsp)
        conn(plr:GetPropertyChangedSignal("Team"), refreshEsp)
        if plr.Character then watchChar(plr.Character) end
    end
    for _, p in ipairs(Players:GetPlayers()) do track(p) end
    conn(Players.PlayerAdded, function(p) refreshEsp() track(p) end)
    conn(Players.PlayerRemoving, refreshEsp)
    local function folder(f)
        conn(f.ChildAdded, refreshEsp)
        conn(f.ChildRemoved, refreshEsp)
    end
    local f = Workspace:FindFirstChild("Characters")
    if f then folder(f) end
    conn(Workspace.ChildAdded, function(c)
        if c.Name == "Characters" then folder(c) refreshEsp() end
    end)
end



local aimStat = {silent = 0, mouse = 0, target = "-", active = false, shots = 0, fireErr = nil}
do
    local A = S.Aim
    local lmb, rmb, rolled = false, false, true
    local realCF = nil

    local lastMove, lastDelta, acc = 0, Vector2.zero, Vector2.zero
    conn(UserInputService.InputChanged, function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d = Vector2.new(i.Delta.X, i.Delta.Y)
            if d.Magnitude > 0.5 then lastMove, lastDelta = os.clock(), d end
        end
    end)

    local function effFov() return A.Mode == "Aim assist" and A.AssistFov or A.Fov end

    conn(UserInputService.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            lmb = true
            rolled = math.random(1, 100) <= A.HitChance
        elseif i.UserInputType == Enum.UserInputType.MouseButton2 then
            rmb = true
        end
    end)
    conn(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then lmb = false
        elseif i.UserInputType == Enum.UserInputType.MouseButton2 then rmb = false end
    end)

    local lastShot = 0
    local function fireShot(part)
        local now = os.clock()
        if now - lastShot < A.ShotDelay / 1000 then return end
        if type(mouse1click) ~= "function" then aimStat.fireErr = "нет mouse1click в экзекуторе" return end
        local me = myChar()
        if not me or not part.Parent then return end
        if not canHit(part, part.Parent, baseIgnore(me)) then return end
        lastShot = now
        pcall(mouse1click)
        aimStat.shots = aimStat.shots + 1
    end

    local function active()
        if A.AutoShot and A.Mode ~= "Aim assist" then return true end
        local a = A.Activation
        if a == "Always" then return true end
        if a == "Hold RMB" then return rmb end
        if A.Mode == "Silent" then return lmb and rolled end
        return lmb
    end

    local function pickPart(char)
        local p = A.Part
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        if p == "Head" then return head or torso end
        if p == "Torso" then return torso or head end
        if head and torso then return math.random(1, 2) == 1 and head or torso end
        return head or torso
    end

    local cache, cacheAt = nil, 0
    local function findTarget()
        local now = os.clock()
        if cache and now - cacheAt < 0.08 and cache.Parent then return cache end
        local me = myChar()
        if not (me and Camera) then return nil end
        local ref = aimRef()
        local fov = effFov()
        local needVis = A.VisCheck or A.Mode == "Aim assist"
        local ignore = baseIgnore(me)
        local origin = Camera.CFrame.Position
        local bestPart, bestChar, bestScore = nil, nil, math.huge
        for _, item in ipairs(collect(false)) do
            local char, plr = item.char, item.plr
            if char.Parent and alive(char) and not (A.TeamCheck and isAlly(plr, char)) then
                local part = pickPart(char)
                if part and (part.Position - origin).Magnitude <= A.MaxDist then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local sd = (Vector2.new(sp.X, sp.Y) - ref).Magnitude
                        if sd <= fov and sd < bestScore then
                            if not needVis or canHit(part, char, ignore) then
                                bestPart, bestChar, bestScore = part, char, sd
                            end
                        end
                    end
                end
            end
        end
        cache, cacheAt = bestPart, now
        if bestChar then aimStat.target = bestChar.Name end
        return bestPart
    end

    onHB("aim_silent", function()
        if not (A.Enabled and A.Mode == "Silent" and Camera and Alive) or State.MenuOpen then aimStat.active = false return end
        if not active() then aimStat.active = false return end
        local part = findTarget()
        aimStat.active = part ~= nil
        if not part then return end
        local cf = Camera.CFrame
        if not realCF then realCF = cf end
        Camera.CFrame = CFrame.lookAt(cf.Position, part.Position)
        aimStat.silent = aimStat.silent + 1
        if A.AutoShot then fireShot(part) end
    end)

    RunService:BindToRenderStep("SakuraRivalsSilentRestore", Enum.RenderPriority.First.Value, function()
        if realCF then
            if Camera then Camera.CFrame = realCF end
            realCF = nil
        end
    end)

    conn(RunService.RenderStepped, guard("aim_mouse", function()
        if not (A.Enabled and A.Mode == "Aimbot" and Camera) or State.MenuOpen then aimStat.active = false return end
        if not active() then aimStat.active = false return end
        local part = findTarget()
        aimStat.active = part ~= nil
        if not part then return end
        local sp = Camera:WorldToViewportPoint(part.Position)
        local d = Vector2.new(sp.X, sp.Y) - aimRef()
        if A.AutoShot and d.Magnitude <= math.max(14, A.Deadzone * 3) then fireShot(part) end
        if d.Magnitude < A.Deadzone then return end
        local step = d / math.max(A.Smooth, 1) * A.Gain
        if step.Magnitude > 90 then step = step.Unit * 90 end
        if type(mousemoverel) == "function" then
            mousemoverel(step.X, step.Y)
        else
            local cf = Camera.CFrame
            Camera.CFrame = cf:Lerp(CFrame.lookAt(cf.Position, part.Position), 1 / math.max(A.Smooth, 1))
        end
        aimStat.mouse = aimStat.mouse + 1
    end))

    conn(RunService.RenderStepped, guard("aim_assist", function(dt)
        if not (A.Enabled and A.Mode == "Aim assist" and Camera) or State.MenuOpen then return end
        if not active() then aimStat.active = false return end
        if A.AssistNeedMove and os.clock() - lastMove > 0.15 then return end
        local part = findTarget()
        aimStat.active = part ~= nil
        if not part then return end
        local sp = Camera:WorldToViewportPoint(part.Position)
        local d = Vector2.new(sp.X, sp.Y) - aimRef()
        local dist = d.Magnitude
        if dist < 3 then return end
        local fov = A.AssistFov
        local falloff = 1 - 0.6 * math.min(dist / fov, 1)
        local k = (A.AssistStrength / 100) * falloff * math.clamp(dt * 60, 0.25, 3)
        local step = d * k
        if lastDelta.Magnitude > 0 and lastDelta:Dot(d) < 0 then step = step * 0.25 end
        if step.Magnitude > A.AssistMaxStep then step = step.Unit * A.AssistMaxStep end
        step = step + Vector2.new((math.random() - 0.5) * 0.5, (math.random() - 0.5) * 0.5)
        if type(mousemoverel) == "function" then
            acc = acc + step
            local ox = acc.X >= 0 and math.floor(acc.X) or math.ceil(acc.X)
            local oy = acc.Y >= 0 and math.floor(acc.Y) or math.ceil(acc.Y)
            if ox ~= 0 or oy ~= 0 then
                acc = acc - Vector2.new(ox, oy)
                mousemoverel(ox, oy)
            end
        else
            local cf = Camera.CFrame
            Camera.CFrame = cf:Lerp(CFrame.lookAt(cf.Position, part.Position), math.clamp(k, 0, 0.2))
        end
        aimStat.mouse = aimStat.mouse + 1
    end))

    Unloaders[#Unloaders + 1] = function()
        pcall(function() RunService:UnbindFromRenderStep("SakuraRivalsSilentRestore") end)
        if realCF and Camera then pcall(function() Camera.CFrame = realCF end) end
    end

    local circle = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Visible = false, Size = UDim2.fromOffset(100, 100)}, EspGui)
    new("UICorner", {CornerRadius = UDim.new(1, 0)}, circle)
    local cst = stroke(circle, T.Accent, 1, 0.2)
    onAccent(function(c) cst.Color = c end)
    local cx, cy, csz = nil, nil, nil
    conn(RunService.RenderStepped, guard("fov", function()
        if A.Enabled and A.ShowFov and Camera then
            local ref = aimRef()
            local x, y, sz = math.floor(ref.X), math.floor(ref.Y), effFov() * 2
            if x ~= cx or y ~= cy then cx, cy = x, y circle.Position = UDim2.fromOffset(x, y) end
            if sz ~= csz then csz = sz circle.Size = UDim2.fromOffset(sz, sz) end
            if not circle.Visible then circle.Visible = true end
        elseif circle.Visible then
            circle.Visible = false
        end
    end))
end


local weaponInfo = "выключено"
local weaponDump = {}
local runWeaponScan = function() end
local weaponRestore = function() end
do
    local Wp = S.Weapon
    local GUN_KEYS = {"Recoil", "Spread", "Ammo", "Reload", "FireRate", "Damage", "Range", "MaxAmmo", "Magazine", "Shoot", "Fire", "Bullet"}
    local count = {recoil = 0, spread = 0}
    local cands, busy, lastScan, pending = 0, false, 0, false
    local seen = setmetatable({}, {__mode = "k"})

    local function isRecoil(k)
        if type(k) ~= "string" then return false end
        local l = string.lower(k)
        return string.find(l, "recoil", 1, true) ~= nil or string.find(l, "kick", 1, true) ~= nil
    end
    local function isSpread(k)
        if type(k) ~= "string" then return false end
        local l = string.lower(k)
        return string.find(l, "spread", 1, true) ~= nil or string.find(l, "inaccuracy", 1, true) ~= nil
    end

    local function reg(holder, key, kind, isAttr)
        for _, d in ipairs(weaponDump) do
            if d.holder == holder and d.key == key and d.attr == isAttr then return end
        end
        local cur
        if isAttr then cur = holder:GetAttribute(key) else cur = rawget(holder, key) end
        if type(cur) == "number" then
            weaponDump[#weaponDump + 1] = {holder = holder, key = key, kind = kind, orig = cur, attr = isAttr}
            count[kind] = count[kind] + 1
        elseif type(cur) == "table" and not isAttr then
            for k, v in pairs(cur) do
                if type(v) == "number" then
                    weaponDump[#weaponDump + 1] = {holder = cur, key = k, kind = kind, orig = v, attr = false}
                    count[kind] = count[kind] + 1
                end
            end
        elseif typeof(cur) == "Vector3" or typeof(cur) == "Vector2" then
            weaponDump[#weaponDump + 1] = {holder = holder, key = key, kind = kind, orig = cur, attr = isAttr}
            count[kind] = count[kind] + 1
        end
    end

    local function scanTable(t)
        if seen[t] then return end
        seen[t] = true
        local gun = 0
        local exact = rawget(t, "ShootRecoil") ~= nil or rawget(t, "ShootSpread") ~= nil
        if not exact then
            local n = 0
            for k in next, t do
                n = n + 1
                if n > 80 then break end
                if type(k) == "string" then
                    for _, g in ipairs(GUN_KEYS) do
                        if string.find(k, g, 1, true) then gun = gun + 1 break end
                    end
                    if gun >= 3 then break end
                end
            end
        end
        if gun >= 3 or exact then
            cands = cands + 1
            for k in next, t do
                if isRecoil(k) then reg(t, k, "recoil", false)
                elseif isSpread(k) then reg(t, k, "spread", false) end
            end
        end
    end

    local function scanInstance(root)
        local list = root:GetDescendants()
        list[#list + 1] = root
        for _, o in ipairs(list) do
            if o:IsA("ValueBase") then
                local v = o.Value
                if type(v) == "number" then
                    if isRecoil(o.Name) then
                        weaponDump[#weaponDump + 1] = {holder = o, key = "Value", kind = "recoil", orig = v, obj = true}
                        count.recoil = count.recoil + 1
                    elseif isSpread(o.Name) then
                        weaponDump[#weaponDump + 1] = {holder = o, key = "Value", kind = "spread", orig = v, obj = true}
                        count.spread = count.spread + 1
                    end
                end
            end
            local attrs = o:GetAttributes()
            for k, v in pairs(attrs) do
                if type(v) == "number" then
                    if isRecoil(k) then reg(o, k, "recoil", true)
                    elseif isSpread(k) then reg(o, k, "spread", true) end
                end
            end
        end
    end

    local function scaled(v, m)
        if type(v) == "number" then return v * m end
        local t = typeof(v)
        if t == "Vector3" or t == "Vector2" then return v * m end
        return nil
    end

    local function wanted(d)
        if not Wp.Enabled then return d.orig end
        if d.kind == "recoil" then
            if not Wp.Recoil then return d.orig end
            return scaled(d.orig, 1 - Wp.RecoilPct / 100)
        end
        if not Wp.Spread then return d.orig end
        return scaled(d.orig, 1 - Wp.SpreadPct / 100)
    end

    local function write(d, v)
        if v == nil then return end
        pcall(function()
            if d.obj then d.holder.Value = v
            elseif d.attr then d.holder:SetAttribute(d.key, v)
            else d.holder[d.key] = v end
        end)
    end

    local function apply()
        for _, d in ipairs(weaponDump) do write(d, wanted(d)) end
    end

    weaponRestore = function()
        for _, d in ipairs(weaponDump) do write(d, d.orig) end
    end

    local function refreshInfo()
        if not Wp.Enabled then weaponInfo = "выключено" return end
        weaponInfo = string.format("отдача: %d | разброс: %d | таблиц оружия: %d", count.recoil, count.spread, cands)
        if count.recoil + count.spread == 0 then weaponInfo = weaponInfo .. " — ничего не найдено, смени оружие" end
    end

    runWeaponScan = function()
        if busy or not Wp.Enabled then return end
        busy = true
        lastScan = os.clock()
        weaponInfo = "сканирую..."
        task.spawn(function()
            local ok, err = pcall(function()
                weaponRestore()
                weaponDump = {}
                count = {recoil = 0, spread = 0}
                cands = 0
                seen = setmetatable({}, {__mode = "k"})
                if LP.Character then scanInstance(LP.Character) end
                local vm = Workspace:FindFirstChild("ViewModel")
                if vm then scanInstance(vm) end
                task.wait()
                local budget = 40000
                local seenW = {}
                local function walk(t, depth)
                    if budget <= 0 or depth > 6 or seenW[t] then return end
                    seenW[t] = true
                    budget = budget - 1
                    pcall(scanTable, t)
                    if budget % 400 == 0 then task.wait() end
                    for _, v in next, t do
                        if type(v) == "table" then walk(v, depth + 1) end
                    end
                end
                local mods = ReplicatedStorage:FindFirstChild("Modules")
                if mods then
                    for _, m in ipairs(mods:GetDescendants()) do
                        if m:IsA("ModuleScript") then
                            local n = string.lower(m.Name)
                            if string.find(n, "itemlibrary", 1, true) or string.find(n, "weapon", 1, true) or string.find(n, "gun", 1, true) then
                                local ok2, res = pcall(require, m)
                                if ok2 and type(res) == "table" then pcall(walk, res, 0) end
                            end
                        end
                    end
                end
                task.wait()
                if Wp.Deep and type(getgc) == "function" then
                    local okgc, gc = pcall(getgc, true)
                    if okgc and type(gc) == "table" then
                        for i = 1, #gc do
                            local t = gc[i]
                            if type(t) == "table" then pcall(scanTable, t) end
                            if i % 700 == 0 then task.wait() end
                        end
                    end
                end
                apply()
            end)
            busy = false
            if not ok then Errors.weapon = tostring(err) end
            refreshInfo()
        end)
    end

    local function schedule()
        if pending or not Wp.Enabled or busy then return end
        if os.clock() - lastScan < 2 then return end
        pending = true
        task.delay(0.6, function()
            pending = false
            runWeaponScan()
        end)
    end

    local slots = {}
    for _, k in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine, Enum.KeyCode.Q}) do slots[k] = true end
    conn(UserInputService.InputBegan, function(i, gp)
        if gp then return end
        if (i.UserInputType == Enum.UserInputType.Keyboard and slots[i.KeyCode]) or i.UserInputType == Enum.UserInputType.MouseWheel then schedule() end
    end)
    conn(LP.CharacterAdded, function() task.delay(1.5, schedule) end)

    local nextApply = 0
    onHB("weapon", function()
        if not Wp.Enabled then return end
        local now = os.clock()
        if Wp.Rescan > 0 and now - lastScan >= Wp.Rescan then schedule() end
        if now >= nextApply then
            nextApply = now + 1
            apply()
        end
    end)

    Unloaders[#Unloaders + 1] = weaponRestore
    S.Weapon.Toggled = function(on)
        if on then runWeaponScan() else weaponRestore() refreshInfo() end
    end
    S.Weapon.Refresh = refreshInfo
end

local devStat = {sent = 0, last = "-", err = nil, remote = "не найден"}
local sendDevice = function() return false end
local realDevice = function() return "MouseKeyboard" end
do
    local D = S.Device
    local remote = nil
    local lastFind = 0
    local function findRemote()
        if remote and remote.Parent then return remote end
        if os.clock() - lastFind < 3 then return nil end
        lastFind = os.clock()
        local ok, r = pcall(function() return ReplicatedStorage.Remotes.Replication.Fighter.SetControls end)
        if ok and r then remote = r devStat.remote = r:GetFullName() return r end
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            if d.Name == "SetControls" and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
                remote = d
                devStat.remote = d:GetFullName()
                return d
            end
        end
        return nil
    end

    realDevice = function()
        local u = UserInputService
        if u.TouchEnabled and not u.KeyboardEnabled and not u.MouseEnabled then return "Touch" end
        if u.GamepadEnabled and not u.KeyboardEnabled then return "Gamepad" end
        return "MouseKeyboard"
    end

    sendDevice = function(mode)
        local r = findRemote()
        if not r then devStat.err = "ремоут SetControls не найден" return false end
        local ok, err = pcall(function()
            if r:IsA("RemoteFunction") then r:InvokeServer(mode) else r:FireServer(mode) end
        end)
        if ok then
            devStat.sent = devStat.sent + 1
            devStat.last = mode
            devStat.err = nil
        else
            devStat.err = tostring(err)
        end
        return ok
    end

    local nextSend = 0
    onHB("device", function()
        if D.Mode == "Auto" then return end
        local now = os.clock()
        if now >= nextSend then
            nextSend = now + D.Interval
            sendDevice(D.Mode)
        end
    end)
    conn(UserInputService.LastInputTypeChanged, function()
        if D.Mode == "Auto" then return end
        task.delay(0.25, function() if D.Mode ~= "Auto" then sendDevice(D.Mode) end end)
    end)
    conn(LP.CharacterAdded, function()
        task.delay(1.5, function() if D.Mode ~= "Auto" then sendDevice(D.Mode) end end)
    end)
    Unloaders[#Unloaders + 1] = function()
        if D.Mode ~= "Auto" then sendDevice(realDevice()) end
    end
end

local function gradLine(parent, h)
    local f = new("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 5}, parent)
    local g = new("UIGradient", {Color = T.Grad}, f)
    onAccent(function() g.Color = T.Grad end)
    return f
end

local function shade(o)
    return new("UIGradient", {Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(165, 165, 165))}, o)
end

local function tween(o, t, props)
    TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local NotifyBox = new("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 50), Size = UDim2.fromOffset(320, 400), ZIndex = 40}, Gui)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, NotifyBox)
local notifyN = 0
local function notify(text)
    if not S.UI.Notify then return end
    notifyN = notifyN + 1
    local f = new("Frame", {Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = T.Dark, BorderSizePixel = 0, LayoutOrder = notifyN, ZIndex = 40}, NotifyBox)
    stroke(f, T.Line, 1)
    new("Frame", {Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 41}, f)
    local l = new("TextLabel", {AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = T.Text, Font = FONT, TextSize = 14, ZIndex = 41}, f)
    pad(l, 0, 10, 0, 10)
    task.delay(2.8, function()
        pcall(function()
            tween(l, 0.3, {TextTransparency = 1})
            tween(f, 0.3, {BackgroundTransparency = 1})
            task.wait(0.35)
            f:Destroy()
        end)
    end)
end

local W, H = 640, 480
local Main = new("Frame", {Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(W, H), BackgroundColor3 = T.Dark, BorderSizePixel = 0, Visible = false, Active = true}, Gui)
stroke(Main, BLACK, 1)
local Scale = new("UIScale", {Scale = 1}, Main)
local function fit()
    local vs = Gui.AbsoluteSize
    if vs.X < 50 then vs = Camera.ViewportSize end
    Scale.Scale = math.clamp(math.min((vs.X - 16) / W, (vs.Y - 16) / H), 0.4, 1)
end
fit()
conn(Gui:GetPropertyChangedSignal("AbsoluteSize"), fit)

local Body = new("Frame", {Position = UDim2.fromOffset(3, 3), Size = UDim2.new(1, -6, 1, -6), BackgroundColor3 = T.Bg, BorderSizePixel = 0}, Main)
stroke(Body, T.Line, 1)
gradLine(Body, 2)

local Drag = new("Frame", {Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(0, 2), BackgroundTransparency = 1, Active = true}, Body)
new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Text = "sakura.bypass", TextColor3 = T.Dim, Font = FONT, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right}, Drag)
do
    local dragging, startIn, startPos = false, nil, nil
    Drag.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startIn, startPos = true, i.Position, Main.Position
        end
    end)
    conn(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = (i.Position - startIn) / Scale.Scale
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    conn(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

local Side = new("Frame", {Position = UDim2.fromOffset(0, 2), Size = UDim2.new(0, 68, 1, -2), BackgroundColor3 = Color3.fromRGB(12, 12, 12), BorderSizePixel = 0}, Body)
new("Frame", {Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = T.Line, BorderSizePixel = 0}, Side)
local TabList = new("Frame", {Size = UDim2.new(1, -1, 1, 0), BackgroundTransparency = 1}, Side)
new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, TabList)
local Pages = new("Frame", {Position = UDim2.fromOffset(80, 30), Size = UDim2.new(1, -92, 1, -40), BackgroundTransparency = 1, ClipsDescendants = true}, Body)

local tabs = {}
local function selectTab(t)
    for _, o in ipairs(tabs) do
        local on = o == t
        o.page.Visible = on
        o.icon.ImageColor3 = on and Color3.new(1, 1, 1) or T.Dim
        o.lbl.TextColor3 = on and T.Text or T.Dim
        o.bar.Visible = on
        o.btn.BackgroundTransparency = on and 0 or 1
    end
end

local function addTab(name, iconId)
    local t = {}
    t.btn = new("TextButton", {Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = T.Bg, BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = #tabs + 1}, TabList)
    t.icon = new("ImageLabel", {BackgroundTransparency = 1, Size = UDim2.fromOffset(26, 26), Position = UDim2.new(0.5, -13, 0, 10), Image = "rbxassetid://" .. iconId, ImageColor3 = T.Dim}, t.btn)
    t.lbl = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -19), Text = string.upper(name), TextColor3 = T.Dim, Font = FONT, TextSize = 11}, t.btn)
    t.bar = new("Frame", {Size = UDim2.new(0, 2, 1, -12), Position = UDim2.fromOffset(0, 6), BackgroundColor3 = T.Accent, BorderSizePixel = 0, Visible = false}, t.btn)
    onAccent(function(c) t.bar.BackgroundColor3 = c end)
    t.page = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = T.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, Pages)
    onAccent(function(c) t.page.ScrollBarImageColor3 = c end)
    pad(t.page, 10, 4, 10, 0)
    local function col(x, ox)
        local c = new("Frame", {Position = UDim2.new(x, ox, 0, 0), Size = UDim2.new(0.5, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, t.page)
        new("UIListLayout", {Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder}, c)
        return c
    end
    t.L, t.R = col(0, 0), col(0.5, 8)
    t.btn.MouseButton1Click:Connect(function() selectTab(t) end)
    t.btn.MouseEnter:Connect(function() if t.bar.Visible == false then t.icon.ImageColor3 = Color3.fromRGB(190, 190, 190) end end)
    t.btn.MouseLeave:Connect(function() if t.bar.Visible == false then t.icon.ImageColor3 = T.Dim end end)
    tabs[#tabs + 1] = t
    return t
end

local function group(col, title)
    local box = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Bg, BorderSizePixel = 0, LayoutOrder = #col:GetChildren()}, col)
    stroke(box, T.Line, 1)
    local lab = new("TextLabel", {AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 14), Position = UDim2.fromOffset(9, -8), BackgroundColor3 = T.Bg, BorderSizePixel = 0, Text = title, TextColor3 = T.Text, Font = FONT, TextSize = 14, ZIndex = 3}, box)
    pad(lab, 0, 4, 0, 4)
    local inner = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, box)
    new("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, inner)
    pad(inner, 14, 10, 10, 10)
    return inner
end

local function Toggle(card, text, tbl, key, cb)
    local row = new("TextButton", {Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = #card:GetChildren()}, card)
    local bx = new("Frame", {Size = UDim2.fromOffset(10, 10), Position = UDim2.new(0, 0, 0.5, -5), BackgroundColor3 = T.Ctl, BorderSizePixel = 0}, row)
    stroke(bx, BLACK, 1)
    shade(bx)
    new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 0), Size = UDim2.new(1, -20, 1, 0), Text = text, TextColor3 = T.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local function refresh() bx.BackgroundColor3 = tbl[key] and T.Accent or T.Ctl end
    onAccent(refresh)
    row.MouseButton1Click:Connect(function()
        tbl[key] = not tbl[key]
        refresh()
        if cb then task.spawn(cb, tbl[key]) end
    end)
    return row
end

local function Slider(card, text, min, max, tbl, key, step, suffix)
    step = step or 1
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = #card:GetChildren()}, card)
    new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 13), Text = text, TextColor3 = T.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local bar = new("TextButton", {Position = UDim2.fromOffset(0, 17), Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = T.Ctl, BorderSizePixel = 0, Text = "", AutoButtonColor = false}, row)
    stroke(bar, BLACK, 1)
    local fill = new("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = T.Accent, BorderSizePixel = 0}, bar)
    shade(fill)
    onAccent(function(c) fill.BackgroundColor3 = c end)
    local val = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", TextColor3 = Color3.new(1, 1, 1), Font = FONTB, TextSize = 11, TextStrokeTransparency = 0.5, ZIndex = 3}, bar)
    local function setv(v)
        v = math.clamp(math.floor(v / step + 0.5) * step, min, max)
        v = tonumber(string.format("%.3f", v))
        tbl[key] = v
        fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
        val.Text = ((step % 1 == 0) and tostring(math.floor(v + 0.5)) or string.format("%.1f", v)) .. (suffix or "")
    end
    setv(tbl[key])
    local dragging = false
    local function fromInput(i)
        local rel = (i.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1)
        setv(min + (max - min) * math.clamp(rel, 0, 1))
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            fromInput(i)
        end
    end)
    conn(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromInput(i) end
    end)
    conn(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    return row
end

local function Choice(card, text, options, tbl, key, cb)
    local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = #card:GetChildren()}, card)
    new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, wrap)
    new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 13), Text = text, TextColor3 = T.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1}, wrap)
    local btn = new("TextButton", {Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = T.Ctl, BorderSizePixel = 0, Text = tostring(tbl[key]), TextColor3 = T.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, LayoutOrder = 2}, wrap)
    stroke(btn, BLACK, 1)
    shade(btn)
    pad(btn, 0, 0, 0, 7)
    new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -18, 0, 0), Text = "v", TextColor3 = T.Dim, Font = FONT, TextSize = 12}, btn)
    local list = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderSizePixel = 0, Visible = false, LayoutOrder = 3}, wrap)
    stroke(list, BLACK, 1)
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, list)
    local items = {}
    local function paint()
        btn.Text = tostring(tbl[key])
        for o, b in pairs(items) do b.TextColor3 = (o == tbl[key]) and T.Accent or T.Text end
    end
    for n, o in ipairs(options) do
        local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 19), BackgroundTransparency = 1, Text = o, TextColor3 = T.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, LayoutOrder = n}, list)
        pad(b, 0, 0, 0, 7)
        items[o] = b
        b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.85 b.BackgroundColor3 = Color3.new(1, 1, 1) end)
        b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
        b.MouseButton1Click:Connect(function()
            tbl[key] = o
            list.Visible = false
            paint()
            if cb then task.spawn(cb, o) end
        end)
    end
    onAccent(paint)
    btn.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)
    return wrap
end

local function Button(card, text, cb)
    local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = T.Ctl, BorderSizePixel = 0, Text = text, TextColor3 = T.Text, Font = FONT, TextSize = 14, AutoButtonColor = false, LayoutOrder = #card:GetChildren()}, card)
    stroke(b, BLACK, 1)
    shade(b)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(48, 48, 48) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = T.Ctl end)
    b.MouseButton1Click:Connect(function() if cb then task.spawn(cb) end end)
    return b
end

local function label(card, text)
    return new("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text, TextColor3 = T.Dim, Font = FONT, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = #card:GetChildren()}, card)
end

local function Picker(card, title, getItems, onPick, height)
    local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = #card:GetChildren()}, card)
    new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, wrap)
    new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 13), Text = title, TextColor3 = T.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1}, wrap)
    local box = new("TextBox", {Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = T.Ctl, BorderSizePixel = 0, Text = "", PlaceholderText = "search...", PlaceholderColor3 = T.Dim, TextColor3 = T.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, LayoutOrder = 2}, wrap)
    stroke(box, BLACK, 1)
    pad(box, 0, 0, 0, 7)
    local list = new("ScrollingFrame", {Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, LayoutOrder = 3}, wrap)
    stroke(list, BLACK, 1)
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, list)
    local selected = nil
    local obj = {}
    local function rebuild()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local q = string.lower(box.Text)
        local shown = 0
        for n, name in ipairs(getItems()) do
            if q == "" or string.find(string.lower(name), q, 1, true) then
                shown = shown + 1
                if shown > 120 then break end
                local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = name, TextColor3 = (name == selected) and T.Accent or T.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, LayoutOrder = n}, list)
                pad(b, 0, 0, 0, 7)
                b.MouseButton1Click:Connect(function()
                    selected = name
                    onPick(name)
                    rebuild()
                end)
            end
        end
    end
    box:GetPropertyChangedSignal("Text"):Connect(rebuild)
    obj.rebuild = rebuild
    obj.get = function() return selected end
    return obj
end

local CAPS = {
    {"getgc", function() return type(getgc) == "function" end},
    {"getconnections", function() return type(getconnections) == "function" end},
    {"hookfunction", function() return type(hookfunction) == "function" end},
    {"hookmetamethod", function() return type(hookmetamethod) == "function" end},
    {"getnamecallmethod", function() return type(getnamecallmethod) == "function" end},
    {"getrawmetatable", function() return type(getrawmetatable) == "function" end},
    {"newcclosure", function() return type(newcclosure) == "function" end},
    {"checkcaller", function() return type(checkcaller) == "function" end},
    {"gethui", function() return type(gethui) == "function" end},
    {"Drawing", function() return hasDrawing end},
    {"mousemoverel", function() return type(mousemoverel) == "function" end},
    {"mouse1click", function() return type(mouse1click) == "function" end},
    {"mouse1press", function() return type(mouse1press) == "function" end},
    {"setclipboard", function() return type(setclipboard) == "function" end},
    {"writefile", function() return type(writefile) == "function" end},
    {"queue_on_teleport", function() return type(queue_on_teleport) == "function" end},
}
local function capsText()
    local parts = {}
    for _, c in ipairs(CAPS) do
        local ok, v = pcall(c[2])
        parts[#parts + 1] = c[1] .. ": " .. ((ok and v) and "yes" or "NO")
    end
    return table.concat(parts, "\n")
end
local function executorName()
    local ok, n = pcall(function() return identifyexecutor and identifyexecutor() end)
    return (ok and n) and tostring(n) or "?"
end

local menuKeys = {[Enum.KeyCode.Insert] = true, [Enum.KeyCode.Equals] = true}
local binding = false
local paintMobile = nil
local function toggleMenu()
    Main.Visible = not Main.Visible
    State.MenuOpen = Main.Visible
    if paintMobile then paintMobile() end
end
RunService:BindToRenderStep("SakuraRivalsMouse", 2000, function()
    if Alive and Main.Visible then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end
end)
Unloaders[#Unloaders + 1] = function() pcall(function() RunService:UnbindFromRenderStep("SakuraRivalsMouse") end) end
conn(UserInputService.InputBegan, function(i)
    if binding or i.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if menuKeys[i.KeyCode] and not UserInputService:GetFocusedTextBox() then toggleMenu() end
end)

local MobileBtn = new("TextButton", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 40, 0.5, 0), Size = UDim2.fromOffset(48, 48), BackgroundColor3 = T.Dark, Text = "", AutoButtonColor = false, Visible = S.UI.MobileBtn, ZIndex = 50}, Gui)
new("UICorner", {CornerRadius = UDim.new(1, 0)}, MobileBtn)
local mst = stroke(MobileBtn, T.Accent, 2)
local mIcon = new("ImageLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(26, 26), Image = "rbxassetid://79478214327919", ImageColor3 = T.Accent, ZIndex = 51}, MobileBtn)
onAccent(function(c) mst.Color = c mIcon.ImageColor3 = c end)
paintMobile = function() mIcon.Image = Main.Visible and "rbxassetid://116396312853810" or "rbxassetid://79478214327919" end
paintMobile()
do
    local dragging, moved, activeIn, startIn, startPos = false, false, nil, nil, nil
    MobileBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, moved, activeIn, startIn, startPos = true, false, i, i.Position, MobileBtn.Position
        end
    end)
    conn(UserInputService.InputChanged, function(i)
        if dragging and (i == activeIn or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - startIn
            if d.Magnitude > 8 then moved = true end
            if moved then MobileBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end
        end
    end)
    conn(UserInputService.InputEnded, function(i)
        if dragging and (i == activeIn or i.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = false
            if not moved then toggleMenu() end
        end
    end)
end

local Watermark = new("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 10), Size = UDim2.fromOffset(240, 22), BackgroundColor3 = T.Dark, BorderSizePixel = 0, ZIndex = 30}, Gui)
stroke(Watermark, T.Line, 1)
gradLine(Watermark, 2).ZIndex = 32
local wmText = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", RichText = true, TextColor3 = T.Text, Font = FONT, TextSize = 14, ZIndex = 31}, Watermark)
pad(wmText, 2, 0, 0, 0)

local fps, fpsN, fpsT = 60, 0, os.clock()
conn(RunService.RenderStepped, function()
    fpsN = fpsN + 1
    local t = os.clock()
    if t - fpsT >= 0.5 then
        fps = math.floor(fpsN / (t - fpsT) + 0.5)
        fpsN, fpsT = 0, t
    end
end)
local function getPing()
    local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    return ok and math.floor(v + 0.5) or 0
end

local winInfo = "выключено"
do
    local Wn = S.Win
    local target, targetAt = nil, 0
    local holding, lastClick, lastWalk = false, 0, 0
    local hasPress = type(mouse1press) == "function" and type(mouse1release) == "function"

    local function setFire(on)
        if on == holding then return end
        holding = on
        if hasPress then pcall(on and mouse1press or mouse1release) end
    end

    local function partOf(char)
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        if Wn.Part == "Torso" then return torso or head end
        return head or torso
    end

    local function pick(me)
        local origin = Camera.CFrame.Position
        local ignore = baseIgnore(me)
        local best, bestScore = nil, math.huge
        for _, item in ipairs(collect(false)) do
            local char = item.char
            if char.Parent and alive(char) and not (Wn.TeamCheck and isAlly(item.plr, char)) then
                local part = partOf(char)
                if part then
                    local d = (part.Position - origin).Magnitude
                    if d <= Wn.MaxDist then
                        local vis = canHit(part, char, ignore)
                        local score = d + (vis and 0 or 10000)
                        if score < bestScore then
                            bestScore = score
                            best = {char = char, part = part, plr = item.plr, vis = vis, dist = d}
                        end
                    end
                end
            end
        end
        return best
    end

    local function step()
        local me = myChar()
        if not (Wn.Enabled and Alive and me and Camera and hasRoot(me)) then
            setFire(false)
            if not Wn.Enabled then winInfo = "выключено" end
            return
        end
        local now = os.clock()
        if not target or not target.char.Parent or not target.part.Parent or not alive(target.char) or now - targetAt > 0.15 then
            targetAt = now
            target = pick(me)
        end
        if not target then
            setFire(false)
            winInfo = "нет целей"
            return
        end
        local part = target.part
        local cf = Camera.CFrame
        target.dist = (part.Position - cf.Position).Magnitude
        winInfo = string.format("цель: %s | %d м | %s", target.plr and target.plr.DisplayName or target.char.Name, math.floor(target.dist), target.vis and "видна" or "за стеной")
        if Main.Visible then
            setFire(false)
            return
        end
        local want = CFrame.lookAt(cf.Position, part.Position)
        Camera.CFrame = Wn.Smooth <= 1 and want or cf:Lerp(want, 1 / Wn.Smooth)
        if Wn.Fire and (target.vis or not Wn.VisOnly) then
            if hasPress then
                setFire(true)
            elseif now - lastClick > 0.09 then
                lastClick = now
                pcall(mouse1click)
            end
        else
            setFire(false)
        end
    end

    RunService:BindToRenderStep("SakuraRivalsWin", Enum.RenderPriority.Camera.Value + 1, guard("autowin", step))

    onHB("autowin_walk", function()
        if not (Wn.Enabled and Wn.Walk and target) then return end
        local now = os.clock()
        if now - lastWalk < 0.2 then return end
        lastWalk = now
        local me = myChar()
        local hum = me and me:FindFirstChildOfClass("Humanoid")
        if hum and target.part.Parent and target.dist > Wn.Stop then hum:MoveTo(target.part.Position) end
    end)

    Unloaders[#Unloaders + 1] = function()
        setFire(false)
        pcall(function() RunService:UnbindFromRenderStep("SakuraRivalsWin") end)
    end
end

local spinInfo = "off"
do
    local Sn = S.Spin
    local yaw, active = 0, false

    local function rootOf(c) return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) end
    local function write(hrp, y)
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, y, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    local function release()
        if not active then return end
        active = false
        local char = myChar()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end

    onHB("spin", function(dt)
        if not Sn.Enabled then
            spinInfo = "выключено"
            release()
            return
        end
        local char = myChar()
        local hrp = rootOf(char)
        if not hrp or hrp.Anchored or not alive(char) then spinInfo = "нет живого персонажа" return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        active = true
        if hum and hum.AutoRotate then hum.AutoRotate = false end
        yaw = (yaw + math.rad(Sn.Speed) * dt * (Sn.Direction == "Left" and 1 or -1)) % (math.pi * 2)
        write(hrp, yaw)
        spinInfo = string.format("%d°/s | угол %d", Sn.Speed, math.floor(math.deg(yaw)))
    end)

    local function reapply()
        if not (Sn.Enabled and active) then return end
        local hrp = rootOf(myChar())
        if hrp and not hrp.Anchored then write(hrp, yaw) end
    end
    conn(RunService.Stepped, guard("spin-step", reapply))

    RunService:BindToRenderStep("SakuraRivalsSpin", Enum.RenderPriority.Last.Value - 5, guard("spin-render", function()
        if not (Sn.Enabled and active) then return end
        local hrp = rootOf(myChar())
        if not hrp or hrp.Anchored then return end
        if Sn.Visual then
            write(hrp, yaw)
        elseif Camera then
            local _, cy = Camera.CFrame:ToOrientation()
            write(hrp, cy)
        end
    end))

    Unloaders[#Unloaders + 1] = function()
        release()
        pcall(function() RunService:UnbindFromRenderStep("SakuraRivalsSpin") end)
    end
end

local win2Info = "выключено"
do
    local W2 = S.Win2
    local target, targetAt = nil, 0
    local holding, lastClick = false, 0
    local hasPress = type(mouse1press) == "function" and type(mouse1release) == "function"

    local function setFire(on)
        if on == holding then return end
        holding = on
        if hasPress then pcall(on and mouse1press or mouse1release) end
    end

    local function rootOf(c) return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) end

    local function pick(myPos)
        local best, bd = nil, math.huge
        for _, item in ipairs(collect(false)) do
            local char = item.char
            if char.Parent and alive(char) and not (W2.TeamCheck and isAlly(item.plr, char)) then
                local root = rootOf(char)
                if root then
                    local d = (root.Position - myPos).Magnitude
                    if d <= W2.MaxDist and d < bd then
                        bd = d
                        best = {char = char, root = root, head = char:FindFirstChild("Head") or root, plr = item.plr, dist = d}
                    end
                end
            end
        end
        return best
    end

    conn(RunService.Stepped, guard("win2_noclip", function()
        if not (W2.Enabled and W2.Noclip) then return end
        local me = myChar()
        if not me then return end
        for _, p in ipairs(me:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end))

    onHB("win2", function(dt)
        if not (W2.Enabled and Alive) then
            if not W2.Enabled then win2Info = "выключено" end
            return
        end
        local me = myChar()
        local hrp = rootOf(me)
        if not (hrp and alive(me)) or hrp.Anchored then win2Info = "нет живого персонажа" target = nil return end
        local now = os.clock()
        if not target or not target.char.Parent or not target.root.Parent or not alive(target.char) or now - targetAt > 0.3 then
            targetAt = now
            target = pick(hrp.Position)
        end
        if not target then win2Info = "нет целей" return end
        local goal = (target.root.CFrame * CFrame.new(0, W2.Height, W2.Dist)).Position
        local cur = hrp.Position
        local off = goal - cur
        local dist = off.Magnitude
        local step = W2.Speed <= 0 and dist or math.min(dist, W2.Speed * dt)
        local newPos = dist > 0.01 and (cur + off.Unit * step) or cur
        local tp = target.root.Position
        hrp.CFrame = CFrame.lookAt(newPos, Vector3.new(tp.X, newPos.Y, tp.Z))
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        win2Info = string.format("цель: %s | до цели %d м", target.plr and target.plr.DisplayName or target.char.Name, math.floor((tp - newPos).Magnitude))
    end)

    RunService:BindToRenderStep("SakuraRivalsWin2", Enum.RenderPriority.Camera.Value + 1, guard("win2_aim", function()
        if not (W2.Enabled and Alive and target and Camera) or not target.head.Parent then
            setFire(false)
            return
        end
        if Main.Visible then
            setFire(false)
            return
        end
        local cf = Camera.CFrame
        Camera.CFrame = CFrame.lookAt(cf.Position, target.head.Position)
        local d = (target.head.Position - cf.Position).Magnitude
        if W2.Fire and d <= W2.FireRange then
            if hasPress then
                setFire(true)
            elseif os.clock() - lastClick > 0.09 then
                lastClick = os.clock()
                pcall(mouse1click)
            end
        else
            setFire(false)
        end
    end))

    Unloaders[#Unloaders + 1] = function()
        setFire(false)
        pcall(function() RunService:UnbindFromRenderStep("SakuraRivalsWin2") end)
    end
end

local Lighting = game:GetService("Lighting")

local speedInfo = "выключено"
do
    local Sp = S.Speed
    local sray = RaycastParams.new()
    sray.FilterType = Enum.RaycastFilterType.Exclude
    sray.IgnoreWater = true
    local lastHum, origWS = nil, nil
    local ACT = {["Hold Shift"] = Enum.KeyCode.LeftShift, ["Hold Alt"] = Enum.KeyCode.LeftAlt, ["Hold Ctrl"] = Enum.KeyCode.LeftControl}

    local function restoreWS()
        if lastHum and origWS and lastHum.Parent then pcall(function() lastHum.WalkSpeed = origWS end) end
        lastHum, origWS = nil, nil
    end

    local function keyDir()
        local u = UserInputService
        if u:GetFocusedTextBox() or not Camera then return nil end
        local x = (u:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (u:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
        local z = (u:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (u:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
        if x == 0 and z == 0 then return nil end
        local cf = Camera.CFrame
        local d = cf.RightVector * x + cf.LookVector * -z
        d = Vector3.new(d.X, 0, d.Z)
        if d.Magnitude < 0.01 then return nil end
        return d.Unit
    end

    onHB("speed", function(dt)
        if not Sp.Enabled then
            speedInfo = "выключено"
            if lastHum then restoreWS() end
            return
        end
        local char = myChar()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
        if not hrp then speedInfo = "нет персонажа" return end
        if not alive(char) then speedInfo = "мёртв" return end
        if Sp.Method ~= "WalkSpeed" and lastHum then restoreWS() end
        local key = ACT[Sp.Activation]
        if key and not UserInputService:IsKeyDown(key) then speedInfo = "жду " .. Sp.Activation return end
        local target = Sp.Speed
        if Sp.Method == "WalkSpeed" then
            if not hum then speedInfo = "нет Humanoid" return end
            if hum ~= lastHum then
                restoreWS()
                lastHum, origWS = hum, hum.WalkSpeed
            end
            if hum.WalkSpeed ~= target then hum.WalkSpeed = target end
            speedInfo = "WalkSpeed " .. target
            return
        end
        local md = hum and hum.MoveDirection or Vector3.new(0, 0, 0)
        local dir = nil
        if md.Magnitude >= 0.1 then dir = Vector3.new(md.X, 0, md.Z).Unit else dir = keyDir() end
        if not dir then speedInfo = "стою" return end
        if Sp.Method == "Velocity" then
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * target, v.Y, dir.Z * target)
            speedInfo = "Velocity " .. target
            return
        end
        local base = hum and hum.WalkSpeed or 16
        local extra = math.max(target - base, 0) * math.min(dt, 0.1)
        if extra <= 0 then speedInfo = "CFrame: цель не выше базовой (" .. base .. ")" return end
        sray.FilterDescendantsInstances = {char, Camera}
        if Workspace:Raycast(hrp.Position, dir * (extra + 1.6), sray) then speedInfo = "CFrame (стена)" return end
        hrp.CFrame = hrp.CFrame + dir * extra
        speedInfo = "CFrame " .. target .. " (база " .. base .. ")"
    end)
    Unloaders[#Unloaders + 1] = restoreWS
    S.Speed.Restore = restoreWS
end

local bpInfo = {nc = "не установлен", idx = "не установлен", kick = 0, remote = 0}
do
    local Bp = S.Bypass
    local BAD = {"ban", "kick", "cheat", "detect", "exploit", "anticheat", "anti_cheat", "suspicious", "violation"}
    local ncDone, idxDone = false, false

    local function hookMeta(name, fn)
        if type(hookmetamethod) == "function" then
            local ok, old = pcall(hookmetamethod, game, name, fn)
            if ok and old then return old end
        end
        if type(getrawmetatable) == "function" and type(setreadonly) == "function" then
            local ok, old = pcall(function()
                local mt = getrawmetatable(game)
                local o = mt[name]
                setreadonly(mt, false)
                mt[name] = fn
                setreadonly(mt, true)
                return o
            end)
            if ok and old then return old end
        end
        return nil
    end
    local function callerIsMe() return type(checkcaller) == "function" and checkcaller() end

    local function installNamecall()
        if ncDone then return end
        ncDone = true
        if type(getnamecallmethod) ~= "function" then bpInfo.nc = "нет getnamecallmethod" return end
        local old
        local wrapper = function(self, ...)
            if Bp.Enabled and not callerIsMe() then
                local m = getnamecallmethod()
                if Bp.AntiKick and self == LP and (m == "Kick" or m == "kick") then
                    bpInfo.kick = bpInfo.kick + 1
                    return
                end
                if Bp.BlockRemotes and (m == "FireServer" or m == "InvokeServer") and typeof(self) == "Instance" then
                    local n = string.lower(self.Name)
                    for _, w in ipairs(BAD) do
                        if string.find(n, w, 1, true) then
                            bpInfo.remote = bpInfo.remote + 1
                            return
                        end
                    end
                end
            end
            return old(self, ...)
        end
        if newcclosure then wrapper = newcclosure(wrapper) end
        old = hookMeta("__namecall", wrapper)
        bpInfo.nc = old and "OK" or "не удалось (нет hookmetamethod)"
    end

    local function installIndex()
        if idxDone then return end
        idxDone = true
        local old
        local wrapper = function(self, key)
            if (key == "WalkSpeed" or key == "JumpPower") and Bp.Enabled and Bp.SpoofSpeed and not callerIsMe() then
                local ok, cls = pcall(old, self, "ClassName")
                if ok and cls == "Humanoid" then return key == "WalkSpeed" and 16 or 50 end
            end
            return old(self, key)
        end
        if newcclosure then wrapper = newcclosure(wrapper) end
        old = hookMeta("__index", wrapper)
        bpInfo.idx = old and "OK" or "не удалось (нет hookmetamethod)"
    end

    S.Bypass.Refresh = function()
        if not Bp.Enabled then return end
        installNamecall()
        if Bp.SpoofSpeed then installIndex() end
    end
end

local antiInfo = {freeze = 0, flash = 0, smoke = 0, afk = "off"}
do
    local An = S.Anti
    local lastWS, nextT = nil, 0

    onHB("anti_freeze", function()
        if not An.Freeze then return end
        local now = os.clock()
        if now < nextT then return end
        nextT = now + 0.1
        local char = myChar()
        if not char or not alive(char) then return end
        local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp and hrp.Anchored then
            hrp.Anchored = false
            antiInfo.freeze = antiInfo.freeze + 1
        end
        if hum then
            if hum.PlatformStand then
                hum.PlatformStand = false
                antiInfo.freeze = antiInfo.freeze + 1
            end
            if hum.WalkSpeed > 0 then
                lastWS = hum.WalkSpeed
            elseif lastWS and An.FreezeSpeed then
                hum.WalkSpeed = lastWS
                antiInfo.freeze = antiInfo.freeze + 1
            end
        end
        for _, holder in ipairs({char, LP}) do
            for k, v in pairs(holder:GetAttributes()) do
                local l = string.lower(k)
                if v == true and (string.find(l, "freez", 1, true) or string.find(l, "frozen", 1, true) or string.find(l, "stun", 1, true)) then
                    holder:SetAttribute(k, false)
                    antiInfo.freeze = antiInfo.freeze + 1
                end
            end
        end
    end)

    local function nukeFlash(o)
        local n = string.lower(o.Name)
        if not string.find(n, "flash", 1, true) or string.find(n, "light", 1, true) then return end
        if o:IsA("ColorCorrectionEffect") or o:IsA("BlurEffect") or o:IsA("BloomEffect") then
            o.Enabled = false
        elseif o:IsA("ScreenGui") then
            o.Enabled = false
        elseif o:IsA("GuiObject") then
            o.Visible = false
        else
            return
        end
        antiInfo.flash = antiInfo.flash + 1
    end
    local function sweepFlash()
        pcall(function()
            for _, o in ipairs(LP.PlayerGui:GetDescendants()) do nukeFlash(o) end
            for _, o in ipairs(Lighting:GetDescendants()) do nukeFlash(o) end
        end)
    end
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if pg then conn(pg.DescendantAdded, function(o) if An.Flash then task.defer(nukeFlash, o) end end) end
    conn(Lighting.DescendantAdded, function(o) if An.Flash then task.defer(nukeFlash, o) end end)
    S.Anti.FlashOn = function(on) if on then sweepFlash() end end

    local smokeConn = nil
    local function smokeCheck(o)
        if o:IsA("ParticleEmitter") or o:IsA("Smoke") then
            local n = string.lower(o.Name)
            local pn = o.Parent and string.lower(o.Parent.Name) or ""
            if string.find(n, "smoke", 1, true) or string.find(pn, "smoke", 1, true) then
                o.Enabled = false
                antiInfo.smoke = antiInfo.smoke + 1
            end
        end
    end
    S.Anti.SmokeOn = function(on)
        if smokeConn then smokeConn:Disconnect() smokeConn = nil end
        if on then
            smokeConn = Workspace.DescendantAdded:Connect(function(o) task.defer(smokeCheck, o) end)
            Conns[#Conns + 1] = smokeConn
        end
    end

    local afkPulse = false
    S.Anti.AfkOn = function(on)
        afkPulse = false
        if not on then antiInfo.afk = "off" return end
        if type(getconnections) == "function" then
            local ok, list = pcall(getconnections, LP.Idled)
            if ok and type(list) == "table" and #list > 0 then
                local n = 0
                for _, c in ipairs(list) do
                    if pcall(function() c:Disable() end) then n = n + 1 end
                end
                if n > 0 then antiInfo.afk = "отключено соединений: " .. n return end
            end
        end
        if type(mousemoverel) == "function" then
            afkPulse = true
            antiInfo.afk = "импульс мышью раз в минуту (getconnections не работает)"
        else
            antiInfo.afk = "нет getconnections и mousemoverel"
        end
    end
    task.spawn(function()
        while Alive do
            task.wait(55)
            if afkPulse and S.Anti.AFK and not State.MenuOpen then
                pcall(mousemoverel, 1, 0)
                task.wait(0.05)
                pcall(mousemoverel, -1, 0)
            end
        end
    end)
end

do
    local V = S.View
    local orig = nil
    local origFov = nil
    conn(RunService.RenderStepped, guard("fov_changer", function()
        if V.FovOn and Camera then
            if not origFov then origFov = Camera.FieldOfView end
            if Camera.FieldOfView ~= V.Fov then Camera.FieldOfView = V.Fov end
        elseif origFov and Camera then
            Camera.FieldOfView = origFov
            origFov = nil
        end
    end))
    local function apply(on)
        if on then
            if not orig then
                orig = {Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.Ambient, Lighting.OutdoorAmbient}
            end
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.Ambient = Color3.fromRGB(170, 170, 170)
            Lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
        elseif orig then
            Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.Ambient, Lighting.OutdoorAmbient = orig[1], orig[2], orig[3], orig[4], orig[5]
            orig = nil
        end
    end
    S.View.Bright = apply
    onHB("fullbright", function()
        if V.Fullbright and orig and Lighting.ClockTime ~= 14 then apply(true) end
    end)
    Unloaders[#Unloaders + 1] = function() apply(false) V.FovOn = false end
end

local jumpInfo = "выключено"
do
    local J = S.Jump
    local lastState, lastJump = nil, 0
    local jumpWas = false
    local lastHum, origPower, origUse = nil, nil, nil

    local function restoreProp()
        if lastHum and lastHum.Parent and origPower then
            pcall(function()
                lastHum.JumpPower = origPower
                if origUse ~= nil then lastHum.UseJumpPower = origUse end
            end)
        end
        lastHum, origPower, origUse = nil, nil, nil
    end

    local function kick(hum, hrp)
        local now = os.clock()
        if now - lastJump < 0.15 then return end
        lastJump = now
        if J.Method == "Velocity" then
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, J.Power, v.Z)
        elseif J.Method == "Impulse" then
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
            hrp:ApplyImpulse(Vector3.new(0, J.Power * hrp.AssemblyMass, 0))
        end
        jumpInfo = J.Method .. " " .. J.Power
    end

    local function ctx()
        local char = myChar()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
        if hum and hrp and alive(char) then return hum, hrp end
        return nil
    end

    local spaceWas = false
    local function pollSpace(hum, hrp)
        local typing = UserInputService:GetFocusedTextBox() ~= nil
        local down = (not typing) and UserInputService:IsKeyDown(Enum.KeyCode.Space)
        local pressed = down and not spaceWas
        spaceWas = down
        if not pressed or J.Method == "JumpPower" then return end
        local grounded = hum.FloorMaterial ~= Enum.Material.Air or math.abs(hrp.AssemblyLinearVelocity.Y) < 2
        if J.Infinite or grounded then
            task.delay(0.03, function()
                local h2, r2 = ctx()
                if h2 and J.Enabled then kick(h2, r2) end
            end)
        end
    end

    onHB("jump", function()
        if not J.Enabled then
            jumpInfo = "выключено"
            if lastHum then restoreProp() end
            lastState = nil
            return
        end
        local hum, hrp = ctx()
        if not hum then jumpInfo = "нет персонажа" return end
        if J.Method == "JumpPower" then
            if hum ~= lastHum then
                restoreProp()
                lastHum, origPower, origUse = hum, hum.JumpPower, hum.UseJumpPower
            end
            if not hum.UseJumpPower then hum.UseJumpPower = true end
            if hum.JumpPower ~= J.Power then hum.JumpPower = J.Power end
            jumpInfo = "JumpPower " .. J.Power .. " (свойство меняется, виден античиту)"
            return
        end
        if lastHum then restoreProp() end
        pollSpace(hum, hrp)
        local st = hum:GetState()
        if (st == Enum.HumanoidStateType.Jumping and lastState ~= Enum.HumanoidStateType.Jumping) or (hum.Jump and not jumpWas) then kick(hum, hrp) end
        jumpWas = hum.Jump
        lastState = st
        if os.clock() - lastJump > 2 then jumpInfo = J.Method .. " " .. J.Power .. " (свойство JumpPower не трогаю)" end
    end)

    S.Jump.Restore = restoreProp
    Unloaders[#Unloaders + 1] = restoreProp
end

local godInfo, bhopInfo = "выключено", "выключено"
do
    local G = S.God
    local lastHum, stateBackup = nil, nil
    local lastSafe, lastSafeAt = nil, 0
    local lastVel = Vector3.zero
    local fixes = {health = 0, override = 0, knock = 0, void = 0, state = 0}
    local setAt = nil
    local BAD = {Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.PlatformStanding}

    local function restoreStates()
        if lastHum and lastHum.Parent and stateBackup then
            for st, was in pairs(stateBackup) do pcall(function() lastHum:SetStateEnabled(st, was) end) end
        end
        lastHum, stateBackup = nil, nil
    end

    onHB("god", function()
        if not G.Enabled then
            godInfo = "выключено"
            if lastHum then restoreStates() end
            setAt = nil
            return
        end
        local char = myChar()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
        if not (hum and hrp) then godInfo = "нет персонажа" return end
        if hum.Health <= 0 then return end

        if G.Health then
            if setAt and hum.Health < hum.MaxHealth - 0.5 and os.clock() - setAt < 0.3 then
                fixes.override = fixes.override + 1
            end
            if hum.Health < hum.MaxHealth then
                pcall(function() hum.Health = hum.MaxHealth end)
                fixes.health = fixes.health + 1
                setAt = os.clock()
            end
        end

        if G.AntiRagdoll then
            if hum ~= lastHum then
                restoreStates()
                lastHum, stateBackup = hum, {}
                for _, st in ipairs(BAD) do
                    local ok, was = pcall(function() return hum:GetStateEnabled(st) end)
                    if ok then
                        stateBackup[st] = was
                        pcall(function() hum:SetStateEnabled(st, false) end)
                    end
                end
            end
            local cur = hum:GetState()
            for _, st in ipairs(BAD) do
                if cur == st then
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                    fixes.state = fixes.state + 1
                    break
                end
            end
        elseif lastHum then
            restoreStates()
        end

        if G.AntiKnock then
            local v = hrp.AssemblyLinearVelocity
            local base = math.max(hum.WalkSpeed, S.Speed.Enabled and S.Speed.Speed or 0, S.Bhop.Enabled and S.Bhop.Max or 0)
            local limit = base * 1.5 + 25
            local h = Vector3.new(v.X, 0, v.Z)
            if h.Magnitude > limit then
                local c = h.Unit * limit
                hrp.AssemblyLinearVelocity = Vector3.new(c.X, v.Y, c.Z)
                fixes.knock = fixes.knock + 1
            end
            if v.Y > 120 then
                hrp.AssemblyLinearVelocity = Vector3.new(v.X, 50, v.Z)
                fixes.knock = fixes.knock + 1
            end
        end

        if G.VoidSave then
            local now = os.clock()
            if hum.FloorMaterial ~= Enum.Material.Air and now - lastSafeAt > 0.5 then
                lastSafe, lastSafeAt = hrp.CFrame, now
            end
            local floor = (Workspace.FallenPartsDestroyHeight or -500) + 80
            if hrp.Position.Y < floor and lastSafe then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.CFrame = lastSafe + Vector3.new(0, 4, 0)
                fixes.void = fixes.void + 1
            end
        end

        local verdict = ""
        if G.Health then
            verdict = fixes.override > 5 and " | сервер перезаписывает HP (блок здоровья не работает в этой игре)" or (fixes.health > 0 and " | HP восстановлен " .. fixes.health .. "x" or "")
        end
        godInfo = string.format("hp %d/%d%s\nанти-отброс: %d | анти-рэгдолл: %d | спасено из войда: %d", hum.Health, hum.MaxHealth, verdict, fixes.knock, fixes.state, fixes.void)
    end)
    S.God.Restore = restoreStates
    Unloaders[#Unloaders + 1] = restoreStates
end

do
    local B = S.Bhop
    local pendingAt, wasGrounded = nil, true
    local jumps = 0
    onHB("bhop", function(dt)
        if not B.Enabled then bhopInfo = "выключено" pendingAt = nil return end
        local char = myChar()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
        if not (hum and hrp) or not alive(char) then bhopInfo = "нет персонажа" return end
        local typing = UserInputService:GetFocusedTextBox() ~= nil
        local down = (not typing) and not State.MenuOpen and UserInputService:IsKeyDown(Enum.KeyCode.Space)
        if not down then pendingAt = nil bhopInfo = "ждёт пробел (зажми Space)" return end
        local grounded = hum.FloorMaterial ~= Enum.Material.Air
        local v = hrp.AssemblyLinearVelocity
        if grounded then
            if pendingAt and os.clock() - pendingAt > 0.12 then
                local p = (hum.UseJumpPower and hum.JumpPower > 0) and hum.JumpPower or 50
                hrp.AssemblyLinearVelocity = Vector3.new(v.X, p, v.Z)
                pendingAt = nil
            elseif not pendingAt then
                local st = hum:GetState()
                if st ~= Enum.HumanoidStateType.Jumping then
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                    hum.Jump = true
                    pendingAt = os.clock()
                    jumps = jumps + 1
                end
            end
        else
            pendingAt = nil
            if B.Mode == "Rage" then
                local wish = hum.MoveDirection
                if wish.Magnitude > 0.1 then
                    wish = Vector3.new(wish.X, 0, wish.Z).Unit
                    local h = Vector3.new(v.X, 0, v.Z)
                    local sp = h.Magnitude
                    local base = math.max(sp, hum.WalkSpeed)
                    local dir = sp > 1 and h.Unit or wish
                    local t = math.clamp(dt * B.Turn, 0, 1)
                    local nd = dir:Lerp(wish, t)
                    if nd.Magnitude < 0.01 then nd = wish end
                    local ns = math.min(B.Max, base + B.Accel * dt)
                    local out = nd.Unit * ns
                    hrp.AssemblyLinearVelocity = Vector3.new(out.X, v.Y, out.Z)
                end
            end
        end
        bhopInfo = string.format("%s | прыжков: %d | скорость: %d", B.Mode, jumps, Vector3.new(v.X, 0, v.Z).Magnitude)
    end)
end

local skinStat = {state = "выключено", err = nil, skins = 0, weapons = 0, patched = "-", hook = "-", equipped = ""}
local skinApply = function() return false, "не готово" end
do
    local Sk = S.Skins
    local HttpService = game:GetService("HttpService")
    local CosmeticLibrary, ItemLibrary, DataController, FighterController, EnumLibrary
    local equipped = {}
    local installed, installing = false, false
    local restores = {}
    local constructing = nil
    local realGet = nil
    local saveFile = "sakura_rivals_skins.json"

    local function safeRequire(inst)
        if not inst then return nil end
        local ok, res = pcall(require, inst)
        if ok then return res end
        return nil
    end

    local function path(root, ...)
        local o = root
        for _, n in ipairs({...}) do
            if not o then return nil end
            o = o:FindFirstChild(n)
        end
        return o
    end

    local function isSkin(name)
        local c = CosmeticLibrary.Cosmetics[name]
        return type(c) == "table" and c.Type == "Skin"
    end

    local function cloneCosmetic(name)
        local base = CosmeticLibrary.Cosmetics[name]
        if type(base) ~= "table" then return nil end
        local data = {}
        for k, v in pairs(base) do data[k] = v end
        data.Name = name
        data.Type = data.Type or "Skin"
        data.Seed = data.Seed or math.random(1, 1000000)
        if EnumLibrary then
            local ok, id = pcall(EnumLibrary.ToEnum, EnumLibrary, name)
            if ok and id then data.Enum, data.ObjectID = id, data.ObjectID or id end
        end
        return data
    end

    local function save()
        if not writefile then return end
        pcall(function()
            local t = {}
            for w, e in pairs(equipped) do
                if e.Skin then t[w] = e.Skin.Name end
            end
            writefile(saveFile, HttpService:JSONEncode(t))
        end)
    end

    local function refreshEquipped()
        local parts = {}
        for w, e in pairs(equipped) do
            if e.Skin then parts[#parts + 1] = w .. " = " .. tostring(e.Skin.Name) end
        end
        table.sort(parts)
        skinStat.equipped = #parts == 0 and "нет" or table.concat(parts, "\n")
    end

    local function loadSaved()
        if not (readfile and isfile) then return end
        pcall(function()
            if not isfile(saveFile) then return end
            local t = HttpService:JSONDecode(readfile(saveFile))
            for w, name in pairs(t) do
                local c = cloneCosmetic(name)
                if c then equipped[w] = {Skin = c} end
            end
        end)
    end

    local function patch(tbl, key, make)
        if type(tbl) ~= "table" then return false end
        local orig = tbl[key]
        if type(orig) ~= "function" then return false end
        local fn = make(orig)
        local ok = pcall(function() tbl[key] = fn end)
        if not ok and type(setreadonly) == "function" then
            pcall(setreadonly, tbl, false)
            ok = pcall(function() tbl[key] = fn end)
        end
        if ok then
            restores[#restores + 1] = function()
                if rawget(tbl, key) == fn then pcall(function() tbl[key] = orig end) end
            end
        end
        return ok
    end

    local function install()
        local mods = ReplicatedStorage:FindFirstChild("Modules")
        local ps = LP:FindFirstChild("PlayerScripts")
        local ctrl = ps and ps:FindFirstChild("Controllers")
        if not (mods and ctrl) then skinStat.err = "нет Modules или Controllers" return false end
        EnumLibrary = safeRequire(mods:FindFirstChild("EnumLibrary"))
        if EnumLibrary and EnumLibrary.WaitForEnumBuilder then pcall(EnumLibrary.WaitForEnumBuilder, EnumLibrary) end
        CosmeticLibrary = safeRequire(mods:FindFirstChild("CosmeticLibrary"))
        ItemLibrary = safeRequire(mods:FindFirstChild("ItemLibrary"))
        DataController = safeRequire(ctrl:FindFirstChild("PlayerDataController"))
        FighterController = safeRequire(ctrl:FindFirstChild("FighterController"))
        if not (type(CosmeticLibrary) == "table" and type(CosmeticLibrary.Cosmetics) == "table") then skinStat.err = "CosmeticLibrary не найден" return false end
        if type(DataController) ~= "table" then skinStat.err = "PlayerDataController не найден" return false end
        local ClientItem = safeRequire(path(ps, "Modules", "ClientReplicatedClasses", "ClientFighter", "ClientItem"))
        local vmInst = path(ps, "Modules", "ClientReplicatedClasses", "ClientFighter", "ClientItem", "ClientViewModel")
        local ClientViewModel = safeRequire(vmInst)
        local ReplicatedClass = safeRequire(mods:FindFirstChild("ReplicatedClass"))

        local done = {}
        for _, key in ipairs({"OwnsCosmeticNormally", "OwnsCosmeticUniversally", "OwnsCosmeticForWeapon", "OwnsCosmetic"}) do
            if patch(CosmeticLibrary, key, function(orig)
                return function(self, inventory, name, ...)
                    if Sk.Enabled and type(name) == "string" and not string.find(name, "MISSING_", 1, true) and isSkin(name) then return true end
                    return orig(self, inventory, name, ...)
                end
            end) then done[#done + 1] = key end
        end

        local cData, cProxy, cAt = nil, nil, 0
        if patch(DataController, "Get", function(orig)
            realGet = orig
            return function(self, key, ...)
                local data = orig(self, key, ...)
                if Sk.Enabled and key == "CosmeticInventory" and type(data) == "table" then
                    local now = os.clock()
                    if cData == data and cProxy and now - cAt < 1 then return cProxy end
                    local proxy = {}
                    for k, v in pairs(data) do proxy[k] = v end
                    for name, c in pairs(CosmeticLibrary.Cosmetics) do
                        if proxy[name] == nil and type(c) == "table" and c.Type == "Skin" then proxy[name] = true end
                    end
                    cData, cProxy, cAt = data, proxy, now
                    return proxy
                end
                return data
            end
        end) then done[#done + 1] = "Get" end

        if patch(DataController, "GetWeaponData", function(orig)
            return function(self, weaponName, ...)
                local data = orig(self, weaponName, ...)
                if not (Sk.Enabled and data) then return data end
                local eq = equipped[weaponName]
                if not (eq and eq.Skin) then return data end
                local merged = {}
                for k, v in pairs(data) do merged[k] = v end
                merged.Name = weaponName
                merged.Skin = eq.Skin
                return merged
            end
        end) then done[#done + 1] = "GetWeaponData" end

        if ClientItem and patch(ClientItem, "_CreateViewModel", function(orig)
            return function(self, ref)
                local weaponName = self.Name
                local owner = self.ClientFighter and self.ClientFighter.Player
                constructing = (owner == LP) and weaponName or nil
                local eq = equipped[weaponName]
                if Sk.Enabled and owner == LP and eq and eq.Skin and ref then
                    pcall(function()
                        local dataKey, skinKey, nameKey = self:ToEnum("Data"), self:ToEnum("Skin"), self:ToEnum("Name")
                        if ref[dataKey] then
                            ref[dataKey][skinKey] = eq.Skin
                            ref[dataKey][nameKey] = eq.Skin.Name
                        elseif ref.Data then
                            ref.Data.Skin = eq.Skin
                            ref.Data.Name = eq.Skin.Name
                        end
                    end)
                end
                local a, b, c = orig(self, ref)
                constructing = nil
                return a, b, c
            end
        end) then done[#done + 1] = "_CreateViewModel" end

        if ClientViewModel and ReplicatedClass and patch(ClientViewModel, "new", function(orig)
            return function(replicated, clientItem)
                local owner = clientItem and clientItem.ClientFighter and clientItem.ClientFighter.Player
                local weaponName = constructing or (clientItem and clientItem.Name)
                local eq = equipped[weaponName]
                if Sk.Enabled and owner == LP and eq and eq.Skin then
                    pcall(function()
                        local dataKey = ReplicatedClass:ToEnum("Data")
                        replicated[dataKey] = replicated[dataKey] or {}
                        replicated[dataKey][ReplicatedClass:ToEnum("Skin")] = eq.Skin
                    end)
                end
                return orig(replicated, clientItem)
            end
        end) then done[#done + 1] = "ClientViewModel.new" end

        if ItemLibrary and patch(ItemLibrary, "GetViewModelImageFromWeaponData", function(orig)
            return function(self, weaponData, highRes)
                if Sk.Enabled and weaponData then
                    local eq = equipped[weaponData.Name]
                    if eq and eq.Skin and weaponData.Skin == eq.Skin then
                        local info = self.ViewModels and self.ViewModels[eq.Skin.Name]
                        if info then return info[highRes and "ImageHighResolution" or "Image"] or info.Image end
                    end
                end
                return orig(self, weaponData, highRes)
            end
        end) then done[#done + 1] = "ViewModelImage" end

        skinStat.hook = "нет hookmetamethod"
        if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
            local equipRemote = path(ReplicatedStorage, "Remotes", "Data", "EquipCosmetic")
            if equipRemote then
                local old
                local hook = function(self, ...)
                    if self == equipRemote and Sk.Enabled and getnamecallmethod() == "FireServer" then
                        local a1, a2, a3 = ...
                        if a2 == "Skin" then
                            local real = realGet and realGet(DataController, "CosmeticInventory")
                            local owned = type(real) == "table" and type(a3) == "string" and real[a3] ~= nil
                            if not owned then
                                if a3 == nil or a3 == "None" or a3 == "" then
                                    equipped[a1] = nil
                                elseif isSkin(a3) then
                                    local c = cloneCosmetic(a3)
                                    if c then equipped[a1] = {Skin = c} end
                                end
                                task.defer(function()
                                    pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
                                    refreshEquipped()
                                    save()
                                end)
                                return
                            end
                        end
                    end
                    return old(self, ...)
                end
                local wrapped = newcclosure and newcclosure(hook) or hook
                local ok, res = pcall(hookmetamethod, game, "__namecall", wrapped)
                if ok and res then
                    old = res
                    skinStat.hook = "OK (обычный выбор скина в игре тоже работает)"
                else
                    skinStat.hook = "не удалось"
                end
            else
                skinStat.hook = "ремоут EquipCosmetic не найден"
            end
        end

        skinStat.patched = table.concat(done, ", ")
        loadSaved()
        refreshEquipped()
        return true
    end

    S.Skins.On = function(on)
        if on then
            if installed or installing then return end
            installing = true
            task.spawn(function()
                local tries = 0
                while Alive and Sk.Enabled and not installed and tries < 30 do
                    tries = tries + 1
                    skinStat.state = "установка... (" .. tries .. ")"
                    local ok, res = pcall(install)
                    if ok and res then installed = true break end
                    if not ok then skinStat.err = tostring(res) end
                    task.wait(2)
                end
                installing = false
                skinStat.state = installed and "активно" or ("не удалось: " .. tostring(skinStat.err))
            end)
        else
            for i = #restores, 1, -1 do pcall(restores[i]) end
            restores = {}
            installed = false
            skinStat.state = "выключено"
        end
    end

    S.Skins.Weapons = function()
        local out, seen = {}, {}
        local function add(n)
            if type(n) == "string" and n ~= "" and not seen[n] then seen[n] = true out[#out + 1] = n end
        end
        if installed then
            local inv = realGet and realGet(DataController, "WeaponInventory")
            if type(inv) == "table" then for k in pairs(inv) do add(k) end end
            if ItemLibrary and type(ItemLibrary.Items) == "table" then for k in pairs(ItemLibrary.Items) do add(k) end end
        end
        table.sort(out)
        skinStat.weapons = #out
        return out
    end

    S.Skins.List = function(weapon)
        local out = {}
        if not installed then return out end
        for name, c in pairs(CosmeticLibrary.Cosmetics) do
            if type(c) == "table" and c.Type == "Skin" then out[#out + 1] = name end
        end
        table.sort(out)
        skinStat.skins = #out
        if weapon and not Sk.ShowAll then
            local wl = string.lower(weapon)
            local f = {}
            for _, name in ipairs(out) do
                local hit = string.find(string.lower(name), wl, 1, true) ~= nil
                if not hit then
                    for _, v in pairs(CosmeticLibrary.Cosmetics[name]) do
                        if type(v) == "string" and string.lower(v) == wl then hit = true break end
                    end
                end
                if hit then f[#f + 1] = name end
            end
            if #f > 0 then return f end
        end
        return out
    end

    S.Skins.Apply = function(weapon, skin)
        if not installed then return false, "сначала включи Unlock all skins" end
        if not weapon then return false, "выбери оружие" end
        if skin then
            local c = cloneCosmetic(skin)
            if not c then return false, "скин не найден" end
            equipped[weapon] = {Skin = c}
        else
            equipped[weapon] = nil
        end
        pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
        refreshEquipped()
        save()
        return true
    end

    S.Skins.ClearAll = function()
        equipped = {}
        if installed then pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end) end
        refreshEquipped()
        save()
    end

    S.Skins.Dump = function()
        local lines = {}
        if not installed then return "не установлено" end
        local n = 0
        for name, c in pairs(CosmeticLibrary.Cosmetics) do
            if type(c) == "table" and c.Type == "Skin" then
                n = n + 1
                if n <= 3 then
                    local keys = {}
                    for k, v in pairs(c) do keys[#keys + 1] = tostring(k) .. "=" .. (type(v) == "string" and v or type(v)) end
                    lines[#lines + 1] = "skin " .. name .. " {" .. table.concat(keys, ", ") .. "}"
                end
            end
        end
        local w = S.Skins.Weapons()
        lines[#lines + 1] = "weapons(" .. #w .. "): " .. table.concat(w, ", ", 1, math.min(#w, 12))
        return table.concat(lines, "\n")
    end

    Unloaders[#Unloaders + 1] = function() S.Skins.On(false) end
end


local TabAim = addTab("Aim", 83752373575368)
local TabVis = addTab("Visuals", 127234874352422)
local TabPlayer = addTab("Player", 114567720540659)
local TabMisc = addTab("Misc", 85345725497834)
local TabSkins = addTab("Skins", 105634041692696)
local TabSet = addTab("Settings", 123222732420633)

local win2Label, bhopLabel, godLabel, jumpLabel, skinLabel, skinSel, skinEq, aimLabel, spinLabel, speedLabel, bpLabel, antiLabel, weaponLabel, deviceLabel, espLabel, dbgLabel, winLabel
do
    local g = group(TabAim.L, "Aimbot")
    Toggle(g, "Enabled", S.Aim, "Enabled", function(on) notify("Aimbot " .. (on and "ON" or "OFF")) end)
    Choice(g, "Mode", {"Silent", "Aimbot", "Aim assist"}, S.Aim, "Mode")
    Choice(g, "Activation", {"Hold LMB", "Hold RMB", "Always"}, S.Aim, "Activation")
    Toggle(g, "Team check", S.Aim, "TeamCheck")
    Toggle(g, "Visible check", S.Aim, "VisCheck")
    Choice(g, "Hit part", {"Head", "Torso", "Random"}, S.Aim, "Part")
    Slider(g, "Field of view", 10, 800, S.Aim, "Fov", 5, "°")
    Slider(g, "Hit chance (silent)", 1, 100, S.Aim, "HitChance", 1, "%")
    Slider(g, "Smoothing (aimbot)", 1, 30, S.Aim, "Smooth", 1)
    Slider(g, "Sensitivity (aimbot)", 0.1, 3, S.Aim, "Gain", 0.1)
    Slider(g, "Max distance", 50, 3000, S.Aim, "MaxDist", 50)
    Toggle(g, "Show FOV circle", S.Aim, "ShowFov")
    Toggle(g, "Auto shot (fires when target is visible)", S.Aim, "AutoShot")
    Slider(g, "Auto shot delay", 30, 500, S.Aim, "ShotDelay", 10, "ms")

    local ga2 = group(TabAim.L, "Aim assist (legit)")
    label(ga2, "Mode Aim assist: a very light nudge like controller aim assist. It works only while you move the mouse yourself, always needs a visible target, pulls weaker near the edge of the field and never snaps. Auto shot is ignored in this mode.")
    Slider(ga2, "Assist field of view", 10, 250, S.Aim, "AssistFov", 5, "°")
    Slider(ga2, "Assist strength", 1, 50, S.Aim, "AssistStrength", 1, "%")
    Slider(ga2, "Max pull per frame", 1, 15, S.Aim, "AssistMaxStep", 1, "px")
    Toggle(ga2, "Only while I move the mouse", S.Aim, "AssistNeedMove")

    local g2 = group(TabAim.R, "Weapon")
    Toggle(g2, "Enabled", S.Weapon, "Enabled", function(on)
        notify("Weapon mods " .. (on and "ON" or "OFF"))
        S.Weapon.Toggled(on)
    end)
    Toggle(g2, "No recoil", S.Weapon, "Recoil")
    Slider(g2, "Recoil removed", 0, 100, S.Weapon, "RecoilPct", 5, "%")
    Toggle(g2, "No spread", S.Weapon, "Spread")
    Slider(g2, "Spread removed", 0, 100, S.Weapon, "SpreadPct", 5, "%")
    Slider(g2, "Auto rescan (0 = off)", 0, 30, S.Weapon, "Rescan", 1, "s")
    Toggle(g2, "Deep scan via getgc (may lag on Xeno)", S.Weapon, "Deep")
    Button(g2, "Rescan weapon now", function() runWeaponScan() end)
    weaponLabel = label(g2, "-")

    local gw = group(TabAim.L, "Auto win")
    label(gw, "Turns on only inside a match. The script picks the nearest enemy, aims at him, shoots and moves on to the next one when he dies.")
    Toggle(gw, "Enabled", S.Win, "Enabled", function(on) notify("Auto win " .. (on and "ON" or "OFF")) end)
    Toggle(gw, "Team check", S.Win, "TeamCheck")
    Toggle(gw, "Auto fire", S.Win, "Fire")
    Toggle(gw, "Fire only when visible", S.Win, "VisOnly")
    Toggle(gw, "Walk to target", S.Win, "Walk")
    Choice(gw, "Aim at", {"Head", "Torso"}, S.Win, "Part")
    Slider(gw, "Stop distance", 5, 80, S.Win, "Stop", 1, "m")
    Slider(gw, "Aim smoothing (1 = instant)", 1, 20, S.Win, "Smooth", 1)
    Slider(gw, "Max distance", 50, 3000, S.Win, "MaxDist", 50)
    winLabel = label(gw, "-")

    local gw2 = group(TabAim.R, "Auto win (through walls)")
    label(gw2, "Flies to the nearest enemy through walls (noclip), stands behind him, aims and shoots. No visibility check. Higher ban risk.")
    Toggle(gw2, "Enabled", S.Win2, "Enabled", function(on) notify("Auto win (walls) " .. (on and "ON" or "OFF")) end)
    Toggle(gw2, "Team check", S.Win2, "TeamCheck")
    Toggle(gw2, "Noclip while active", S.Win2, "Noclip")
    Toggle(gw2, "Auto fire", S.Win2, "Fire")
    Slider(gw2, "Distance behind target", 3, 30, S.Win2, "Dist", 1, "m")
    Slider(gw2, "Height offset", -5, 10, S.Win2, "Height", 1, "m")
    Slider(gw2, "Fly speed (0 = instant)", 0, 300, S.Win2, "Speed", 10, "/s")
    Slider(gw2, "Fire range", 10, 200, S.Win2, "FireRange", 5, "m")
    Slider(gw2, "Max distance", 50, 3000, S.Win2, "MaxDist", 50)
    win2Label = label(gw2, "-")

    local g3 = group(TabAim.R, "Status")
    aimLabel = label(g3, "-")
end

do
    local E = S.ESP
    local g = group(TabVis.L, "Players")
    Toggle(g, "Enabled", E, "Enabled", function(on) refreshEsp() notify("ESP " .. (on and "ON" or "OFF")) end)
    Toggle(g, "Team check", E, "TeamCheck", refreshEsp)
    Toggle(g, "Box", E, "Box")
    Choice(g, "Box style", {"Corner", "Full"}, E, "BoxStyle")
    Toggle(g, "Filled", E, "Filled")
    Toggle(g, "Chams (highlight)", E, "Chams", refreshEsp)
    Toggle(g, "Health bar", E, "Health")
    Toggle(g, "Skeleton", E, "Skeleton")
    Toggle(g, "Name", E, "Name")
    Toggle(g, "Info (hp / distance)", E, "Info")
    local g2 = group(TabVis.R, "Extra")
    Toggle(g2, "Tracers", E, "Tracers")
    Choice(g2, "Tracer from", {"Bottom", "Center", "Top"}, E, "TracerFrom")
    Choice(g2, "Color", {"Sakura", "White", "Red", "Cyan", "Green"}, E, "Color")
    Slider(g2, "Max distance", 100, 5000, E, "MaxDist", 50)
    Toggle(g2, "Scan NPC / bots", E, "Npc", refreshEsp)
    Toggle(g2, "Auto refresh", E, "AutoRefresh")
    Slider(g2, "Refresh interval", 1, 10, E, "Interval", 1, "s")
    Button(g2, "Refresh ESP now", refreshEsp)
    espLabel = label(g2, "-")
end

do
    local D = S.Device
    local g = group(TabMisc.L, "Device changer")
    label(g, "Other players see this device icon next to your name.")
    Choice(g, "Device", {"Auto", "MouseKeyboard", "Touch", "Gamepad", "VR"}, D, "Mode", function(m)
        if m == "Auto" then
            sendDevice(realDevice())
            notify("Device: real (" .. realDevice() .. ")")
        else
            sendDevice(m)
            notify("Device: " .. m)
        end
    end)
    Slider(g, "Resend interval", 1, 10, D, "Interval", 1, "s")
    Button(g, "Send now", function()
        local m = D.Mode == "Auto" and realDevice() or D.Mode
        sendDevice(m)
        notify("Sent: " .. m)
    end)
    deviceLabel = label(g, "-")
    local gs = group(TabMisc.R, "Spinbot")
    Toggle(gs, "Enabled", S.Spin, "Enabled", function(on) notify("Spinbot " .. (on and "ON" or "OFF")) end)
    Slider(gs, "Speed", 10, 1080, S.Spin, "Speed", 10, "°/s")
    Choice(gs, "Direction", {"Left", "Right"}, S.Spin, "Direction")
    Toggle(gs, "Local visual (see the spin yourself)", S.Spin, "Visual")
    spinLabel = label(gs, "-")
    local g2 = group(TabMisc.R, "Info")
    label(g2, "MouseKeyboard = PC, Touch = phone, Gamepad = console, VR = headset icon. The game re-sends the real value when input changes, so the script resends it on a timer.")
end

do
    local g = group(TabSkins.L, "Unlock skins")
    label(g, "Opens all weapon skins (not the weapons themselves). Visual, client side only: other players do not see it.")
    Toggle(g, "Unlock all skins", S.Skins, "Enabled", function(on)
        S.Skins.On(on)
        notify("Unlock skins " .. (on and "ON" or "OFF"))
    end)
    Toggle(g, "Show skins of all weapons", S.Skins, "ShowAll", function() if skinSel then skinSel.rebuild() end end)
    skinLabel = label(g, "-")
    Button(g, "Refresh lists", function()
        if skinSel then skinSel.rebuild() end
        if skinEq then skinEq.rebuild() end
    end)
    local chosenWeapon, chosenSkin = nil, nil
    Button(g, "Equip selected skin", function()
        local ok, err = S.Skins.Apply(chosenWeapon, chosenSkin)
        notify(ok and ("Skin equipped: " .. tostring(chosenSkin) .. ". Switch weapons to see it") or ("Skin: " .. tostring(err)))
    end)
    Button(g, "Remove skin from selected weapon", function()
        local ok, err = S.Skins.Apply(chosenWeapon, nil)
        notify(ok and "Skin removed" or ("Skin: " .. tostring(err)))
    end)
    Button(g, "Remove all my skins", function() S.Skins.ClearAll() notify("All skins removed") end)

    local g2 = group(TabSkins.R, "Weapon")
    skinEq = Picker(g2, "Weapon", function() return S.Skins.Weapons() end, function(name)
        chosenWeapon = name
        chosenSkin = nil
        if skinSel then skinSel.rebuild() end
    end, 110)
    local g3 = group(TabSkins.R, "Skin")
    skinSel = Picker(g3, "Skin (for the selected weapon)", function() return S.Skins.List(chosenWeapon) end, function(name) chosenSkin = name end, 170)
end

do
    local g = group(TabPlayer.L, "Speedhack")
    Toggle(g, "Enabled", S.Speed, "Enabled", function(on)
        if not on then S.Speed.Restore() end
        notify("Speedhack " .. (on and "ON" or "OFF"))
    end)
    Choice(g, "Method", {"CFrame", "Velocity", "WalkSpeed"}, S.Speed, "Method")
    Choice(g, "Activation", {"Always", "Hold Shift", "Hold Alt", "Hold Ctrl"}, S.Speed, "Activation")
    Slider(g, "Speed", 16, 150, S.Speed, "Speed", 1)
    speedLabel = label(g, "-")
    label(g, "CFrame moves the body itself and does not touch WalkSpeed (hardest for anti-cheat to see). WalkSpeed is the most visible method.")

    local gj = group(TabPlayer.L, "Jump power")
    Toggle(gj, "Enabled", S.Jump, "Enabled", function(on)
        if not on then S.Jump.Restore() end
        notify("Jump power " .. (on and "ON" or "OFF"))
    end)
    Choice(gj, "Method", {"Velocity", "Impulse", "JumpPower"}, S.Jump, "Method", function() S.Jump.Restore() end)
    Slider(gj, "Power", 30, 250, S.Jump, "Power", 5)
    Toggle(gj, "Infinite jump (jump in the air)", S.Jump, "Infinite")
    jumpLabel = label(gj, "-")
    label(gj, "Velocity and Impulse push the body up like a physics jump and never touch the JumpPower property, so there is nothing for the game to check (this is the bypass). JumpPower changes the property itself and is the easiest to catch.")

    local gh = group(TabPlayer.L, "Bunnyhop")
    Toggle(gh, "Enabled", S.Bhop, "Enabled", function(on) notify("Bunnyhop " .. (on and "ON" or "OFF")) end)
    Choice(gh, "Mode", {"Legit", "Rage"}, S.Bhop, "Mode")
    Slider(gh, "Max speed (Rage)", 20, 120, S.Bhop, "Max", 1)
    Slider(gh, "Acceleration (Rage)", 0, 80, S.Bhop, "Accel", 1)
    Slider(gh, "Air turn rate (Rage)", 1, 20, S.Bhop, "Turn", 1)
    bhopLabel = label(gh, "-")
    label(gh, "Hold Space: you jump again by yourself the moment you land. Legit only repeats the jump, your speed is not changed. Rage also turns and speeds you up in the air toward the direction you walk.")

    local gb = group(TabPlayer.L, "Bypass")
    local hooksOk = type(hookmetamethod) == "function" and type(getnamecallmethod) == "function"
    if hooksOk then
        Toggle(gb, "Enabled", S.Bypass, "Enabled", function() S.Bypass.Refresh() end)
        Toggle(gb, "Anti-kick", S.Bypass, "AntiKick")
        Toggle(gb, "Block anti-cheat remotes", S.Bypass, "BlockRemotes")
        Toggle(gb, "Spoof WalkSpeed / JumpPower (for the JumpPower method)", S.Bypass, "SpoofSpeed", function() S.Bypass.Refresh() end)
        bpLabel = label(gb, "-")
    else
        bpLabel = label(gb, "Unavailable in this executor: hookmetamethod / getnamecallmethod are missing (Xeno fails them in sUNC), so anti-kick and remote blocking cannot work.")
        label(gb, "What still helps: Speedhack with the CFrame method does not touch WalkSpeed, so there is nothing for the game to check.")
    end
    local gg = group(TabPlayer.R, "Godmode")
    Toggle(gg, "Enabled", S.God, "Enabled", function(on)
        if not on then S.God.Restore() end
        notify("Godmode " .. (on and "ON" or "OFF"))
    end)
    Toggle(gg, "Keep health at max (client side)", S.God, "Health")
    Toggle(gg, "Anti-knockback (clamp pushes)", S.God, "AntiKnock")
    Toggle(gg, "Anti-ragdoll / fall-down", S.God, "AntiRagdoll")
    Toggle(gg, "Void rescue (return to last safe spot)", S.God, "VoidSave")
    godLabel = label(gg, "-")
    label(gg, "Honest note: damage is decided on the server, so a script cannot make you truly immortal. Keep health only works if the game trusts the client. The label shows if the server overwrites it.")

    local ga = group(TabPlayer.R, "Anti")
    Toggle(ga, "Anti-freeze (Freeze Ray, stun)", S.Anti, "Freeze")
    Toggle(ga, "Restore WalkSpeed if it drops to 0", S.Anti, "FreezeSpeed")
    Toggle(ga, "Anti-flash (flashbang)", S.Anti, "Flash", function(on) S.Anti.FlashOn(on) end)
    Toggle(ga, "Anti-smoke", S.Anti, "Smoke", function(on) S.Anti.SmokeOn(on) end)
    Toggle(ga, "Anti-AFK", S.Anti, "AFK", function(on) S.Anti.AfkOn(on) end)
    antiLabel = label(ga, "-")

    local gv = group(TabPlayer.R, "View")
    Toggle(gv, "FOV changer", S.View, "FovOn")
    Slider(gv, "Field of view", 60, 120, S.View, "Fov", 1)
    Toggle(gv, "Fullbright", S.View, "Fullbright", function(on) S.View.Bright(on) end)
end

do
    local g = group(TabSet.L, "Menu")
    local keyBtn
    keyBtn = Button(g, "Menu key: Insert / =", function()
        keyBtn.Text = "press any key..."
        binding = true
        local c
        c = UserInputService.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                menuKeys = {[i.KeyCode] = true}
                binding = false
                keyBtn.Text = "Menu key: " .. i.KeyCode.Name
                c:Disconnect()
            end
        end)
    end)
    Choice(g, "Accent color", {"Skeet", "Sakura", "Ice", "Orange"}, S.UI, "Accent", setAccent)
    Toggle(g, "Watermark", S.UI, "Watermark", function(on) Watermark.Visible = on end)
    Toggle(g, "Notifications", S.UI, "Notify")
    Toggle(g, "Round menu button (phone)", S.UI, "MobileBtn", function(on) MobileBtn.Visible = on end)

    local gc = group(TabSet.R, "Executor")
    label(gc, "Executor: " .. executorName())
    label(gc, capsText())
    local g2 = group(TabSet.R, "Debug")
    dbgLabel = label(g2, "-")
    Button(g2, "Copy debug report", function()
        local L = {}
        local function add(s) L[#L + 1] = s end
        add("sakura.bypass | PlaceId " .. tostring(game.PlaceId))
        add("executor: " .. executorName())
        add("caps: " .. string.gsub(capsText(), "\n", ", "))
        add(string.format("aim: enabled=%s mode=%s activation=%s silentFrames=%d mouseFrames=%d lastTarget=%s mousemoverel=%s", tostring(S.Aim.Enabled), S.Aim.Mode, S.Aim.Activation, aimStat.silent, aimStat.mouse, tostring(aimStat.target), tostring(type(mousemoverel))))
        add("spin: " .. spinInfo)
        add("skins: " .. skinStat.state .. " | patched: " .. skinStat.patched .. " | hook: " .. skinStat.hook .. " | err: " .. tostring(skinStat.err))
        add(S.Skins.Dump())
        add(string.format("autoshot: shots=%d err=%s mouse1click=%s", aimStat.shots, tostring(aimStat.fireErr), type(mouse1click)))
        add("speed: " .. speedInfo)
        add("jump: " .. jumpInfo)
        add("bhop: " .. bhopInfo)
        add("god: " .. string.gsub(godInfo, "\n", " | "))
        add(string.format("assist: fov=%d strength=%d step=%d needMove=%s", S.Aim.AssistFov, S.Aim.AssistStrength, S.Aim.AssistMaxStep, tostring(S.Aim.AssistNeedMove)))
        add("autowin2: " .. win2Info)
        add(string.format("bypass: namecall=%s index=%s kicks=%d remotes=%d hookmetamethod=%s", bpInfo.nc, bpInfo.idx, bpInfo.kick, bpInfo.remote, type(hookmetamethod)))
        add(string.format("anti: freeze=%d flash=%d smoke=%d afk=%s", antiInfo.freeze, antiInfo.flash, antiInfo.smoke, antiInfo.afk))
        add("weapon: " .. weaponInfo)
        add(string.format("device: mode=%s remote=%s sent=%d last=%s err=%s real=%s", S.Device.Mode, devStat.remote, devStat.sent, devStat.last, tostring(devStat.err), realDevice()))
        add(string.format("esp: n=%d shown=%d rebuilt=%d", espStat.n, espStat.shown, espStat.rebuilt))
        add("me: team=" .. tostring(LP.Team) .. " attrs:")
        for k, v in pairs(LP:GetAttributes()) do add("   " .. tostring(k) .. "=" .. tostring(v)) end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local c = p.Character
                add(string.format("%s team=%s char=%s ally=%s", p.Name, tostring(p.Team), tostring(c ~= nil), tostring(isAlly(p, c))))
            end
        end
        for k, v in pairs(Errors) do add("ERR " .. k .. ": " .. v) end
        local text = table.concat(L, "\n")
        if setclipboard then
            pcall(setclipboard, text)
            notify("Debug report copied")
        else
            print(text)
            notify("No setclipboard — printed to console")
        end
    end)
    Button(g2, "Unload script", function() if ENV.SakuraBypassUnload then ENV.SakuraBypassUnload() end end)
end

selectTab(tabs[1])

task.spawn(function()
    local lastWm = ""
    while Alive do
        pcall(function()
            local me = LP.DisplayName ~= "" and LP.DisplayName or LP.Name
            local wm = string.format('<font color="%s">sakura</font>.bypass  |  %s  |  %d fps  |  %d ms', hex(T.Accent), me, fps, getPing())
            Watermark.Visible = S.UI.Watermark
            if S.UI.Watermark and wm ~= lastWm then
                lastWm = wm
                wmText.Text = wm
                Watermark.Size = UDim2.fromOffset(math.ceil(wmText.TextBounds.X) + 24, 22)
            end
            if not State.MenuOpen then return end
            aimLabel.Text = string.format("mode: %s | %s\nsilent frames: %d | mouse frames: %d | auto shots: %d\nlast target: %s%s", S.Aim.Mode, aimStat.active and "target locked" or "no target", aimStat.silent, aimStat.mouse, aimStat.shots, tostring(aimStat.target), aimStat.fireErr and ("\n" .. aimStat.fireErr) or "")
            spinLabel.Text = spinInfo
            speedLabel.Text = speedInfo
            jumpLabel.Text = jumpInfo
            bhopLabel.Text = bhopInfo
            godLabel.Text = godInfo
            if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
                bpLabel.Text = string.format("namecall: %s | index: %s\nblocked: kick %d, remotes %d", bpInfo.nc, bpInfo.idx, bpInfo.kick, bpInfo.remote)
            end
            antiLabel.Text = string.format("freeze fixes: %d | flash: %d | smoke: %d\nafk: %s", antiInfo.freeze, antiInfo.flash, antiInfo.smoke, antiInfo.afk)
            weaponLabel.Text = weaponInfo
            winLabel.Text = winInfo
            win2Label.Text = win2Info
            skinLabel.Text = string.format("status: %s\nskins: %d | weapons: %d\npatched: %s\nremote hook: %s\nequipped:\n%s", skinStat.state, skinStat.skins, skinStat.weapons, skinStat.patched, skinStat.hook, skinStat.equipped)
            deviceLabel.Text = string.format("remote: %s\nsent: %d | last: %s%s", devStat.remote, devStat.sent, devStat.last, devStat.err and ("\nerror: " .. devStat.err) or "")
            espLabel.Text = string.format("players: %d | shown: %d | rebuilt: %d", espStat.n, espStat.shown, espStat.rebuilt)
            local n = 0
            for _ in pairs(Errors) do n = n + 1 end
            dbgLabel.Text = n == 0 and "errors: none" or ("errors: " .. n .. " (see report)")
        end)
        task.wait(0.5)
    end
end)

local function unload()
    if not Alive then return end
    Alive = false
    for _, f in ipairs(Unloaders) do pcall(f) end
    for _, e in pairs(espEntries) do pcall(killEntry, e) end
    for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
    pcall(function() Gui:Destroy() end)
    pcall(function() EspGui:Destroy() end)
    ENV.SakuraBypassUnload = nil
end
ENV.SakuraBypassUnload = unload

if queue_on_teleport then
    pcall(function() queue_on_teleport('if isfile and isfile("sakura.bypass.lua") then loadstring(readfile("sakura.bypass.lua"))() end') end)
end

Main.Visible = true
State.MenuOpen = true
notify("sakura.bypass loaded - Insert or = to hide the menu")
