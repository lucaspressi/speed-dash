-- DiagnosticClient.client.lua
-- Runs automatic diagnostics from client side
-- Shows in Output console what's working and what's not

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Wait a bit for server to initialize
task.wait(3)

print("🔍 ==================== CLIENT-SIDE DIAGNOSTICS ====================")
print("")
print("Player: " .. player.Name)
print("Testing game systems from client perspective...")
print("")

-- ==================== 1. LEADERSTATS CHECK ====================
print("📊 LEADERSTATS CHECK:")
local leaderstats = player:FindFirstChild("leaderstats")
if leaderstats then
	print("   ✅ leaderstats folder exists")

	local speed = leaderstats:FindFirstChild("Speed")
	local wins = leaderstats:FindFirstChild("Wins")

	if speed then
		print("   ✅ Speed stat: " .. speed.Value)
	else
		warn("   ❌ Speed stat MISSING")
	end

	if wins then
		print("   ✅ Wins stat: " .. wins.Value)
	else
		warn("   ❌ Wins stat MISSING")
	end
else
	warn("   ❌ NO LEADERSTATS FOLDER!")
	warn("   SpeedGameServer didn't create leaderstats on PlayerAdded")
end

print("")

-- ==================== 2. NPC CHECK ====================
print("🤖 NOOB NPC CHECK:")
local npc = workspace:FindFirstChild("Buff Noob")
if npc then
	print("   ✅ Buff Noob found in Workspace")

	local humanoid = npc:FindFirstChild("Humanoid")
	local hrp = npc:FindFirstChild("HumanoidRootPart")

	if humanoid and hrp then
		print("   ✅ Has Humanoid and HumanoidRootPart")
		print("      Health: " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
		print("      WalkSpeed: " .. humanoid.WalkSpeed)
		print("      Position: " .. tostring(hrp.Position))

		-- Check if NPC is moving (sample over 3 seconds)
		task.spawn(function()
			local startPos = hrp.Position
			task.wait(3)
			if hrp then
				local endPos = hrp.Position
				local distance = (endPos - startPos).Magnitude
				if distance > 2 then
					print("   ✅ NPC IS MOVING (moved " .. math.floor(distance) .. " studs)")
				else
					warn("   ❌ NPC NOT MOVING (only moved " .. math.floor(distance) .. " studs)")
					warn("   NoobNpcAI script may not be running")
				end
			end
		end)
	else
		warn("   ❌ NPC missing Humanoid or HumanoidRootPart")
	end
else
	warn("   ❌ Buff Noob NOT FOUND in Workspace!")
	warn("   NoobNpcAI script may have failed to initialize")
end

print("")

-- ==================== 3. LAVA CHECK ====================
print("🔥 LAVA CHECK:")
local lavaCount = 0
local lavaNames = {"Lava", "lava", "LAVA", "KillBrick"}

for _, name in ipairs(lavaNames) do
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name == name and obj:IsA("BasePart") then
			lavaCount = lavaCount + 1
		end
	end
end

if lavaCount > 0 then
	print("   ✅ Found " .. lavaCount .. " lava parts")
	print("   ⚠️  Cannot verify if they kill from client")
	print("   TEST: Walk into lava to see if it kills you")
else
	warn("   ❌ NO LAVA PARTS FOUND!")
end

print("")

-- ==================== 4. TREADMILL ZONES CHECK ====================
print("🏃 TREADMILL ZONES CHECK:")
local CollectionService = game:GetService("CollectionService")
local treadmillZones = CollectionService:GetTagged("TreadmillZone")

if #treadmillZones > 0 then
	print("   ✅ Found " .. #treadmillZones .. " TreadmillZone tagged parts")

	local freeCount = 0
	local paidCount = 0

	for _, zone in ipairs(treadmillZones) do
		local zoneName = zone.Parent and zone.Parent.Name or "Unknown"
		if zoneName:lower():find("free") then
			freeCount = freeCount + 1
			print("      FREE: " .. zone:GetFullName())
		else
			paidCount = paidCount + 1
			print("      PAID: " .. zone:GetFullName())
		end
	end

	print("   Summary: " .. freeCount .. " FREE, " .. paidCount .. " PAID")
else
	warn("   ❌ NO TreadmillZone tags found!")
	warn("   AutoSetupTreadmills may not have run")
end

print("")

-- ==================== 5. ROLLING BALLS CHECK ====================
print("⚽ ROLLING BALLS CHECK:")
local sphere1 = workspace:FindFirstChild("sphere1")
local sphere2 = workspace:FindFirstChild("sphere2")
local track1 = workspace:FindFirstChild("BallRollPart1")
local track2 = workspace:FindFirstChild("BallRollPart2")

local ballsPresent = 0
if sphere1 then
	print("   ✅ sphere1 found")
	ballsPresent = ballsPresent + 1
else
	warn("   ❌ sphere1 missing")
end

if sphere2 then
	print("   ✅ sphere2 found")
	ballsPresent = ballsPresent + 1
else
	warn("   ❌ sphere2 missing")
end

if track1 then
	print("   ✅ BallRollPart1 found")
else
	warn("   ❌ BallRollPart1 missing")
end

if track2 then
	print("   ✅ BallRollPart2 found")
else
	warn("   ❌ BallRollPart2 missing")
end

if ballsPresent == 2 then
	print("   ✅ All rolling balls present")
else
	warn("   ⚠️  " .. ballsPresent .. "/2 rolling balls present")
	warn("   RollingBallController may be disabled or objects missing")
end

print("")

-- ==================== 6. REMOTES CHECK ====================
print("📡 REMOTES CHECK:")
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if remotes then
	print("   ✅ Remotes folder exists")
	local remoteCount = #remotes:GetChildren()
	print("   Found " .. remoteCount .. " remote events/functions")

	-- Check critical remotes
	local criticalRemotes = {
		"UpdateSpeed",
		"TreadmillStateChanged",
		"RequestCurrentSpeed"
	}

	for _, remoteName in ipairs(criticalRemotes) do
		if remotes:FindFirstChild(remoteName) then
			print("      ✅ " .. remoteName)
		else
			warn("      ❌ " .. remoteName .. " missing")
		end
	end
else
	warn("   ❌ Remotes folder NOT FOUND!")
	warn("   RemotesBootstrap may not have run")
end

print("")

-- ==================== SUMMARY ====================
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("📋 DIAGNOSTIC SUMMARY:")
print("")

local issues = {}

if not leaderstats then
	table.insert(issues, "❌ Leaderstats not created")
end

if not npc then
	table.insert(issues, "❌ Buff Noob NPC missing")
end

if lavaCount == 0 then
	table.insert(issues, "❌ No lava parts found")
end

if #treadmillZones == 0 then
	table.insert(issues, "❌ No treadmill zones tagged")
end

if ballsPresent < 2 then
	table.insert(issues, "⚠️  Rolling balls incomplete (" .. ballsPresent .. "/2)")
end

if not remotes then
	table.insert(issues, "❌ Remotes folder missing")
end

if #issues == 0 then
	print("✅ ALL SYSTEMS OPERATIONAL from client perspective!")
	print("")
	print("Next steps:")
	print("   1. Walk into lava to test if it kills")
	print("   2. Walk onto treadmills to test speed boost")
	print("   3. Go near Stage 2 to test if NPC chases you")
else
	warn("⚠️  FOUND " .. #issues .. " ISSUE(S):")
	print("")
	for _, issue in ipairs(issues) do
		warn("   " .. issue)
	end
	print("")
	print("🔧 POSSIBLE SOLUTIONS:")
	print("   1. Make sure Rojo is syncing (rojo serve)")
	print("   2. In Studio: Plugins > Rojo > Connect")
	print("   3. Publish to Roblox (File > Publish)")
	print("   4. If still broken, run FORCE_ACTIVATE_SYSTEMS.lua in server console")
end

print("")
print("🔍 ==================== END DIAGNOSTICS ====================")
