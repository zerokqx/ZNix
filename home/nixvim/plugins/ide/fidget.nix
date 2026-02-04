{
  plugins.fidget = {
    enable = false;
    settings = {
      logger = {
        level = "warn";
        float_precision = 0.01;
      };
      progress = {
        poll_rate = 0;
        suppress_on_insert = true;
        ignore_done_already = false;
        ignore_empty_message = false;
        clear_on_detach = ''
          function(client_id)
            local client = vim.lsp.get_client_by_id(client_id)
            return client and client.name or nil
          end
        '';
        notification_group = ''
          function(msg) return msg.lsp_client.name end
        '';
        ignore = [ ];
        lsp = {
          progress_ringbuf_size = 0; # ← исправлено
        };
        display = {
          render_limit = 16; # ← исправлено
          done_ttl = 3;
          done_icon = "✔";
          done_style = "Constant";
          progress_icon = {
            pattern = "dots";
            period = 1;
          };
          progress_style = "WarningMsg";
          group_style = "Title";
          icon_style = "Question";
          priority = 30;
          skip_history = true;
          format_message = ''
            require("fidget.progress.display").default_format_message
          '';
          format_annote = ''
            function(msg) return msg.title end
          '';
          format_group_name = ''
            function(group) return tostring(group) end
          '';
          overrides = {
            rust_analyzer = {
              name = "rust-analyzer";
            };
          };
        };
      };
      notification = {
        poll_rate = 10; # ← исправлено
        filter = "info";
        history_size = 128; # ← исправлено
        override_vim_notify = false; # ← исправлено
        window = {
          normal_hl = "Comment"; # ← исправлено
          winblend = 1;
          border = "rounded";
          zindex = 45;
          max_width = 0; # ← исправлено
          max_height = 0; # ← исправлено
          x_padding = 1; # ← исправлено
          y_padding = 0; # ← исправлено
          align = "bottom";
          relative = "editor";
        };
        view = {
          # ← добавлена секция view
          group_separator = "──";
          group_separator_hl = "Comment";
          icon_separator = " ";
          stack_upwards = true;
        };
      };
    };
  };
}
