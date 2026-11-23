-- ============================================================
--  HOÀNG LONG SIGMAMEOMEOPLS
--  Tối ưu cho Delta Executor | ESP, Fly, Noclip
--  Credit: TIKTOK HLONG🍃 V9.99.99 max
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Trạng thái
local ESP_ENABLED = false
local FLY_ENABLED = false
local NOCLIP_ENABLED = false

local ESP_CACHE = {}
local flyVelocity, flyGyro = nil, nil
local FLY_SPEED = 50

-- ============================================================
--  1. TẠO MENU (TƯƠNG THÍCH DELTA)
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoangLongMenu"
ScreenGui.ResetOnSpawn = false

-- Thử CoreGui trước (Delta thường chặn), fallback về PlayerGui
local guiParent
local success = pcall(function()
    guiParent = CoreGui
    ScreenGui.Parent = CoreGui
end)
if not success or not ScreenGui.Parent then
    guiParent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.Parent = guiParent
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 260)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(100, 160, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 40, 70)
Title.BorderSizePixel = 0
Title.Text = "hoàng long SIGMAMEOMEOPLS"
Title.TextColor3 = Color3.fromRGB(200, 220, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local function createToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 55, 80)
    btn.Text = text .. " : OFF"
    btn.TextColor3 = Color3.fromRGB(180, 200, 240)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " : " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 120, 80) or Color3.fromRGB(45, 55, 80)
        callback(state)
    end)
    return btn
end

createToggle("ESP Người Chơi", 45, function(state)
    ESP_ENABLED = state
    if state then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then createESP(plr) end
        end
    else
        clearAllESP()
    end
end)

createToggle("Fly (Bay)", 85, function(state)
    FLY_ENABLED = state
    if state then startFly() else stopFly() end
end)

createToggle("Noclip (Xuyên Tường)", 125, function(state)
    NOCLIP_ENABLED = state
end)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, -20, 0, 25)
Credit.Position = UDim2.new(0, 10, 1, -35)
Credit.BackgroundTransparency = 1
Credit.Text = "TIKTOK HLONG🍃 V9.99.99 max"
Credit.TextColor3 = Color3.fromRGB(120, 255, 120)
Credit.TextSize = 13
Credit.Font = Enum.Font.GothamBold
Credit.Parent = MainFrame

local menuVisible = true
CloseBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    TweenService:Create(MainFrame, TweenInfo.new(0.2), {
        Size = menuVisible and UDim2.new(0, 280, 0, 260) or UDim2.new(0, 280, 0, 35)
    }):Play()
    CloseBtn.Text = menuVisible and "✕" or "☰"
end)

-- ============================================================
--  2. ESP BẰNG HIGHLIGHT (TƯƠNG THÍCH DELTA)
-- ============================================================
local function createESP(plr)
    if ESP_CACHE[plr] then return end
    local char = plr.Character
    if not char then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "HL_ESP"
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(255, 80, 80)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char

    ESP_CACHE[plr] = highlight

    plr.CharacterRemoving:Connect(function()
        if ESP_CACHE[plr] then
            ESP_CACHE[plr]:Destroy()
            ESP_CACHE[plr] = nil
        end
    end)
end

local function clearAllESP()
    for plr, hl in pairs(ESP_CACHE) do
        if hl then hl:Destroy() end
        ESP_CACHE[plr] = nil
    end
end

Players.PlayerAdded:Connect(function(plr)
    if ESP_ENABLED and plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function()
            task.wait(1)
            if ESP_ENABLED then createESP(plr) end
        end)
    end
end)

-- ============================================================
--  3. FLY
-- ============================================================
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = hrp

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyGyro.CFrame = hrp.CFrame
    flyGyro.Parent = hrp

    humanoid.PlatformStand = true

    local flyConnection
    flyConnection = RunService.Heartbeat:Connect(function()
        if not FLY_ENABLED then
            flyConnection:Disconnect()
            return
        end

        local moveDir = Vector3.zero
        local camCFrame = Camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            flyVelocity.Velocity = moveDir.Unit * FLY_SPEED
        else
            flyVelocity.Velocity = Vector3.zero
        end

        flyGyro.CFrame = camCFrame
    end)
end

local function stopFly()
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    if flyGyro then flyGyro:Destroy(); flyGyro = nil end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- ============================================================
--  4. NOCLIP
-- ============================================================
RunService.Stepped:Connect(function()
    if not NOCLIP_ENABLED then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- ============================================================
--  5. HỒI SINH
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    if FLY_ENABLED then
        stopFly()
        task.wait(0.5)
        startFly()
    end
    if ESP_ENABLED then
        task.wait(1)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then createESP(plr) end
        end
    end
end)

print("[Hoàng Long Menu] Đã tải thành công trên Delta!")
print("TIKTOK HLONG🍃 V9.99.99 max")
