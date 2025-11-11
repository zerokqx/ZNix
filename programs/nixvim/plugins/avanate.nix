{
  plugins.avante = {
    enable = true;
    settings = {

  diff = {
    autojump = true;
    debug = false;
    list_opener = "copen";
  };
  highlights = {
    diff = {
      current = "DiffText";
      incoming = "DiffAdd";
    };
  };
  hints = {
    enabled = true;
  };
  provider = "gemini";
  providers = {
    gemini = {
      extra_request_body = {
        max_tokens = 4096;
        temperature = 0;
      };
      model = "gemini-2.5-flash";
    };
  };
  windows = {
    sidebar_header = {
      align = "center";
      rounded = true;
    };
    width = 30;
    wrap = true;
  };
    };
  };
}
# {
#   plugins.codecompanion = {
#     enable = true;
#   #   settings = {
#   #     adapters = {
#   #       http = {
#   #         gemini = {
#   #           __raw = ''
#   #             function()
#   #               return require("codecompanion.adapters").extend("gemini", {
#   #                 env = {
#   #                   url = "https://generativelanguage.googleapis.com/v1beta",
#   #                   api_key = os.getenv("GEMINI_API_KEY"),
#   #                 },
#   #                 schema = {
#   #                   model = {
#   #                     default = "gemini-2.5-flash",
#   #                   },
#   #                   temperature = {
#   #                     default = 0.7,
#   #                   },
#   #                   max_tokens = {
#   #                     default = 4096,
#   #                   },
#   #                 },
#   #               })
#   #             end
#   #           '';
#   #         };
#   #       };
#   #     };
#   #
#   #     opts = {
#   #       log_level = "INFO";
#   #       send_code = true;
#   #       use_default_actions = true;
#   #       use_default_prompts = true;
#   #     };
#   #
#     settings = {
#
#       strategies = {
#         agent = { adapter = "gemini"; };
#         chat  = { adapter = "gemini"; };
#         inline = { adapter = "gemini"; };
#       };
#     };
#   #
#   #     display = {
#   #       chat = {
#   #         window = {
#   #           layout = "vertical";
#   #           opts = {
#   #             breakindent = true;
#   #           };
#   #         };
#   #       };
#   #       action_palette = {
#   #         provider = "default";
#   #         opts = {
#   #           show_default_prompt_library = true;
#   #         };
#   #       };
#   #     };
#   #   };
#   # };
#
# };
#   keymaps = [
#    {
#       mode = "n";
#       key = "<leader>ac";
#       action = ":CodeCompanionChat<CR>";
#       options = {
#         desc = "CodeCompanion: Открыть чат";
#         silent = true;
#       };
#     }
#   ];
# }
