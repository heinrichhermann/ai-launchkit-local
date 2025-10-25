#!/bin/bash

set -e

# Source utilities
source "$(dirname "$0")/utils.sh"

# Get project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"
ENV_FILE="$PROJECT_ROOT/.env"

# Check if speech services are in COMPOSE_PROFILES
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# Check if any speech profile is active
if [[ "$COMPOSE_PROFILES" == *"speech"* ]] || [[ "$COMPOSE_PROFILES" == *"speech-cpu"* ]] || [[ "$COMPOSE_PROFILES" == *"speech-gpu"* ]]; then
    log_info "Speech services selected - Setting up German TTS voice (Thorsten)..."
    
    cd "$PROJECT_ROOT"
    
    # Create directories if they don't exist
    # Use mkdir -p which doesn't fail if directory exists
    if ! mkdir -p openedai-voices openedai-config 2>/dev/null; then
        log_warning "Could not create directories (permission issue)"
        log_info "Attempting with sudo..."
        sudo mkdir -p openedai-voices openedai-config
        # Set ownership to current user
        sudo chown -R $USER:$USER openedai-voices openedai-config
    fi
    
    # German Voice Setup (Thorsten - High Quality, Male)
    VOICE_FILE="openedai-voices/de_DE-thorsten-high.onnx"
    CONFIG_FILE="openedai-voices/de_DE-thorsten-high.onnx.json"
    
    if [ ! -f "$VOICE_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
        log_info "Downloading German voice model (Thorsten - High Quality)..."
        log_info "This is a ~30MB download and may take a moment..."
        
        # Download voice model with proper error handling
        if ! wget -q --show-progress -O "$VOICE_FILE" \
            "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/de/de_DE/thorsten/high/de_DE-thorsten-high.onnx" 2>&1; then
            
            # If permission denied, try with sudo
            if [ $? -eq 1 ] && [[ "$(ls -ld openedai-voices 2>/dev/null)" != d*$USER* ]]; then
                log_info "Retrying download with proper permissions..."
                sudo wget -q --show-progress -O "$VOICE_FILE" \
                    "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/de/de_DE/thorsten/high/de_DE-thorsten-high.onnx" || {
                    log_error "Failed to download German voice model"
                    log_warning "Speech services will use default English voices"
                    log_info "Manual download: bash ./scripts/04b_setup_german_voice.sh (run with sudo if needed)"
                    exit 0  # Non-critical error
                }
                sudo chown $USER:$USER "$VOICE_FILE"
            else
                log_error "Failed to download German voice model"
                log_warning "Speech services will use default English voices"
                log_info "Check internet connection and try again:"
                log_info "  sudo bash ./scripts/04b_setup_german_voice.sh"
                exit 0  # Non-critical error
            fi
        fi
        
        # Download voice config
        if ! wget -q -O "$CONFIG_FILE" \
            "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/de/de_DE/thorsten/high/de_DE-thorsten-high.onnx.json" 2>/dev/null; then
            log_warning "Failed to download voice config, but model is available"
        fi
        
        log_success "German voice model downloaded successfully!"
        log_info "Voice file: $(du -h $VOICE_FILE | cut -f1)"
    else
        log_info "German voice model already exists - skipping download"
    fi
    
    # Create voice_to_speaker.yaml configuration
    VOICE_CONFIG="openedai-config/voice_to_speaker.yaml"
    
    if [ ! -f "$VOICE_CONFIG" ]; then
        log_info "Creating voice configuration with German support..."
        
        cat > "$VOICE_CONFIG" << 'EOF'
# OpenedAI Speech - Voice Configuration
# This file maps voice names to specific TTS models and speakers

# TTS-1 Voices (Piper - Fast, CPU-friendly)
# These voices use the Piper TTS engine and work on CPU
tts-1:
  # Original OpenAI-compatible voices (English)
  alloy:
    model: voices/en_US-amy-medium.onnx
    speaker: # default speaker
  
  echo:
    model: voices/en_US-danny-low.onnx
    speaker: # default speaker
  
  fable:
    model: voices/en_GB-alan-medium.onnx
    speaker: # default speaker
  
  onyx:
    model: voices/en_US-libritts-high.onnx
    speaker: # default speaker
  
  nova:
    model: voices/en_US-amy-medium.onnx
    speaker: # default speaker
  
  shimmer:
    model: voices/en_US-amy-medium.onnx
    speaker: # default speaker
  
  # German Voice - Thorsten (Male, High Quality)
  # Native German pronunciation for professional podcasts
  thorsten:
    model: voices/de_DE-thorsten-high.onnx
    speaker: # default speaker

# TTS-1-HD Voices (XTTS v2 - High Quality, GPU-accelerated)
# These voices use neural voice cloning for better quality
tts-1-hd:
  # Original OpenAI-compatible voices with voice cloning
  alloy:
    model: xtts
    speaker: voices/alloy.wav
  
  echo:
    model: xtts
    speaker: voices/echo.wav
  
  fable:
    model: xtts
    speaker: voices/fable.wav
  
  onyx:
    model: xtts
    speaker: voices/onyx.wav
  
  nova:
    model: xtts
    speaker: voices/nova.wav
  
  shimmer:
    model: xtts
    speaker: voices/shimmer.wav

# Usage Instructions:
# 
# 1. In Open Notebook Settings -> Models:
#    - Add Model: tts-1
#    - Provider: openai_compatible
#    - Voice: thorsten (for German) or alloy/nova (for English)
#
# 2. For podcasts, use:
#    - Voice name: "thorsten" for German content
#    - Voice name: "alloy", "nova", etc. for English content
#
# 3. Voice files are automatically downloaded during installation
#    and mounted to the container via docker-compose.local.yml
EOF
        
        log_success "Voice configuration created with German support!"
        log_info "Available voices:"
        log_info "  - English: alloy, echo, fable, onyx, nova, shimmer"
        log_info "  - German: thorsten (native German pronunciation)"
    else
        log_info "Voice configuration already exists"
        
        # Check if thorsten is configured
        if ! grep -q "thorsten:" "$VOICE_CONFIG"; then
            log_info "Adding thorsten voice to existing configuration..."
            cp "$VOICE_CONFIG" "${VOICE_CONFIG}.bak" 2>/dev/null || true
            
            # Simple append if tts-1 section exists
            if grep -q "^tts-1:" "$VOICE_CONFIG"; then
                echo "" >> "$VOICE_CONFIG"
                echo "  # German Voice - Thorsten (Male, High Quality)" >> "$VOICE_CONFIG"
                echo "  thorsten:" >> "$VOICE_CONFIG"
                echo "    model: voices/de_DE-thorsten-high.onnx" >> "$VOICE_CONFIG"
                echo "    speaker: # default speaker" >> "$VOICE_CONFIG"
                log_success "Added thorsten voice to configuration!"
            fi
        else
            log_success "Thorsten voice already configured!"
        fi
    fi
    
    # Detect which speech service variant is running
    SPEECH_SERVICE=""
    if [[ "$COMPOSE_PROFILES" == *"speech-gpu"* ]]; then
        SPEECH_SERVICE="openedai-speech-gpu"
    elif [[ "$COMPOSE_PROFILES" == *"speech-cpu"* ]]; then
        SPEECH_SERVICE="openedai-speech-cpu"
    elif [[ "$COMPOSE_PROFILES" == *"speech"* ]]; then
        # Check which container is actually running
        if docker ps --format '{{.Names}}' | grep -q "openedai-speech"; then
            SPEECH_SERVICE="openedai-speech-cpu"  # Default/backward compatibility
        fi
    fi
    
    log_success "German TTS voice setup complete!"
    log_info ""
    log_info "📢 How to use the German voice:"
    log_info "  1. Restart OpenedAI Speech service:"
    if [ -n "$SPEECH_SERVICE" ]; then
        log_info "     sudo docker compose -p localai -f docker-compose.local.yml restart $SPEECH_SERVICE"
    else
        log_info "     sudo docker compose -p localai -f docker-compose.local.yml restart openedai-speech-cpu"
        log_info "     # or: openedai-speech-gpu (depending on your setup)"
    fi
    log_info "  2. Open Open Notebook: http://SERVER_IP:8100"
    log_info "  3. Go to: Settings → Models → Add Model"
    log_info "     - Provider: openai_compatible"
    log_info "     - Model Name: tts-1"
    log_info "     - Display Name: Local TTS"
    log_info "  4. In Podcast Episode Profile, set voice: 'thorsten'"
    log_info ""
    log_info "🎙️ The Thorsten voice will speak native German!"
    log_info "   Available voices: thorsten (DE), alloy/nova/echo (EN)"
    
    cd "$PROJECT_ROOT"
else
    log_info "Speech services not selected - skipping German voice setup"
    log_info "To enable later:"
    log_info "  1. Add 'speech-cpu' or 'speech-gpu' to COMPOSE_PROFILES in .env"
    log_info "  2. Run: bash ./scripts/04b_setup_german_voice.sh"
    log_info "  3. Start services: docker compose -p localai -f docker-compose.local.yml up -d"
fi

exit 0
