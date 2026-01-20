-- SOLUÇÃO FINAL - GAMEPASS BUTTON
-- ✅ Usa ValueText dinâmico (16x, 32x, etc)
-- ✅ Mantém FloatAnimation funcionando
-- ✅ Animação hover/click suave
-- Cole dentro do GamepassButton!

local button = script.Parent
local TweenService = game:GetService("TweenService")

-- ✅ VALIDAÇÃO: Verificar se o parent é um botão válido
if not button:IsA("TextButton") and not button:IsA("ImageButton") then
    warn("[ButtonAnimator] Script parent is not a Button! Parent:", button.Name, "Type:", button.ClassName)
    script.Enabled = false
    return
end

-- ✅ PROTEÇÃO: Verificar se já existe um ButtonAnimator ativo
if button:GetAttribute("ButtonAnimatorActive") then
    warn("[ButtonAnimator] ButtonAnimator already active on", button.Name)
    script.Enabled = false
    return
end
button:SetAttribute("ButtonAnimatorActive", true)

print("🚀 INICIANDO GAMEPASS BUTTON...")

-- ==================== ENCONTRAR ELEMENTOS ====================
local valueText = button:FindFirstChild("ValueText")
local gamepassText = button:FindFirstChild("GamepassText")
local floatAnimation = button:FindFirstChild("FloatAnimation")
local onlyLabel = button:FindFirstChild("OnlyLabel")

if not valueText then
    warn("❌ ValueText não encontrado dentro de " .. button.Name)
    return
end

print("✅ ValueText encontrado: " .. valueText.Text)
print("✅ FloatAnimation: " .. tostring(floatAnimation ~= nil))

-- ==================== LIMPAR SOMBRAS ANTIGAS ====================
for _, child in ipairs(button.Parent:GetChildren()) do
    if child.Name:find("Shadow") or child.Name:find("Visual") then
        child:Destroy()
    end
end

-- Limpar UIScales antigos (mas preservar os atuais)
for _, child in ipairs(button:GetChildren()) do
    if child:IsA("UIScale") and child.Name ~= "UIScale" then
        child:Destroy()
    end
end

task.wait(0.1)

-- ==================== CRIAR/ENCONTRAR UISCALE ====================
local scale = button:FindFirstChild("UIScale")
if not scale then
    scale = Instance.new("UIScale")
    scale.Name = "UIScale"
    scale.Parent = button
end
scale.Scale = 1

print("✅ UIScale configurado")

-- ==================== ATIVAR FLOATANIMATION SE ESTIVER DESABILITADO ====================
-- Ativar FloatAnimation se estiver desabilitado
if floatAnimation then
    -- ✅ Verificar se já está ativo via attribute
    if not button:GetAttribute("FloatAnimationActive") and not floatAnimation.Enabled then
        floatAnimation.Enabled = true
        print("[ButtonAnimator] ✅ FloatAnimation ativa para", button.Name)
    elseif button:GetAttribute("FloatAnimationActive") then
        print("[ButtonAnimator] ✅ FloatAnimation já estava ativo")
    end
end

-- ==================== ANIMAR APENAS SCALE ====================
local function hover()
    TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
        Scale = 1.06
    }):Play()
end

local function normal()
    TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        Scale = 1
    }):Play()
end

local function click()
    TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
        Scale = 0.95
    }):Play()
end

-- ==================== EVENTOS ====================
local hovering = false
local clicking = false

button.MouseEnter:Connect(function()
    if clicking then return end
    hovering = true
    hover()
end)

button.MouseLeave:Connect(function()
    if clicking then return end
    hovering = false
    normal()
end)

button.MouseButton1Down:Connect(function()
    clicking = true
    click()
end)

button.MouseButton1Up:Connect(function()
    task.wait(0.05)
    clicking = false
    if hovering then
        hover()
    else
        normal()
    end
end)

-- ==================== ATUALIZAR VALUETEXT DINAMICAMENTE ====================
-- Se você quiser atualizar o multiplicador dinamicamente no futuro:
local function updateMultiplier(newValue)
    if valueText then
        valueText.Text = tostring(newValue) .. "x"
        print("📊 Multiplicador atualizado: " .. valueText.Text)
    end
end

-- Exemplo: updateMultiplier(32) mudaria para "32x"

print("━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ GAMEPASS BUTTON ATIVO")
print("   Usando: " .. valueText.Text)
print("   FloatAnimation: ✅")
print("   Hover/Click: ✅")
print("━━━━━━━━━━━━━━━━━━━━━━━")

-- ✅ CLEANUP: Remover attribute quando o script for destruído
script.AncestryChanged:Connect(function()
    if not script.Parent then
        button:SetAttribute("ButtonAnimatorActive", nil)
    end
end)
