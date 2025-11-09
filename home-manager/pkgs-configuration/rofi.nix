{ pkgs, ... }: {
  programs.rofi = {

    enable = true;
    location = "top-left";
    theme = toString ../configs/rofi/theme.rasi;
    plugins = with pkgs; [ rofi-calc ];
  };

}
