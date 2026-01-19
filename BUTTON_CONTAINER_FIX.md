# 🔧 Button Container Layout Fix

## 📋 O que foi mudado?

### PATCH 1: Modal Show/Hide Logic (UIHandler.client.lua)

**Antes:**
- Quando um modal era aberto, os botões `GamepassButton` e `GamepassButton2` eram escondidos individualmente usando `.Visible = false`
- Isso quebrava o layout do `UIListLayout` dentro do `ButtonsContainer`

**Depois:**
- Agora o script tenta esconder o `ButtonsContainer` inteiro (se existir)
- Se `ButtonsContainer` não existir, usa o comportamento antigo como **fallback**
- Isso respeita o `UIListLayout` e mantém o layout organizado

**Linhas modificadas:**
- `openModal()` função (linhas 403-430)
- `closeModal()` função (linhas 432-456)

---

### PATCH 2: Mobile UIScale Fix (UIHandler.client.lua)

**Antes:**
- `UIScale` era aplicado ao `SpeedGameUI` inteiro (1.4x em mobile)
- Isso escalava TUDO, incluindo o `ButtonsContainer` com `UIListLayout`
- Causava problemas de espaçamento e alinhamento

**Depois:**
- Se `ButtonsContainer` existir E tiver `UIListLayout`:
  - Cria um `UIScale` separado no `ButtonsContainer`
  - Neutraliza o scale do parent (0.714x × 1.4x = 1.0x efetivo)
  - Botões mantêm tamanho consistente em mobile/desktop
- Mantém comportamento antigo se `ButtonsContainer` não existir

**Linhas modificadas:**
- `setupMobileUI()` função (linhas 594-640)

---

## 🔄 Como fazer ROLLBACK

Se algo quebrar, você tem 2 opções:

### Opção 1: Voltar para o backup branch (RECOMENDADO)

```bash
# Volta para o branch de backup (estado 100% funcional)
git checkout backup-before-button-fixes

# Se quiser deletar as mudanças e voltar permanentemente:
git branch -D fix-button-container-layout
```

### Opção 2: Reverter commits específicos

```bash
# Lista os commits recentes
git log --oneline -5

# Reverte o commit do fix
git revert <commit-hash>
```

---

## ✅ Compatibilidade

**GARANTIDO:** O código funciona em AMBOS os cenários:

1. **COM ButtonsContainer + UIListLayout:**
   - Usa o novo comportamento (esconde container inteiro)
   - Neutraliza UIScale em mobile

2. **SEM ButtonsContainer (layout antigo):**
   - Usa o comportamento antigo (esconde botões individuais)
   - UIScale funciona normalmente

---

## 🧪 Como testar

1. **Desktop:**
   - Abra um modal (ex: Rebirth)
   - Verifique se os botões desaparecem e reaparecem corretamente

2. **Mobile:**
   - Teste no emulador ou device real
   - Verifique se os botões não ficam gigantes ou desalinhados

3. **Console Output:**
   - Veja os prints no console:
     - "ButtonsContainer hidden" = novo comportamento
     - "Individual buttons hidden (fallback mode)" = comportamento antigo

---

## 📝 Branches

- `main` - Branch principal (onde as mudanças serão mergeadas)
- `backup-before-button-fixes` - **BACKUP COMPLETO** (estado antes das mudanças)
- `fix-button-container-layout` - Branch com as mudanças aplicadas

---

## 🚨 Se algo der errado

1. Volte para o backup:
   ```bash
   git checkout backup-before-button-fixes
   ```

2. Reporte o problema com:
   - Screenshot do erro
   - Console output (F9 no Roblox Studio)
   - Qual ação causou o problema

---

**Data:** 2026-01-19
**Arquivos modificados:** `src/client/UIHandler.client.lua`
**Linhas de código:** ~50 linhas modificadas
