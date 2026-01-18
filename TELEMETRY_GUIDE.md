# 📊 Guia de Telemetria - Sistema de Logs Automático

## 🎯 O que é?

Sistema que **envia automaticamente** logs do Roblox para seu backend, para você consultar depois sem precisar ficar enviando prints.

---

## 🚀 Como Usar

### **1. Iniciar o Backend**

No terminal (na pasta do projeto):

```bash
cd dashboard-backend
npm install  # Primeira vez apenas
npm run dev  # Inicia o servidor
```

Você verá:
```
Server: http://localhost:3001
✅ Telemetry will be sent to backend
```

### **2. Configurar Roblox**

No **Roblox Studio**:

1. **Game Settings (Alt+S)** > **Security** > **Allow HTTP Requests** ✅ (marcar)
2. Salve e Publique

### **3. Logs Automáticos**

Quando jogadores entrarem no jogo, logs serão enviados automaticamente!

---

## 📡 APIs Disponíveis

### **Ver todos os logs**
```bash
curl http://localhost:3001/api/telemetry/logs
```

### **Ver apenas erros**
```bash
curl "http://localhost:3001/api/telemetry/logs?level=error"
```

### **Ver logs de uma categoria específica**
```bash
curl "http://localhost:3001/api/telemetry/logs?category=Leaderstats"
```

### **Ver resumo estatístico**
```bash
curl http://localhost:3001/api/telemetry/summary
```

### **Status do sistema**
```bash
curl http://localhost:3001/api/telemetry/health
```

---

## 🔍 Como Ver os Logs

### **Opção 1: No Terminal**

```bash
# Ver últimos 10 logs
curl http://localhost:3001/api/telemetry/logs?limit=10 | json_pp

# Ver apenas erros
curl "http://localhost:3001/api/telemetry/logs?level=error" | json_pp

# Ver logs de uma categoria
curl "http://localhost:3001/api/telemetry/logs?category=TreadmillService" | json_pp
```

### **Opção 2: No Navegador**

Abra no navegador:
```
http://localhost:3001/api/telemetry/logs
http://localhost:3001/api/telemetry/summary
```

### **Opção 3: Arquivo JSON**

Logs são salvos automaticamente em:
```
dashboard-backend/logs/telemetry-YYYY-MM-DD.json
```

Você pode abrir direto no VS Code ou qualquer editor!

---

## 📝 Como Adicionar Logs nos Seus Scripts

### **No Servidor (Lua)**

```lua
-- No topo do seu script
local TelemetryService = _G.TelemetryService

-- Logs de informação
TelemetryService.info("Categoria", "Mensagem", {
    dados = "contexto adicional"
})

-- Avisos
TelemetryService.warn("Sistema", "Algo suspeito aconteceu", {
    valor = 123
})

-- Erros
TelemetryService.error("Lava", "Falha ao ativar lava", {
    lavaCount = 0
})

-- Debug (detalhes técnicos)
TelemetryService.debug("Performance", "Loop demorou", {
    duration = 0.5
})
```

### **Exemplo Prático**

```lua
-- Em LavaKill.server.lua
local TelemetryService = _G.TelemetryService

local lavaCount = 0
for _, obj in pairs(workspace:GetDescendants()) do
    if obj.Name == "Lava" then
        lavaCount = lavaCount + 1
    end
end

if lavaCount == 0 then
    TelemetryService.error("LavaKill", "No lava parts found in workspace", {
        searchedObjects = #workspace:GetDescendants()
    })
else
    TelemetryService.info("LavaKill", "Activated lava kill system", {
        lavaCount = lavaCount
    })
end
```

---

## 🎨 Níveis de Log

| Nível   | Quando usar                                      |
|---------|--------------------------------------------------|
| `info`  | Eventos normais (servidor iniciou, sistema OK)   |
| `warn`  | Algo suspeito mas não crítico                    |
| `error` | Problema que impede funcionalidade               |
| `debug` | Informações técnicas detalhadas                  |

---

## 📊 Exemplo de Saída

```json
{
  "success": true,
  "count": 3,
  "logs": [
    {
      "timestamp": 1705598400000,
      "level": "error",
      "category": "Leaderstats",
      "message": "Player has no leaderstats folder",
      "context": {
        "playerName": "Xxpress1xX",
        "userId": 123456
      },
      "serverId": "abc12345",
      "placeId": 987654321,
      "jobId": "abc12345-def67890"
    },
    {
      "timestamp": 1705598350000,
      "level": "info",
      "category": "Server",
      "message": "Server started",
      "context": {
        "playerCount": 1
      },
      "serverId": "abc12345",
      "placeId": 987654321,
      "jobId": "abc12345-def67890"
    }
  ]
}
```

---

## 🔧 Troubleshooting

### **Logs não aparecem**

1. **Backend está rodando?**
   ```bash
   curl http://localhost:3001/health
   ```
   Se der erro, inicie o backend: `cd dashboard-backend && npm run dev`

2. **HTTP Requests habilitado no Roblox?**
   - Game Settings > Security > Allow HTTP Requests ✅

3. **Publicou o jogo depois do sync?**
   - TelemetryService só funciona em produção (não Studio)

### **Erro "HttpService is not allowed"**

Você esqueceu de habilitar HTTP Requests no Game Settings.

### **Logs antigos sumindo**

Normal! O sistema mantém apenas os últimos 10 arquivos de log para economizar espaço.

---

## 🎯 Casos de Uso

### **Debugar problema em produção**

```bash
# Ver erros das últimas 24 horas
curl "http://localhost:3001/api/telemetry/logs?level=error&limit=100"
```

### **Monitorar sistema específico**

```bash
# Ver logs do TreadmillService
curl "http://localhost:3001/api/telemetry/logs?category=Treadmill"
```

### **Ver estatísticas gerais**

```bash
curl http://localhost:3001/api/telemetry/summary
```

Mostra:
- Total de logs
- Erros vs warnings vs info
- Logs por categoria
- Últimos 10 erros

---

## 💡 Dicas

1. **Sempre inicie o backend antes de testar** em produção
2. **Logs são salvos em arquivo** - você pode acessar mesmo depois de parar o backend
3. **Use categorias consistentes** - facilita filtrar depois
4. **Adicione contexto** - dados adicionais ajudam no debug

---

## ✅ Checklist

- [ ] Backend instalado: `cd dashboard-backend && npm install`
- [ ] Backend rodando: `npm run dev`
- [ ] HTTP Requests habilitado no Roblox
- [ ] TelemetryService sincronizado via Rojo
- [ ] Publicou o jogo
- [ ] Testou em produção (não Studio)
- [ ] Consegue ver logs: `curl http://localhost:3001/api/telemetry/logs`

---

**Pronto!** Agora você tem logs automáticos sem precisar ficar enviando prints! 🚀
