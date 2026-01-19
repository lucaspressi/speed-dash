# NPC Attributes - Custom Configuration

## Como configurar a velocidade e comportamento do NPC

O NPC "Buff Noob" agora pode ser customizado **diretamente no Studio** usando **Attributes**, sem precisar editar código!

### Attributes Disponíveis

| Attribute Name | Type | Default | Description |
|---------------|------|---------|-------------|
| `ChaseSpeed` | Number | 120 | Velocidade ao perseguir jogador (studs/segundo) |
| `IdleSpeed` | Number | 16 | Velocidade ao vagar (não usado atualmente) |
| `DetectionRange` | Number | 200 | Distância máxima para detectar jogadores |

---

## Como Usar

### Passo 1: Selecione o NPC no Workspace

1. Abra o Roblox Studio
2. No **Explorer**, navegue para `Workspace > Buff Noob`
3. Clique no modelo "Buff Noob" para selecioná-lo

### Passo 2: Adicione Attributes

1. No painel **Properties**, role até a seção **Attributes**
2. Clique no botão **"+"** para adicionar um novo Attribute
3. Configure o nome e valor:

**Exemplo 1 - NPC Lento (para iniciantes):**
```
Name: ChaseSpeed
Type: Number
Value: 60
```

**Exemplo 2 - NPC Normal (padrão):**
```
Name: ChaseSpeed
Type: Number
Value: 120
```

**Exemplo 3 - NPC Muito Rápido (dificuldade alta):**
```
Name: ChaseSpeed
Type: Number
Value: 200
```

**Exemplo 4 - NPC com detecção maior:**
```
Name: DetectionRange
Type: Number
Value: 300
```

### Passo 3: Stop + Play

1. Pare o jogo (Stop)
2. Inicie novamente (Play)
3. Veja no Output:
   ```
   [NoobAI] ⚙️ Configuration:
   [NoobAI]   Chase Speed: 60 (custom)
   ```

---

## Exemplos de Configuração

### Arena para Iniciantes
```
ChaseSpeed = 50
DetectionRange = 150
```
**Resultado:** NPC lento e não detecta de muito longe

### Arena Normal
```
ChaseSpeed = 120
DetectionRange = 200
```
**Resultado:** Configuração padrão, balanceada

### Arena Pesadelo
```
ChaseSpeed = 250
DetectionRange = 300
```
**Resultado:** NPC extremamente rápido e detecta de longe

---

## Múltiplos NPCs com Velocidades Diferentes

Você pode ter vários NPCs na mesma arena com velocidades diferentes:

1. **Crie cópias do NPC:**
   - Duplique "Buff Noob" no Workspace
   - Renomeie cada cópia (ex: "Buff Noob Slow", "Buff Noob Fast")

2. **Configure Attributes diferentes:**
   - "Buff Noob Slow" → `ChaseSpeed = 60`
   - "Buff Noob Fast" → `ChaseSpeed = 180`

3. **Atualize NoobNpcAI.server.lua** para detectar múltiplos NPCs:
   ```lua
   -- Em vez de:
   local noob = workspace:WaitForChild("Buff Noob", 5)

   -- Use:
   for _, model in pairs(workspace:GetChildren()) do
       if model.Name:match("Buff Noob") and model:IsA("Model") then
           -- Inicializar NPC
       end
   end
   ```

---

## Dicas

### Velocidades Recomendadas

- **50-80**: Muito lento (fácil de escapar)
- **100-120**: Normal (balanceado)
- **150-180**: Rápido (difícil)
- **200+**: Muito rápido (nextbot extremo)

### Testando Velocidades

Para testar rapidamente diferentes velocidades:

1. No Studio, **enquanto o jogo está rodando**
2. Selecione "Buff Noob" no Workspace
3. Mude o Attribute `ChaseSpeed` nas Properties
4. **Stop + Play** para aplicar

### Salvando Configurações

Os Attributes são salvos no arquivo .rbxl, então:
- ✅ Ficam permanentes no seu jogo
- ✅ Podem ser diferentes por fase/arena
- ✅ Não precisam de código

---

## Troubleshooting

**Attribute não funciona:**
- Certifique-se de que o nome está **exatamente** como na tabela: `ChaseSpeed` (case-sensitive)
- O tipo deve ser **Number**, não String
- Faça Stop + Play para aplicar mudanças

**NPC ainda usa velocidade padrão:**
- Verifique o Output: deve mostrar "(custom)" ao lado da velocidade
- Se mostrar "(default)", o Attribute não foi configurado corretamente

**Quero velocidade dinâmica (muda durante o jogo):**
- Use um script separado que altera o Attribute em runtime:
  ```lua
  workspace["Buff Noob"]:SetAttribute("ChaseSpeed", 200)
  ```

---

## Próximos Passos

Outros Attributes que podem ser adicionados no futuro:
- `LaserEnabled` (true/false) - Desabilitar laser
- `LaserCooldown` (número) - Tempo entre lasers
- `MaxHealth` (número) - Vida do NPC
- `DamageMultiplier` (número) - Dano causado

Peça para adicionar se precisar!
