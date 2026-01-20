# 🔧 Como Corrigir "ONLY 3 ROBUX" Hardcoded

## Problema Identificado

O texto "ONLY 3 ROBUX" está **hardcoded no design do Studio**, não no código Lua.

## Localização

```
GamepassButton (ImageButton)
├── OnlyLabel (TextLabel) ← Tem "ONLY" hardcoded
├── PriceTag (Frame)
│   └── (elementos com "3 ROBUX")
└── ValueText (TextLabel) ← Atualizado dinamicamente pelo código
```

## Solução Manual no Studio

### Opção 1: Deletar OnlyLabel (Recomendado)

1. No **Explorer**, navegue até:
   ```
   StarterGui → SpeedGameUI → GamepassButton → OnlyLabel
   ```

2. **Delete o OnlyLabel** (clique direito → Delete)

3. O código já controla a visibilidade dinamicamente, mas se não existir, não mostrará nada

### Opção 2: Limpar Texto Hardcoded

1. No **Explorer**, selecione **OnlyLabel**

2. No **Properties**, encontre **Text**

3. **Delete o texto** (deixe vazio: "")

4. O código GamepassButtonUpdater vai controlar quando mostrar/esconder

### Opção 3: Deixar Dinâmico via Código

Se você quer manter "ONLY" mas torná-lo dinâmico:

**Adicione no GamepassButtonUpdater.client.lua** (após linha 96):

```lua
-- Atualizar texto do OnlyLabel dinamicamente
if OnlyLabel then
    if data.nextMult < 16 then
        OnlyLabel.Text = "ONLY"
        OnlyLabel.Visible = true
    else
        OnlyLabel.Visible = false
    end
end
```

## PriceTag (se mostrar "3 ROBUX")

Se houver um PriceTag mostrando "3 ROBUX":

1. Navegue até:
   ```
   GamepassButton → PriceTag
   ```

2. **Delete o PriceTag** completo (ou esconda: Visible = false)

3. O sistema não usa preço no botão atualmente

## Verificação Final

Após aplicar a solução, o botão deve mostrar apenas:
- ✅ "2x SPEED", "4x SPEED", "8x SPEED", "16x SPEED" (ValueText dinâmico)
- ✅ Sem "ONLY 3 ROBUX"
- ✅ Design limpo

## Script Automático (Se Preferir)

Cole no Command Bar:

```lua
local playerGui = game.Players.LocalPlayer.PlayerGui
for _, gui in ipairs(playerGui:GetDescendants()) do
    if gui.Name == "GamepassButton" then
        -- Limpar OnlyLabel
        local onlyLabel = gui:FindFirstChild("OnlyLabel")
        if onlyLabel and onlyLabel:IsA("TextLabel") then
            onlyLabel.Text = ""
            print("✅ OnlyLabel texto limpo em", gui:GetFullName())
        end

        -- Esconder PriceTag
        local priceTag = gui:FindFirstChild("PriceTag")
        if priceTag then
            priceTag.Visible = false
            print("✅ PriceTag escondido em", gui:GetFullName())
        end
    end
end
print("✅ GamepassButton limpo!")
```

---

**Status**: O código Lua está correto. O problema é apenas no design do Studio.
