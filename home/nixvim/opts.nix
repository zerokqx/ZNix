{ config, ... }:
{

  config = {

    luaLoader.enable = true;
    opts = {
      clipboard = "unnamedplus";
      virtualedit = "block"; # Allow cursor to move where there is no text in visual block mode
      cursorline = true; # Highlight the line where the cursor is located
      cmdheight = 0; # more space in the neovim command line for displaying messages
      showmode = false; # Dont show the editor mode in status line
      signcolumn = "no";
      numberwidth = 2;

      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;

      smartindent = true;
      wrap = true;
      breakindent = true;
      swapfile = false;
      backup = false;
      undofile = true;
      hlsearch = true;
      incsearch = true;
      splitbelow = true;
      splitright = true;
      ignorecase = true;
      smartcase = true; # Don't ignore case with capitals
      grepprg = "rg --vimgrep";
      grepformat = "%f:%l:%c:%m";
      conceallevel = 2;
      termguicolors = true;
      fillchars = {
        vert = "│";
        vertleft = "│";
        vertright = "│";
        horiz = "─";
        horizup = "─";
        horizdown = "─";
        verthoriz = "┼";
      };

      # Важно: убираем фон у разделителя
      winhighlight = "WinSeparator:Normal";
      timeoutlen = 250;
      scrolloff = 8;
      mouse = "a";
      encoding = "utf-8";
      fileencoding = "utf-8";
      pumheight = 0;

    };

  };
}
