# 🚨 GUIA DEFINITIVO: REMOVER "55 ROBUX HD ADMIN" MALWARE

**Última atualização:** 2026-01-18
**Problema:** Prompt automático de "55 robux [OWNER] HD Admin Owner Rank!" persiste após rebuild

---

## 🔍 O QUE DESCOBRIMOS

Baseado em pesquisa no Roblox DevForum e análise do seu projeto:

### ✅ Confirmado LIMPO:
- Seu código fonte Rojo está limpo (32 arquivos .lua verificados)
- Plugins instalados: apenas RojoManagedPlugin (legítimo)

### ❌ O Problema:
O malware é **inserido DURANTE O RUNTIME** (quando você clica "Play" no Studio). Ele não está salvo no arquivo, por isso o rebuild não funcionou.

### 📚 Fontes da Pesquisa:
Este é um malware **muito conhecido** documentado em:
- [DevForum: HD Admin prompt virus problem](https://devforum.roblox.com/t/hd-admin-prompt-virus-problem/4115546)
- [DevForum: Need help dealing with a sneaky script virus of HD Admin](https://devforum.roblox.com/t/need-help-dealing-with-a-sneaky-script-virus-of-hd-admin/3976582)
- [DevForum: Man made 200k+ Robux with this malicious script](https://devforum.roblox.com/t/this-man-has-made-over-200k-robux-by-making-this-malicious-script-that-inserts-a-fake-50r-admin-command-into-infected-games/655024)

**Características deste malware:**
- Cria prompt falso para comprar "admin powers" (geralmente 50-200 robux)
- É inserido por free models da Toolbox do Roblox
- Se disfarça como "HD Admin" legítimo
- É inserido apenas quando o jogo roda (não aparece no Explorer quando parado)
- O criador do malware já faturou mais de 200k robux com vítimas

---

## 🎯 ESTRATÉGIA DE DETECÇÃO

Como o malware só aparece durante runtime, precisamos usar técnicas especiais:

### MÉTODO 1: Detector de Runtime (MAIS EFICAZ)

Este método detecta scripts que são inseridos quando você clica "Play":

1. **Abra build.rbxl no Studio**
2. **NÃO clique em Play ainda**
3. **Abra o Command Bar** (View > Command Bar)
4. **Copie TODO o conteúdo** de `DETECT_RUNTIME_INJECTION.lua`
5. **Cole no Command Bar** e pressione Enter
6. **Aguarde a mensagem:** "✅ Runtime monitoring is now ACTIVE!"
7. **Agora clique em PLAY**
8. **OBSERVE O OUTPUT** - se um script for inserido, você verá:
   ```
   🚨 NEW SCRIPT INSERTED DURING RUNTIME!
   ```
9. **Se detectar um script suspeito**, você verá o código completo dele
10. **Navegue até o script** usando o caminho mostrado
11. **DELETE o script imediatamente**
12. **Pare o jogo** e **encontre o que está inserindo ele** (veja abaixo)

### MÉTODO 2: Busca por require() Externos

Backdoors frequentemente usam `require()` para carregar código malicioso:

1. **Abra build.rbxl no Studio** (com jogo PARADO)
2. **Rode `FIND_REQUIRE_BACKDOORS.lua`** no Command Bar
3. Se encontrar `require(NÚMERO)`, investigue esse script
4. Delete qualquer `require()` de asset IDs que você não reconhece

### MÉTODO 3: Busca Manual (Ctrl+Shift+F)

1. **No Studio, pressione Ctrl+Shift+F** (busca global)
2. **Procure por:**
   - `55` (vai encontrar muitas coisas, mas foque em contexto de robux)
   - `PromptProductPurchase`
   - `HD Admin` ou `HDAdmin`
   - `Owner Rank`
   - `require(`
3. **Para cada resultado**, veja se o código parece suspeito

---

## 🔨 FONTES COMUNS DO MALWARE

O malware geralmente vem de:

### 1. Free Models da Toolbox
- **Como verificar:** Você inseriu algum modelo da Toolbox recentemente?
- **Solução:** Delete TODOS os free models
- **Alternativa:** Apenas use modelos de criadores verificados

### 2. Scripts com require() Externo
- **Como verificar:** Rode `FIND_REQUIRE_BACKDOORS.lua`
- **Solução:** Delete scripts com `require(assetId)`

### 3. HttpService Malicioso
- **Como verificar:** Busque por `HttpService:GetAsync` ou `HttpService:PostAsync`
- **Solução:** Verifique se algum script baixa e executa código externo

### 4. Scripts em Locais Estranhos
- **Como verificar:** Procure scripts em:
  - Workspace (não deveria ter scripts de servidor aqui)
  - Lighting (nunca deveria ter scripts)
  - SoundService (raramente tem scripts)
- **Solução:** Delete todos esses scripts

---

## ✅ PLANO DE AÇÃO DEFINITIVO

### PASSO 1: Detectar o Malware

Execute `DETECT_RUNTIME_INJECTION.lua` e identifique qual script está sendo inserido.

### PASSO 2: Encontrar a Fonte

Depois de identificar o script malicioso, procure por:

**A) Scripts que o inserem:**
```lua
-- Padrões comuns em loaders de backdoor:
Instance.new("Script")
game:GetService("InsertService")
require(NUMERO)
loadstring(CÓDIGO)
```

**B) Free models suspeitos:**
- Vá em cada modelo do Workspace
- Expanda ele no Explorer
- Procure por scripts escondidos dentro
- Delete o modelo completo se encontrar algo suspeito

**C) Scripts em ServerScriptService:**
- Verifique TODOS os scripts
- Compare com seu código fonte do Rojo
- Se encontrar um script que NÃO está no Rojo, DELETE

### PASSO 3: Remover COMPLETAMENTE

1. **Delete o script malicioso** detectado
2. **Delete a FONTE** (free model, script loader, etc)
3. **Save o jogo**
4. **Feche o Studio**
5. **Reabra e teste novamente**

### PASSO 4: Prevenir Reinfecção

1. **NÃO use free models** sem inspeção completa
2. **Evite require() externos** (use ModuleScripts locais)
3. **Mantenha tudo no Rojo** - se não está no código fonte, não deveria estar no jogo
4. **Execute scanners mensalmente**

---

## 🆘 SE AINDA APARECER

Se mesmo após seguir TODOS os passos o prompt ainda aparecer:

### Opção 1: Rebuild Completo do Zero

```bash
# Delete TUDO
rm build.rbxl
rm -rf build/

# Rebuild do zero
rojo build -o build.rbxl

# Abra NO STUDIO
# NÃO insira NADA manualmente
# Apenas teste se o jogo funciona básico
```

### Opção 2: Verificar Jogo Publicado

O malware pode estar no jogo publicado no Roblox:

1. Vá em https://create.roblox.com/dashboard/creations
2. Selecione seu jogo
3. Clique em "Edit" para baixar a versão publicada
4. Verifique se ela tem o malware
5. Se sim, publique a versão limpa do Studio

### Opção 3: Verificar Developer Products

1. Vá em https://create.roblox.com/dashboard/creations
2. Selecione seu jogo
3. Vá em "Monetization" > "Developer Products"
4. **Verifique se há um produto de 55 robux** que você NÃO criou
5. **DELETE qualquer produto suspeito**

---

## 📊 CHECKLIST FINAL

Use esta lista para garantir que fez tudo:

- [ ] Executei `verify-source-clean.sh` - código fonte está limpo
- [ ] Executei `FIND_PLUGIN_MALWARE.sh` - apenas RojoManagedPlugin
- [ ] Executei `DETECT_RUNTIME_INJECTION.lua` no Studio
- [ ] Cliquei em Play e observei o Output
- [ ] Identifiquei qual script está sendo inserido (se algum)
- [ ] Encontrei a FONTE que está inserindo o script
- [ ] Deletei o script malicioso E a fonte
- [ ] Executei `FIND_REQUIRE_BACKDOORS.lua` - nenhum require externo
- [ ] Verifiquei free models no Workspace - deletei os suspeitos
- [ ] Salvei o jogo e reiniciei o Studio
- [ ] Testei novamente - prompt NÃO aparece mais
- [ ] Verifiquei developer products no dashboard
- [ ] Publiquei a versão limpa para o Roblox

---

## 💡 DICAS IMPORTANTES

1. **Seja paciente** - pode levar várias tentativas para encontrar a fonte
2. **Delete tudo suspeito** - melhor deletar demais que de menos
3. **Use apenas Rojo** - evite adicionar coisas direto no Studio
4. **Quando em dúvida, rebuild** - o código fonte está limpo, então é seguro

---

## 🔗 RECURSOS ADICIONAIS

- [Roblox DevForum: Guide to securing your game](https://devforum.roblox.com/t/a-beginners-guide-to-securing-your-game-from-virusesbackdoors-and-more/1189874)
- [How to remove backdoors from your game](https://devforum.roblox.com/t/how-to-remove-backdoors-from-your-game/511548)
- [Detecting and Tracing Backdoors via Runtime Debugging](https://devforum.roblox.com/t/detecting-and-tracing-backdoors-via-runtime-debugging/3693872)

---

**Boa sorte! Se precisar de ajuda específica durante o processo, avise!**
