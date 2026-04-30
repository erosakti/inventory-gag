--[[ 
    📊 LIVE PET INVENTORY COUNTER (GROW A GARDEN)
    Fitur: Dropdown Menu, Floating Logo Minimize, Track Favorit (⭐), Tidak Favorit (📦), & Total (🐾)
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local PETS_TO_COUNT = {
    "Mimic Octopus"
}

-- Pet yang sedang dipilih (Default: Pet pertama di daftar)
local SelectedPet = PETS_TO_COUNT[1]

-- ==================================================================
-- 🛠️ FUNGSI MENGHITUNG STATUS (GROW A GARDEN DECODER)
-- ==================================================================
local function GetPetCounts(petName)
    local favCount = 0
    local unfavCount = 0
    local countedUUIDs = {}
    local lowerPetName = string.lower(petName)
    
    local searchAreas = {
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer.Character
    }
    
    for _, area in pairs(searchAreas) do
        if area then
            for _, item in pairs(area:GetChildren()) do
                if item:IsA("Tool") then
                    
                    local realName = item:GetAttribute("f")
                    local isMatch = false
                    
                    if realName and string.lower(realName) == lowerPetName then
                        isMatch = true
                    elseif item.Name and string.find(string.lower(item.Name), lowerPetName, 1, true) then
                        isMatch = true
                    end
                    
                    if isMatch then
                        local uuid = item:GetAttribute("PET_UUID") or item
                        
                        if not countedUUIDs[uuid] then
                            countedUUIDs[uuid] = true
                            local isFav = item:GetAttribute("d")
                            if isFav == true then
                                favCount = favCount + 1
                            else
                                unfavCount = unfavCount + 1
                            end
                        end
                    end
                    
                end
            end
        end
    end
    
    return favCount, unfavCount
end

-- ==================================================================
-- 🎨 PEMBUATAN UI (DROPDOWN & FLOATING LOGO)
-- ==================================================================
local GuiParent = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if GuiParent:FindFirstChild("DualPetCounterGUI") then GuiParent.DualPetCounterGUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "DualPetCounterGUI"; ScreenGui.Parent = GuiParent; ScreenGui.ResetOnSpawn = false

-- === LOGO KECIL (FLOATING BUTTON) ===
local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name = "OpenButton"
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -20) -- Posisi default di kiri layar
OpenBtn.Size = UDim2.new(0, 40, 0, 40)
OpenBtn.Image = "rbxassetid://13110260460" -- Ikon grafik batang
OpenBtn.Visible = false -- Disembunyikan secara default
OpenBtn.Active = true
OpenBtn.Draggable = true -- Bisa digeser-geser bebas
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", OpenBtn)
Stroke.Color = Color3.fromRGB(70, 130, 180)
Stroke.Thickness = 2

-- === MAIN FRAME ===
local normalSize = UDim2.new(0, 275, 0, 105)

local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); MainFrame.Position = UDim2.new(0.5, -135, 0.2, 0); MainFrame.Size = normalSize; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.BorderSizePixel = 0; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Header Panel
local HeaderFrame = Instance.new("Frame"); HeaderFrame.Name = "HeaderFrame"; HeaderFrame.Parent = MainFrame; HeaderFrame.Size = UDim2.new(1, 0, 0, 35); HeaderFrame.BackgroundTransparency = 1; HeaderFrame.ZIndex = 2
local Icon = Instance.new("ImageLabel"); Icon.Parent = HeaderFrame; Icon.BackgroundTransparency = 1; Icon.Position = UDim2.new(0, 10, 0, 5); Icon.Size = UDim2.new(0, 25, 0, 25); Icon.Image = "rbxassetid://13110260460"; Icon.ScaleType = Enum.ScaleType.Fit; Icon.ZIndex = 2
local Title = Instance.new("TextLabel"); Title.Parent = HeaderFrame; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 40, 0, 5); Title.Size = UDim2.new(1, -110, 0, 25); Title.Font = Enum.Font.GothamBold; Title.Text = "PET TRACKER"; Title.TextColor3 = Color3.fromRGB(200, 200, 255); Title.TextSize = 12; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 2

-- Tombol Close & Minimize
local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = HeaderFrame; CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.ZIndex = 2; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinBtn = Instance.new("TextButton"); MinBtn.Parent = HeaderFrame; MinBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180); MinBtn.Position = UDim2.new(1, -60, 0, 5); MinBtn.Size = UDim2.new(0, 25, 0, 25); MinBtn.Font = Enum.Font.GothamBold; MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MinBtn.ZIndex = 2; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Area Konten
local ContentFrame = Instance.new("Frame"); ContentFrame.Parent = MainFrame; ContentFrame.Position = UDim2.new(0, 0, 0, 35); ContentFrame.Size = UDim2.new(1, 0, 1, -35); ContentFrame.BackgroundTransparency = 1

-- Tombol Dropdown Menu
local DropdownBtn = Instance.new("TextButton"); DropdownBtn.Parent = ContentFrame; DropdownBtn.Position = UDim2.new(0, 10, 0, 5); DropdownBtn.Size = UDim2.new(1, -20, 0, 28); DropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); DropdownBtn.Font = Enum.Font.GothamSemibold; DropdownBtn.Text = "  " .. SelectedPet .. "  ▼"; DropdownBtn.TextColor3 = Color3.fromRGB(220, 220, 220); DropdownBtn.TextSize = 12; DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 4)

-- Panel Info Statistik
local StatsFrame = Instance.new("Frame"); StatsFrame.Parent = ContentFrame; StatsFrame.Position = UDim2.new(0, 10, 0, 40); StatsFrame.Size = UDim2.new(1, -20, 0, 25); StatsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 4)

local FavLbl = Instance.new("TextLabel"); FavLbl.Parent = StatsFrame; FavLbl.Size = UDim2.new(0.33, 0, 1, 0); FavLbl.Position = UDim2.new(0, 0, 0, 0); FavLbl.BackgroundTransparency = 1; FavLbl.Font = Enum.Font.GothamBold; FavLbl.Text = "⭐ 0"; FavLbl.TextColor3 = Color3.fromRGB(150, 150, 150); FavLbl.TextSize = 12
local UnfavLbl = Instance.new("TextLabel"); UnfavLbl.Parent = StatsFrame; UnfavLbl.Size = UDim2.new(0.33, 0, 1, 0); UnfavLbl.Position = UDim2.new(0.33, 0, 0, 0); UnfavLbl.BackgroundTransparency = 1; UnfavLbl.Font = Enum.Font.GothamBold; UnfavLbl.Text = "📦 0"; UnfavLbl.TextColor3 = Color3.fromRGB(150, 150, 150); UnfavLbl.TextSize = 12
local TotalLbl = Instance.new("TextLabel"); TotalLbl.Parent = StatsFrame; TotalLbl.Size = UDim2.new(0.33, 0, 1, 0); TotalLbl.Position = UDim2.new(0.66, 0, 0, 0); TotalLbl.BackgroundTransparency = 1; TotalLbl.Font = Enum.Font.GothamBold; TotalLbl.Text = "🐾 0"; TotalLbl.TextColor3 = Color3.fromRGB(150, 150, 150); TotalLbl.TextSize = 12

-- List Dropdown (Disembunyikan secara default)
local DropListScroll = Instance.new("ScrollingFrame"); DropListScroll.Parent = ContentFrame; DropListScroll.Position = UDim2.new(0, 10, 0, 35); DropListScroll.Size = UDim2.new(1, -20, 0, 130); DropListScroll.BackgroundColor3 = Color3.fromRGB(45, 45, 50); DropListScroll.ScrollBarThickness = 4; DropListScroll.BorderSizePixel = 0; DropListScroll.Visible = false; DropListScroll.ZIndex = 10; Instance.new("UICorner", DropListScroll).CornerRadius = UDim.new(0, 4)
local UIListLayout = Instance.new("UIListLayout"); UIListLayout.Parent = DropListScroll; UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Fungsi Update Tampilan Statistik
local function UpdateDisplay()
    local fav, unfav = GetPetCounts(SelectedPet)
    local total = fav + unfav
    
    FavLbl.Text = "⭐ " .. fav
    FavLbl.TextColor3 = (fav > 0) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(100, 100, 100)
    
    UnfavLbl.Text = "📦 " .. unfav
    UnfavLbl.TextColor3 = (unfav > 0) and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(100, 100, 100)
    
    TotalLbl.Text = "🐾 " .. total
    TotalLbl.TextColor3 = (total > 0) and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(100, 100, 100)
end

-- Isi daftar Dropdown
for _, petName in ipairs(PETS_TO_COUNT) do
    local btn = Instance.new("TextButton"); btn.Parent = DropListScroll; btn.Size = UDim2.new(1, 0, 0, 25); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50); btn.BorderSizePixel = 0; btn.Font = Enum.Font.Gotham; btn.Text = "  " .. petName; btn.TextColor3 = Color3.fromRGB(220, 220, 220); btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.ZIndex = 10
    
    -- Efek Hover
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) end)
    
    -- Saat Pet Dipilih
    btn.MouseButton1Click:Connect(function()
        SelectedPet = petName
        DropdownBtn.Text = "  " .. SelectedPet .. "  ▼"
        DropListScroll.Visible = false
        MainFrame.Size = normalSize 
        UpdateDisplay()
    end)
end
DropListScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)

-- Logika Buka/Tutup Dropdown
DropdownBtn.MouseButton1Click:Connect(function()
    DropListScroll.Visible = not DropListScroll.Visible
    if DropListScroll.Visible then
        MainFrame.Size = UDim2.new(0, 275, 0, 205) 
    else
        MainFrame.Size = normalSize
    end
end)

-- ==================================================================
-- 🔘 LOGIKA TOMBOL MINIMIZE KE LOGO
-- ==================================================================
local isMinimized = false

-- Saat tombol minus ditekan
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = true
    MainFrame.Visible = false -- Hilangkan UI Utama
    DropListScroll.Visible = false -- Pastikan dropdown tertutup
    OpenBtn.Visible = true -- Munculkan Logo Kecil
end)

-- Saat Logo Kecil ditekan
OpenBtn.MouseButton1Click:Connect(function()
    isMinimized = false
    OpenBtn.Visible = false -- Hilangkan Logo Kecil
    MainFrame.Visible = true -- Munculkan UI Utama
    UpdateDisplay() -- Refresh data saat dibuka
end)

-- ==================================================================
-- 🔄 LOGIC AUTO-REFRESH
-- ==================================================================
task.spawn(function()
    while task.wait(2) do
        if not GuiParent:FindFirstChild("DualPetCounterGUI") then break end
        
        -- Hanya menghitung jika UI sedang TERBUKA (Mencegah Lag)
        if not isMinimized then
            UpdateDisplay()
        end
    end
end)
