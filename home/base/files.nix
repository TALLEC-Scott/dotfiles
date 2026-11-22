{ ... }:
{
  # fastfetch config + helper scripts. recursive: link each file, so other files
  # already in ~/.config/fastfetch are left alone.
  xdg.configFile."fastfetch" = {
    source = ../../.config/fastfetch;
    recursive = true;
  };
}
