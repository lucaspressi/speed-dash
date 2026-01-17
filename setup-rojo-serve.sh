#!/bin/bash
# Setup script for Rojo Serve workflow
# This syncs your updated scripts to your original .rbxl file with the full map and UI

clear
echo "============================================================"
echo "🔧 SPEED DASH - ROJO SERVE SETUP"
echo "============================================================"
echo ""

# Go to correct directory
cd /Users/lucassampaio/Projects/speed-dash || exit 1

echo "📋 INSTRUÇÕES:"
echo ""
echo "1️⃣  Este script vai iniciar o Rojo Server"
echo "2️⃣  O servidor ficará rodando e esperando conexão do Studio"
echo "3️⃣  Você precisará:"
echo "    • Abrir seu arquivo ORIGINAL .rbxl (aquele com mapa completo e UI)"
echo "    • Clicar no botão Rojo plugin no Studio"
echo "    • Clicar em 'Connect'"
echo ""
echo "============================================================"
echo ""

# Check if rojo is installed
if ! command -v rojo &> /dev/null; then
    echo "❌ ERRO: Rojo não está instalado!"
    echo ""
    echo "Para instalar:"
    echo "  brew install rojo"
    echo ""
    exit 1
fi

echo "✅ Rojo encontrado: $(rojo --version)"
echo ""
echo "🚀 Iniciando Rojo Server..."
echo ""
echo "============================================================"
echo "📡 ROJO SERVER ATIVO"
echo "============================================================"
echo ""
echo "Próximos passos NO STUDIO:"
echo ""
echo "1. Abra seu arquivo ORIGINAL .rbxl"
echo "   (Aquele que tem o mapa completo e a UI)"
echo ""
echo "2. No Studio, clique no botão 'Rojo' no toolbar"
echo ""
echo "3. Clique em 'Connect' na janela que abrir"
echo ""
echo "4. Você verá: '✅ Connected to Rojo'"
echo ""
echo "5. Vá para ServerScriptService no Explorer"
echo ""
echo "6. Clique direito em 'TreadmillSetupWizard' → Run"
echo ""
echo "7. Aguarde ver no Output:"
echo "   [WIZARD] 🎉 SETUP COMPLETE!"
echo "   [WIZARD] ✅ Success: 60 zones"
echo ""
echo "8. Clique Play Solo (F5) e teste!"
echo ""
echo "============================================================"
echo ""
echo "⚠️  MANTENHA ESTE TERMINAL ABERTO enquanto trabalhar no Studio"
echo "⚠️  Para parar o servidor: Ctrl+C"
echo ""
echo "============================================================"
echo ""

# Start rojo serve
rojo serve
