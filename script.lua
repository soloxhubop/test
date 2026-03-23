local C3=Color3.fromRGB
local U2=UDim2.new
local U1=UDim.new
local IN=Instance.new
local V3=Vector3.new
local FGOTB=Enum.Font.GothamBold
local FGOT=Enum.Font.Gotham
local UIT=Enum.UserInputType
local HST=Enum.HumanoidStateType
local GITHUB_KEYS_URL = "https://raw.githubusercontent.com/soloxhubop/test2/refs/heads/main/keys.txt"
local WEBHOOK_URL = "https://discord.com/api/webhooks/1479874056097632256/f95iwk7QqvFqVkwd_1_BMVeRr_3JqZjtGnlcCPgUAT2aOLSNoY9CcejnJV3CB8xEc1-S"
local DISCORD_LINK = "https://discord.gg/METTI_QUI_IL_LINK"
local KEY_SAVE_FILE = "Meloska_Key.txt"
local ADMIN_ID = 2641454068
local ADMIN_NAME2 = "SKINLALAL5"
local _CoreGui = game:GetService("CoreGui")
local _Players = game:GetService("Players")
local _HttpService = game:GetService("HttpService")
local _UIS = game:GetService("UserInputService")
local _LocalPlayer = _Players.LocalPlayer
local function isAdmin()
  return _LocalPlayer.UserId == ADMIN_ID or _LocalPlayer.Name == ADMIN_NAME2
end
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
  return "MELOSKA-" .. seg(4) .. "-" .. seg(4) .. "-" .. seg(4) .. "-" .. (keyType or "LT")
end
local function getExpiryDate(keyType)
  local now = os.time()
  if keyType == "1D" then
    return os.date("!%Y-%m-%d", now + 86400)
  elseif keyType == "2W" then
    return os.date("!%Y-%m-%d", now + 1209600)
  else
    return "lifetime"
  end
end
local function isKeyExpired(expiryStr)
  if expiryStr == "lifetime" then return false end
  local y, m, d = expiryStr:match("(%d+)-(%d+)-(%d+)")
  if not y then return true end
  local expTime = os.time({year=tonumber(y), month=tonumber(m), day=tonumber(d), hour=23, min=59, sec=59})
  return os.time() > expTime
end
local function trimStr(s)
  return s:gsub("^%s+", ""):gsub("%s+$", "")
end
local function checkKeyValid(inputKey)
  local ok, result = pcall(function()
    return game:HttpGet(GITHUB_KEYS_URL)
  end)
  if not ok or not result then return false, "Errore connessione" end
  local clean = inputKey:match("^([^|]+)") or inputKey
  clean = trimStr(clean)
  for line in result:gmatch("[^\r\n]+") do
    line = trimStr(line)
    if line ~= "" and not line:match("^%-%-") then
      local key, expiry = line:match("^([^|]+)|(.+)$")
      if key then
        key = trimStr(key) expiry = trimStr(expiry)
        if key == clean then
          if isKeyExpired(expiry) then return false, "Key scaduta!" end
          return true, expiry
        end
      else
        if line == clean then return true, "lifetime" end
      end
    end
  end
  return false, "Key non valida!"
end
local function saveKeyLocally(key)
  pcall(function()
    writefile(KEY_SAVE_FILE, key)
  end)
end
local function loadSavedKey()
  local ok, result = pcall(function()
    if isfile(KEY_SAVE_FILE) then
      return readfile(KEY_SAVE_FILE)
    end
  end)
  if ok and result and result ~= "" then
    return trimStr(result)
  end
  return nil
end
local function sendKeyToWebhook(keyLine)
  pcall(function()
    local data = _HttpService:JSONEncode({
      username = "Meloska Key System", embeds = {{
        title = "Nuova Key Generata", description = "**Copia nel GitHub:**\n```" .. keyLine .. "```", color = 7930480, footer = { text = "Meloska Development" }
      }}
    })
    local reqOpts = {
      Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = data
    }
    if http_request then
      http_request(reqOpts)
    elseif request then
      request(reqOpts)
    elseif syn and syn.request then
      syn.request(reqOpts)
    elseif fluxus and fluxus.request then
      fluxus.request(reqOpts)
    end
  end)
end
if _CoreGui:FindFirstChild("Meloska_KeySystem") then
  _CoreGui.Meloska_KeySystem:Destroy()
end
local keyGui = IN("ScreenGui", _CoreGui)
keyGui.Name = "Meloska_KeySystem"
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.ResetOnSpawn = false
local _winW = 320
local _winH = 400
local win = IN("Frame", keyGui)
win.Size = U2(0, _winW, 0, _winH)
win.Position = U2(0.5, -160, 0.5, -200)
win.BackgroundColor3 = C3(8, 5, 18)
win.BackgroundTransparency = 0.05
win.ZIndex = 11
win.ClipsDescendants = true
IN("UICorner", win).CornerRadius = U1(0, 16)
local winStroke = IN("UIStroke", win)
winStroke.Color = C3(140, 60, 255)
winStroke.Thickness = 2
local topBar = IN("Frame", win)
topBar.Size = U2(1, 0, 0, 46)
topBar.BackgroundColor3 = C3(90, 30, 180)
topBar.ZIndex = 12
IN("UICorner", topBar).CornerRadius = U1(0, 16)
local titleLbl = IN("TextLabel", topBar)
titleLbl.Size = U2(1, -60, 1, 0)
titleLbl.Position = U2(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "welcome to the"
titleLbl.TextColor3 = C3(200, 200, 200)
titleLbl.Font = FGOT
titleLbl.TextSize = 12
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 13
local closeBtnKey = IN("TextButton", topBar)
closeBtnKey.Size = U2(0, 26, 0, 26)
closeBtnKey.Position = U2(1, -34, 0.5, -13)
closeBtnKey.BackgroundColor3 = C3(200, 50, 50)
closeBtnKey.Text = "X"
closeBtnKey.TextColor3 = C3(255, 255, 255)
closeBtnKey.Font = FGOTB
closeBtnKey.TextSize = 11
closeBtnKey.ZIndex = 13
IN("UICorner", closeBtnKey).CornerRadius = U1(0.5, 0)
closeBtnKey.MouseButton1Click:Connect(function()
  keyGui:Destroy()
end)
do
  local kDragging = false
  local kDragStart = nil
  local kStartPos = nil
  topBar.InputBegan:Connect(function(i)
    if i.UserInputType == UIT.MouseButton1 or i.UserInputType == UIT.Touch then
      kDragging = true kDragStart = i.Position kStartPos = win.Position
      i.Changed:Connect(function()
        if i.UserInputState == Enum.UserInputState.End then
          kDragging = false
        end
      end)
    end
  end)
  _UIS.InputChanged:Connect(function(i)
    if kDragging and (i.UserInputType == UIT.MouseMovement or i.UserInputType == UIT.Touch) then
      local d = i.Position - kDragStart
      win.Position = U2(kStartPos.X.Scale, kStartPos.X.Offset + d.X, kStartPos.Y.Scale, kStartPos.Y.Offset + d.Y)
    end
  end)
  _UIS.InputEnded:Connect(function(i)
    if i.UserInputType == UIT.MouseButton1 or i.UserInputType == UIT.Touch then
      kDragging = false
    end
  end)
end
if isAdmin() then
  local adminBtn = IN("TextButton", win)
  adminBtn.Size = U2(1, -20, 0, 28) adminBtn.Position = U2(0, 10, 0, 50) adminBtn.BackgroundColor3 = C3(70, 20, 140) adminBtn.Text = ">> Genera Key (Admin)" adminBtn.TextColor3 = C3(220, 180, 255) adminBtn.Font = FGOTB
  adminBtn.TextSize = 11 adminBtn.ZIndex = 13 IN("UICorner", adminBtn).CornerRadius = U1(0, 8)
  local adminStroke = IN("UIStroke", adminBtn)
  adminStroke.Color = C3(170, 80, 255) adminStroke.Thickness = 1.5
  adminBtn.MouseButton1Click:Connect(function()
    if keyGui:FindFirstChild("AdminPopup") then
      keyGui.AdminPopup:Destroy()
      return
    end
    local popup = IN("Frame", keyGui)
    popup.Name = "AdminPopup" popup.Size = U2(0, 240, 0, 200) popup.Position = U2(0.5, -120, 0.5, -100) popup.BackgroundColor3 = C3(10, 5, 22) popup.ZIndex = 50 IN("UICorner", popup).CornerRadius = U1(0, 14)
    local ps = IN("UIStroke", popup)
    ps.Color = C3(140, 60, 255) ps.Thickness = 2
    local pt = IN("TextLabel", popup)
    pt.Size = U2(1, -40, 0, 36) pt.Position = U2(0, 10, 0, 0) pt.BackgroundTransparency = 1 pt.Text = "Scegli tipo key" pt.TextColor3 = C3(220, 180, 255) pt.Font = FGOTB
    pt.TextSize = 14 pt.ZIndex = 51
    local pc = IN("TextButton", popup)
    pc.Size = U2(0, 26, 0, 26) pc.Position = U2(1, -30, 0, 5) pc.BackgroundColor3 = C3(200, 50, 50) pc.Text = "X" pc.TextColor3 = C3(255, 255, 255) pc.Font = FGOTB
    pc.TextSize = 11 pc.ZIndex = 52 IN("UICorner", pc).CornerRadius = U1(0.5, 0)
    pc.MouseButton1Click:Connect(function()
      popup:Destroy()
    end)
    local pStatus = IN("TextLabel", popup)
    pStatus.Size = U2(1, -20, 0, 20) pStatus.Position = U2(0, 10, 0, 172) pStatus.BackgroundTransparency = 1 pStatus.Text = "" pStatus.TextColor3 = C3(100, 255, 150) pStatus.Font = FGOT
    pStatus.TextSize = 11 pStatus.ZIndex = 51
    local keyTypes = {
      {"1 Giorno",    "1D", C3(180, 60, 60)}, {"2 Settimane", "2W", C3(60, 100, 200)}, {"Lifetime",    "LT", C3(120, 40, 240)}
    }
    for i, t in ipairs(keyTypes) do
      local b = IN("TextButton", popup)
      b.Size = U2(1, -20, 0, 36) b.Position = U2(0, 10, 0, 30 + (i - 1) * 44) b.BackgroundColor3 = t[3] b.Text = t[1] b.TextColor3 = C3(255, 255, 255) b.Font = FGOTB
      b.TextSize = 13 b.ZIndex = 51 IN("UICorner", b).CornerRadius = U1(0, 8)
      b.MouseButton1Click:Connect(function()
        local expiry = getExpiryDate(t[2])
        local newKey = generateKey(t[2])
        local keyLine = ""
        if expiry == "lifetime" then
          keyLine = newKey
        else
          keyLine = newKey .. "|" .. expiry
        end
        sendKeyToWebhook(keyLine) pStatus.Text = "Inviata su Discord!" b.Text = "Inviata!"
        task.delay(2, function()
          popup:Destroy()
        end)
      end)
    end
  end)
end
local productLbl = IN("TextLabel", win)
productLbl.Size = U2(1, 0, 0, 26)
productLbl.Position = U2(0, 0, 0, 142)
productLbl.BackgroundTransparency = 1
productLbl.Text = "Meloska Development"
productLbl.TextColor3 = C3(255, 255, 255)
productLbl.Font = FGOTB
productLbl.TextSize = 16
productLbl.ZIndex = 12
local keyBox = IN("TextBox", win)
keyBox.Size = U2(1, -30, 0, 42)
keyBox.Position = U2(0, 15, 0, 204)
keyBox.BackgroundColor3 = C3(15, 8, 30)
keyBox.Text = ""
keyBox.PlaceholderText = "Inserisci la tua key..."
keyBox.TextColor3 = C3(255, 255, 255)
keyBox.PlaceholderColor3 = C3(120, 100, 160)
keyBox.Font = FGOT
keyBox.TextSize = 12
keyBox.ClearTextOnFocus = false
keyBox.ZIndex = 12
IN("UICorner", keyBox).CornerRadius = U1(0, 10)
local kbs = IN("UIStroke", keyBox)
kbs.Color = C3(120, 50, 220)
kbs.Thickness = 1.5
local redeemBtn = IN("TextButton", win)
redeemBtn.Size = U2(1, -30, 0, 46)
redeemBtn.Position = U2(0, 15, 0, 254)
redeemBtn.BackgroundColor3 = C3(120, 40, 240)
redeemBtn.Text = "> Redeem"
redeemBtn.TextColor3 = C3(255, 255, 255)
redeemBtn.Font = FGOTB
redeemBtn.TextSize = 14
redeemBtn.ZIndex = 12
IN("UICorner", redeemBtn).CornerRadius = U1(0, 10)
local statusLbl = IN("TextLabel", win)
statusLbl.Size = U2(1, -30, 0, 22)
statusLbl.Position = U2(0, 15, 0, 308)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = ""
statusLbl.TextColor3 = C3(255, 100, 100)
statusLbl.Font = FGOT
statusLbl.TextSize = 11
statusLbl.ZIndex = 12
local btnW = math.floor((_winW - 40) / 3)
local discordBtn = IN("TextButton", win)
discordBtn.Size = U2(0, btnW, 0, 38)
discordBtn.Position = U2(0, 15, 0, 364)
discordBtn.BackgroundColor3 = C3(14, 8, 28)
discordBtn.Text = "Discord"
discordBtn.TextColor3 = C3(220, 220, 220)
discordBtn.Font = FGOTB
discordBtn.TextSize = 11
discordBtn.ZIndex = 12
IN("UICorner", discordBtn).CornerRadius = U1(0, 10)
discordBtn.MouseButton1Click:Connect(function()
  pcall(function()
    setclipboard(DISCORD_LINK)
  end)
  discordBtn.Text = "Copiato!"
  task.delay(2, function()
    discordBtn.Text = "Discord"
  end)
end)
local function launchMainScript()
  keyGui:Destroy()
  local CoreGui = game:GetService("CoreGui")
  local UserInputService = game:GetService("UserInputService")
  local RunService = game:GetService("RunService")
  local Players = game:GetService("Players")
  local TweenService = game:GetService("TweenService")
  local HttpService = game:GetService("HttpService")
  local LocalPlayer = Players.LocalPlayer
  local guiNames = {"BS_DuelHelper","BS_DuelUI_TopPosition","BS_HUD","BS_TpPicker","BS_Menu","BS_LoopKiller"}
  for _, n in ipairs(guiNames) do
    if CoreGui:FindFirstChild(n) then
      CoreGui[n]:Destroy()
    end
  end
  IN("BoolValue", CoreGui).Name = "BS_LoopKiller"
  local tag = IN("StringValue", LocalPlayer)
  tag.Name = "BS_DUEL_USER" tag.Value = "using bs duel"
  local HUDScreen = IN("ScreenGui", CoreGui)
  HUDScreen.Name = "BS_HUD" HUDScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling HUDScreen.ResetOnSpawn = false
  local function AddOutline(frame)
    local s = IN("UIStroke", frame)
    s.Color = C3(255, 255, 255) s.Thickness = 2 s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border s.Transparency = 0
  end
  local vp=workspace.CurrentCamera.ViewportSize
  local isTablet=(vp.X>=768 and UserInputService.TouchEnabled)
  local isMobile=(UserInputService.TouchEnabled and not isTablet)
  local scale=isMobile and 0.78 or (isTablet and 0.88 or 1.0)
  local BW=math.floor(110*scale)
  local BH=math.floor(44*scale)
  local LX=8
  local RX=-math.floor(118*scale)
  local BTEXT=math.floor(12*scale)
  local BGAP=math.floor(52*scale)
  local Y1=math.floor(60*scale)
  local Y2=Y1+BGAP
  local Y3=Y2+BGAP
  local Y4=Y3+BGAP
  local TitleBox = IN("Frame", HUDScreen)
  TitleBox.Size = U2(0, 200, 0, 42) TitleBox.Position = U2(0.5, -100, 0, 8) TitleBox.BackgroundColor3 = C3(15, 15, 15) TitleBox.ZIndex = 5 IN("UICorner", TitleBox).CornerRadius = U1(0, 8) AddOutline(TitleBox)
  local TitleLabel = IN("TextLabel", TitleBox)
  TitleLabel.Size = U2(1, 0, 0, 22) TitleLabel.Position = U2(0, 0, 0, 2) TitleLabel.BackgroundTransparency = 1 TitleLabel.Text = "Meloska DUEL" TitleLabel.TextColor3 = C3(255, 255, 255) TitleLabel.Font = FGOTB
  TitleLabel.TextSize = 13 TitleLabel.ZIndex = 6
  local InfoLabel = IN("TextLabel", TitleBox)
  InfoLabel.Size = U2(1, -8, 0, 14) InfoLabel.Position = U2(0, 4, 0, 25) InfoLabel.BackgroundTransparency = 1 InfoLabel.Text = "fps:-- | ping:-- | --" InfoLabel.TextColor3 = C3(180, 180, 180) InfoLabel.Font = FGOT
  InfoLabel.TextSize = math.floor(9*scale) InfoLabel.ZIndex = 6
  local function getDevice()
    local UIS2 = game:GetService("UserInputService")
    if UIS2.TouchEnabled and not UIS2.MouseEnabled then
      return "mobile"
    elseif UIS2.GamepadEnabled then
      return "console"
    else
      return "pc"
    end
  end
  local serverRegion = getDevice()
  local lastFPSUpdate = 0
  local fpsCount = 0
  local currentFPS = 0
  RunService.Heartbeat:Connect(function(dt)
    fpsCount = fpsCount + 1
    local now = tick()
    if now - lastFPSUpdate >= 1 then
      currentFPS = fpsCount fpsCount = 0 lastFPSUpdate = now
      local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
      local pingColor
      if ping < 80 then
        pingColor = "00ff88"
      elseif ping < 150 then
        pingColor = "ffcc00"
      else
        pingColor = "ff4444"
      end
      InfoLabel.Text = "fps:" .. currentFPS .. " | ping:" .. ping .. "ms | " .. serverRegion
      if ping < 80 then
        InfoLabel.TextColor3 = C3(100, 220, 150)
      elseif ping < 150 then
        InfoLabel.TextColor3 = C3(220, 180, 50)
      else
        InfoLabel.TextColor3 = C3(220, 80, 80)
      end
    end
  end)
  local SETTINGS = {
    ENABLED = false, FLOAT = false, AUTOLEFT = false, AUTORIGHT = false, SPEED_ENABLED = true, LOCK_ENABLED = false,
    STEAL_DURATION = 0.2, TARGET_SPEED = 58.5, LOCK_SPEED = 59, JUMP_FORCE = 58, UNWALK = false, SPIN_ENABLED = false,
    SPIN_SPEED = 100, STEAL_SPEED = 29, CHASE_SPEED = 37, OPTIMIZER = false, KEYBIND_GRAB = "None", KEYBIND_LOCK = "None",
    KEYBIND_LEFT = "None", KEYBIND_RIGHT = "None", KEYBIND_PLAY = "None", KEYBIND_TP = "None", KEYBIND_FLOAT = "None", KEYBIND_DROP = "None",
  }
  local SAVE_KEYS = {
    "ENABLED", "FLOAT", "AUTOLEFT", "AUTORIGHT", "LOCK_ENABLED", "STEAL_DURATION", "LOCK_SPEED", "JUMP_FORCE", "SPIN_ENABLED", "SPIN_SPEED", "UNWALK", "CHASE_SPEED", "OPTIMIZER"
  }
  local MENU_SAVE_KEY = "BS_MenuConfig"
  local patrolMode = "none"
  local currentWaypoint = 1
  local rightWaypoints = {
    V3(-473.04, -6.99, 29.71), V3(-483.57, -5.10, 18.74), V3(-475.00, -6.99, 26.43), V3(-474.67, -6.94, 105.48),
  }
  local leftWaypoints = {
    V3(-472.49, -7.00, 90.62), V3(-484.62, -5.10, 100.37), V3(-475.08, -7.00, 93.29), V3(-474.22, -6.96, 16.18),
  }
  local floatPart = nil
  local floatHeight = 0
  local isStealing = false
  local currentTween = nil
  local Cebo={} local BAT_CD=0.05 local lastSwing=0 local spamBatConn=nil local meleeConn=nil
  local L_POS_1      = V3(-476.48, -6.28, 92.73)
  local L_POS_END    = V3(-483.12, -4.95, 94.80)
  local L_POS_RETURN = V3(-475, -8, 19)
  local L_POS_FINAL  = V3(-488, -6, 19)
  local R_POS_1      = V3(-476.16, -6.52, 25.62)
  local R_POS_END    = V3(-483.04, -5.09, 23.14)
  local R_POS_RETURN = V3(-476, -8, 99)
  local R_POS_FINAL  = V3(-488, -6, 102)
  local Connections = {}
  local allButtons = {}
  local SAVE_KEY = "BS_DuelHelper_Config"
  local savedPositions = {}
  local function saveConfig()
    local data = {}
    for _, k in ipairs(SAVE_KEYS) do
      data[k] = SETTINGS[k]
    end
    data.positions = {}
    for name, btn in pairs(allButtons) do
      data.positions[name] = {
        xs = btn.Position.X.Scale, xo = btn.Position.X.Offset, ys = btn.Position.Y.Scale, yo = btn.Position.Y.Offset
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
        if result[k] ~= nil then
          SETTINGS[k] = result[k]
        end
      end
      SETTINGS.SPEED_ENABLED = true
      if result.positions then
        savedPositions = result.positions
      end
    end
  end
  loadConfig() SETTINGS.TARGET_SPEED = 58.5 SETTINGS.STEAL_SPEED = 29
  local function saveMenuConfig()
    local d = {
      SPIN_ENABLED = SETTINGS.SPIN_ENABLED, SPIN_SPEED   = SETTINGS.SPIN_SPEED, UNWALK       = SETTINGS.UNWALK
    }
    pcall(function()
      writefile(MENU_SAVE_KEY .. ".json", HttpService:JSONEncode(d))
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
      if result.UNWALK       ~= nil then SETTINGS.UNWALK       = result.UNWALK       end
    end
  end
  loadMenuConfig()
  local function resolvePosition(name)
    local p = savedPositions[name]
    if p then
      return U2(p.xs, p.xo, p.ys, p.yo)
    end
    local defaults = {
      Save      = U2(0,   8,   0,   8), Drop      = U2(0,   8,   0,  54), AutoGrab  = U2(0,   8,   0, 102), Lock      = U2(0,   8,   0, 150), Float     = U2(0,   8,   0, 198), AutoTP    = U2(0.5, -55, 0,  58),
      MenuBtn   = U2(1, -118,  0,   8), AutoLeft  = U2(1, -118,  0,  56), AutoRight = U2(1, -118,  0, 104),
    }
    if defaults[name] then
      return defaults[name]
    end
    return U2(0, 8, 0, 8)
  end
  local function startAntiRagdoll()
    if Connections.antiRagdoll then return end
    Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
      local char = LocalPlayer.Character
      if not char then return end
      local root = char:FindFirstChild("HumanoidRootPart")
      local hum = char:FindFirstChildOfClass("Humanoid")
      if hum then
        local st = hum:GetState()
        if st == HST.Physics or st == HST.Ragdoll or st == HST.FallingDown then
          hum:ChangeState(HST.Running)
          if workspace.CurrentCamera then
            workspace.CurrentCamera.CameraSubject = hum
          end
          if root then
            root.AssemblyLinearVelocity = V3(0, 0, 0) root.AssemblyAngularVelocity = V3(0, 0, 0)
          end
        end
      end
      for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Motor6D") and obj.Enabled == false then
          obj.Enabled = true
        end
      end
    end)
  end
  startAntiRagdoll()
  UserInputService.JumpRequest:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.AssemblyLinearVelocity = V3(
        hrp.AssemblyLinearVelocity.X, SETTINGS.JUMP_FORCE, hrp.AssemblyLinearVelocity.Z
      )
    end
  end)
  local function MakeDraggable(frame, onClickCallback)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local wasDragged = false
    frame.InputBegan:Connect(function(input)
      if input.UserInputType == UIT.MouseButton1 or input.UserInputType == UIT.Touch then
        dragging = true wasDragged = false dragStart = input.Position startPos = frame.Position dragInput = input
        input.Changed:Connect(function()
          if input.UserInputState == Enum.UserInputState.End then
            dragging = false
          end
        end)
      end
    end)
    UserInputService.InputChanged:Connect(function(input)
      if not dragging then return end
      if input ~= dragInput then return end
      local delta = input.Position - dragStart
      if delta.Magnitude > 6 then
        wasDragged = true
      end
      frame.Position = U2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)
    UserInputService.InputEnded:Connect(function(input)
      if input == dragInput then
        dragging = false
        if not wasDragged and onClickCallback then
          onClickCallback()
        end
        wasDragged = false
      end
    end)
  end
  local function findBat()
    local c=LocalPlayer.Character local bp=LocalPlayer:FindFirstChild("Backpack")
    if c then for _,ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    if bp then for _,ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    return nil
  end
  local function equipBat()
    local char=LocalPlayer.Character local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local bat=findBat() if bat and bat.Parent~=char then hum:EquipTool(bat) end
  end
  local function findNearestEnemy(myHRP)
    local nearest = nil
    local nearestDist = math.huge
    local nearestTorso = nil
    for _, p in ipairs(Players:GetPlayers()) do
      if p ~= LocalPlayer and p.Character then
        local eh = p.Character:FindFirstChild("HumanoidRootPart")
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if eh and hum and hum.Health > 0 then
          local d = (eh.Position - myHRP.Position).Magnitude
          if d < nearestDist then
            nearestDist = d nearest = eh nearestTorso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso") or eh
          end
        end
      end
    end
    return nearest, nearestDist, nearestTorso
  end
  local function startAutoSwing()
    equipBat()
    if spamBatConn then spamBatConn:Disconnect(); spamBatConn=nil end
    spamBatConn=RunService.Heartbeat:Connect(function()
      if not SETTINGS.LOCK_ENABLED then return end
      local c=LocalPlayer.Character if not c then return end
      local bat=findBat() if not bat then return end
      if bat.Parent~=c then bat.Parent=c end
      local now=tick() if now-lastSwing<BAT_CD then return end
      lastSwing=now pcall(function() bat:Activate() end)
    end)
    if meleeConn then meleeConn:Disconnect(); meleeConn=nil end
    local char=LocalPlayer.Character if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
    Cebo.Attach=Instance.new("Attachment",hrp) Cebo.Align=Instance.new("AlignOrientation",hrp) Cebo.Align.Attachment0=Cebo.Attach Cebo.Align.Mode=Enum.OrientationAlignmentMode.OneAttachment Cebo.Align.RigidityEnabled=true
    meleeConn=RunService.Heartbeat:Connect(function()
      if not SETTINGS.LOCK_ENABLED then return end
      local c2=LocalPlayer.Character if not c2 then return end
      local h=c2:FindFirstChild("HumanoidRootPart") local hum=c2:FindFirstChildOfClass("Humanoid")
      if not h or not hum then return end
      local target,dist,torso=findNearestEnemy(h)
      if target and torso then
        if Cebo.Align then
          Cebo.Align.Enabled=true Cebo.Align.CFrame=CFrame.lookAt(h.Position,V3(target.Position.X,h.Position.Y,target.Position.Z)) hum.AutoRotate=false
        end
        local fd=V3(torso.Position.X-h.Position.X,0,torso.Position.Z-h.Position.Z)
        if fd.Magnitude>1.5 then
          local u=fd.Unit
          h.AssemblyLinearVelocity=V3(u.X*SETTINGS.CHASE_SPEED,h.AssemblyLinearVelocity.Y,u.Z*SETTINGS.CHASE_SPEED)
        else
          h.AssemblyLinearVelocity=V3(target.AssemblyLinearVelocity.X,h.AssemblyLinearVelocity.Y,target.AssemblyLinearVelocity.Z)
        end
      else
        if Cebo.Align then Cebo.Align.Enabled=false end
        local h2=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h2 then h2.AutoRotate=true end
      end
    end)
  end
  local function stopAutoSwing()
    if spamBatConn then spamBatConn:Disconnect(); spamBatConn=nil end
    if meleeConn then meleeConn:Disconnect(); meleeConn=nil end
    if Cebo.Align then Cebo.Align:Destroy() end
    if Cebo.Attach then Cebo.Attach:Destroy() end
    Cebo={}
    local char=LocalPlayer.Character
    if char then local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum.AutoRotate=true end end
  end
  local function applySpin()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if root:FindFirstChild("BlaalSpin") then
      root.BlaalSpin:Destroy()
    end
    local s = IN("BodyAngularVelocity")
    s.Name = "BlaalSpin" s.Parent = root s.MaxTorque = V3(0, math.huge, 0) s.P = 1200 s.AngularVelocity = V3(0, SETTINGS.SPIN_SPEED, 0)
  end
  local function removeSpin()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if char then
      set_physics(char, false)
    end
    if root and root:FindFirstChild("BlaalSpin") then
      root.BlaalSpin:Destroy()
    end
  end
  LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.2)
    if SETTINGS.SPIN_ENABLED then
      applySpin()
    end
  end)
  RunService.PreSimulation:Connect(function()
    if SETTINGS.SPIN_ENABLED then
      local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if root then
        local vel = root.AssemblyLinearVelocity
        if vel.Magnitude > 150 then
          root.AssemblyLinearVelocity = V3(0, vel.Y, 0)
        end
        root.AssemblyAngularVelocity = V3(0, root.AssemblyAngularVelocity.Y, 0)
      end
    end
  end)
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
  local barBox = IN("Frame", HUDScreen)
  barBox.Size = U2(0, 350, 0, 10) barBox.Position = U2(0.5, -175, 1, -62) barBox.BackgroundColor3 = C3(15, 15, 15) barBox.ZIndex = 5 IN("UICorner", barBox).CornerRadius = U1(0, 5) AddOutline(barBox)
  local ProgressBarFill = IN("Frame", barBox)
  ProgressBarFill.Size = U2(0, 0, 1, 0) ProgressBarFill.BackgroundColor3 = C3(255, 255, 255) ProgressBarFill.ZIndex = 6 IN("UICorner", ProgressBarFill).CornerRadius = U1(0, 5)
  local stealLbl = IN("TextLabel", HUDScreen)
  stealLbl.Size = U2(0, 350, 0, 14) stealLbl.Position = U2(0.5, -175, 1, -78) stealLbl.BackgroundTransparency = 1 stealLbl.Text = "INSTA STEAL" stealLbl.TextColor3 = C3(120, 80, 200) stealLbl.Font = FGOTB
  stealLbl.TextSize = 10 stealLbl.ZIndex = 5
  local PromptMemoryCache = {}
  local InternalStealCache = {}
  local AUTO_STEAL_PROX_RADIUS = 8
  local function isMyBase(plotName)
    local plot = workspace.Plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
      local yourBase = sign:FindFirstChild("YourBase")
      if yourBase and yourBase:IsA("BillboardGui") then
        return yourBase.Enabled == true
      end
    end
    return false
  end
  local function findPromptInPodium(podium)
    local base = podium:FindFirstChild("Base")
    if not base then return nil end
    local spawn = base:FindFirstChild("Spawn")
    if not spawn then return nil end
    local attach = spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
      if p:IsA("ProximityPrompt") then return p end
    end
    return nil
  end
  local function findNearestStealPrompt()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local myPos = root.Position
    local nearest = nil
    local nearestDist = math.huge
    for _, plot in ipairs(plots:GetChildren()) do
      if not isMyBase(plot.Name) then
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
          for _, podium in ipairs(podiums:GetChildren()) do
            if podium:IsA("Model") and podium:FindFirstChild("Base") then
              local uid = plot.Name .. "_" .. podium.Name
              local worldPos = podium:GetPivot().Position
              local dist = (myPos - worldPos).Magnitude
              if dist <= AUTO_STEAL_PROX_RADIUS and dist < nearestDist then
                local prompt = PromptMemoryCache[uid]
                if not prompt or not prompt.Parent then
                  prompt = findPromptInPodium(podium)
                  if prompt then PromptMemoryCache[uid] = prompt end
                end
                if prompt then
                  nearest = prompt nearestDist = dist
                end
              end
            end
          end
        end
      end
    end
    return nearest
  end
  local function buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then return end
    local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table" then
      for _, conn in ipairs(conns1) do
        if type(conn.Function) == "function" then
          table.insert(data.holdCallbacks, conn.Function)
        end
      end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table" then
      for _, conn in ipairs(conns2) do
        if type(conn.Function) == "function" then
          table.insert(data.triggerCallbacks, conn.Function)
        end
      end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
      InternalStealCache[prompt] = data
    end
  end
  local function executeInternalSteal(prompt)
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false isStealing = true
    task.spawn(function()
      for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
      task.wait(0.3)
      for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
      task.wait(0.01)
      data.ready = true
    end)
    return true
  end
  local function resetBar()
    if currentTween then currentTween:Cancel(); currentTween = nil end
    ProgressBarFill.Size = U2(0, 0, 1, 0)
  end
  local function indicateGrab()
    if currentTween then currentTween:Cancel() end
    ProgressBarFill.Size = U2(0, 0, 1, 0) currentTween = TweenService:Create(
      ProgressBarFill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = U2(1, 0, 1, 0)}
    ) currentTween:Play()
  end
  local stealConn = nil
  local function startStealLoop()
    if stealConn then return end
    stealConn = RunService.Heartbeat:Connect(function()
      if not SETTINGS.ENABLED or isStealing then return end
      local prompt = findNearestStealPrompt()
      if not prompt then return end
      buildStealCallbacks(prompt)
      if InternalStealCache[prompt] then
        indicateGrab() executeInternalSteal(prompt)
      else
        task.spawn(function()
          pcall(function() fireproximityprompt(prompt) end)
        end)
        indicateGrab()
      end
    end)
  end
  local function stopStealLoop()
    if stealConn then stealConn:Disconnect(); stealConn = nil end
    resetBar()
  end
  local function MakeHUDButton(name, label, onToggle)
    local btn = IN("TextButton", HUDScreen)
    btn.Size = U2(0, 110, 0, 42) btn.Position = resolvePosition(name) btn.BackgroundColor3 = C3(0, 0, 0) btn.BackgroundTransparency = 0.45 btn.Text = label .. "\nOFF" btn.TextColor3 = C3(200, 200, 200)
    btn.Font = FGOTB btn.TextSize = 11 btn.Visible = true btn.ZIndex = 5 IN("UICorner", btn).CornerRadius = U1(0, 8) AddOutline(btn)
    allButtons[name] = btn
    local active = false
    MakeDraggable(btn, function()
      active = not active onToggle(active) SetHUDState(btn, label, active)
    end)
    local function forceState(state)
      active = state SetHUDState(btn, label, state)
    end
    return btn, forceState
  end
  local function getCurrentSpeed()
    if isStealing then
      return SETTINGS.STEAL_SPEED
    else
      return SETTINGS.TARGET_SPEED
    end
  end
  local function getCurrentWaypoints()
    if patrolMode == "right" then
      return rightWaypoints
    elseif patrolMode == "left" then
      return leftWaypoints
    end
    return {}
  end
  local function startMovement(mode)
    patrolMode = mode currentWaypoint = 1
  end
  local function stopMovement()
    patrolMode = "none" currentWaypoint = 1
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
      root.AssemblyLinearVelocity = V3(0, root.AssemblyLinearVelocity.Y, 0)
    end
  end
  local function updateWalking(hrp)
    if patrolMode == "none" then return end
    local waypoints = getCurrentWaypoints()
    local targetPos = waypoints[currentWaypoint]
    if not targetPos then return end
    local targetXZ = V3(targetPos.X, 0, targetPos.Z)
    local currentXZ = V3(hrp.Position.X, 0, hrp.Position.Z)
    local distanceXZ = (targetXZ - currentXZ).Magnitude
    if distanceXZ > 3 then
      local moveDir = (targetXZ - currentXZ).Unit
      local spd = getCurrentSpeed()
      hrp.AssemblyLinearVelocity = V3(moveDir.X * spd, hrp.AssemblyLinearVelocity.Y, moveDir.Z * spd)
    else
      if currentWaypoint == #waypoints then
        patrolMode = "none" currentWaypoint = 1 isStealing = false hrp.AssemblyLinearVelocity = V3(0, hrp.AssemblyLinearVelocity.Y, 0)
        if SETTINGS.AUTOLEFT then
          task.spawn(function() startMovement("left") end)
        elseif SETTINGS.AUTORIGHT then
          task.spawn(function() startMovement("right") end)
        end
      else
        currentWaypoint = currentWaypoint + 1
      end
    end
  end
  local autoTPEnabled = false
  local ragdollDetectorConn = nil
  local ragdollWasActive = false
  local C_TP = {
    right = {V3(-464.46, -5.85, 23.38), V3(-486.15, -3.50, 23.85)}, left  = {V3(-469.95, -5.85, 90.99), V3(-485.91, -3.55, 96.77)}
  }
  local function tpMove(pos)
    local char = LocalPlayer.Character
    if not char then return end
    char:PivotTo(CFrame.new(pos))
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = V3(0, 0, 0) end
  end
  local function findAnimalTarget()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, pl in ipairs(plots:GetChildren()) do
      local s = pl:FindFirstChild("PlotSign")
      local b = pl:FindFirstChild("DeliveryHitbox")
      if s and s:FindFirstChild("YourBase") and s.YourBase.Enabled and b then
        local t = pl:FindFirstChild("AnimalTarget", true)
        if t then return t.Position end
      end
    end
    return nil
  end
  local function doSilentTP()
    local tPos = findAnimalTarget()
    if not tPos then return end
    local l = (tPos - C_TP.left[1]).Magnitude
    local r = (tPos - C_TP.right[1]).Magnitude
    local side = (l > r) and C_TP.left or C_TP.right
    tpMove(side[1])
    task.wait(0.1)
    tpMove(side[2])
  end
  local function startRagdollDetector()
    if ragdollDetectorConn then ragdollDetectorConn:Disconnect() end
    ragdollDetectorConn = RunService.Heartbeat:Connect(function()
      if not autoTPEnabled then return end
      local char = LocalPlayer.Character
      if not char then return end
      local hum = char:FindFirstChildOfClass("Humanoid")
      if not hum then return end
      local nowRagdolled = hum:GetState() == HST.Physics
      if nowRagdolled and not ragdollWasActive then
        ragdollWasActive = true
        task.spawn(doSilentTP)
      end
      ragdollWasActive = nowRagdolled
    end)
  end
  local function stopRagdollDetector()
    if ragdollDetectorConn then
      ragdollDetectorConn:Disconnect()
      ragdollDetectorConn = nil
    end
    ragdollWasActive = false
  end
  local _wfActive = false
  local _wfConns = {}
  local function startWalkFling()
    _wfActive = true
    table.insert(_wfConns, RunService.Stepped:Connect(function()
      if not _wfActive then return end
      for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
          for _, part in ipairs(p.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
          end
        end
      end
    end))
    local co = coroutine.create(function()
      while _wfActive do
        RunService.Heartbeat:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then RunService.Heartbeat:Wait(); continue end
        local vel = root.Velocity
        root.Velocity = vel * 10000 + V3(0, 10000, 0) RunService.RenderStepped:Wait()
        if root and root.Parent then root.Velocity = vel end
        RunService.Stepped:Wait()
        if root and root.Parent then root.Velocity = vel + V3(0, 0.1, 0) end
      end
    end)
    coroutine.resume(co) table.insert(_wfConns, co)
  end
  local function stopWalkFling()
    _wfActive = false
    for _, c in ipairs(_wfConns) do
      if typeof(c) == "RBXScriptConnection" then c:Disconnect()
      elseif typeof(c) == "thread" then pcall(task.cancel, c) end
    end
    _wfConns = {}
  end
  local C_OFF=C3(22,22,26) local C_ON=C3(28,20,45) local DON=C3(80,255,120) local DOFF=C3(60,60,70)
  local BOFF=C3(50,50,60) local BON=C3(130,60,255) local TOFF=C3(180,180,190) local TON=C3(255,255,255)
  local function MakeBtn(parent,text,bx,by,bw,bh)
    local btn=IN("TextButton",parent)
    btn.Size=U2(0,bw,0,bh) btn.Position=U2(0,bx,0,by) btn.BackgroundColor3=C_OFF btn.BackgroundTransparency=0.1 btn.Text="" btn.ZIndex=5 btn.AutoButtonColor=false IN("UICorner",btn).CornerRadius=U1(0,12)
    local s=IN("UIStroke",btn) s.Color=BOFF s.Thickness=1.5
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local dot=IN("Frame",btn)
    dot.Size=U2(0,8,0,8) dot.Position=U2(0,10,0.5,-4) dot.BackgroundColor3=DOFF dot.ZIndex=6 IN("UICorner",dot).CornerRadius=U1(0.5,0)
    local lbl=IN("TextLabel",btn)
    lbl.Size=U2(1,-26,1,0) lbl.Position=U2(0,22,0,0) lbl.BackgroundTransparency=1 lbl.Text=text lbl.TextColor3=TOFF lbl.Font=FGOTB lbl.TextSize=BTEXT lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=6
    return btn,dot,lbl,s
  end
  local function SetActive(dot,lbl,s,on)
    dot.BackgroundColor3=on and DON or DOFF lbl.TextColor3=on and TON or TOFF s.Color=on and BON or BOFF
  end
  local SaveBtn=IN("TextButton",HUDScreen)
  SaveBtn.Size=U2(0,70,0,28) SaveBtn.Position=U2(0,LX,0,24) SaveBtn.BackgroundColor3=C_OFF SaveBtn.BackgroundTransparency=0.1 SaveBtn.Text="SAVE" SaveBtn.TextColor3=TOFF SaveBtn.Font=FGOTB SaveBtn.TextSize=math.floor(11*scale) SaveBtn.ZIndex=5 SaveBtn.AutoButtonColor=false IN("UICorner",SaveBtn).CornerRadius=U1(0,10)
  local ss=IN("UIStroke",SaveBtn) ss.Color=BOFF ss.Thickness=1.5
  ss.ApplyStrokeMode=Enum.ApplyStrokeMode.Border allButtons["Save"]=SaveBtn
  SaveBtn.MouseButton1Click:Connect(function()
    saveConfig() SaveBtn.Text="SAVED!" SaveBtn.TextColor3=DON
    task.delay(1.5,function() SaveBtn.Text="SAVE" SaveBtn.TextColor3=TOFF end)
  end)
  local dBtn,dDot,dLbl,dStroke=MakeBtn(HUDScreen,"DROP",LX,Y1,BW,BH)
  allButtons["Drop"]=dBtn
  MakeDraggable(dBtn,function()
    SetActive(dDot,dLbl,dStroke,true) startWalkFling()
    task.delay(0.4,function() stopWalkFling(); SetActive(dDot,dLbl,dStroke,false) end)
  end)
  local agBtn,agDot,agLbl,agStroke=MakeBtn(HUDScreen,"AUTO GRAB",LX,Y2,BW,BH)
  allButtons["AutoGrab"]=agBtn local agOn=false
  local function setAutoGrabState(on)
    agOn=on SETTINGS.ENABLED=on SetActive(agDot,agLbl,agStroke,on)
    if not on then resetBar() end
  end
  agBtn.MouseButton1Click:Connect(function() setAutoGrabState(not agOn) end)
  local lkBtn,lkDot,lkLbl,lkStroke=MakeBtn(HUDScreen,"BAT LOCK",LX,Y3,BW,BH)
  allButtons["Lock"]=lkBtn local lkOn=false
  local function setLockState(on)
    lkOn=on SETTINGS.LOCK_ENABLED=on SetActive(lkDot,lkLbl,lkStroke,on)
    if on then equipBat(); startAutoSwing() else stopAutoSwing() end
  end
  lkBtn.MouseButton1Click:Connect(function() setLockState(not lkOn) end)
  local flBtn,flDot,flLbl,flStroke=MakeBtn(HUDScreen,"FLOAT",LX,Y4,BW,BH)
  allButtons["Float"]=flBtn local flOn=false
  local function setFloatState(on)
    flOn=on SETTINGS.FLOAT=on SetActive(flDot,flLbl,flStroke,on)
    if not on and floatPart then pcall(function() floatPart:Destroy() end); floatPart=nil end
  end
  flBtn.MouseButton1Click:Connect(function() setFloatState(not flOn) end)
  local mnBtn,mnDot,mnLbl,mnStroke=MakeBtn(HUDScreen,"MENU",0,0,BW,BH)
  mnBtn.Position=U2(1,RX,0,Y1) allButtons["MenuBtn"]=mnBtn
  local tpBtn,tpDot,tpLbl,tpStroke=MakeBtn(HUDScreen,"TP AUTO",0,0,BW,BH)
  tpBtn.Position=U2(1,RX,0,Y2) allButtons["AutoTP"]=tpBtn local tpOn=false
  tpBtn.MouseButton1Click:Connect(function()
    tpOn=not tpOn autoTPEnabled=tpOn SetActive(tpDot,tpLbl,tpStroke,tpOn)
    if tpOn then startRagdollDetector() else stopRagdollDetector() end
  end)
  -- ===== AUTO PLAY (logica Kawatan) =====
  local SPEED_NO_STEAL = SETTINGS.TARGET_SPEED
  local SPEED_STEAL = SETTINGS.STEAL_SPEED
  local autoPlay = false
  local apMode = nil  -- 1 = lato Z~94, 2 = lato Z~25

  -- Trigger points per rilevare lato automaticamente
  local AUTO1_TRIGGER = V3(-466.43,-7.89,6.55)
  local AUTO2_TRIGGER = V3(-466.51,-7.81,113.79)

  -- Waypoints lato 1 (base vicino Z~94)
  local A1 = V3(-472.59,-7.30,94.43)
  local A2 = V3(-484.55,-5.33,95.05)
  local A3 = V3(-472.59,-7.30,94.43)
  local A4 = V3(-471.25,-6.83,7.08)

  -- Waypoints lato 2 (base vicino Z~25)
  local B1 = V3(-474.02,-7.30,25.55)
  local B2 = V3(-484.92,-5.13,24.53)
  local B3 = V3(-474.02,-7.30,25.55)
  local B4 = V3(-470.93,-6.83,113.38)

  local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
  end

  local function goTo(pos, speed, cond)
    local r = getHRP()
    if not r then return end
    while cond() and (r.Position - pos).Magnitude > 1 do
      local dir = (pos - r.Position).Unit
      r.AssemblyLinearVelocity = V3(dir.X*speed, r.AssemblyLinearVelocity.Y, dir.Z*speed)
      task.wait()
    end
  end

  -- Rileva lato in base alla posizione del giocatore
  RunService.Heartbeat:Connect(function()
    if apMode then return end
    local r = getHRP()
    if not r then return end
    if (r.Position - AUTO1_TRIGGER).Magnitude < 4 then apMode=1 end
    if (r.Position - AUTO2_TRIGGER).Magnitude < 4 then apMode=2 end
  end)

  -- GUI Auto Play separata (draggabile)
  local apGui = IN("ScreenGui", CoreGui)
  apGui.Name = "BS_AutoPlay"
  apGui.ResetOnSpawn = false
  apGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

  local apMain = IN("Frame", apGui)
  apMain.Size = U2(0, math.floor(200*scale), 0, math.floor(58*scale))
  apMain.Position = U2(0.5, -math.floor(100*scale), 0, math.floor(120*scale))
  apMain.BackgroundColor3 = C_OFF
  apMain.BackgroundTransparency = 0.1
  apMain.Active = true
  apMain.Draggable = true
  IN("UICorner", apMain).CornerRadius = U1(0, 10)
  local apStroke2 = IN("UIStroke", apMain)
  apStroke2.Color = BON; apStroke2.Thickness = 1.5

  -- Header con frecce
  local apHeader = IN("Frame", apMain)
  apHeader.Size = U2(1, -16, 0, math.floor(24*scale))
  apHeader.Position = U2(0, 8, 0, 4)
  apHeader.BackgroundTransparency = 1

  local apArrowL = IN("TextButton", apHeader)
  apArrowL.Size = U2(0, math.floor(20*scale), 0, math.floor(20*scale))
  apArrowL.Position = U2(0, 0, 0, 0)
  apArrowL.Text = "â—€"
  apArrowL.BackgroundTransparency = 1
  apArrowL.TextColor3 = TON
  apArrowL.Font = FGOTB
  apArrowL.TextSize = math.floor(12*scale)
  apArrowL.AutoButtonColor = false

  local apTitle = IN("TextLabel", apHeader)
  apTitle.Size = U2(1, -math.floor(44*scale), 1, 0)
  apTitle.Position = U2(0, math.floor(22*scale), 0, 0)
  apTitle.BackgroundTransparency = 1
  apTitle.Text = "Auto Play"
  apTitle.TextColor3 = DON
  apTitle.Font = FGOTB
  apTitle.TextSize = math.floor(13*scale)
  apTitle.TextXAlignment = Enum.TextXAlignment.Left

  local apArrowR = IN("TextButton", apHeader)
  apArrowR.Size = U2(0, math.floor(20*scale), 0, math.floor(20*scale))
  apArrowR.Position = U2(1, -math.floor(20*scale), 0, 0)
  apArrowR.Text = "â–¶"
  apArrowR.BackgroundTransparency = 1
  apArrowR.TextColor3 = TON
  apArrowR.Font = FGOTB
  apArrowR.TextSize = math.floor(12*scale)
  apArrowR.AutoButtonColor = false

  -- Bottone PLAY
  local apPlayBtn = IN("TextButton", apMain)
  apPlayBtn.Size = U2(1, -16, 0, math.floor(22*scale))
  apPlayBtn.Position = U2(0, 8, 0, math.floor(30*scale))
  apPlayBtn.BackgroundColor3 = C3(43,160,235)
  apPlayBtn.TextColor3 = TON
  apPlayBtn.Text = "PLAY"
  apPlayBtn.Font = FGOTB
  apPlayBtn.TextSize = math.floor(13*scale)
  apPlayBtn.AutoButtonColor = false
  IN("UICorner", apPlayBtn).CornerRadius = U1(0, 6)

  -- Config GUI (speed)
  local apConfig = IN("Frame", apGui)
  apConfig.Size = U2(0, math.floor(200*scale), 0, math.floor(88*scale))
  apConfig.Position = U2(0.5, -math.floor(100*scale), 0, math.floor(182*scale))
  apConfig.BackgroundColor3 = C_OFF
  apConfig.BackgroundTransparency = 0.1
  apConfig.Visible = false
  IN("UICorner", apConfig).CornerRadius = U1(0, 10)
  IN("UIStroke", apConfig).Color = BOFF

  local function mkRow2(lbl,val,yp)
    local l=IN("TextLabel",apConfig)
    l.Size=U2(0.6,0,0,math.floor(20*scale)); l.Position=U2(0,8,0,yp)
    l.BackgroundTransparency=1; l.Text=lbl
    l.TextColor3=TOFF; l.Font=FGOTB
    l.TextSize=math.floor(11*scale); l.TextXAlignment=Enum.TextXAlignment.Left
    local bx=IN("TextBox",apConfig)
    bx.Size=U2(0,math.floor(60*scale),0,math.floor(20*scale))
    bx.Position=U2(1,-math.floor(68*scale),0,yp)
    bx.BackgroundColor3=C3(30,35,40); bx.Text=tostring(val)
    bx.TextColor3=TON; bx.Font=FGOTB; bx.TextSize=math.floor(12*scale)
    bx.ClearTextOnFocus=false
    IN("UICorner",bx).CornerRadius=U1(0,6)
    return bx
  end

  local noStealBox = mkRow2("Speed No Steal", SPEED_NO_STEAL, 8)
  local stealBox = mkRow2("Speed Steal", SPEED_STEAL, 8+math.floor(30*scale))

  noStealBox.FocusLost:Connect(function()
    local n=tonumber(noStealBox.Text)
    if n then SPEED_NO_STEAL=n; SETTINGS.TARGET_SPEED=n end
  end)
  stealBox.FocusLost:Connect(function()
    local n=tonumber(stealBox.Text)
    if n then SPEED_STEAL=n; SETTINGS.STEAL_SPEED=n end
  end)

  -- Arrow clicks
  local apConfigOpen = false
  apArrowL.MouseButton1Click:Connect(function()
    apConfigOpen = not apConfigOpen
    apConfig.Visible = apConfigOpen
  end)

  apArrowR.MouseButton1Click:Connect(function()
    -- salva config
    saveConfig(); saveMenuConfig()
    apArrowR.TextColor3 = DON
    task.delay(1, function() apArrowR.TextColor3 = TON end)
  end)

  -- PLAY button
  apPlayBtn.MouseButton1Click:Connect(function()
    autoPlay = not autoPlay
    if autoPlay then
      apPlayBtn.Text = "STOP"
      apPlayBtn.BackgroundColor3 = C3(255,80,80)
      task.spawn(function()
        if apMode == 1 then
          goTo(A1, SPEED_NO_STEAL, function() return autoPlay end)
          goTo(A2, SPEED_NO_STEAL, function() return autoPlay end)
          isStealing = true
          goTo(A3, SPEED_STEAL, function() return autoPlay end)
          goTo(A4, SPEED_STEAL, function() return autoPlay end)
          isStealing = false
        elseif apMode == 2 then
          goTo(B1, SPEED_NO_STEAL, function() return autoPlay end)
          goTo(B2, SPEED_NO_STEAL, function() return autoPlay end)
          isStealing = true
          goTo(B3, SPEED_STEAL, function() return autoPlay end)
          goTo(B4, SPEED_STEAL, function() return autoPlay end)
          isStealing = false
        end
        autoPlay = false
        apPlayBtn.Text = "PLAY"
        apPlayBtn.BackgroundColor3 = C3(43,160,235)
      end)
    else
      apPlayBtn.Text = "PLAY"
      apPlayBtn.BackgroundColor3 = C3(43,160,235)
      isStealing = false
    end
  end)

  -- Funzioni dummy per keybind compatibility
  local alOn=false; local arOn=false
  local function setAutoLeftState(on) alOn=on end
  local function setAutoRightState(on) arOn=on end


  local menuOpen=false local menuPanel=nil
  local function buildMenuPanel()
    if menuPanel then menuPanel:Destroy(); menuPanel=nil end
    local pGui=IN("ScreenGui",CoreGui) pGui.Name="BS_Menu"
    pGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling menuPanel=pGui
    local panel=IN("Frame",pGui)
    panel.Size=U2(0,240,0,10) panel.Position=U2(0.5,-120,0.5,-145) panel.BackgroundColor3=C_OFF panel.BackgroundTransparency=0.05 panel.ZIndex=10 IN("UICorner",panel).CornerRadius=U1(0,14)
    local pS=IN("UIStroke",panel) pS.Color=C3(120,40,220) pS.Thickness=1.5
    local pT=IN("TextLabel",panel)
    pT.Size=U2(1,-60,0,28) pT.Position=U2(0,10,0,4) pT.BackgroundTransparency=1 pT.Text="MELOSKA MENU" pT.Font=FGOTB pT.TextSize=13 pT.ZIndex=11 pT.TextColor3=C3(255,255,255) pT.TextXAlignment=Enum.TextXAlignment.Left
    local xBtn=IN("TextButton",panel)
    xBtn.Size=U2(0,26,0,26) xBtn.Position=U2(1,-30,0,3) xBtn.BackgroundColor3=C3(40,20,20) xBtn.Text="X" xBtn.TextColor3=C3(220,80,80) xBtn.Font=FGOTB xBtn.TextSize=12 xBtn.ZIndex=12 xBtn.AutoButtonColor=false IN("UICorner",xBtn).CornerRadius=U1(0.5,0)
    xBtn.MouseButton1Click:Connect(function()
      menuOpen=false pGui:Destroy(); menuPanel=nil; SetActive(mnDot,mnLbl,mnStroke,false)
    end)
    local tabBar=IN("Frame",panel)
    tabBar.Size=U2(1,0,0,28) tabBar.Position=U2(0,0,0,32) tabBar.BackgroundColor3=C3(15,15,18) tabBar.ZIndex=11
    local tabLine=IN("Frame",tabBar)
    tabLine.Size=U2(1,0,0,1) tabLine.Position=U2(0,0,1,-1) tabLine.BackgroundColor3=BOFF tabLine.ZIndex=12
    local curTab="menu"
    local menuContent=IN("Frame",panel)
    menuContent.Size=U2(1,0,1,-60) menuContent.Position=U2(0,0,0,60) menuContent.BackgroundTransparency=1 menuContent.ZIndex=11 menuContent.ClipsDescendants=true
    local kbContent=IN("Frame",panel)
    kbContent.Size=U2(1,0,1,-60) kbContent.Position=U2(0,0,0,60) kbContent.BackgroundTransparency=1 kbContent.ZIndex=11 kbContent.ClipsDescendants=true kbContent.Visible=false
    local function makeTab(txt,x,target,other)
      local tb=IN("TextButton",tabBar)
      tb.Size=U2(0.5,0,1,0) tb.Position=U2(0,x,0,0) tb.BackgroundTransparency=1 tb.Text=txt tb.Font=FGOTB tb.TextSize=11 tb.ZIndex=12 tb.AutoButtonColor=false
      local tind=IN("Frame",tabBar)
      tind.Size=U2(0.5,0,0,2) tind.Position=U2(0,x,1,-2) tind.BackgroundColor3=BON tind.ZIndex=13 tind.Visible=(txt=="MENU")
      tb.MouseButton1Click:Connect(function()
        tb.TextColor3=TON tind.Visible=true target.Visible=true other.Visible=false
      end)
      return tb,tind
    end
    local tb1,ti1=makeTab("MENU",0,menuContent,kbContent)
    local tb2,ti2=makeTab("KBIND",120,kbContent,menuContent)
    tb1.TextColor3=TON tb2.TextColor3=TOFF
    tb1.MouseButton1Click:Connect(function() ti2.Visible=false tb2.TextColor3=TOFF end)
    tb2.MouseButton1Click:Connect(function() ti1.Visible=false tb1.TextColor3=TOFF end)
    MakeDraggable(panel,nil)
    local yO=8
    local function MT(lt,cs,cb)
      local b=IN("TextButton",menuContent)
      b.Size=U2(1,-20,0,38) b.Position=U2(0,10,0,yO) b.BackgroundColor3=cs and C_ON or C_OFF b.BackgroundTransparency=0.1 b.Text=lt.."\n"..(cs and "ON" or "OFF") b.TextColor3=cs and TON or TOFF b.Font=FGOTB b.TextSize=11 b.ZIndex=12 b.AutoButtonColor=false IN("UICorner",b).CornerRadius=U1(0,8)
      local bS=IN("UIStroke",b) bS.Color=cs and BON or BOFF bS.Thickness=1.5
      yO=yO+46 local st=cs
      b.MouseButton1Click:Connect(function()
        st=not st b.Text=lt.."\n"..(st and "ON" or "OFF") b.TextColor3=st and TON or TOFF b.BackgroundColor3=st and C_ON or C_OFF bS.Color=st and BON or BOFF cb(st)
      end)
    end
    local function IR(lt,cv,cb)
      local il=IN("TextLabel",menuContent)
      il.Size=U2(0,100,0,28) il.Position=U2(0,10,0,yO) il.BackgroundTransparency=1 il.Text=lt il.TextColor3=TOFF il.Font=FGOTB il.TextSize=11 il.ZIndex=12 il.TextXAlignment=Enum.TextXAlignment.Left
      local bx=IN("TextBox",menuContent)
      bx.Size=U2(0,90,0,28) bx.Position=U2(1,-100,0,yO) bx.BackgroundColor3=C3(25,25,25) bx.Text=tostring(cv) bx.TextColor3=TON bx.Font=FGOTB bx.TextSize=11 bx.ZIndex=12 IN("UICorner",bx).CornerRadius=U1(0,6)
      local bS2=IN("UIStroke",bx) bS2.Color=BOFF bS2.Thickness=1.5
      bx.FocusLost:Connect(function()
        local v=tonumber(bx.Text)
        if v then cb(v); bx.Text=tostring(v) else bx.Text=tostring(cv) end
      end)
      yO=yO+36
    end
    IR("Speed Value:",SETTINGS.TARGET_SPEED,function(v) SETTINGS.TARGET_SPEED=v end)
    IR("Steal Speed:",SETTINGS.STEAL_SPEED,function(v) SETTINGS.STEAL_SPEED=v end)
    IR("Chase Speed:",SETTINGS.CHASE_SPEED,function(v) SETTINGS.CHASE_SPEED=v end)
    MT("UNWALK",SETTINGS.UNWALK,function(on) SETTINGS.UNWALK=on end)
    MT("OPTIMIZER",SETTINGS.OPTIMIZER,function(on)
      SETTINGS.OPTIMIZER=on
      if on then
        pcall(function()
          local lighting=game:GetService("Lighting")
          lighting.GlobalShadows=false lighting.FogEnd=100000
          local env=game:GetService("ReplicatedFirst")
          game:GetService("RunService"):UnbindFromRenderStep("PerformanceOptimizer")
          game:GetService("RunService"):BindToRenderStep("PerformanceOptimizer",1,function()
            if not SETTINGS.OPTIMIZER then
              game:GetService("RunService"):UnbindFromRenderStep("PerformanceOptimizer")
              return
            end
            for _,p in ipairs(game:GetService("Players"):GetPlayers()) do
              if p~=LocalPlayer and p.Character then
                for _,obj in ipairs(p.Character:GetDescendants()) do
                  if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled=false
                  end
                  if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency=1
                  end
                end
              end
            end
          end)
          for _,obj in ipairs(game:GetService("Lighting"):GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BlurEffect") then
              obj.Enabled=false
            end
          end
          workspace.CurrentCamera.FieldOfView=70
        end)
      else
        pcall(function()
          game:GetService("RunService"):UnbindFromRenderStep("PerformanceOptimizer") game:GetService("Lighting").GlobalShadows=true
        end)
      end
    end)
    local kbY=8
    local kbList2={
      {"Auto Grab","KEYBIND_GRAB"},{"Bat Lock","KEYBIND_LOCK"}, {"Auto Left","KEYBIND_LEFT"},{"Auto Right","KEYBIND_RIGHT"}, {"Auto Play","KEYBIND_PLAY"},{"TP Auto","KEYBIND_TP"}, {"Float","KEYBIND_FLOAT"},{"Drop","KEYBIND_DROP"}
    }
    for _,kb in ipairs(kbList2) do
      local kl=IN("TextLabel",kbContent)
      kl.Size=U2(0,90,0,26) kl.Position=U2(0,10,0,kbY) kl.BackgroundTransparency=1 kl.Text=kb[1] kl.TextColor3=TOFF kl.Font=FGOTB
      kl.TextSize=10 kl.TextXAlignment=Enum.TextXAlignment.Left kl.ZIndex=12
      local kb2=IN("TextButton",kbContent)
      kb2.Size=U2(0,100,0,26) kb2.Position=U2(1,-110,0,kbY) kb2.BackgroundColor3=C3(25,25,25) kb2.BackgroundTransparency=0.1 kb2.Text=SETTINGS[kb[2]] or "None" kb2.TextColor3=(SETTINGS[kb[2]] or "None")~="None" and DON or TOFF
      kb2.Font=FGOTB kb2.TextSize=10 kb2.ZIndex=12 kb2.AutoButtonColor=false IN("UICorner",kb2).CornerRadius=U1(0,6) IN("UIStroke",kb2).Color=BOFF
      local kbWait=false
      local kbConn=nil
      kb2.MouseButton1Click:Connect(function()
        if kbWait then
          return
        end
        kbWait=true kb2.Text="..." kb2.TextColor3=DON
        kbConn=UserInputService.InputBegan:Connect(function(inp,gpe)
          if gpe then
            return
          end
          if inp.UserInputType==Enum.UserInputType.Keyboard then
            SETTINGS[kb[2]]=inp.KeyCode.Name kb2.Text=inp.KeyCode.Name kb2.TextColor3=DON
          else
            SETTINGS[kb[2]]="None" kb2.Text="None" kb2.TextColor3=TOFF
          end
          kbWait=false
          if kbConn then
            kbConn:Disconnect()
            kbConn=nil
          end
        end)
      end)
      kbY=kbY+32
    end
    local svB=IN("TextButton",menuContent)
    svB.Size=U2(1,-20,0,34) svB.Position=U2(0,10,0,yO) svB.BackgroundColor3=C3(80,30,160) svB.BackgroundTransparency=0.1 svB.Text="SAVE CONFIG" svB.TextColor3=TON svB.Font=FGOTB svB.TextSize=11 svB.ZIndex=11 svB.AutoButtonColor=false IN("UICorner",svB).CornerRadius=U1(0,8)
    svB.MouseButton1Click:Connect(function()
      saveConfig(); saveMenuConfig() svB.Text="SAVED!"
      task.delay(1.5,function() svB.Text="SAVE CONFIG" end)
    end)
    yO=yO+42 panel.Size=U2(0,240,0,math.max(yO+72,kbY+72))
  end
  mnBtn.MouseButton1Click:Connect(function()
    menuOpen=not menuOpen SetActive(mnDot,mnLbl,mnStroke,menuOpen)
    if menuOpen then buildMenuPanel() else if menuPanel then menuPanel:Destroy(); menuPanel=nil end end
  end)
  SETTINGS.SPEED_ENABLED = true
  UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
    local k=inp.KeyCode.Name
    if SETTINGS.KEYBIND_GRAB~="None" and k==SETTINGS.KEYBIND_GRAB then setAutoGrabState(not agOn) end
    if SETTINGS.KEYBIND_LOCK~="None" and k==SETTINGS.KEYBIND_LOCK  then setLockState(not lkOn) end
    if SETTINGS.KEYBIND_LEFT~="None" and k==SETTINGS.KEYBIND_LEFT  then setAutoLeftState(not alOn) end
    if SETTINGS.KEYBIND_RIGHT~="None" and k==SETTINGS.KEYBIND_RIGHT then setAutoRightState(not arOn) end
    if SETTINGS.KEYBIND_TP~="None" and k==SETTINGS.KEYBIND_TP then
      tpOn=not tpOn autoTPEnabled=tpOn SetActive(tpDot,tpLbl,tpStroke,tpOn)
      if tpOn then startRagdollDetector() else stopRagdollDetector() end
    end
    if SETTINGS.KEYBIND_FLOAT~="None" and k==SETTINGS.KEYBIND_FLOAT then setFloatState(not flOn) end
    if SETTINGS.KEYBIND_DROP~="None" and k==SETTINGS.KEYBIND_DROP then
      SetActive(dDot,dLbl,dStroke,true) startWalkFling()
      task.delay(0.4,function() stopWalkFling(); SetActive(dDot,dLbl,dStroke,false) end)
    end
  end)
  if SETTINGS.ENABLED then setAutoGrabState(true) end
  if SETTINGS.LOCK_ENABLED then setLockState(true); equipBat(); startAutoSwing() end
  if SETTINGS.FLOAT then setFloatState(true) end
  if SETTINGS.AUTOLEFT then setAutoLeftState(true) end
  if SETTINGS.AUTORIGHT then setAutoRightState(true) end
  if SETTINGS.SPIN_ENABLED then applySpin() end
  RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not hum then return end
    speedLabel.Text = math.floor(hrp.AssemblyLinearVelocity.Magnitude) .. " sp"
    if SETTINGS.AUTOLEFT and SETTINGS.AUTORIGHT then
      SETTINGS.AUTORIGHT = false arOn = false stopMovement()
    end
    updateWalking(hrp)
    if SETTINGS.LOCK_ENABLED then
      if not char:FindFirstChild("Bat") then equipBat() end
    else
      if hum.MoveDirection.Magnitude > 0 then
        local spd = isStealing and SETTINGS.STEAL_SPEED or SETTINGS.TARGET_SPEED
        hrp.AssemblyLinearVelocity = V3(
          hum.MoveDirection.X * spd, hrp.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * spd
        )
      end
    end
    if SETTINGS.ENABLED and not stealLoopRunning then
      startStealLoop()
    end
    if SETTINGS.FLOAT then
      if not floatPart then
        floatHeight = hrp.Position.Y floatPart = IN("BodyPosition", hrp) floatPart.Name = "MelFloatBP" floatPart.MaxForce = V3(0, math.huge, 0) floatPart.D = 1000 floatPart.P = 10000
        floatPart.Position = V3(hrp.Position.X, floatHeight, hrp.Position.Z)
      else
        floatPart.Position = V3(hrp.Position.X, floatHeight, hrp.Position.Z)
      end
    elseif floatPart then
      floatPart:Destroy() floatPart = nil
    end
  end)
  print("[Meloska DUEL v3] Caricato!")
end
local function tryRedeem(inputKey)
  redeemBtn.Text = "Checking..." redeemBtn.BackgroundColor3 = C3(50, 30, 80) statusLbl.Text = ""
  local cleanKey = inputKey:match("^([^|]+)") or inputKey
  cleanKey = trimStr(cleanKey)
  local valid, info = checkKeyValid(cleanKey)
  if valid then
    saveKeyLocally(cleanKey)
    local infoText = ""
    if info == "lifetime" then
      infoText = "Lifetime"
    else
      infoText = "Scade: " .. tostring(info)
    end
    statusLbl.Text = "Key valida! " .. infoText statusLbl.TextColor3 = C3(100, 255, 150)
    task.spawn(function()
      task.wait(1)
      launchMainScript()
    end)
  else
    redeemBtn.Text = "> Redeem" redeemBtn.BackgroundColor3 = C3(120, 40, 240) statusLbl.Text = "X " .. (info or "Key non valida!") statusLbl.TextColor3 = C3(255, 80, 80)
  end
end
redeemBtn.MouseButton1Click:Connect(function()
  local input = trimStr(keyBox.Text)
  if input == "" then
    statusLbl.Text = "Inserisci una key!" statusLbl.TextColor3 = C3(255, 200, 50)
    return
  end
  tryRedeem(input)
end)
local savedKey = loadSavedKey()
if savedKey and savedKey ~= "" then
  local cleanSaved = savedKey:match("^([^|]+)") or savedKey
  cleanSaved = trimStr(cleanSaved) keyBox.Text = cleanSaved
  task.spawn(function()
    task.wait(0.5)
    tryRedeem(cleanSaved)
  end)
end
