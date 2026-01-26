{
  autoGroups = {
    alacritty_padding = { }; # Новая группа
  };

  autoCmd = [
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
