-- Meloska DUEL v3
-- No key system version

local C3=Color3.fromRGB
local U2=UDim2.new
local U1=UDim.new
local IN=Instance.new
local V3=Vector3.new
local FGOTB=Enum.Font.GothamBold
local FGOT=Enum.Font.Gotham
local UIT=Enum.UserInputType
local HST=Enum.HumanoidStateType

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
tag.Name = "BS_DUEL_USER"
tag.Value = "using bs duel"
local HUDScreen = IN("ScreenGui", CoreGui)
HUDScreen.Name = "BS_HUD"
HUDScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HUDScreen.ResetOnSpawn = false
local function AddOutline(frame)
  local s = IN("UIStroke", frame)
  s.Color = C3(255, 255, 255)
  s.Thickness = 2
  s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  s.Transparency = 0
end
local TitleBox = IN("Frame", HUDScreen)
TitleBox.Size = U2(0, 200, 0, 42)
TitleBox.Position = U2(0.5, -100, 0, 8)
TitleBox.BackgroundColor3 = C3(15, 15, 15)
TitleBox.ZIndex = 5
IN("UICorner", TitleBox).CornerRadius = U1(0, 8)
AddOutline(TitleBox)
local TitleLabel = IN("TextLabel", TitleBox)
TitleLabel.Size = U2(1, 0, 0, 22)
TitleLabel.Position = U2(0, 0, 0, 2)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Meloska DUEL"
TitleLabel.TextColor3 = C3(255, 255, 255)
TitleLabel.Font = FGOTB
TitleLabel.TextSize = 13
TitleLabel.ZIndex = 6
local InfoLabel = IN("TextLabel", TitleBox)
InfoLabel.Size = U2(1, -8, 0, 14)
InfoLabel.Position = U2(0, 4, 0, 25)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "fps:-- | ping:-- | --"
InfoLabel.TextColor3 = C3(180, 180, 180)
InfoLabel.Font = FGOT
InfoLabel.TextSize = 9
InfoLabel.ZIndex = 6
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
    currentFPS = fpsCount
    fpsCount = 0
    lastFPSUpdate = now
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
  ENABLED = false,
  FLOAT = false,
  AUTOLEFT = false,
  AUTORIGHT = false,
  SPEED_ENABLED = true,
  LOCK_ENABLED = false,
  STEAL_DURATION = 0.2,
  GRAB_DELAY = 0.3,
  GRAB_RADIUS = 8,
  TARGET_SPEED = 58,
  LOCK_SPEED = 59,
  JUMP_FORCE = 58,
  UNWALK = false,
  SPIN_ENABLED = false,
  SPIN_SPEED = 100,
  STEAL_SPEED = 29.40,
}
local KEYBINDS = {
  AutoGrab  = "G",
  Lock      = "F",
  AutoTP    = "T",
  Drop      = "X",
  Float     = "V",
  AutoLeft  = "Z",
  AutoRight = "C",
  Taunt     = "H",
}
local SAVE_KEYS = {
  "ENABLED", "FLOAT", "AUTOLEFT", "AUTORIGHT", "LOCK_ENABLED",
  "STEAL_DURATION", "TARGET_SPEED", "LOCK_SPEED", "JUMP_FORCE",
  "SPIN_ENABLED", "SPIN_SPEED", "UNWALK", "STEAL_SPEED", "GRAB_DELAY", "GRAB_RADIUS"
}
local MENU_SAVE_KEY = "BS_MenuConfig"
local patrolMode = "none"
local currentWaypoint = 1
local rightWaypoints = {
  V3(-473.04, -6.99, 29.71),
  V3(-483.57, -5.10, 18.74),
  V3(-475.00, -6.99, 26.43),
  V3(-474.67, -6.94, 105.48),
}
local leftWaypoints = {
  V3(-472.49, -7.00, 90.62),
  V3(-484.62, -5.10, 100.37),
  V3(-475.08, -7.00, 93.29),
  V3(-474.22, -6.96, 16.18),
}
local floatPart = nil
local floatHeight = 0
local isStealing = false
local currentTween = nil
local autoSwingActive = false
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
loadConfig()
-- Keybind save/load
local KB_SAVE_KEY = "BS_Keybinds"
local function saveKeybinds()
  pcall(function()
    writefile(KB_SAVE_KEY..".json", HttpService:JSONEncode(KEYBINDS))
  end)
end
local function loadKeybinds()
  local ok, result = pcall(function()
    if isfile(KB_SAVE_KEY..".json") then
      return HttpService:JSONDecode(readfile(KB_SAVE_KEY..".json"))
    end
  end)
  if ok and result then
    for k, v in pairs(result) do
      if KEYBINDS[k] ~= nil then KEYBINDS[k] = v end
    end
  end
end
loadKeybinds()
local function saveMenuConfig()
  local d = {
    SPIN_ENABLED = SETTINGS.SPIN_ENABLED,
    SPIN_SPEED   = SETTINGS.SPIN_SPEED,
    TARGET_SPEED = SETTINGS.TARGET_SPEED,
    STEAL_SPEED  = SETTINGS.STEAL_SPEED,
    UNWALK       = SETTINGS.UNWALK
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
    if result.TARGET_SPEED ~= nil then SETTINGS.TARGET_SPEED = result.TARGET_SPEED end
    if result.STEAL_SPEED  ~= nil then SETTINGS.STEAL_SPEED  = result.STEAL_SPEED  end
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
    Save      = U2(0,   8,   0,   8),
    Drop      = U2(0,   8,   0,  54),
    Taunt     = U2(0,   8,   0, 102),
    AutoGrab  = U2(0,   8,   0, 150),
    Lock      = U2(0,   8,   0, 198),
    Float     = U2(0,   8,   0, 198),
    AutoTP    = U2(0.5, -55, 0,  58),
    MenuBtn   = U2(1, -118,  0,   8),
    AutoLeft  = U2(1, -118,  0,  56),
    AutoRight = U2(1, -118,  0, 104),
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
          root.AssemblyLinearVelocity = V3(0, 0, 0)
          root.AssemblyAngularVelocity = V3(0, 0, 0)
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
-- OPTIMIZER
local function enableOptimizer()
  workspace.Terrain.WaterWaveSize = 0
  game:GetService("Lighting").GlobalShadows = false
  for _, obj in pairs(game:GetDescendants()) do
    if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic
    elseif obj:IsA("Decal") then obj.Transparency = 1 end
  end
end
-- XRAY BASE
local XrayBase = {
  Enabled = false,
  OriginalTransparency = {},
  Connections = {},
  BaseKeywords = {"base", "claim"}
}
local function isPlayerBase(obj)
  if not (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) then return false end
  local n = obj.Name:lower()
  local p = obj.Parent and obj.Parent.Name:lower() or ""
  for _, kw in ipairs(XrayBase.BaseKeywords) do
    if n:find(kw) or p:find(kw) then return true end
  end
  return false
end
local function applyXray(obj)
  if isPlayerBase(obj) then
    if not XrayBase.OriginalTransparency[obj] then
      XrayBase.OriginalTransparency[obj] = obj.LocalTransparencyModifier
    end
    obj.LocalTransparencyModifier = 0.8
  end
end
local function enableXrayBase()
  if XrayBase.Enabled then return end
  XrayBase.Enabled = true
  for _, obj in ipairs(workspace:GetDescendants()) do applyXray(obj) end
  XrayBase.Connections.added = workspace.DescendantAdded:Connect(applyXray)
  XrayBase.Connections.charAdded = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    for _, obj in ipairs(workspace:GetDescendants()) do applyXray(obj) end
  end)
end
local function disableXrayBase()
  if not XrayBase.Enabled then return end
  XrayBase.Enabled = false
  for _, conn in pairs(XrayBase.Connections) do conn:Disconnect() end
  XrayBase.Connections = {}
  for obj, original in pairs(XrayBase.OriginalTransparency) do
    obj.LocalTransparencyModifier = original
  end
  XrayBase.OriginalTransparency = {}
end
UserInputService.JumpRequest:Connect(function()
  local char = LocalPlayer.Character
  local hrp = char and char:FindFirstChild("HumanoidRootPart")
  if hrp then
    hrp.AssemblyLinearVelocity = V3(
      hrp.AssemblyLinearVelocity.X,
      SETTINGS.JUMP_FORCE,
      hrp.AssemblyLinearVelocity.Z
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
      dragging = true
      wasDragged = false
      dragStart = input.Position
      startPos = frame.Position
      dragInput = input
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
  local char = LocalPlayer.Character
  if char then
    for _, ch in ipairs(char:GetChildren()) do
      if ch:IsA("Tool") and ch.Name == "Bat" then
        return ch
      end
    end
  end
  local bp = LocalPlayer:FindFirstChild("Backpack")
  if bp then
    for _, ch in ipairs(bp:GetChildren()) do
      if ch:IsA("Tool") and ch.Name == "Bat" then
        return ch
      end
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
      if eh and hum and hum.Health > 0 and (eh.Position - hrp.Position).Magnitude <= 10 then
        for _, part in ipairs(p.Character:GetChildren()) do
          if part:IsA("BasePart") then
            pcall(function()
              firetouchinterest(handle, part, 0)
            end)
            pcall(function()
              firetouchinterest(handle, part, 1)
            end)
          end
        end
        break
      end
    end
  end
end
local function startAutoSwing()
  if autoSwingActive then return end
  autoSwingActive = true
  task.spawn(function()
    while autoSwingActive and SETTINGS.LOCK_ENABLED do
      equipBat()
      silentSwing()
      silentSwing()
      task.wait(0.18)
    end
    autoSwingActive = false
  end)
end
local function stopAutoSwing()
  autoSwingActive = false
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
          nearestDist = d
          nearest = eh
          nearestTorso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso") or eh
        end
      end
    end
  end
  return nearest, nearestDist, nearestTorso
end
local function set_physics(char, active)
  for _, part in pairs(char:GetDescendants()) do
    if part:IsA("BasePart") then
      if active then
        part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0, 1, 100)
      else
        part.CustomPhysicalProperties = nil
      end
    end
  end
end
local function applySpin()
  local char = LocalPlayer.Character
  local root = char and char:FindFirstChild("HumanoidRootPart")
  if not root then return end
  set_physics(char, true)
  if root:FindFirstChild("BlaalSpin") then
    root.BlaalSpin:Destroy()
  end
  local s = IN("BodyAngularVelocity")
  s.Name = "BlaalSpin"
  s.Parent = root
  s.MaxTorque = V3(0, math.huge, 0)
  s.P = 1200
  s.AngularVelocity = V3(0, SETTINGS.SPIN_SPEED, 0)
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
-- Keybind listener
UserInputService.InputBegan:Connect(function(input, gpe)
  if gpe then return end
  local key = nil
  if input.UserInputType == Enum.UserInputType.Keyboard then
    key = input.KeyCode.Name
  elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
    key = "GP:"..input.KeyCode.Name
  end
  if not key then return end
  if key == KEYBINDS.AutoGrab then
    SETTINGS.ENABLED = not SETTINGS.ENABLED
    if setAutoGrabState then setAutoGrabState(SETTINGS.ENABLED) end
    if not SETTINGS.ENABLED then resetBar() end
  elseif key == KEYBINDS.Lock then
    SETTINGS.LOCK_ENABLED = not SETTINGS.LOCK_ENABLED
    if setLockState then setLockState(SETTINGS.LOCK_ENABLED) end
    if SETTINGS.LOCK_ENABLED then equipBat(); startAutoSwing() else stopAutoSwing() end
  elseif key == KEYBINDS.AutoTP then
    autoTPEnabled = not autoTPEnabled
    if autoTPEnabled then
      AutoTPBtn.Text = "AUTO TP\nON"
      AutoTPBtn.TextColor3 = C3(255,255,255)
      AutoTPBtn.BackgroundTransparency = 0.2
      startRagdollDetector()
    else
      AutoTPBtn.Text = "AUTO TP\nOFF"
      AutoTPBtn.TextColor3 = C3(200,200,200)
      AutoTPBtn.BackgroundTransparency = 0.45
      stopRagdollDetector()
    end
  elseif key == KEYBINDS.Drop then
    startWalkFling(); task.delay(0.4, stopWalkFling)
  elseif key == KEYBINDS.Float then
    SETTINGS.FLOAT = not SETTINGS.FLOAT
    if setFloatState then setFloatState(SETTINGS.FLOAT) end
  elseif key == KEYBINDS.AutoLeft then
    SETTINGS.AUTOLEFT = not SETTINGS.AUTOLEFT
    if SETTINGS.AUTOLEFT then
      SETTINGS.AUTORIGHT = false
      if setAutoRightState then setAutoRightState(false) end
      stopMovement(); startMovement("left")
      if setAutoLeftState then setAutoLeftState(true) end
    else
      stopMovement()
      if setAutoLeftState then setAutoLeftState(false) end
    end
  elseif key == KEYBINDS.AutoRight then
    SETTINGS.AUTORIGHT = not SETTINGS.AUTORIGHT
    if SETTINGS.AUTORIGHT then
      SETTINGS.AUTOLEFT = false
      if setAutoLeftState then setAutoLeftState(false) end
      stopMovement(); startMovement("right")
      if setAutoRightState then setAutoRightState(true) end
    else
      stopMovement()
      if setAutoRightState then setAutoRightState(false) end
    end
  elseif key == KEYBINDS.Taunt then
    tauntActive = not tauntActive
    if tauntActive then
      TauntBtn.Text = "TAUNT\nON"
      TauntBtn.TextColor3 = C3(255,255,255)
      TauntBtn.BackgroundTransparency = 0.2
      tauntLoop = task.spawn(function()
        while tauntActive do
          pcall(function()
            local TCS = game:GetService("TextChatService")
            local ch = TCS.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync("/MeloskaDuelsOp") end
          end)
          task.wait(0.5)
        end
      end)
    else
      TauntBtn.Text = "TAUNT\nOFF"
      TauntBtn.TextColor3 = C3(200,200,200)
      TauntBtn.BackgroundTransparency = 0.45
      if tauntLoop then task.cancel(tauntLoop); tauntLoop = nil end
    end
  end
end)
local speedBillboard = IN("BillboardGui")
speedBillboard.Name = "BS_SpeedDisplay"
speedBillboard.Size = U2(0, 90, 0, 26)
speedBillboard.StudsOffset = V3(0, 3.5, 0)
speedBillboard.AlwaysOnTop = false
speedBillboard.ResetOnSpawn = false
local speedLabel = IN("TextLabel", speedBillboard)
speedLabel.Size = U2(1, 0, 1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = C3(255, 255, 255)
speedLabel.Font = FGOTB
speedLabel.TextSize = 20
speedLabel.Text = "0 sp"
speedLabel.TextStrokeTransparency = 0.3
speedLabel.TextStrokeColor3 = C3(0, 0, 0)
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
    local t2 = IN("StringValue", LocalPlayer)
    t2.Name = "BS_DUEL_USER"
    t2.Value = "using bs duel"
  end
  -- Fix auto-reset: riavvia i loop attivi dopo respawn
  task.wait(0.5)
  isStealing = false
  if SETTINGS.ENABLED then startStealLoop() end
  if SETTINGS.LOCK_ENABLED then equipBat(); startAutoSwing() end
  if SETTINGS.SPIN_ENABLED then applySpin() end
  if autoTPEnabled then startRagdollDetector() end
  patrolMode = "none"; currentWaypoint = 1
  if SETTINGS.AUTOLEFT then startMovement("left")
  elseif SETTINGS.AUTORIGHT then startMovement("right") end
end)
attachSpeedDisplay()
local trackedTags = {}
local function addTagToPlayer(p)
  if p == LocalPlayer or trackedTags[p] then return end
  local function tryBuild()
    local char = p.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local bb = IN("BillboardGui")
    bb.Name = "BS_DuelTag"
    bb.Size = U2(0, 140, 0, 26)
    bb.StudsOffset = V3(0, 2.5, 0)
    bb.AlwaysOnTop = false
    bb.ResetOnSpawn = false
    bb.Adornee = head
    bb.Parent = CoreGui
    local lbl = IN("TextLabel", bb)
    lbl.Size = U2(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = C3(255, 255, 255)
    lbl.Font = FGOTB
    lbl.TextSize = 14
    lbl.Text = "using bs duel"
    lbl.TextStrokeTransparency = 0.3
    lbl.TextStrokeColor3 = C3(0, 0, 0)
    trackedTags[p] = bb
    p.CharacterAdded:Connect(function()
      bb:Destroy()
      trackedTags[p] = nil
      task.wait(1)
      tryBuild()
    end)
  end
  tryBuild()
end
Players.PlayerAdded:Connect(function(p)
  p.ChildAdded:Connect(function(child)
    if child.Name == "BS_DUEL_USER" then
      addTagToPlayer(p)
    end
  end)
  p.ChildRemoved:Connect(function(child)
    if child.Name == "BS_DUEL_USER" and trackedTags[p] then
      trackedTags[p]:Destroy()
      trackedTags[p] = nil
    end
  end)
end)
for _, p in ipairs(Players:GetPlayers()) do
  if p ~= LocalPlayer then
    p.ChildAdded:Connect(function(child)
      if child.Name == "BS_DUEL_USER" then
        addTagToPlayer(p)
      end
    end)
    p.ChildRemoved:Connect(function(child)
      if child.Name == "BS_DUEL_USER" and trackedTags[p] then
        trackedTags[p]:Destroy()
        trackedTags[p] = nil
      end
    end)
    if p:FindFirstChild("BS_DUEL_USER") then
      addTagToPlayer(p)
    end
  end
end
local barBox = IN("Frame", HUDScreen)
barBox.Size = U2(0, 350, 0, 10)
barBox.Position = U2(0.5, -175, 1, -62)
barBox.BackgroundColor3 = C3(15, 15, 15)
barBox.ZIndex = 5
IN("UICorner", barBox).CornerRadius = U1(0, 5)
AddOutline(barBox)
local ProgressBarFill = IN("Frame", barBox)
ProgressBarFill.Size = U2(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = C3(0, 220, 80)
ProgressBarFill.ZIndex = 6
IN("UICorner", ProgressBarFill).CornerRadius = U1(0, 5)
local stealLbl = IN("TextLabel", HUDScreen)
stealLbl.Size = U2(0, 350, 0, 14)
stealLbl.Position = U2(0.5, -175, 1, -78)
stealLbl.BackgroundTransparency = 1
stealLbl.Text = "GRAB"
stealLbl.TextColor3 = C3(255, 255, 255)
stealLbl.Font = FGOTB
stealLbl.TextSize = 10
stealLbl.ZIndex = 5
local PromptMemoryCache = {}
local InternalStealCache = {}
local AUTO_STEAL_PROX_RADIUS = SETTINGS.GRAB_RADIUS
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
            if dist <= SETTINGS.GRAB_RADIUS and dist < nearestDist then
              local prompt = PromptMemoryCache[uid]
              if not prompt or not prompt.Parent then
                prompt = findPromptInPodium(podium)
                if prompt then PromptMemoryCache[uid] = prompt end
              end
              if prompt then
                nearest = prompt
                nearestDist = dist
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
  data.ready = false
  isStealing = true
  task.spawn(function()
    for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
    task.wait(SETTINGS.GRAB_DELAY)
    for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
    task.wait(0.01)
    data.ready = true
    task.wait(0.01)
    isStealing = false
    resetBar()
  end)
  return true
end
local function resetBar()
  if currentTween then currentTween:Cancel(); currentTween = nil end
  ProgressBarFill.Size = U2(0, 0, 1, 0)
  isStealing = false
end
local function indicateGrab()
  if currentTween then currentTween:Cancel() end
  ProgressBarFill.Size = U2(0, 0, 1, 0)
  currentTween = TweenService:Create(
    ProgressBarFill,
    TweenInfo.new(SETTINGS.GRAB_DELAY, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
    {Size = U2(1, 0, 1, 0)}
  )
  currentTween:Play()
end
local stealConn = nil
local function startStealLoop()
  if stealConn then stealConn:Disconnect(); stealConn = nil end
  stealConn = RunService.Heartbeat:Connect(function()
    if not SETTINGS.ENABLED or isStealing then return end
    local prompt = findNearestStealPrompt()
    if not prompt then return end
    buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then
      indicateGrab()
      executeInternalSteal(prompt)
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
  isStealing = false
  resetBar()
end
local function SetHUDState(btn, label, on)
  btn.Text = label .. "\n" .. (on and "ON" or "OFF")
  if on then
    btn.TextColor3 = C3(255, 255, 255)
    btn.BackgroundColor3 = C3(30, 30, 30)
    btn.BackgroundTransparency = 0.2
  else
    btn.TextColor3 = C3(200, 200, 200)
    btn.BackgroundColor3 = C3(0, 0, 0)
    btn.BackgroundTransparency = 0.45
  end
  local s = btn:FindFirstChildOfClass("UIStroke")
  if s then
    s.Color = C3(255, 255, 255)
    s.Thickness = 2
    if on then
      s.Transparency = 0
    else
      s.Transparency = 0.4
    end
  end
end
local function MakeHUDButton(name, label, onToggle)
  local btn = IN("TextButton", HUDScreen)
  btn.Size = U2(0, 110, 0, 42)
  btn.Position = resolvePosition(name)
  btn.BackgroundColor3 = C3(0, 0, 0)
  btn.BackgroundTransparency = 0.45
  btn.Text = label .. "\nOFF"
  btn.TextColor3 = C3(200, 200, 200)
  btn.Font = FGOTB
  btn.TextSize = 11
  btn.Visible = true
  btn.ZIndex = 5
  IN("UICorner", btn).CornerRadius = U1(0, 8)
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
    SetHUDState(btn, label, state)
  end
  return btn, forceState
end
local function getCurrentSpeed()
  if currentWaypoint >= 3 then
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
  patrolMode = mode
  currentWaypoint = 1
end
local function stopMovement()
  patrolMode = "none"
  currentWaypoint = 1
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
    hrp.AssemblyLinearVelocity = V3(
      moveDir.X * spd,
      hrp.AssemblyLinearVelocity.Y,
      moveDir.Z * spd
    )
  else
    if currentWaypoint == #waypoints then
      patrolMode = "none"
      currentWaypoint = 1
      hrp.AssemblyLinearVelocity = V3(0, hrp.AssemblyLinearVelocity.Y, 0)
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
  right = {V3(-464.46, -5.85, 23.38), V3(-486.15, -3.50, 23.85)},
  left  = {V3(-469.95, -5.85, 90.99), V3(-485.91, -3.55, 96.77)}
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
      root.Velocity = vel * 10000 + V3(0, 10000, 0)
      RunService.RenderStepped:Wait()
      if root and root.Parent then root.Velocity = vel end
      RunService.Stepped:Wait()
      if root and root.Parent then root.Velocity = vel + V3(0, 0.1, 0) end
    end
  end)
  coroutine.resume(co)
  table.insert(_wfConns, co)
end
local function stopWalkFling()
  _wfActive = false
  for _, c in ipairs(_wfConns) do
    if typeof(c) == "RBXScriptConnection" then c:Disconnect()
    elseif typeof(c) == "thread" then pcall(task.cancel, c) end
  end
  _wfConns = {}
end
local SaveBtn = IN("TextButton", HUDScreen)
SaveBtn.Size = U2(0, 80, 0, 28)
SaveBtn.Position = resolvePosition("Save")
SaveBtn.BackgroundColor3 = C3(0, 0, 0)
SaveBtn.BackgroundTransparency = 0.45
SaveBtn.Text = "SAVE"
SaveBtn.TextColor3 = C3(200, 200, 200)
SaveBtn.Font = FGOTB
SaveBtn.TextSize = 11
SaveBtn.ZIndex = 5
IN("UICorner", SaveBtn).CornerRadius = U1(0, 8)
AddOutline(SaveBtn)
allButtons["Save"] = SaveBtn
MakeDraggable(SaveBtn, function()
  saveConfig()
  SaveBtn.Text = "SAVED!"
  SaveBtn.TextColor3 = C3(255, 255, 255)
  task.delay(1.5, function()
    SaveBtn.Text = "SAVE"
    SaveBtn.TextColor3 = C3(200, 200, 200)
  end)
end)
local DropBtn = IN("TextButton", HUDScreen)
DropBtn.Size = U2(0, 110, 0, 42)
DropBtn.Position = resolvePosition("Drop")
DropBtn.BackgroundColor3 = C3(0, 0, 0)
DropBtn.BackgroundTransparency = 0.45
DropBtn.Text = "DROP"
DropBtn.TextColor3 = C3(200, 200, 200)
DropBtn.Font = FGOTB
DropBtn.TextSize = 11
DropBtn.ZIndex = 5
IN("UICorner", DropBtn).CornerRadius = U1(0, 8)
AddOutline(DropBtn)
allButtons["Drop"] = DropBtn
MakeDraggable(DropBtn, function()
  DropBtn.TextColor3 = C3(255, 255, 255)
  DropBtn.BackgroundTransparency = 0.2
  startWalkFling()
  task.delay(0.4, function()
    stopWalkFling()
    DropBtn.TextColor3 = C3(200, 200, 200)
    DropBtn.BackgroundTransparency = 0.45
  end)
end)
local tauntActive = false
local tauntLoop = nil
local TauntBtn = IN("TextButton", HUDScreen)
TauntBtn.Size = U2(0, 110, 0, 42)
TauntBtn.Position = resolvePosition("Taunt")
TauntBtn.BackgroundColor3 = C3(0, 0, 0)
TauntBtn.BackgroundTransparency = 0.45
TauntBtn.Text = "TAUNT\nOFF"
TauntBtn.TextColor3 = C3(200, 200, 200)
TauntBtn.Font = FGOTB
TauntBtn.TextSize = 11
TauntBtn.ZIndex = 5
IN("UICorner", TauntBtn).CornerRadius = U1(0, 8)
AddOutline(TauntBtn)
allButtons["Taunt"] = TauntBtn
MakeDraggable(TauntBtn, function()
  tauntActive = not tauntActive
  if tauntActive then
    TauntBtn.Text = "TAUNT\nON"
    TauntBtn.TextColor3 = C3(255, 255, 255)
    TauntBtn.BackgroundTransparency = 0.2
    tauntLoop = task.spawn(function()
      while tauntActive do
        pcall(function()
          local TCS = game:GetService("TextChatService")
          local ch = TCS.TextChannels:FindFirstChild("RBXGeneral")
          if ch then ch:SendAsync("/MeloskaDuelsOp") end
        end)
        task.wait(0.5)
      end
    end)
  else
    TauntBtn.Text = "TAUNT\nOFF"
    TauntBtn.TextColor3 = C3(200, 200, 200)
    TauntBtn.BackgroundTransparency = 0.45
    if tauntLoop then task.cancel(tauntLoop); tauntLoop = nil end
  end
end)
local AutoGrabHUD, setAutoGrabState = MakeHUDButton("AutoGrab", "AUTO GRAB", function(on)
  SETTINGS.ENABLED = on
  if not on then
    resetBar()
  end
end)
local LockHUD, setLockState = MakeHUDButton("Lock", "LOCK ON", function(on)
  SETTINGS.LOCK_ENABLED = on
  if on then
    equipBat()
    startAutoSwing()
  else
    stopAutoSwing()
  end
end)
local FloatHUD, setFloatState = MakeHUDButton("Float", "FLOAT", function(on)
  SETTINGS.FLOAT = on
  if not on and floatPart then
    pcall(function()
      floatPart:Destroy()
    end)
    floatPart = nil
  end
end)
local AutoTPBtn = IN("TextButton", HUDScreen)
AutoTPBtn.Size = U2(0, 110, 0, 42)
AutoTPBtn.Position = resolvePosition("AutoTP")
AutoTPBtn.BackgroundColor3 = C3(0, 0, 0)
AutoTPBtn.BackgroundTransparency = 0.45
AutoTPBtn.Text = "AUTO TP\nOFF"
AutoTPBtn.TextColor3 = C3(200, 200, 200)
AutoTPBtn.Font = FGOTB
AutoTPBtn.TextSize = 11
AutoTPBtn.ZIndex = 5
IN("UICorner", AutoTPBtn).CornerRadius = U1(0, 8)
AddOutline(AutoTPBtn)
allButtons["AutoTP"] = AutoTPBtn
MakeDraggable(AutoTPBtn, function()
  autoTPEnabled = not autoTPEnabled
  if autoTPEnabled then
    AutoTPBtn.Text = "AUTO TP\nON"
    AutoTPBtn.TextColor3 = C3(255, 255, 255)
    AutoTPBtn.BackgroundTransparency = 0.2
    startRagdollDetector()
  else
    AutoTPBtn.Text = "AUTO TP\nOFF"
    AutoTPBtn.TextColor3 = C3(200, 200, 200)
    AutoTPBtn.BackgroundTransparency = 0.45
    stopRagdollDetector()
  end
end)
local menuOpen = false
local menuPanel = nil
local MenuBtn = IN("TextButton", HUDScreen)
MenuBtn.Size = U2(0, 110, 0, 42)
MenuBtn.Position = resolvePosition("MenuBtn")
MenuBtn.BackgroundColor3 = C3(0, 0, 0)
MenuBtn.BackgroundTransparency = 0.45
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = C3(200, 200, 200)
MenuBtn.Font = FGOTB
MenuBtn.TextSize = 12
MenuBtn.ZIndex = 5
IN("UICorner", MenuBtn).CornerRadius = U1(0, 8)
AddOutline(MenuBtn)
allButtons["MenuBtn"] = MenuBtn
local function buildMenuPanel()
  if menuPanel then menuPanel:Destroy(); menuPanel = nil end
  local panelGui = IN("ScreenGui", CoreGui)
  panelGui.Name = "BS_Menu"
  panelGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  menuPanel = panelGui
  local panel = IN("Frame", panelGui)
  panel.Size = U2(0, 240, 0, 10)
  panel.Position = U2(0.5, -120, 0.5, -145)
  panel.BackgroundColor3 = C3(0, 0, 0)
  panel.BackgroundTransparency = 0.35
  panel.ZIndex = 10
  IN("UICorner", panel).CornerRadius = U1(0, 8)
  AddOutline(panel)
  local panelTitle = IN("TextLabel", panel)
  panelTitle.Size = U2(1, -60, 0, 32)
  panelTitle.Position = U2(0, 10, 0, 0)
  panelTitle.BackgroundTransparency = 1
  panelTitle.Text = "MELOSKA MENU"
  panelTitle.TextColor3 = C3(255, 255, 255)
  panelTitle.Font = FGOTB
  panelTitle.TextSize = 13
  panelTitle.ZIndex = 11
  -- Tab buttons
  local tabMenuBtn = IN("TextButton", panel)
  tabMenuBtn.Size = U2(0, 70, 0, 22)
  tabMenuBtn.Position = U2(1, -155, 0, 5)
  tabMenuBtn.BackgroundColor3 = C3(40, 40, 40)
  tabMenuBtn.Text = "MENU"
  tabMenuBtn.TextColor3 = C3(255,255,255)
  tabMenuBtn.Font = FGOTB; tabMenuBtn.TextSize = 10
  tabMenuBtn.ZIndex = 12
  IN("UICorner", tabMenuBtn).CornerRadius = U1(0,5)
  local tabKbindBtn = IN("TextButton", panel)
  tabKbindBtn.Size = U2(0, 70, 0, 22)
  tabKbindBtn.Position = U2(1, -80, 0, 5)
  tabKbindBtn.BackgroundColor3 = C3(20, 20, 20)
  tabKbindBtn.Text = "KBIND"
  tabKbindBtn.TextColor3 = C3(160,160,160)
  tabKbindBtn.Font = FGOTB; tabKbindBtn.TextSize = 10
  tabKbindBtn.ZIndex = 12
  IN("UICorner", tabKbindBtn).CornerRadius = U1(0,5)
  local cBtn = IN("TextButton", panel)
  cBtn.Size = U2(0, 24, 0, 24)
  cBtn.Position = U2(1, -28, 0, 4)
  cBtn.BackgroundColor3 = C3(30, 30, 30)
  cBtn.Text = "X"; cBtn.TextColor3 = C3(200, 200, 200)
  cBtn.Font = FGOTB; cBtn.TextSize = 12; cBtn.ZIndex = 12
  IN("UICorner", cBtn).CornerRadius = U1(0, 6)
  cBtn.MouseButton1Click:Connect(function()
    menuOpen = false; panelGui:Destroy(); menuPanel = nil
    MenuBtn.Text = "MENU"; MenuBtn.BackgroundTransparency = 0.45
    MenuBtn.TextColor3 = C3(200, 200, 200)
  end)
  MakeDraggable(panel, nil)
  -- MENU TAB CONTENT
  local menuScroll = IN("ScrollingFrame", panel)
  menuScroll.Size = U2(1, 0, 1, -38)
  menuScroll.Position = U2(0, 0, 0, 38)
  menuScroll.BackgroundTransparency = 1
  menuScroll.ScrollBarThickness = 3
  menuScroll.ScrollBarImageColor3 = C3(255,255,255)
  menuScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
  menuScroll.ZIndex = 11
  -- KBIND TAB CONTENT
  local kbindScroll = IN("ScrollingFrame", panel)
  kbindScroll.Size = U2(1, 0, 1, -38)
  kbindScroll.Position = U2(0, 0, 0, 38)
  kbindScroll.BackgroundTransparency = 1
  kbindScroll.ScrollBarThickness = 3
  kbindScroll.ScrollBarImageColor3 = C3(255,255,255)
  kbindScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
  kbindScroll.Visible = false
  kbindScroll.ZIndex = 11
  local function setTab(tab)
    if tab == "menu" then
      menuScroll.Visible = true; kbindScroll.Visible = false
      tabMenuBtn.BackgroundColor3 = C3(40,40,40); tabMenuBtn.TextColor3 = C3(255,255,255)
      tabKbindBtn.BackgroundColor3 = C3(20,20,20); tabKbindBtn.TextColor3 = C3(160,160,160)
    else
      menuScroll.Visible = false; kbindScroll.Visible = true
      tabKbindBtn.BackgroundColor3 = C3(40,40,40); tabKbindBtn.TextColor3 = C3(255,255,255)
      tabMenuBtn.BackgroundColor3 = C3(20,20,20); tabMenuBtn.TextColor3 = C3(160,160,160)
    end
  end
  tabMenuBtn.MouseButton1Click:Connect(function() setTab("menu") end)
  tabKbindBtn.MouseButton1Click:Connect(function() setTab("kbind") end)
  -- Build MENU tab
  local yOff = 8
  local function MakeMenuToggle(labelText, currentState, onToggle)
    local btn = IN("TextButton", menuScroll)
    btn.Size = U2(1, -20, 0, 38)
    btn.Position = U2(0, 10, 0, yOff)
    btn.BackgroundColor3 = currentState and C3(30,30,30) or C3(0,0,0)
    btn.BackgroundTransparency = currentState and 0.2 or 0.45
    btn.TextColor3 = currentState and C3(255,255,255) or C3(160,160,160)
    btn.Text = labelText.."\n"..(currentState and "ON" or "OFF")
    btn.Font = FGOTB; btn.TextSize = 11; btn.ZIndex = 11
    IN("UICorner", btn).CornerRadius = U1(0, 8)
    AddOutline(btn); yOff = yOff + 46
    local state = currentState
    btn.MouseButton1Click:Connect(function()
      state = not state
      btn.Text = labelText.."\n"..(state and "ON" or "OFF")
      btn.TextColor3 = state and C3(255,255,255) or C3(160,160,160)
      btn.BackgroundColor3 = state and C3(30,30,30) or C3(0,0,0)
      btn.BackgroundTransparency = state and 0.2 or 0.45
      onToggle(state)
    end)
  end
  local function MakeInputRow(labelText, currentVal, onChanged)
    local lbl = IN("TextLabel", menuScroll)
    lbl.Size = U2(0, 110, 0, 28)
    lbl.Position = U2(0, 10, 0, yOff)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText; lbl.TextColor3 = C3(200,200,200)
    lbl.Font = FGOTB; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 11
    local box = IN("TextBox", menuScroll)
    box.Size = U2(0, 90, 0, 28)
    box.Position = U2(1, -100, 0, yOff)
    box.BackgroundColor3 = C3(25,25,25)
    box.Text = tostring(currentVal); box.TextColor3 = C3(255,255,255)
    box.Font = FGOTB; box.TextSize = 11; box.ZIndex = 11
    box.ClearTextOnFocus = false
    IN("UICorner", box).CornerRadius = U1(0, 6)
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
  MakeMenuToggle("SPEED OVERRIDE", SETTINGS.SPEED_ENABLED, function()
    SETTINGS.SPEED_ENABLED = true
  end)
  MakeInputRow("Speed Value:", SETTINGS.TARGET_SPEED, function(val)
    SETTINGS.TARGET_SPEED = val
  end)
  MakeInputRow("Steal Speed:", SETTINGS.STEAL_SPEED, function(val)
    SETTINGS.STEAL_SPEED = val
  end)
  MakeMenuToggle("UNWALK", SETTINGS.UNWALK, function(on)
    SETTINGS.UNWALK = on
  end)
  MakeInputRow("Grab Delay:", SETTINGS.GRAB_DELAY, function(val)
    SETTINGS.GRAB_DELAY = val
  end)
  MakeInputRow("Grab Radius:", SETTINGS.GRAB_RADIUS, function(val)
    SETTINGS.GRAB_RADIUS = val
  end)
  MakeMenuToggle("OPTIMIZER", false, function(on)
    if on then enableOptimizer() end
  end)
  MakeMenuToggle("XRAY BASE", XrayBase.Enabled, function(on)
    if on then enableXrayBase() else disableXrayBase() end
  end)
  local menuSaveBtn = IN("TextButton", menuScroll)
  menuSaveBtn.Size = U2(1, -20, 0, 34)
  menuSaveBtn.Position = U2(0, 10, 0, yOff)
  menuSaveBtn.BackgroundColor3 = C3(0,0,0); menuSaveBtn.BackgroundTransparency = 0.45
  menuSaveBtn.Text = "SAVE MENU CONFIG"; menuSaveBtn.TextColor3 = C3(200,200,200)
  menuSaveBtn.Font = FGOTB; menuSaveBtn.TextSize = 11; menuSaveBtn.ZIndex = 11
  IN("UICorner", menuSaveBtn).CornerRadius = U1(0, 8)
  AddOutline(menuSaveBtn)
  menuSaveBtn.MouseButton1Click:Connect(function()
    saveMenuConfig(); saveKeybinds()
    menuSaveBtn.Text = "SAVED!"; menuSaveBtn.TextColor3 = C3(255,255,255)
    menuSaveBtn.BackgroundTransparency = 0.2
    task.delay(1.5, function()
      menuSaveBtn.Text = "SAVE MENU CONFIG"; menuSaveBtn.TextColor3 = C3(200,200,200)
      menuSaveBtn.BackgroundTransparency = 0.45
    end)
  end)
  yOff = yOff + 42
  -- Build KBIND tab
  local ALL_KEYS = {
    "Q","W","E","R","T","Y","U","I","O","P",
    "A","S","D","F","G","H","J","K","L",
    "Z","X","C","V","B","N","M",
    "One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Zero",
    "F1","F2","F3","F4","F5",
    -- Gamepad
    "GP:ButtonA","GP:ButtonB","GP:ButtonX","GP:ButtonY",
    "GP:ButtonL1","GP:ButtonR1","GP:ButtonL2","GP:ButtonR2",
    "GP:DPadUp","GP:DPadDown","GP:DPadLeft","GP:DPadRight",
  }
  local KBIND_ACTIONS = {"AutoGrab","Lock","AutoTP","Drop","Float","AutoLeft","AutoRight","Taunt"}
  local selectedAction = nil
  local actionBtns = {}
  local keyBtns = {}
  local function refreshKbindColors()
    for action, btn in pairs(actionBtns) do
      local isSelected = (selectedAction == action)
      btn.BackgroundColor3 = isSelected and C3(80,40,160) or C3(20,20,20)
      btn.TextColor3 = isSelected and C3(255,255,255) or C3(200,200,200)
      btn.BackgroundTransparency = isSelected and 0.1 or 0.5
    end
    for keyName, btn in pairs(keyBtns) do
      local isBound = false
      for _, act in ipairs(KBIND_ACTIONS) do
        if KEYBINDS[act] == keyName then isBound = true; break end
      end
      btn.BackgroundColor3 = isBound and C3(0,180,60) or C3(20,20,20)
      btn.TextColor3 = isBound and C3(255,255,255) or C3(180,180,180)
      btn.BackgroundTransparency = isBound and 0.1 or 0.5
    end
  end
  -- Action selector row
  local kbLbl = IN("TextLabel", kbindScroll)
  kbLbl.Size = U2(1, -20, 0, 20)
  kbLbl.Position = U2(0, 10, 0, 8)
  kbLbl.BackgroundTransparency = 1
  kbLbl.Text = "1. Seleziona azione  2. Premi tasto"
  kbLbl.TextColor3 = C3(160,160,160)
  kbLbl.Font = FGOTB; kbLbl.TextSize = 9; kbLbl.ZIndex = 11
  local kyOff = 32
  -- Draw action buttons (2 per row)
  for i, action in ipairs(KBIND_ACTIONS) do
    local col = (i-1) % 2
    local row = math.floor((i-1) / 2)
    local btn = IN("TextButton", kbindScroll)
    btn.Size = U2(0.5, -8, 0, 30)
    btn.Position = U2(col * 0.5, col == 0 and 10 or -2, 0, kyOff + row * 36)
    btn.BackgroundColor3 = C3(20,20,20)
    btn.BackgroundTransparency = 0.5
    local keyDisplay = KEYBINDS[action] or "-"
    btn.Text = action.."\n["..keyDisplay.."]"
    btn.TextColor3 = C3(200,200,200)
    btn.Font = FGOTB; btn.TextSize = 9; btn.ZIndex = 11
    IN("UICorner", btn).CornerRadius = U1(0,6)
    AddOutline(btn)
    actionBtns[action] = btn
    btn.MouseButton1Click:Connect(function()
      selectedAction = (selectedAction == action) and nil or action
      refreshKbindColors()
    end)
  end
  kyOff = kyOff + (math.ceil(#KBIND_ACTIONS / 2)) * 36 + 8
  -- Separator
  local sep = IN("Frame", kbindScroll)
  sep.Size = U2(1, -20, 0, 1)
  sep.Position = U2(0, 10, 0, kyOff)
  sep.BackgroundColor3 = C3(80,80,80); sep.BorderSizePixel = 0; sep.ZIndex = 11
  kyOff = kyOff + 8
  -- Key grid (6 per row)
  local COLS = 6
  local BTN_W = math.floor((240 - 20) / COLS) - 2
  for i, keyName in ipairs(ALL_KEYS) do
    local col = (i-1) % COLS
    local row = math.floor((i-1) / COLS)
    local label = keyName:gsub("GP:Button",""):gsub("GP:DPad","â†•"):gsub("GP:","")
    if #label > 4 then label = label:sub(1,4) end
    local btn = IN("TextButton", kbindScroll)
    btn.Size = U2(0, BTN_W, 0, BTN_W)
    btn.Position = U2(0, 10 + col * (BTN_W + 2), 0, kyOff + row * (BTN_W + 2))
    btn.BackgroundColor3 = C3(20,20,20)
    btn.BackgroundTransparency = 0.5
    btn.Text = label
    btn.TextColor3 = C3(180,180,180)
    btn.Font = FGOTB; btn.TextSize = 9; btn.ZIndex = 11
    IN("UICorner", btn).CornerRadius = U1(0,4)
    keyBtns[keyName] = btn
    btn.MouseButton1Click:Connect(function()
      if not selectedAction then return end
      -- Unbind old key for this action
      KEYBINDS[selectedAction] = keyName
      -- Update action button label
      if actionBtns[selectedAction] then
        actionBtns[selectedAction].Text = selectedAction.."\n["..keyName.."]"
      end
      selectedAction = nil
      refreshKbindColors()
      saveKeybinds()
    end)
  end
  refreshKbindColors()
  -- Resize panel based on content
  panel.Size = U2(0, 240, 0, 420)
end
MakeDraggable(MenuBtn, function()
  menuOpen = not menuOpen
  if menuOpen then
    MenuBtn.Text = "MENU\nOPEN"
    MenuBtn.BackgroundTransparency = 0.2
    MenuBtn.TextColor3 = C3(255, 255, 255)
    buildMenuPanel()
  else
    MenuBtn.Text = "MENU"
    MenuBtn.BackgroundTransparency = 0.45
    MenuBtn.TextColor3 = C3(200, 200, 200)
    if menuPanel then
      menuPanel:Destroy()
      menuPanel = nil
    end
  end
end)
local AutoLeftHUD, setAutoLeftState = MakeHUDButton("AutoLeft", "AUTO LEFT", function(on)
  SETTINGS.AUTOLEFT = on
  if on then
    SETTINGS.AUTORIGHT = false
    stopMovement()
    startMovement("left")
  else
    stopMovement()
  end
end)
local AutoRightHUD, setAutoRightState = MakeHUDButton("AutoRight", "AUTO RIGHT", function(on)
  SETTINGS.AUTORIGHT = on
  if on then
    SETTINGS.AUTOLEFT = false
    stopMovement()
    startMovement("right")
  else
    stopMovement()
  end
end)
SETTINGS.SPEED_ENABLED = true
if SETTINGS.ENABLED then setAutoGrabState(true) end
if SETTINGS.LOCK_ENABLED then setLockState(true); equipBat(); startAutoSwing() end
if SETTINGS.FLOAT then setFloatState(true) end
if SETTINGS.AUTOLEFT then setAutoLeftState(true); startMovement("left") end
if SETTINGS.AUTORIGHT then setAutoRightState(true); startMovement("right") end
if SETTINGS.SPIN_ENABLED then applySpin() end
RunService.Heartbeat:Connect(function()
  local char = LocalPlayer.Character
  if not char then return end
  local hum = char:FindFirstChildOfClass("Humanoid")
  local hrp = char:FindFirstChild("HumanoidRootPart")
  if not hrp or not hum then return end
  speedLabel.Text = math.floor(hrp.AssemblyLinearVelocity.Magnitude) .. " sp"
  if SETTINGS.AUTOLEFT and SETTINGS.AUTORIGHT then
    SETTINGS.AUTORIGHT = false
    setAutoRightState(false)
    stopMovement()
  end
  updateWalking(hrp)
  if SETTINGS.LOCK_ENABLED then
    if not char:FindFirstChild("Bat") then
      equipBat()
    end
    local target, dist, torso = findNearestEnemy(hrp)
    if target and torso then
      local predicted = torso.Position + target.AssemblyLinearVelocity * 0.08
      local fullDir = predicted - hrp.Position
      if fullDir.Magnitude > 0.8 then
        local u = fullDir.Unit
        local spd = SETTINGS.LOCK_SPEED
        if dist < 4 then
          spd = spd * 0.4
        end
        hrp.AssemblyLinearVelocity = V3(
          u.X * spd,
          hrp.AssemblyLinearVelocity.Y,
          u.Z * spd
        )
      else
        hrp.AssemblyLinearVelocity = V3(
          target.AssemblyLinearVelocity.X,
          hrp.AssemblyLinearVelocity.Y,
          target.AssemblyLinearVelocity.Z
        )
      end
    end
  elseif SETTINGS.SPEED_ENABLED then
    if isStealing then
      hum.WalkSpeed = SETTINGS.STEAL_SPEED
    else
      hum.WalkSpeed = SETTINGS.TARGET_SPEED
    end
  end
  if SETTINGS.ENABLED and not stealLoopRunning then
    startStealLoop()
  end
  if SETTINGS.FLOAT then
    if not floatPart then
      floatHeight = hrp.Position.Y
      floatPart = IN("BodyPosition", hrp)
      floatPart.Name = "MelFloatBP"
      floatPart.MaxForce = V3(0, math.huge, 0)
      floatPart.D = 1000
      floatPart.P = 10000
      floatPart.Position = V3(hrp.Position.X, floatHeight, hrp.Position.Z)
    else
      floatPart.Position = V3(hrp.Position.X, floatHeight, hrp.Position.Z)
    end
  elseif floatPart then
    floatPart:Destroy()
    floatPart = nil
  end

end)
print("[Meloska DUEL v3] Caricato!")
