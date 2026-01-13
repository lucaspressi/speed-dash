local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local sphere1 = workspace:WaitForChild("sphere1")
local sphere2 = workspace:WaitForChild("sphere2")
local ballRollPart1 = workspace:WaitForChild("BallRollPart1")
local ballRollPart2 = workspace:WaitForChild("BallRollPart2")

local halfLength1 = ballRollPart1.Size.Z / 2
local halfLength2 = ballRollPart2.Size.Z / 2

local sphereRadius1 = sphere1.Size.X / 2
local sphereRadius2 = sphere2.Size.X / 2

local track1Start = Vector3.new(
    ballRollPart1.Position.X + halfLength1 + sphereRadius1,
    ballRollPart1.Position.Y + ballRollPart1.Size.Y/2 + sphereRadius1,
    ballRollPart1.Position.Z
)
local track1End = Vector3.new(
    ballRollPart1.Position.X - halfLength1 - sphereRadius1,
    ballRollPart1.Position.Y + ballRollPart1.Size.Y/2 + sphereRadius1,
    ballRollPart1.Position.Z
)

local track2Start = Vector3.new(
    ballRollPart2.Position.X - halfLength2 - sphereRadius2,
    ballRollPart2.Position.Y + ballRollPart2.Size.Y/2 + sphereRadius2,
    ballRollPart2.Position.Z
)
local track2End = Vector3.new(
    ballRollPart2.Position.X + halfLength2 + sphereRadius2,
    ballRollPart2.Position.Y + ballRollPart2.Size.Y/2 + sphereRadius2,
    ballRollPart2.Position.Z
)

-- EVEN FASTER
local ROLL_SPEED = 175
local ROTATION_SPEED = 10

sphere1.Anchored = true
sphere2.Anchored = true
sphere1.CanCollide = true
sphere2.CanCollide = true

local ball1 = {
    part = sphere1,
    startPos = track1Start,
    endPos = track1End,
    currentPos = track1Start,
    direction = (track1End - track1Start).Unit
}

local ball2 = {
    part = sphere2,
    startPos = track2Start,
    endPos = track2End,
    currentPos = track2Start,
    direction = (track2End - track2Start).Unit
}

sphere1.Position = track1Start
sphere2.Position = track2Start

local function setupKillTouch(sphere)
    sphere.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
        
        if player then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
            end
        end
    end)
end

setupKillTouch(sphere1)
setupKillTouch(sphere2)

local function hasReachedEnd(ball)
    local totalDist = (ball.endPos - ball.startPos).Magnitude
    local traveled = (ball.currentPos - ball.startPos).Magnitude
    return traveled >= totalDist
end

local function resetBall(ball)
    ball.currentPos = ball.startPos
    ball.part.Position = ball.startPos
end

local angle1 = 0
local angle2 = 0

RunService.Heartbeat:Connect(function(dt)
    ball1.currentPos = ball1.currentPos + ball1.direction * ROLL_SPEED * dt
    angle1 = angle1 + ROTATION_SPEED * dt
    ball1.part.CFrame = CFrame.new(ball1.currentPos) * CFrame.Angles(0, 0, angle1)
    
    if hasReachedEnd(ball1) then
        resetBall(ball1)
    end
    
    ball2.currentPos = ball2.currentPos + ball2.direction * ROLL_SPEED * dt
    angle2 = angle2 + ROTATION_SPEED * dt
    ball2.part.CFrame = CFrame.new(ball2.currentPos) * CFrame.Angles(0, 0, angle2)
    
    if hasReachedEnd(ball2) then
        resetBall(ball2)
    end
end)

print("Rolling balls - SPEED 175!")
