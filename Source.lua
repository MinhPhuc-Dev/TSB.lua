local b64 = function(s) return game:HttpGet(('data:text/plain;base64,'..s):sub(24)) end
local a = loadstring
local g = game
local s, f = pcall(function()
    return a(b64("aHR0cHM6Ly9naXRodWIuY29tL2Rhd2lkLXNjcmlwdHMvRmx1ZW50L3JlbGVhc2VzL2xhdGVzdC9kb3dubG9hZC9tYWluLmx1YQ=="))()
end)

if not s then error("Can't load GUI") end

local p = g:GetService("Players")
local w = g:GetService("Workspace")
local r = g:GetService("RunService")
local u = g:GetService("UserInputService")
local t = g:GetService("TweenService")
local v = g:GetService("VirtualInputManager")

local l = p.LocalPlayer or p.PlayerAdded:Wait()
local c = l.Character or l.CharacterAdded:Wait()
local h = c:FindFirstChild("Humanoid") or c:WaitForChild("Humanoid")
local d = c:FindFirstChild("HumanoidRootPart") or c:WaitForChild("HumanoidRootPart")

local w1 = f:CreateWindow({ Title = "Main Window", SubTitle = "RielSick Hub", TabWidth = 160, Size = UDim2.fromOffset(400, 300), Acrylic = true, Theme = "Dark", MinimizeKey = Enum.KeyCode.LeftControl })
local t1 = w1:AddTab({ Title = "Main", Icon = "" })

local sk, lu, e = {1,1,1,1}, {0,0,0,0}, false

local us = function(i)
    local now = os.clock()
    if now - lu[i] >= sk[i] then
        lu[i] = now
        local k = Enum.KeyCode["One"]
        if i == 2 then k = Enum.KeyCode["Two"] elseif i == 3 then k = Enum.KeyCode["Three"] elseif i == 4 then k = Enum.KeyCode["Four"] end
        v:SendKeyEvent(true, k, false, nil)
        v:SendKeyEvent(false, k, false, nil)
        return true
    end
    return false
end

local m1 = function()
    v:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
    v:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
end

local tp = function(trg)
    if trg and d then
        local pos = trg.Position
        local dir = (d.Position - pos).Unit
        local behind = pos - dir * 5
        d.CFrame = CFrame.new(behind, pos)
        w.CurrentCamera.CFrame = CFrame.new(w.CurrentCamera.CFrame.Position, pos)
        h.AutoRotate = false
        d.CFrame = CFrame.new(d.Position, pos)
    end
end

local af = function()
    local trg = nil
    while e do
        if not trg or not trg.Character or not trg.Character:FindFirstChild("Humanoid") or trg.Character.Humanoid.Health <= 0 then
            local lh = math.huge
            for _, pl in ipairs(p:GetPlayers()) do
                if pl ~= l and pl.Character and pl.Character:FindFirstChild("Humanoid") then
                    local hp = pl.Character.Humanoid
                    if hp.Health < lh and hp.Health > 0 then
                        lh = hp.Health
                        trg = pl
                    end
                end
            end
        end

        if trg and trg.Character and trg.Character:FindFirstChild("HumanoidRootPart") then
            local th = trg.Character.HumanoidRootPart
            tp(th)
            local su = false
            for i=1,4 do if us(i) then su = true end end
            if not su then m1() end
        end
        task.wait(0.05)
    end
end

t1:AddToggle("Tg", {
    Title = "Enable Autofarm",
    Default = false,
    Callback = function(st)
        e = st
        if st then task.spawn(af) end
    end
})

l.CharacterAdded:Connect(function(nc)
    c = nc
    h = c:WaitForChild("Humanoid")
    d = c:WaitForChild("HumanoidRootPart")
end)

f:Notify({ Title = "Fluent", Content = "The script has been loaded.", Duration = 8 })
