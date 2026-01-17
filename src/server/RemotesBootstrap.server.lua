-- RemotesBootstrap.server.lua
-- Garante que todos os RemoteEvents/Functions necessários existem
-- Roda no boot ANTES de qualquer outro script que precise deles
-- Idempotente: pode rodar múltiplas vezes sem duplicar

local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[RemotesBootstrap] ==================== STARTING ====================")

-- ==================== CREATE FOLDERS ====================
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage
	print("[RemotesBootstrap] Created Remotes folder")
else
	print("[RemotesBootstrap] Remotes folder already exists")
end

local Shared = ReplicatedStorage:FindFirstChild("Shared")
if not Shared then
	Shared = Instance.new("Folder")
	Shared.Name = "Shared"
	Shared.Parent = ReplicatedStorage
	print("[RemotesBootstrap] Created Shared folder")
else
	print("[RemotesBootstrap] Shared folder already exists")
end

-- ==================== REMOTE DEFINITIONS ====================
-- Lista completa de todos RemoteEvents/Functions esperados pelo client

local remoteEvents = {
	-- Core gameplay
	"UpdateSpeed",
	"UpdateUI",
	"AddWin",
	"EquipStepAward",

	-- Treadmill
	"TreadmillOwnershipUpdated",

	-- Rebirth
	"Rebirth",
	"RebirthSuccess",

	-- Prompts/Purchases
	"PromptSpeedBoost",
	"PromptWinsBoost",
	"Prompt100KSpeed",
	"Prompt1MSpeed",
	"Prompt10MSpeed",

	-- Gift
	"ClaimGift",

	-- Visual feedback
	"ShowWin",
}

local remoteFunctions = {
	-- Group verification (returns boolean)
	"VerifyGroup",
}

-- ==================== CREATE REMOTE EVENTS ====================
print("[RemotesBootstrap] Creating RemoteEvents...")

local created = 0
local existing = 0

for _, remoteName in ipairs(remoteEvents) do
	local remote = Remotes:FindFirstChild(remoteName)

	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = remoteName
		remote.Parent = Remotes
		print("[RemotesBootstrap]   ✅ Created: " .. remoteName)
		created = created + 1
	elseif not remote:IsA("RemoteEvent") then
		warn("[RemotesBootstrap]   ⚠️ EXISTS but WRONG TYPE: " .. remoteName .. " (is " .. remote.ClassName .. ")")
		remote:Destroy()
		remote = Instance.new("RemoteEvent")
		remote.Name = remoteName
		remote.Parent = Remotes
		print("[RemotesBootstrap]   ✅ Recreated: " .. remoteName)
		created = created + 1
	else
		-- print("[RemotesBootstrap]   ✓ Exists: " .. remoteName)
		existing = existing + 1
	end
end

-- ==================== CREATE REMOTE FUNCTIONS ====================
if #remoteFunctions > 0 then
	print("[RemotesBootstrap] Creating RemoteFunctions...")

	for _, remoteName in ipairs(remoteFunctions) do
		local remote = Remotes:FindFirstChild(remoteName)

		if not remote then
			remote = Instance.new("RemoteFunction")
			remote.Name = remoteName
			remote.Parent = Remotes
			print("[RemotesBootstrap]   ✅ Created: " .. remoteName)
			created = created + 1
		elseif not remote:IsA("RemoteFunction") then
			warn("[RemotesBootstrap]   ⚠️ EXISTS but WRONG TYPE: " .. remoteName .. " (is " .. remote.ClassName .. ")")
			remote:Destroy()
			remote = Instance.new("RemoteFunction")
			remote.Name = remoteName
			remote.Parent = Remotes
			print("[RemotesBootstrap]   ✅ Recreated: " .. remoteName)
			created = created + 1
		else
			-- print("[RemotesBootstrap]   ✓ Exists: " .. remoteName)
			existing = existing + 1
		end
	end
end

-- ==================== SUMMARY ====================
print("[RemotesBootstrap] ==================== COMPLETE ====================")
print("[RemotesBootstrap] Created: " .. created .. " remotes")
print("[RemotesBootstrap] Existing: " .. existing .. " remotes")
print("[RemotesBootstrap] Total: " .. (created + existing) .. " remotes")
print("[RemotesBootstrap] ✅ All remotes ready for use")
print("[RemotesBootstrap] =======================================================")

-- ==================== VERIFICATION ====================
-- Pequena pausa para garantir que scripts dependentes possam usar imediatamente
task.wait(0.1)

return true
