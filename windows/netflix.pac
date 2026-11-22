// Firefox proxy auto-config: only Netflix goes out through home (vpn-nas SOCKS5 proxy
// in WSL), so Netflix sees the home IP. Everything else is direct.
// No DIRECT fallback on purpose: if the VPN is down, Netflix fails instead of leaking.
function FindProxyForURL(url, host) {
  var home = ["netflix.com", "netflix.net", "nflxvideo.net", "nflximg.net",
              "nflximg.com", "nflxext.com", "nflxso.net", "fast.com"];
  for (var i = 0; i < home.length; i++)
    if (host === home[i] || dnsDomainIs(host, "." + home[i]))
      return "SOCKS5 127.0.0.1:41080";
  return "DIRECT";
}
