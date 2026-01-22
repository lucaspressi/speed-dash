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

-- Helper: Encontrar player por nome ou UserId
local function findPlayerByNameOrId(identifier)
	-- Tentar como UserId primeiro
	local userId = tonumber(identifier)
	if userId then
		return Players:GetPlayerByUserId(userId)
	end

	-- Tentar como nome (case insensitive, partial match)
	identifier = string.lower(identifier)
	for _, player in ipairs(Players:GetPlayers()) do
		if string.lower(player.Name):find(identifier) or string.lower(player.DisplayName):find(identifier) then
			return player
		end
	end

	return nil
end

-- Helper: Liberar tudo para um player
local function giveAllToPlayer(targetPlayer)
	-- Libera todas as esteiras e boosts
	targetPlayer:SetAttribute("TreadmillX3Owned", true)
	targetPlayer:SetAttribute("TreadmillX9Owned", true)
	targetPlayer:SetAttribute("TreadmillX25Owned", true)
	targetPlayer:SetAttribute("SpeedBoostLevel", 4)
	targetPlayer:SetAttribute("SpeedBoostActive", true)
	targetPlayer:SetAttribute("CurrentSpeedBoostMultiplier", 16)
	-- Win Boost REMOVIDO - mantém em 0 (sem multiplicação de trofeus)

	-- Salvar no DataStore
	local data = AdminAPI.getPlayerData(targetPlayer.UserId)
	if data then
		data.TreadmillX3Owned = true
		data.TreadmillX9Owned = true
		data.TreadmillX25Owned = true
		data.SpeedBoostLevel = 4
		data.SpeedBoostActive = true
		data.CurrentSpeedBoostMultiplier = 16
		-- Win Boost REMOVIDO - mantém em 0

		AdminAPI.saveAll(targetPlayer, data, "admin_giveall")
	end
end

-- Comandos disponíveis
local commands = {
	["/giveall"] = function(player, args)
		-- Se tiver argumento, dar para outro player
		if args[1] then
			local targetPlayer = findPlayerByNameOrId(args[1])
			if not targetPlayer then
				return "❌ Player '" .. args[1] .. "' não encontrado online"
			end

			giveAllToPlayer(targetPlayer)
			return "✅ TUDO LIBERADO para " .. targetPlayer.Name .. "! (Esteiras 3x/9x/25x + Speed Boost 16x)"
		else
			-- Dar para si mesmo
			giveAllToPlayer(player)
			return "✅ TUDO LIBERADO! (Esteiras 3x/9x/25x + Speed Boost 16x)"
		end
	end,

	["/givetreadmill"] = function(player, args)
		if not args[1] then
			return "❌ Use: /givetreadmill <3,9,25> [playerName]"
		end

		local multiplier = tonumber(args[1])
		if not multiplier or (multiplier ~= 3 and multiplier ~= 9 and multiplier ~= 25) then
			return "❌ Use: /givetreadmill <3,9,25> [playerName]"
		end

		-- Se tiver segundo argumento, dar para outro player
		local targetPlayer = player
		if args[2] then
			targetPlayer = findPlayerByNameOrId(args[2])
			if not targetPlayer then
				return "❌ Player '" .. args[2] .. "' não encontrado online"
			end
		end

		local key = "TreadmillX" .. multiplier .. "Owned"
		targetPlayer:SetAttribute(key, true)

		local data = AdminAPI.getPlayerData(targetPlayer.UserId)
		if data then
			data[key] = true
			AdminAPI.saveAll(targetPlayer, data, "admin_treadmill")
		end

		if targetPlayer == player then
			return "✅ Esteira " .. multiplier .. "x liberada!"
		else
			return "✅ Esteira " .. multiplier .. "x liberada para " .. targetPlayer.Name .. "!"
		end
	end,

	["/givespeed"] = function(player, args)
		if not args[1] then
			return "❌ Use: /givespeed <0-4> [playerName] (0=1x, 1=2x, 2=4x, 3=8x, 4=16x)"
		end

		local level = tonumber(args[1])
		if not level or level < 0 or level > 4 then
			return "❌ Use: /givespeed <0-4> [playerName] (0=1x, 1=2x, 2=4x, 3=8x, 4=16x)"
		end

		-- Se tiver segundo argumento, dar para outro player
		local targetPlayer = player
		if args[2] then
			targetPlayer = findPlayerByNameOrId(args[2])
			if not targetPlayer then
				return "❌ Player '" .. args[2] .. "' não encontrado online"
			end
		end

		local multiplier = level > 0 and math.pow(2, level) or 1

		targetPlayer:SetAttribute("SpeedBoostLevel", level)
		targetPlayer:SetAttribute("SpeedBoostActive", level > 0)
		targetPlayer:SetAttribute("CurrentSpeedBoostMultiplier", multiplier)

		local data = AdminAPI.getPlayerData(targetPlayer.UserId)
		if data then
			data.SpeedBoostLevel = level
			data.SpeedBoostActive = level > 0
			data.CurrentSpeedBoostMultiplier = multiplier
			AdminAPI.saveAll(targetPlayer, data, "admin_speedboost")
		end

		if targetPlayer == player then
			return "✅ Speed Boost " .. multiplier .. "x liberado!"
		else
			return "✅ Speed Boost " .. multiplier .. "x liberado para " .. targetPlayer.Name .. "!"
		end
	end,

	-- ❌ /givewin REMOVIDO - Win boost foi desabilitado para economia de teletransporte

	["/adminhelp"] = function(player)
		local help = "🔧 COMANDOS ADMIN DISPONÍVEIS:\n\n"
		help = help .. "PARA VOCÊ MESMO:\n"
		help = help .. "/giveall - Libera tudo para você\n"
		help = help .. "/givetreadmill <3,9,25> - Libera esteira para você\n"
		help = help .. "/givespeed <0-4> - Speed boost para você\n\n"
		help = help .. "PARA OUTROS PLAYERS:\n"
		help = help .. "/giveall <playerName> - Libera tudo para outro player\n"
		help = help .. "/givetreadmill <3,9,25> <playerName> - Libera esteira para outro\n"
		help = help .. "/givespeed <0-4> <playerName> - Speed boost para outro\n\n"
		help = help .. "EXEMPLOS:\n"
		help = help .. "/giveall Lucas - Dá tudo para player Lucas\n"
		help = help .. "/givespeed 4 Joao - Dá speed 16x para Joao\n"
		help = help .. "/givetreadmill 25 Maria - Dá esteira 25x para Maria\n\n"
		help = help .. "NÍVEIS SPEED: 0=1x, 1=2x, 2=4x, 3=8x, 4=16x\n"
		help = help .. "NOTA: Win Boost foi removido do jogo"
		return help
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
