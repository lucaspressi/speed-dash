-- ════════════════════════════════════════════════════════════════
-- 🔧 FIX AUTOMÁTICO - BOTÕES PEQUENOS
-- ════════════════════════════════════════════════════════════════
-- Cole este script INTEIRO no Command Bar do Roblox Studio
-- Pressione Enter
-- Este script vai CORRIGIR automaticamente qualquer UIScale problemático
-- ════════════════════════════════════════════════════════════════

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔧 FIX AUTOMÁTICO: Corrigindo botões pequenos...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local fixes = 0

-- ════════════════════════════════════════════════════════════════
-- CORRIGIR STARTERUI
-- ════════════════════════════════════════════════════════════════
print("\n🔧 Corrigindo StarterGui...")

local starterGui = game:GetService("StarterGui")

for _, gui in ipairs(starterGui:GetChildren()) do
	if gui:IsA("ScreenGui") then
		-- Verificar UIScale no ScreenGui
		local uiScale = gui:FindFirstChildOfClass("UIScale")
		if uiScale and uiScale.Scale ~= 1.0 then
			print("  ⚠️ " .. gui.Name .. " tem UIScale com Scale = " .. uiScale.Scale)
			print("     🔧 Corrigindo para 1.0...")
			uiScale.Scale = 1.0
			fixes = fixes + 1
			print("     ✅ Corrigido!")
		end

		-- Corrigir todos os UIScales dentro
		for _, desc in ipairs(gui:GetDescendants()) do
			if desc:IsA("UIScale") and desc.Scale ~= 1.0 then
				print("  ⚠️ " .. desc:GetFullName() .. " tem Scale = " .. desc.Scale)
				print("     🔧 Corrigindo para 1.0...")
				desc.Scale = 1.0
				fixes = fixes + 1
				print("     ✅ Corrigido!")
			end
		end
	end
end

-- ════════════════════════════════════════════════════════════════
-- CORRIGIR PLAYERGUI (SE ESTIVER EM JOGO)
-- ════════════════════════════════════════════════════════════════
print("\n🔧 Corrigindo PlayerGui...")

local Players = game:GetService("Players")
if #Players:GetPlayers() == 0 then
	print("  ℹ️ Nenhum jogador no jogo. Execute durante o Play para corrigir PlayerGui também.")
else
	for _, player in ipairs(Players:GetPlayers()) do
		local playerGui = player:FindFirstChild("PlayerGui")
		if playerGui then
			for _, gui in ipairs(playerGui:GetChildren()) do
				if gui:IsA("ScreenGui") then
					local uiScale = gui:FindFirstChildOfClass("UIScale")
					if uiScale and uiScale.Scale ~= 1.0 then
						print("  ⚠️ " .. player.Name .. " → " .. gui.Name .. " tem Scale = " .. uiScale.Scale)
						print("     🔧 Corrigindo para 1.0...")
						uiScale.Scale = 1.0
						fixes = fixes + 1
						print("     ✅ Corrigido!")
					end
				end
			end
		end
	end
end

-- ════════════════════════════════════════════════════════════════
-- REMOVER UISCALES DESNECESSÁRIOS
-- ════════════════════════════════════════════════════════════════
print("\n🗑️ Removendo UIScales desnecessários...")

local speedGameUI = starterGui:FindFirstChild("SpeedGameUI")
if speedGameUI then
	-- Remover UIScale direto do SpeedGameUI se ele existe
	local uiScale = speedGameUI:FindFirstChildOfClass("UIScale")
	if uiScale then
		print("  ⚠️ SpeedGameUI tem UIScale (Scale = " .. uiScale.Scale .. ")")
		print("     🗑️ Removendo UIScale...")
		uiScale:Destroy()
		fixes = fixes + 1
		print("     ✅ UIScale removido!")
	else
		print("  ✅ SpeedGameUI não tem UIScale (normal)")
	end
end

-- ════════════════════════════════════════════════════════════════
-- RESUMO
-- ════════════════════════════════════════════════════════════════
print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📊 RESUMO DO FIX")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if fixes > 0 then
	print("\n✅ Total de correções aplicadas: " .. fixes)
	print("\n💾 IMPORTANTE: Salve o jogo agora! (Ctrl+S)")
	print("   Depois teste clicando em Play")
	print("\n🎯 Resultado esperado: Botões voltam ao tamanho normal!")
else
	print("\n✅ Nenhuma correção necessária!")
	print("   Todos os UIScales já estavam em 1.0")
	print("\n🤔 Se os botões continuam pequenos, pode ser:")
	print("   1. Elementos com Size reduzido manualmente")
	print("   2. Script criando UIScale durante o jogo")
	print("   3. Problema em outro lugar")
	print("\n💡 Execute o script de DIAGNÓSTICO para investigar mais")
end

print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
