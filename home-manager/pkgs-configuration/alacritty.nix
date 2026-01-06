{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [ "${pkgs.alacritty-theme}/share/alacritty-theme/terminal_app.toml" ];
      font = {
        normal = {
          family = "Maple Mono NF";
          style = "Regular";
        };
        bold = {
          family = "Maple Mono NF";
          style = "Bold";
        };
        italic = {
          family = "Maple Mono NF";
          style = "Italic";
        };
        bold_italic = {
          family = "Maple Mono NF";
          style = "Bold Italic";
        };

        size = 12.0;

        offset = {
          x = 0;
          y = 0;
        };
      };
    };
  };
}
