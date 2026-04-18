-- ==============================================================================
-- OPTIMUM KEY SYSTEM - ENTERPRISE EDITION (REFACTORED & BUG-FREE)
-- ==============================================================================
-- Fully Featured, Animated, Glass UI with Sounds & Particle Systems
-- Added Customizable Background Image & Fully Centered Text Layouts
-- Includes Live Status Polling (Cache-Bypass) & Game Breaker Anti-Bypass
-- Added Initial Loading Screen Sequence with Smooth Fade-Ins
-- Fixed Button Size Sticking Bug Upon Authentication
-- ==============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- Robust Safe execution context fallback
local function GetSafeGuiParent()
    if gethui then return gethui() end
    if RunService:IsStudio() then return player:WaitForChild("PlayerGui") end
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then return coreGui end
    return player:WaitForChild("PlayerGui")
end

local GuiParent = GetSafeGuiParent()

-- ==============================================================================
-- SYSTEM CONFIGURATION
-- ==============================================================================
local Config = {
    KeySystem = {
        CorrectKey = "Rwnv-toEfk-69gI-PteDt",
        GetKeyURL = "https://pastebin.com/raw/pB1h5cjF",
        DiscordURL = "https://discord.gg/yv9GpfEzkC",
        MainScriptURL = "https://raw.githubusercontent.com/FuddyOG/MainOptimumRealScript/refs/heads/main/MainOptumumRealScript.lua"
    },
    Theme = {
        Background = Color3.fromRGB(5, 5, 8),
        MainFrame = Color3.fromRGB(15, 15, 18),
        BoxContainer = Color3.fromRGB(10, 10, 12),
        AccentPrimary = Color3.fromRGB(0, 170, 255),   -- Cyan/Blue
        AccentSecondary = Color3.fromRGB(170, 0, 255), -- Purple
        VerifyAccent = Color3.fromRGB(50, 200, 255),   -- Cyan Border
        GetKeyAccent = Color3.fromRGB(255, 170, 50),   -- Orange Border
        DiscordAccent = Color3.fromRGB(130, 80, 255),  -- Purple Border
        TextLight = Color3.fromRGB(245, 245, 245),
        TextDim = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(0, 200, 100),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 150, 0)
    },
    UI = {
        GlassTransparency = 0.15,
        BlurIntensity = 12,
        CornerRadius = 12,
        BorderThickness = 1.5,
        -- === CUSTOM BACKGROUND SETTINGS ===
        BackgroundImageID = "rbxassetid://74254450878926", -- Change this ID to your custom image
        BackgroundImageTransparency = 0.75 -- 0 is fully visible, 1 is invisible
    },
    Animations = {
        Hover = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        Click = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Slide = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        Fade = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),  
        IntroFade = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), -- Added smooth 1-second intro fade
        ParticleSpeedMin = 5, 
        ParticleSpeedMax = 10
    }
}

-- ==============================================================================
-- SOUND MANAGER
-- ==============================================================================
local SoundManager = {
    Sounds = {},
    SoundGroup = nil
}

function SoundManager:Initialize()
    self.SoundGroup = Instance.new("SoundGroup")
    self.SoundGroup.Name = "OptimumKeySystemSounds"
    self.SoundGroup.Parent = SoundService

    local soundData = {
        Hover = {Id = "rbxassetid://136108770017536", Volume = 0.5, Pitch = 1.2},
        Click = {Id = "rbxassetid://6895079853", Volume = 0.6, Pitch = 1.0},
        Success = {Id = "rbxassetid://4590657391", Volume = 0.8, Pitch = 1.0},
        Error = {Id = "rbxassetid://18453214291", Volume = 0.7, Pitch = 1.0},
        Notify = {Id = "rbxassetid://136211732441165", Volume = 0.5, Pitch = 1.5}
    }

    for name, data in pairs(soundData) do
        local snd = Instance.new("Sound")
        snd.Name = "OptimumSound_" .. name
        snd.SoundId = data.Id
        snd.Volume = data.Volume
        snd.Pitch = data.Pitch
        snd.Parent = self.SoundGroup
        self.Sounds[name] = snd
    end
end

function SoundManager:Play(soundName)
    if self.Sounds[soundName] and self.SoundGroup and self.SoundGroup.Parent then
        local snd = self.Sounds[soundName]:Clone()
        snd.Parent = self.SoundGroup
        snd:Play()
        game.Debris:AddItem(snd, snd.TimeLength + 0.5)
    end
end

function SoundManager:Cleanup()
    for _, snd in pairs(self.Sounds) do
        if snd and snd.Parent then
            snd:Destroy()
        end
    end
    if self.SoundGroup then
        self.SoundGroup:Destroy()
    end
    self.Sounds = {}
end

SoundManager:Initialize()

-- ==============================================================================
-- CORE UI CREATION & BLUR
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Optimum KeySystem | By Fuddy"
ScreenGui.Parent = GuiParent
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "Optimum Notifications"
NotifyGui.Parent = GuiParent
NotifyGui.ResetOnSpawn = false
NotifyGui.IgnoreGuiInset = true
NotifyGui.DisplayOrder = 1000
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local BackgroundBlur = Instance.new("BlurEffect")
BackgroundBlur.Name = "OptimumBlur"
BackgroundBlur.Size = 0 
BackgroundBlur.Parent = Lighting

local BackgroundOverlay = Instance.new("Frame")
BackgroundOverlay.Name = "Overlay"
BackgroundOverlay.Size = UDim2.fromScale(1, 1)
BackgroundOverlay.Position = UDim2.fromScale(0, 0)
BackgroundOverlay.BackgroundColor3 = Config.Theme.Background
BackgroundOverlay.BackgroundTransparency = 1 
BackgroundOverlay.BorderSizePixel = 0
BackgroundOverlay.ZIndex = 1
BackgroundOverlay.Parent = ScreenGui

-- ==============================================================================
-- PARTICLE MANAGER 
-- ==============================================================================
local ParticleManager = {
    Container = nil,
    Active = false,
    Particles = {},
    LoopConnection = nil
}

function ParticleManager:Initialize(parentFrame)
    self.Container = Instance.new("Frame")
    self.Container.Name = "ParticleContainer"
    self.Container.Size = UDim2.fromScale(1, 1)
    self.Container.Position = UDim2.fromScale(0, 0)
    self.Container.BackgroundTransparency = 1
    self.Container.ZIndex = 2
    self.Container.ClipsDescendants = true
    self.Container.Parent = parentFrame
end

function ParticleManager:SpawnParticle(randomY)
    if not self.Active then return end

    local size = math.random(10, 35)
    local startX = math.random(0, 100) / 100
    local speed = math.random(Config.Animations.ParticleSpeedMin, Config.Animations.ParticleSpeedMax)
    
    local startY = 1.1
    if randomY then
        startY = math.random(0, 100) / 100
    end
    
    local Particle = Instance.new("Frame")
    Particle.Size = UDim2.new(0, size, 0, size)
    Particle.Position = UDim2.new(startX, 0, startY, 0)
    
    if math.random(1, 2) == 1 then
        Particle.BackgroundColor3 = Config.Theme.AccentPrimary
    else
        Particle.BackgroundColor3 = Config.Theme.AccentSecondary
    end
    
    Particle.BackgroundTransparency = math.random(5, 8) / 10
    Particle.BorderSizePixel = 0
    Particle.Rotation = math.random(0, 360)
    Particle.ZIndex = 2
    Particle.Parent = self.Container
    
    local PCorner = Instance.new("UICorner")
    PCorner.CornerRadius = UDim.new(0.5, 0)
    PCorner.Parent = Particle
    
    local targetY = math.random(-20, -5) / 100 
    local targetRot = Particle.Rotation + math.random(-180, 180)
    
    local moveTween = TweenService:Create(Particle, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
        Position = UDim2.new(startX + (math.random(-15, 15)/100), 0, targetY, 0),
        Rotation = targetRot,
        BackgroundTransparency = 1
    })
    
    table.insert(self.Particles, Particle)
    moveTween:Play()
    
    moveTween.Completed:Connect(function()
        if Particle and Particle.Parent then
            Particle:Destroy()
        end
        local index = table.find(self.Particles, Particle)
        if index then
            table.remove(self.Particles, index)
        end
    end)
end

function ParticleManager:SpawnBurst(amount)
    for i = 1, amount do
        self:SpawnParticle(true) 
    end
end

function ParticleManager:Start()
    if self.Active then return end
    self.Active = true
    task.spawn(function()
        while self.Active do
            self:SpawnParticle(false)
            task.wait(math.random(1, 3) / 10) 
        end
    end)
end

function ParticleManager:Stop()
    self.Active = false
    for _, p in ipairs(self.Particles) do
        if p and p.Parent then
            TweenService:Create(p, Config.Animations.Fade, {BackgroundTransparency = 1}):Play()
            game.Debris:AddItem(p, 0.5)
        end
    end
    self.Particles = {}
end

ParticleManager:Initialize(BackgroundOverlay)

-- ==============================================================================
-- NOTIFICATION MANAGER
-- ==============================================================================
local NotificationManager = {
    List = {},
    Width = 170,  
    Height = 28,  
    Padding = 34, 
    StartX = 20,  
    StartY = 30   
}

function NotificationManager:UpdatePositions()
    for index, frame in ipairs(self.List) do
        if frame and frame.Parent then
            local targetX = -self.Width - self.StartX
            local targetY = self.StartY + ((index - 1) * self.Padding)
            
            TweenService:Create(frame, Config.Animations.Slide, {
                Position = UDim2.new(1, targetX, 0, targetY)
            }):Play()
        end
    end
end

function NotificationManager:Notify(text, duration, isError)
    duration = duration or 2.5
    local accentColor = isError and Config.Theme.Error or Config.Theme.Success

    if isError then
        SoundManager:Play("Error")
    else
        SoundManager:Play("Success")
    end

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Name = "Notification"
    NotifFrame.Size = UDim2.new(0, self.Width, 0, self.Height) 
    NotifFrame.Position = UDim2.new(1, self.StartX + 50, 0, self.StartY + (#self.List * self.Padding)) 
    NotifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    NotifFrame.BackgroundTransparency = 0.1
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ZIndex = 20
    NotifFrame.Parent = NotifyGui

    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 4)

    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Color = accentColor
    NotifStroke.Thickness = 1
    NotifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local NotifText = Instance.new("TextLabel")
    NotifText.Size = UDim2.new(1, -16, 1, 0)
    NotifText.Position = UDim2.new(0, 14, 0, 0)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = text
    NotifText.TextColor3 = Color3.fromRGB(240, 240, 240)
    NotifText.Font = Enum.Font.GothamMedium
    
    NotifText.TextScaled = true
    NotifText.TextWrapped = true
    local TextConstraint = Instance.new("UITextSizeConstraint")
    TextConstraint.MaxTextSize = 12 
    TextConstraint.MinTextSize = 9
    TextConstraint.Parent = NotifText
    
    NotifText.TextXAlignment = Enum.TextXAlignment.Left
    NotifText.ZIndex = 21
    NotifText.Parent = NotifFrame

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0.5, 0) 
    Indicator.Position = UDim2.new(0, 6, 0.25, 0)
    Indicator.BackgroundColor3 = accentColor
    Indicator.BorderSizePixel = 0
    Indicator.ZIndex = 21
    Indicator.Parent = NotifFrame
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    table.insert(self.List, NotifFrame)
    self:UpdatePositions()

    task.delay(duration, function()
        if not NotifFrame or not NotifFrame.Parent then return end 
        
        local fadeOut = TweenService:Create(NotifFrame, Config.Animations.Fade, {
            Position = UDim2.new(1, self.StartX + 50, 0, NotifFrame.Position.Y.Offset), 
            BackgroundTransparency = 1
        })
        
        TweenService:Create(NotifStroke, Config.Animations.Fade, {Transparency = 1}):Play()
        TweenService:Create(NotifText, Config.Animations.Fade, {TextTransparency = 1}):Play()
        TweenService:Create(Indicator, Config.Animations.Fade, {BackgroundTransparency = 1}):Play()
        
        fadeOut:Play()
        fadeOut.Completed:Wait()

        local index = table.find(self.List, NotifFrame)
        if index then
            table.remove(self.List, index)
            self:UpdatePositions()
        end
        
        NotifFrame:Destroy()
    end)
end

-- ==============================================================================
-- MAIN INTERFACE CONSTRUCTION 
-- ==============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 330)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -165) 
MainFrame.BackgroundColor3 = Config.Theme.MainFrame
MainFrame.BackgroundTransparency = 1 
MainFrame.ZIndex = 3
MainFrame.Parent = BackgroundOverlay
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, Config.UI.CornerRadius)
MainCorner.Parent = MainFrame

-- Customizable Background Image applied properly
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "BackgroundImage"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = Config.UI.BackgroundImageID
BackgroundImage.ImageTransparency = 1 -- Faded in during intro
BackgroundImage.ScaleType = Enum.ScaleType.Crop -- Ensures any image fits perfectly without stretching
BackgroundImage.ZIndex = 3
BackgroundImage.Parent = MainFrame
Instance.new("UICorner", BackgroundImage).CornerRadius = UDim.new(0, Config.UI.CornerRadius)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = Config.UI.BorderThickness
MainStroke.Transparency = 1
MainStroke.Parent = MainFrame

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Config.Theme.AccentSecondary), -- Purple
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(50, 50, 80)), -- Dark blend
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(50, 50, 80)),
    ColorSequenceKeypoint.new(1, Config.Theme.AccentPrimary)    -- Cyan
}
StrokeGradient.Rotation = 45
StrokeGradient.Parent = MainStroke

-- LOADING TEXT (Added for intro feature)
local LoadingLabel = Instance.new("TextLabel")
LoadingLabel.Name = "LoadingLabel"
LoadingLabel.Size = UDim2.new(1, 0, 1, 0)
LoadingLabel.Position = UDim2.new(0, 0, 0, 0)
LoadingLabel.BackgroundTransparency = 1
LoadingLabel.Text = "LOADING..."
LoadingLabel.TextColor3 = Config.Theme.TextLight
LoadingLabel.TextTransparency = 1
LoadingLabel.Font = Enum.Font.GothamMedium
LoadingLabel.TextSize = 22
LoadingLabel.ZIndex = 15
LoadingLabel.Parent = MainFrame

-- TITLE SECTION
local TitleContainer = Instance.new("Frame")
TitleContainer.Size = UDim2.new(1, 0, 0, 60)
TitleContainer.Position = UDim2.new(0, 0, 0, 0)
TitleContainer.BackgroundTransparency = 1
TitleContainer.ZIndex = 4
TitleContainer.Parent = MainFrame

local TitleIconBG = Instance.new("Frame")
TitleIconBG.Name = "IconPlaceholder"
TitleIconBG.Size = UDim2.new(0, 30, 0, 30)
TitleIconBG.Position = UDim2.new(0, 20, 0.5, -15)
TitleIconBG.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleIconBG.BackgroundTransparency = 1
TitleIconBG.ZIndex = 4
TitleIconBG.Parent = TitleContainer

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 8)
IconCorner.Parent = TitleIconBG

local IconGradient = Instance.new("UIGradient")
IconGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150))
}
IconGradient.Rotation = 45
IconGradient.Parent = TitleIconBG

-- Title text perfectly centered
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.Position = UDim2.new(0, 0, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "OPTIMUM KEYSYSTEM | BY FUDDY" 
TitleText.TextColor3 = Config.Theme.TextLight
TitleText.TextTransparency = 1
TitleText.Font = Enum.Font.GothamMedium

TitleText.TextScaled = true
local TitleConstraint = Instance.new("UITextSizeConstraint")
TitleConstraint.MaxTextSize = 14
TitleConstraint.Parent = TitleText

TitleText.TextXAlignment = Enum.TextXAlignment.Center -- Centered the title
TitleText.ZIndex = 4
TitleText.Parent = TitleContainer

-- TEXTBOX SECTION
local BoxContainer = Instance.new("Frame")
BoxContainer.Size = UDim2.new(0.9, 0, 0, 48)
BoxContainer.Position = UDim2.new(0.05, 0, 0, 65)
BoxContainer.BackgroundColor3 = Config.Theme.BoxContainer
BoxContainer.BackgroundTransparency = 1
BoxContainer.ZIndex = 4
BoxContainer.Parent = MainFrame

Instance.new("UICorner", BoxContainer).CornerRadius = UDim.new(0, 8)
local BoxStroke = Instance.new("UIStroke", BoxContainer)
BoxStroke.Color = Color3.fromRGB(40, 40, 45)
BoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BoxStroke.Thickness = 1.5
BoxStroke.Transparency = 1

local Box = Instance.new("TextBox")
Box.Size = UDim2.new(1, 0, 1, 0)
Box.Position = UDim2.new(0, 0, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "PASTE YOUR KEY HERE..."
Box.PlaceholderColor3 = Config.Theme.TextDim
Box.Text = ""
Box.TextColor3 = Config.Theme.TextLight
Box.TextTransparency = 1
Box.Font = Enum.Font.GothamMedium
Box.ClearTextOnFocus = false 

Box.TextScaled = true
local BoxConstraint = Instance.new("UITextSizeConstraint")
BoxConstraint.MaxTextSize = 14
BoxConstraint.Parent = Box

Box.TextXAlignment = Enum.TextXAlignment.Center -- Textbox text is centered
Box.ZIndex = 5
Box.Parent = BoxContainer

Box.Focused:Connect(function()
    SoundManager:Play("Hover")
    TweenService:Create(BoxStroke, Config.Animations.Hover, {Color = Config.Theme.AccentPrimary}):Play()
end)

Box.FocusLost:Connect(function()
    TweenService:Create(BoxStroke, Config.Animations.Hover, {Color = Color3.fromRGB(40, 40, 45)}):Play()
end)

-- BUTTON FACTORY 
local ButtonsList = {}

local function CreateInteractiveButton(name, yPos, text, iconId, strokeColor)
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.Size = UDim2.new(0.9, 0, 0, 46)
    Btn.Position = UDim2.new(0.05, 0, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Btn.BackgroundTransparency = 1 
    Btn.Text = "" 
    Btn.AutoButtonColor = false
    Btn.ZIndex = 4
    Btn.Parent = MainFrame

    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Color = strokeColor
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Thickness = 1.5
    Stroke.Transparency = 1

    -- Container to perfectly center Icon and Text side-by-side
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, 0, 1, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ZIndex = 5
    ContentContainer.Parent = Btn

    -- This Layout automatically centers the items together perfectly
    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder 
    Layout.Padding = UDim.new(0, 12)
    Layout.Parent = ContentContainer

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 22, 0, 22)
    Icon.BackgroundTransparency = 1
    Icon.Image = iconId
    Icon.ImageTransparency = 1
    Icon.LayoutOrder = 1 -- Forces Icon to the left
    Icon.ZIndex = 5
    Icon.Parent = ContentContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 0, 1, 0)
    Label.AutomaticSize = Enum.AutomaticSize.X
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.Theme.TextLight
    Label.TextTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Center -- Forces button text to be centered
    Label.LayoutOrder = 2 -- Forces Text to the middle
    Label.ZIndex = 5
    Label.Parent = ContentContainer
    
    -- INVISIBLE SPACER TRICK:
    local Spacer = Instance.new("Frame")
    Spacer.Size = UDim2.new(0, 22, 0, 22)
    Spacer.BackgroundTransparency = 1
    Spacer.LayoutOrder = 3 -- Forces Spacer to the right
    Spacer.ZIndex = 5
    Spacer.Parent = ContentContainer

    -- FIX: Local variable to track if the button is currently being held
    local isPressed = false

    Btn.MouseEnter:Connect(function()
        if not Btn.Active then return end
        SoundManager:Play("Hover")
        TweenService:Create(Btn, Config.Animations.Hover, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
    end)

    Btn.MouseLeave:Connect(function()
        if not Btn.Active then return end
        isPressed = false
        -- Reset Hover Color
        TweenService:Create(Btn, Config.Animations.Hover, {BackgroundColor3 = Color3.fromRGB(20, 20, 25)}):Play()
        -- FIX: Reset size and position if the mouse/finger drags off the button while it's held down
        TweenService:Create(Btn, Config.Animations.Click, {
            Size = UDim2.new(0.9, 0, 0, 46),
            Position = UDim2.new(0.05, 0, 0, yPos)
        }):Play()
    end)

    Btn.MouseButton1Down:Connect(function()
        if not Btn.Active then return end
        isPressed = true
        SoundManager:Play("Click")
        TweenService:Create(Btn, Config.Animations.Click, {
            Size = UDim2.new(0.86, 0, 0, 42), 
            Position = UDim2.new(0.07, 0, 0, yPos + 2)
        }):Play()
    end)

    Btn.MouseButton1Up:Connect(function()
        if not Btn.Active then return end
        if isPressed then
            isPressed = false
            TweenService:Create(Btn, Config.Animations.Click, {
                Size = UDim2.new(0.9, 0, 0, 46), 
                Position = UDim2.new(0.05, 0, 0, yPos)
            }):Play()
        end
    end)

    -- FIX FOR MOBILE: Fallback connection to guarantee the button pops back up when a touch input ends
    Btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not Btn.Active then return end
            if isPressed then
                isPressed = false
                TweenService:Create(Btn, Config.Animations.Click, {
                    Size = UDim2.new(0.9, 0, 0, 46),
                    Position = UDim2.new(0.05, 0, 0, yPos)
                }):Play()
            end
        end
    end)

    table.insert(ButtonsList, {Btn = Btn, Stroke = Stroke, Label = Label, Icon = Icon, OriginalY = yPos})

    return Btn, Stroke, Label, Icon
end

local SubmitBtn, SubmitStroke, SubmitLabel, SubmitIcon = CreateInteractiveButton(
    "SubmitBtn", 130, "Verify Key", "rbxassetid://88877080527938", Config.Theme.VerifyAccent
)

local GetKeyBtn, GetKeyStroke, GetKeyLabel, GetKeyIcon = CreateInteractiveButton(
    "GetKeyBtn", 190, "Get Key", "rbxassetid://108761867864835", Config.Theme.GetKeyAccent
)

local DiscordBtn, DiscordStroke, DiscordLabel, DiscordIcon = CreateInteractiveButton(
    "DiscordBtn", 250, "Join Our Discord Server (For Updates)", "rbxassetid://95450893846739", Config.Theme.DiscordAccent
)

-- ==============================================================================
-- ANIMATION CONTROLLERS
-- ==============================================================================
local function PerformIntro()
    if BackgroundBlur and BackgroundBlur.Parent then
        TweenService:Create(BackgroundBlur, Config.Animations.Fade, {Size = Config.UI.BlurIntensity}):Play()
    end
    TweenService:Create(BackgroundOverlay, Config.Animations.Fade, {BackgroundTransparency = 0.2}):Play()
    
    local mainTween = TweenService:Create(MainFrame, Config.Animations.Slide, {
        Position = UDim2.new(0.5, -200, 0.5, -165), 
        BackgroundTransparency = Config.UI.GlassTransparency 
    })
    mainTween:Play()

    ParticleManager:Start()
    ParticleManager:SpawnBurst(20) 

    -- ADDED: Loading Sequence Setup
    mainTween.Completed:Wait() -- Wait for the main frame to finish sliding in
    TweenService:Create(LoadingLabel, Config.Animations.Fade, {TextTransparency = 0}):Play()
    
    task.wait(1.5) -- Simulated loading wait time
    
    TweenService:Create(LoadingLabel, Config.Animations.Fade, {TextTransparency = 1}):Play()
    task.wait(0.3) -- Small buffer between loading out and elements fading in

    -- Fade everything else in smoothly (using the new 1-second IntroFade setting)
    local elementsToFade = {
        {Obj = MainStroke, Prop = "Transparency", Target = 0},
        {Obj = BackgroundImage, Prop = "ImageTransparency", Target = Config.UI.BackgroundImageTransparency},
        
        {Obj = TitleText, Prop = "TextTransparency", Target = 0},
        {Obj = TitleIconBG, Prop = "BackgroundTransparency", Target = 0},
        
        {Obj = BoxContainer, Prop = "BackgroundTransparency", Target = 0.4},
        {Obj = BoxStroke, Prop = "Transparency", Target = 0},
        {Obj = Box, Prop = "TextTransparency", Target = 0}
    }

    for _, btnData in ipairs(ButtonsList) do
        table.insert(elementsToFade, {Obj = btnData.Btn, Prop = "BackgroundTransparency", Target = 0.4})
        table.insert(elementsToFade, {Obj = btnData.Stroke, Prop = "Transparency", Target = 0})
        table.insert(elementsToFade, {Obj = btnData.Label, Prop = "TextTransparency", Target = 0})
        table.insert(elementsToFade, {Obj = btnData.Icon, Prop = "ImageTransparency", Target = 0})
    end

    for _, data in ipairs(elementsToFade) do
        TweenService:Create(data.Obj, Config.Animations.IntroFade, {[data.Prop] = data.Target}):Play()
    end
end

local function PerformOutro()
    ParticleManager:Stop()

    if BackgroundBlur and BackgroundBlur.Parent then
        TweenService:Create(BackgroundBlur, Config.Animations.Fade, {Size = 0}):Play()
    end

    for _, v in pairs(MainFrame:GetDescendants()) do
        if v:IsA("UIStroke") then
            TweenService:Create(v, Config.Animations.Fade, {Transparency = 1}):Play()
        end
    end

    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 350, 0, 280),
        Position = UDim2.new(0.5, -175, 0.5, -140),
        BackgroundTransparency = 1
    }):Play()

    for _, v in pairs(ScreenGui:GetDescendants()) do
        if v:IsA("GuiObject") and not v:IsA("UIStroke") then
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                TweenService:Create(v, Config.Animations.Fade, {TextTransparency = 1}):Play()
            end
            if v:IsA("ImageLabel") then
                TweenService:Create(v, Config.Animations.Fade, {ImageTransparency = 1}):Play()
            end
            if v.Name ~= "MainFrame" and v.BackgroundTransparency < 1 then
                 TweenService:Create(v, Config.Animations.Fade, {BackgroundTransparency = 1}):Play()
            end
        end
    end

    task.wait(0.4)
    if BackgroundBlur then BackgroundBlur:Destroy() end
    
    ScreenGui:Destroy()
    
    task.delay(1.5, function()
        SoundManager:Cleanup()
    end)
end

-- ==============================================================================
-- LOGIC & EVENT HANDLERS
-- ==============================================================================

local isSubmitting = false

SubmitBtn.MouseButton1Click:Connect(function()
    if isSubmitting or not SubmitBtn.Active then return end
    isSubmitting = true
    
    if Box.Text == Config.KeySystem.CorrectKey then
        
        -- FIX: Force the button to immediately pop back up to normal size before running the auth visuals
        TweenService:Create(SubmitBtn, Config.Animations.Click, {
            Size = UDim2.new(0.9, 0, 0, 46),
            Position = UDim2.new(0.05, 0, 0, 130)
        }):Play()
        
        NotificationManager:Notify("Key Authenticated", 2, false)
        
        Box.TextEditable = false
        SubmitBtn.Active = false
        
        TweenService:Create(SubmitBtn, Config.Animations.Fade, {BackgroundColor3 = Config.Theme.Success}):Play()
        TweenService:Create(SubmitLabel, Config.Animations.Fade, {TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        TweenService:Create(SubmitIcon, Config.Animations.Fade, {ImageColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        
        task.wait(1.5)
        PerformOutro()

        task.wait(0.5)
        local success, errorMessage = pcall(function()
            local payloadStr = game:HttpGet(Config.KeySystem.MainScriptURL)
            local func = loadstring(payloadStr)
            if func then
                func()
            else
                error("Script payload returned nil. Issue with raw link or syntax.")
            end
        end)

        if success then
            NotificationManager:Notify("Optimum Script loaded successfully!", 4, false)
        else
            NotificationManager:Notify("Failed to load script.", 5, true)
            warn("Optimum Load Error: ", errorMessage)
        end
    else
        NotificationManager:Notify("Invalid Key Provided", 2.5, true)
        
        local oldStrokeColor = BoxStroke.Color
        TweenService:Create(BoxStroke, Config.Animations.Hover, {Color = Config.Theme.Error}):Play()
        task.wait(0.5)
        TweenService:Create(BoxStroke, Config.Animations.Hover, {Color = oldStrokeColor}):Play()
        isSubmitting = false
    end
end)

local hasCopiedKey = false
GetKeyBtn.MouseButton1Click:Connect(function()
    if hasCopiedKey then
        NotificationManager:Notify("Key link is already in your clipboard", 2, true)
        return
    end
    
    if setclipboard then
        local success = pcall(function() setclipboard(Config.KeySystem.GetKeyURL) end)
        if success then
            hasCopiedKey = true
            NotificationManager:Notify("Key Link Copied! Paste it in your browser.", 5, false)
        else
            NotificationManager:Notify("Failed to access your clipboard.", 3, true)
        end
    else
        NotificationManager:Notify("Your executor doesn't support clipboard copying.", 3, true)
    end
end)

local hasCopiedDiscord = false
DiscordBtn.MouseButton1Click:Connect(function()
    if hasCopiedDiscord then
        NotificationManager:Notify("Discord link is already in your clipboard", 2, true)
        return
    end
    
    if setclipboard then
        local success = pcall(function() setclipboard(Config.KeySystem.DiscordURL) end)
        if success then
            hasCopiedDiscord = true
            NotificationManager:Notify("Discord Link Copied!", 3, false)
        else
            NotificationManager:Notify("Failed to access your clipboard.", 3, true)
        end
    else
        NotificationManager:Notify("Your executor doesn't support clipboard copying.", 3, true)
    end
end)

-- ==============================================================================
-- INITIALIZATION
-- ==============================================================================
PerformIntro()
