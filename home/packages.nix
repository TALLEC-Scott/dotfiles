{ pkgs, lib, ... }:
let
  # Python CLIs installed with `uv tool install` on switch:
  #  - hf-mem: not in nixpkgs
  uvTools = [ "hf-mem" ];
in
{
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

    # git / dev workflow
    gh
    glab
    lazygit
    lazydocker
    pre-commit
    dive
    osv-scanner

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

    # python tooling
    uv
    python312
    ruff
    ty
    deptry
    python3Packages.huggingface-hub  # `hf` CLI
    llm

    # toolchains (previously apt: build-essential, cmake, golang, nodejs, jdk)
    gcc
    cmake
    ninja
    clang-tools        # clang-format for the `epiclang` alias
    go
    nodejs             # also needed by coc.nvim
    jdk

    # AI
    ollama

    # fonts
    nerd-fonts.jetbrains-mono
  ];

  home.activation.uvTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.uv}/bin:$PATH"
    installed=$(uv tool list 2>/dev/null | cut -d' ' -f1)
    for t in ${lib.escapeShellArgs uvTools}; do
      if ! grep -qx "$t" <<<"$installed"; then
        echo "uv tool install $t (first time: can take minutes)"
        run uv tool install "$t" || echo "warning: uv tool install $t failed" >&2
      fi
    done
  '';
}
