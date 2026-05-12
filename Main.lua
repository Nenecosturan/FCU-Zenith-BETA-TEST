-- ============================================================================
-- •PIOP• ZENITH V18 - AESTHETIC ULTRA EDITION (STABİL SÜRÜM)
-- YENİ: BAĞIMSIZ KAPANIŞ EKRANI | TELEPORT KORUMASI | AUTOEXEC DOSYA SİSTEMİ
-- YENİ (EK): ŞİFRELİ DEV PANEL (RGB) | DERİN MOTOR OPTİMİZASYONLARI
-- ============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- [0. OTOMATİK BAŞLAMA VE DOSYA SİSTEMİ MANTIĞI]
local StateFileName = "ZenithClosed_State.txt"
local LoadstringURL = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Nenecosturan/FPS-CAP-SCR-PT/refs/heads/main/Main.lua"))()'

-- Eğer kullanıcı scripti kapatma tuşuyla kapattıysa, autoexec klasöründen çalışmasını engellemek için kontrol
if isfile and isfile(StateFileName) then
    local state = readfile(StateFileName)
    if state == "CLOSED" then
        -- Durumu sıfırla ki kullanıcı manuel olarak tekrar çalıştırabilsin
        if delfile then delfile(StateFileName) end 
        return -- Scripti burada durdur
    end
end

-- Sunucu değiştirmelerde (Teleport) otomatik tekrar çalışması için sıraya al
if queue_on_teleport then
    queue_on_teleport(LoadstringURL)
end

-- [1. TEMA AYARLARI]
local Theme = {
    Main = Color3.fromRGB(11, 13, 19),
    Secondary = Color3.fromRGB(18, 20, 28),
    Accent = Color3.fromRGB(0, 180, 255),
    Text = Color3.fromRGB(240, 240, 250),
    SubText = Color3.fromRGB(160, 165, 180),
    Red = Color3.fromRGB(255, 70, 70),
    Yellow = Color3.fromRGB(255, 200, 0),
    Green = Color3.fromRGB(0, 255, 130),
    Easing = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
}

-- [2. YENİ DONANIM TESPİTİ (120+ DESTEKLİ)]
local MaxHardwareHz = "60"
task.spawn(function()
    if setfpscap then
        setfpscap(999)
        local frameTimes = {}
        for i = 1, 30 do table.insert(frameTimes, RunService.RenderStepped:Wait()) end
        local avg = 0
        for _, t in pairs(frameTimes) do avg = avg + t end
        local detected = math.floor((1 / (avg / #frameTimes)) + 5)
        
        if detected >= 124 then
            MaxHardwareHz = "120+"
        elseif detected >= 63 then
            MaxHardwareHz = "120"
        else
            MaxHardwareHz = "60"
        end
        
        setfpscap(60)
    end
end)

-- [3. ANA GUI]
local Zenith = Instance.new("ScreenGui")
Zenith.Name = "•FPS-CAP-UNLOCKER• by ZENITH"
pcall(function() Zenith.Parent = CoreGui end)

local UI = {}
function UI:Smooth(obj, rad) Instance.new("UICorner", obj).CornerRadius = UDim.new(0, rad) end
function UI:Stroke(obj, color, trans)
    local s = Instance.new("UIStroke", obj)
    s.Thickness = 1.5; s.Color = color or Theme.Accent
    s.Transparency = trans or 0.4; s.ApplyStrokeMode = "Border"
end

-- Yüzer FPS HUD (Düzgün Sayıcı)
local FloatingHUD = Instance.new("Frame", Zenith)
FloatingHUD.Size = UDim2.new(0, 100, 0, 32)
FloatingHUD.Position = UDim2.new(1, -115, 0, 15)
FloatingHUD.BackgroundColor3 = Theme.Secondary
FloatingHUD.Visible = false
UI:Smooth(FloatingHUD, 8)
UI:Stroke(FloatingHUD, Theme.Accent, 0.4)

local HUDLabel = Instance.new("TextLabel", FloatingHUD)
HUDLabel.Size = UDim2.new(1, 0, 1, 0); HUDLabel.BackgroundTransparency = 1; HUDLabel.Font = "GothamBold"; HUDLabel.TextSize = 13; HUDLabel.TextColor3 = Theme.Green; HUDLabel.Text = "FPS: --"

-- [4. ANA PENCERE (CANVASGROUP)]
local Main = Instance.new("CanvasGroup", Zenith)
Main.Size = UDim2.new(0, 460, 0, 420)
Main.Position = UDim2.new(0.5, -230, 0.5, -210)
Main.BackgroundColor3 = Theme.Main
Main.BorderSizePixel = 0
Main.GroupTransparency = 1
UI:Smooth(Main, 18) 
UI:Stroke(Main, Theme.Accent, 0.3)

TweenService:Create(Main, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {GroupTransparency = 0}):Play()

-- [YENİLİK: BAĞIMSIZ KAPANIŞ YÜKLEME EKRANI (SEPARATE MENU)]
local LoadingOverlay = Instance.new("Frame", Zenith)
LoadingOverlay.Size = UDim2.new(1, 0, 1, 0)
LoadingOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingOverlay.BackgroundTransparency = 0.5
LoadingOverlay.Visible = false
LoadingOverlay.ZIndex = 9999
LoadingOverlay.Active = true -- Arkaya tıklanmayı engeller

local LoadingBox = Instance.new("Frame", LoadingOverlay)
LoadingBox.Size = UDim2.new(0, 320, 0, 80)
LoadingBox.Position = UDim2.new(0.5, -160, 0.5, -40)
LoadingBox.BackgroundColor3 = Theme.Main
UI:Smooth(LoadingBox, 14)
UI:Stroke(LoadingBox, Theme.Accent, 0.3)

local LoadingText = Instance.new("TextLabel", LoadingBox)
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Değişiklikler düzeltiliyor..."
LoadingText.TextColor3 = Theme.Accent
LoadingText.Font = "GothamBold"
LoadingText.TextSize = 16

-- [5. TOPBAR VE BUTONLAR]
local Topbar = Instance.new("Frame", Main)
Topbar.Size = UDim2.new(1, 0, 0, 45)
Topbar.BackgroundColor3 = Theme.Secondary
Topbar.BorderSizePixel = 0
UI:Smooth(Topbar, 18) 

local TopbarHide = Instance.new("Frame", Topbar)
TopbarHide.Size = UDim2.new(1, 0, 0, 10); TopbarHide.Position = UDim2.new(0, 0, 1, -10); TopbarHide.BackgroundColor3 = Theme.Secondary; TopbarHide.BorderSizePixel = 0; TopbarHide.ZIndex = 0

local Title = Instance.new("TextLabel", Topbar)
Title.Text = "  • FCU • | ZENITH"
Title.Size = UDim2.new(1, -120, 1, 0); Title.TextColor3 = Theme.Text; Title.Font = "GothamBold"; Title.TextSize = 14; Title.TextXAlignment = "Left"; Title.BackgroundTransparency = 1

local Btns = Instance.new("Frame", Topbar)
Btns.Size = UDim2.new(0, 110, 1, 0); Btns.Position = UDim2.new(1, -120, 0, 0); Btns.BackgroundTransparency = 1
local UIList = Instance.new("UIListLayout", Btns)
UIList.FillDirection = "Horizontal"; UIList.HorizontalAlignment = "Right"; UIList.VerticalAlignment = "Center"; UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local MicroBtn = Instance.new("TextButton", Btns)
MicroBtn.LayoutOrder = 1
MicroBtn.Size = UDim2.new(0, 24, 0, 24); MicroBtn.BackgroundColor3 = Theme.Accent; MicroBtn.Text = "▶"; MicroBtn.TextColor3 = Color3.new(1,1,1); MicroBtn.Font = "GothamBold"; MicroBtn.TextSize = 14
MicroBtn.Visible = false; MicroBtn.BackgroundTransparency = 1; MicroBtn.TextTransparency = 1
UI:Smooth(MicroBtn, 12)

local MiniBtn = Instance.new("TextButton", Btns)
MiniBtn.LayoutOrder = 2
MiniBtn.Size = UDim2.new(0, 24, 0, 24); MiniBtn.BackgroundColor3 = Theme.Yellow; MiniBtn.Text = "-"; MiniBtn.TextColor3 = Color3.new(1,1,1); MiniBtn.Font = "GothamBold"; MiniBtn.TextSize = 18; UI:Smooth(MiniBtn, 12)

local CloseBtn = Instance.new("TextButton", Btns)
CloseBtn.LayoutOrder = 3
CloseBtn.Size = UDim2.new(0, 24, 0, 24); CloseBtn.BackgroundColor3 = Theme.Red; CloseBtn.Text = "×"; CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.Font = "GothamBold"; CloseBtn.TextSize = 18; UI:Smooth(CloseBtn, 12)

-- KAPATMA TUŞU MANTIĞI EKLENDİ (Bağımsız Kapanış Ekranı)
CloseBtn.MouseButton1Click:Connect(function() 
    -- Ana menüyü gizle ve bağımsız yükleme ekranını göster
    Main.Visible = false
    FloatingHUD.Visible = false
    LoadingOverlay.Visible = true
    
    -- "CLOSED" durumunu kaydet (Autoexec'in diğer oyunda açılmasını engeller)
    if writefile then pcall(function() writefile(StateFileName, "CLOSED") end) end
    
    -- Yazıya hafif bir yanıp sönme efekti verelim
    TweenService:Create(LoadingText, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextTransparency = 0.5}):Play()
    
    task.wait(2) 
    
    if setfpscap then setfpscap(60) end 
    Zenith:Destroy() 
end)

local minimized = false
local isMicro = false

MicroBtn.MouseButton1Click:Connect(function()
    isMicro = not isMicro
    TweenService:Create(MicroBtn, Theme.Easing, {Rotation = isMicro and -180 or 0}):Play()
    TweenService:Create(Main, Theme.Easing, {Size = isMicro and UDim2.new(0, 120, 0, 45) or UDim2.new(0, 460, 0, 45)}):Play()
end)

MiniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    
    if not minimized and isMicro then
        isMicro = false
        MicroBtn.Rotation = 0
    end
    
    local targetSize = minimized and UDim2.new(0, 460, 0, 45) or UDim2.new(0, 460, 0, 420)
    TweenService:Create(Main, Theme.Easing, {Size = targetSize}):Play()
    
    if minimized then
        MicroBtn.Visible = true
        TweenService:Create(MicroBtn, TweenInfo.new(0.4), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    else
        local fadeOut = TweenService:Create(MicroBtn, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1})
        fadeOut:Play()
        fadeOut.Completed:Connect(function() if not minimized then MicroBtn.Visible = false end end)
    end
end)

-- [İçerik Alanı ve Diğer Modüller...]
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -65); Content.Position = UDim2.new(0, 10, 0, 55); Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2; Content.AutomaticCanvasSize = "Y"; Content.CanvasSize = UDim2.new(0,0,0,0)
UI:Smooth(Content, 10)
local Layout = Instance.new("UIListLayout", Content); Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = "Center"

function UI:Paragraph(title, desc)
    local F = Instance.new("Frame", Content)
    F.Size = UDim2.new(1, -5, 0, 75); F.BackgroundColor3 = Theme.Secondary; UI:Smooth(F, 10); UI:Stroke(F, nil, 0.7)
    local T = Instance.new("TextLabel", F)
    T.Text = "   " .. title:upper(); T.Size = UDim2.new(1, 0, 0, 30); T.TextColor3 = Theme.Accent; T.Font = "GothamBold"; T.TextSize = 12; T.TextXAlignment = "Left"; T.BackgroundTransparency = 1
    local D = Instance.new("TextLabel", F)
    D.Text = "   " .. desc; D.Size = UDim2.new(1, -10, 0, 40); D.Position = UDim2.new(0, 0, 0, 28); D.TextColor3 = Theme.SubText; D.Font = "Gotham"; D.TextSize = 11; D.TextXAlignment = "Left"; D.BackgroundTransparency = 1; D.TextWrapped = true
    return D
end

function UI:Toggle(name, default, callback)
    local B = Instance.new("TextButton", Content)
    B.Size = UDim2.new(1, -5, 0, 45); B.BackgroundColor3 = Theme.Secondary; B.Text = "   " .. name; B.TextColor3 = Theme.Text; B.Font = "GothamMedium"; B.TextSize = 13; B.TextXAlignment = "Left"; B.AutoButtonColor = false
    UI:Smooth(B, 10); UI:Stroke(B, nil, 0.7)
    local S = Instance.new("Frame", B)
    S.Size = UDim2.new(0, 36, 0, 18); S.Position = UDim2.new(1, -48, 0.5, -9); S.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(40,43,53); UI:Smooth(S, 10)
    local I = Instance.new("Frame", S)
    I.Size = UDim2.new(0, 14, 0, 14); I.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); I.BackgroundColor3 = Color3.new(1,1,1); UI:Smooth(I, 8)
    local active = default
    B.MouseButton1Click:Connect(function() active = not active TweenService:Create(I, Theme.Easing, {Position = active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play() TweenService:Create(S, Theme.Easing, {BackgroundColor3 = active and Theme.Accent or Color3.fromRGB(40,43,53)}):Play() callback(active) end)
end

function UI:Slider(name, min, max, default, callback)
    local F = Instance.new("Frame", Content)
    F.Size = UDim2.new(1, -5, 0, 65); F.BackgroundColor3 = Theme.Secondary; UI:Smooth(F, 10); UI:Stroke(F, nil, 0.7)
    local T = Instance.new("TextLabel", F)
    T.Text = "   " .. name; T.Size = UDim2.new(1, 0, 0, 35); T.TextColor3 = Theme.Text; T.Font = "GothamMedium"; T.TextSize = 13; T.TextXAlignment = "Left"; T.BackgroundTransparency = 1
    local V = Instance.new("TextLabel", F)
    V.Text = tostring(default) .. " "; V.Size = UDim2.new(1, -15, 0, 35); V.TextColor3 = Theme.Accent; V.Font = "GothamBold"; V.TextSize = 13; V.TextXAlignment = "Right"; V.BackgroundTransparency = 1
    local Bar = Instance.new("Frame", F)
    Bar.Size = UDim2.new(1, -30, 0, 6); Bar.Position = UDim2.new(0.5, 0, 0, 48); Bar.AnchorPoint = Vector2.new(0.5, 0); Bar.BackgroundColor3 = Color3.fromRGB(40,43,53); UI:Smooth(Bar, 3)
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; UI:Smooth(Fill, 3)
    local sliding = false; local finalValue = default
    local function Update() local p = math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1) Fill.Size = UDim2.new(p, 0, 1, 0) finalValue = math.floor(min + (max-min)*p) V.Text = tostring(finalValue) .. " " end
    F.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true Content.ScrollingEnabled = false Update() end end)
    UserInputService.InputEnded:Connect(function(input) if sliding then sliding = false Content.ScrollingEnabled = true callback(finalValue) end end)
    UserInputService.InputChanged:Connect(function(input) if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update() end end)
end

-- YENİ FONKSİYON: Şifreli Giriş Alanı (Dev Panel İçin)
function UI:Input(name, placeholder, callback)
    local F = Instance.new("Frame", Content)
    F.Size = UDim2.new(1, -5, 0, 50); F.BackgroundColor3 = Theme.Secondary; UI:Smooth(F, 10); UI:Stroke(F, nil, 0.7)
    
    local T = Instance.new("TextLabel", F)
    T.Text = "   " .. name; T.Size = UDim2.new(0.4, 0, 1, 0); T.TextColor3 = Theme.Text; T.Font = "GothamMedium"; T.TextSize = 13; T.TextXAlignment = "Left"; T.BackgroundTransparency = 1
    
    local BoxFrame = Instance.new("Frame", F)
    BoxFrame.Size = UDim2.new(0.55, 0, 0, 30); BoxFrame.Position = UDim2.new(0.4, 0, 0.5, -15); BoxFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 38); UI:Smooth(BoxFrame, 6); UI:Stroke(BoxFrame, Theme.Accent, 0.6)
    
    local TextBox = Instance.new("TextBox", BoxFrame)
    TextBox.Size = UDim2.new(1, -10, 1, 0); TextBox.Position = UDim2.new(0, 5, 0, 0); TextBox.BackgroundTransparency = 1; TextBox.Text = ""; TextBox.PlaceholderText = placeholder; TextBox.TextColor3 = Theme.Text; TextBox.PlaceholderColor3 = Theme.SubText; TextBox.Font = "Gotham"; TextBox.TextSize = 12; TextBox.TextXAlignment = "Left"; TextBox.ClearTextOnFocus = false
    
    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        callback(TextBox.Text)
    end)
end

-- ============================================================================
-- [7. SİSTEM MANTIĞI VE DEV PANEL]
-- ============================================================================

local HW_Label = UI:Paragraph("Donanım Raporu", "Analiz ediliyor...")
task.spawn(function()
    while task.wait(1) do
        HW_Label.Text = "   Ekran Kapasitesi: " .. MaxHardwareHz .. " Hz\n   Stabilize Edilmiş Maksimum FPS: " .. MaxHardwareHz
    end
end)

local currentFPSLimit = 60
local isFPSApplyEnabled = false

UI:Toggle("Yüzer FPS Paneli (HUD)", false, function(s) FloatingHUD.Visible = s end)

UI:Toggle("FPS Limitini Uygula", false, function(s)
    isFPSApplyEnabled = s
    if s and setfpscap then
        setfpscap(currentFPSLimit)
    elseif not s and setfpscap then
        setfpscap(60)
    end
end)

UI:Slider("Hedef FPS Değeri", 3, 550, 60, function(val)
    currentFPSLimit = val
    if isFPSApplyEnabled and setfpscap then setfpscap(val) end
end)

-- Geliştirici Kodu Girişi (Dev Panel Tetikleyicisi)
local devPanelActive = false

-- DEV PANEL TASARIMI (RGB)
local DevPanel = Instance.new("Frame", Zenith)
DevPanel.Size = UDim2.new(0, 260, 0, 180)
DevPanel.Position = UDim2.new(1, 50, 0.5, -90) -- Sağ ekran dışında gizli başlar
DevPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Gradient işlemesi için beyaz olmalı
DevPanel.Visible = false
DevPanel.ZIndex = 100
UI:Smooth(DevPanel, 12)

-- Sürekli Akan RGB Gradient Efekti
local Gradient = Instance.new("UIGradient", DevPanel)
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
})

local hueOffset = 0
RunService.RenderStepped:Connect(function(dt)
    if DevPanel.Visible then
        hueOffset = hueOffset + dt * 0.15 -- Renk akış hızı
        Gradient.Rotation = (hueOffset * 360) % 360
    end
end)

-- Dev Panel İçerik Şekillendirme (Siyah iç kutu)
local DevInner = Instance.new("Frame", DevPanel)
DevInner.Size = UDim2.new(1, -6, 1, -6); DevInner.Position = UDim2.new(0, 3, 0, 3); DevInner.BackgroundColor3 = Theme.Main; UI:Smooth(DevInner, 10)

local DevTitle = Instance.new("TextLabel", DevInner)
DevTitle.Text = "DEVELOPER ENGINE"; DevTitle.Size = UDim2.new(1, 0, 0, 40); DevTitle.TextColor3 = Theme.Text; DevTitle.Font = "GothamBold"; DevTitle.TextSize = 16; DevTitle.BackgroundTransparency = 1

local DevDesc = Instance.new("TextLabel", DevInner)
DevDesc.Text = "Deep Render & Memory Optimization (120 FPS Forced)"; DevDesc.Size = UDim2.new(1, -20, 0, 40); DevDesc.Position = UDim2.new(0, 10, 0, 35); DevDesc.TextColor3 = Theme.SubText; DevDesc.Font = "Gotham"; DevDesc.TextSize = 11; DevDesc.BackgroundTransparency = 1; DevDesc.TextWrapped = true

local OptimizeBtn = Instance.new("TextButton", DevInner)
OptimizeBtn.Size = UDim2.new(0, 200, 0, 45); OptimizeBtn.Position = UDim2.new(0.5, -100, 1, -60); OptimizeBtn.BackgroundColor3 = Theme.Secondary; OptimizeBtn.Text = "ENGAGE OVERDRIVE"; OptimizeBtn.TextColor3 = Theme.Accent; OptimizeBtn.Font = "GothamBold"; OptimizeBtn.TextSize = 13; UI:Smooth(OptimizeBtn, 8); UI:Stroke(OptimizeBtn, Theme.Accent, 0.5)

-- DERİN MOTOR OPTİMİZASYONLARI (Render API, Bellek, Fizik ve Gecikme)
OptimizeBtn.MouseButton1Click:Connect(function()
    OptimizeBtn.Text = "OVERDRIVE ACTIVE!"
    OptimizeBtn.TextColor3 = Theme.Green
    TweenService:Create(OptimizeBtn, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(15, 40, 20)}):Play()
    
    -- 1. FPS ZORLAMASI (DFIntTaskSchedulerTargetFps Simülasyonu)
    if setfpscap then setfpscap(120) end
    
    -- 2. RENDER API & KALİTE DÜŞÜRME
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    lighting.Brightness = 1
    
    -- Gecikmeyi (Latency) düşürmek için gereksiz ışık teknolojilerini kapat
    pcall(function() lighting.Technology = Enum.Technology.Compatibility end)
    
    -- 3. BELLEK (MEMORY) YÖNETİMİ & ÇÖP TOPLAMA
    -- Mevcut kullanılmayan texture ve assetleri bellekten temizler
    local function CleanMemory()
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1 -- Texture'ları silerek RAM tasarrufu
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false -- Parçacık efektlerini kapat
            end
        end
    end
    CleanMemory()
    
    -- 4. FİZİK MOTORU VE SCRIPT GECİKMESİ (Latency)
    -- Fizik güncellemelerini ekrana çizim hızıyla senkronize ederek CPU yükünü hafifletir
    local runService = game:GetService("RunService")
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Enabled
    settings().Physics.AllowSleep = true -- Duran nesnelerin fiziğini kapatır
    
    -- Sürekli temizlik (Garbage Collection Trigger) - Hafızayı rahatlatır
    task.spawn(function()
        while task.wait(30) do -- Her 30 saniyede bir hafif temizlik
            pcall(functionwhile task.wait(30) do -- Her 30 saniyede bir hafif temizlik
            pcall(function() game:GetService("ContentProvider"):ClearContext() end)
        end
    end)
    
    print("• ZENITH V18: Engine Overdrive Initiated. Max Performance Reached.")
end)

-- Metin kutusu şifre kontrolü
UI:Input("Geliştirici Şifresi:", "Panel için şifre girin", function(text)
    if text == "dev-zenith" and not devPanelActive then
        devPanelActive = true
        DevPanel.Visible = true
        TweenService:Create(DevPanel, Theme.Easing, {Position = UDim2.new(1, -280, 0.5, -90)}):Play()
    elseif text ~= "dev-zenith" and devPanelActive then
        devPanelActive = false
        local hideTween = TweenService:Create(DevPanel, Theme.Easing, {Position = UDim2.new(1, 50, 0.5, -90)})
        hideTween:Play()
        hideTween.Completed:Connect(function()
            if not devPanelActive then DevPanel.Visible = false end
        end)
    end
end)

-- SMOOTH FPS SAYACI (0.5s GÜNCELLEME)
task.spawn(function()
    local lastUpdate = tick()
    local frames = 0
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - lastUpdate >= 0.5 then
            local fps = math.floor(frames / (now - lastUpdate))
            HUDLabel.Text = "FPS: " .. fps
            if fps > 55 then HUDLabel.TextColor3 = Theme.Green
            elseif fps > 28 then HUDLabel.TextColor3 = Theme.Yellow
            else HUDLabel.TextColor3 = Theme.Red end
            frames = 0; lastUpdate = now
        end
    end)
end)

-- Sürükleme Mantığı (OOB iptal edildiği için sadece basit sürükleme var)
local dragging, dragStart, startPos
Topbar.InputBegan:Connect(function(input) 
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
        dragging = true; dragStart = input.Position; startPos = Main.Position 
    end 
end)
UserInputService.InputChanged:Connect(function(input) 
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
        local delta = input.Position - dragStart 
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) 
    end 
end)
UserInputService.InputEnded:Connect(function() dragging = false end)

print("• ZENITH V18: AESTHETIC ULTRA LOADED. [Bağımsız Kapanış Ekranı, Autoexec & Dev Panel Aktif]")
