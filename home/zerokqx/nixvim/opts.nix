{ lib, ... }:
{
  opts = {
    tabstop = lib.mkForce 2;
    softtabstop = lib.mkForce 2;
    shiftwidth = lib.mkForce 2;
    expandtab = lib.mkForce true;
    cmdheight = lib.mkForce 0;
    cursorline = lib.mkForce true;
    clipboard = lib.mkForce "unnamedplus";
    wrap = lib.mkForce true;
    breakindent = lib.mkForce true;
    undofile = lib.mkForce true;
    scrolloff = lib.mkForce 8;
    timeoutlen = lib.mkForce 250;
    signcolumn = lib.mkForce "yes";
    number = lib.mkForce true;
    relativenumber = lib.mkForce true;

    # 1. ГЛАВНЫЙ ИСТОЧНИК ФРИЗОВ: Отключаем автоматический расчет фолдинга treesitter на каждый символ
    foldmethod = lib.mkForce "manual";
    foldexpr = lib.mkForce "";
    foldenable = lib.mkForce false;

    # 2. Курсор: квадрат (block) в normal/visual, палочка (| ver25) в insert
    guicursor = lib.mkForce [
      "n-v-c-sm:block"
      "i-ci-ve:ver25"
      "r-cr:hor20"
      "o:hor50"
    ];

    # 3. Убираем вертикальную полосу ограничения длины строки
    colorcolumn = lib.mkForce "";

    # 4. Убираем скрытые символы
    list = lib.mkForce false;

    # 5. Убираем символы '~' внизу экрана
    fillchars = lib.mkForce "eob: ";
  };
}
