#!/bin/bash
echo "====================================="
echo "📥 VAULTWARDEN CREDENTIALS DOWNLOAD"
echo "====================================="
echo

# File already exists, just serve it
if [ ! -f $HOME/ai-launchkit/ai-launchkit-credentials.json ]; then
    echo "Generating file..."
    cd $HOME/ai-launchkit
    sudo bash ./scripts/08_generate_vaultwarden_json.sh
fi

# Get IPv4 address
IP=$(curl -4 -s ifconfig.me)

# Open port
sudo ufw allow 8889/tcp >/dev/null 2>&1

echo "👇 Open this link in your browser:"
echo
echo "http://$IP:8889/ai-launchkit-credentials.json"
echo
echo "⏱️  Download within 60 seconds!"

# Start server
cd $HOME/ai-launchkit
timeout 60 python3 -m http.server 8889 >/dev/null 2>&1

# Cleanup
sudo ufw delete allow 8889/tcp >/dev/null 2>&1
rm -f ai-launchkit-credentials.json
echo
echo "✅ Done! File deleted for security."
