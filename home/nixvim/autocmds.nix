{
  autoGroups = {
    restore_cursor = { };
    alpha_on_empty = { };
    alacritty_padding = { }; # Новая группа
  };

  autoCmd = [
    {
      group = "restore_cursor";
      event = [ "BufReadPost" ];
      pattern = "*";
      callback = {
        __raw = ''
          function()
            if
              vim.fn.line "'\"" > 1
              and vim.fn.line "'\"" <= vim.fn.line "$"
              and vim.bo.filetype ~= "commit"
              and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
            then
              vim.cmd "normal! g`\""
            end
          end
        '';
      };
    }
    {
      group = "alacritty_padding";
      event = [ "VimEnter" ];
      pattern = "*";
      desc = "Remove Alacritty padding on startup";
      callback = {
        __raw = ''
          function()
            vim.fn.system("alacritty msg config window.padding.x=0 window.padding.y=0")
          end
        '';
      };
    }
  ];
}
