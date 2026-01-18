# Relatório de Correções - Sincronização Rojo

**Data:** 2026-01-18
**Projeto:** speed-dash
**Arquivo de Configuração:** default.project.json

---

## Resumo Executivo

Este relatório documenta as correções aplicadas para resolver inconsistências entre a configuração do Rojo e a estrutura do projeto no Roblox Studio. Todas as mudanças foram validadas com `rojo build` sem erros.

---

## Problemas Corrigidos

### 1. ✅ Módulos Admin Faltando no Mapeamento

**Problema:** 3 módulos existentes em `src/server/modules/` não estavam mapeados no default.project.json.

**Arquivos Afetados:**
- AdminConfig.lua
- AdminControlFunctions.lua
- AdminSecurity.lua

**Solução Aplicada:**
Adicionados os 3 módulos na seção `ServerScriptService.Modules` do default.project.json (linhas 91-99).

**Localização no Código:**
```json
"Modules": {
  "$className": "Folder",
  "TreadmillConfig": {
    "$path": "src/server/modules/TreadmillConfig.lua"
  },
  "TreadmillRegistry": {
    "$path": "src/server/modules/TreadmillRegistry.lua"
  },
  "AdminConfig": {
    "$path": "src/server/modules/AdminConfig.lua"
  },
  "AdminControlFunctions": {
    "$path": "src/server/modules/AdminControlFunctions.lua"
  },
  "AdminSecurity": {
    "$path": "src/server/modules/AdminSecurity.lua"
  }
}
```

---

### 2. ✅ RollingBallController sem Propriedade Disabled Explícita

**Problema:** O script aparecia "grayed out" no Studio, mas não tinha a propriedade `Disabled: true` definida explicitamente no default.project.json.

**Análise:** O script procura por objetos específicos no Workspace (sphere1, sphere2, BallRollPart1, BallRollPart2) que não existem no mapa atual, fazendo um early return. O script está funcionalmente desabilitado, mas isso não estava documentado na configuração.

**Solução Aplicada:**
Adicionada propriedade `Disabled: true` explicitamente ao RollingBallController (linhas 55-60).

**Localização no Código:**
```json
"RollingBallController": {
  "$path": "src/server/RollingBallController.server.lua",
  "$properties": {
    "Disabled": true
  }
}
```

---

## Ferramentas Diagnósticas Criadas

### 3. ✅ Script FIND_DUPLICATE_SCRIPTS.lua

**Propósito:** Identificar duplicações e scripts não gerenciados pelo Rojo em StarterPlayerScripts.

**Uso:**
1. Abrir o Roblox Studio
2. Abrir a aba Output (View → Output)
3. Colar o conteúdo de `FIND_DUPLICATE_SCRIPTS.lua` no console
4. Executar (Enter)

**Funcionalidades:**
- Lista TODOS os scripts em StarterPlayerScripts
- Identifica duplicações por nome
- Compara com scripts esperados do Rojo (src/client/)
- Detecta scripts criados diretamente no Studio (não gerenciados pelo Rojo)
- Mostra hierarquia completa
- Fornece recomendações de correção

**Scripts Esperados do Rojo:**
- ClientBootstrap
- DebugLogExporter
- DiagnosticClient
- TestClient
- UIHandler

---

## Problemas Identificados mas NÃO Corrigidos

### 4. ⚠️ StarterGui.rbxm - Arquivo Não Mapeável

**Problema:** O arquivo `src/ui/StarterGui.rbxm` existe no projeto mas não está mapeado no default.project.json.

**Causa Raiz:** O arquivo contém múltiplas instâncias top-level, e o Rojo atualmente **não suporta** arquivos .rbxm com múltiplas instâncias.

**Erro do Rojo:**
```
[ERROR rojo] Rojo currently only supports model files with one top-level instance.
Check the model file at path /Users/lucassampaio/Projects/speed-dash/src/ui/StarterGui.rbxm
```

**Soluções Possíveis:**

#### Opção 1: Dividir em Múltiplos Arquivos (Recomendado)
Dividir StarterGui.rbxm em múltiplos arquivos .rbxm, cada um com uma única instância top-level:
```
src/ui/
  ├── SpeedDisplay.rbxm
  ├── LeaderboardUI.rbxm
  └── ShopUI.rbxm
```

Depois mapear no default.project.json:
```json
"StarterGui": {
  "$className": "StarterGui",
  "SpeedDisplay": {
    "$path": "src/ui/SpeedDisplay.rbxm"
  },
  "LeaderboardUI": {
    "$path": "src/ui/LeaderboardUI.rbxm"
  },
  "ShopUI": {
    "$path": "src/ui/ShopUI.rbxm"
  }
}
```

#### Opção 2: Converter para Estrutura de Arquivos Lua
Converter os elementos de UI para estrutura de pastas/scripts Lua ao invés de arquivo binário .rbxm.

#### Opção 3: Carregar Manualmente no Studio
Manter o arquivo .rbxm fora do controle do Rojo e carregar manualmente no Studio quando necessário.

**Status:** PENDENTE DE DECISÃO DO DESENVOLVEDOR

---

### 5. ⚠️ Duplicação de StarterPlayerScripts (INVESTIGAÇÃO NECESSÁRIA)

**Problema Reportado:** Aparecem DUAS pastas StarterPlayerScripts dentro de StarterPlayer no Explorer do Studio, com conteúdos diferentes/sobrepostos.

**Ferramenta para Diagnóstico:** Use o script `FIND_DUPLICATE_SCRIPTS.lua` (criado neste processo) para investigar.

**Possível Causa:** Scripts criados diretamente no Studio que não estão no repositório. Esses scripts não são gerenciados pelo Rojo e serão perdidos na próxima sincronização.

**Status:** REQUER EXECUÇÃO DO SCRIPT DIAGNÓSTICO NO STUDIO

---

## Estrutura de Diretórios Verificada

### Arquivos e Pastas no Projeto:

```
src/
├── client/                          [✅ MAPEADO]
│   ├── ClientBootstrap.client.lua
│   ├── DebugLogExporter.client.lua
│   ├── DiagnosticClient.client.lua
│   ├── TestClient.client.lua
│   └── UIHandler.client.lua
│
├── server/                          [✅ MAPEADO]
│   ├── modules/
│   │   ├── AdminConfig.lua         [✅ CORRIGIDO]
│   │   ├── AdminControlFunctions.lua [✅ CORRIGIDO]
│   │   ├── AdminSecurity.lua       [✅ CORRIGIDO]
│   │   ├── TreadmillConfig.lua     [✅ JÁ MAPEADO]
│   │   └── TreadmillRegistry.lua   [✅ JÁ MAPEADO]
│   ├── DataStore2.rbxm             [✅ MAPEADO]
│   └── [múltiplos scripts .server.lua...]
│
├── storage/                         [✅ MAPEADO]
│   └── templates/
│       └── TreadmillZoneHandler.lua
│
├── shared/                          [✅ MAPEADO]
│
└── ui/
    └── StarterGui.rbxm              [❌ NÃO MAPEÁVEL - Ver Problema #4]
```

---

## Validação Final

### Build do Rojo: ✅ SUCESSO

```bash
$ rojo build default.project.json --output test-build.rbxl
Building project 'speed-dash-rojo'
Built project to test-build.rbxl
```

Todas as mudanças aplicadas foram validadas com sucesso. O projeto agora compila sem erros.

---

## Próximos Passos Recomendados

1. **IMEDIATO:** Execute `FIND_DUPLICATE_SCRIPTS.lua` no Studio para investigar duplicações em StarterPlayerScripts

2. **CURTO PRAZO:** Decida como lidar com StarterGui.rbxm:
   - Dividir em múltiplos arquivos .rbxm (recomendado)
   - Converter para estrutura Lua
   - Manter fora do controle do Rojo

3. **VALIDAÇÃO:** Execute `rojo serve` e sincronize no Studio para confirmar que todas as mudanças foram aplicadas corretamente

4. **LIMPEZA:** Se encontrar scripts duplicados ou não gerenciados no Studio, remova-os para evitar confusão

---

## Arquivos Modificados

1. **default.project.json**
   - Linhas 91-99: Adicionados AdminConfig, AdminControlFunctions, AdminSecurity
   - Linhas 55-60: Adicionada propriedade Disabled ao RollingBallController

2. **FIND_DUPLICATE_SCRIPTS.lua** (NOVO)
   - Script diagnóstico para identificar problemas em StarterPlayerScripts

3. **ROJO_SYNC_CORRECTIONS_REPORT.md** (ESTE ARQUIVO)
   - Documentação completa das correções aplicadas

---

## Referências

- **Rojo Documentation:** https://rojo.space/docs/
- **Issue Tracker:** https://github.com/rojo-rbx/rojo/issues
- **Modelo de Referência:** WHERE_IS_LAVA.lua (usado como base para FIND_DUPLICATE_SCRIPTS.lua)

---

**Fim do Relatório**
