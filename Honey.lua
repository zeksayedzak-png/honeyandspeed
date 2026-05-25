--[[
    🐝 HONEYCOMB AUTO-FARM & SPEED UI
    ✅ تلقائي الانتقال لـ Honeycomb.001
    ✅ شريط تحكم بالسرعة (0-100)
    ✅ واجهة مستخدم متطورة للهواتف
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- متغيرات التحكم
local autoFarmEnabled = false
local playerSpeed = 16 -- السرعة الافتراضية لروبلوكس

-- ==================== دالة السحب (Draggable GUI) ====================
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ==================== بناء الواجهة (GUI) ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HoneycombSystem"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 220)
mainFrame.Position = UDim2.new(0.5, -100, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "🐝 HONEY HUB"
title.Size = UDim2.new(1, 0, 0, 40)
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- زر الـ Auto Farm (On/Off)
local toggleContainer = Instance.new("TextButton")
toggleContainer.Text = ""
toggleContainer.Size = UDim2.new(0.8, 0, 0, 40)
toggleContainer.Position = UDim2.new(0.1, 0, 0.25, 0)
toggleContainer.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleContainer.AutoButtonColor = false
toggleContainer.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleContainer

local toggleCircle = Instance.new("Frame")
toggleCircle.Size = UDim2.new(0, 30, 0, 30)
toggleCircle.Position = UDim2.new(0.05, 0, 0.5, -15)
toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleCircle.Parent = toggleContainer

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = toggleCircle

local toggleText = Instance.new("TextLabel")
toggleText.Text = "AUTO FARM: OFF"
toggleText.Size = UDim2.new(1, 0, 1, 0)
toggleText.BackgroundTransparency = 1
toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleText.Font = Enum.Font.GothamBold
toggleText.TextSize = 12
toggleText.Parent = toggleContainer

-- نظام السرعة (Slider)
local speedTitle = Instance.new("TextLabel")
speedTitle.Text = "Speed: 16"
speedTitle.Size = UDim2.new(1, 0, 0, 20)
speedTitle.Position = UDim2.new(0, 0, 0.55, 0)
speedTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
speedTitle.BackgroundTransparency = 1
speedTitle.Font = Enum.Font.Gotham
speedTitle.Parent = mainFrame

local sliderBack = Instance.new("Frame")
sliderBack.Name = "SliderBack"
sliderBack.Size = UDim2.new(0.8, 0, 0, 6)
sliderBack.Position = UDim2.new(0.1, 0, 0.75, 0)
sliderBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderBack.Parent = mainFrame

local sliderBtn = Instance.new("TextButton")
sliderBtn.Name = "SliderBtn"
sliderBtn.Size = UDim2.new(0, 16, 0, 16)
sliderBtn.Position = UDim2.new(0.16, -8, 0.5, -8) -- القيمة 16 من 100
sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
sliderBtn.Text = ""
sliderBtn.Parent = sliderBack

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = sliderBtn

makeDraggable(mainFrame)

-- ==================== منطق البرمجة (Logic) ====================

-- 1. منطق الزر (Toggle)
toggleContainer.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        toggleContainer.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        toggleText.Text = "AUTO FARM: ON"
        toggleCircle:TweenPosition(UDim2.new(0.75, 0, 0.5, -15), "Out", "Quint", 0.3)
    else
        toggleContainer.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        toggleText.Text = "AUTO FARM: OFF"
        toggleCircle:TweenPosition(UDim2.new(0.05, 0, 0.5, -15), "Out", "Quint", 0.3)
    end
end)

-- 2. منطق شريط السرعة (Slider Logic)
local isSliding = false

local function updateSpeed(input)
    local rect = sliderBack.AbsolutePosition
    local width = sliderBack.AbsoluteSize.X
    local x = math.clamp(input.Position.X - rect.X, 0, width)
    local percentage = x / width
    sliderBtn.Position = UDim2.new(percentage, -8, 0.5, -8)
    
    playerSpeed = math.floor(percentage * 100)
    speedTitle.Text = "Speed: " .. playerSpeed
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = playerSpeed
    end
end

sliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSpeed(input)
    end
end)

-- 3. منطق الانتقال التلقائي للـ Honeycomb
task.spawn(function()
    while true do
        if autoFarmEnabled then
            pcall(function()
                local target = workspace.InteractiveEvents.QueenBee.RuntimeHoneycombs.Honeycomb:FindFirstChild("Honeycomb.001")
                if target and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- الانتقال مباشرة فوق القطعة قليلاً لضمان اللمس
                    player.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 2, 0)
                end
            end)
        end
        task.wait(0.1) -- سرعة التحديث
    end
end)

-- 4. الحفاظ على السرعة حتى عند الموت
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.5)
    hum.WalkSpeed = playerSpeed
end)

print("✅ Honeycomb Script Loaded Successfully!")
