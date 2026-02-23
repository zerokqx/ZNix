{ ... }:

{
  plugins = {
    treesitter = {
      enable = true;

      settings = {
        highlight.enable = false;
        indent.enable = false;
        incremental_selection.enable = false;
        autotag.enable = false;

        highlight.additional_vim_regex_highlighting = false;
      };

      nixvimInjections = false;
    };

    treesitter-context.enable = false;
    treesitter-refactor.enable = false;
  };
}
