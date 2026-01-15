{ ... }:
{

  programs.swaylock = {
    enable = true;
    # settings =
    #   let
    #     green = "#00FF00";
    #     bl = "#000000";
    #     red = "#FF0000";
    #   in
    #   {
    #     color = bl; # черный фон, как терминал
    #     indicator = true; # показать кружок
    #     ring-color = green; # ярко-зеленое кольцо
    #     key-hl-color = green; # подсветка клавиш
    #     bs-hl-color = red; # подсветка backspace (красная, как ошибки)
    #     text-color = green; # текст на экране ANSI зеленый
    #     fade-in = 0.1;
    #   };

  };
}
