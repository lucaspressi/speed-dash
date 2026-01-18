# Guia de Emergência - Sistemas Não Funcionando

## 🚨 Situação Atual

Você testou e:
- ❌ Lava não mata
- ❌ Leaderboard não aparece
- ❌ NoobNPC não anda

## 🔍 Diagnóstico Rápido

**1. No Studio (com jogo rodando), cole e rode:**

```lua
-- Cole: CHECK_SCRIPTS_RUNNING.lua
```

Isso vai mostrar se os scripts estão **realmente rodando**.

**2. Depois, rode:**

```lua
-- Cole: FORCE_ACTIVATE_SYSTEMS.lua
```

Isso vai **forçar** a ativação dos sistemas manualmente.

---

## 💡 Causas Prováveis

### **A. Scripts não estão no ServerScriptService**

**Como verificar:**
1. No Studio, abra ServerScriptService (View > Explorer)
2. Procure por:
   - SpeedGameServer
   - NoobNpcAI
   - LavaKill
   - TreadmillService

**Se algum estiver faltando:**
1. Certifique que Rojo está rodando: `rojo serve`
2. No Studio: Plugins > Rojo > Connect
3. Aguarde sincronizar
4. Publique: File > Publish to Roblox

---

### **B. Scripts estão disabled**

**Como verificar:**
1. No ServerScriptService, clique em cada script
2. Properties (View > Properties)
3. Verifique se "Enabled" está marcado ✅

**Se estiver desmarcado:**
1. Marque "Enabled"
2. Salve (Ctrl+S)
3. Publique

---

### **C. Scripts têm erros**

**Como verificar:**
1. View > Output
2. Procure por linhas em **VERMELHO** (erros)
3. Procure por nomes de scripts: [LavaKill], [NoobAI], [SpeedGameServer]

**Se encontrar erros:**
- Copie TODO o erro
- Me mande para eu corrigir

---

### **D. Testando no lugar errado**

**IMPORTANTE:** Você está testando em:
- ❌ **Studio (Play aqui)** - pode ter problemas de sync
- ✅ **Jogo publicado** - é onde deve funcionar

**Se está testando no Studio:**
1. File > Publish to Roblox
2. Aguarde 10 segundos
3. Abra o jogo publicado no navegador
4. Teste lá

---

## 🔧 Correções Manuais

### **1. Ativar Lava Manualmente (Emergência)**

```lua
-- Cole e rode: FORCE_ACTIVATE_SYSTEMS.lua
```

Isso ativa as lavas **na hora**, sem precisar do script.

### **2. Criar Leaderstats Manualmente**

```lua
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local speed = Instance.new("IntValue")
    speed.Name = "Speed"
    speed.Value = 0
    speed.Parent = leaderstats

    local wins = Instance.new("IntValue")
    wins.Name = "Wins"
    wins.Value = 0
    wins.Parent = leaderstats

    print("Created leaderstats for " .. player.Name)
end)
```

Cole isso no Command Bar e rode. Depois saia e entre no jogo.

### **3. Verificar NoobNPC**

Se o NPC não anda:

1. Verifique se existe: Workspace > Buff Noob
2. Verifique se Stage2NpcKill existe: Workspace > Stage2NpcKill
3. Verifique se NoobNpcAI está enabled: ServerScriptService > NoobNpcAI

**Teste manual:**
```lua
local npc = workspace:FindFirstChild("Buff Noob")
if npc then
    local humanoid = npc:FindFirstChild("Humanoid")
    local hrp = npc:FindFirstChild("HumanoidRootPart")

    if humanoid and hrp then
        print("Health: " .. humanoid.Health)
        print("WalkSpeed: " .. humanoid.WalkSpeed)

        -- Force movement test
        humanoid:MoveTo(hrp.Position + Vector3.new(10, 0, 0))
        print("Commanded NPC to move!")
    end
end
```

---

## 📋 Checklist de Troubleshooting

Vá marcando conforme faz:

- [ ] Rojo está rodando (`rojo serve` no terminal)
- [ ] Studio conectado ao Rojo (Plugins > Rojo > Connect)
- [ ] Aguardei sincronização (2-3 segundos)
- [ ] Publiquei (File > Publish to Roblox)
- [ ] Aguardei 10 segundos após publicar
- [ ] Verifiquei Output (View > Output) por erros em vermelho
- [ ] Verifiquei que scripts existem em ServerScriptService
- [ ] Verifiquei que scripts estão "Enabled"
- [ ] Testei no jogo PUBLICADO (não no Studio)
- [ ] Saí e entrei novamente no jogo

---

## 🆘 Último Recurso

Se NADA funcionar:

**1. Me mande estas informações:**

No Command Bar, rode:
```lua
-- CHECK_SCRIPTS_RUNNING.lua
```

Copie **TODO** o output e me envie.

**2. Me mande o Output com erros:**

View > Output > Copie todas as linhas em VERMELHO

**3. Me diga:**
- Está testando no Studio ou no jogo publicado?
- Rojo está rodando?
- Já publicou depois do último commit?

---

## 🎯 Solução Mais Rápida

**Se você só quer fazer funcionar AGORA:**

```lua
-- FORCE_ACTIVATE_SYSTEMS.lua (cole e rode no Command Bar)
```

Isso ativa TUDO manualmente:
- ✅ Lava mata
- ✅ Leaderboard aparece
- ✅ Verifica NPC

**Limitação:** Só funciona na sessão atual. Quando reiniciar, precisa rodar de novo.

**Solução permanente:** Publicar os scripts corretamente via Rojo.

---

Rode esses diagnósticos e me manda o resultado que eu te ajudo a corrigir! 🚀
