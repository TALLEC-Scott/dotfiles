# Windows WireGuard tunnels

Peer `scott-windows` from the Freebox; its config (keys) is in sops as `wireguard_windows`.
Two tunnels from the same key (activate one at a time). MTU 1200: the Freebox's 1360 is too big on some networks.

- `freebox-admin`: only mafreebox.freebox.fr through the VPN, DNS unchanged
- `freebox-full`: all traffic through the Freebox (e.g. Netflix), Freebox DNS, IPv6 blocked

Generate the files, import them in the WireGuard app, then delete them:

```bash
src=~/.config/sops-nix/secrets/wireguard_windows; out=/mnt/c/Users/$WINUSER/Downloads/wireguard-import; mkdir -p "$out"
mk() { awk -v allowed="$2" -v dns="$3" '/^\[Interface\]/{print; print "MTU = 1200"; if(dns!="")print "DNS = " dns; next}
  /^\[Peer\]/{print; print "AllowedIPs = " allowed; next} /^(DNS|AllowedIPs|MTU)[[:space:]]*=/{next} {print}' "$src" \
  | sed 's/$/\r/' > "$out/$1.conf"; }
mk freebox-admin "212.27.38.253/32, 192.168.0.254/32" ""
mk freebox-full  "0.0.0.0/0, ::/0" "212.27.38.253"
```

Freebox HTTPS certificates: the box uses Free's private CA. Install `Freebox Root CA` and
`Freebox ECC Root CA` in **Local Machine → Trusted Root** (admin; a policy on this PC ignores
per-user roots), and the two intermediates in Intermediate CAs. Firefox:
`security.enterprise_roots.enabled = true`.
