-- Tải thư viện giao diện Fluent
local success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)
if not success then
    error("Failed to load Fluent. Please check your internet connection.")
end

-- Tạo cửa sổ chính
local MainWindow = Fluent:CreateWindow({
    Title = "Main Window",
    SubTitle = "RielSick Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(400, 300),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tạo tab "Main"
local MainTab = MainWindow:AddTab({ Title = "Main", Icon = "" })

-- Các biến cốt lõi
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Ensure character and its components are initialized
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 10)
if not humanoid then
    error("Humanoid is nil. Ensure the character has a Humanoid.")
end

local hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 10)
if not hrp then
    error("HumanoidRootPart is nil. Ensure the character has a HumanoidRootPart.")
end



local function find_player()
    -- Get all players in the server, avoiding the local player
    local players = Players:GetPlayers()
    local targetPlayer = nil
    local lowestHealth = math.huge

    for _, player in ipairs(players) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health < lowestHealth then
                lowestHealth = humanoid.Health
                targetPlayer = player
            end
        end
    end

    -- Get target player's position and print their health and name
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        print("Target player: " .. targetPlayer.Name)
        print("Target health: " .. tostring(lowestHealth))
        return targetHRP.Position
    else
        return nil
    end
end

local VirtualInputManager = game:GetService("VirtualInputManager")

local skillCooldowns = {1, 1, 1, 1} -- Cooldown times for skills 1, 2, 3, and 4 in seconds
local lastUsedTimes = {0, 0, 0, 0} -- Last used times for each skill
local autofarmEnabled = false -- Toggle state for autofarm

local function use_skill(skillIndex)
    local currentTime = os.clock()
    if currentTime - lastUsedTimes[skillIndex] >= skillCooldowns[skillIndex] then
        lastUsedTimes[skillIndex] = currentTime
        local keyCode = Enum.KeyCode["One"]
        if skillIndex == 2 then keyCode = Enum.KeyCode["Two"]
        elseif skillIndex == 3 then keyCode = Enum.KeyCode["Three"]
        elseif skillIndex == 4 then keyCode = Enum.KeyCode["Four"] end

        -- Simulate pressing the key for the skill
        VirtualInputManager:SendKeyEvent(true, keyCode, false, nil)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, nil)
        return true -- Skill was used
    end
    return false -- Skill was not used
end

local function smart_m1()
    -- Simulate a left mouse click
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
end

local function teleport_behind_target(targetHRP)
    if targetHRP and hrp then
        local targetPosition = targetHRP.Position
        local direction = (hrp.Position - targetPosition).Unit
        local behindPosition = targetPosition - direction * 5 -- Stay 5 studs behind the target

        -- Instantly teleport behind the target
        hrp.CFrame = CFrame.new(behindPosition, targetPosition)

        -- Make the camera face the target
        Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, targetPosition)

        -- Make the body face the target
        humanoid.AutoRotate = false
        hrp.CFrame = CFrame.new(hrp.Position, targetPosition)
    end
end

local function autofarm()
    local targetPlayer = nil -- Keep track of the current target

    while autofarmEnabled do
        -- Check if the current target is valid
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Humanoid") or targetPlayer.Character.Humanoid.Health <= 0 then
            -- Find a new target if the old target is invalid or dead
            local lowestHealth = math.huge
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                    local humanoid = player.Character.Humanoid
                    if humanoid.Health < lowestHealth and humanoid.Health > 0 then
                        lowestHealth = humanoid.Health
                        targetPlayer = player
                    end
                end
            end
        end

        -- Follow the target and perform actions
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = targetPlayer.Character.HumanoidRootPart
            teleport_behind_target(targetHRP) -- Instantly teleport behind the target player

            -- Perform actions on the target
            local skillUsed = false
            for i = 1, 4 do
                if use_skill(i) then
                    skillUsed = true
                end
            end

            if not skillUsed then
                smart_m1() -- Use M1 if no skills are available
            end
        end

        task.wait(0.05) -- Reduced delay for smoother execution
    end
end

-- Toggle for autofarm
MainTab:AddToggle("AutofarmToggle", {
    Title = "Enable Autofarm",
    Default = false,
    Callback = function(state)
        autofarmEnabled = state
        if state then
            task.spawn(autofarm) -- Start autofarm in a separate thread
        end
    end
})

-- Ensure the script resets after the local player dies
localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
end)

-- Thông báo đã tải
Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})
