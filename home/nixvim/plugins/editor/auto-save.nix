{ ... }:
{
  plugins.auto-save = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings.event = "InsertEnter";
    };
  };
}
