# 🎮 GAMEPASS DYNAMIC SYSTEM - GUIA DE TESTES

## ✅ ARQUIVOS MODIFICADOS/CRIADOS

### 📝 Servidor (SpeedGameServer.server.lua)
- ✅ **Linha 339-340**: Adiciona Attributes quando jogador entra
- ✅ **Linha 590**: Atualiza Attribute após compra de Speed Boost
- ✅ **Linha 618**: Atualiza Attribute após compra de Win Boost

### 📱 Cliente (Novos/Modificados)
- ✅ **GamepassButtonUpdater.client.lua**: Novo script que atualiza UI dinamicamente
- ✅ **ClientBootstrap.client.lua**: Função antiga comentada (linhas 305-338, 355, 632)

---

## 🧪 TESTES NO ROBLOX STUDIO

### **TESTE 1: Verificar Attribute Inicial**

1. Inicie o jogo no Studio
2. Abra o **Command Bar** (View → Command Bar)
3. Execute:
```lua
local player = game.Players.LocalPlayer
print("SpeedBoostLevel:", player:GetAttribute("SpeedBoostLevel"))
print("WinBoostLevel:", player:GetAttribute("WinBoostLevel"))
```

**Resultado Esperado:**
```
SpeedBoostLevel: 0
WinBoostLevel: 0
```

---

### **TESTE 2: Verificar se o Botão Existe**

Execute no Command Bar:
```lua
local player = game.Players.LocalPlayer
local gui = player.PlayerGui
for _, screenGui in ipairs(gui:GetChildren()) do
    local btn = screenGui:FindFirstChild("GamepassButton", true)
    if btn then
        print("✅ Botão encontrado:", btn:GetFullName())
        for _, child in ipairs(btn:GetChildren()) do
            print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
end
```

**Resultado Esperado:**
```
✅ Botão encontrado: PlayerGui.SpeedGameUI.GamepassButton
  - ValueText (TextLabel)
  - OnlyLabel (TextLabel)
  - PriceLabel (TextLabel)  ← NOVO!
  - RobuxIcon (ImageLabel)  ← NOVO!
  - [outros elementos...]
```

---

### **TESTE 3: Simular Mudança de Nível**

Execute no Command Bar:
```lua
-- Simula compra do primeiro boost (2x Speed)
local player = game.Players.LocalPlayer
player:SetAttribute("SpeedBoostLevel", 1)
task.wait(0.5)
print("Nível mudou para 1 - Botão deve mostrar '4X SPEED' e '29 R$'")
```

**Resultado Esperado:**
- Output: `[GamepassUpdater] 🔔 SpeedBoostLevel mudou para: 1`
- Output: `[GamepassUpdater] ✅ Botão mostra 4X por 29 R$`
- Botão na UI deve mostrar **"4X SPEED"** e **"29"**

---

### **TESTE 4: Testar Todos os Níveis**

Execute no Command Bar:
```lua
local player = game.Players.LocalPlayer
local levels = {
    [0] = {mult = "2X", price = "3"},
    [1] = {mult = "4X", price = "29"},
    [2] = {mult = "8X", price = "81"},
    [3] = {mult = "16X", price = "599"},
    [4] = {mult = "16X", price = "MAX"},
}

for level = 0, 4 do
    player:SetAttribute("SpeedBoostLevel", level)
    task.wait(1)
    print(string.format("Nível %d → Deve mostrar %s SPEED / %s R$",
        level, levels[level].mult, levels[level].price))
end
```

**Resultado Esperado:**
- Nível 0 → Botão mostra **"2X SPEED"** / **"3"**
- Nível 1 → Botão mostra **"4X SPEED"** / **"29"**
- Nível 2 → Botão mostra **"8X SPEED"** / **"81"**
- Nível 3 → Botão mostra **"16X SPEED"** / **"599"**
- Nível 4 → Botão mostra **"16X SPEED"** / **"MAX"** (sem ícone R$)

---

### **TESTE 5: Verificar Logs do Script**

Abra o **Output** e procure por mensagens:

**Ao entrar no jogo:**
```
[GamepassUpdater] ✅ Botão encontrado: PlayerGui.SpeedGameUI.GamepassButton
[GamepassUpdater] 🎯 ValueText encontrado: ...
[GamepassUpdater] ✅ PriceLabel criado
[GamepassUpdater] ✅ RobuxIcon criado
[GamepassUpdater] 🎬 Nível inicial: 0
[GamepassUpdater] ✅ Sistema de atualização dinâmica ativado!
```

**Ao mudar o nível:**
```
[GamepassUpdater] 🔔 SpeedBoostLevel mudou para: 1
[GamepassUpdater] 🔄 Atualizando botão para nível: 1
[GamepassUpdater] ✅ Botão mostra 4X por 29 R$
```

---

## 🐛 TROUBLESHOOTING

### **Problema: "GamepassButton não encontrado"**

**Possíveis causas:**
1. O botão tem outro nome na UI
2. O script está rodando antes da UI carregar

**Solução:**
Execute no Command Bar para descobrir o nome real:
```lua
local player = game.Players.LocalPlayer
local gui = player.PlayerGui
for _, sg in ipairs(gui:GetChildren()) do
    for _, obj in ipairs(sg:GetDescendants()) do
        if obj:IsA("ImageButton") or obj:IsA("TextButton") then
            if string.match(obj.Name:lower(), "speed") or
               string.match(obj.Name:lower(), "boost") or
               string.match(obj.Name:lower(), "gamepass") then
                print("🔍 Possível botão:", obj:GetFullName())
            end
        end
    end
end
```

Depois, edite a linha 24 de `GamepassButtonUpdater.client.lua` com o nome correto.

---

### **Problema: "ValueText não encontrado"**

**Solução:**
Execute para ver a estrutura do botão:
```lua
local player = game.Players.LocalPlayer
local btn = player.PlayerGui:FindFirstChild("GamepassButton", true)
if btn then
    for _, child in ipairs(btn:GetChildren()) do
        if child:IsA("TextLabel") then
            print("TextLabel:", child.Name, "→ Text:", child.Text)
        end
    end
end
```

Edite a linha 46 de `GamepassButtonUpdater.client.lua` com o nome correto.

---

### **Problema: PriceLabel/RobuxIcon aparecem fora do lugar**

**Solução:**
Ajuste as posições no script `GamepassButtonUpdater.client.lua`:

```lua
-- Linha ~69 (PriceLabel)
PriceLabel.Position = UDim2.new(0.68, 0, 0.55, 0)  -- Ajustar X e Y

-- Linha ~86 (RobuxIcon)
RobuxIcon.Position = UDim2.new(0.82, 0, 0.55, 0)  -- Ajustar X e Y
```

Use o **Explorer** no Studio para ver as posições atuais dos elementos.

---

## 📋 CHECKLIST FINAL

Após implementar, verifique:

- [ ] Servidor seta o Attribute quando compra boost ✅
- [ ] Servidor seta o Attribute quando jogador entra ✅
- [ ] Script do cliente encontra o GamepassButton
- [ ] PriceLabel é criado na posição correta
- [ ] RobuxIcon é criado na posição correta
- [ ] Botão atualiza quando compra boost
- [ ] Botão mostra "MAX" quando nível 4
- [ ] Função antiga está comentada ✅

---

## 🎯 COMPRA REAL (Teste Final)

1. Publique o jogo (File → Publish to Roblox)
2. Entre no jogo publicado
3. Clique no botão de gamepass
4. Compre o boost (ou cancele a compra)
5. Verifique se o botão atualiza automaticamente após a compra

**Comportamento esperado:**
- Após comprar o 2x Speed (3 R$), o botão deve mostrar automaticamente **"4X SPEED"** / **"29"**
- Após comprar o 4x Speed (29 R$), o botão deve mostrar **"8X SPEED"** / **"81"**
- E assim por diante...

---

## 📊 ESTRUTURA DE DADOS (Referência)

### Multiplicadores (Fórmula: 2^level)
- Level 0 → 1x (sem boost)
- Level 1 → 2x (3 R$)
- Level 2 → 4x (29 R$)
- Level 3 → 8x (81 R$)
- Level 4 → 16x (599 R$)

### Product IDs
```lua
SPEEDBOOST_PRODUCT_BY_LEVEL = {
    [1] = 3510578826,  -- 2x Speed (3 R$)
    [2] = 3510802965,  -- 4x Speed (29 R$)
    [3] = 3510803353,  -- 8x Speed (81 R$)
    [4] = 3510803870,  -- 16x Speed (599 R$)
}
```

---

## 🔧 PRÓXIMAS MELHORIAS (Opcional)

1. **Animações**: Adicionar tween ao atualizar o preço/multiplicador
2. **Som**: Tocar som de "ding" ao atualizar
3. **Efeito Visual**: Fazer o botão "pulsar" ao mudar
4. **Botão Win Boost**: Criar script similar para o botão de Win Boost

---

**🎉 SISTEMA IMPLEMENTADO COM SUCESSO!**

Se tudo funcionou, o botão agora atualiza dinamicamente mostrando:
- O multiplicador correto para o próximo nível
- O preço correto em Robux
- "MAX" quando já tem todos os boosts

Para qualquer problema, verifique o **Output** do Roblox Studio para logs de debug.
