-- ════════════════════════════════════════════════════════════════
-- 👀 APENAS MOSTRAR INFORMAÇÕES - NÃO MODIFICA NADA!
-- ════════════════════════════════════════════════════════════════
-- Este script APENAS mostra informações, não faz NENHUMA modificação
-- ════════════════════════════════════════════════════════════════

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("👀 MOSTRANDO INFORMAÇÕES (SEM MODIFICAR NADA)")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local starterGui = game:GetService("StarterGui")
local speedGameUI = starterGui:FindFirstChild("SpeedGameUI")

if not speedGameUI then
	print("\n❌ SpeedGameUI não encontrado!")
	return
end

print("\n✅ SpeedGameUI encontrado!")
print("Path: " .. speedGameUI:GetFullName())

-- ════════════════════════════════════════════════════════════════
-- MOSTRAR PROPRIEDADES DO SPEEDGAMEUI
-- ════════════════════════════════════════════════════════════════
print("\n📦 PROPRIEDADES DO SPEEDGAMEUI:")
print("  Classe: " .. speedGameUI.ClassName)
print("  Enabled: " .. tostring(speedGameUI.Enabled))

-- Verificar UIScale direto no SpeedGameUI
local mainUIScale = speedGameUI:FindFirstChildOfClass("UIScale")
if mainUIScale then
	print("  ⚠️ TEM UIScale: Scale = " .. mainUIScale.Scale)
else
	print("  ✅ NÃO tem UIScale (normal)")
end

-- ════════════════════════════════════════════════════════════════
-- LISTAR TODOS OS BOTÕES
-- ════════════════════════════════════════════════════════════════
print("\n🎮 BOTÕES ENCONTRADOS:")

local buttons = {}
for _, desc in ipairs(speedGameUI:GetDescendants()) do
	if desc:IsA("TextButton") or desc:IsA("ImageButton") then
		table.insert(buttons, desc)
	end
end

print("  Total: " .. #buttons .. " botões")

for i, button in ipairs(buttons) do
	print("\n  " .. i .. ". " .. button.Name)
	print("     Path: " .. button:GetFullName())
	print("     Classe: " .. button.ClassName)
	print("     Size: " .. tostring(button.Size))
	print("     AbsoluteSize: " .. button.AbsoluteSize.X .. "x" .. button.AbsoluteSize.Y .. " pixels")

	-- Verificar se tem UIScale nos pais
	local parent = button.Parent
	local depth = 0
	while parent and parent ~= speedGameUI and depth < 10 do
		local scale = parent:FindFirstChildOfClass("UIScale")
		if scale then
			print("     ⚠️ Parent '" .. parent.Name .. "' tem UIScale: " .. scale.Scale)
		end
		parent = parent.Parent
		depth = depth + 1
	end
end

-- ════════════════════════════════════════════════════════════════
-- MOSTRAR TODOS OS UISCALES NO JOGO
-- ════════════════════════════════════════════════════════════════
print("\n\n🔍 TODOS OS UISCALES NO JOGO:")

local allUIScales = {}
for _, desc in ipairs(game:GetDescendants()) do
	if desc:IsA("UIScale") then
		table.insert(allUIScales, desc)
	end
end

print("  Total: " .. #allUIScales .. " UIScales")

for i, uiScale in ipairs(allUIScales) do
	print("\n  " .. i .. ". " .. uiScale:GetFullName())
	print("     Scale: " .. uiScale.Scale)
	if uiScale.Scale ~= 1.0 then
		print("     ⚠️ DIFERENTE DE 1.0!")
	end
end

-- ════════════════════════════════════════════════════════════════
-- RESUMO
-- ════════════════════════════════════════════════════════════════
print("\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📋 RESUMO:")
print("  Botões encontrados: " .. #buttons)
print("  UIScales encontrados: " .. #allUIScales)
print("\n💡 COPIE TODO O OUTPUT ACIMA E ME ENVIE")
print("   Assim posso ver o que está acontecendo!")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
