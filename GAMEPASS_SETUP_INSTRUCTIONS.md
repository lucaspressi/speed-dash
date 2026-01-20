# 🎮 Setup Completo do GamepassButton

## 📋 Estrutura Necessária

```
GamepassButton (ImageButton)
├── UICorner
├── UIScale
├── UIStroke
├── ValueText (TextLabel) ← "16x", "32x", etc
├── OnlyLabel (TextLabel) ← "ONLY"
├── PriceTag (Frame)
│   └── (elementos do preço)
├── GamepassText (TextLabel) ← "SPEED", etc
├── FloatAnimation (LocalScript) ← Script de flutuação
└── ButtonAnimator (LocalScript) ← Script de hover/click
```

## 🔧 Passo a Passo

### 1️⃣ Criar FloatAnimation

1. No Explorer, selecione o **GamepassButton**
2. Clique com botão direito → **Insert Object** → **LocalScript**
3. Renomeie para **"FloatAnimation"**
4. Cole o conteúdo de `FLOAT_ANIMATION.lua`
5. **NÃO marque como Disabled** (deve estar ativo)

### 2️⃣ Criar ButtonAnimator

1. No Explorer, selecione o **GamepassButton**
2. Clique com botão direito → **Insert Object** → **LocalScript**
3. Renomeie para **"ButtonAnimator"**
4. Cole o conteúdo de `GAMEPASS_BUTTON_FINAL.lua`
5. **NÃO marque como Disabled** (deve estar ativo)

### 3️⃣ Verificar ValueText

1. Certifique-se que **ValueText** existe dentro do GamepassButton
2. O texto deve ser: `"16x"`, `"32x"`, `"64x"`, etc
3. O script vai ler automaticamente esse valor

### 4️⃣ Testar no Studio

1. Execute o jogo (Play)
2. Observe o Output:
   ```
   🚀 INICIANDO GAMEPASS BUTTON...
   ✅ ValueText encontrado: 16x
   ✅ FloatAnimation: true
   ✅ UIScale configurado
   ━━━━━━━━━━━━━━━━━━━━━━━
   ✅ GAMEPASS BUTTON ATIVO
      Usando: 16x
      FloatAnimation: ✅
      Hover/Click: ✅
   ━━━━━━━━━━━━━━━━━━━━━━━

   🎈 FloatAnimation iniciando para GamepassButton
   ✅ FloatAnimation ativa para GamepassButton
   ```

3. Passe o mouse sobre o botão → deve crescer suavemente
4. Clique no botão → deve encolher e voltar
5. O botão deve flutuar constantemente (sobe/desce)

## 🎨 Customização

### Alterar Multiplicador Dinamicamente

Se você quiser mudar o multiplicador (de 16x para 32x, por exemplo):

```lua
-- Em outro script que gerencia gamepasses:
local gamepassButton = script.Parent:FindFirstChild("GamepassButton")
local valueText = gamepassButton:FindFirstChild("ValueText")

if valueText then
    valueText.Text = "32x"  -- Atualiza para 32x
end
```

### Ajustar Flutuação

No `FLOAT_ANIMATION.lua`, linha 8-10:

```lua
local FLOAT_DISTANCE = 10  -- Distância em pixels (aumentar = flutua mais)
local FLOAT_DURATION = 2   -- Tempo do ciclo (aumentar = mais lento)
```

### Ajustar Animação Hover

No `GAMEPASS_BUTTON_FINAL.lua`, linha 51:

```lua
-- Aumentar o scale no hover (1.06 = 6% maior)
Scale = 1.06  -- Mudar para 1.10 = 10% maior
```

## ⚠️ Troubleshooting

### Problema: Botão não flutua
- ✅ Verifique se FloatAnimation está **ativo** (Disabled = false)
- ✅ Verifique se FloatAnimation é um **LocalScript**, não Script
- ✅ Veja o Output para mensagens de erro

### Problema: ValueText não atualiza
- ✅ Certifique-se que o TextLabel se chama **"ValueText"** (case-sensitive)
- ✅ Verifique que ValueText está **dentro** do GamepassButton
- ✅ Veja o Output: deve mostrar "ValueText encontrado: 16x"

### Problema: Hover não funciona
- ✅ Certifique-se que ButtonAnimator é um **LocalScript**
- ✅ Verifique se o botão tem Active = true
- ✅ Certifique-se que não há um Frame cobrindo o botão

### Problema: Botão cresceu demais/não volta ao normal
1. Selecione o GamepassButton no Explorer
2. Delete o UIScale antigo
3. Reexecute o jogo (Play) - o script vai criar um novo UIScale

## 📝 Notas Importantes

- ✅ Os scripts são **independentes** (um não depende do outro)
- ✅ FloatAnimation = faz o botão flutuar
- ✅ ButtonAnimator = faz hover/click animation + lê ValueText
- ✅ Ambos podem rodar ao mesmo tempo sem conflito
- ✅ ValueText é lido automaticamente, não precisa hardcoded

## 🔄 Aplicar em Múltiplos Botões

Se você tem vários gamepasses (2x, 4x, 8x, 16x, etc):

1. **Copie o GamepassButton** inteiro (Ctrl+C, Ctrl+V)
2. **Renomeie** os botões: GamepassButton2x, GamepassButton4x, etc
3. **Altere o ValueText** de cada um: "2x", "4x", "8x", "16x"
4. Os scripts vão funcionar automaticamente para todos!

**Não precisa copiar os scripts individualmente** - eles já estão dentro do botão copiado.

---

## ✅ Checklist Final

- [ ] FloatAnimation criado como LocalScript dentro do GamepassButton
- [ ] ButtonAnimator criado como LocalScript dentro do GamepassButton
- [ ] ValueText existe e tem o texto correto (ex: "16x")
- [ ] Ambos os scripts estão **ativos** (Disabled = false)
- [ ] Testado no Play mode
- [ ] Output mostra mensagens de sucesso
- [ ] Botão flutua suavemente
- [ ] Hover/Click funcionam

Se todos os itens estão marcados, está pronto para produção! 🎉
