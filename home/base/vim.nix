{ pkgs, ... }:
let
  fromGitHub = { owner, repo, rev, hash }: pkgs.vimUtils.buildVimPlugin {
    pname = repo;
    version = builtins.substring 0 7 rev;
    src = pkgs.fetchFromGitHub { inherit owner repo rev hash; };
  };

  spaceduck = fromGitHub {
    owner = "pineapplegiant";
    repo = "spaceduck";
    rev = "350491f19343b24fa85809242089caa02d4dadce";
    hash = "sha256-lE8y9BA2a4y0B6O3+NyOS7numoltmzhArgwTAner2fE=";
  };

  vim-rainbow = fromGitHub {
    owner = "frazrepo";
    repo = "vim-rainbow";
    rev = "a6c7fd5a2b0193b5dbd03f62ad820b521dea3290";
    hash = "sha256-zha3BNZXJSgEWEyh8fcy1+x3Y+c1DV1eTMa/AQ+sj7M=";
  };
in
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      dracula-vim
      vim-airline
      coc-nvim
      spaceduck
      vim-rainbow
    ];
    extraConfig = builtins.readFile ../../.vimrc;
  };

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
}
