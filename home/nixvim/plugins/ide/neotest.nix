{ lib, config, ... }:
{
  plugins = {

    neotest = {
      adapters = {
        jest.enable = true;
        jest.settings.jestCommand = "npm test --";
        vitest.enable = true;
      };
      enable = true;
      settings = {
        discovery.enabled = true;
        status.virtual_text = true;
        output = {
          enabled = true;
          open_on_run = true;
        };
        quickfix = {
          enabled = true;
          open = false;
        };
        floating = {
          border = "rounded";
        };
      };
    };

    which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>t";
        mode = [ "n" ];
        group = "Test";
      }
    ];
  };

  keymaps = lib.mkIf config.plugins.neotest.enable [
    {
      mode = [ "n" ];
      key = "<leader>tt";
      action = "<cmd>Neotest run file<cr>";
      options = {
        silent = true;
        desc = "Run file";
      };
    }
    {
      mode = [ "n" ];
      key = "<leader>tn";
      action = "<cmd>Neotest run<cr>";
      options = {
        silent = true;
        desc = "Run nearest";
      };
    }
    {
      mode = [ "n" ];
      key = "<leader>ts";
      action = "<cmd>Neotest summary toggle<cr>";
      options = {
        silent = true;
        desc = "Toggle summary";
      };
    }
    {
      mode = [ "n" ];
      key = "<leader>to";
      action = "<cmd>Neotest output<cr>";
      options = {
        silent = true;
        desc = "Open output";
      };
    }
    {
      mode = [ "n" ];
      key = "<leader>tO";
      action = "<cmd>Neotest output-panel toggle<cr>";
      options = {
        silent = true;
        desc = "Toggle output-panel";
      };
    }
    {
      mode = [ "n" ];
      key = "<leader>ta";
      action = "<cmd>Neotest attach<cr>";
      options = {
        silent = true;
        desc = "Attach";
      };
    }
    {
      mode = [ "n" ];
      key = "<leader>tS";
      action = "<cmd>Neotest stop<cr>";
      options = {
        silent = true;
        desc = "Stop";
      };
    }
  ];
}
