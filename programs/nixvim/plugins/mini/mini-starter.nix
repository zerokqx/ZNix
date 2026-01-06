{ lib, ... }:
{
  plugins.mini-starter = {
    enable = true;
    settings = {
      autoopen = true;
      footer = ""; # Убираем подсказки внизу
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
              { name = 'Find File ',     action = ':Pick files',                  section = "" },
              { name = 'Recent Files ',  action = ':Pick buffers',                section = "" },
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
