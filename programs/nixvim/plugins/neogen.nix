{
  plugins.neogen = {
    enable = true;
    settings = {
      languages = {
        lua = {
          template = {
            annotation_convention = "emmylua";
          };
        };
        python = {
          template = {
            annotation_convention = "numpydoc";
          };
        };
        typescript = {
          template = {
            annotation_convention = "tsdoc";
          };
        };
        javascript = {
          template = {
            annotation_convention = "jsdoc";
          };
        };
      };
      snippet_engine = "mini";
    };
  };
}
