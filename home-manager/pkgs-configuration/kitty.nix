{ ... }:
{

  programs.kitty = {
    enable = false;
    enableGitIntegration = true;
    settings = {
      font_family = "MapleMono NF";
      confirm_os_window_close = 0;
    };
  };
}
