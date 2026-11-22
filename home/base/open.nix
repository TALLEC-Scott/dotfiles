{ pkgs, lib, ... }:
let
  # xdg-open: on WSL, open files/URLs with the Windows default app; elsewhere, the normal one.
  xdg-open = pkgs.writeShellScriptBin "xdg-open" ''
    if ! grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
      exec ${pkgs.xdg-utils}/bin/xdg-open "$@"
    fi
    [ $# -ge 1 ] || { echo "usage: xdg-open <file|url>" >&2; exit 2; }

    url_scheme='^[A-Za-z][A-Za-z0-9+.-]*:'                 # https:, mailto:, ...
    host_port='^[^/:]+:[0-9]+(/|$)'                        # localhost.dev:8080 (not a scheme)
    domain='^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.([A-Za-z]{2,24})(:[0-9]+)?(/.*)?$'   # google.com/x
    file_ext='^(md|txt|pdf|py|sh|js|ts|json|ya?ml|toml|nix|c|h|cpp|hpp|rs|go|java|html?|css|csv|log|conf|ini|png|jpe?g|gif|svg|mp[34]|mkv|mov|zip|tar|gz|docx?|xlsx?|pptx?)$'

    target="$1"
    if [ -e "$target" ]; then
      target=$(wslpath -w "$(realpath "$target")")
    elif [[ $target =~ $url_scheme && ! $target =~ $host_port ]]; then
      :
    elif [[ $target =~ $domain ]] && ! [[ ''${BASH_REMATCH[2],,} =~ $file_ext ]]; then
      target="https://$target"                                       # bare domain
    else
      echo "xdg-open: no such file or URL: $target" >&2; exit 1
    fi
    /mnt/c/Windows/explorer.exe "$target" || true   # explorer.exe always exits 1
  '';
in
{
  home.packages = [ (lib.hiPrio xdg-open) pkgs.xdg-utils ];
  home.sessionVariables.BROWSER = "xdg-open";
}
