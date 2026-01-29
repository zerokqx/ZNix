{

  programs.opencode = {
    enable = false;
    settings = {
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options = {
            num_ctx = 36000;
            baseURL = "http://localhost:11434/v1";
          };
          models = {
            "granite4:3b" = {
              name = "Granite 4 3B";
            };
            "deepseek-coder:6.7b" = {
              tool_call = false;
              name = "Deepseek Coder 6.7B";
            };
            "qwen2.5-coder:3b" = {
              name = "Qwen 2.5 Coder 3B";
            };
          };
        };
      };
    };
  };
}
