local workspace = game:GetService("Workspace")

local treadmills = {
	{
		name = "TreadmillFree",
		productId = 0,
		multiplier = 1
	},
	{
		name = "TreadmillPaid",      -- 3x Speed Treadmill (dourada) - 59 Robux
		productId = 3510639799,
		multiplier = 3
	},
	{
		name = "TreadmillBlue",      -- 9x Speed Treadmill (azul) - 149 Robux
		productId = 3510662188,
		multiplier = 9
	},
	{
		name = "TreadmillPurple",    -- 25x Speed Treadmill (roxa) - 399 Robux
		productId = 3510662405,
		multiplier = 25
	}
}

for _, config in ipairs(treadmills) do
	local zone = workspace:FindFirstChild(config.name, true)

	if not zone then
		local parent = workspace:FindFirstChild(config.name)
		if parent then
			zone = parent:FindFirstChild("TreadmillZone")
		end
	end

	if zone then
		print("Configurando " .. zone:GetFullName())

		for _, child in ipairs(zone:GetChildren()) do
			if child.Name == "ProductId" or child.Name == "Multiplier" or child.Name == "Value" then
				child:Destroy()
			end
		end

		task.wait(0.1)

		local productIdValue = Instance.new("IntValue")
		productIdValue.Name = "ProductId"
		productIdValue.Value = config.productId
		productIdValue.Parent = zone

		local multiplierValue = Instance.new("IntValue")
		multiplierValue.Name = "Multiplier"
		multiplierValue.Value = config.multiplier
		multiplierValue.Parent = zone

		print("  ProductId: " .. config.productId)
		print("  Multiplier: " .. config.multiplier)
	else
		warn("Esteira nao encontrada: " .. config.name)
	end
end

print("Setup completo")