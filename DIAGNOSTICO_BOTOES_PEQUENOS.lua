-- ════════════════════════════════════════════════════════════════
-- 🔍 DIAGNÓSTICO COMPLETO - BOTÕES PEQUENOS
-- ════════════════════════════════════════════════════════════════
-- Cole este script INTEIRO no Command Bar do Roblox Studio
-- Pressione Enter e veja o Output
-- ════════════════════════════════════════════════════════════════

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔍 DIAGNÓSTICO: Procurando causa dos botões pequenos")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- ════════════════════════════════════════════════════════════════
-- FASE 1: VERIFICAR STARTERUI
-- ════════════════════════════════════════════════════════════════
print("\n📦 FASE 1: Verificando StarterGui...")

local starterGui = game:GetService("StarterGui")

for _, gui in ipairs(starterGui:GetChildren()) do
	if gui:IsA("ScreenGui") then
		print("\n  ScreenGui: " .. gui.Name)

		-- Verificar UIScale no ScreenGui
		local uiScale = gui:FindFirstChildOfClass("UIScale")
		if uiScale then
			if uiScale.Scale == 1.0 then
				print("    ✅ UIScale: " .. uiScale.Scale .. " (normal)")
			else
				print("    ⚠️ UIScale: " .. uiScale.Scale .. " ← PODE SER O PROBLEMA!")
			end
		else
			print("    ℹ️ Sem UIScale")
		end

		-- Procurar por todos os UIScales dentro
		for _, desc in ipairs(gui:GetDescendants()) do
			if desc:IsA("UIScale") and desc ~= uiScale then
				print("    📍 UIScale em: " .. desc:GetFullName())
				if desc.Scale == 1.0 then
					print("       ✅ Scale: " .. desc.Scale .. " (normal)")
				else
					print("       ⚠️ Scale: " .. desc.Scale .. " ← PODE SER O PROBLEMA!")
				end
			end
		end
	end
end

-- ════════════════════════════════════════════════════════════════
-- FASE 2: VERIFICAR PLAYERGUI (EM JOGO)
-- ════════════════════════════════════════════════════════════════
print("\n\n📱 FASE 2: Verificando PlayerGui (em jogo)...")

local Players = game:GetService("Players")
if #Players:GetPlayers() == 0 then
	print("  ⚠️ Nenhum jogador no jogo. Clique em Play primeiro!")
else
	for _, player in ipairs(Players:GetPlayers()) do
		print("\n  Jogador: " .. player.Name)

		local playerGui = player:FindFirstChild("PlayerGui")
		if playerGui then
			for _, gui in ipairs(playerGui:GetChildren()) do
				if gui:IsA("ScreenGui") then
					print("    ScreenGui: " .. gui.Name)

					local uiScale = gui:FindFirstChildOfClass("UIScale")
					if uiScale then
						if uiScale.Scale == 1.0 then
							print("      ✅ UIScale: " .. uiScale.Scale .. " (normal)")
						else
							print("      ⚠️ UIScale: " .. uiScale.Scale .. " ← PODE SER O PROBLEMA!")
						end
					end
				end
			end
		end
	end
end

-- ════════════════════════════════════════════════════════════════
-- FASE 3: VERIFICAR BOTÕES ESPECÍFICOS
-- ════════════════════════════════════════════════════════════════
print("\n\n🎮 FASE 3: Verificando botões específicos...")

local speedGameUI = starterGui:FindFirstChild("SpeedGameUI")
if speedGameUI then
	print("\n  ✅ SpeedGameUI encontrado!")

	-- Listar todos os botões
	local buttons = {}
	for _, desc in ipairs(speedGameUI:GetDescendants()) do
		if desc:IsA("TextButton") or desc:IsA("ImageButton") then
			table.insert(buttons, desc)
		end
	end

	print("  📊 Total de botões encontrados: " .. #buttons)

	for _, button in ipairs(buttons) do
		print("\n    Botão: " .. button.Name)
		print("      Path: " .. button:GetFullName())
		print("      Size: " .. tostring(button.Size))
		print("      AbsoluteSize: " .. tostring(button.AbsoluteSize))

		-- Verificar se tem UIScale nos pais
		local parent = button.Parent
		while parent and parent ~= speedGameUI do
			local scale = parent:FindFirstChildOfClass("UIScale")
			if scale then
				if scale.Scale == 1.0 then
					print("      ✅ Parent '" .. parent.Name .. "' tem UIScale: " .. scale.Scale)
				else
					print("      ⚠️ Parent '" .. parent.Name .. "' tem UIScale: " .. scale.Scale .. " ← PROBLEMA!")
				end
			end
			parent = parent.Parent
		end
	end
else
	print("\n  ❌ SpeedGameUI NÃO encontrado!")
	print("  Verifique se o nome está correto")
end

-- ════════════════════════════════════════════════════════════════
-- FASE 4: VERIFICAR SCRIPTS QUE MODIFICAM SCALE
-- ════════════════════════════════════════════════════════════════
print("\n\n📜 FASE 4: Procurando scripts que modificam Scale...")

local function searchInScript(script)
	local success, source = pcall(function()
		return script.Source
	end)

	if success and source then
		if source:find("%.Scale%s*=") or source:find("UIScale") then
			return true
		end
	end
	return false
end

for _, script in ipairs(game:GetDescendants()) do
	if script:IsA("LocalScript") or script:IsA("Script") then
		if searchInScript(script) then
			print("  📍 Script que mexe com Scale: " .. script:GetFullName())
		end
	end
end

-- ════════════════════════════════════════════════════════════════
-- RESUMO FINAL
-- ════════════════════════════════════════════════════════════════
print("\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📋 RESUMO DO DIAGNÓSTICO")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("\n🔍 Procure por linhas marcadas com ⚠️ no Output acima")
print("   Essas são as causas PROVÁVEIS do problema!")
print("\n💡 SOLUÇÕES:")
print("   1. Se encontrou UIScale com Scale ≠ 1.0:")
print("      → Deletar o UIScale OU mudar Scale para 1.0")
print("   2. Se encontrou script modificando Scale:")
print("      → Verificar o script e comentar a linha")
print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
