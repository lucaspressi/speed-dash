# Guia de Deploy - Correção de Esteiras FREE

## 🚨 Problema Identificado

As esteiras FREE funcionam no Studio mas NÃO funcionam em produção após deploy. Isso acontece porque:

1. ✅ Os scripts (código) são sincronizados pelo Rojo automaticamente
2. ❌ As **posições dos objetos** (TreadmillZone parts) NÃO são sincronizadas automaticamente
3. ❌ Quando você rodou `FIX_FREE_ZONE_POSITIONS.lua`, as zonas foram corrigidas **apenas no Studio**
4. ❌ Essas correções não foram salvas no arquivo `.rbxl` e não foram publicadas

## 📋 Diagnóstico

### Passo 1: Verificar diferenças entre Studio e Prod

**No Studio:**
1. Abra o jogo no Studio
2. Abra Command Bar (View > Command Bar)
3. Cole e rode: `COMPARE_STUDIO_VS_PROD.lua`
4. **COPIE TODO O OUTPUT**

**Em Produção:**
1. Abra o jogo publicado (Play no Roblox)
2. Abra Console (F9 ou F12)
3. Cole e rode o mesmo script na aba "Server"
4. **COPIE TODO O OUTPUT**

**Compare:**
- Se as posições Y das FREE zones forem diferentes → Confirmado que as correções não foram publicadas
- Studio deve mostrar Y ≈ 1.0
- Prod provavelmente mostra Y = 0.0

---

## ✅ Solução 1: Corrigir em Prod diretamente (RECOMENDADO)

Esta é a solução mais rápida e confiável.

### Passo 1: Abra o lugar publicado no Studio

**IMPORTANTE:** Você precisa abrir o lugar PUBLICADO, não o arquivo local.

1. Abra Roblox Studio
2. **File > Open from Roblox**
3. Selecione seu jogo "Speed Dash"
4. **BAIXE o lugar publicado atual**

### Passo 2: Aplique o fix

1. Com o lugar publicado aberto no Studio
2. **Pare o Rojo** se estiver rodando (Ctrl+C no terminal)
3. Abra Command Bar
4. Cole e rode: `FIX_FREE_ZONE_POSITIONS.lua`
5. Espere a mensagem: "✅ Fixed 2 FREE zones"

### Passo 3: Verifique as correções

Cole e rode no Command Bar:
```lua
local ws = game:GetService("Workspace")
for _, obj in pairs(ws:GetDescendants()) do
    if obj.Name == "TreadmillZone" and obj:IsA("BasePart") then
        local mult = obj:GetAttribute("Multiplier")
        if mult == 1 then
            print("FREE zone Y position: " .. obj.Position.Y)
        end
    end
end
```

Deve mostrar `Y position: 1.0` (ou próximo).

### Passo 4: Publique as correções

1. **File > Publish to Roblox**
2. Confirme que está publicando para o jogo certo
3. Adicione uma mensagem de commit: "Fix FREE treadmill positions"
4. Clique "Publish"

### Passo 5: Teste em Prod

1. Abra o jogo publicado
2. Teste as esteiras FREE
3. Se ainda não funcionar, rode `COMPARE_STUDIO_VS_PROD.lua` novamente

---

## ✅ Solução 2: Corrigir no arquivo local e re-sync (ALTERNATIVA)

Se você quer manter as mudanças no arquivo local também:

### Passo 1: Abra o arquivo local

1. Abra `speed-dash.rbxl` (ou o arquivo do seu lugar)
2. **Não inicie o Rojo ainda**

### Passo 2: Aplique o fix

1. Com o arquivo aberto no Studio
2. Abra Command Bar
3. Cole e rode: `FIX_FREE_ZONE_POSITIONS.lua`

### Passo 3: Salve o arquivo local

1. **File > Save** (Ctrl+S)
2. Confirme que salvou no arquivo correto

### Passo 4: Publique

1. **File > Publish to Roblox**
2. Publique para seu jogo

### Passo 5: Re-sync com Rojo

1. Inicie o Rojo novamente: `rojo serve`
2. Conecte no Studio
3. Agora o Rojo vai sincronizar scripts sobre o lugar corrigido

---

## ⚠️ IMPORTANTE: Entendendo Rojo

### O que o Rojo sincroniza:
- ✅ Scripts (`.lua` files)
- ✅ ModuleScripts
- ✅ RemoteEvents, RemoteFunctions
- ✅ Folders, estrutura

### O que o Rojo NÃO sincroniza:
- ❌ Posições de Parts
- ❌ Propriedades de objetos (Transparency, Color, etc.)
- ❌ Terrain
- ❌ GUI layouts (posições de frames, etc.)

### Workflow correto:

1. **Para código:** Edite os arquivos `.lua` → Rojo sincroniza automaticamente
2. **Para objetos do mundo:** Edite no Studio → Salve o `.rbxl` → Publique

---

## 🔍 Verificação Final

Depois de publicar, rode este teste em PROD:

```lua
-- No console do jogo publicado (F9, aba Server)
local Players = game:GetService("Players")
local player = Players:GetPlayers()[1]
if player then
    print("Player multiplier:", player:GetAttribute("CurrentTreadmillMultiplier"))
    print("On treadmill:", player:GetAttribute("OnTreadmill"))
end
```

Se o player estiver na esteira FREE, deve mostrar:
- `CurrentTreadmillMultiplier: 1`
- `On treadmill: true`

---

## 🐛 Se ainda não funcionar

Rode o diagnóstico completo em PROD:

```lua
-- Cole e rode DIAGNOSE_FREE_REALTIME.lua na aba Server do console (F9)
```

E me mande o output completo que eu te ajudo a debugar!

---

## 📝 Checklist de Deploy

Antes de publicar qualquer update:

- [ ] Testei no Studio? ✅
- [ ] Salvei o arquivo `.rbxl`?
- [ ] Publiquei via "Publish to Roblox"?
- [ ] Esperei alguns segundos após publish?
- [ ] Testei em produção?
- [ ] Verifiquei o console de prod (F9) por erros?

---

## 💡 Dica: Como evitar isso no futuro

Use um script de setup server-side que corrige posições automaticamente ao inicializar:

```lua
-- TreadmillAutoFix.server.lua (já existe como TreadmillSetup)
-- Roda automaticamente no boot e corrige zonas
```

Assim, mesmo que publique com posições erradas, elas são corrigidas automaticamente quando o servidor inicia.
