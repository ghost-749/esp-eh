local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
local Window = Library:CreateWindow({
    Name = "ESP Module - Nebula Premium",
    LoadingTitle = "ESP Module",
    LoadingSubtitle = "by Sandra",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local ESP_Tab = Window:CreateTab("ESP", 4483362458)
local ESPSection = ESP_Tab:CreateSection("ESP Settings")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local cam = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local espEnabled = false
local espBoxEnabled = false
local espNameEnabled = false
local espTracerEnabled = false
local espHealthEnabled = false

ESP_Tab:CreateToggle({
    Name = "Enable ESP (Basic)",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
    end
})

ESP_Tab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Callback = function(state)
        espBoxEnabled = state
    end
})

ESP_Tab:CreateToggle({
    Name = "Name/Distance ESP",
    CurrentValue = false,
    Callback = function(state)
        espNameEnabled = state
    end
})

ESP_Tab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = false,
    Callback = function(state)
        espTracerEnabled = state
    end
})

ESP_Tab:CreateToggle({
    Name = "Health ESP",
    CurrentValue = false,
    Callback = function(state)
        espHealthEnabled = state
    end
})

local espObjects = {}
local function CreateESP(player)
    if espObjects[player] then return end
    local esp = {}
    esp.Box = Drawing.new("Square")
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255,0,255)
    esp.Box.Visible = false

    esp.Name = Drawing.new("Text")
    esp.Name.Size = 13
    esp.Name.Color = Color3.new(1,1,1)
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false

    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Color = Color3.fromRGB(255,0,255)
    esp.Tracer.Thickness = 1
    esp.Tracer.Visible = false

    esp.HealthBar = Drawing.new("Square")
    esp.HealthBar.Color = Color3.new(0,1,0)
    esp.HealthBar.Filled = true
    esp.HealthBar.Visible = false

    espObjects[player] = esp
end

local function RemoveESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            obj:Remove()
        end
        espObjects[player] = nil
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            CreateESP(player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        CreateESP(player)
    end
end

RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _, esp in pairs(espObjects) do
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
        end
        return
    end

    for player, esp in pairs(espObjects) do
        local char = player.Character
        if char then
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            if head and root and humanoid and humanoid.Health > 0 then
                local headPos, onScreen1 = cam:WorldToViewportPoint(head.Position)
                local rootPos, onScreen2 = cam:WorldToViewportPoint(root.Position)
                if onScreen1 and onScreen2 then
                    local boxHeight = math.abs(rootPos.Y - headPos.Y)
                    local boxWidth = boxHeight * 0.65
                    local boxX = rootPos.X - boxWidth/2
                    local boxY = headPos.Y

                    if espBoxEnabled then
                        esp.Box.Visible = true
                        esp.Box.Position = Vector2.new(boxX, boxY)
                        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    else
                        esp.Box.Visible = false
                    end

                    if espNameEnabled then
                        esp.Name.Visible = true
                        local distance = (cam.CFrame.Position - root.Position).Magnitude
                        esp.Name.Text = string.format("%s [%.0f]", player.Name, distance)
                        esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 15)
                    else
                        esp.Name.Visible = false
                    end

                    if espTracerEnabled then
                        esp.Tracer.Visible = true
                        esp.Tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    else
                        esp.Tracer.Visible = false
                    end

                    if espHealthEnabled then
                        esp.HealthBar.Visible = true
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        esp.HealthBar.Position = Vector2.new(boxX - 6, boxY + (boxHeight * (1 - healthPercent)))
                        esp.HealthBar.Size = Vector2.new(4, boxHeight * healthPercent)
                    else
                        esp.HealthBar.Visible = false
                    end
                else
                    for _, obj in pairs(esp) do
                        obj.Visible = false
                    end
                end
            else
                for _, obj in pairs(esp) do
                    obj.Visible = false
                end
            end
        end
    end
end)
