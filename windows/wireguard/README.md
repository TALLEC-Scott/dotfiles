# Windows WireGuard tunnels

The Windows WireGuard config (peer `scott-windows`) is in sops as `wireguard_windows`.
It gives two tunnels with the same key, so only one can be active at a time:

- `freebox-admin`: only mafreebox.freebox.fr goes through the VPN
- `freebox-full`: everything goes through the Freebox (Netflix app, etc.)

MTU is 1200 because the Freebox default (1360) hangs on some networks.

### **Create the tunnels**
Generate the two files, import them in the WireGuard app, then delete them:

```bash
src=~/.config/sops-nix/secrets/wireguard_windows; out=/mnt/c/Users/$WINUSER/Downloads/wireguard-import; mkdir -p "$out"
mk() { awk -v allowed="$2" -v dns="$3" '/^\[Interface\]/{print; print "MTU = 1200"; if(dns!="")print "DNS = " dns; next}
  /^\[Peer\]/{print; print "AllowedIPs = " allowed; next} /^(DNS|AllowedIPs|MTU)[[:space:]]*=/{next} {print}' "$src" \
  | sed 's/$/\r/' > "$out/$1.conf"; }
mk freebox-admin "212.27.38.253/32, 192.168.0.254/32" ""
mk freebox-full  "0.0.0.0/0, ::/0" "212.27.38.253"
```

### **Freebox certificates**
The Freebox HTTPS certificate comes from Free's own CA, so browsers show "not secure" until it is installed:
- `Freebox Root CA` and `Freebox ECC Root CA` in Local Machine → Trusted Root (admin, user roots are ignored on this PC)
- the two intermediates in Intermediate CAs
- Firefox: set `security.enterprise_roots.enabled` to `true`
