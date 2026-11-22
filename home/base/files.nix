{ ... }:
{
  # recursive: link each file, so other files in ~/.config/fastfetch are left alone
  xdg.configFile."fastfetch" = {
    source = ../../.config/fastfetch;
    recursive = true;
  };
}
