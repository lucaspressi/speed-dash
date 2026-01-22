-- AdminChatCommands.server.lua
-- Sistema simples de comandos de chat para admins

local Players = game:GetService("Players")

-- Lista de admins (deve estar sincronizada com SpeedGameServer)
local ADMIN_USER_IDS = {
	[10286998085] = true,
	[10291926911] = true,
	[10345555230] = true,
}

-- Aguardar AdminAPI estar disponível
local function waitForAdminAPI()
	local maxWait = 30
	local waited = 0
	while not _G.AdminAPI and waited < maxWait do
		task.wait(0.5)
		waited = waited + 0.5
	end
	return _G.AdminAPI
end

local AdminAPI = waitForAdminAPI()

if not AdminAPI then
	warn("[AdminChatCommands] AdminAPI não disponível, comandos de chat desabilitados")
	return
end

-- Comandos disponíveis
local commands = {
	["/giveall"] = function(player)
		-- Libera todas as esteiras e boosts
		player:SetAttribute("TreadmillX3Owned", true)
		player:SetAttribute("TreadmillX9Owned", true)
		player:SetAttribute("TreadmillX25Owned", true)
		player:SetAttribute("SpeedBoostLevel", 4)
		player:SetAttribute("SpeedBoostActive", true)
		player:SetAttribute("CurrentSpeedBoostMultiplier", 16)
		player:SetAttribute("WinBoostLevel", 4)
		player:SetAttribute("WinBoostActive", true)
		player:SetAttribute("CurrentWinBoostMultiplier", 16)

		-- Salvar no DataStore
		local data = AdminAPI.getPlayerData(player.UserId)
		if data then
			data.TreadmillX3Owned = true
			data.TreadmillX9Owned = true
			data.TreadmillX25Owned = true
			data.SpeedBoostLevel = 4
			data.SpeedBoostActive = true
			data.CurrentSpeedBoostMultiplier = 16
			data.WinBoostLevel = 4
			data.WinBoostActive = true
			data.CurrentWinBoostMultiplier = 16

			AdminAPI.saveAll(player, data, "admin_giveall")
		end

		return "✅ TUDO LIBERADO! (Esteiras 3x/9x/25x + Speed Boost 16x + Win Boost 16x)"
	end,

	["/givetreadmill"] = function(player, args)
		local multiplier = tonumber(args[1])
		if not multiplier or (multiplier ~= 3 and multiplier ~= 9 and multiplier ~= 25) then
			return "❌ Use: /givetreadmill <3|9|25>"
		end

		local key = "TreadmillX" .. multiplier .. "Owned"
		player:SetAttribute(key, true)

		local data = AdminAPI.getPlayerData(player.UserId)
		if data then
			data[key] = true
			AdminAPI.saveAll(player, data, "admin_treadmill")
		end

		return "✅ Esteira " .. multiplier .. "x liberada!"
	end,

	["/givespeed"] = function(player, args)
		local level = tonumber(args[1])
		if not level or level < 0 or level > 4 then
			return "❌ Use: /givespeed <0-4> (0=1x, 1=2x, 2=4x, 3=8x, 4=16x)"
		end

		local multiplier = level > 0 and math.pow(2, level) or 1

		player:SetAttribute("SpeedBoostLevel", level)
		player:SetAttribute("SpeedBoostActive", level > 0)
		player:SetAttribute("CurrentSpeedBoostMultiplier", multiplier)

		local data = AdminAPI.getPlayerData(player.UserId)
		if data then
			data.SpeedBoostLevel = level
			data.SpeedBoostActive = level > 0
			data.CurrentSpeedBoostMultiplier = multiplier
			AdminAPI.saveAll(player, data, "admin_speedboost")
		end

		return "✅ Speed Boost " .. multiplier .. "x liberado!"
	end,

	["/givewin"] = function(player, args)
		local level = tonumber(args[1])
		if not level or level < 0 or level > 4 then
			return "❌ Use: /givewin <0-4> (0=1x, 1=2x, 2=4x, 3=8x, 4=16x)"
		end

		local multiplier = level > 0 and math.pow(2, level) or 1

		player:SetAttribute("WinBoostLevel", level)
		player:SetAttribute("WinBoostActive", level > 0)
		player:SetAttribute("CurrentWinBoostMultiplier", multiplier)

		local data = AdminAPI.getPlayerData(player.UserId)
		if data then
			data.WinBoostLevel = level
			data.WinBoostActive = level > 0
			data.CurrentWinBoostMultiplier = multiplier
			AdminAPI.saveAll(player, data, "admin_winboost")
		end

		return "✅ Win Boost " .. multiplier .. "x liberado!"
	end,

	["/adminhelp"] = function(player)
		return [[
🔧 COMANDOS ADMIN DISPONÍVEIS:
/giveall - Libera tudo (esteiras + boosts máximos)
/givetreadmill <3|9|25> - Libera esteira específica
/givespeed <0-4> - Speed boost (0=1x, 1=2x, 2=4x, 3=8x, 4=16x)
/givewin <0-4> - Win boost (0=1x, 1=2x, 2=4x, 3=8x, 4=16x)
/adminhelp - Mostra esta mensagem
]]
	end,
}

-- Listener de chat
Players.PlayerAdded:Connect(function(player)
	-- Verificar se é admin
	if not ADMIN_USER_IDS[player.UserId] then return end

	print("[AdminChatCommands] Admin conectado:", player.Name, "UserId:", player.UserId)

	-- Mensagem de boas-vindas no console
	task.wait(3)
	print("[AdminChatCommands] ===========================================")
	print("[AdminChatCommands] Admin", player.Name, "conectado!")
	print("[AdminChatCommands] Digite /adminhelp no chat para ver comandos")
	print("[AdminChatCommands] ===========================================")

	-- Listener de mensagens
	player.Chatted:Connect(function(message)
		local parts = string.split(message, " ")
		local command = string.lower(parts[1])

		if commands[command] then
			local args = {}
			for i = 2, #parts do
				table.insert(args, parts[i])
			end

			local response = commands[command](player, args)

			if response then
				-- Log no console
				print("[AdminChatCommands]", player.Name, "executou:", command)
				print("[AdminChatCommands]", response)
			end
		end
	end)
end)

print("[AdminChatCommands] ✅ Sistema de comandos de chat carregado")
