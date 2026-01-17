# 🚀 Como Testar no Studio

## ⚠️ IMPORTANTE: Use Rojo para testar!

O arquivo `build.rbxl` pode estar desatualizado. Para testar as **últimas alterações**, use Rojo:

### Opção 1: Rojo Serve (Recomendado)

```bash
# 1. Inicie o servidor Rojo
rojo serve

# 2. No Roblox Studio:
#    - Abra qualquer place
#    - Clique no plugin "Rojo"
#    - Clique em "Connect"
#    - Os scripts serão sincronizados automaticamente!
```

### Opção 2: Build Manual

```bash
# Gera um novo build.rbxl com as últimas mudanças
rojo build -o build.rbxl

# Depois abra build.rbxl no Studio
```

---

## 🎵 Features Adicionadas (Última Atualização)

### Áudio:
- ✅ Música de fundo (chill music loop)
- ✅ Vine Boom ao morrer pelo NPC
- ✅ Efeito visual vermelho ao ser atingido pelo laser

### NPC AI:
- ✅ Laser deixa player lento (20% velocidade) ao invés de matar
- ✅ Dança aleatória após matar (8 danças diferentes)
- ✅ Meditação quando idle (sem players por perto)

---

## 🐛 Debug

Se nada funcionar, procure por estes logs no **Output**:

### Client Tab:
```
[CLIENT] ✅ CHECKPOINT 1: Services and player loaded
[CLIENT] ✅ CHECKPOINT 2: Basic sounds created
[CLIENT] 🎵 Background music created: rbxassetid://...
[CLIENT] 🔊 NPC kill sound created: rbxassetid://...
```

### Server Tab:
```
[NoobAI] Stage2 center: ...
[NoobAI] 🧘 Starting meditation...
[NoobAI] 💃 STARTING VICTORY TAUNT!
```

Se **NÃO ver** esses logs, significa que:
1. Você está testando build.rbxl desatualizado (use Rojo serve!)
2. Há um erro impedindo o script de rodar

---

## 📝 Comandos Úteis

```bash
# Ver status do git
git status

# Ver logs recentes
git log --oneline -5

# Iniciar Rojo (sincronização automática)
rojo serve

# Rebuild (gera novo build.rbxl)
rojo build -o build.rbxl
```
