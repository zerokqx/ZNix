{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      window-padding-x = 12;
      window-padding-y = 10;
      window-decoration = false;
      cursor-style = "bar";
      cursor-style-blink = true;
      mouse-hide-while-typing = true;
      font-feature = [
        "calt"
        "liga"
        "dlig"
      ];
    };
  };
}
