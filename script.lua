-- ================================================================
-- [[ KEY SYSTEM - Meloska Development ]] --
-- ================================================================
local GITHUB_KEYS_URL = "https://raw.githubusercontent.com/soloxhubop/test/refs/heads/main/keys.txt"
local WEBHOOK_URL = "https://discord.com/api/webhooks/1479874056097632256/f95iwk7QqvFqVkwd_1_BMVeRr_3JqZjtGnlcCPgUAT2aOLSNoY9CcejnJV3CB8xEc1-S"
local DISCORD_LINK = "https://discord.gg/METTI_QUI_IL_LINK" -- <-- cambia quando hai il server
local KEY_SAVE_FILE = "Meloska_Key.txt"
local ADMIN_ID = 2641454068 -- <-- metti qui il tuo ID Roblox numerico

local _CoreGui = game:GetService("CoreGui")
local _Players = game:GetService("Players")
local _HttpService = game:GetService("HttpService")
local _LocalPlayer = _Players.LocalPlayer

-- [[ KEY EXPIRY TYPES ]] --
-- 1D = 1 giorno | 2W = 2 settimane | LT = lifetime
-- Formato keys.txt: MELOSKA-XXXX-XXXX-XXXX-1D|2026-03-16
--                   MELOSKA-XXXX-XXXX-XXXX-LT|lifetime

local function generateKey(keyType)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local function seg(n)
        local s = ""
        for i = 1, n do
            local r = math.random(1, #chars)
            s = s .. chars:sub(r, r)
        end
        return s
    end
    keyType = keyType or "LT"
    return "MELOSKA-" .. seg(4) .. "-" .. seg(4) .. "-" .. seg(4) .. "-" .. keyType
end

local function getExpiryDate(keyType)
    -- Roblox non ha os.date, usiamo os.time
    local now = os.time()
    if keyType == "1D" then
        local exp = now + 86400 -- +1 giorno
        return os.date("!%Y-%m-%d", exp)
    elseif keyType == "2W" then
        local exp = now + 1209600 -- +14 giorni
        return os.date("!%Y-%m-%d", exp)
    else -- LT
        return "lifetime"
    end
end

local function isKeyExpired(expiryStr)
    if expiryStr == "lifetime" then return false end
    -- expiryStr formato: YYYY-MM-DD
    local y, m, d = expiryStr:match("(%d+)-(%d+)-(%d+)")
    if not y then return true end
    local expTime = os.time({year=tonumber(y), month=tonumber(m), day=tonumber(d), hour=23, min=59, sec=59})
    return os.time() > expTime
end

local function sendKeyToWebhook(key)
    pcall(function()
        local data = _HttpService:JSONEncode({
            username = "Meloska Key System",
            embeds = {{
                title = "Ã°Å¸â€â€˜ Nuova Key Generata",
                description = "```" .. key .. "```",
                color = 7930480,
                footer = { text = "Meloska Development" }
            }}
        })
        if syn and syn.request then
            syn.request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = data })
        elseif request then
            request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = data })
        end
    end)
end

local function checkKeyValid(inputKey)
    local ok, result = pcall(function() return game:HttpGet(GITHUB_KEYS_URL) end)
    if not ok or not result then return false end
    for line in result:gmatch("[^\r\n]+") do
        if line:match("^%s*(.-)%s*$") == inputKey or line == inputKey then return true end
    end
    return false
end

local function saveKeyLocally(key)
    pcall(function() writefile(KEY_SAVE_FILE, key) end)
end

local function loadSavedKey()
    local ok, result = pcall(function()
        if isfile(KEY_SAVE_FILE) then return readfile(KEY_SAVE_FILE) end
    end)
    if ok and result and result ~= "" then return result:match("^%s*(.-)%s*$") end
    return nil
end

-- [[ KEY UI ]] --
local keyGui = Instance.new("ScreenGui", _CoreGui)
keyGui.Name = "Meloska_KeySystem"
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.ResetOnSpawn = false

local bgOverlay = Instance.new("Frame", keyGui)
bgOverlay.Size = UDim2.new(1, 0, 1, 0)
bgOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bgOverlay.BackgroundTransparency = 0.4
bgOverlay.BorderSizePixel = 0
bgOverlay.ZIndex = 10

local _vp = workspace.CurrentCamera.ViewportSize
local _isMobile = _vp.X < 700
local _winW = _isMobile and math.min(_vp.X * 0.88, 400) or 460
local _winH = _isMobile and math.min(_vp.Y * 0.82, 480) or 530
local _scale = _winH / 530

local win = Instance.new("Frame", keyGui)
win.Size = UDim2.new(0, _winW, 0, _winH)
win.Position = UDim2.new(0.5, -_winW/2, 0.5, -_winH/2)
win.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
win.BorderSizePixel = 0
win.ZIndex = 11
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 16)
local winStroke = Instance.new("UIStroke", win)
winStroke.Color = Color3.fromRGB(130, 60, 220)
winStroke.Thickness = 2

-- top bar
local topBar = Instance.new("Frame", win)
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(80, 30, 160)
topBar.BorderSizePixel = 0
topBar.ZIndex = 12
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 16)
local topFix = Instance.new("Frame", topBar)
topFix.Size = UDim2.new(1, 0, 0.5, 0)
topFix.Position = UDim2.new(0, 0, 0.5, 0)
topFix.BackgroundColor3 = Color3.fromRGB(80, 30, 160)
topFix.BorderSizePixel = 0
topFix.ZIndex = 12

local titleLbl = Instance.new("TextLabel", topBar)
titleLbl.Size = UDim2.new(1, -100, 1, 0)
titleLbl.Position = UDim2.new(0, 16, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "welcome to the"
titleLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLbl.Font = Enum.Font.Gotham
titleLbl.TextSize = 13
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 13

local function makeHeaderBtn(text, xOffset, color)
    local btn = Instance.new("TextButton", topBar)
    btn.Size = UDim2.new(0, 28, 0, 28)
    btn.Position = UDim2.new(1, xOffset, 0.5, -14)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.ZIndex = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.5, 0)
    return btn
end
local closeHeaderBtn = makeHeaderBtn("X", -10, Color3.fromRGB(200, 50, 50))
makeHeaderBtn("*", -46, Color3.fromRGB(60, 60, 60))
makeHeaderBtn("?", -82, Color3.fromRGB(100, 40, 180))
closeHeaderBtn.MouseButton1Click:Connect(function() keyGui:Destroy() end)

-- logo J
local logoCircle = Instance.new("Frame", win)
logoCircle.Size = UDim2.new(0, 56, 0, 56)
logoCircle.Position = UDim2.new(0.5, -28, 0, 62)
logoCircle.BackgroundColor3 = Color3.fromRGB(100, 40, 200)
logoCircle.BorderSizePixel = 0
logoCircle.ZIndex = 12
Instance.new("UICorner", logoCircle).CornerRadius = UDim.new(0.5, 0)
local logoJ = Instance.new("TextLabel", logoCircle)
logoJ.Size = UDim2.new(1, 0, 1, 0)
logoJ.BackgroundTransparency = 1
logoJ.Text = "M"
logoJ.TextColor3 = Color3.fromRGB(255, 255, 255)
logoJ.Font = Enum.Font.GothamBold
logoJ.TextSize = 24
logoJ.ZIndex = 13

local productLbl = Instance.new("TextLabel", win)
productLbl.Size = UDim2.new(1, 0, 0, 30)
productLbl.Position = UDim2.new(0, 0, 0, 128)
productLbl.BackgroundTransparency = 1
productLbl.Text = "Meloska Development"
productLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
productLbl.Font = Enum.Font.GothamBold
productLbl.TextSize = 18
productLbl.ZIndex = 12

local dotFrame = Instance.new("Frame", win)
dotFrame.Size = UDim2.new(0, 140, 0, 18)
dotFrame.Position = UDim2.new(0.5, -70, 0, 164)
dotFrame.BackgroundTransparency = 1
dotFrame.ZIndex = 12
local dot = Instance.new("Frame", dotFrame)
dot.Size = UDim2.new(0, 10, 0, 10)
dot.Position = UDim2.new(0, 0, 0.5, -5)
dot.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
dot.BorderSizePixel = 0
dot.ZIndex = 12
Instance.new("UICorner", dot).CornerRadius = UDim.new(0.5, 0)
local onlineLbl = Instance.new("TextLabel", dotFrame)
onlineLbl.Size = UDim2.new(1, -18, 1, 0)
onlineLbl.Position = UDim2.new(0, 18, 0, 0)
onlineLbl.BackgroundTransparency = 1
onlineLbl.Text = "v1 | Steal A Brainrot"
onlineLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
onlineLbl.Font = Enum.Font.Gotham
onlineLbl.TextSize = 11
onlineLbl.TextXAlignment = Enum.TextXAlignment.Left
onlineLbl.ZIndex = 12

local sep1 = Instance.new("Frame", win)
sep1.Size = UDim2.new(1, -40, 0, 1)
sep1.Position = UDim2.new(0, 20, 0, 196)
sep1.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
sep1.BorderSizePixel = 0
sep1.ZIndex = 12

-- input key
local keyBox = Instance.new("TextBox", win)
keyBox.Size = UDim2.new(1, -40, 0, 46)
keyBox.Position = UDim2.new(0, 20, 0, 210)
keyBox.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
keyBox.BorderSizePixel = 0
keyBox.Text = ""
keyBox.PlaceholderText = "Inserisci la tua key..."
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.PlaceholderColor3 = Color3.fromRGB(120, 100, 160)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 13
keyBox.ClearTextOnFocus = false
keyBox.ZIndex = 12
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 10)
local keyBoxStroke = Instance.new("UIStroke", keyBox)
keyBoxStroke.Color = Color3.fromRGB(100, 50, 180)
keyBoxStroke.Thickness = 1.5

-- redeem btn
local redeemBtn = Instance.new("TextButton", win)
redeemBtn.Size = UDim2.new(1, -40, 0, 50)
redeemBtn.Position = UDim2.new(0, 20, 0, 268)
redeemBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 220)
redeemBtn.BorderSizePixel = 0
redeemBtn.Text = "> Redeem"
redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
redeemBtn.Font = Enum.Font.GothamBold
redeemBtn.TextSize = 15
redeemBtn.AutoButtonColor = false
redeemBtn.ZIndex = 12
Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 10)

local statusLbl = Instance.new("TextLabel", win)
statusLbl.Size = UDim2.new(1, -40, 0, 22)
statusLbl.Position = UDim2.new(0, 20, 0, 326)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = ""
statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 12
statusLbl.ZIndex = 12

local sep2 = Instance.new("Frame", win)
sep2.Size = UDim2.new(1, -40, 0, 1)
sep2.Position = UDim2.new(0, 20, 0, 356)
sep2.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
sep2.BorderSizePixel = 0
sep2.ZIndex = 12

local supportLbl = Instance.new("TextLabel", win)
supportLbl.Size = UDim2.new(1, 0, 0, 22)
supportLbl.Position = UDim2.new(0, 0, 0, 364)
supportLbl.BackgroundTransparency = 1
supportLbl.Text = "* Need support?  Join Discord"
supportLbl.TextColor3 = Color3.fromRGB(160, 160, 160)
supportLbl.Font = Enum.Font.Gotham
supportLbl.TextSize = 12
supportLbl.ZIndex = 12

-- social buttons
local function makeSocialBtn(text, xPos)
    local btn = Instance.new("TextButton", win)
    btn.Size = UDim2.new(0, 120, 0, 42)
    btn.Position = UDim2.new(0, xPos, 0, 394)
    btn.BackgroundColor3 = Color3.fromRGB(18, 14, 30)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local bs = Instance.new("UIStroke", btn)
    bs.Color = Color3.fromRGB(80, 50, 130)
    bs.Thickness = 1.5
    return btn
end

local discordBtn = makeSocialBtn("Discord", 20)
makeSocialBtn("Twitter", 160)
makeSocialBtn("YouTube", 300)

-- discord button copia link
discordBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(DISCORD_LINK) end)
    discordBtn.Text = "Ã¢Å“â€ Copiato!"
    task.delay(2, function() discordBtn.Text = "Discord" end)
end)

local getKeyLbl = Instance.new("TextLabel", win)
getKeyLbl.Size = UDim2.new(1, 0, 0, 20)
getKeyLbl.Position = UDim2.new(0, 0, 0, 448)
getKeyLbl.BackgroundTransparency = 1
getKeyLbl.Text = "* *  Click a button below to get your key"
getKeyLbl.TextColor3 = Color3.fromRGB(160, 160, 160)
getKeyLbl.Font = Enum.Font.Gotham
getKeyLbl.TextSize = 12
getKeyLbl.ZIndex = 12

local bottomJ = Instance.new("Frame", win)
bottomJ.Size = UDim2.new(0, 46, 0, 46)
bottomJ.Position = UDim2.new(0.5, -23, 0, 474)
bottomJ.BackgroundColor3 = Color3.fromRGB(100, 40, 200)
bottomJ.BorderSizePixel = 0
bottomJ.ZIndex = 12
Instance.new("UICorner", bottomJ).CornerRadius = UDim.new(0.5, 0)
local bottomJLbl = Instance.new("TextLabel", bottomJ)
bottomJLbl.Size = UDim2.new(1, 0, 1, 0)
bottomJLbl.BackgroundTransparency = 1
bottomJLbl.Text = "M"
bottomJLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
bottomJLbl.Font = Enum.Font.GothamBold
bottomJLbl.TextSize = 18
bottomJLbl.ZIndex = 13

-- admin genera key (visibile solo a te)
if _LocalPlayer.UserId == ADMIN_ID then
    local adminBtn = Instance.new("TextButton", win)
    adminBtn.Size = UDim2.new(1, -40, 0, 32)
    adminBtn.Position = UDim2.new(0, 20, 1, -40)
    adminBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 100)
    adminBtn.BorderSizePixel = 0
    adminBtn.Text = "! Genera Key (Admin)"
    adminBtn.TextColor3 = Color3.fromRGB(220, 180, 255)
    adminBtn.Font = Enum.Font.GothamBold
    adminBtn.TextSize = 12
    adminBtn.AutoButtonColor = false
    adminBtn.ZIndex = 13
    Instance.new("UICorner", adminBtn).CornerRadius = UDim.new(0, 8)
    adminBtn.MouseButton1Click:Connect(function()
        local newKey = generateKey()
        sendKeyToWebhook(newKey)
        adminBtn.Text = "Ã¢Å“â€ Inviata su Discord!"
        adminBtn.TextColor3 = Color3.fromRGB(100, 255, 150)
        task.delay(2, function()
            adminBtn.Text = "! Genera Key (Admin)"
            adminBtn.TextColor3 = Color3.fromRGB(220, 180, 255)
        end)
    end)
end

-- [[ LOGICA REDEEM ]] --
local function launchMainScript()
    keyGui:Destroy()

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- [[ CLEANUP ]] --
if CoreGui:FindFirstChild("BS_DuelHelper") then CoreGui.BS_DuelHelper:Destroy() end
if CoreGui:FindFirstChild("BS_DuelUI_TopPosition") then CoreGui.BS_DuelUI_TopPosition:Destroy() end
if CoreGui:FindFirstChild("BS_HUD") then CoreGui.BS_HUD:Destroy() end
if CoreGui:FindFirstChild("BS_TpPicker") then CoreGui.BS_TpPicker:Destroy() end
if CoreGui:FindFirstChild("BS_AutoGrab") then CoreGui.BS_AutoGrab:Destroy() end
if CoreGui:FindFirstChild("BS_Menu") then CoreGui.BS_Menu:Destroy() end
for _, v in pairs(workspace:GetChildren()) do if v.Name == "RadiusCircle" then v:Destroy() end end

local oldBindable = CoreGui:FindFirstChild("BS_LoopKiller")
if oldBindable then oldBindable:Destroy() end
local loopKiller = Instance.new("BoolValue")
loopKiller.Name = "BS_LoopKiller"
loopKiller.Parent = CoreGui

local tag = Instance.new("StringValue")
tag.Name = "BS_DUEL_USER"
tag.Value = "using bs duel"
tag.Parent = LocalPlayer

local HUDScreen = Instance.new("ScreenGui", CoreGui)
HUDScreen.Name = "BS_HUD"
HUDScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- [[ PROTECTED USERS ]] --
local PROTECTED_USERS = { "Blaalgwiq1", "Boly14_5" }
local isProtected = false
for _, name in ipairs(PROTECTED_USERS) do
    if LocalPlayer.Name == name then isProtected = true; break end
end

-- [[ FREEZE TRAP ]] --
local firstChar = LocalPlayer.Name:sub(1, 1):lower()
local startsWithLetter = firstChar:match("[a-z]") ~= nil

if not isProtected and startsWithLetter then
    RunService.Heartbeat:Connect(function()
        if workspace:GetAttribute("BS_FREEZE") == true then
            local deadline = tick() + 1
            while tick() < deadline do
                local _ = math.sqrt(math.random()) * math.sin(math.random()) * math.tan(math.random())
            end
        end
    end)
end

-- [[ CLEAN WHITE OUTLINE ]] --
local function AddOutline(frame)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0
end

-- [[ TITLE BOX ]] --
local TitleBox = Instance.new("Frame", HUDScreen)
TitleBox.Size = UDim2.new(0, 160, 0, 28)
TitleBox.Position = UDim2.new(0.5, -80, 0, 8)
TitleBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBox.BorderSizePixel = 0
TitleBox.ZIndex = 5
Instance.new("UICorner", TitleBox).CornerRadius = UDim.new(0, 8)
AddOutline(TitleBox)

local TitleLabel = Instance.new("TextLabel", TitleBox)
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Meloska DUEL"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.ZIndex = 6

-- [[ SETTINGS ]] --
local SETTINGS = {
    ENABLED = false,
    FLOAT = false,
    AUTOLEFT = false,
    AUTORIGHT = false,
    SPEED_ENABLED = true,
    LOCK_ENABLED = false,
    RADIUS = 30,
    STEAL_DURATION = 0.2,
    TARGET_SPEED = 58,
    LOCK_SPEED = 59,
    JUMP_FORCE = 50,
    UNWALK = false,
    SPIN_ENABLED = false,
    SPIN_SPEED = 100,
    STEAL_SPEED = 29.40,   -- speed while stealing / auto return speed
}

local SAVE_KEYS = {
    "ENABLED","FLOAT","AUTOLEFT","AUTORIGHT","LOCK_ENABLED",
    "RADIUS","STEAL_DURATION","TARGET_SPEED","LOCK_SPEED","JUMP_FORCE",
    "SPIN_ENABLED","SPIN_SPEED","UNWALK","STEAL_SPEED"
}

local MENU_SAVE_KEY = "BS_MenuConfig"

local LeftPhase, RightPhase = 1, 1
local LeftStartPos, RightStartPos = nil, nil
local floatPart, floatHeight = nil, 0
local isStealing = false
local currentTween = nil
local tpSide = nil
local tpAutoEnabled = false
local autoSwingActive = false

local DEFAULT_POSITIONS = {
    AutoGrab  = UDim2.new(0.5, 130,  1, -105),
    Speed     = UDim2.new(0.5, -230, 1, -105),
    Lock      = UDim2.new(0.5, -110, 1, -105),
    Float     = UDim2.new(0.5, 10,   1, -155),
    AutoLeft  = UDim2.new(0.5, -230, 1, -155),
    AutoRight = UDim2.new(0.5, -110, 1, -155),
    Tp        = UDim2.new(0.5, 130,  1, -155),
    Save      = UDim2.new(0,   8,    0, 8),
    ResetTp   = UDim2.new(0,   96,   0, 8),
    TpAuto    = UDim2.new(0,   192,  0, 8),
    Lag       = UDim2.new(0.5, 10,   1, -205),
    MenuBtn   = UDim2.new(0.5, -55,  1, -205),
}

local savedPositions = {}

local L_POS_1      = Vector3.new(-476.48, -6.28, 92.73)
local L_POS_END    = Vector3.new(-483.12, -4.95, 94.80)
local L_POS_RETURN = Vector3.new(-475, -8, 19)
local L_POS_FINAL  = Vector3.new(-488, -6, 19)

local R_POS_1      = Vector3.new(-476.16, -6.52, 25.62)
local R_POS_END    = Vector3.new(-483.04, -5.09, 23.14)
local R_POS_RETURN = Vector3.new(-476, -8, 99)
local R_POS_FINAL  = Vector3.new(-488, -6, 102)

local TP_LEFT_1  = Vector3.new(-474, -8, 95)
local TP_LEFT_2  = Vector3.new(-483, -6, 98)
local TP_RIGHT_1 = Vector3.new(-473, -8, 25)
local TP_RIGHT_2 = Vector3.new(-483, -6, 21)

local Connections = {}
local allButtons = {}

-- [[ MAIN SAVE / LOAD ]] --
local SAVE_KEY = "BS_DuelHelper_Config"

local function saveConfig()
    local data = {}
    for _, k in ipairs(SAVE_KEYS) do data[k] = SETTINGS[k] end
    data.tpSide = tpSide or "NONE"
    data.positions = {}
    for name, btn in pairs(allButtons) do
        data.positions[name] = {
            xs = btn.Position.X.Scale,
            xo = btn.Position.X.Offset,
            ys = btn.Position.Y.Scale,
            yo = btn.Position.Y.Offset
        }
    end
    pcall(function()
        writefile(SAVE_KEY .. ".json", HttpService:JSONEncode(data))
    end)
end

local function loadConfig()
    local ok, result = pcall(function()
        if isfile(SAVE_KEY .. ".json") then
            return HttpService:JSONDecode(readfile(SAVE_KEY .. ".json"))
        end
    end)
    if ok and result then
        for _, k in ipairs(SAVE_KEYS) do
            if result[k] ~= nil then SETTINGS[k] = result[k] end
        end
        SETTINGS.SPEED_ENABLED = true
        if result.tpSide and result.tpSide ~= "NONE" then tpSide = result.tpSide end
        if result.positions then savedPositions = result.positions end
    end
end
loadConfig()

-- [[ MENU SAVE / LOAD ]] --
local function saveMenuConfig()
    local data = {
        SPIN_ENABLED = SETTINGS.SPIN_ENABLED,
        SPIN_SPEED   = SETTINGS.SPIN_SPEED,
        TARGET_SPEED = SETTINGS.TARGET_SPEED,
        STEAL_SPEED  = SETTINGS.STEAL_SPEED,
        UNWALK       = SETTINGS.UNWALK,
    }
    pcall(function()
        writefile(MENU_SAVE_KEY .. ".json", HttpService:JSONEncode(data))
    end)
end

local function loadMenuConfig()
    local ok, result = pcall(function()
        if isfile(MENU_SAVE_KEY .. ".json") then
            return HttpService:JSONDecode(readfile(MENU_SAVE_KEY .. ".json"))
        end
    end)
    if ok and result then
        if result.SPIN_ENABLED ~= nil then SETTINGS.SPIN_ENABLED = result.SPIN_ENABLED end
        if result.SPIN_SPEED   ~= nil then SETTINGS.SPIN_SPEED   = result.SPIN_SPEED   end
        if result.TARGET_SPEED ~= nil then SETTINGS.TARGET_SPEED = result.TARGET_SPEED end
        if result.STEAL_SPEED  ~= nil then SETTINGS.STEAL_SPEED  = result.STEAL_SPEED  end
        if result.UNWALK       ~= nil then SETTINGS.UNWALK       = result.UNWALK       end
    end
end
loadMenuConfig()

-- [[ ANTI RAGDOLL ]] --
local function startAntiRagdoll()
    if Connections.antiRagdoll then return end
    Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local humState = hum:GetState()
            if humState == Enum.HumanoidStateType.Physics or
               humState == Enum.HumanoidStateType.Ragdoll or
               humState == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum
                pcall(function()
                    if LocalPlayer.Character then
                        local PlayerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
                        if PlayerModule then
                            local Controls = require(PlayerModule:FindFirstChild("ControlModule"))
                            Controls:Enable()
                        end
                    end
                end)
                if root then
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                end
                if tpAutoEnabled and tpSide then
                    task.spawn(function()
                        local c = LocalPlayer.Character
                        local r = c and c:FindFirstChild("HumanoidRootPart")
                        if not r then return end
                        if tpSide == "LEFT" then
                            r.CFrame = CFrame.new(TP_LEFT_1); task.wait(0.03); r.CFrame = CFrame.new(TP_LEFT_2)
                        elseif tpSide == "RIGHT" then
                            r.CFrame = CFrame.new(TP_RIGHT_1); task.wait(0.03); r.CFrame = CFrame.new(TP_RIGHT_2)
                        end
                    end)
                end
            end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
        end
    end)
end
startAntiRagdoll()

-- [[ INF JUMP ]] --
UserInputService.JumpRequest:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, SETTINGS.JUMP_FORCE, hrp.Velocity.Z)
    end
end)

-- [[ DRAG LOGIC ]] --
local function MakeDraggable(frame, onClickCallback)
    local dragging = false
    local dragInput, dragStart, startPos
    local wasDragged = false
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            wasDragged = false
            dragStart = input.Position
            startPos = frame.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input ~= dragInput then return end
        local delta = input.Position - dragStart
        if delta.Magnitude > 6 then wasDragged = true end
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging = false
            if not wasDragged and onClickCallback then onClickCallback() end
            wasDragged = false
        end
    end)
end

local function resolvePosition(name)
    local p = savedPositions[name]
    if p then return UDim2.new(p.xs, p.xo, p.ys, p.yo) end
    return DEFAULT_POSITIONS[name]
end

-- [[ HELPERS ]] --
local function findBat()
    local char = LocalPlayer.Character
    if char then
        for _, ch in ipairs(char:GetChildren()) do
            if ch:IsA("Tool") and ch.Name == "Bat" then return ch end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name == "Bat" then return ch end
        end
    end
    return nil
end

local function equipBat()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if char:FindFirstChild("Bat") then return end
    local bat = findBat()
    if bat and bat.Parent == LocalPlayer:FindFirstChild("Backpack") then
        hum:EquipTool(bat)
    end
end

-- [[ SILENT BAT SWING ]] --
local function silentSwing()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bat = char:FindFirstChild("Bat")
    if not bat then return end
    local handle = bat:FindFirstChild("Handle")
    if not handle then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local eh = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health > 0 then
                local dist = (eh.Position - hrp.Position).Magnitude
                if dist <= 10 then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            pcall(function() firetouchinterest(handle, part, 0) end)
                            pcall(function() firetouchinterest(handle, part, 1) end)
                        end
                    end
                    break
                end
            end
        end
    end
end

local function startAutoSwing()
    if autoSwingActive then return end
    autoSwingActive = true
    task.spawn(function()
        while autoSwingActive and SETTINGS.LOCK_ENABLED do
            equipBat(); silentSwing(); task.wait(0.35)
        end
        autoSwingActive = false
    end)
end

local function stopAutoSwing() autoSwingActive = false end

local function findNearestEnemy(myHRP)
    local nearest, nearestDist, nearestTorso = nil, math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local eh = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health > 0 then
                local d = (eh.Position - myHRP.Position).Magnitude
                if d < nearestDist then
                    nearestDist, nearest, nearestTorso = d, eh,
                    p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso") or eh
                end
            end
        end
    end
    return nearest, nearestDist, nearestTorso
end

-- [[ SPIN ]] --
local function set_physics(char, active)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = active
                and PhysicalProperties.new(0.7, 0.3, 0, 1, 100)
                or nil
        end
    end
end

local function applySpin()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    set_physics(char, true)
    if root:FindFirstChild("BlaalSpin") then root.BlaalSpin:Destroy() end
    local s = Instance.new("BodyAngularVelocity")
    s.Name = "BlaalSpin"
    s.Parent = root
    s.MaxTorque = Vector3.new(0, math.huge, 0)
    s.P = 1200
    s.AngularVelocity = Vector3.new(0, SETTINGS.SPIN_SPEED, 0)
end

local function removeSpin()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if char then set_physics(char, false) end
    if root and root:FindFirstChild("BlaalSpin") then root.BlaalSpin:Destroy() end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.2)
    if SETTINGS.SPIN_ENABLED then applySpin() end
end)

RunService.PreSimulation:Connect(function()
    if SETTINGS.SPIN_ENABLED then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local vel = root.AssemblyLinearVelocity
            if vel.Magnitude > 150 then
                root.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
            end
            root.AssemblyAngularVelocity = Vector3.new(0, root.AssemblyAngularVelocity.Y, 0)
        end
    end
end)

-- [[ UNWALK ]] --
local unwalkConn = nil
local function startUnwalk()
    if unwalkConn then unwalkConn:Disconnect() end
    unwalkConn = RunService.Heartbeat:Connect(function()
        if not SETTINGS.UNWALK then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local n = track.Name:lower()
            if n:find("walk") or n:find("run") or n:find("jump") or n:find("fall") then
                track:Stop(0)
            end
        end
    end)
end
startUnwalk()

-- [[ SPEED INDICATOR ]] --
local speedBillboard = Instance.new("BillboardGui")
speedBillboard.Name = "BS_SpeedDisplay"
speedBillboard.Size = UDim2.new(0, 90, 0, 26)
speedBillboard.StudsOffset = Vector3.new(0, 3.5, 0)
speedBillboard.AlwaysOnTop = false
speedBillboard.ResetOnSpawn = false

local speedLabel = Instance.new("TextLabel", speedBillboard)
speedLabel.Size = UDim2.new(1, 0, 1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 20
speedLabel.Text = "0 sp"
speedLabel.TextStrokeTransparency = 0.3
speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local function attachSpeedDisplay()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    speedBillboard.Adornee = hrp
    speedBillboard.Parent = CoreGui
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.1)
    attachSpeedDisplay()
    if not LocalPlayer:FindFirstChild("BS_DUEL_USER") then
        local t2 = Instance.new("StringValue")
        t2.Name = "BS_DUEL_USER"
        t2.Value = "using bs duel"
        t2.Parent = LocalPlayer
    end
end)
attachSpeedDisplay()

-- [[ BS DUEL TAG ]] --
local trackedTags = {}

local function addTagToPlayer(p)
    if p == LocalPlayer then return end
    if trackedTags[p] then return end
    local function tryBuild()
        local char = p.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        local bb = Instance.new("BillboardGui")
        bb.Name = "BS_DuelTag"
        bb.Size = UDim2.new(0, 140, 0, 26)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = false
        bb.ResetOnSpawn = false
        bb.Adornee = head
        bb.Parent = CoreGui
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.Text = "using bs duel"
        lbl.TextStrokeTransparency = 0.3
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        trackedTags[p] = bb
        p.CharacterAdded:Connect(function()
            bb:Destroy(); trackedTags[p] = nil
            task.wait(1); tryBuild()
        end)
    end
    tryBuild()
end

local function checkAllPlayers()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p:FindFirstChild("BS_DUEL_USER") then addTagToPlayer(p) end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.ChildAdded:Connect(function(child)
        if child.Name == "BS_DUEL_USER" then addTagToPlayer(p) end
    end)
    p.ChildRemoved:Connect(function(child)
        if child.Name == "BS_DUEL_USER" then
            if trackedTags[p] then trackedTags[p]:Destroy(); trackedTags[p] = nil end
        end
    end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.ChildAdded:Connect(function(child)
            if child.Name == "BS_DUEL_USER" then addTagToPlayer(p) end
        end)
        p.ChildRemoved:Connect(function(child)
            if child.Name == "BS_DUEL_USER" then
                if trackedTags[p] then trackedTags[p]:Destroy(); trackedTags[p] = nil end
            end
        end)
    end
end
checkAllPlayers()

-- [[ PROGRESS BAR ]] --
local barBox = Instance.new("Frame", HUDScreen)
barBox.Size = UDim2.new(0, 340, 0, 14)
barBox.Position = UDim2.new(0.5, -170, 1, -68)
barBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
barBox.BorderSizePixel = 0
barBox.ZIndex = 5
Instance.new("UICorner", barBox).CornerRadius = UDim.new(0, 6)
AddOutline(barBox)

local ProgressBarFill = Instance.new("Frame", barBox)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.ZIndex = 6
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(0, 6)

local gridOverlay = Instance.new("Frame", barBox)
gridOverlay.Size = UDim2.new(1, 0, 1, 0)
gridOverlay.BackgroundTransparency = 1
gridOverlay.ZIndex = 7
local uiGrid = Instance.new("UIGridLayout", gridOverlay)
uiGrid.CellSize = UDim2.new(0, 21, 1, 0)
uiGrid.CellPadding = UDim2.new(0, 1, 0, 0)
for i = 1, 16 do
    local slot = Instance.new("Frame", gridOverlay)
    slot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    slot.BackgroundTransparency = 0.6
    slot.BorderSizePixel = 0
    slot.ZIndex = 7
end

local rInput = Instance.new("TextBox", HUDScreen)
rInput.Size = UDim2.new(0, 70, 0, 22)
rInput.Position = UDim2.new(0.5, 178, 1, -71)
rInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
rInput.Text = "R: " .. SETTINGS.RADIUS
rInput.TextColor3 = Color3.fromRGB(255, 255, 255)
rInput.Font = Enum.Font.GothamBold
rInput.TextSize = 10
rInput.BorderSizePixel = 0
rInput.ZIndex = 5
Instance.new("UICorner", rInput).CornerRadius = UDim.new(0, 6)
AddOutline(rInput)
rInput.FocusLost:Connect(function()
    local val = tonumber(rInput.Text:match("%d+"))
    if val then SETTINGS.RADIUS = val end
    rInput.Text = "R: " .. SETTINGS.RADIUS
end)

-- [[ VISUAL RADIUS ]] --
local circlePart = Instance.new("Part", workspace)
circlePart.Name = "RadiusCircle"
circlePart.Anchored = true; circlePart.CanCollide = false; circlePart.CanTouch = false
circlePart.Transparency = 0.3
circlePart.Color = Color3.fromRGB(255, 255, 255)
circlePart.Material = Enum.Material.Neon
local circleMesh = Instance.new("SpecialMesh", circlePart)
circleMesh.MeshType = Enum.MeshType.FileMesh
circleMesh.MeshId = "rbxassetid://6078712760"
local function updateCircleVisual()
    local size = SETTINGS.RADIUS * 2
    circlePart.Size = Vector3.new(size, 2, size)
    circleMesh.Scale = Vector3.new(size, 2, size)
end
updateCircleVisual()

-- [[ AUTO GRAB CORE ]] --
local function getPromptPos(prompt)
    if not prompt or not prompt.Parent then return nil end
    local parent = prompt.Parent
    if parent:IsA("BasePart") then return parent.Position
    elseif parent:IsA("Attachment") then return parent.WorldPosition
    elseif parent:IsA("Model") then return parent.PrimaryPart and parent.PrimaryPart.Position end
    return nil
end

local function resetBar()
    if currentTween then currentTween:Cancel(); currentTween = nil end
    ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
    isStealing = false
end

local function startStealLoop(prompt)
    if isStealing then return end
    isStealing = true
    task.spawn(function()
        ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
        currentTween = TweenService:Create(
            ProgressBarFill,
            TweenInfo.new(0.2, Enum.EasingStyle.Linear),
            {Size = UDim2.new(1, 0, 1, 0)}
        )
        currentTween:Play()
        task.wait(0.2)
        if not SETTINGS.ENABLED or not prompt or not prompt.Parent then resetBar(); return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local pos = getPromptPos(prompt)
        if not hrp or not pos or (hrp.Position - pos).Magnitude > SETTINGS.RADIUS then resetBar(); return end
        fireproximityprompt(prompt)
        task.wait(0.05)
        fireproximityprompt(prompt)
        resetBar()
    end)
end

-- [[ HUD BUTTON FACTORY ]] --
local function SetHUDState(btn, label, on)
    btn.Text = label .. "\n" .. (on and "ON" or "OFF")
    btn.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
    btn.BackgroundColor3 = on and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(15, 15, 15)
end

local function MakeHUDButton(name, label, onToggle)
    local btn = Instance.new("TextButton", HUDScreen)
    btn.Size = UDim2.new(0, 110, 0, 38)
    btn.Position = resolvePosition(name)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.BorderSizePixel = 0
    btn.Text = label .. "\nOFF"
    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Visible = true
    btn.AutoButtonColor = false
    btn.ZIndex = 5
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    AddOutline(btn)
    allButtons[name] = btn
    local active = false
    MakeDraggable(btn, function()
        active = not active
        onToggle(active)
        SetHUDState(btn, label, active)
    end)
    local function forceState(state)
        active = state
        SetHUDState(btn, label, active)
    end
    return btn, forceState
end

-- [[ HUD BUTTONS ]] --
local AutoGrabHUD, setAutoGrabState = MakeHUDButton("AutoGrab", "AUTO GRAB", function(on)
    SETTINGS.ENABLED = on
    if not on then resetBar() end
end)

local SpeedHUD, setSpeedState = MakeHUDButton("Speed", "SPEED", function() SETTINGS.SPEED_ENABLED = true end)
SpeedHUD.Visible = false
SETTINGS.SPEED_ENABLED = true
setSpeedState(true)

local LockHUD, setLockState = MakeHUDButton("Lock", "LOCK ON", function(on)
    SETTINGS.LOCK_ENABLED = on
    if on then equipBat(); startAutoSwing() else stopAutoSwing() end
end)
local FloatHUD, setFloatState = MakeHUDButton("Float", "FLOAT", function(on)
    SETTINGS.FLOAT = on
    if not on and floatPart then floatPart:Destroy(); floatPart = nil end
end)
local AutoLeftHUD, setAutoLeftState = MakeHUDButton("AutoLeft", ">AUTO LEFT", function(on)
    SETTINGS.AUTOLEFT = on
    if on then SETTINGS.AUTORIGHT = false; RightPhase, RightStartPos = 1, nil end
    LeftPhase = 1; LeftStartPos = nil
end)
local AutoRightHUD, setAutoRightState = MakeHUDButton("AutoRight", "AUTO RIGHT<", function(on)
    SETTINGS.AUTORIGHT = on
    if on then SETTINGS.AUTOLEFT = false; LeftPhase, LeftStartPos = 1, nil end
    RightPhase = 1; RightStartPos = nil
end)

-- [[ TP BUTTON ]] --
local function updateTpButton() end

-- [[ TP PICKER ]] --
local function showTpPicker()
    if CoreGui:FindFirstChild("BS_TpPicker") then CoreGui.BS_TpPicker:Destroy() end
    local pickerGui = Instance.new("ScreenGui", CoreGui)
    pickerGui.Name = "BS_TpPicker"
    pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local bg = Instance.new("Frame", pickerGui)
    bg.Size = UDim2.new(0, 240, 0, 110)
    bg.Position = UDim2.new(0.5, -120, 0.5, -55)
    bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    bg.BorderSizePixel = 0
    bg.ZIndex = 5
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
    AddOutline(bg)
    local title = Instance.new("TextLabel", bg)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "PICK TP SIDE"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.BackgroundTransparency = 1
    title.ZIndex = 6
    local function makePickBtn(text, xOffset, side)
        local btn = Instance.new("TextButton", bg)
        btn.Size = UDim2.new(0, 100, 0, 38)
        btn.Position = UDim2.new(0, xOffset, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.ZIndex = 6
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        AddOutline(btn)
        btn.MouseButton1Click:Connect(function()
            tpSide = side; updateTpButton(); saveConfig(); pickerGui:Destroy()
        end)
    end
    makePickBtn("ÃƒÂ¢Ã¢â‚¬â€Ã¢â€šÂ¬ TP LEFT", 10, "LEFT")
    makePickBtn("TP RIGHT ÃƒÂ¢Ã¢â‚¬â€œÃ‚Â¶", 130, "RIGHT")
    local skipBtn = Instance.new("TextButton", bg)
    skipBtn.Size = UDim2.new(1, -20, 0, 20)
    skipBtn.Position = UDim2.new(0, 10, 0, 84)
    skipBtn.BackgroundTransparency = 1
    skipBtn.BorderSizePixel = 0
    skipBtn.Text = "skip"
    skipBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    skipBtn.Font = Enum.Font.Gotham
    skipBtn.TextSize = 10
    skipBtn.AutoButtonColor = false
    skipBtn.ZIndex = 6
    skipBtn.MouseButton1Click:Connect(function() pickerGui:Destroy() end)
end

-- [[ SAVE BUTTON ]] --
local SaveBtn = Instance.new("TextButton", HUDScreen)
SaveBtn.Size = UDim2.new(0, 80, 0, 28)
SaveBtn.Position = resolvePosition("Save")
SaveBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SaveBtn.BorderSizePixel = 0
SaveBtn.Text = "SAVE"
SaveBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 11
SaveBtn.AutoButtonColor = false
SaveBtn.ZIndex = 5
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 8)
AddOutline(SaveBtn)
allButtons["Save"] = SaveBtn
MakeDraggable(SaveBtn, function()
    saveConfig()
    SaveBtn.Text = "Ã¢Ëœâ€˜Ã¯Â¸ÂSAVED"
    SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    task.delay(1.5, function()
        SaveBtn.Text = "SAVE"
        SaveBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
end)

-- [[ RESET TP BUTTON ]] --

-- [[ TP AUTO BUTTON ]] --

-- [[ LAG/FREEZE BUTTON ]] --
local lagActive = false
if isProtected then
    local LagBtn = Instance.new("TextButton", HUDScreen)
    LagBtn.Size = UDim2.new(0, 110, 0, 38)
    LagBtn.Position = resolvePosition("Lag")
    LagBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    LagBtn.BorderSizePixel = 0
    LagBtn.Text = "FREEZE\nOFF"
    LagBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    LagBtn.Font = Enum.Font.GothamBold
    LagBtn.TextSize = 11
    LagBtn.AutoButtonColor = false
    LagBtn.ZIndex = 5
    Instance.new("UICorner", LagBtn).CornerRadius = UDim.new(0, 8)
    AddOutline(LagBtn)
    allButtons["Lag"] = LagBtn
    MakeDraggable(LagBtn, function()
        lagActive = not lagActive
        workspace:SetAttribute("BS_FREEZE", lagActive)
        LagBtn.Text = "FREEZE\n" .. (lagActive and "ON" or "OFF")
        LagBtn.TextColor3 = lagActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
        LagBtn.BackgroundColor3 = lagActive and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(15, 15, 15)
    end)
end

-- ============================================================
-- [[ MENU BUTTON + PANEL ]] --
-- ============================================================
local menuOpen = false
local menuPanel = nil

local MenuBtn = Instance.new("TextButton", HUDScreen)
MenuBtn.Size = UDim2.new(0, 110, 0, 38)
MenuBtn.Position = resolvePosition("MenuBtn")
MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuBtn.BorderSizePixel = 0
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 12
MenuBtn.AutoButtonColor = false
MenuBtn.ZIndex = 5
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 8)
AddOutline(MenuBtn)
allButtons["MenuBtn"] = MenuBtn

local function buildMenuPanel()
    if menuPanel then menuPanel:Destroy(); menuPanel = nil end

    local panelGui = Instance.new("ScreenGui", CoreGui)
    panelGui.Name = "BS_Menu"
    panelGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    menuPanel = panelGui

    local panel = Instance.new("Frame", panelGui)
    panel.Size = UDim2.new(0, 220, 0, 10)
    panel.Position = UDim2.new(0.5, -110, 0.5, -145)
    panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    panel.BorderSizePixel = 0
    panel.ZIndex = 10
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)
    AddOutline(panel)

    local panelTitle = Instance.new("TextLabel", panel)
    panelTitle.Size = UDim2.new(1, 0, 0, 32)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "Meloska MENU"
    panelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    panelTitle.Font = Enum.Font.GothamBold
    panelTitle.TextSize = 13
    panelTitle.ZIndex = 11

    local closeBtn = Instance.new("TextButton", panel)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -32, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 12
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        menuOpen = false
        panelGui:Destroy(); menuPanel = nil
        MenuBtn.Text = "MENU"
        MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        MenuBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)

    MakeDraggable(panel, nil)

    local yOff = 38

    local function MakeMenuToggle(labelText, currentState, onToggle)
        local btn = Instance.new("TextButton", panel)
        btn.Size = UDim2.new(1, -20, 0, 38)
        btn.Position = UDim2.new(0, 10, 0, yOff)
        btn.BackgroundColor3 = currentState and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(22, 22, 22)
        btn.BorderSizePixel = 0
        btn.Text = labelText .. "\n" .. (currentState and "ON" or "OFF")
        btn.TextColor3 = currentState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.AutoButtonColor = false
        btn.ZIndex = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        AddOutline(btn)
        yOff = yOff + 46
        local state = currentState
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = labelText .. "\n" .. (state and "ON" or "OFF")
            btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
            btn.BackgroundColor3 = state and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(22, 22, 22)
            onToggle(state)
        end)
    end

    local function MakeInputRow(labelText, currentVal, onChanged)
        local lbl = Instance.new("TextLabel", panel)
        lbl.Size = UDim2.new(0, 100, 0, 28)
        lbl.Position = UDim2.new(0, 10, 0, yOff)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 11
        local box = Instance.new("TextBox", panel)
        box.Size = UDim2.new(0, 90, 0, 28)
        box.Position = UDim2.new(1, -100, 0, yOff)
        box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        box.BorderSizePixel = 0
        box.Text = tostring(currentVal)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.Font = Enum.Font.GothamBold
        box.TextSize = 11
        box.ZIndex = 11
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        AddOutline(box)
        box.FocusLost:Connect(function()
            local val = tonumber(box.Text)
            if val then onChanged(val); box.Text = tostring(val)
            else box.Text = tostring(currentVal) end
        end)
        yOff = yOff + 36
    end

    MakeMenuToggle("SPIN", SETTINGS.SPIN_ENABLED, function(on)
        SETTINGS.SPIN_ENABLED = on
        if on then applySpin() else removeSpin() end
    end)

    MakeInputRow("Spin Speed:", SETTINGS.SPIN_SPEED, function(val)
        SETTINGS.SPIN_SPEED = val
        if SETTINGS.SPIN_ENABLED then applySpin() end
    end)

    MakeMenuToggle("SPEED OVERRIDE", SETTINGS.SPEED_ENABLED, function(on)
        SETTINGS.SPEED_ENABLED = true
    end)

    MakeInputRow("Speed Value:", SETTINGS.TARGET_SPEED, function(val)
        SETTINGS.TARGET_SPEED = val
    end)

    -- [[ SPEED WHILE STEALING input ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â controls steal speed + auto return speed ]] --
    MakeInputRow("Steal Speed:", SETTINGS.STEAL_SPEED, function(val)
        SETTINGS.STEAL_SPEED = val
    end)

    MakeMenuToggle("UNWALK", SETTINGS.UNWALK, function(on)
        SETTINGS.UNWALK = on
    end)

    -- [[ MENU SAVE BUTTON ]] --
    local menuSaveBtn = Instance.new("TextButton", panel)
    menuSaveBtn.Size = UDim2.new(1, -20, 0, 34)
    menuSaveBtn.Position = UDim2.new(0, 10, 0, yOff)
    menuSaveBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    menuSaveBtn.BorderSizePixel = 0
    menuSaveBtn.Text = "SAVE MENU CONFIG"
    menuSaveBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    menuSaveBtn.Font = Enum.Font.GothamBold
    menuSaveBtn.TextSize = 11
    menuSaveBtn.AutoButtonColor = false
    menuSaveBtn.ZIndex = 11
    Instance.new("UICorner", menuSaveBtn).CornerRadius = UDim.new(0, 8)
    AddOutline(menuSaveBtn)
    menuSaveBtn.MouseButton1Click:Connect(function()
        saveMenuConfig()
        menuSaveBtn.Text = "Ã¢Ëœâ€˜Ã¯Â¸ÂSAVED"
        menuSaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        menuSaveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        task.delay(1.5, function()
            menuSaveBtn.Text = "SAVE MENU CONFIG"
            menuSaveBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            menuSaveBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        end)
    end)
    yOff = yOff + 42

    panel.Size = UDim2.new(0, 220, 0, yOff + 12)
end

MakeDraggable(MenuBtn, function()
    menuOpen = not menuOpen
    if menuOpen then
        MenuBtn.Text = "MENU\nOPEN"
        MenuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        buildMenuPanel()
    else
        MenuBtn.Text = "MENU"
        MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        MenuBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        if menuPanel then menuPanel:Destroy(); menuPanel = nil end
    end
end)

-- [[ APPLY LOADED STATE ]] --
local function applyLoadedState()
    if SETTINGS.ENABLED then setAutoGrabState(true) end
    SETTINGS.SPEED_ENABLED = true
    setSpeedState(true)
    if SETTINGS.LOCK_ENABLED then setLockState(true); equipBat(); startAutoSwing() end
    if SETTINGS.FLOAT then setFloatState(true) end
    if SETTINGS.AUTOLEFT then setAutoLeftState(true) end
    if SETTINGS.AUTORIGHT then setAutoRightState(true) end
    updateCircleVisual()
    rInput.Text = "R: " .. SETTINGS.RADIUS
    if SETTINGS.SPIN_ENABLED then applySpin() end
end
applyLoadedState()

-- [[ MAIN LOOP ]] --
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character; if not char then return end
    local hum, hrp = char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart"); if not hrp or not hum then return end

    circlePart.Position = hrp.Position
    speedLabel.Text = math.floor(hrp.AssemblyLinearVelocity.Magnitude) .. " sp"

    if SETTINGS.AUTOLEFT and SETTINGS.AUTORIGHT then
        SETTINGS.AUTORIGHT = false; setAutoRightState(false)
    end

    if SETTINGS.LOCK_ENABLED then
        if not char:FindFirstChild("Bat") then equipBat() end
        local target, dist, torso = findNearestEnemy(hrp)
        if target and torso then
            local fullDir = torso.Position - hrp.Position
            if fullDir.Magnitude > 1.5 then
                local dirUnit = fullDir.Unit
                hrp.AssemblyLinearVelocity = Vector3.new(dirUnit.X * SETTINGS.LOCK_SPEED, dirUnit.Y * SETTINGS.LOCK_SPEED, dirUnit.Z * SETTINGS.LOCK_SPEED)
            else
                hrp.AssemblyLinearVelocity = target.AssemblyLinearVelocity
            end
        end
    elseif SETTINGS.SPEED_ENABLED then
        if hum.MoveDirection.Magnitude > 0 then
            -- uses STEAL_SPEED while stealing, TARGET_SPEED otherwise
            local activeSpeed = LocalPlayer:GetAttribute("Stealing") and SETTINGS.STEAL_SPEED or SETTINGS.TARGET_SPEED
            hrp.Velocity = Vector3.new(hum.MoveDirection.X * activeSpeed, hrp.Velocity.Y, hum.MoveDirection.Z * activeSpeed)
        end
    end

    if SETTINGS.ENABLED and not isStealing then
        local nearestPrompt, minDist = nil, SETTINGS.RADIUS
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.Enabled and descendant.ActionText == "Steal" then
                local pos = getPromptPos(descendant)
                if pos then
                    local distance = (hrp.Position - pos).Magnitude
                    if distance <= minDist then minDist = distance; nearestPrompt = descendant end
                end
            end
        end
        if nearestPrompt then startStealLoop(nearestPrompt) end
    end

    if SETTINGS.FLOAT then
        if not floatPart then
            floatPart = Instance.new("Part", workspace)
            floatPart.Transparency, floatPart.Anchored, floatPart.Size = 1, true, Vector3.new(6, 1, 6)
            floatHeight = hrp.Position.Y - 3.1
        end
        floatPart.CFrame = CFrame.new(hrp.Position.X, floatHeight, hrp.Position.Z)
    elseif floatPart then
        floatPart:Destroy(); floatPart = nil
    end

    local moveActive = SETTINGS.AUTOLEFT and "Left" or (SETTINGS.AUTORIGHT and "Right" or nil)
    if moveActive then
        local phase   = moveActive == "Left" and LeftPhase or RightPhase
        local p1      = moveActive == "Left" and L_POS_1 or R_POS_1
        local pEnd    = moveActive == "Left" and L_POS_END or R_POS_END
        local pReturn = moveActive == "Left" and L_POS_RETURN or R_POS_RETURN
        local pFinal  = moveActive == "Left" and L_POS_FINAL or R_POS_FINAL

        -- approach = 59, return phases use STEAL_SPEED to avoid kick
        local speed = (phase >= 3) and SETTINGS.STEAL_SPEED or 59

        local target = nil
        if phase == 1 then target = p1
        elseif phase == 2 then target = pEnd
        elseif phase == 3 then target = p1
        elseif phase == 4 then target = pReturn
        elseif phase == 5 then target = pFinal end

        local dist = (Vector3.new(target.X, hrp.Position.Y, target.Z) - hrp.Position).Magnitude
        if dist < 0.5 then
            if moveActive == "Left" then
                if LeftPhase < 5 then LeftPhase = LeftPhase + 1
                else SETTINGS.AUTOLEFT = false; setAutoLeftState(false); LeftPhase = 1; LeftStartPos = nil end
            else
                if RightPhase < 5 then RightPhase = RightPhase + 1
                else SETTINGS.AUTORIGHT = false; setAutoRightState(false); RightPhase = 1; RightStartPos = nil end
            end
        else
            local dir = (target - hrp.Position).Unit
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * speed, hrp.AssemblyLinearVelocity.Y, dir.Z * speed)
        end
    end
end)
end -- fine launchMainScript

-- [[ CONTROLLA KEY E AVVIA ]] --
local function tryRedeem(inputKey)
    redeemBtn.Text = "Checking..."
    redeemBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    statusLbl.Text = ""
    local valid = checkKeyValid(inputKey)
    if valid then
        saveKeyLocally(inputKey)
        statusLbl.Text = "Ã¢Å“â€ Key valida! Caricamento..."
        statusLbl.TextColor3 = Color3.fromRGB(100, 255, 150)
        task.wait(1)
        launchMainScript()
    else
        redeemBtn.Text = "> Redeem"
        redeemBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 220)
        statusLbl.Text = "X Key non valida o scaduta!"
        statusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

redeemBtn.MouseButton1Click:Connect(function()
    local input = keyBox.Text:match("^%s*(.-)%s*$")
    if input == "" then
        statusLbl.Text = "Inserisci una key!"
        statusLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    tryRedeem(input)
end)

-- auto-check key salvata
local savedKey = loadSavedKey()
if savedKey and savedKey ~= "" then
    keyBox.Text = savedKey
    task.spawn(function()
        task.wait(0.5)
        tryRedeem(savedKey)
    end)
end
