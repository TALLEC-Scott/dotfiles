{ pkgs, lib, ... }:
let
  # Python CLIs installed with `uv tool install` on switch (not in nixpkgs)
  uvTools = [ "hf-mem" ];
in
{
  # Development toolchains and tools
  home.packages = with pkgs; [
    # workflow
    lazydocker
    pre-commit
    dive
    osv-scanner

    # python
    python312
    ruff
    ty
    deptry
    python3Packages.huggingface-hub  # `hf` CLI
    llm

    # toolchains
    gcc
    cmake
    ninja
    go
    jdk

    # AI
    ollama
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
