# 🐛 Debug Checklist - Audio & Animations Not Working

## Problema Atual:
- ❌ Música de fundo não toca
- ❌ Vine Boom não toca
- ❌ NPC não dança
- ❌ NPC não medita

## Causa Identificada:
**O script do CLIENT não está rodando!**

## Como Verificar:

### 1. Abra o Output no Studio
- Menu: View → Output (ou Ctrl+Alt+M)

### 2. Veja se há 2 ABAS no Output:
```
[Server] [Client] [Log]
   ↑        ↑
```

### 3. Clique na aba "Client"

### 4. Procure por estes logs:
```
[CLIENT] ==================== LocalScript.lua STARTING ====================
[CLIENT] LocalScript.lua loaded! Player: Xxpress1xX
[CLIENT] ✅ CHECKPOINT 1: Services and player loaded
[CLIENT] ✅ CHECKPOINT 2: Basic sounds created
[CLIENT] 🎵 Background music created: rbxassetid://1837879082
```

## Se NÃO aparecer nada na aba Client:

### Opção A: O script não está no lugar certo
Verifique se existe:
```
StarterPlayer
  └─ StarterPlayerScripts
      └─ Client (LocalScript)
```

### Opção B: Há um erro impedindo o script
- Veja se há mensagens de ERRO em vermelho na aba Client
- Copie e cole aqui para eu analisar

### Opção C: Você está testando sem player
- Certifique-se de apertar **F5** (Play) e não F6 (Run)
- O player precisa spawnar para o LocalScript rodar

## Outros problemas identificados:

### 1. Buff Noob (NPC) não existe
```
Infinite yield possible on 'Workspace:WaitForChild("Buff Noob")'
```

**Solução**: 
- O NPC precisa existir no Workspace com o nome exato "Buff Noob"
- OU você precisa comentar o script NoobNpcAI.server.lua

### 2. sphere1 não existe
```
Infinite yield possible on 'Workspace:WaitForChild("sphere1")'
```

**Solução**:
- Comente ou delete o script RollingBallController.server.lua

## Próximos Passos:

1. **OLHE A ABA CLIENT DO OUTPUT**
2. **Me mostre o que aparece lá** (tire print ou copie)
3. Se não aparecer NADA, me avise
4. Se aparecer ERRO em vermelho, me mostre o erro

