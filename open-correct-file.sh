#!/bin/bash
# Script para abrir o build.rbxl CORRETO
# Usage: ./open-correct-file.sh

echo "=================================================="
echo "🚀 Abrindo build.rbxl CORRETO"
echo "=================================================="
echo ""

BUILD_FILE="/Users/lucassampaio/projects/speed-dash/build.rbxl"

# Verifica se o arquivo existe
if [ ! -f "$BUILD_FILE" ]; then
    echo "❌ ERRO: build.rbxl não encontrado!"
    echo "   Execute: rojo build -o build.rbxl"
    exit 1
fi

# Mostra informações do arquivo
echo "📄 Arquivo: $BUILD_FILE"
echo "📅 Última modificação: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$BUILD_FILE")"
echo "📦 Tamanho: $(du -h "$BUILD_FILE" | cut -f1)"
echo ""

# Fecha todas as instâncias do Roblox Studio
echo "🔄 Fechando Roblox Studio..."
killall "RobloxStudio" 2>/dev/null || echo "   (Nenhuma instância aberta)"
sleep 1

# Abre o arquivo correto
echo "✅ Abrindo build.rbxl..."
open "$BUILD_FILE"

echo ""
echo "=================================================="
echo "✅ CONCLUÍDO!"
echo "=================================================="
echo ""
echo "Próximos passos no Studio:"
echo "1. Aguarde o Studio abrir"
echo "2. Verifique o Output - deve ver: [RemotesBootstrap] ✅ All remotes ready"
echo "3. ServerScriptService → TreadmillSetup → Clique direito → Run"
echo "4. Aguarde: [TREADMILL-FIX] ✅ SETUP COMPLETE"
echo "5. Clique Play Solo"
echo ""
