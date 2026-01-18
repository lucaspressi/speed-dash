local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Collect all axes
local axes = {}
for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name == "Axe" and obj:IsA("Model") then
        table.insert(axes, obj)
    end
end

print("[AxeController] Managing " .. #axes .. " axes")

-- Setup each axe
local axeData = {}
for i, axe in ipairs(axes) do
    -- Find pivot part and handle
    local pivotPart = nil
    local handlePart = nil
    
    for _, part in pairs(axe:GetChildren()) do
        if part:IsA("BasePart") then
            if part.Name == "Handle" then
                handlePart = part
            elseif part.Name == "Part" and not pivotPart then
                pivotPart = part
            end
        end
    end
    
    if pivotPart then
        -- Anchor pivot
        pivotPart.Anchored = true
        
        -- Weld handle to pivot if not already
        if handlePart then
            handlePart.Anchored = false
            local weld = handlePart:FindFirstChild("AxeWeld")
            if not weld then
                weld = Instance.new("WeldConstraint")
                weld.Name = "AxeWeld"
                weld.Part0 = pivotPart
                weld.Part1 = handlePart
                weld.Parent = handlePart
            end
        end
        
        -- Alternate direction: odd axes go one way, even go the other
        local direction = (i % 2 == 0) and 1 or -1
        
        axeData[i] = {
            pivot = pivotPart,
            handle = handlePart,
            baseCFrame = pivotPart.CFrame,
            direction = direction,
            angle = (direction == 1) and 0 or math.pi -- Start opposite
        }

        -- Setup kill touch on handle
        if handlePart then
            handlePart.Touched:Connect(function(hit)
                local character = hit.Parent
                local player = Players:GetPlayerFromCharacter(character)

                if player then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        print("[AxeController] Axe #" .. i .. " killed " .. player.Name)
                        humanoid.Health = 0
                    end
                end
            end)
            print("[AxeController] Axe #" .. i .. " kill touch enabled on Handle")
        end

        print("[AxeController] Axe #" .. i .. " direction: " .. direction)
    end
end

-- Swing parameters
local SWING_SPEED = 2 -- radians per second
local SWING_ANGLE = math.rad(180) -- 180 degrees total swing (90 each way)

-- Animation loop
local time = 0
RunService.Heartbeat:Connect(function(dt)
    time = time + dt
    
    for i, data in pairs(axeData) do
        if data.pivot then
            -- Calculate swing angle using sine wave for smooth back-and-forth
            local swing = math.sin(time * SWING_SPEED + (data.direction == 1 and 0 or math.pi)) * (SWING_ANGLE / 2)
            
            -- Apply rotation
            data.pivot.CFrame = data.baseCFrame * CFrame.Angles(0, swing, 0)
        end
    end
end)

print("[AxeController] Started - 180 degree swing, alternating directions, kill touch enabled")
