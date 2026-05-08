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
      signcolumn = "yes";
      numberwidth = 2;
      laststatus = 3;
      showtabline = 2;

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
        eob = " ";
        vert = "│";
        vertleft = "│";
        vertright = "│";
        horiz = "─";
        horizup = "─";
        horizdown = "─";
        verthoriz = "┼";
        fold = " ";
        foldopen = "";
        foldsep = " ";
        foldclose = "";
      };

      # Важно: убираем фон у разделителя
      winhighlight = "WinSeparator:Normal";
      winbar = "";
      timeoutlen = 250;
      scrolloff = 8;
      mouse = "a";
      encoding = "utf-8";
      fileencoding = "utf-8";
      pumheight = 12;
      pumblend = 0;
      winblend = 0;
      ttimeoutlen = 10;
      updatetime = 200;
      redrawtime = 1500;
      synmaxcol = 300;
      lazyredraw = false;
      completeopt = "menu,menuone,noselect";
      shortmess = "filnxtToOFIcC";
      inccommand = "split";

    };

  };
}
