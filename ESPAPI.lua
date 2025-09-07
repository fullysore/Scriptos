local ESP = {}

ESP.Settings = {
    BoxColor = Color3.fromRGB(255, 0, 0),
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    DistanceColor = Color3.fromRGB(255, 255, 255),
    TeamCheck = false,
    Enabled = true,
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local tracked = {}

-- Internal: create a drawing object easily
local function newDrawing(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- Internal: remove drawings for a player
local function removeDrawings(plr)
    if tracked[plr] then
        for _, d in pairs(tracked[plr]) do
            d:Remove()
        end
        tracked[plr] = nil
    end
end

-- Public: add a player to ESP
function ESP:AddPlayer(plr)
    if plr == LocalPlayer or tracked[plr] then return end
    local box = newDrawing("Square", {Thickness = 1, Color = ESP.Settings.BoxColor, Filled = false, Visible = false})
    local healthbar = newDrawing("Line", {Thickness = 2, Color = ESP.Settings.HealthBarColor, Visible = false})
    local distText = newDrawing("Text", {Size = 14, Color = ESP.Settings.DistanceColor, Center = true, Visible = false})
    tracked[plr] = {box, healthbar, distText}
end

-- Public: remove a player from ESP
function ESP:RemovePlayer(plr)
    removeDrawings(plr)
end

-- Auto-track players
Players.PlayerRemoving:Connect(removeDrawings)
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        ESP:AddPlayer(plr)
    end
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        ESP:AddPlayer(plr)
    end
end

-- Update loop
RunService.RenderStepped:Connect(function()
    if not ESP.Settings.Enabled then
        for _, items in pairs(tracked) do
            for _, d in pairs(items) do
                d.Visible = false
            end
        end
        return
    end

    for plr, items in pairs(tracked) do
        local char = plr.Character
        local box, healthbar, distText = unpack(items)
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            if ESP.Settings.TeamCheck and plr.Team == LocalPlayer.Team then
                box.Visible, healthbar.Visible, distText.Visible = false, false, false
            else
                local hrp = char.HumanoidRootPart
                local humanoid = char.Humanoid
                local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
                if onscreen then
                    local scale = 1 / (pos.Z * 0.003)  -- scale box by distance
                    local boxSize = Vector2.new(40 * scale, 60 * scale)
                    box.Size = boxSize
                    box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                    box.Color = ESP.Settings.BoxColor
                    box.Visible = true

                    -- Health bar (left side)
                    local healthFrac = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                    local barHeight = boxSize.Y * healthFrac
                    healthbar.From = Vector2.new(box.Position.X - 5, box.Position.Y + boxSize.Y)
                    healthbar.To = Vector2.new(box.Position.X - 5, box.Position.Y + boxSize.Y - barHeight)
                    healthbar.Color = ESP.Settings.HealthBarColor
                    healthbar.Visible = true

                    -- Distance text
                    local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
                    distText.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 14)
                    distText.Text = string.format("[%dm]", math.floor(dist))
                    distText.Color = ESP.Settings.DistanceColor
                    distText.Visible = true
                else
                    box.Visible, healthbar.Visible, distText.Visible = false, false, false
                end
            end
        else
            box.Visible, healthbar.Visible, distText.Visible = false, false, false
        end
    end
end)

return ESP
