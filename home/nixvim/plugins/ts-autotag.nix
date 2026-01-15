{
  plugins.ts-autotag = {
    enable = true;
    settings = {
      opts = {
        enable_close = true;
        enable_close_on_slash = false;
        enable_rename = true;
      };
      per_filetype = {
        html = {
          enable_close = false;
        };
      };
    };
  };
}
