--[[ 
    📊 LIVE PET INVENTORY COUNTER (GROW A GARDEN - TRIPLE TRACKER)
    Fitur: Menampilkan Favorit (⭐), Tidak Favorit (📦), & Total (🐾)
    Tambahan: UI SUPER RAMPING & Fitur Minimize yang Diperbaiki
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local PETS_TO_COUNT = {
    "Giant Scorpion", "Rainbow Dilophosaurus", "Rainbow Elephant", 
    "Ghostly Headless Horseman", "Rainbow Birb", "Seal", "Flamingo", 
    "Toucan", "Sea Turtle", "Orang Utan", "Mimic Octopus", "Kitsune", 
    "Raccoon", "Peryton", "Gilded Choc Peryton"
}

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
                    
                    -- 1. BACA NAMA ASLI (Bypass Sandi 'f')
                    local realName = item:GetAttribute("f")
                    local isMatch = false
                    
                    if realName and string.lower(realName) == lowerPetName then
                        isMatch = true
                    elseif item.Name and string.find(string.lower(item.Name), lowerPetName, 1, true) then
                        isMatch = true
                    end
                    
                    if isMatch then
                        -- 2. BACA UUID UNTUK MENCEGAH DOBEL HITUNG
                        local uuid = item:GetAttribute("PET_UUID") or item
                        
                        if not countedUUIDs[uuid] then
                            countedUUIDs[uuid] = true
                            
                            -- 3. CEK STATUS FAVORIT (Bypass Sandi 'd')
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
-- 🎨 PEMBUATAN UI (SUPER RAMPING, HEADER FOKUS)
-- ==================================================================
local GuiParent = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if GuiParent:FindFirstChild("DualPetCounterGUI") then GuiParent.DualPetCounterGUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "DualPetCounterGUI"; ScreenGui.Parent = GuiParent; ScreenGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); MainFrame.Position = UDim2.new(0.5, -135, 0.2, 0); MainFrame.Size = UDim2.new(0, 275, 0, 180); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.BorderSizePixel = 0; MainFrame.ClipsDescendants = true; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Header Panel (Akan tetap terlihat saat diminimalkan)
local HeaderFrame = Instance.new("Frame"); HeaderFrame.Name = "HeaderFrame"; HeaderFrame.Parent = MainFrame; HeaderFrame.Size = UDim2.new(1, 0, 0, 35); HeaderFrame.BackgroundTransparency = 1

-- Ikon dan Judul
local Icon = Instance.new("ImageLabel"); Icon.Parent = HeaderFrame; Icon.BackgroundTransparency = 1; Icon.Position = UDim2.new(0, 10, 0, 5); Icon.Size = UDim2.new(0, 25, 0, 25); Icon.Image = "rbxassetid://13110260460"; Icon.ScaleType = Enum.ScaleType.Fit -- Ikon grafik batang
local Title = Instance.new("TextLabel"); Title.Parent = HeaderFrame; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 40, 0, 5); Title.Size = UDim2.new(1, -110, 0, 25); Title.Font = Enum.Font.GothamBold; Title.Text = "INVENTORY COUNTER"; Title.TextColor3 = Color3.fromRGB(200, 200, 255); Title.TextSize = 12; Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tombol Close (X)
local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = HeaderFrame; CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Tombol Minimize (-) / Maximize (+)
local MinBtn = Instance.new("TextButton"); MinBtn.Parent = HeaderFrame; MinBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180); MinBtn.Position = UDim2.new(1, -60, 0, 5); MinBtn.Size = UDim2.new(0, 25, 0, 25); MinBtn.Font = Enum.Font.GothamBold; MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Area Scroll (Untuk daftar pet)
local ScrollFrame = Instance.new("ScrollingFrame"); ScrollFrame.Parent = MainFrame; ScrollFrame.Position = UDim2.new(0, 10, 0, 40); ScrollFrame.Size = UDim2.new(1, -20, 1, -50); ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35); ScrollFrame.ScrollBarThickness = 3; ScrollFrame.BorderSizePixel = 0; Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 6)
local UIListLayout = Instance.new("UIListLayout"); UIListLayout.Parent = ScrollFrame; UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.Padding = UDim.new(0, 3); Instance.new("UIPadding", ScrollFrame).PaddingTop = UDim.new(0, 3)

-- Logika Minimize yang Diperbaiki
local isMinimized = false
local normalSize = UDim2.new(0, 275, 0, 180) -- Ukuran ramping yang baru
local minimizedSize = UDim2.new(0, 275, 0, 35) -- Ukuran header saja

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = minimizedSize -- Lipat ke ukuran header
        ScrollFrame.Visible = false -- Sembunyikan daftar
        MinBtn.Text = "+" -- Ubah ikon menjadi Plus
    else
        MainFrame.Size = normalSize -- Kembali ke ukuran ramping
        ScrollFrame.Visible = true -- Tampilkan daftar
        MinBtn.Text = "-" -- Ubah ikon kembali ke Minus
    end
end)

local ItemLabels = {}

for _, petName in ipairs(PETS_TO_COUNT) do
    local petContainer = Instance.new("Frame"); petContainer.Parent = ScrollFrame; petContainer.Size = UDim2.new(1, -8, 0, 20); petContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45); Instance.new("UICorner", petContainer).CornerRadius = UDim.new(0, 4)
    
    -- Nama Pet (Lebih ramping)
    local nameLbl = Instance.new("TextLabel"); nameLbl.Parent = petContainer; nameLbl.Size = UDim2.new(1, -145, 1, 0); nameLbl.Position = UDim2.new(0, 5, 0, 0); nameLbl.BackgroundTransparency = 1; nameLbl.Font = Enum.Font.Gotham; nameLbl.Text = petName; nameLbl.TextColor3 = Color3.fromRGB(220, 220, 220); nameLbl.TextSize = 10; nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Kolom Angka Favorit (Kiri)
    local favLbl = Instance.new("TextLabel"); favLbl.Parent = petContainer; favLbl.Size = UDim2.new(0, 38, 1, 0); favLbl.Position = UDim2.new(1, -138, 0, 0); favLbl.BackgroundTransparency = 1; favLbl.Font = Enum.Font.GothamBold; favLbl.Text = "⭐ 0"; favLbl.TextColor3 = Color3.fromRGB(150, 150, 150); favLbl.TextSize = 10; favLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Kolom Angka Tidak Favorit (Tengah)
    local unfavLbl = Instance.new("TextLabel"); unfavLbl.Parent = petContainer; unfavLbl.Size = UDim2.new(0, 38, 1, 0); unfavLbl.Position = UDim2.new(1, -93, 0, 0); unfavLbl.BackgroundTransparency = 1; unfavLbl.Font = Enum.Font.GothamBold; unfavLbl.Text = "📦 0"; unfavLbl.TextColor3 = Color3.fromRGB(150, 150, 150); unfavLbl.TextSize = 10; unfavLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Kolom Angka Total (Kanan)
    local totalLbl = Instance.new("TextLabel"); totalLbl.Parent = petContainer; totalLbl.Size = UDim2.new(0, 38, 1, 0); totalLbl.Position = UDim2.new(1, -48, 0, 0); totalLbl.BackgroundTransparency = 1; totalLbl.Font = Enum.Font.GothamBold; totalLbl.Text = "🐾 0"; totalLbl.TextColor3 = Color3.fromRGB(150, 150, 150); totalLbl.TextSize = 10; totalLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    ItemLabels[petName] = { fav = favLbl, unfav = unfavLbl, total = totalLbl }
end
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)

-- ==================================================================
-- 🔄 LOGIC AUTO-REFRESH
-- ==================================================================
task.spawn(function()
    while task.wait(2) do
        if not GuiParent:FindFirstChild("DualPetCounterGUI") then break end
        
        for petName, labels in pairs(ItemLabels) do
            local favCount, unfavCount = GetPetCounts(petName)
            local totalCount = favCount + unfavCount
            
            -- Update UI Favorit
            labels.fav.Text = "⭐ " .. favCount
            if favCount > 0 then 
                labels.fav.TextColor3 = Color3.fromRGB(255, 215, 0) -- Kuning Emas
            else 
                labels.fav.TextColor3 = Color3.fromRGB(100, 100, 100) 
            end
            
            -- Update UI Tidak Favorit
            labels.unfav.Text = "📦 " .. unfavCount
            if unfavCount > 0 then 
                labels.unfav.TextColor3 = Color3.fromRGB(100, 255, 100) -- Hijau Terang
            else 
                labels.unfav.TextColor3 = Color3.fromRGB(100, 100, 100) 
            end
            
            -- Update UI Total
            labels.total.Text = "🐾 " .. totalCount
            if totalCount > 0 then
                labels.total.TextColor3 = Color3.fromRGB(100, 200, 255) -- Biru Terang
            else
                labels.total.TextColor3 = Color3.fromRGB(100, 100, 100)
            end
        end
    end
end)
