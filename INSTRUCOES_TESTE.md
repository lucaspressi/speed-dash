# 🚨 INSTRUÇÕES PARA TESTAR COM ROJO SERVE

## Passo 1: Inicie o Rojo Server

No terminal, rode:
```bash
cd /Users/lucassampaio/Projects/speed-dash
rojo serve
```

Você verá algo como:
```
Rojo server listening on port 34872
```

## Passo 2: Conecte o Roblox Studio

1. Abra **QUALQUER place** no Roblox Studio (pode até criar um novo)
2. Procure o plugin **Rojo** na barra superior
3. Clique no plugin Rojo
4. Clique em **"Connect"**
5. O Studio vai sincronizar com seu código automaticamente!

## Passo 3: Aperte F5 (Play)

1. **Aperte F5** (ou clique no botão verde ▶️ PLAY)
   - ❌ NÃO use F6 (Run)
   - ✅ USE F5 (Play)
2. Espere o player spawnar

## Passo 4: Verifique os Logs

Você DEVE ver esta mensagem no **SERVER log**:
```
[SERVER] 🎉 RECEBEU MENSAGEM DO CLIENT! 🎉
[SERVER] Player: SeuNome
[SERVER] Mensagem: CLIENT IS ALIVE!
```

Se ver essa mensagem = **TUDO FUNCIONANDO!** 🎉

Se NÃO ver = Me avise!
