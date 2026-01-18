#!/bin/bash

# verify-source-clean.sh
# Verifica se o código fonte do Rojo está limpo (sem código malicioso)

echo "🔍 Verificando código fonte do Rojo..."
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

THREATS_FOUND=0

# Verificar por padrões suspeitos no código fonte
echo "📋 Escaneando arquivos .lua no código fonte..."
echo ""

# Procurar por "55" em contexto suspeito
echo "🔎 Procurando por '55' em contexto de Robux/produtos..."
if grep -r -n -i "55.*robux\|55.*product\|55.*owner\|promptproductpurchase.*55\|promptgamepasspurchase.*55" src/ 2>/dev/null; then
    echo -e "${RED}⚠️ AMEAÇA ENCONTRADA: Referência a 55 robux/produto!${NC}"
    THREATS_FOUND=$((THREATS_FOUND + 1))
else
    echo -e "${GREEN}✅ Nenhuma referência suspeita a '55' encontrada${NC}"
fi
echo ""

# Procurar por "HD Admin"
echo "🔎 Procurando por 'HD Admin'..."
if grep -r -n -i "hd.*admin\|hdadmin" src/ 2>/dev/null; then
    echo -e "${RED}⚠️ AMEAÇA ENCONTRADA: Referência a HD Admin!${NC}"
    THREATS_FOUND=$((THREATS_FOUND + 1))
else
    echo -e "${GREEN}✅ Nenhuma referência a HD Admin encontrada${NC}"
fi
echo ""

# Procurar por "Owner Rank"
echo "🔎 Procurando por 'Owner Rank'..."
if grep -r -n -i "owner.*rank" src/ 2>/dev/null; then
    echo -e "${RED}⚠️ AMEAÇA ENCONTRADA: Referência a Owner Rank!${NC}"
    THREATS_FOUND=$((THREATS_FOUND + 1))
else
    echo -e "${GREEN}✅ Nenhuma referência a Owner Rank encontrada${NC}"
fi
echo ""

# Procurar por loadstring (comum em código ofuscado)
echo "🔎 Procurando por 'loadstring' (código ofuscado)..."
if grep -r -n "loadstring" src/ 2>/dev/null; then
    echo -e "${YELLOW}⚠️ AVISO: 'loadstring' encontrado (pode ser código ofuscado)${NC}"
    THREATS_FOUND=$((THREATS_FOUND + 1))
else
    echo -e "${GREEN}✅ Nenhum 'loadstring' encontrado${NC}"
fi
echo ""

# Procurar por require com asset IDs suspeitos
echo "🔎 Procurando por require() com asset IDs..."
if grep -r -n "require([0-9]\+)" src/ 2>/dev/null; then
    echo -e "${YELLOW}⚠️ AVISO: require() com asset ID encontrado${NC}"
    echo "   Verifique se esses são módulos confiáveis!"
else
    echo -e "${GREEN}✅ Nenhum require() com asset ID encontrado${NC}"
fi
echo ""

# Verificar produtos conhecidos (deve encontrar apenas os legítimos)
echo "🔎 Verificando produtos do MarketplaceService..."
if grep -r -n "PromptProductPurchase\|PromptGamePassPurchase" src/ 2>/dev/null; then
    echo -e "${YELLOW}ℹ️ MarketplaceService encontrado - verificando se são legítimos:${NC}"
    grep -r -n "3510662188\|3510662405" src/ 2>/dev/null
    echo "   ✅ Produtos legítimos: 3510662188 e 3510662405 (esteiras)"
else
    echo -e "${GREEN}✅ Nenhuma chamada de MarketplaceService encontrada${NC}"
fi
echo ""

# Contar arquivos .lua
LUA_COUNT=$(find src/ -name "*.lua" -type f | wc -l | tr -d ' ')
echo "📊 Total de arquivos .lua no código fonte: $LUA_COUNT"
echo ""

# Resultado final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $THREATS_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ CÓDIGO FONTE LIMPO!${NC}"
    echo "   Seu código fonte do Rojo não contém ameaças conhecidas."
    echo ""
    echo "   Se o prompt de 55 robux ainda aparece, o problema está no arquivo"
    echo "   build.rbxl (scripts não sincronizados com Rojo)."
    echo ""
    echo "   Solução: Delete build.rbxl e reconstrua com 'rojo build'"
else
    echo -e "${RED}⚠️ AMEAÇAS ENCONTRADAS NO CÓDIGO FONTE!${NC}"
    echo "   Total de ameaças: $THREATS_FOUND"
    echo ""
    echo "   AÇÃO IMEDIATA NECESSÁRIA:"
    echo "   1. Revise os arquivos marcados acima"
    echo "   2. Delete código malicioso do código fonte"
    echo "   3. Commit as mudanças limpas no Git"
    echo "   4. Reconstrua com 'rojo build'"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Instruções adicionais
echo "📝 PRÓXIMOS PASSOS:"
echo ""
echo "1. Execute o scanner no Studio para encontrar scripts no build.rbxl:"
echo "   - Abra build.rbxl no Roblox Studio"
echo "   - Rode FIND_55_ROBUX_PROMPT.lua no Command Bar"
echo ""
echo "2. Verifique plugins maliciosos:"
echo "   - Mac: ~/Documents/Roblox/Plugins"
echo "   - Windows: %LOCALAPPDATA%\\Roblox\\Plugins"
echo ""
echo "3. Se necessário, reconstrua o jogo:"
echo "   rm build.rbxl"
echo "   rojo build -o build.rbxl"
echo ""
