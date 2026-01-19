# 🎨 Guia de Padronização de Botões

## 📋 Problema Identificado

**Screenshot:** Os botões "x2" (Speed Boost) e "2X WIN" (Wins Boost) têm tamanhos inconsistentes:
- ❌ Botão "x2" menor que "2X WIN"
- ❌ Ícones com tamanhos diferentes (troféu maior que raio)
- ❌ Texto com proporções inconsistentes

**Objetivo:** Padronizar todos os botões para terem o mesmo tamanho (width, height) e elementos internos (ícones, texto) consistentes.

---

## 🛠️ Duas Opções de Implementação

### **OPÇÃO 1: Ajuste Manual no Studio (RECOMENDADO)**

Use este método se você quer ajustar **uma vez** no Studio e salvar permanentemente.

#### Passo a passo:

1. **Abra Roblox Studio** com o projeto speed-dash

2. **Abra o Command Bar:**
   - View > Command Bar (ou Ctrl+Shift+X)

3. **Cole o script:** `STANDARDIZE_BUTTONS.lua`
   - Copie todo o conteúdo do arquivo `STANDARDIZE_BUTTONS.lua`
   - Cole no Command Bar
   - Pressione **Enter**

4. **Verifique a saída:**
   ```
   ✅ Button sizes standardized!
   ✅ Button standardization complete!
   ```

5. **Ajuste os valores (opcional):**
   - Se os botões ficarem muito grandes/pequenos
   - Edite estas linhas no script:
   ```lua
   local STANDARD_SIZE = UDim2.new(0, 150, 0, 60)  -- Largura: 150px, Altura: 60px
   local STANDARD_ICON_SIZE = UDim2.new(0, 40, 0, 40)  -- Ícones: 40x40px
   local STANDARD_TEXT_SIZE = 24  -- Texto: 24px
   ```

6. **Salve o projeto:**
   - File > Save (Ctrl+S)
   - Publique no Roblox se necessário

---

### **OPÇÃO 2: Padronização Automática (Runtime)**

Use este método se você quer que os botões sejam padronizados **automaticamente** quando o jogo carrega.

#### Passo a passo:

1. **Arquivo criado:** `src/client/ButtonStandardizer.client.lua`

2. **Como funciona:**
   - Script roda automaticamente quando o jogador entra
   - Padroniza os botões GamepassButton e GamepassButton2
   - Aplica tamanhos consistentes em runtime

3. **Configuração:**
   - Edite o arquivo `ButtonStandardizer.client.lua`
   - Ajuste os valores em `CONFIG`:
   ```lua
   local CONFIG = {
       BUTTON_SIZE = UDim2.new(0, 150, 0, 60),  -- Tamanho do botão
       ICON_SIZE = UDim2.new(0, 40, 0, 40),     -- Tamanho dos ícones
       TEXT_SIZE = 24,                           -- Tamanho do texto
       CENTER_ICONS = true,                      -- Centralizar ícones
   }
   ```

4. **Como testar:**
   - Publique o jogo
   - Entre no jogo
   - Veja no **Output Console (F9)**:
   ```
   [ButtonStandardizer] ✅ Button standardization complete!
   ```

---

## 📐 Valores Padrão Recomendados

| Elemento | Tamanho | Descrição |
|----------|---------|-----------|
| **Botão** | `150px × 60px` | Largura × Altura do botão |
| **Ícone** | `40px × 40px` | Ícones (raio, troféu) |
| **Texto** | `24px` | TextSize dos labels |

### Ajustes para Mobile:

Se os botões ficarem muito pequenos em mobile, ajuste:

```lua
-- Para botões maiores em mobile:
BUTTON_SIZE = UDim2.new(0, 180, 0, 70)  -- +30px width, +10px height
ICON_SIZE = UDim2.new(0, 50, 0, 50)     -- +10px para ícones
TEXT_SIZE = 28                           -- +4px para texto
```

---

## 🎯 Comparação: Antes vs Depois

### ANTES (Inconsistente):
```
GamepassButton (x2):    Size = (140, 50)  ❌
GamepassButton2 (2X WIN): Size = (160, 70)  ❌

Ícone raio:   Size = (35, 35)  ❌
Ícone troféu: Size = (50, 50)  ❌
```

### DEPOIS (Padronizado):
```
GamepassButton (x2):    Size = (150, 60)  ✅
GamepassButton2 (2X WIN): Size = (150, 60)  ✅

Ícone raio:   Size = (40, 40)  ✅
Ícone troféu: Size = (40, 40)  ✅
```

---

## 🔧 Resolução de Problemas

### Problema: "Buttons not found"
**Solução:** Os botões podem ter nomes diferentes. Edite o script e adicione o nome correto:

```lua
local buttonNames = {"GamepassButton", "SpeedBoostButton", "SEU_NOME_AQUI"}
```

### Problema: Botões ficaram muito grandes/pequenos
**Solução:** Ajuste os valores `STANDARD_SIZE`:

```lua
-- Botões menores:
local STANDARD_SIZE = UDim2.new(0, 120, 0, 50)

-- Botões maiores:
local STANDARD_SIZE = UDim2.new(0, 180, 0, 70)
```

### Problema: Ícones não centralizados
**Solução:** Ajuste manualmente a Position no script:

```lua
child.Position = UDim2.new(0.5, -20, 0.5, -20)  -- Centro para ícone 40x40
```

### Problema: Texto cortado
**Solução:** Use `TextScaled = true` ao invés de tamanho fixo:

```lua
child.TextScaled = true  -- Texto se ajusta automaticamente
```

---

## 📊 Qual Opção Escolher?

| Critério | Opção 1 (Manual) | Opção 2 (Automático) |
|----------|------------------|----------------------|
| **Setup** | Uma vez no Studio | Automático |
| **Performance** | ✅ Melhor (sem overhead) | ⚠️ Leve overhead no load |
| **Manutenção** | ⚠️ Precisa reajustar se mudar UI | ✅ Sempre padronizado |
| **Controle** | ✅ Total controle no Studio | ⚠️ Depende do script |
| **Recomendado para** | UI final/produção | Desenvolvimento/testes |

**Recomendação:** Use **Opção 1 (Manual)** para produção final.

---

## 🚀 Próximos Passos

1. ✅ Execute um dos scripts (Opção 1 ou 2)
2. ✅ Teste no Studio e no jogo
3. ✅ Ajuste valores se necessário
4. ✅ Salve/publique o projeto

---

## 📝 Arquivos Criados

- `STANDARDIZE_BUTTONS.lua` - Script manual para Studio Command Bar
- `src/client/ButtonStandardizer.client.lua` - Script automático (runtime)
- `BUTTON_STANDARDIZATION_GUIDE.md` - Este guia (você está aqui!)

---

**Data:** 2026-01-19
**Problema:** Botões com tamanhos inconsistentes (PDF screenshot)
**Solução:** Padronização automática ou manual de Size/Icons/Text
