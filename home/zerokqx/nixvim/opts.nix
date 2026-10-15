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
    swapfile = lib.mkForce false;
    backup = lib.mkForce false;
    writebackup = lib.mkForce false;
    scrolloff = lib.mkForce 8;
    timeoutlen = lib.mkForce 250;
    signcolumn = lib.mkForce "yes";
    number = lib.mkForce true;
    relativenumber = lib.mkForce true;
    laststatus = lib.mkForce 3;
    winblend = lib.mkForce 0;
    pumblend = lib.mkForce 0;

    foldmethod = lib.mkForce "expr";
    foldexpr = lib.mkForce "v:lua.vim.treesitter.foldexpr()";
    foldenable = lib.mkForce true;
    foldlevel = lib.mkForce 99;
    foldlevelstart = lib.mkForce 99;
    foldtext = lib.mkForce "";

    guicursor = lib.mkForce [
      "n-v-c-sm:block"
      "i-ci-ve:ver25"
      "r-cr:hor20"
      "o:hor50"
    ];

    colorcolumn = lib.mkForce "";

    list = lib.mkForce false;

    fillchars = lib.mkForce "eob: ,fold: ,foldopen:,foldsep: ,foldclose:";
  };
}
