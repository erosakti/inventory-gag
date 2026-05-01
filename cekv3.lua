--[[ 
    📊 GROW A GARDEN: PREMIUM PET TRACKER (V5 - FINAL + SEARCH BAR)
    Fitur: Auto-Detect Capacity, Strict Pet Filter, Auto-Update List, & LIVE SEARCH!
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local MaxBackpackCapacity = 100 
local DynamicPetList = {}
local SelectedPet = "Menunggu Data..."

-- ==================================================================
-- 🔍 SISTEM EKSTRAKSI DATABASE (PERFECT "EGG" FILTER)
-- ==================================================================
local function FetchMasterPetList()
    local rawList = {}
    
    for _, t in pairs(getgc(true)) do
        if type(t) == "table" then
            pcall(function()
                local tempNames = {}
                local isPetDatabase = false
                
                for key, val in pairs(t) do
                    if type(key) == "string" and type(val) == "table" then
                        -- FILTER ABSOLUT: Hanya ambil item yang punya EggType atau HatchTime
                        if rawget(val, "EggType") or rawget(val, "HatchTime") then
                            table.insert(tempNames, key)
                            isPetDatabase = true
                        end
                    end
                end
                
                if isPetDatabase and #tempNames > 5 then
                    for _, n in ipairs(tempNames) do table.insert(rawList, n) end
                end
            end)
        end
    end
    
    if #rawList == 0 then
        rawList = {
            "Giant Scorpion", "Rainbow Dilophosaurus", "Rainbow Elephant", 
            "Ghostly Headless Horseman", "Rainbow Birb", "Seal", "Flamingo", 
            "Toucan", "Sea Turtle", "Orang Utan", "Mimic Octopus", "Kitsune", 
            "Raccoon", "Peryton", "Gilded Choc Peryton", "Arctic Fox", 
            "Rainbow Frost Dragon", "Rainbow Cerberus"
        }
    end
    
    local uniqueNames = {}
    local finalSorted = {}
    for _, name in ipairs(rawList) do
        if not uniqueNames[name] then
            uniqueNames[name] = true
            table.insert(finalSorted, name)
        end
    end
    
    table.sort(finalSorted)
    return finalSorted
end

DynamicPetList = FetchMasterPetList()

if table.find(DynamicPetList, "Mimic Octopus") then
    SelectedPet = "Mimic Octopus"
elseif #DynamicPetList > 0 then
    SelectedPet = DynamicPetList[1]
end

-- ==================================================================
-- 🧠 SISTEM PENYADAP MEMORI (KAPASITAS TAS V2)
-- ==================================================================
local CachedMemoryTable = nil

local function GetMaxCapacityFromMemory(currentPetCount)
    if CachedMemoryTable and type(CachedMemoryTable.MaxPetsInInventory) == "number" then
        if CachedMemoryTable.MaxPetsInInventory >= currentPetCount then return CachedMemoryTable.MaxPetsInInventory
        else CachedMemoryTable = nil end
    end

    local possibleTables = {}
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" then
            if rawget(v, "MaxPetsInInventory") and type(v.MaxPetsInInventory) == "number" then
                local isOurs = false
                for _, val in pairs(v) do
                    if val == LocalPlayer.Name or val == LocalPlayer.UserId or val == LocalPlayer then
                        isOurs = true; break
                    end
                end
                if isOurs then CachedMemoryTable = v; return v.MaxPetsInInventory end
                table.insert(possibleTables, v)
            end
        end
    end
    
    local bestCandidate = nil
    for _, t in ipairs(possibleTables) do
        if t.MaxPetsInInventory >= currentPetCount then
            if not bestCandidate or t.MaxPetsInInventory < bestCandidate.MaxPetsInInventory then
                bestCandidate = t
            end
        end
    end
    if bestCandidate then CachedMemoryTable = bestCandidate; return bestCandidate.MaxPetsInInventory end
    return nil
end

-- ==================================================================
-- 🛠️ FUNGSI MENGHITUNG PET (STRICT FILTER)
-- ==================================================================
local function GetPetStats(targetPetName)
    local targetFav = 0; local targetUnfav = 0; local totalAllPets = 0
    local countedUUIDs = {}; local lowerTarget = string.lower(targetPetName)
    local searchAreas = {LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}
    
    for _, area in pairs(searchAreas) do
        if area then
            for _, item in pairs(area:GetChildren()) do
                if item:IsA("Tool") then
                    local itemType = item:GetAttribute("ItemType")
                    local petType = item:GetAttribute("PetType")
                    if itemType == "Pet" or petType == "Pet" then
                        local petUUID = item:GetAttribute("PET_UUID")
                        local uuid = petUUID or item
                        if not countedUUIDs[uuid] then
                            countedUUIDs[uuid] = true
                            totalAllPets = totalAllPets + 1 
                            local realName = item:GetAttribute("f")
                            local isMatch = false
                            if realName and string.lower(realName) == lowerTarget then isMatch = true
                            elseif item.Name and string.find(string.lower(item.Name), lowerTarget, 1, true) then isMatch = true end
                            if isMatch then
                                if item:GetAttribute("d") == true then targetFav = targetFav + 1 else targetUnfav = targetUnfav + 1 end
                            end
                        end
                    end
                end
            end
        end
    end
    return targetFav, targetUnfav, totalAllPets
end

-- ==================================================================
-- 🎨 PEMBUATAN UI (DENGAN SEARCH BAR)
-- ==================================================================
local GuiParent = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if GuiParent:FindFirstChild("DualPetCounterGUI") then GuiParent.DualPetCounterGUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "DualPetCounterGUI"; ScreenGui.Parent = GuiParent; ScreenGui.ResetOnSpawn = false

local OpenBtn = Instance.new("ImageButton"); OpenBtn.Name = "OpenButton"; OpenBtn.Parent = ScreenGui; OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); OpenBtn.Position = UDim2.new(0, 15, 0.5, -20); OpenBtn.Size = UDim2.new(0, 40, 0, 40); OpenBtn.Image = "rbxassetid://13110260460"; OpenBtn.Visible = false; OpenBtn.Active = true; OpenBtn.Draggable = true; Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", OpenBtn); Stroke.Color = Color3.fromRGB(70, 130, 180); Stroke.Thickness = 2

local normalSize = UDim2.new(0, 275, 0, 145)
local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); MainFrame.Position = UDim2.new(0.5, -135, 0.2, 0); MainFrame.Size = normalSize; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.BorderSizePixel = 0; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local HeaderFrame = Instance.new("Frame"); HeaderFrame.Name = "HeaderFrame"; HeaderFrame.Parent = MainFrame; HeaderFrame.Size = UDim2.new(1, 0, 0, 35); HeaderFrame.BackgroundTransparency = 1; HeaderFrame.ZIndex = 2
local Icon = Instance.new("ImageLabel"); Icon.Parent = HeaderFrame; Icon.BackgroundTransparency = 1; Icon.Position = UDim2.new(0, 10, 0, 5); Icon.Size = UDim2.new(0, 25, 0, 25); Icon.Image = "rbxassetid://13110260460"; Icon.ScaleType = Enum.ScaleType.Fit; Icon.ZIndex = 2
local Title = Instance.new("TextLabel"); Title.Parent = HeaderFrame; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 40, 0, 5); Title.Size = UDim2.new(1, -110, 0, 25); Title.Font = Enum.Font.GothamBold; Title.Text = "PREMIUM TRACKER"; Title.TextColor3 = Color3.fromRGB(255, 215, 0); Title.TextSize = 12; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 2

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = HeaderFrame; CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.ZIndex = 2; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
local MinBtn = Instance.new("TextButton"); MinBtn.Parent = HeaderFrame; MinBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180); MinBtn.Position = UDim2.new(1, -60, 0, 5); MinBtn.Size = UDim2.new(0, 25, 0, 25); MinBtn.Font = Enum.Font.GothamBold; MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MinBtn.ZIndex = 2; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local ContentFrame = Instance.new("Frame"); ContentFrame.Parent = MainFrame; ContentFrame.Position = UDim2.new(0, 0, 0, 35); ContentFrame.Size = UDim2.new(1, 0, 1, -35); ContentFrame.BackgroundTransparency = 1
local DropdownBtn = Instance.new("TextButton"); DropdownBtn.Parent = ContentFrame; DropdownBtn.Position = UDim2.new(0, 10, 0, 5); DropdownBtn.Size = UDim2.new(1, -20, 0, 28); DropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); DropdownBtn.Font = Enum.Font.GothamSemibold; DropdownBtn.Text = "  " .. SelectedPet .. "  ▼"; DropdownBtn.TextColor3 = Color3.fromRGB(220, 220, 220); DropdownBtn.TextSize = 12; DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 4)

-- Stats & Ransel
local StatsFrame = Instance.new("Frame"); StatsFrame.Parent = ContentFrame; StatsFrame.Position = UDim2.new(0, 10, 0, 40); StatsFrame.Size = UDim2.new(1, -20, 0, 25); StatsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 4)
local FavLbl = Instance.new("TextLabel"); FavLbl.Parent = StatsFrame; FavLbl.Size = UDim2.new(0.33, 0, 1, 0); FavLbl.Position = UDim2.new(0, 0, 0, 0); FavLbl.BackgroundTransparency = 1; FavLbl.Font = Enum.Font.GothamBold; FavLbl.Text = "⭐ 0"; FavLbl.TextColor3 = Color3.fromRGB(150, 150, 150); FavLbl.TextSize = 12
local UnfavLbl = Instance.new("TextLabel"); UnfavLbl.Parent = StatsFrame; UnfavLbl.Size = UDim2.new(0.33, 0, 1, 0); UnfavLbl.Position = UDim2.new(0.33, 0, 0, 0); UnfavLbl.BackgroundTransparency = 1; UnfavLbl.Font = Enum.Font.GothamBold; UnfavLbl.Text = "📦 0"; UnfavLbl.TextColor3 = Color3.fromRGB(150, 150, 150); UnfavLbl.TextSize = 12
local TotalLbl = Instance.new("TextLabel"); TotalLbl.Parent = StatsFrame; TotalLbl.Size = UDim2.new(0.33, 0, 1, 0); TotalLbl.Position = UDim2.new(0.66, 0, 0, 0); TotalLbl.BackgroundTransparency = 1; TotalLbl.Font = Enum.Font.GothamBold; TotalLbl.Text = "🐾 0"; TotalLbl.TextColor3 = Color3.fromRGB(150, 150, 150); TotalLbl.TextSize = 12

local RanselFrame = Instance.new("Frame"); RanselFrame.Parent = ContentFrame; RanselFrame.Position = UDim2.new(0, 10, 0, 75); RanselFrame.Size = UDim2.new(1, -20, 0, 25); RanselFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", RanselFrame).CornerRadius = UDim.new(0, 4)
local RanselTitle = Instance.new("TextLabel"); RanselTitle.Parent = RanselFrame; RanselTitle.Size = UDim2.new(0, 60, 1, 0); RanselTitle.Position = UDim2.new(0, 5, 0, 0); RanselTitle.BackgroundTransparency = 1; RanselTitle.Font = Enum.Font.Gotham; RanselTitle.Text = "Ransel:"; RanselTitle.TextColor3 = Color3.fromRGB(180, 180, 180); RanselTitle.TextSize = 10; RanselTitle.TextXAlignment = Enum.TextXAlignment.Left
local TotalIsiLbl = Instance.new("TextLabel"); TotalIsiLbl.Parent = RanselFrame; TotalIsiLbl.Size = UDim2.new(0, 40, 1, 0); TotalIsiLbl.Position = UDim2.new(0, 45, 0, 0); TotalIsiLbl.BackgroundTransparency = 1; TotalIsiLbl.Font = Enum.Font.GothamBold; TotalIsiLbl.Text = "0"; TotalIsiLbl.TextColor3 = Color3.fromRGB(255, 255, 255); TotalIsiLbl.TextSize = 11; TotalIsiLbl.TextXAlignment = Enum.TextXAlignment.Right
local SlashLbl = Instance.new("TextLabel"); SlashLbl.Parent = RanselFrame; SlashLbl.Size = UDim2.new(0, 10, 1, 0); SlashLbl.Position = UDim2.new(0, 87, 0, 0); SlashLbl.BackgroundTransparency = 1; SlashLbl.Font = Enum.Font.Gotham; SlashLbl.Text = "/"; SlashLbl.TextColor3 = Color3.fromRGB(150, 150, 150); SlashLbl.TextSize = 11

local MaxInputBox = Instance.new("TextBox"); MaxInputBox.Parent = RanselFrame; MaxInputBox.Size = UDim2.new(0, 35, 0, 18); MaxInputBox.Position = UDim2.new(0, 98, 0, 3.5); MaxInputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45); MaxInputBox.Font = Enum.Font.GothamBold; MaxInputBox.Text = tostring(MaxBackpackCapacity); MaxInputBox.TextColor3 = Color3.fromRGB(0, 255, 200); MaxInputBox.TextSize = 10; MaxInputBox.TextEditable = false; Instance.new("UICorner", MaxInputBox).CornerRadius = UDim.new(0, 4)
local SisaSlotLbl = Instance.new("TextLabel"); SisaSlotLbl.Parent = RanselFrame; SisaSlotLbl.Size = UDim2.new(0, 100, 1, 0); SisaSlotLbl.Position = UDim2.new(1, -105, 0, 0); SisaSlotLbl.BackgroundTransparency = 1; SisaSlotLbl.Font = Enum.Font.GothamBold; SisaSlotLbl.Text = "Kosong: 0"; SisaSlotLbl.TextColor3 = Color3.fromRGB(100, 255, 100); SisaSlotLbl.TextSize = 10; SisaSlotLbl.TextXAlignment = Enum.TextXAlignment.Right

-- ==================================================================
-- 🔍 FITUR SEARCH BAR & DROPDOWN LIST
-- ==================================================================
-- Search Box
local SearchBox = Instance.new("TextBox"); SearchBox.Parent = ContentFrame; SearchBox.Position = UDim2.new(0, 10, 0, 35); SearchBox.Size = UDim2.new(1, -20, 0, 25); SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55); SearchBox.Font = Enum.Font.Gotham; SearchBox.PlaceholderText = "🔍 Cari Pet..."; SearchBox.Text = ""; SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); SearchBox.TextSize = 11; SearchBox.ClearTextOnFocus = false; SearchBox.Visible = false; SearchBox.ZIndex = 11; Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

-- Scrolling Frame
local DropListScroll = Instance.new("ScrollingFrame"); DropListScroll.Parent = ContentFrame; DropListScroll.Position = UDim2.new(0, 10, 0, 65); DropListScroll.Size = UDim2.new(1, -20, 0, 125); DropListScroll.BackgroundColor3 = Color3.fromRGB(45, 45, 50); DropListScroll.ScrollBarThickness = 4; DropListScroll.BorderSizePixel = 0; DropListScroll.Visible = false; DropListScroll.ZIndex = 10; Instance.new("UICorner", DropListScroll).CornerRadius = UDim.new(0, 4)
local UIListLayout = Instance.new("UIListLayout"); UIListLayout.Parent = DropListScroll; UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Simpan tombol ke dalam tabel agar bisa di-filter
local PetButtons = {}

for _, petName in ipairs(DynamicPetList) do
    local btn = Instance.new("TextButton"); btn.Parent = DropListScroll; btn.Size = UDim2.new(1, 0, 0, 25); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50); btn.BorderSizePixel = 0; btn.Font = Enum.Font.Gotham; btn.Text = "  " .. petName; btn.TextColor3 = Color3.fromRGB(220, 220, 220); btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.ZIndex = 10
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) end)
    btn.MouseButton1Click:Connect(function()
        SelectedPet = petName; DropdownBtn.Text = "  " .. SelectedPet .. "  ▼"
        DropListScroll.Visible = false; SearchBox.Visible = false; MainFrame.Size = normalSize
    end)
    table.insert(PetButtons, btn)
end

-- Update ukuran scroll saat ada yang difilter
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    DropListScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

-- Logika Live Search
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = string.lower(SearchBox.Text)
    for _, btn in ipairs(PetButtons) do
        -- Hapus spasi di awal nama tombol agar pencarian akurat
        local cleanPetName = string.lower(string.match(btn.Text, "^%s*(.-)%s*$"))
        if searchText == "" or string.find(cleanPetName, searchText, 1, true) then
            btn.Visible = true
        else
            btn.Visible = false
        end
    end
end)

-- Toggle Menu Dropdown & Search
DropdownBtn.MouseButton1Click:Connect(function()
    local isOpening = not DropListScroll.Visible
    DropListScroll.Visible = isOpening
    SearchBox.Visible = isOpening
    
    if isOpening then 
        MainFrame.Size = UDim2.new(0, 275, 0, 235) -- Perbesar UI untuk memuat search bar
        SearchBox.Text = "" -- Reset kata pencarian saat menu dibuka
        for _, btn in pairs(PetButtons) do btn.Visible = true end -- Tampilkan semua pet lagi
    else 
        MainFrame.Size = normalSize 
    end
end)

-- ==================================================================
-- FUNGSI UTAMA
-- ==================================================================
local function UpdateDisplay()
    local fav, unfav, totalSemua = GetPetStats(SelectedPet)
    local totalTarget = fav + unfav
    
    FavLbl.Text = "⭐ " .. fav; FavLbl.TextColor3 = (fav > 0) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(100, 100, 100)
    UnfavLbl.Text = "📦 " .. unfav; UnfavLbl.TextColor3 = (unfav > 0) and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(100, 100, 100)
    TotalLbl.Text = "🐾 " .. totalTarget; TotalLbl.TextColor3 = (totalTarget > 0) and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(100, 100, 100)
    
    local detectedMax = GetMaxCapacityFromMemory(totalSemua)
    if detectedMax and detectedMax ~= MaxBackpackCapacity then
        MaxBackpackCapacity = detectedMax
        MaxInputBox.Text = tostring(MaxBackpackCapacity)
        MaxInputBox.TextColor3 = Color3.fromRGB(0, 255, 255) 
    end
    
    TotalIsiLbl.Text = tostring(totalSemua)
    
    local sisaSlot = MaxBackpackCapacity - totalSemua
    if sisaSlot > 0 then
        SisaSlotLbl.Text = "Sisa: " .. sisaSlot; SisaSlotLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        SisaSlotLbl.Text = "FULL!"; SisaSlotLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

-- Tombol Kontrol Window
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = true; MainFrame.Visible = false; DropListScroll.Visible = false; SearchBox.Visible = false
    MainFrame.Size = normalSize; OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    isMinimized = false; OpenBtn.Visible = false; MainFrame.Visible = true; UpdateDisplay()
end)

-- Loop Realtime
task.spawn(function()
    while task.wait(1.5) do
        if not GuiParent:FindFirstChild("DualPetCounterGUI") then break end
        if not isMinimized then UpdateDisplay() end
    end
end)
