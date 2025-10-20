# ComfyUI Update und Version-Kompatibilität

## Problem

Bei ComfyUI konnte es zu Version-Inkompatibilitäten zwischen Frontend und Backend kommen:

```
Alert: Frontend version 1.27.7 is outdated. Backend requires 1.27.10 or higher.
```

## Ursache

Das ursprüngliche Setup verwendete einen **festen Image-Tag** (`cu124-slim`), der nicht automatisch auf neuere Versionen aktualisiert wurde:

```yaml
# ALT - Fixierter Tag
comfyui:
  image: yanwk/comfyui-boot:cu124-slim  # ❌ Bleibt auf diesem spezifischen Build
```

## Lösung

ComfyUI wurde auf ein **Profile-basiertes System** umgestellt (analog zu Ollama), das immer die neuesten Images verwendet:

```yaml
# NEU - Profile-basiert mit :latest Tags
comfyui-cpu:
  image: yanwk/comfyui-boot:latest  # ✅ Immer neueste CPU-Version
  profiles: ["comfyui-cpu"]

comfyui-gpu:
  image: yanwk/comfyui-boot:latest-cuda  # ✅ Immer neueste CUDA-Version
  profiles: ["comfyui-gpu"]
```

## Verwendung

### Bei Installation

Im Wizard oder in der `.env` Datei:

```bash
# Für CPU:
COMPOSE_PROFILES="n8n,comfyui-cpu"

# Für NVIDIA GPU:
COMPOSE_PROFILES="n8n,comfyui-gpu,gpu-nvidia"
```

### Nach dem Update

Das Update-Skript erkennt automatisch die gewählte Variante und prüft den entsprechenden Service:

```bash
sudo bash scripts/update_local.sh
```

Ausgabe:
```
✅ ComfyUI (GPU) is running (Port 8024)
# oder
✅ ComfyUI (CPU) is running (Port 8024)
```

## Vorteile

1. **Immer aktuell**: `docker pull` holt automatisch die neueste kompatible Version
2. **GPU-optimiert**: Separate Images für CPU und GPU (bessere Performance)
3. **Konsistent**: Gleiche Strategie wie Ollama (bewährtes Pattern)
4. **Bulletproof**: Maintainer pflegt `:latest` und `:latest-cuda` Tags

## Migration bestehender Installation

Wenn du bereits eine Installation mit dem alten `comfyui` Profil hast:

1. **Stoppe ComfyUI:**
   ```bash
   docker compose -p localai -f docker-compose.local.yml stop comfyui
   ```

2. **Aktualisiere `.env`:**
   ```bash
   # Ersetze "comfyui" durch "comfyui-cpu" oder "comfyui-gpu"
   # Beispiel:
   COMPOSE_PROFILES="n8n,comfyui-gpu,gpu-nvidia"
   ```

3. **Starte neu:**
   ```bash
   docker compose -p localai -f docker-compose.local.yml up -d
   ```

4. **Entferne altes Image (optional):**
   ```bash
   docker image rm yanwk/comfyui-boot:cu124-slim
   ```

## Technische Details

### Image-Tags

- `yanwk/comfyui-boot:latest` - Neueste stabile CPU-Version
- `yanwk/comfyui-boot:latest-cuda` - Neueste stabile CUDA-Version
- Docker Hub: https://hub.docker.com/r/yanwk/comfyui-boot/tags

### Warum Profile-basiert?

- **Flexibilität**: User wählt explizit CPU oder GPU
- **Konsistenz**: Gleiche Strategie wie Ollama im Projekt
- **Wartbarkeit**: Nur ein Update-Mechanismus für beide Varianten
- **Zukunftssicher**: Neue CUDA-Versionen automatisch verfügbar

## Troubleshooting

### Version-Mismatch bleibt bestehen

1. **Erzwinge Image-Neudownload:**
   ```bash
   docker compose -p localai -f docker-compose.local.yml pull comfyui-gpu
   docker compose -p localai -f docker-compose.local.yml up -d comfyui-gpu
   ```

2. **Browser-Cache leeren:**
   - Drücke `Ctrl + Shift + R` (Windows/Linux)
   - Drücke `Cmd + Shift + R` (Mac)

3. **Container komplett neu erstellen:**
   ```bash
   docker compose -p localai -f docker-compose.local.yml down comfyui
   docker volume rm localai_comfyui_data
   docker compose -p localai -f docker-compose.local.yml up -d
   ```

### GPU wird nicht erkannt

Stelle sicher, dass:
- NVIDIA Container Toolkit installiert ist
- Profile `gpu-nvidia` aktiv ist
- `nvidia-smi` funktioniert

```bash
# Prüfe GPU:
nvidia-smi

# Prüfe Docker GPU-Support:
docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi
```

## Weiterführende Links

- [ComfyUI Official Docs](https://github.com/comfyanonymous/ComfyUI)
- [yanwk/comfyui-boot Docker Hub](https://hub.docker.com/r/yanwk/comfyui-boot)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
