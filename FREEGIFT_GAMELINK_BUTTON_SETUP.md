# 🔗 SETUP: Botão de Link do Jogo no FreeGiftModal

## 📋 O QUE FOI FEITO:

Adicionado suporte para botão "Copy Game Link" no FreeGiftModal, similar ao botão de Community/Group.

---

## 🎨 COMO ADICIONAR O BOTÃO NO STUDIO:

### 1️⃣ Abra o Roblox Studio com `speed-dash.rbxl`

### 2️⃣ Navegue até o FreeGiftModal:

```
PlayerGui
  └─ SpeedGameUI
      └─ FreeGiftModal
          └─ Step2Frame  (aqui vamos adicionar o botão)
```

### 3️⃣ Crie o ImageButton:

1. Clique com botão direito em **Step2Frame**
2. Selecione **Insert Object** > **ImageButton**
3. Renomeie para: **`CopyGameLinkButton`**

### 4️⃣ Configure as propriedades:

| Propriedade | Valor |
|-------------|-------|
| **Name** | `CopyGameLinkButton` |
| **Size** | `{0, 70}, {0, 70}` |
| **Position** | `{0.7, 0}, {0.5, 0}` (lado direito) |
| **AnchorPoint** | `0.5, 0.5` |
| **BackgroundTransparency** | `1` |
| **Image** | *(Cole a imagem de um ícone de link/share)* |
| **ImageColor3** | `80, 120, 200` (azul) |
| **ZIndex** | `5` |

### 5️⃣ Adicione um ícone de imagem:

Você pode usar um ícone de:
- 🔗 Link/Chain icon
- 📋 Clipboard icon
- 🎮 Game controller icon
- 📤 Share icon

**Exemplo de asset IDs do Roblox:**
```lua
rbxassetid://3926305904  -- Link icon
rbxassetid://3926307971  -- Share icon
```

---

## ✅ COMO FUNCIONA:

Quando o player clicar no botão:

1. **Mostra notificação**: "Link Copiado! Cole o link para convidar amigos!"
2. **Feedback visual**: Botão fica verde por 1.5 segundos
3. **Link do jogo**: `https://www.roblox.com/games/{PlaceId}`
4. **Log no console**: Para debug

---

## 📐 LAYOUT RECOMENDADO:

```
┌─────────────────────────────────┐
│       Step2Frame                │
│                                 │
│   ┌────┐         ┌────┐        │
│   │ 👥 │         │ 🔗 │        │
│   │Join│         │Link│        │
│   └────┘         └────┘        │
│  (0.3, 0)      (0.7, 0)        │
│                                 │
└─────────────────────────────────┘
```

- **JoinGroupButton**: Lado esquerdo (30%)
- **CopyGameLinkButton**: Lado direito (70%)

---

## 🔧 CUSTOMIZAÇÕES OPCIONAIS:

### Mudar texto da notificação:
```lua
-- Em UIHandler.client.lua, linha ~718
Title = "Link Copiado!",
Text = "Cole o link para convidar amigos!",
```

### Mudar posição do botão:
```lua
-- Centralizado
copyGameLinkButton.Position = UDim2.new(0.5, 0, 0.5, 0)

-- Mais à direita
copyGameLinkButton.Position = UDim2.new(0.8, 0, 0.5, 0)
```

### Adicionar texto abaixo do ícone:
```lua
local textLabel = Instance.new("TextLabel")
textLabel.Text = "Copy Link"
textLabel.Size = UDim2.new(1, 0, 0, 20)
textLabel.Position = UDim2.new(0, 0, 1, 5)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextSize = 12
textLabel.Font = Enum.Font.SourceSansBold
textLabel.Parent = copyGameLinkButton
```

---

## ⚠️ IMPORTANTE:

1. **Nome exato**: O botão DEVE se chamar `CopyGameLinkButton`
2. **Local correto**: DEVE estar dentro de `Step2Frame`
3. **Tipo correto**: DEVE ser `ImageButton` (não TextButton)
4. **Após adicionar**: Publique o jogo para as mudanças funcionarem

---

## 🐛 TROUBLESHOOTING:

### Botão não aparece:
- Verifique se está dentro de `Step2Frame`
- Verifique se `Visible = true`
- Verifique se `ZIndex >= 2`

### Botão não clica:
- Verifique se `Interactable = true` (será setado automaticamente pelo script)
- Verifique se não há outro elemento sobrepondo

### Notificação não mostra:
- Normal! Roblox não permite copiar para clipboard via script
- A notificação serve para informar o link visualmente
- Players podem copiar manualmente do console (F9)

---

## 📝 PRÓXIMOS PASSOS:

1. ✅ Adicione o botão no Studio
2. ✅ Configure as propriedades
3. ✅ Adicione um ícone bonito
4. ✅ Publique o jogo
5. ✅ Teste clicando no botão in-game

---

**Status**: ✅ Código implementado, aguardando criação do botão no Studio
