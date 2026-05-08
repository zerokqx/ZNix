{ ... }:
{
  plugins.mini-pairs = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings.event = "InsertEnter";
    };
  };
}
