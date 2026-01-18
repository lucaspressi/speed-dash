# Rojo Workflow - Speed Dash

## ⚠️ REGRA FUNDAMENTAL

**O Rojo é a fonte da verdade.** Mudanças feitas no Roblox Studio serão **sobrescritas** quando você der Stop/Play ou quando o Rojo sincronizar.

### ❌ NÃO FAÇA NO STUDIO:
- Renomear objetos gerenciados pelo Rojo
- Adicionar/remover objetos na hierarquia
- Modificar propriedades de objetos no Workspace

### ✅ FAÇA NO REPOSITÓRIO:
- Edite `default.project.json` para mudanças de hierarquia/propriedades
- Edite arquivos `.lua` para código
- Commit e push suas mudanças

---

## 🏟️ NoobArena - Configuração

### Estrutura no Repositório

No arquivo `default.project.json`, a arena do NPC está definida assim:

```json
"NoobArena": {
  "$className": "Model",
  "ArenaBounds": {
    "$className": "Part",
    "$properties": {
      "Anchored": true,
      "CanCollide": false,
      "Color": [1, 0, 0],
      "Position": [0, 20, 100],
      "Size": [80, 40, 80],
      "Transparency": 0.8,
      "Name": "ArenaBounds"
    }
  }
}
```

### Como o Script do NPC Funciona

O script `NoobNpcAI.server.lua` procura:

1. **Model** chamado `NoobArena` no Workspace
2. **Part** chamado `ArenaBounds` dentro do Model

```lua
local arenaModel = workspace:WaitForChild("NoobArena", 5)
local arena = arenaModel:FindFirstChild("ArenaBounds")
```

### Como Ajustar a Arena

#### Opção 1: Editar default.project.json (Recomendado)

1. Abra `default.project.json`
2. Encontre a seção `"NoobArena"` dentro de `"Workspace"`
3. Modifique as propriedades de `"ArenaBounds"`:
   - `Position`: Centro da arena `[X, Y, Z]`
   - `Size`: Dimensões da arena `[Largura, Altura, Profundidade]`
   - `Color`: Cor RGB normalizada `[R, G, B]` (0-1)
   - `Transparency`: 0 (opaco) a 1 (invisível)
4. Salve o arquivo
5. Execute `rojo serve` (se ainda não estiver rodando)
6. No Studio: Stop/Play para aplicar mudanças

#### Opção 2: Adicionar Mais Parts na Arena

Se você quiser adicionar floors, walls, ou outras parts, edite `default.project.json`:

```json
"NoobArena": {
  "$className": "Model",
  "ArenaBounds": {
    "$className": "Part",
    "$properties": {
      "Anchored": true,
      "CanCollide": false,
      "Color": [1, 0, 0],
      "Position": [0, 20, 100],
      "Size": [80, 40, 80],
      "Transparency": 0.8,
      "Name": "ArenaBounds"
    }
  },
  "Floor": {
    "$className": "Part",
    "$properties": {
      "Anchored": true,
      "CanCollide": true,
      "Color": [0.5, 0.5, 0.5],
      "Position": [0, 0, 100],
      "Size": [80, 1, 80],
      "Transparency": 0
    }
  }
}
```

---

## 🔧 Comandos Rojo

### Desenvolvimento Normal

```bash
# Inicia servidor Rojo (mantém sincronização em tempo real)
rojo serve

# No Roblox Studio: Plugins > Rojo > Connect
# Deixe rodando enquanto desenvolve
```

### Build para Publicação

```bash
# Gera arquivo .rbxl para upload no Roblox
rojo build -o speed-dash.rbxl

# Upload manual no Roblox.com ou via rojo upload (requer API key)
```

### Verificar Configuração

```bash
# Valida o default.project.json (útil após edições)
rojo build --output /dev/null
# Se não houver erros, a configuração está válida
```

---

## 🐛 Diagnósticos do NPC

O script do NPC adiciona atributos ao Workspace para diagnóstico:

```lua
-- Verifique no Studio: Properties > Workspace > Attributes
workspace:GetAttribute("NoobNpcAI_Running")    -- true se o script iniciou
workspace:GetAttribute("NoobNpcAI_ArenaPart")  -- Path completo da arena
```

### Logs Esperados

Se tudo estiver correto:

```
[NoobAI] ✅ Found NPC and parts
[NoobAI] ✅ Found NoobArena model (ClassName: Model)
[NoobAI] ✅ Arena bounds found at: Vector3
[NoobAI] ✅ Arena size: Vector3
```

Se algo estiver errado:

```
[NoobAI] ❌ 'NoobArena' Model not found in Workspace!
[NoobAI] This should be managed by Rojo in default.project.json
```

ou

```
[NoobAI] ❌ 'ArenaBounds' Part not found inside NoobArena Model!
[NoobAI] Children found in NoobArena:
[NoobAI]   - NoobArena (Part)  <-- Nome errado!
```

---

## 📝 Exemplo de Workflow Completo

### Cenário: Quero mover a arena do NPC

1. **Pare o jogo** no Studio (não tente mover no Play Mode)

2. **Edite `default.project.json`**:
   ```json
   "Position": [100, 20, 200],  // Nova posição
   "Size": [100, 50, 100],      // Novo tamanho
   ```

3. **Salve o arquivo**

4. **No Studio**: Se `rojo serve` está rodando, clique em **Sync** no plugin Rojo
   - Ou: Stop/Play para forçar sincronização

5. **Verifique**: A arena deve aparecer na nova posição

6. **Commit suas mudanças**:
   ```bash
   git add default.project.json
   git commit -m "feat: Move NoobArena to new position"
   git push
   ```

### Cenário: Adicionei algo no Studio por engano

Se você criou/renomeou algo no Studio e o Rojo sobrescreveu:

1. **Não entre em pânico** - suas mudanças no repo estão salvas
2. **Edite `default.project.json`** com as mudanças desejadas
3. **Sync/Stop+Play** para aplicar

---

## 🎯 Resumo

| Ação | Onde Fazer | Como Aplicar |
|------|-----------|--------------|
| Mudar posição da arena | `default.project.json` | Sync ou Stop+Play |
| Ajustar tamanho da arena | `default.project.json` | Sync ou Stop+Play |
| Adicionar parts na arena | `default.project.json` | Sync ou Stop+Play |
| Modificar código do NPC | `src/server/NoobNpcAI.server.lua` | Sync ou Stop+Play |
| Adicionar novo script | `default.project.json` + criar arquivo `.lua` | Sync ou Stop+Play |

**Lembre-se**: Sempre edite no repositório, nunca no Studio!

---

## 🆘 Problemas Comuns

### "ArenaBounds não encontrado"

**Causa**: O nome foi mudado no Studio

**Solução**:
1. Verifique `default.project.json` - deve ter `"Name": "ArenaBounds"`
2. Stop+Play para Rojo sobrescrever
3. Se persistir, delete NoobArena no Studio manualmente e Stop+Play

### "NoobArena é uma Part, não um Model"

**Causa**: Objeto antigo no Studio com nome conflitante

**Solução**:
1. Delete manualmente NoobArena no Studio
2. Stop+Play para Rojo criar o correto

### "Mudanças no Studio desaparecem"

**Causa**: Comportamento esperado do Rojo

**Solução**: Faça mudanças no repositório, não no Studio

---

## 📚 Referências

- [Documentação Oficial do Rojo](https://rojo.space/docs/)
- [Formato do Project File](https://rojo.space/docs/v7/project-format/)
- [Sync Details](https://rojo.space/docs/v7/sync-details/)
