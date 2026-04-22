#!/bin/bash

echo "🚀 Iniciando configuración del entorno Koharu..."

# 1. Intentar desactivar el repositorio problemático
echo "🔧 Desactivando repositorio problemático de libnvidia-container..."
sudo cp /dev/null /etc/apt/sources.list.d/nvidia-container-toolkit.sources 2>/dev/null || true
sudo cp /dev/null /etc/apt/sources.list.d/nvidia-container-toolkit.list 2>/dev/null || true

# 2. Configurar repositorio oficial de CUDA
echo "📦 Configurando repositorio oficial de NVIDIA CUDA..."
if [ ! -f /tmp/cuda-keyring_1.1-1_all.deb ]; then
    wget -q -O /tmp/cuda-keyring_1.1-1_all.deb \
        https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
fi
sudo dpkg -i /tmp/cuda-keyring_1.1-1_all.deb

# 3. Limpiar caché y actualizar
echo "🔄 Limpiando caché y actualizando lista de paquetes..."
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update -o Acquire::AllowInsecureRepositories=true \
    || { echo "❌ Error actualizando paquetes"; exit 1; }

# 4. Buscar paquetes de CUDA disponibles
echo "🔍 Buscando paquetes de CUDA disponibles..."
apt-cache search cuda-toolkit | head -20

# 5. Instalar CUDA Toolkit (intentar varias versiones)
echo "🛠️ Instalando CUDA Toolkit..."
if sudo apt-get install -y cuda-toolkit-12-4; then
    echo "✅ CUDA Toolkit 12.4 instalado."
elif sudo apt-get install -y cuda-toolkit-12-6; then
    echo "✅ CUDA Toolkit 12.6 instalado."
elif sudo apt-get install -y cuda-toolkit; then
    echo "✅ CUDA Toolkit (última versión) instalado."
else
    echo "❌ Error instalando CUDA Toolkit"
    echo "Paquetes disponibles:"
    apt-cache search cuda-toolkit
    exit 1
fi

# 6. Instalar Rust
if [ ! -f "$HOME/.cargo/bin/cargo" ]; then
    echo "🦀 Instalando Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "✅ Rust ya está instalado."
fi

# 7. Instalar Bun
if [ ! -d "$HOME/.bun" ]; then
    echo "🍞 Instalando Bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
else
    echo "✅ Bun ya está instalado."
fi

# 8. Detectar dónde quedó instalado CUDA
CUDA_PATH=""
if [ -d "/usr/local/cuda" ]; then
    CUDA_PATH="/usr/local/cuda"
elif [ -d "/usr/local/cuda-12.4" ]; then
    CUDA_PATH="/usr/local/cuda-12.4"
elif [ -d "/usr/local/cuda-12.6" ]; then
    CUDA_PATH="/usr/local/cuda-12.6"
else
    CUDA_PATH="/usr"
fi

# 9. Configurar variables persistentes en .bashrc
echo "📝 Configurando variables de entorno (CUDA_HOME=$CUDA_PATH)..."
if ! grep -q "CUDA_HOME" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<EOF

# Koharu Dev Environment
source \$HOME/.cargo/env
export PATH=\$HOME/.bun/bin:\$PATH
export PATH=\$PATH:${CUDA_PATH}/bin
export CUDA_HOME=${CUDA_PATH}
EOF
fi

# 10. Verificación
echo ""
echo "================================================"
echo "🔍 Verificando instalación..."
NVCC_BIN="${CUDA_PATH}/bin/nvcc"
echo "  nvcc: $($NVCC_BIN --version 2>/dev/null | grep 'release' || echo 'NO ENCONTRADO')"
echo "  cargo: $(cargo --version 2>/dev/null || echo 'NO ENCONTRADO')"
echo "  bun: $(bun --version 2>/dev/null || echo 'NO ENCONTRADO')"
echo "================================================"
echo "✅ ¡Configuración completada!"
echo "👉 Ejecuta: source ~/.bashrc && bun install && bun dev"
echo "================================================"
