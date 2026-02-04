{ lib, ... }:
{

  plugins.mini-animate = {
    enable = true;
    settings = {
      cursor = {
        enable = true;
        timing = lib.nixvim.mkRaw ''
          require("mini.animate").gen_timing.linear({
            unit = "total",
            duration = 120,
          })
        '';
        path = lib.nixvim.mkRaw ''require("mini.animate").gen_path.line()'';
      };
      scroll = {
        enable = false; # smooth scroll handled by Snacks to avoid double animation
        timing = lib.nixvim.mkRaw ''
          require("mini.animate").gen_timing.linear({
            unit = "total",
            duration = 140,
          })
        '';
        subscroll = lib.nixvim.mkRaw ''
          require("mini.animate").gen_subscroll.equal({
            max_output_steps = 30,
          })
        '';
      };
      resize = {
        enable = true;
        timing = lib.nixvim.mkRaw ''
          require("mini.animate").gen_timing.linear({
            unit = "total",
            duration = 120,
          })
        '';
      };
      open = {
        enable = true;
        timing = lib.nixvim.mkRaw ''
          require("mini.animate").gen_timing.linear({
            unit = "total",
            duration = 160,
          })
        '';
        winconfig = {
          border = "rounded";
        };
      };
      close = {
        enable = true;
        timing = lib.nixvim.mkRaw ''
          require("mini.animate").gen_timing.linear({
            unit = "total",
            duration = 120,
          })
        '';
      };
      predicate = lib.nixvim.mkRaw ''
        function(buf_id)
          return not vim.b[buf_id].minianimate_disable
        end
      '';
    };
  };

}
