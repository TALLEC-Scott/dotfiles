# Windows OpenVPN profiles

- `freebox-admin`: only mafreebox.freebox.fr through the VPN (split tunnel)
- `freebox-full`: all traffic through the Freebox (e.g. Netflix); connect only when needed

`*-routes.ovpn` hold only the routing lines. The full profile also
contains the client private key, so it is **not** in git (it is in sops as
`openvpn_nas`).

Create a Windows profile (NAME = freebox-admin or freebox-full):

```bash
mkdir -p "/mnt/c/Users/$WINUSER/OpenVPN/config/$NAME"
{ sops decrypt --extract '["openvpn_nas"]' secrets/secrets.yaml
  echo; cat windows/openvpn/$NAME-routes.ovpn; } | sed 's/$/\r/' \
  > "/mnt/c/Users/$WINUSER/OpenVPN/config/$NAME/$NAME.ovpn"
```

Freebox HTTPS certificates: the box uses Free's private CA. Install
`Freebox Root CA` and `Freebox ECC Root CA` in **Local Machine → Trusted Root**
(admin; a policy on this PC ignores per-user roots), and the two intermediates
in Intermediate CAs. Firefox: `security.enterprise_roots.enabled = true`.
