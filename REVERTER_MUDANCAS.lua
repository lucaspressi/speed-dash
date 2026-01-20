-- ════════════════════════════════════════════════════════════════
-- ⏪ REVERTER MUDANÇAS - DESFAZER TUDO
-- ════════════════════════════════════════════════════════════════
-- Cole este script no Command Bar para DESFAZER as mudanças
-- ════════════════════════════════════════════════════════════════

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("⏪ REVERTENDO: Removendo TODOS os UIScales criados...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local removed = 0

-- ════════════════════════════════════════════════════════════════
-- REMOVER TODOS OS UISCALES
-- ════════════════════════════════════════════════════════════════

local starterGui = game:GetService("StarterGui")

for _, gui in ipairs(starterGui:GetChildren()) do
	if gui:IsA("ScreenGui") then
		-- Remover UIScale direto do ScreenGui
		local uiScale = gui:FindFirstChildOfClass("UIScale")
		if uiScale then
			print("  🗑️ Removendo UIScale de: " .. gui.Name)
			uiScale:Destroy()
			removed = removed + 1
		end

		-- Remover TODOS os UIScales dentro
		for _, desc in ipairs(gui:GetDescendants()) do
			if desc:IsA("UIScale") then
				print("  🗑️ Removendo UIScale de: " .. desc:GetFullName())
				desc:Destroy()
				removed = removed + 1
			end
		end
	end
end

-- REMOVER DO PLAYERGUI TAMBÉM (SE ESTIVER EM JOGO)
local Players = game:GetService("Players")
for _, player in ipairs(Players:GetPlayers()) do
	local playerGui = player:FindFirstChild("PlayerGui")
	if playerGui then
		for _, gui in ipairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") then
				for _, desc in ipairs(gui:GetDescendants()) do
					if desc:IsA("UIScale") then
						print("  🗑️ Removendo UIScale de: " .. desc:GetFullName())
						desc:Destroy()
						removed = removed + 1
					end
				end
			end
		end
	end
end

print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ Total de UIScales removidos: " .. removed)
print("\n💾 SALVE O JOGO AGORA! (Ctrl+S)")
print("🔄 Depois FECHE E REABRA o Studio completamente")
print("🎮 Abra o jogo de novo e teste")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
