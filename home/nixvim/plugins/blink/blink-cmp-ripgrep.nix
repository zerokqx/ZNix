{ lib, config, ... }:

lib.mkIf config.plugins.blink-cmp.enable {
  # Включаем ripgrep-провайдер + сразу видно в логе
  plugins.blink-ripgrep.enable = builtins.trace "Ripgrep провайдер включён (blink-cmp активен)" true;

  # Настройки — всё в одном месте, красиво и с правильными типами
  plugins.blink-cmp.settings.sources.providers.ripgrep = {
    async = true;
    module = "blink-ripgrep";
    name = "Ripgrep";
    score_offset = 100;

    opts = {
      prefix_min_len = 3;
      context_size = 5;
      max_filesize = "1M";
      project_root_marker = [
        ".git"
        "Cargo.toml"
        "package.json"
      ]; # можно список!
      project_root_fallback = true;
      search_casing = "--ignore-case";
      additional_rg_options = [
        "--hidden" # искать в скрытых файлах
        "--glob=!.git/*" # но игнорировать .git
      ];
      fallback_to_regex_highlighting = true;
      ignore_paths = [
        "node_modules"
        "target"
        "dist"
        "build"
      ];
      additional_paths = [ ];
      debug = false;
    };
  };
}
