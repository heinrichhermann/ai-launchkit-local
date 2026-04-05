#!/bin/bash
# =============================================================================
# OpenClaw VM Setup Script
# Fixes SSH password auth and configures network bridge for LAN access
# Run as: bash fix_openclaw_vm.sh
# =============================================================================

set -e
LOGFILE="/tmp/openclaw_setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*"; }
info() { echo -e "${YELLOW}[INFO]${NC} $*"; }

echo "=============================================="
echo " OpenClaw VM Setup - $(date)"
echo "=============================================="

# =============================================================================
# 1. SSH PASSWORD AUTH FIX
# =============================================================================
info "=== 1. SSH Konfiguration prüfen und fixen ==="

SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_DIR="/etc/ssh/sshd_config.d"

info "Aktueller sshd Status:"
systemctl is-active ssh 2>/dev/null || systemctl is-active sshd 2>/dev/null || err "SSH nicht aktiv"

info "Alle SSH-Config Dateien:"
grep -rn "PasswordAuth\|KbdInteractive\|UsePAM\|AllowUsers\|PubkeyAuth\|Match" \
    "$SSHD_CONFIG" "$SSHD_DIR"/*.conf 2>/dev/null || info "sshd_config.d leer oder keine Treffer"

# Fix main sshd_config
info "Setze PasswordAuthentication yes in $SSHD_CONFIG..."
sudo sed -i 's/^#*\s*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
if ! grep -q "^PasswordAuthentication yes" "$SSHD_CONFIG"; then
    echo "PasswordAuthentication yes" | sudo tee -a "$SSHD_CONFIG"
fi

# Fix KbdInteractiveAuthentication
sudo sed -i 's/^#*\s*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' "$SSHD_CONFIG"
if ! grep -q "^KbdInteractiveAuthentication" "$SSHD_CONFIG"; then
    echo "KbdInteractiveAuthentication yes" | sudo tee -a "$SSHD_CONFIG"
fi

# Fix UsePAM
sudo sed -i 's/^#*\s*UsePAM.*/UsePAM yes/' "$SSHD_CONFIG"
if ! grep -q "^UsePAM yes" "$SSHD_CONFIG"; then
    echo "UsePAM yes" | sudo tee -a "$SSHD_CONFIG"
fi

# Override any files in sshd_config.d that disable password auth
if ls "$SSHD_DIR"/*.conf 2>/dev/null; then
    info "Override-Dateien in sshd_config.d werden gepatcht..."
    sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' "$SSHD_DIR"/*.conf 2>/dev/null || true
fi

# Write a high-priority override file
sudo tee "$SSHD_DIR/99-password-auth.conf" > /dev/null << 'EOF'
# OpenClaw VM Setup - Password Authentication
PasswordAuthentication yes
KbdInteractiveAuthentication yes
UsePAM yes
EOF
ok "sshd_config.d/99-password-auth.conf erstellt"

# Validate config
info "SSH-Config validieren..."
sudo sshd -t && ok "SSH-Config ist valide" || err "SSH-Config fehlerhaft!"

# Restart SSH
info "SSH neu starten..."
sudo systemctl restart ssh 2>/dev/null || sudo systemctl restart sshd 2>/dev/null
sleep 1
systemctl is-active ssh 2>/dev/null || systemctl is-active sshd 2>/dev/null
ok "SSH neugestartet"

# Show effective config
info "Aktive SSH-Einstellungen:"
sudo sshd -T | grep -E "passwordauth|kbdinteractive|usepam|allowusers|pubkeyauth"

# =============================================================================
# 2. USER SETUP
# =============================================================================
info "=== 2. User 'openclaw' prüfen ==="

if id openclaw &>/dev/null; then
    ok "User openclaw existiert"
    info "User-Info: $(getent passwd openclaw)"
    info "Password-Status: $(sudo passwd -S openclaw)"
else
    err "User openclaw existiert nicht!"
    sudo useradd -m -s /bin/bash openclaw
    echo "openclaw:OpenClaw19_" | sudo chpasswd
    ok "User openclaw erstellt"
fi

# Unlock account if locked
sudo passwd -u openclaw 2>/dev/null && ok "Account entsperrt" || true

# Add to sudo group
sudo usermod -aG sudo openclaw 2>/dev/null && ok "openclaw zur sudo-Gruppe hinzugefügt" || true

# =============================================================================
# 3. SSH KEY VOM HOST EINRICHTEN
# =============================================================================
info "=== 3. SSH Key vom AI-Server einrichten ==="

OPENCLAW_SSH_DIR="/home/openclaw/.ssh"
AUTHORIZED_KEYS="$OPENCLAW_SSH_DIR/authorized_keys"
HOST_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEHk3H8Gc9ZMlXt5rUi7WorYGPO2WG1WtYPCtP6arjHJ heinrich@AISERVER"

sudo mkdir -p "$OPENCLAW_SSH_DIR"
if ! sudo grep -qF "$HOST_KEY" "$AUTHORIZED_KEYS" 2>/dev/null; then
    echo "$HOST_KEY" | sudo tee -a "$AUTHORIZED_KEYS" > /dev/null
    ok "Host SSH Key eingetragen"
else
    ok "Host SSH Key bereits vorhanden"
fi
sudo chmod 700 "$OPENCLAW_SSH_DIR"
sudo chmod 600 "$AUTHORIZED_KEYS"
sudo chown -R openclaw:openclaw "$OPENCLAW_SSH_DIR"

# =============================================================================
# 4. NETZWERK - ZWEITE INTERFACE KONFIGURIEREN (macvtap / LAN)
# =============================================================================
info "=== 4. Netzwerk-Interfaces prüfen ==="

info "Alle Interfaces:"
ip link show | grep -E "^[0-9]"

info "IP-Adressen:"
ip addr show | grep -E "inet |^[0-9]"

# Find second interface (not lo, not first NIC)
INTERFACES=($(ip link show | grep -E "^[0-9]" | awk -F': ' '{print $2}' | grep -v lo | grep -v '@'))
info "Gefundene Interfaces: ${INTERFACES[*]}"

SECOND_IF=""
for iface in "${INTERFACES[@]}"; do
    if [[ "$iface" != "lo" ]]; then
        IP=$(ip addr show "$iface" 2>/dev/null | grep "inet " | grep -v "127\." | awk '{print $2}' | head -1)
        info "Interface $iface: ${IP:-keine IP}"
        if [[ -z "$IP" ]] && [[ -z "$SECOND_IF" ]] && [[ "$iface" != "${INTERFACES[0]}" ]]; then
            SECOND_IF="$iface"
        fi
    fi
done

if [[ -n "$SECOND_IF" ]]; then
    info "Zweites Interface ohne IP gefunden: $SECOND_IF"
    info "Konfiguriere $SECOND_IF mit DHCP..."

    # Check if netplan is used
    if command -v netplan &>/dev/null && ls /etc/netplan/*.yaml &>/dev/null; then
        info "Netplan erkannt - erstelle Konfiguration..."
        sudo tee /etc/netplan/99-second-interface.yaml > /dev/null << EOF
network:
  version: 2
  ethernets:
    ${SECOND_IF}:
      dhcp4: true
      dhcp6: false
      optional: true
EOF
        sudo chmod 600 /etc/netplan/99-second-interface.yaml
        sudo netplan apply 2>/dev/null && ok "Netplan angewendet" || err "Netplan Fehler"
        sleep 3
        IP=$(ip addr show "$SECOND_IF" 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)
        if [[ -n "$IP" ]]; then
            ok "Interface $SECOND_IF hat IP: $IP"
        else
            err "Kein DHCP-Lease erhalten für $SECOND_IF"
        fi

    # Check if NetworkManager is used
    elif command -v nmcli &>/dev/null; then
        info "NetworkManager erkannt..."
        sudo nmcli con add type ethernet ifname "$SECOND_IF" con-name "lan-bridge" \
            ipv4.method auto ipv6.method ignore 2>/dev/null && ok "NM Verbindung erstellt" || true
        sudo nmcli con up "lan-bridge" 2>/dev/null && ok "NM Verbindung aktiviert" || true
        sleep 3
        IP=$(ip addr show "$SECOND_IF" 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)
        [[ -n "$IP" ]] && ok "Interface $SECOND_IF hat IP: $IP" || err "Kein DHCP-Lease"

    else
        info "Kein Netplan/NM - benutze dhclient..."
        sudo dhclient "$SECOND_IF" 2>/dev/null && ok "DHCP angefragt" || err "dhclient Fehler"
        sleep 3
        IP=$(ip addr show "$SECOND_IF" 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)
        [[ -n "$IP" ]] && ok "Interface $SECOND_IF hat IP: $IP" || err "Kein DHCP-Lease"
    fi
else
    info "Alle Interfaces haben bereits IPs oder nur ein Interface vorhanden"
fi

# =============================================================================
# 5. FIREWALL KONFIGURIEREN
# =============================================================================
info "=== 5. Firewall prüfen ==="

if command -v ufw &>/dev/null; then
    info "UFW Status: $(sudo ufw status | head -3)"
    sudo ufw allow 22/tcp comment 'SSH' 2>/dev/null && ok "UFW: SSH erlaubt"
    sudo ufw allow from 192.168.178.0/24 comment 'Local network' 2>/dev/null && ok "UFW: LAN erlaubt"
    sudo ufw reload 2>/dev/null
elif command -v iptables &>/dev/null; then
    info "iptables erkannt"
    sudo iptables -I INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null && ok "iptables: SSH erlaubt"
fi

# =============================================================================
# 6. OPENSSH-SERVER SICHERSTELLEN
# =============================================================================
info "=== 6. OpenSSH-Server sicherstellen ==="

if ! command -v sshd &>/dev/null; then
    info "OpenSSH nicht installiert - installiere..."
    sudo apt-get update -qq
    sudo apt-get install -y openssh-server
    ok "OpenSSH installiert"
else
    ok "OpenSSH bereits installiert: $(sshd -V 2>&1 | head -1)"
fi

sudo systemctl enable ssh 2>/dev/null || sudo systemctl enable sshd 2>/dev/null
sudo systemctl restart ssh 2>/dev/null || sudo systemctl restart sshd 2>/dev/null

# =============================================================================
# 7. QEMU GUEST AGENT INSTALLIEREN
# =============================================================================
info "=== 7. QEMU Guest Agent installieren ==="

if ! command -v qemu-ga &>/dev/null; then
    info "Installiere qemu-guest-agent..."
    sudo apt-get install -y qemu-guest-agent -qq
    sudo systemctl enable --now qemu-guest-agent
    ok "QEMU Guest Agent installiert und gestartet"
else
    ok "QEMU Guest Agent bereits installiert"
    sudo systemctl enable --now qemu-guest-agent 2>/dev/null
fi

# =============================================================================
# 8. ABSCHLUSSBERICHT
# =============================================================================
echo ""
echo "=============================================="
echo " ABSCHLUSSBERICHT"
echo "=============================================="

info "SSH-Service Status:"
systemctl is-active ssh 2>/dev/null || systemctl is-active sshd 2>/dev/null

info "Aktive SSH-Passwort-Einstellung:"
sudo sshd -T | grep passwordauth

info "Alle IP-Adressen:"
ip addr show | grep "inet " | grep -v "127\." | awk '{print $2, $NF}'

info "LAN-Erreichbarkeit:"
for IP in $(ip addr show | grep "inet " | grep -v "127\." | awk '{print $2}' | cut -d/ -f1); do
    echo "  -> $IP"
done

info "Logfile: $LOGFILE"
ok "Setup abgeschlossen!"
echo ""
echo "Zum Testen vom AISERVER:"
echo "  ssh openclaw@<VM-IP>"
