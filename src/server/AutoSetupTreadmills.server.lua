-- AutoSetupTreadmills.server.lua
-- Configura Attributes nas TreadmillZones de teste automaticamente
-- Roda ANTES do TreadmillService escanear

local workspace = game:GetService("Workspace")

print("[AutoSetup] ==================== AUTO-CONFIGURING TEST TREADMILLS ====================")

-- Define os multipliers e ProductIds para cada treadmill
local treadmillConfig = {
	TreadmillFree = {Multiplier = 1, IsFree = true, ProductId = 0},
	Esteira1x = {Multiplier = 1, IsFree = true, ProductId = 0},
	Esteira1X = {Multiplier = 1, IsFree = true, ProductId = 0},

	TreadmillX3 = {Multiplier = 3, IsFree = false, ProductId = 3510662188},
	Esteira3x = {Multiplier = 3, IsFree = false, ProductId = 3510662188},
	Esteira3X = {Multiplier = 3, IsFree = false, ProductId = 3510662188},

	TreadmillBlue = {Multiplier = 9, IsFree = false, ProductId = 3510662188},
	Esteira9x = {Multiplier = 9, IsFree = false, ProductId = 3510662188},
	Esteira9X = {Multiplier = 9, IsFree = false, ProductId = 3510662188},

	TreadmillPurple = {Multiplier = 25, IsFree = false, ProductId = 3510662405},
	Esteira25x = {Multiplier = 25, IsFree = false, ProductId = 3510662405},
	Esteira25X = {Multiplier = 25, IsFree = false, ProductId = 3510662405},
}

local configured = 0

for modelName, config in pairs(treadmillConfig) do
	local model = workspace:FindFirstChild(modelName)

	if model then
		local zone = model:FindFirstChild("TreadmillZone")

		if zone and zone:IsA("BasePart") then
			-- Configura os Attributes
			zone:SetAttribute("Multiplier", config.Multiplier)
			zone:SetAttribute("IsFree", config.IsFree)
			zone:SetAttribute("ProductId", config.ProductId)

			print(string.format("[AutoSetup] ✅ Configured: %s (x%d, %s, ProductId=%d)",
				modelName, config.Multiplier,
				config.IsFree and "FREE" or "PAID",
				config.ProductId))

			configured = configured + 1
		else
			warn(string.format("[AutoSetup] ⚠️ TreadmillZone not found in %s", modelName))
		end
	else
		warn(string.format("[AutoSetup] ⚠️ Model '%s' not found in Workspace", modelName))
	end
end

print(string.format("[AutoSetup] ✅ Auto-setup complete: %d treadmills configured", configured))
print("[AutoSetup] ========================================================================")

-- Pequena pausa para garantir que TreadmillService pegue as mudanças
task.wait(0.1)
