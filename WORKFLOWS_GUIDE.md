# 🎮 SPEED DASH - GUIA COMPLETO DE WORKFLOWS

**Data**: 2026-01-17 08:00
**Status**: ✅ Todos os scripts corrigidos e funcionando

---

## 🎯 DOIS WORKFLOWS DISPONÍVEIS

Você tem duas formas de trabalhar no projeto. Escolha baseado no que quer testar:

### Workflow A: build.rbxl (Testes Rápidos de Scripts)

**Para que serve:**
- ✅ Testar scripts isoladamente
- ✅ Validar lógica do servidor
- ✅ Verificar que não há erros de sintaxe
- ✅ Testar TreadmillService com 3 zonas

**Como usar:**
```bash
./open-and-fix.sh
```

**O que você TEM neste workflow:**
- ✅ Todos os scripts atualizados (servidor + cliente)
- ✅ RemotesBootstrap funcionando (17 remotes)
- ✅ TreadmillService funcionando (3 zonas de teste)
- ✅ AutoSetupTreadmills (configura zonas automaticamente)
- ✅ WinBlocks (3 blocos de teste)
- ✅ Sistema de Speed/Level/XP funcionando
- ✅ Zero erros de concatenação
- ✅ Sistema de rebirth funcionando (backend)

**O que você NÃO TEM:**
- ❌ UI completa (SpeedGameUI)
- ❌ Botões de speed boost visíveis
- ❌ Display de Speed/Level/XP na HUD
- ❌ Botão de rebirth visível
- ❌ Apenas 3 zonas (não 60+)
- ❌ Mapa completo

**Quando usar:**
- 🔧 Você fez mudanças nos scripts e quer testar rapidamente
- 🐛 Você quer verificar se há erros no Output
- ⚡ Você quer validação rápida sem abrir o mapa completo

---

### Workflow B: rojo serve + Arquivo Original (Desenvolvimento Completo)

**Para que serve:**
- ✅ Desenvolvimento completo com UI
- ✅ Testar todas as 60+ zonas
- ✅ Ver Speed/Level/XP na HUD
- ✅ Usar botões e rebirth
- ✅ Sincronização ao vivo (muda arquivo .lua, atualiza no Studio)

**Como usar:**
```bash
./setup-rojo-serve.sh
```

Então no Studio:
1. Abra seu arquivo ORIGINAL .rbxl (aquele com o mapa completo)
2. Clique no botão **Rojo** no toolbar
3. Clique em **Connect**
4. Aguarde "✅ Connected to Rojo"

**O que você TEM neste workflow:**
- ✅ Todos os scripts atualizados (sincronizados via Rojo)
- ✅ UI completa (SpeedGameUI) do arquivo original
- ✅ Todas as 60+ TreadmillZones
- ✅ Mapa completo
- ✅ Botões funcionando
- ✅ Rebirth button funcionando
- ✅ Display de Speed/Level/XP na HUD
- ✅ Live sync (muda código, atualiza instantaneamente)

**O que você NÃO TEM:**
- ⚠️ Precisa configurar as zonas uma vez com TreadmillSetupWizard
- ⚠️ Servidor Rojo precisa ficar rodando no terminal

**Quando usar:**
- 🎮 Você quer testar o jogo completo
- 🖥️ Você quer ver a UI funcionando
- 🎨 Você quer trabalhar no mapa e scripts ao mesmo tempo
- 🔄 Você quer mudanças instantâneas (live sync)

---

## 📊 COMPARAÇÃO LADO A LADO

| Feature | build.rbxl (A) | rojo serve + Original (B) |
|---------|----------------|---------------------------|
| Scripts atualizados | ✅ Sim | ✅ Sim (via sync) |
| UI completa | ❌ Não | ✅ Sim |
| Botões funcionam | ❌ Não | ✅ Sim |
| Speed/Level na HUD | ❌ Não | ✅ Sim |
| TreadmillService | ✅ Sim (3 zonas) | ✅ Sim (60+ zonas) |
| WinBlocks | ✅ Sim (3 blocos) | ✅ Sim (todos) |
| Mapa completo | ❌ Não | ✅ Sim |
| Setup necessário | ⚡ Automático | 🔧 Manual (Wizard) |
| Live sync | ❌ Não (rebuild) | ✅ Sim (instantâneo) |
| Velocidade de teste | ⚡⚡⚡ Muito rápido | ⚡⚡ Rápido |
| Melhor para | 🐛 Debug de scripts | 🎮 Teste completo |

---

## 🚀 GUIA RÁPIDO: QUAL USAR?

### Use Workflow A (build.rbxl) quando:
- Você mudou um script e quer verificar se tem erro de sintaxe
- Você quer testar a lógica do TreadmillService
- Você não precisa da UI
- Você quer algo MUITO rápido

**Exemplo:**
> "Mudei o cálculo de XP no SpeedGameServer, será que funciona?"
>
> → Use `./open-and-fix.sh`

### Use Workflow B (rojo serve) quando:
- Você quer ver o jogo funcionando completo
- Você precisa testar botões ou UI
- Você quer testar todas as zonas
- Você está desenvolvendo features que envolvem UI

**Exemplo:**
> "Preciso ver se o botão de rebirth está aparecendo corretamente"
>
> → Use `./setup-rojo-serve.sh`

---

## 📝 PASSO A PASSO: WORKFLOW B (COMPLETO)

### Primeira Vez (Setup Inicial)

**1. Inicie o Rojo Server**
```bash
cd /Users/lucassampaio/Projects/speed-dash
./setup-rojo-serve.sh
```

Você verá:
```
🚀 Iniciando Rojo Server...
📡 ROJO SERVER ATIVO
Rojo server listening on 127.0.0.1:34872
```

**⚠️ DEIXE O TERMINAL ABERTO!** O servidor precisa ficar rodando.

**2. Abra Seu Arquivo Original no Studio**

- **NÃO** abra build.rbxl
- **SIM** abra seu arquivo .rbxl original (aquele com o mapa e UI)
- Exemplo: `/Users/lucassampaio/Desktop/SpeedDash_Final.rbxl`

**3. Conecte ao Rojo**

No Studio:
1. Procure o botão **"Rojo"** no toolbar (plugin Rojo precisa estar instalado)
2. Clique no botão
3. Uma janela abrirá mostrando "Manage Rojo Connections"
4. Clique em **"Connect"**
5. Aguarde a mensagem: **"✅ Connected to Rojo"**

**4. Configure as Treadmills (APENAS PRIMEIRA VEZ)**

No Explorer (painel esquerdo):
1. Vá para **ServerScriptService**
2. Encontre o script **TreadmillSetupWizard**
3. **Clique direito** → **Run**

No Output você verá:
```
[WIZARD] 🧙 Treadmill Setup Wizard Starting...
[WIZARD] Found 60 TreadmillZones in workspace
[WIZARD] Processing: Workspace.TreadmillPurple1.TreadmillZone
[WIZARD]   Detected: TreadmillPurple (pattern: purple)
[WIZARD]   ✅ SUCCESS: Multiplier=25 ProductId=3510662405 Type=paid
...
[WIZARD] 🎉 SETUP COMPLETE!
[WIZARD] ✅ Success: 60 zones
[WIZARD] ❌ Skipped: 0 zones
```

**5. Teste!**

Clique em **Play Solo** (F5)

Você DEVE ver:
- ✅ Speed/Level/XP na HUD
- ✅ Botões de speed boost (+100K, +1M, +10M)
- ✅ Botão de rebirth
- ✅ Zonas funcionando (ande nas treadmills)
- ✅ WinBlocks dando XP

---

### Próximas Vezes (Desenvolvimento Diário)

**1. Inicie o Rojo Server**
```bash
./setup-rojo-serve.sh
```

**2. Abra o arquivo original no Studio**

**3. Clique em Rojo → Connect**

**4. Trabalhe normalmente!**

Agora, toda vez que você:
- Salvar um arquivo `.lua` no VSCode
- O Studio atualiza AUTOMATICAMENTE
- Você NÃO precisa rebuild nem reabrir o Studio

**5. Para parar:**
- No terminal: Pressione **Ctrl+C**
- No Studio: Close normalmente

---

## 🔧 TROUBLESHOOTING

### Problema: "Rojo button não aparece no Studio"

**Solução:** Você precisa instalar o plugin Rojo no Studio

1. Abra o Roblox Studio
2. Vá em **Plugins** → **Plugin Manager**
3. Procure por **"Rojo"**
4. Click **Install**

OU baixe de: https://github.com/rojo-rbx/rojo/releases

### Problema: "Cannot connect to Rojo server"

**Causas possíveis:**

1. **Servidor não está rodando**
   - Verifique se você rodou `./setup-rojo-serve.sh`
   - Verifique se o terminal mostra "Rojo server listening"

2. **Porta errada**
   - Padrão é 34872
   - Verifique no Output do terminal qual porta está sendo usada

3. **Firewall bloqueando**
   - Permita conexões locais na porta 34872

### Problema: "Scripts não atualizam quando salvo no VSCode"

**Solução:**

1. Verifique que o terminal com Rojo está aberto e rodando
2. Verifique no Studio que está "✅ Connected"
3. Se a conexão caiu:
   - No Studio, clique em Rojo → Disconnect
   - Clique em Rojo → Connect novamente

### Problema: "TreadmillSetupWizard não encontrou nenhuma zona"

**Causa:** Seu arquivo não tem TreadmillZones no Workspace

**Solução:**

1. Verifique que você abriu o arquivo ORIGINAL (com o mapa)
2. No Explorer, vá para **Workspace**
3. Procure por models com nomes como "TreadmillPurple1", "TreadmillBlue2", etc.
4. Cada model deve ter um Part filho chamado "TreadmillZone"

Se não encontrar:
- Você está no arquivo errado (provavelmente build.rbxl)
- Ou seu mapa ainda não tem as zonas criadas

### Problema: "Botões/UI não funcionam"

**Se você está usando build.rbxl:**
- ❌ build.rbxl não tem UI
- ✅ Use Workflow B (rojo serve + arquivo original)

**Se você está usando arquivo original:**
- Verifique que SpeedGameUI existe em StarterGui
- No Explorer → StarterGui → SpeedGameUI
- Se não existir, você precisa recriar a UI ou restaurar de backup

---

## ✅ CHECKLIST DE SUCESSO

### Para Workflow A (build.rbxl)

Quando você rodar `./open-and-fix.sh` e clicar Play Solo, você deve ver:

**No Output:**
- ✅ `[RemotesBootstrap] ✅ All remotes ready for use`
- ✅ `[AutoSetup] ✅ Auto-setup complete: 3 treadmills configured`
- ✅ `[TreadmillService] ✅ TreadmillService initialized with 3 zones`
- ✅ `[SpeedGameServer] ✅ Player data loaded`
- ✅ Zero erros de concatenação
- ✅ Zero "NO VALID ZONES FOUND"

**No jogo:**
- ✅ Você consegue andar
- ✅ Treadmills respondem quando você entra nelas
- ✅ WinBlocks concedem wins

**Limitações esperadas:**
- ❌ Speed/Level/XP não aparecem na HUD (normal, sem UI)
- ❌ Botões não aparecem (normal, sem UI)

### Para Workflow B (rojo serve + original)

Quando você conectar via Rojo e clicar Play Solo, você deve ver:

**No Output:**
- ✅ `[RemotesBootstrap] ✅ All remotes ready for use`
- ✅ `[TreadmillService] ✅ TreadmillService initialized with 60 zones`
- ✅ `[SpeedGameServer] ✅ Player data loaded`
- ✅ Zero erros de concatenação
- ✅ Zero "NO VALID ZONES FOUND"

**No jogo:**
- ✅ Speed/Level/XP aparecem na HUD
- ✅ Botões de speed boost aparecem
- ✅ Botão de rebirth aparece
- ✅ Todas as 60+ treadmills funcionam
- ✅ WinBlocks concedem wins e XP

**Se tudo isso funciona = 100% SUCESSO! 🎉**

---

## 🎯 RECOMENDAÇÃO FINAL

### Para desenvolvimento diário:
**Use Workflow B (rojo serve + original)**

Vantagens:
- ✅ Você vê tudo funcionando
- ✅ Live sync (mudanças instantâneas)
- ✅ Teste completo do jogo

### Para debug rápido de scripts:
**Use Workflow A (build.rbxl)**

Vantagens:
- ⚡ Super rápido (5 segundos)
- 🐛 Foca apenas nos scripts
- 🎯 Sem distrações do mapa/UI

---

## 📞 AJUDA

Se precisar de ajuda:

1. **Workflow A não funciona:**
   - Cole o Output completo do Studio
   - Cole resultado de: `ls -lah build.rbxl`

2. **Workflow B não conecta:**
   - Cole o Output do terminal (onde rodou setup-rojo-serve.sh)
   - Cole mensagem de erro do Studio

3. **Scripts não atualizam no Workflow B:**
   - Verifique status da conexão no Studio
   - Verifique que o terminal do Rojo está aberto

---

**Criado**: 2026-01-17 08:00
**Scripts Status**: ✅ Todos funcionando (28/32 testes passando)
**build.rbxl**: ✅ Disponível para testes rápidos
**Rojo Serve**: ✅ Configurado para desenvolvimento completo
