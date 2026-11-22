// Firefox proxy auto-config: these sites go out through home (vpn-nas SOCKS5 proxy in WSL):
// Netflix (so it sees the home IP) and the Freebox admin page. Everything else is direct.
// No DIRECT fallback on purpose: if the VPN is down, they fail instead of leaking/timing out.
function FindProxyForURL(url, host) {
  var home = ["netflix.com", "netflix.net", "nflxvideo.net", "nflximg.net",
              "nflximg.com", "nflxext.com", "nflxso.net", "fast.com",
              "mafreebox.freebox.fr"];
  for (var i = 0; i < home.length; i++)
    if (host === home[i] || dnsDomainIs(host, "." + home[i]))
      return "SOCKS5 127.0.0.1:41080";
  return "DIRECT";
}
