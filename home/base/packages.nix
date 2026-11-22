{ pkgs, ... }:
{
  # Everyday tools, on every profile
  home.packages = with pkgs; [
    # system / monitoring
    fastfetch
    htop
    btop               # use btop-cuda instead on a machine with an NVIDIA GPU
    bottom             # btm
    glances
    nvitop
    python3Packages.gpustat  # `gpustat` top-level is a different project
    util-linux         # lscpu
    dust
    ncdu

    # git
    gh
    glab
    lazygit

    # shell niceties
    bat
    eza
    ripgrep
    jq
    fzf
    tmux
    lolcat
    cowsay
    speedtest-cli
    wpm
    asciinema
    spotify-player
    yt-dlp
    visidata

    uv
    nodejs             # needed by coc.nvim (vim)
    nerd-fonts.jetbrains-mono
  ];
}
