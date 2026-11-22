# Windows OpenVPN: Freebox admin only (split tunnel)

`freebox-admin-routes.ovpn` holds only the routing lines. The full profile also
contains the client private key, so it is **not** in git (it is in sops as
`openvpn_nas`).

Create the Windows profile:

```bash
mkdir -p "/mnt/c/Users/$WINUSER/OpenVPN/config/freebox-admin"
{ sops decrypt --extract '["openvpn_nas"]' secrets/secrets.yaml
  echo; cat windows/openvpn/freebox-admin-routes.ovpn; } | sed 's/$/\r/' \
  > "/mnt/c/Users/$WINUSER/OpenVPN/config/freebox-admin/freebox-admin.ovpn"
```

Freebox HTTPS certificates: the box uses Free's private CA. Install
`Freebox Root CA` and `Freebox ECC Root CA` in **Local Machine → Trusted Root**
(admin; a policy on this PC ignores per-user roots), and the two intermediates
in Intermediate CAs. Firefox: `security.enterprise_roots.enabled = true`.
