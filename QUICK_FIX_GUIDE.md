# Guia Rápido - Corrigir NoobNPC, Lava e Leaderboard

## 🚨 3 Problemas Reportados

1. **NoobNPC não anda**
2. **Lava não mata mais**
3. **Leaderboard não funciona**

---

## ✅ Solução Rápida (5 minutos)

### Passo 1: Diagnóstico

**Em PRODUÇÃO (jogo publicado):**

1. Entre no jogo publicado
2. Pressione **F9** para abrir o console
3. Vá na aba **"Server"**
4. Cole e rode:

```lua
-- Cole todo o conteúdo de: DIAGNOSE_ALL_SYSTEMS.lua
```

5. **COPIE TODO O OUTPUT** e me mande se precisar de ajuda

### Passo 2: Aplicar Fixes Automáticos

**No Studio:**

1. Abra o jogo no Studio
2. Inicie o Rojo: `rojo serve`
3. Conecte o Studio ao Rojo
4. **File > Publish to Roblox**
5. Aguarde alguns segundos

**O que vai acontecer:**
- ✅ `LavaKill.server.lua` será publicado (mata jogadores que tocam lava)
- ✅ `TreadmillAutoFix.server.lua` corrige esteiras FREE automaticamente
- ✅ Scripts serão sincronizados via Rojo

### Passo 3: Teste em Produção

1. Entre no jogo publicado novamente
2. Teste:
   - **Leaderboard:** Deve aparecer Speed e Wins no canto superior direito
   - **Lava:** Toque na lava, deve morrer instantaneamente
   - **NoobNPC:** O NPC deve estar andando pela Stage 2

---

## 🔍 Problemas Comuns e Soluções

### ❌ NoobNPC não existe no workspace

**Sintoma:** Output mostra "Buff Noob NPC NOT FOUND"

**Solução:**
1. No Studio, vá para Workspace
2. Insira um **Rig** (Insert > Rig > R15 ou R6)
3. Renomeie para **"Buff Noob"** (nome exato!)
4. Salve e publique

### ❌ Stage2NpcKill não existe

**Sintoma:** Output mostra "Stage2NpcKill area NOT FOUND"

**Solução:**
1. No Studio, crie uma **Folder** no Workspace
2. Renomeie para **"Stage2NpcKill"**
3. Adicione **Parts** dentro dessa pasta para definir a área de patrulha
4. O NPC vai andar dentro dos limites desses parts
5. Salve e publique

### ❌ Lava não tem parts

**Sintoma:** Output mostra "NO LAVA PARTS FOUND"

**Solução:**
1. No Studio, crie **Parts** no Workspace
2. Renomeie para **"Lava"** ou **"KillBrick"**
3. Configure:
   - Material: `Neon` ou `Slate` (visual)
   - Color: Vermelho/Laranja
   - CanCollide: `true`
4. Salve e publique
5. `LavaKill.server.lua` vai detectar e ativar automaticamente

### ❌ Leaderboard não aparece

**Sintoma:** Speed e Wins não aparecem no jogo

**Possíveis causas:**

1. **SpeedGameServer está disabled**
   - No Studio, procure por `SpeedGameServer.server.lua`
   - Marque como **Enabled**
   - Publique

2. **Player precisa reentrar**
   - Leaderstats são criados quando o player entra
   - Saia e entre novamente no jogo

3. **Script com erro**
   - Pressione F9 no jogo publicado
   - Vá na aba "Server"
   - Procure por erros em vermelho
   - Me mande o erro se precisar de ajuda

---

## 📋 Checklist de Deploy

Antes de publicar, verifique:

- [ ] Rojo está rodando (`rojo serve`)
- [ ] Studio conectado ao Rojo
- [ ] "Buff Noob" existe no Workspace
- [ ] "Stage2NpcKill" folder existe no Workspace
- [ ] Parts de lava existem no Workspace
- [ ] Salvei o arquivo `.rbxl` (Ctrl+S)
- [ ] Publiquei via **File > Publish to Roblox**
- [ ] Aguardei 10 segundos após publicar
- [ ] Testei em produção

---

## 🎯 Scripts Criados

### Diagnóstico:
- **DIAGNOSE_ALL_SYSTEMS.lua** - Verifica tudo de uma vez
- **COMPARE_STUDIO_VS_PROD.lua** - Compara Studio vs Produção

### Correção:
- **FIX_ALL_SYSTEMS.lua** - Tenta corrigir automaticamente
- **LavaKill.server.lua** - Sistema de lava universal (AUTO)
- **TreadmillAutoFix.server.lua** - Corrige esteiras FREE (AUTO)

### Guias:
- **QUICK_FIX_GUIDE.md** - Este guia
- **DEPLOY_FIX_GUIDE.md** - Guia detalhado de deploy

---

## 🆘 Se Ainda Não Funcionar

1. **Rode o diagnóstico completo:**
   - Em produção, rode `DIAGNOSE_ALL_SYSTEMS.lua`
   - Me mande TODO o output

2. **Verifique erros:**
   - F9 no jogo publicado
   - Aba "Server"
   - Copie todos os erros em vermelho

3. **Informe:**
   - "Funciona no Studio?" (Sim/Não)
   - "Qual sistema não funciona?" (NoobNPC, Lava, Leaderboard)
   - "Output do diagnóstico"
   - "Erros no console (F9)"

---

## 💡 Entendendo o Problema

**Por que funciona no Studio mas não em produção?**

1. **Rojo sincroniza SCRIPTS** (código `.lua`)
2. **Rojo NÃO sincroniza OBJETOS** (models, parts, positions)
3. Quando você publica, precisa:
   - ✅ Ter os scripts corretos (via Rojo)
   - ✅ Ter os objetos corretos (salvar + publicar no Studio)

**Solução permanente:**
- Scripts que criam/corrigem objetos automaticamente no boot do servidor
- `TreadmillAutoFix.server.lua` já faz isso para esteiras FREE
- `LavaKill.server.lua` já faz isso para lava

---

## 📞 Próximos Passos

1. **Teste o diagnóstico:** rode `DIAGNOSE_ALL_SYSTEMS.lua` em prod
2. **Publique os novos scripts:** via Rojo + File > Publish
3. **Teste novamente** e me diz se funcionou!

Se ainda tiver problemas, me manda o output do diagnóstico que eu te ajudo! 🚀
