{ lib, ... }:
{
  plugins.mini-starter = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings.event = "VimEnter";
    };
    settings = {
      autoopen = false;
      footer = ""; 
      content_hooks = [
        (lib.nixvim.mkRaw "require(\"mini.starter\").gen_hook.adding_bullet('')")
        (lib.nixvim.mkRaw "require(\"mini.starter\").gen_hook.aligning('center', 'center')")
      ];
      evaluate_single = true;
      header = '''';
      items = [
        (lib.nixvim.mkRaw ''
          (function()
            return {
              { name = 'New File ',      action = 'enew',                         section = "" },
              { name = 'Find File ',     action = 'lua Snacks.picker.files()',   section = "" },
              { name = 'Recent Files ',  action = 'lua Snacks.picker.buffers()', section = "" },
              { name = 'Projects ',      action = 'lua Snacks.picker.projects()', section = "" },
              { name = 'Quit Neovim 󰈆',   action = 'qa',                           section = "" },
            }
          end)()
        '')
      ];
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>ua";
      action = ":lua require('mini.starter').open()<CR>";
      options = {
        silent = true;
        desc = "Открыть Mini Starter";
      };
    }
  ];
}
