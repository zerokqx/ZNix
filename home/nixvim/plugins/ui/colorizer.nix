{ ... }:

{
  plugins.colorizer = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings.ft = [
        "css"
        "scss"
        "sass"
        "less"
        "javascript"
        "javascriptreact"
        "typescript"
        "typescriptreact"
        "html"
      ];
    };
  };
}
