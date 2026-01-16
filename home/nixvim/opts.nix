{ config, ... }:
{
  config = {

    luaLoader.enable = true;
    opts = {
      clipboard = "unnamedplus";
      virtualedit = "block"; # Allow cursor to move where there is no text in visual block mode
      cursorline = true; # Highlight the line where the cursor is located
      cmdheight = 2; # more space in the neovim command line for displaying messages
      showmode = false; # Dont show the editor mode in status line
      number = true;
      relativenumber = true;
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

      timeoutlen = 250;

      scrolloff = 8; # Will never have less than 8 characters as you scroll down
      mouse = "a"; # Mouse

      # Set encoding type
      encoding = "utf-8";
      fileencoding = "utf-8";

      # Maximum number of items to show in the popup menu (0 means "use available screen space")
      pumheight = 0;

    };

  };
}
