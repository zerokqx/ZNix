{ ... }:
{
  plugins.web-devicons.enable = true;

  plugins.mini = {
    enable = false;
    modules = {
      icons = {
        mockDevIcons = true;
      };

    };
  };

}
