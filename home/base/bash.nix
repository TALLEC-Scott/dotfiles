{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [ "ignoreboth" ];
    historySize = 100000;
    historyFileSize = 200000;
    shellOptions = [ "histappend" "checkwinsize" ];

    sessionVariables = {
      PIP_REQUIRE_VIRTUALENV = "false";
      UV_MANAGED_PYTHON = "1";
    };

    initExtra = ''
      # WSL: expose the Windows NVIDIA driver libs to Nix-built GPU tools (nvitop, gpustat, btop)
      if [ -d /usr/lib/wsl/lib ]; then
        export LD_LIBRARY_PATH="/usr/lib/wsl/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      fi

      DOTFILES="''${DOTFILES:-$HOME/home/dotfiles}"
      ${builtins.readFile ../../.bash_aliases}
      ${builtins.readFile ../../.bashrc}
    '';
  };

  programs.oh-my-posh = {
    enable = true;
    enableBashIntegration = true;
    useTheme = "atomic";
  };
}
