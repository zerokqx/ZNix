{ pkgs, ... }:
{

  plugins.treesitter = {
    enable = true;
    nixvimInjections = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      bash
      json
      lua
      markdown
      nix
      regex
      toml
      yaml
      typescript
      javascript
      html
    ];
  };
}
