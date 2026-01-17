#!/bin/bash
# Script para abrir build.rbxl correto e mostrar próximos passos
# Usage: ./open-and-fix.sh

clear
echo "============================================================"
echo "🔧 SPEED DASH - FIX COMPLETO"
echo "============================================================"
echo ""

# Vai para o diretório correto
cd /Users/lucassampaio/Projects/speed-dash || exit 1

# Rebuild para garantir última versão
echo "📦 Reconstruindo build.rbxl..."
rojo build -o build.rbxl

if [ $? -eq 0 ]; then
    echo "✅ Build concluído!"
else
    echo "❌ Erro no build! Verifique o Rojo."
    exit 1
fi

# Mostra informações do arquivo
echo ""
echo "📄 Informações do arquivo:"
ls -lah build.rbxl | awk '{print "   Tamanho: "$5"\n   Data: "$6" "$7" "$8}'

# Fecha Studio se estiver aberto (para evitar arquivo errado)
echo ""
echo "🔄 Fechando Roblox Studio..."
killall "RobloxStudio" 2>/dev/null
sleep 2

# Abre o arquivo CORRETO
echo "✅ Abrindo build.rbxl..."
open build.rbxl

echo ""
echo "============================================================"
echo "📋 PRÓXIMOS PASSOS NO STUDIO:"
echo "============================================================"
echo ""
echo "1️⃣  Aguarde o Studio abrir"
echo ""
echo "2️⃣  Vá em View → Output e verifique:"
echo "    ✅ [RemotesBootstrap] ✅ All remotes ready"
echo "    Se NÃO ver isso, você abriu arquivo errado!"
echo ""
echo "3️⃣  No Explorer, vá para ServerScriptService"
echo ""
echo "4️⃣  Encontre 'TreadmillSetupWizard'"
echo ""
echo "5️⃣  Clique direito → Run"
echo ""
echo "6️⃣  Aguarde ver no Output:"
echo "    [WIZARD] 🎉 SETUP COMPLETE!"
echo "    [WIZARD] ✅ Success: X zones"
echo ""
echo "7️⃣  Clique Play Solo (F5) e teste!"
echo ""
echo "============================================================"
echo ""
echo "🎯 O QUE DEVE FUNCIONAR:"
echo "   ✅ Sem erro 'concatenate table with string'"
echo "   ✅ TreadmillService encontra zonas"
echo "   ✅ Speed/Level/XP aparecem"
echo "   ✅ Botões funcionam"
echo ""
echo "❌ SE NÃO FUNCIONAR:"
echo "   Leia: FIX_FINAL_INSTRUCTIONS.md"
echo ""
echo "============================================================"
