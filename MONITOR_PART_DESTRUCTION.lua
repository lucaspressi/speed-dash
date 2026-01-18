-- MONITOR_PART_DESTRUCTION.lua
-- COMMAND BAR SCRIPT - Run on SERVER with game RUNNING
-- Monitors if Stage 3 floor parts are being destroyed or moved

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔍 ==================== MONITORING PART DESTRUCTION/MOVEMENT ====================")
print("")

-- Find all Procedual Futuristic Flooring models
local flooringModels = {}
for _, obj in pairs(workspace:GetChildren()) do
	if obj.Name == "Procedual Futuristic Flooring" and obj:IsA("Model") then
		table.insert(flooringModels, obj)
	end
end

-- Find all Stage3Part objects
local stage3Parts = {}
for _, obj in pairs(workspace:GetChildren()) do
	if string.match(obj.Name, "Stage3") and obj:IsA("BasePart") then
		table.insert(stage3Parts, obj)
	end
end

print("📋 Monitoring:")
print("   " .. #flooringModels .. " Procedual Futuristic Flooring models")
print("   " .. #stage3Parts .. " Stage3Part objects")
print("")

local partPositions = {}
local connections = {}
local partsDestroyed = 0
local partsMoved = 0

-- Monitor flooring model destruction
for _, model in ipairs(flooringModels) do
	local conn = model.AncestryChanged:Connect(function(child, parent)
		if not parent then
			partsDestroyed = partsDestroyed + 1
			warn("❌ MODEL DESTROYED: " .. model.Name .. " at " .. tostring(model.Position))
		end
	end)
	table.insert(connections, conn)

	-- Monitor each part in the model
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			-- Save initial position
			partPositions[part] = part.Position

			-- Monitor destruction
			local destroyConn = part.AncestryChanged:Connect(function(child, parent)
				if not parent then
					partsDestroyed = partsDestroyed + 1
					warn("❌ PART DESTROYED: " .. part:GetFullName())
				end
			end)
			table.insert(connections, destroyConn)

			-- Monitor position changes
			local posConn = part:GetPropertyChangedSignal("Position"):Connect(function()
				local oldPos = partPositions[part]
				local newPos = part.Position
				if oldPos and (oldPos - newPos).Magnitude > 0.1 then
					partsMoved = partsMoved + 1
					warn("⚠️ PART MOVED: " .. part:GetFullName())
					warn("   Old Position: " .. tostring(oldPos))
					warn("   New Position: " .. tostring(newPos))
					warn("   Distance: " .. string.format("%.2f", (oldPos - newPos).Magnitude))
					partPositions[part] = newPos
				end
			end)
			table.insert(connections, posConn)
		end
	end
end

-- Monitor Stage3Part destruction and movement
for _, part in ipairs(stage3Parts) do
	-- Save initial position
	partPositions[part] = part.Position

	-- Monitor destruction
	local destroyConn = part.AncestryChanged:Connect(function(child, parent)
		if not parent then
			partsDestroyed = partsDestroyed + 1
			warn("❌ STAGE3 PART DESTROYED: " .. part.Name)
		end
	end)
	table.insert(connections, destroyConn)

	-- Monitor position changes
	local posConn = part:GetPropertyChangedSignal("Position"):Connect(function()
		local oldPos = partPositions[part]
		local newPos = part.Position
		if oldPos and (oldPos - newPos).Magnitude > 0.1 then
			partsMoved = partsMoved + 1
			warn("⚠️ STAGE3 PART MOVED: " .. part.Name)
			warn("   Old Position: " .. tostring(oldPos))
			warn("   New Position: " .. tostring(newPos))
			warn("   Distance: " .. string.format("%.2f", (oldPos - newPos).Magnitude))
			partPositions[part] = newPos
		end
	end)
	table.insert(connections, posConn)
end

print("⏱️ Monitoring for 30 seconds...")
print("   Walk around Stage 3 to see if parts are destroyed or moved")
print("")

task.wait(30)

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("📊 RESULTS:")
print("   Parts destroyed: " .. partsDestroyed)
print("   Parts moved: " .. partsMoved)
print("")

if partsDestroyed == 0 and partsMoved == 0 then
	print("✅ No parts were destroyed or moved!")
	print("")
	print("💡 If the floor looks like it's falling, it might be:")
	print("   1. A visual glitch (camera angle, transparency)")
	print("   2. The floor was already in a falling state before we fixed it")
	print("   3. You need to RESTART THE GAME (close and reopen)")
else
	if partsDestroyed > 0 then
		warn("❌ " .. partsDestroyed .. " parts were DESTROYED!")
		warn("   Check the warnings above to see what script is destroying them")
	end
	if partsMoved > 0 then
		warn("❌ " .. partsMoved .. " parts were MOVED!")
		warn("   Check the warnings above to see what script is moving them")
	end
end

-- Cleanup
for _, conn in ipairs(connections) do
	conn:Disconnect()
end

print("")
print("🔍 ==================== END MONITORING ====================")
-- ==================== COPY UNTIL HERE ====================
