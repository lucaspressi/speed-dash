--[[
    Remove Photos Folder

    This script automatically removes any "Photos" folder created in Workspace
    that might interfere with the leaderboard display
]]

local workspace = game:GetService("Workspace")

-- Remove Photos folder if it exists
local function removePhotosFolder()
    local photosFolder = workspace:FindFirstChild("Photos")
    if photosFolder then
        photosFolder:Destroy()
        print("[RemovePhotosFolder] Removed 'Photos' folder from Workspace")
    end
end

-- Initial cleanup
removePhotosFolder()

-- Monitor and remove if created again
workspace.ChildAdded:Connect(function(child)
    if child.Name == "Photos" then
        warn("[RemovePhotosFolder] 'Photos' folder detected, removing...")
        task.wait(0.1)
        if child.Parent then
            child:Destroy()
            print("[RemovePhotosFolder] 'Photos' folder removed automatically")
        end
    end
end)

print("[RemovePhotosFolder] Monitoring for 'Photos' folder...")
