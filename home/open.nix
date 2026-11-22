{ pkgs, lib, ... }:
let
  # xdg-open: on WSL, open files/URLs with the Windows default app; elsewhere, the normal one.
  xdg-open = pkgs.writeShellScriptBin "xdg-open" ''
    if grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
      [ $# -ge 1 ] || { echo "usage: xdg-open <file|url>" >&2; exit 2; }
      target="$1"
      if [[ "$target" =~ ^[A-Za-z][A-Za-z0-9+.-]*: && ! "$target" =~ ^[^/:]+:[0-9]+(/|$) && ! -e "$target" ]]; then :  # URL (https:, mailto:, ...)
      elif [ -e "$target" ]; then target=$(wslpath -w "$(realpath "$target")")       # file or folder
      elif [[ "$target" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.([A-Za-z]{2,24})(:[0-9]+)?(/.*)?$ ]] \
           && ! [[ "''${BASH_REMATCH[2],,}" =~ ^(md|txt|pdf|py|sh|js|ts|json|ya?ml|toml|nix|c|h|cpp|hpp|rs|go|java|html?|css|csv|log|conf|ini|png|jpe?g|gif|svg|mp[34]|mkv|mov|zip|tar|gz|docx?|xlsx?|pptx?)$ ]]
      then target="https://$target"                                                    # bare domain
      else echo "xdg-open: no such file or URL: $target" >&2; exit 1
      fi
      /mnt/c/Windows/explorer.exe "$target" || true   # explorer.exe always exits 1
    else
      exec ${pkgs.xdg-utils}/bin/xdg-open "$@"
    fi
  '';
in
{
  home.packages = [ (lib.hiPrio xdg-open) pkgs.xdg-utils ];
  home.sessionVariables.BROWSER = "xdg-open";   # gh, python webbrowser, ... open links the same way
}
