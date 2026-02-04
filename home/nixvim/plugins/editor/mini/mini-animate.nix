{ lib, ... }:
{

  plugins.mini-animate = {
    enable = true;
    settings = {
      cursor = {
        enable = true;
        timing = {
          unit = "total";
          total = 120;
        };
      };
      scroll = {
        enable = false; # smooth scroll handled by Snacks to avoid double animation
        timing = {
          unit = "total";
          total = 140;
        };
        subscroll = 15;
      };
      resize = {
        enable = true;
        timing = {
          unit = "total";
          total = 120;
        };
      };
      open = {
        enable = true;
        timing = {
          unit = "total";
          total = 160;
        };
        winconfig = {
          border = "rounded";
        };
      };
      close = {
        enable = true;
        timing = {
          unit = "total";
          total = 120;
        };
      };
      predicate = lib.nixvim.mkRaw ''
        function(buf_id)
          return not vim.b[buf_id].minianimate_disable
        end
      '';
    };
  };

}
