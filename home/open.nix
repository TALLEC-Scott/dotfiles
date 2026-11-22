{ pkgs, lib, ... }:
let
  # xdg-open: on WSL, open files/URLs with the Windows default app; elsewhere, the normal one.
  xdg-open = pkgs.writeShellScriptBin "xdg-open" ''
    if grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
      [ $# -ge 1 ] || { echo "usage: xdg-open <file|url>" >&2; exit 2; }
      target="$1"
      [ -e "$target" ] && target=$(wslpath -w "$(realpath "$target")")
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
