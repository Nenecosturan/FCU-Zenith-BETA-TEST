-- ============================================================================
-- •PIOP• ZENITH V19 - 2026 MODERN EDİTİON
-- BÖLÜM 1: SERVİSLER & AUTOEXEC SİSTEMİ
-- ============================================================================

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")

local StateFileName = "ZenithClosed_State.txt"
local LoadstringURL = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Nenecosturan/FPS-CAP-SCR-PT/refs/heads/main/Main.lua"))()'

-- Autoexec kapalı durumu kontrolü
if isfile and isfile(StateFileName) then
    local state = readfile(StateFileName)
    if state == "CLOSED" then
        if delfile then delfile(StateFileName) end
        return
    end
end

-- Teleport koruma
if queue_on_teleport then
    queue_on_teleport(LoadstringURL)
end

-- Güvenli setfpscap wrapper (her yerde tekrar kontrol yazmak yerine bunu kullan)
local function SafeSetFPS(value)
    if setfpscap then
        pcall(setfpscap, value)
    end
end

-- Son kaydedilen FPS değerini yükle (yoksa 60)
local SavedFPSFile = "ZenithLastFPS.txt"
local savedFPS = 60
if isfile and isfile(SavedFPSFile) then
    local val = tonumber(readfile(SavedFPSFile))
    if val and val >= 3 and val <= 550 then
        savedFPS = val
    end
end-- ============================================================================
-- BÖLÜM 2: TEMA & RENK KONFİGÜRASYONU
-- ============================================================================

-- Mevcut accent rengi (tema seçicide değiştirilebilir)
local CurrentAccent = Color3.fromRGB(0, 180, 255)

local Theme = {
    Main      = Color3.fromRGB(11, 13, 19),
    Secondary = Color3.fromRGB(18, 20, 28),
    Accent    = CurrentAccent,
    Text      = Color3.fromRGB(240, 240, 250),
    SubText   = Color3.fromRGB(160, 165, 180),
    Red       = Color3.fromRGB(255, 70, 70),
    Yellow    = Color3.fromRGB(255, 200, 0),
    Green     = Color3.fromRGB(0, 255, 130),
    Easing    = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
}

-- YENİ: Tema renk seçenekleri
local AccentColors = {
    { name = "Mavi",   color = Color3.fromRGB(0, 180, 255) },
    { name = "Mor",    color = Color3.fromRGB(150, 80, 255) },
    { name = "Yeşil",  color = Color3.fromRGB(0, 220, 120) },
    { name = "Turuncu",color = Color3.fromRGB(255, 140, 0)  },
}

-- Accent rengini her UI elementinde güncellemek için listener tablosu
local AccentListeners = {}
local function RegisterAccent(obj, property)
    table.insert(AccentListeners, { obj = obj, prop = property })
end
local function ApplyAccent(color)
    Theme.Accent = color
    for _, item in ipairs(AccentListeners) do
        if item.obj and item.obj.Parent then
            TweenService:Create(item.obj, TweenInfo.new(0.3), { [item.prop] = color }):Play()
        end
    end
end-- ============================================================================
-- BÖLÜM 3: DONANIM TESPİTİ (240Hz'e kadar tam destek)
-- ============================================================================

local MaxHardwareHz  = "?"
local DetectionDone  = false

task.spawn(function()
    if not setfpscap then
        MaxHardwareHz = "Desteklenmiyor"
        DetectionDone = true
        return
    end

    SafeSetFPS(999)
    task.wait(0.1) -- Stabilizasyon için kısa bekleme

    local frameTimes = {}
    for i = 1, 60 do -- Daha fazla örnek = daha doğru sonuç (30 → 60)
        table.insert(frameTimes, RunService.RenderStepped:Wait())
    end

    local avg = 0
    for _, t in ipairs(frameTimes) do avg += t end
    local detected = math.floor(1 / (avg / #frameTimes))

    -- DÜZELTME: Tüm yaygın monitör hızları destekleniyor
    if     detected >= 230 then MaxHardwareHz = "240"
    elseif detected >= 155 then MaxHardwareHz = "165"
    elseif detected >= 134 then MaxHardwareHz = "144"
    elseif detected >= 115 then MaxHardwareHz = "120"
    elseif detected >= 80  then MaxHardwareHz = "90"
    elseif detected >= 68  then MaxHardwareHz = "75"
    else                        MaxHardwareHz = "60"
    end

    SafeSetFPS(60)
    DetectionDone = true
end)-- ============================================================================
-- BÖLÜM 4: ANA GUI YAPISI & KAPANIŞ YÜKLEME EKRANI
-- ============================================================================

local Zenith = Instance.new("ScreenGui")
Zenith.Name = "•FPS-CAP-UNLOCKER• by ZENITH"
Zenith.ResetOnSpawn = false
pcall(function() Zenith.Parent = CoreGui end)

-- [Ana CanvasGroup]
local Main = Instance.new("CanvasGroup", Zenith)
Main.Size = UDim2.new(0, 460, 0, 420)
Main.Position = UDim2.new(0.5, -230, 0.5, -210)
Main.BackgroundColor3 = Theme.Main
Main.BorderSizePixel = 0
Main.GroupTransparency = 1

-- [Kapanış Yükleme Ekranı]
local LoadingOverlay = Instance.new("Frame", Zenith)
LoadingOverlay.Size = UDim2.new(1, 0, 1, 0)
LoadingOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingOverlay.BackgroundTransparency = 0.5
LoadingOverlay.Visible = false
LoadingOverlay.ZIndex = 9999
LoadingOverlay.Active = true

local LoadingBox = Instance.new("Frame", LoadingOverlay)
LoadingBox.Size = UDim2.new(0, 320, 0, 80)
LoadingBox.Position = UDim2.new(0.5, -160, 0.5, -40)
LoadingBox.BackgroundColor3 = Theme.Main

local LoadingText = Instance.new("TextLabel", LoadingBox)
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Değişiklikler düzeltiliyor..."
LoadingText.TextColor3 = Theme.Accent
LoadingText.Font = Enum.Font.GothamBold  -- DÜZELTME: string değil Enum
LoadingText.TextSize = 16--
 -- ============================================================================
-- DÜZELTME: Content önceden declare ediliyor
-- (BÖLÜM 4'ün en sonuna, BÖLÜM 5'ten önce ekle)
-- ============================================================================

-- İçerik alanı burada declare ediliyor, BÖLÜM 8'de oluşturulacak
-- UI fonksiyonları bu değişkeni kapatma (closure) yoluyla görecek
local Content  -- Kasıtlı olarak boş bırakıldı       
        ============================================================================
-- BÖLÜM 5: UI YARDIMCI FONKSİYONLARI
-- ============================================================================

local UI = {}

function UI:Smooth(obj, rad)
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, rad)
end

function UI:Stroke(obj, color, trans)
    local s = Instance.new("UIStroke", obj)
    s.Thickness = 1.5
    s.Color = color or Theme.Accent
    s.Transparency = trans or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function UI:Paragraph(title, desc)
    local F = Instance.new("Frame", Content)
    F.Size = UDim2.new(1, -5, 0, 75)
    F.BackgroundColor3 = Theme.Secondary
    UI:Smooth(F, 10)
    UI:Stroke(F, nil, 0.7)

    local T = Instance.new("TextLabel", F)
    T.Text = "   " .. title:upper()
    T.Size = UDim2.new(1, 0, 0, 30)
    T.TextColor3 = Theme.Accent
    T.Font = Enum.Font.GothamBold       -- DÜZELTME
    T.TextSize = 12
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.BackgroundTransparency = 1
    RegisterAccent(T, "TextColor3")

    local D = Instance.new("TextLabel", F)
    D.Text = "   " .. desc
    D.Size = UDim2.new(1, -10, 0, 40)
    D.Position = UDim2.new(0, 0, 0, 28)
    D.TextColor3 = Theme.SubText
    D.Font = Enum.Font.Gotham           -- DÜZELTME
    D.TextSize = 11
    D.TextXAlignment = Enum.TextXAlignment.Left
    D.BackgroundTransparency = 1
    D.TextWrapped = true
    return D
end

-- DÜZELTME: Toggle okunabilir ve düzgün formatlandı
function UI:Toggle(name, default, callback)
    local B = Instance.new("TextButton", Content)
    B.Size = UDim2.new(1, -5, 0, 45)
    B.BackgroundColor3 = Theme.Secondary
    B.Text = "   " .. name
    B.TextColor3 = Theme.Text
    B.Font = Enum.Font.GothamMedium     -- DÜZELTME
    B.TextSize = 13
    B.TextXAlignment = Enum.TextXAlignment.Left
    B.AutoButtonColor = false
    UI:Smooth(B, 10)
    UI:Stroke(B, nil, 0.7)

    local S = Instance.new("Frame", B)
    S.Size = UDim2.new(0, 36, 0, 18)
    S.Position = UDim2.new(1, -48, 0.5, -9)
    S.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(40, 43, 53)
    UI:Smooth(S, 10)

    local I = Instance.new("Frame", S)
    I.Size = UDim2.new(0, 14, 0, 14)
    I.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    I.BackgroundColor3 = Color3.new(1, 1, 1)
    UI:Smooth(I, 8)

    local active = default
    B.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(I, Theme.Easing, {
            Position = active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        TweenService:Create(S, Theme.Easing, {
            BackgroundColor3 = active and Theme.Accent or Color3.fromRGB(40, 43, 53)
        }):Play()
        callback(active)
    end)
end

-- DÜZELTME: Slider — memory leak giderildi (InputEnded/Changed bağlantıları değişkende tutuluyor)
function UI:Slider(name, min, max, default, callback)
    local F = Instance.new("Frame", Content)
    F.Size = UDim2.new(1, -5, 0, 65)
    F.BackgroundColor3 = Theme.Secondary
    UI:Smooth(F, 10)
    UI:Stroke(F, nil, 0.7)

    local T = Instance.new("TextLabel", F)
    T.Text = "   " .. name
    T.Size = UDim2.new(1, 0, 0, 35)
    T.TextColor3 = Theme.Text
    T.Font = Enum.Font.GothamMedium     -- DÜZELTME
    T.TextSize = 13
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.BackgroundTransparency = 1

    local V = Instance.new("TextLabel", F)
    V.Text = tostring(default) .. " "
    V.Size = UDim2.new(1, -15, 0, 35)
    V.TextColor3 = Theme.Accent
    V.Font = Enum.Font.GothamBold       -- DÜZELTME
    V.TextSize = 13
    V.TextXAlignment = Enum.TextXAlignment.Right
    V.BackgroundTransparency = 1
    RegisterAccent(V, "TextColor3")

    local Bar = Instance.new("Frame", F)
    Bar.Size = UDim2.new(1, -30, 0, 6)
    Bar.Position = UDim2.new(0.5, 0, 0, 48)
    Bar.AnchorPoint = Vector2.new(0.5, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 43, 53)
    UI:Smooth(Bar, 3)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    UI:Smooth(Fill, 3)
    RegisterAccent(Fill, "BackgroundColor3")

    local sliding = false
    local finalValue = default

    local function Update()
        local p = math.clamp(
            (UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
            0, 1
        )
        Fill.Size = UDim2.new(p, 0, 1, 0)
        finalValue = math.floor(min + (max - min) * p)
        V.Text = tostring(finalValue) .. " "
    end

    -- DÜZELTME: Bağlantıları değişkende tut, Zenith destroy edilince otomatik temizlenir
    local connEnd, connChange

    F.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            Content.ScrollingEnabled = false
            Update()
        end
    end)

    connEnd = UserInputService.InputEnded:Connect(function(input)
        if sliding then
            sliding = false
            Content.ScrollingEnabled = true
            callback(finalValue)
        end
    end)

    connChange = UserInputService.InputChanged:Connect(function(input)
        if sliding and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            Update()
        end
    end)

    -- Temizleme: GUI destroy edilince bağlantıları kes
    Zenith.Destroying:Connect(function()
        connEnd:Disconnect()
        connChange:Disconnect()
    end)

    return V -- Değer label'ını dışarıdan güncellemek için döndür
end

-- YENİ: FPS Preset butonları satırı
function UI:PresetRow(presets, onSelect)
    local F = Instance.new("Frame", Content)
    F.Size = UDim2.new(1, -5, 0, 45)
    F.BackgroundColor3 = Theme.Secondary
    UI:Smooth(F, 10)
    UI:Stroke(F, nil, 0.7)

    local Label = Instance.new("TextLabel", F)
    Label.Text = "   Hızlı Seçim:"
    Label.Size = UDim2.new(0, 100, 1, 0)
    Label.TextColor3 = Theme.SubText
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local BtnHolder = Instance.new("Frame", F)
    BtnHolder.Size = UDim2.new(1, -110, 1, -10)
    BtnHolder.Position = UDim2.new(0, 105, 0.5, -17.5)
    BtnHolder.BackgroundTransparency = 1

    local BList = Instance.new("UIListLayout", BtnHolder)
    BList.FillDirection = Enum.FillDirection.Horizontal
    BList.VerticalAlignment = Enum.VerticalAlignment.Center
    BList.Padding = UDim.new(0, 5)

    for _, preset in ipairs(presets) do
        local Btn = Instance.new("TextButton", BtnHolder)
        Btn.Size = UDim2.new(0, 55, 0, 28)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
        Btn.Text = tostring(preset)
        Btn.TextColor3 = Theme.Accent
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        Btn.AutoButtonColor = false
        UI:Smooth(Btn, 8)
        UI:Stroke(Btn, Theme.Accent, 0.6)
        RegisterAccent(Btn, "BorderColor3") -- stroke rengi accent ile değişir

        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
            task.delay(0.15, function()
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 35, 48)}):Play()
            end)
            onSelect(preset)
        end)
    end
end

-- YENİ: Tema renk seçici satırı
function UI:ThemePicker()
    local F = Instance.new("Frame", Content)
    F.Size = UDim2.new(1, -5, 0, 45)
    F.BackgroundColor3 = Theme.Secondary
    UI:Smooth(F, 10)
    UI:Stroke(F, nil, 0.7)

    local Label = Instance.new("TextLabel", F)
    Label.Text = "   Tema Rengi:"
    Label.Size = UDim2.new(0, 100, 1, 0)
    Label.TextColor3 = Theme.SubText
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local BtnHolder = Instance.new("Frame", F)
    BtnHolder.Size = UDim2.new(1, -110, 1, -10)
    BtnHolder.Position = UDim2.new(0, 105, 0.5, -17.5)
    BtnHolder.BackgroundTransparency = 1

    local BList = Instance.new("UIListLayout", BtnHolder)
    BList.FillDirection = Enum.FillDirection.Horizontal
    BList.VerticalAlignment = Enum.VerticalAlignment.Center
    BList.Padding = UDim.new(0, 8)

    for _, entry in ipairs(AccentColors) do
        local Btn = Instance.new("TextButton", BtnHolder)
        Btn.Size = UDim2.new(0, 28, 0, 28)
        Btn.BackgroundColor3 = entry.color
        Btn.Text = ""
        Btn.AutoButtonColor = false
        UI:Smooth(Btn, 14) -- Tam daire

        Btn.MouseButton1Click:Connect(function()
            ApplyAccent(entry.color)
            -- Seçilen rengi vurgula
            TweenService:Create(Btn, TweenInfo.new(0.15), {Size = UDim2.new(0, 24, 0, 24)}):Play()
            task.delay(0.15, function()
                TweenService:Create(Btn, TweenInfo.new(0.15), {Size = UDim2.new(0, 28, 0, 28)}):Play()
            end)
        end)
    end
end-- ============================================================================
-- BÖLÜM 6: TOPBAR, PENCERE KONTROLLERİ & KLAVYE KISAYOLU
-- ============================================================================

-- Köşe ve stroke ekle (BÖLÜM 4'teki Main ve LoadingBox için)
UI:Smooth(Main, 18)
UI:Stroke(Main, Theme.Accent, 0.3)
UI:Smooth(LoadingBox, 14)
UI:Stroke(LoadingBox, Theme.Accent, 0.3)

-- Açılış animasyonu
TweenService:Create(Main, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {GroupTransparency = 0}):Play()

-- [Topbar]
local Topbar = Instance.new("Frame", Main)
Topbar.Size = UDim2.new(1, 0, 0, 45)
Topbar.BackgroundColor3 = Theme.Secondary
Topbar.BorderSizePixel = 0
UI:Smooth(Topbar, 18)

local TopbarHide = Instance.new("Frame", Topbar)
TopbarHide.Size = UDim2.new(1, 0, 0, 10)
TopbarHide.Position = UDim2.new(0, 0, 1, -10)
TopbarHide.BackgroundColor3 = Theme.Secondary
TopbarHide.BorderSizePixel = 0
TopbarHide.ZIndex = 0

-- YENİ: Oyun adını başlıkta göster
local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local Title = Instance.new("TextLabel", Topbar)
Title.Text = "  • FCU • | " .. (gameName ~= "" and gameName or "ZENITH")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold       -- DÜZELTME
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.TextTruncate = Enum.TextTruncate.AtEnd

-- [Buton satırı]
local Btns = Instance.new("Frame", Topbar)
Btns.Size = UDim2.new(0, 110, 1, 0)
Btns.Position = UDim2.new(1, -120, 0, 0)
Btns.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Btns)
UIList.FillDirection = Enum.FillDirection.Horizontal
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIList.VerticalAlignment = Enum.VerticalAlignment.Center
UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local MicroBtn = Instance.new("TextButton", Btns)
MicroBtn.LayoutOrder = 1
MicroBtn.Size = UDim2.new(0, 24, 0, 24)
MicroBtn.BackgroundColor3 = Theme.Accent
MicroBtn.Text = "▶"
MicroBtn.TextColor3 = Color3.new(1, 1, 1)
MicroBtn.Font = Enum.Font.GothamBold    -- DÜZELTME
MicroBtn.TextSize = 14
MicroBtn.Visible = false
MicroBtn.BackgroundTransparency = 1
MicroBtn.TextTransparency = 1
UI:Smooth(MicroBtn, 12)

local MiniBtn = Instance.new("TextButton", Btns)
MiniBtn.LayoutOrder = 2
MiniBtn.Size = UDim2.new(0, 24, 0, 24)
MiniBtn.BackgroundColor3 = Theme.Yellow
MiniBtn.Text = "-"
MiniBtn.TextColor3 = Color3.new(1, 1, 1)
MiniBtn.Font = Enum.Font.GothamBold     -- DÜZELTME
MiniBtn.TextSize = 18
UI:Smooth(MiniBtn, 12)

local CloseBtn = Instance.new("TextButton", Btns)
CloseBtn.LayoutOrder = 3
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.BackgroundColor3 = Theme.Red
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold    -- DÜZELTME
CloseBtn.TextSize = 18
UI:Smooth(CloseBtn, 12)

-- DÜZELTME: Kapatma — önce FPS sıfırla, sonra animasyon
CloseBtn.MouseButton1Click:Connect(function()
    SafeSetFPS(60)  -- DÜZELTME: 2 saniye beklemeden önce sıfırla

    Main.Visible = false
    FloatingHUD.Visible = false
    LoadingOverlay.Visible = true

    if writefile then pcall(function() writefile(StateFileName, "CLOSED") end) end

    TweenService:Create(LoadingText, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextTransparency = 0.5}):Play()

    task.wait(2)
    Zenith:Destroy()
end)

-- Minimize / Micro buton mantığı (değişmedi)
local minimized = false
local isMicro = false

MicroBtn.MouseButton1Click:Connect(function()
    isMicro = not isMicro
    TweenService:Create(MicroBtn, Theme.Easing, {Rotation = isMicro and -180 or 0}):Play()
    TweenService:Create(Main, Theme.Easing, {
        Size = isMicro and UDim2.new(0, 120, 0, 45) or UDim2.new(0, 460, 0, 45)
    }):Play()
end)

MiniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized

    if not minimized and isMicro then
        isMicro = false
        MicroBtn.Rotation = 0
    end

    TweenService:Create(Main, Theme.Easing, {
        Size = minimized and UDim2.new(0, 460, 0, 45) or UDim2.new(0, 460, 0, 420)
    }):Play()

    if minimized then
        MicroBtn.Visible = true
        TweenService:Create(MicroBtn, TweenInfo.new(0.4), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    else
        local fadeOut = TweenService:Create(MicroBtn, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1})
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            if not minimized then MicroBtn.Visible = false end
        end)
    end
end)

-- Pencere sürükleme (değişmedi)
local dragging, dragStart, startPos
Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- YENİ: RightShift klavye kısayolu (menüyü gizle/göster)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)-- ============================================================================
-- BÖLÜM 7: YÜZER FPS HUD (Sürüklenebilir)
-- ============================================================================

local FloatingHUD = Instance.new("Frame", Zenith)
FloatingHUD.Size = UDim2.new(0, 110, 0, 32)
FloatingHUD.Position = UDim2.new(1, -125, 0, 15)
FloatingHUD.BackgroundColor3 = Theme.Secondary
FloatingHUD.Visible = false
FloatingHUD.Active = true
UI:Smooth(FloatingHUD, 8)
UI:Stroke(FloatingHUD, Theme.Accent, 0.4)

local HUDLabel = Instance.new("TextLabel", FloatingHUD)
HUDLabel.Size = UDim2.new(1, 0, 1, 0)
HUDLabel.BackgroundTransparency = 1
HUDLabel.Font = Enum.Font.GothamBold    -- DÜZELTME
HUDLabel.TextSize = 13
HUDLabel.TextColor3 = Theme.Green
HUDLabel.Text = "FPS: --"

-- YENİ: HUD sürükleme
local hudDragging, hudDragStart, hudStartPos
FloatingHUD.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        hudDragging = true
        hudDragStart = input.Position
        hudStartPos = FloatingHUD.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if hudDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - hudDragStart
        FloatingHUD.Position = UDim2.new(
            hudStartPos.X.Scale, hudStartPos.X.Offset + delta.X,
            hudStartPos.Y.Scale, hudStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        hudDragging = false
    end
end)-- ============================================================================
-- BÖLÜM 8: İÇERİK ALANI & ANA KONTROLLER
-- ===========================================================================

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -65)
Content.Position = UDim2.new(0, 10, 0, 55)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
UI:Smooth(Content, 10)

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [Donanım Raporu — DÜZELTME: "Analiz ediliyor..." tespit bitene kadar bekler]
local HW_Label = UI:Paragraph("Donanım Raporu", "Analiz ediliyor...")
task.spawn(function()
    -- Önce tespit bitsin
    repeat task.wait(0.5) until DetectionDone
    -- Ardından her saniye güncelle
    while task.wait(1) do
        if HW_Label and HW_Label.Parent then
            HW_Label.Text = "   Ekran Kapasitesi: " .. MaxHardwareHz .. " Hz\n   Stabilize Maks FPS: " .. MaxHardwareHz
        end
    end
end)

-- Değişkenler
local currentFPSLimit = savedFPS  -- Son kaydedilen değerle başla
local isFPSApplyEnabled = false

-- Togglelar
UI:Toggle("Yüzer FPS Paneli (HUD)", false, function(s)
    FloatingHUD.Visible = s
end)

UI:Toggle("FPS Limitini Uygula", false, function(s)
    isFPSApplyEnabled = s
    if s then
        SafeSetFPS(currentFPSLimit)
    else
        SafeSetFPS(60)
    end
end)

-- Slider (FPS) — kaydedilen değerle başlar
local SliderValueLabel = UI:Slider("Hedef FPS Değeri", 3, 550, savedFPS, function(val)
    currentFPSLimit = val
    if isFPSApplyEnabled then SafeSetFPS(val) end

    -- YENİ: Değeri kaydet
    if writefile then
        pcall(function() writefile(SavedFPSFile, tostring(val)) end)
    end
end)

-- YENİ: Hızlı preset butonları
UI:PresetRow({30, 60, 120, 144, 165, 240}, function(preset)
    currentFPSLimit = preset
    if SliderValueLabel then
        SliderValueLabel.Text = tostring(preset) .. " "
    end
    if isFPSApplyEnabled then SafeSetFPS(preset) end
    if writefile then
        pcall(function() writefile(SavedFPSFile, tostring(preset)) end)
    end
end)

-- YENİ: Tema renk seçici
UI:ThemePicker()-- ============================================================================
-- BÖLÜM 9: FPS SAYACI & DÜŞÜŞ UYARISI
-- ============================================================================

-- FPS eşik uyarısı için konfigürasyon
local FPS_WARN_THRESHOLD = 45  -- Bu değerin altına düşerse HUD uyarı verir

task.spawn(function()
    local lastUpdate = tick()
    local frames = 0
    local warningActive = false

    -- DÜZELTME: RenderStepped bağlantısı task.spawn içinde açılıyor (memory safe)
    RunService.RenderStepped:Connect(function()
        frames += 1
        local now = tick()

        if now - lastUpdate >= 0.5 then
            local fps = math.floor(frames / (now - lastUpdate))
            frames = 0
            lastUpdate = now

            -- HUD renk güncellemesi
            if fps >= 56 then
                HUDLabel.TextColor3 = Theme.Green
            elseif fps >= 30 then
                HUDLabel.TextColor3 = Theme.Yellow
            else
                HUDLabel.TextColor3 = Theme.Red
            end

            HUDLabel.Text = "FPS: " .. fps

            -- YENİ: FPS düşüş uyarısı — HUD titreyerek dikkat çeker
            if fps < FPS_WARN_THRESHOLD and FloatingHUD.Visible then
                if not warningActive then
                    warningActive = true
                    task.spawn(function()
                        for _ = 1, 3 do
                            TweenService:Create(FloatingHUD, TweenInfo.new(0.08), {BackgroundColor3 = Theme.Red}):Play()
                            task.wait(0.1)
                            TweenService:Create(FloatingHUD, TweenInfo.new(0.08), {BackgroundColor3 = Theme.Secondary}):Play()
                            task.wait(0.1)
                        end
                        warningActive = false
                    end)
                end
            end
        end
    end)
end)-- ============================================================================
-- BÖLÜM 10: MOTOR OPTİMİZASYONU & DEV PANELİ
-- (Orijinal logic korundu, sadece Enum.Font düzeltmesi uygulandı)
-- ============================================================================

UI:Paragraph("Developer Access", "Panel açmak için şifreyi girip ENTER'a bas.")

local InputFrame = Instance.new("Frame", Content)
InputFrame.Size = UDim2.new(1, -10, 0, 85)
InputFrame.BackgroundTransparency = 1

local DevInput = Instance.new("TextBox", InputFrame)
DevInput.Size = UDim2.new(1, 0, 0, 40)
DevInput.BackgroundColor3 = Theme.Secondary
DevInput.TextColor3 = Theme.Text
DevInput.PlaceholderText = "Şifreyi giriniz..."
DevInput.Font = Enum.Font.GothamMedium  -- DÜZELTME
DevInput.TextSize = 13
UI:Smooth(DevInput, 10)
UI:Stroke(DevInput, Theme.Accent, 0.6)

local EnterBtn = Instance.new("TextButton", InputFrame)
EnterBtn.Size = UDim2.new(1, 0, 0, 35)
EnterBtn.Position = UDim2.new(0, 0, 0, 50)
EnterBtn.BackgroundColor3 = Theme.Accent
EnterBtn.TextColor3 = Color3.new(1, 1, 1)
EnterBtn.Font = Enum.Font.GothamBold    -- DÜZELTME
EnterBtn.Text = "ENTER"
EnterBtn.TextSize = 14
UI:Smooth(EnterBtn, 8)

local DevPanelActive = false
local DevPanel = Instance.new("Frame", Zenith)
DevPanel.Name = "DevPanel"
DevPanel.Size = UDim2.new(0, 280, 0, 290)
DevPanel.Position = UDim2.new(1, 50, 0.5, -145)
DevPanel.BackgroundTransparency = 1
DevPanel.Visible = false

local DevInner = Instance.new("Frame", DevPanel)
DevInner.Size = UDim2.new(1, 0, 1, 0)
DevInner.BackgroundColor3 = Theme.Main
UI:Smooth(DevInner, 14)

local DevStroke = UI:Stroke(DevInner, Color3.new(1, 1, 1), 0)
local DevGrad = Instance.new("UIGradient", DevStroke)
DevGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 0, 255)),
})
RunService.RenderStepped:Connect(function()
    DevGrad.Rotation = (tick() * 100) % 360
end)

local PillHandle = Instance.new("TextButton", DevInner)
PillHandle.Size = UDim2.new(0, 40, 0, 6)
PillHandle.Position = UDim2.new(0.5, -20, 0, 10)
PillHandle.BackgroundColor3 = Theme.SubText
PillHandle.Text = ""
UI:Smooth(PillHandle, 10)

-- Dev panel sürükleme (değişmedi)
local devDragging, devDragStart, devStartPos
PillHandle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        devDragging = true
        devDragStart = i.Position
        devStartPos = DevPanel.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if devDragging and (
        i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = i.Position - devDragStart
        DevPanel.Position = UDim2.new(
            devStartPos.X.Scale, devStartPos.X.Offset + delta.X,
            devStartPos.Y.Scale, devStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function() devDragging = false end)

-- Motor optimizasyon buton oluşturucu (değişmedi)
local function CreateEngineButton(yPos, title, desc, optLevel)
    local Btn = Instance.new("TextButton", DevInner)
    Btn.Size = UDim2.new(1, -30, 0, 60)
    Btn.Position = UDim2.new(0, 15, 0, yPos)
    Btn.BackgroundColor3 = Theme.Secondary
    Btn.Text = ""
    UI:Smooth(Btn, 10)
    UI:Stroke(Btn, Theme.Accent, 0.7)
    Btn.ClipsDescendants = true

    local TitleLabel = Instance.new("TextLabel", Btn)
    TitleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold  -- DÜZELTME
    TitleLabel.TextSize = 12
    TitleLabel.Text = title
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 3

    local DescLabel = Instance.new("TextLabel", Btn)
    DescLabel.Size = UDim2.new(1, 0, 0.5, 0)
    DescLabel.Position = UDim2.new(0, 0, 0.5, 0)
    DescLabel.TextColor3 = Theme.SubText
    DescLabel.Font = Enum.Font.Gotham      -- DÜZELTME
    DescLabel.TextSize = 10
    DescLabel.Text = desc
    DescLabel.BackgroundTransparency = 1
    DescLabel.ZIndex = 3

    local LoadBar = Instance.new("Frame", Btn)
    LoadBar.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadBar.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadBar.Size = UDim2.new(0, 0, 1, 0)
    LoadBar.BackgroundColor3 = Theme.Green
    LoadBar.BackgroundTransparency = 0.5
    LoadBar.BorderSizePixel = 0
    UI:Smooth(LoadBar, 10)
    LoadBar.ZIndex = 2

    local isApplied = false
    Btn.MouseButton1Click:Connect(function()
        if isApplied then return end
        isApplied = true

        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -34, 0, 56)}):Play()
        task.delay(0.1, function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -30, 0, 60)}):Play()
        end)

        task.spawn(function()
            TitleLabel.Text = "YÜKLENİYOR: %0"
            TweenService:Create(LoadBar, TweenInfo.new(2, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 1, 0)}):Play()

            for i = 1, 100 do
                TitleLabel.Text = "YÜKLENİYOR: %" .. i
                task.wait(4 / 100)
            end

            TitleLabel.Text = "UYGULANDI"
            TitleLabel.TextColor3 = Color3.new(1, 1, 1)
            DescLabel.TextTransparency = 1
            TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Green}):Play()

            if optLevel == 1 then
                pcall(function() settings().Physics.AllowSleep = true end)
                task.spawn(function()
                    while task.wait(5) do pcall(function() collectgarbage("collect") end) end
                end)
            elseif optLevel == 2 then
                pcall(function() SafeSetFPS(120) end)
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                pcall(function() settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled end)
                pcall(function() game:GetService("NetworkSettings").IncomingReplicationLag = 0 end)
                Lighting.GlobalShadows = false
            elseif optLevel == 3 then
                pcall(function() Lighting.Technology = Enum.Technology.Compatibility end)
                pcall(function() game:GetService("ContentProvider"):ClearContext() end)
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.CastShadow = false
                        v.Reflectance = 0
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 1
                    end
                end
            end

            task.wait(3)
            TweenService:Create(Btn, TweenInfo.new(1), {BackgroundColor3 = Color3.fromRGB(15, 20, 15)}):Play()
            TweenService:Create(LoadBar, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
            TweenService:Create(TitleLabel, TweenInfo.new(1), {TextColor3 = Theme.SubText}):Play()
        end)
    end)
end

CreateEngineButton(30,  "1. GÜVENLİ OPTİMİZASYON",  "Fizik uyku modu ve arka plan bellek (RAM) temizliği.", 1)
CreateEngineButton(100, "2. AGRESİF OPTİMİZASYON",   "Render API zorlaması, gölge iptali ve ağ sıfırlama.",  2)
CreateEngineButton(170, "3. DENEYSEL (EXTREME)",      "Işık motorunu eskiye zorlar, kaplamaları siler.",       3)

-- Enter butonu mantığı (değişmedi)
EnterBtn.MouseButton1Click:Connect(function()
    if DevInput.Text == "dev-zenith" and not DevPanelActive then
        DevPanelActive = true
        EnterBtn.Text = "ERİŞİM ONAYLANDI"
        EnterBtn.BackgroundColor3 = Theme.Green
        DevPanel.Visible = true
        TweenService:Create(DevPanel, Theme.Easing, {Position = UDim2.new(1, -300, 0.5, -145)}):Play()
    elseif DevInput.Text ~= "dev-zenith" then
        EnterBtn.Text = "HATALI ŞİFRE!"
        EnterBtn.BackgroundColor3 = Theme.Red
        task.wait(1.5)
        EnterBtn.Text = "ENTER"
        EnterBtn.BackgroundColor3 = Theme.Accent
    end
end)
