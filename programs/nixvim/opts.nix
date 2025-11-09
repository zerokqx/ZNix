{ ... }:
{
  opts = {
    number = true;
    fillchars = {
      vert = "▌";
      horiz = "━";
      eob = " ";
    };
    termguicolors = true;
    relativenumber = true;
    swapfile = false;
    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    clipboard = "unnamedplus"; # использует системный clipboard
    wrap = true; # Включи перенос длинных строк
    linebreak = true; # Переносы по словам, а не посередине
    breakindent = true; # Сохраняй отступ при переносе
    showmode = false;
    cmdheight = 0;
  };
}
