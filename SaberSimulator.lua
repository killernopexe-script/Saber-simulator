-- Загрузка Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- === RAYFIELD WINDOW ===
local Window = Rayfield:CreateWindow({
    Name = "Christmas Event Auto Farm",
    LoadingTitle = "Christmas Event Auto Farm",
    LoadingSubtitle = "by Scripting",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ChristmasAutoFarm",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

-- Переменные для авто-фарма
local autoHitEnabled = false
local autoCandyEnabled = false
local autoEggsEnabled = false
local hitConnection, candyConnection, eggsConnection

-- Функция для безопасного выполнения с проверкой существования объектов
local function safeExecute(callback)
    local success, error = pcall(callback)
    if not success then
        -- Тихий режим, не выводим ошибки
    end
end

-- Функция безопасного получения объекта
local function getSafeObject(path)
    local current = Workspace
    for _, part in ipairs(path) do
        current = current:FindFirstChild(part)
        if not current then return nil end
    end
    return current
end

-- === ОСНОВНАЯ ВКЛАДКА ===
local MainTab = Window:CreateTab("Auto Farm", 4483362458)

-- Секция авто-хита босса
local BossSection = MainTab:CreateSection("Auto Hit Boss")

local BossToggle = MainTab:CreateToggle({
    Name = "Auto Hit Boss",
    CurrentValue = false,
    Flag = "AutoHitToggle",
    Callback = function(Value)
        autoHitEnabled = Value
        if Value then
            if hitConnection then hitConnection:Disconnect() end
            hitConnection = RunService.Heartbeat:Connect(function()
                safeExecute(function()
                    -- Безопасная проверка пути к боссу
                    local bossPath = {"Gameplay", "RegionsLoaded", "ChristmasEvent", "Boss", "BossHolder", "Boss"}
                    local boss = getSafeObject(bossPath)
                    local character = player.Character
                    
                    if character and boss and boss:IsA("Model") then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool and tool:FindFirstChild("RemoteClick") then
                            local args = {{boss}}
                            tool.RemoteClick:FireServer(unpack(args))
                        end
                    end
                end)
            end)
            Rayfield:Notify({
                Title = "Auto Hit Boss",
                Content = "Включен (максимальная скорость!)",
                Duration = 3,
                Image = 4483362458
            })
        else
            if hitConnection then
                hitConnection:Disconnect()
                hitConnection = nil
            end
            Rayfield:Notify({
                Title = "Auto Hit Boss",
                Content = "Выключен",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Секция авто-сбора конфет
local CandySection = MainTab:CreateSection("Auto Collect Candy")

local CandyToggle = MainTab:CreateToggle({
    Name = "Auto Collect Candy Canes",
    CurrentValue = false,
    Flag = "AutoCandyToggle",
    Callback = function(Value)
        autoCandyEnabled = Value
        if Value then
            if candyConnection then candyConnection:Disconnect() end
            candyConnection = RunService.Heartbeat:Connect(function()
                safeExecute(function()
                    -- Безопасная проверка пути к конфетам
                    local candyPath = {"Gameplay", "RegionsLoaded", "ChristmasEvent", "CurrencyPickup", "CurrencyHolder"}
                    local candyFolder = getSafeObject(candyPath)
                    
                    if candyFolder then
                        local collectedCandies = {}
                        
                        for _, candy in pairs(candyFolder:GetChildren()) do
                            if candy.Name == "CandyCane" and candy:IsA("BasePart") then
                                local args = {{candy}}
                                ReplicatedStorage:WaitForChild("Events"):WaitForChild("CollectCurrencyPickup"):FireServer(unpack(args))
                                table.insert(collectedCandies, candy)
                            end
                        end
                        
                        -- Удаляем собранные конфеты после сбора
                        for _, candy in ipairs(collectedCandies) do
                            safeExecute(function()
                                if candy and candy.Parent then
                                    candy:Destroy()
                                end
                            end)
                        end
                    end
                end)
            end)
            Rayfield:Notify({
                Title = "Auto Candy",
                Content = "Включен (авто-сбор конфет!)",
                Duration = 3,
                Image = 4483362458
            })
        else
            if candyConnection then
                candyConnection:Disconnect()
                candyConnection = nil
            end
            Rayfield:Notify({
                Title = "Auto Candy",
                Content = "Выключен",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Секция авто-открытия яиц
local EggsSection = MainTab:CreateSection("Auto Hatch Eggs")

local EggsToggle = MainTab:CreateToggle({
    Name = "Auto Hatch FJ Eggs",
    CurrentValue = false,
    Flag = "AutoEggsToggle",
    Callback = function(Value)
        autoEggsEnabled = Value
        if Value then
            if eggsConnection then eggsConnection:Disconnect() end
            eggsConnection = RunService.Heartbeat:Connect(function()
                safeExecute(function()
                    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
                    if eventsFolder then
                        local uiAction = eventsFolder:FindFirstChild("UIAction")
                        if uiAction then
                            local args = {"BuyEgg", "FJ Egg"}
                            uiAction:FireServer(unpack(args))
                        end
                    end
                end)
            end)
            Rayfield:Notify({
                Title = "Auto Eggs",
                Content = "Включен (авто-открытие FJ яиц!)",
                Duration = 3,
                Image = 4483362458
            })
        else
            if eggsConnection then
                eggsConnection:Disconnect()
                eggsConnection = nil
            end
            Rayfield:Notify({
                Title = "Auto Eggs",
                Content = "Выключен",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- === ИНИЦИАЛИЗАЦИЯ ===
Rayfield:LoadConfiguration()
print("Christmas Event Auto Farm загружен!")