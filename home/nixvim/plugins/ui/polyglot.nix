{ pkgs, ... }:
{

  extraPlugins = with pkgs; [
    vimPlugins.vim-polyglot
  ];
}
