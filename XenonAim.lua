local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local AimbotEnabled = false -- Trạng thái Aimbot

-- Kiểm tra game có hệ thống Team hay không
local HasTeams = false
if LocalPlayer.Neutral == false then
    HasTeams = true
end

-- Hàm kiểm tra có phải đồng đội không
local function IsTeammate(Player)
    if HasTeams and Player.Team == LocalPlayer.Team then
        return true
    end
    return false
end

-- Xóa Nametag nếu có
local function RemoveESP(Character)
    if not Character then return end
    if Character:FindFirstChild("ESP_NameTag") then
        Character:FindFirstChild("ESP_NameTag"):Destroy()
    end
end

-- Tạo ESP Nametag trên đầu kẻ địch
local function CreateESP(Player)
    if Player == LocalPlayer or IsTeammate(Player) then return end -- Không hiển thị với đồng đội
    local Character = Player.Character or Player.CharacterAdded:Wait()
    if not Character then return end

    RemoveESP(Character)

    local Head = Character:FindFirstChild("Head")
    if not Head then return end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ESP_NameTag"
    Billboard.Adornee = Head
    Billboard.Size = UDim2.new(0, 100, 0, 25)
    Billboard.StudsOffset = Vector3.new(0, 2, 0) -- Hiển thị trên đầu
    Billboard.AlwaysOnTop = true

    local NameTag = Instance.new("TextLabel")
    NameTag.Size = UDim2.new(1, 0, 1, 0)
    NameTag.BackgroundTransparency = 1
    NameTag.TextColor3 = Color3.fromRGB(255, 50, 50) -- Màu đỏ (kẻ địch)
    NameTag.TextStrokeTransparency = 0.5
    NameTag.Text = Player.Name
    NameTag.Font = Enum.Font.SourceSansBold
    NameTag.TextSize = 14
    NameTag.Parent = Billboard

    Billboard.Parent = Character
end

-- Tìm kẻ địch gần nhất
local function GetClosestEnemy()
    local ClosestEnemy = nil
    local ShortestDistance = math.huge

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and not IsTeammate(Player) and Player.Character then
            local Head = Player.Character:FindFirstChild("Head") or Player.Character:FindFirstChildOfClass("BasePart")
            if Head then
                local Distance = (Head.Position - Camera.CFrame.Position).Magnitude
                if Distance < ShortestDistance then
                    ShortestDistance = Distance
                    ClosestEnemy = Head
                end
            end
        end
    end
    return ClosestEnemy
end

-- Aimbot khi giữ chuột phải
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local Target = GetClosestEnemy()
        if Target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
        end
    end
end)

-- Bật Aimbot khi giữ chuột phải
UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = true
    end
end)

-- Tắt Aimbot khi thả chuột phải
UserInputService.InputEnded:Connect(function(Input, Processed)
    if Processed then return end
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = false
    end
end)

-- Cập nhật ESP liên tục
task.spawn(function()
    while true do
        for _, Player in pairs(Players:GetPlayers()) do
            task.spawn(function() CreateESP(Player) end)
        end
        task.wait(1) -- Cập nhật mỗi giây
    end
end)

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function()
        task.wait(1)
        CreateESP(Player)
    end)
end)

Players.PlayerRemoving:Connect(function(Player)
    if Player.Character then
        RemoveESP(Player.Character)
    end
end)
