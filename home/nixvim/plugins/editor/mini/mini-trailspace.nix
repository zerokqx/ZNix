{
  plugins.mini-trailspace = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
    };
    settings = {
      only_in_normal_buffers = true;
    };
  };

}
