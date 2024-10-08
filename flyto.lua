local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Chat = game:GetService("Chat")
local Camera = workspace.CurrentCamera
local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local CONFIG = {
    FlySpeed = 5,
    VehicleFlySpeed = 5,
    QEfly = true,
}

local FLYING = false
local flyKeyDown, flyKeyUp
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local SPEED = 0

local function setSitting(state)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Sit = state
    end
end

local function FLY(vfly)
    repeat wait() until Players.LocalPlayer and Players.LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local T = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    local function fly()
        FLYING = true
        setSitting(true)  -- Sit down when starting to fly
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.cframe = T.CFrame
        BV.velocity = Vector3.new(0, 0, 0)
        BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            repeat wait()
                if not vfly and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                    LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                end
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = 50
                elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                    SPEED = 0
                end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.velocity = ((workspace.CurrentCamera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).Position) - workspace.CurrentCamera.CFrame.Position)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BV.velocity = ((workspace.CurrentCamera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).Position) - workspace.CurrentCamera.CFrame.Position)) * SPEED
                else
                    BV.velocity = Vector3.new(0, 0, 0)
                end
                BG.cframe = workspace.CurrentCamera.CFrame
            until not FLYING
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()
            setSitting(false)  -- Stand up when stopping flying
            if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end

    flyKeyDown = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name:lower()
            if key == 'w' then
                CONTROL.F = (vfly and CONFIG.VehicleFlySpeed or CONFIG.FlySpeed)
            elseif key == 's' then
                CONTROL.B = -(vfly and CONFIG.VehicleFlySpeed or CONFIG.FlySpeed)
            elseif key == 'a' then
                CONTROL.L = -(vfly and CONFIG.VehicleFlySpeed or CONFIG.FlySpeed)
            elseif key == 'd' then
                CONTROL.R = (vfly and CONFIG.VehicleFlySpeed or CONFIG.FlySpeed)
            elseif CONFIG.QEfly and key == 'e' then
                CONTROL.Q = (vfly and CONFIG.VehicleFlySpeed or CONFIG.FlySpeed) * 2
            elseif CONFIG.QEfly and key == 'q' then
                CONTROL.E = -(vfly and CONFIG.VehicleFlySpeed or CONFIG.FlySpeed) * 2
            end
            pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
        end
    end)

    flyKeyUp = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name:lower()
            if key == 'w' then
                CONTROL.F = 0
            elseif key == 's' then
                CONTROL.B = 0
            elseif key == 'a' then
                CONTROL.L = 0
            elseif key == 'd' then
                CONTROL.R = 0
            elseif key == 'e' then
                CONTROL.Q = 0
            elseif key == 'q' then
                CONTROL.E = 0
            end
        end
    end)

    fly()
end

local function NOFLY()
    FLYING = false
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
    if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
    setSitting(false)  -- Stand up when stopping flying
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local function teleportToPlayer(namePart)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local lowerUsername = player.Name:lower()
            local lowerDisplayName = player.DisplayName:lower()
            if lowerUsername:find(namePart) or lowerDisplayName:find(namePart) then
                local targetCharacter = player.Character
                if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character:MoveTo(targetCharacter.HumanoidRootPart.Position)
                    return
                end
            end
        end
    end
end

LocalPlayer.Chatted:Connect(function(message)
    if message:lower():sub(1, 4) == ".to " then
        local namePart = message:sub(5):lower()
        teleportToPlayer(namePart)
    end
end)

-- Keybind for toggling fly
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Z then
        if FLYING then
            NOFLY()
        else
            FLY()
        end
        print(FLYING and "Fly enabled." or "Fly disabled.")
    end
end)
