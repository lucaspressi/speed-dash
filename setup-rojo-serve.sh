#!/bin/bash

# Script helper para testar o jogo com Rojo

case "$1" in
    "rebuild")
        echo "🔨 Rebuilding build.rbxl..."
        rojo build -o build.rbxl
        echo "✅ Build complete! Open build.rbxl in Studio to test."
        ;;
    
    "serve")
        echo "🚀 Starting Rojo server..."
        echo "📝 Instructions:"
        echo "   1. Open any place in Roblox Studio"
        echo "   2. Click the Rojo plugin"
        echo "   3. Click 'Connect'"
        echo ""
        echo "Starting server..."
        rojo serve
        ;;
    
    *)
        echo "Usage: $0 {rebuild|serve}"
        echo ""
        echo "Options:"
        echo "  rebuild  - Rebuild build.rbxl with latest code changes"
        echo "  serve    - Start Rojo server for live sync"
        exit 1
        ;;
esac
