# Koharu Distrobox Environment

Este archivo configura un entorno de desarrollo para Koharu usando [Distrobox](https://distrobox.it/). 

## Requisitos

- `distrobox` instalado en el host.
- `podman` o `docker` instalado en el host.
- Drivers de NVIDIA instalados en el host (para soporte CUDA).

## Configuración Inicial

1. **Crear el contenedor:**
   ```bash
   distrobox-assemble create --file distrobox.ini
   ```

2. **Entrar al contenedor:**
   ```bash
   distrobox enter koharu-dev
   ```

3. **Ejecutar el script de configuración (solo la primera vez):**
   Este script instala el CUDA Toolkit, Rust, Bun y configura las variables de entorno automáticamente.
   ```bash
   bash scripts/setup-dev.sh
   ```

4. **Activar el entorno y empezar a trabajar:**
   ```bash
   source ~/.bashrc
   bun install
   bun dev
   ```

## Uso Diario

Una vez configurado, cada vez que entres al contenedor las variables de entorno ya estarán listas:

```bash
distrobox enter koharu-dev
bun dev
```

## Compilar el proyecto

```bash
bun run build
```

## Recrear el contenedor desde cero

Si necesitas empezar de nuevo:

```bash
distrobox rm koharu-dev -f
distrobox-assemble create --file distrobox.ini
distrobox enter koharu-dev
bash scripts/setup-dev.sh
```

## Detalles del Entorno

- **Base:** Ubuntu 24.04
- **Herramientas:** Rust, Bun, LLVM, Clang, CMake, Go.
- **CUDA:** Toolkit instalado vía repositorio oficial de NVIDIA.
- **Gráficos:** Soporte para NVIDIA (vía `nvidia=true`) y Vulkan.
- **GUI:** Reenvío de X11/Wayland habilitado para ejecutar la app de Tauri.
