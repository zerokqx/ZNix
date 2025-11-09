{ lib, ... }:
{
  # Ваш код для включения плагина
  plugins.emmet = {
    enable = true;
    settings = {

      leader = "<C-Z>";
      mode = "inv";
      settings = {
        html = {
          default_attributes = {
            option = {
              value = lib.nixvim.mkRaw "nil";
            };
            textarea = {
              cols = 10;
              id = lib.nixvim.mkRaw "nil";
              name = lib.nixvim.mkRaw "nil";
              rows = 10;
            };
          };
          snippets = {
            "html:5" = ''
              <!DOCTYPE html>
              <html lang=\"$\{lang}\">
              <head>
              \t<meta charset=\"$\{charset}\">
              \t<title></title>
              \t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
              </head>
              <body>\n\t$\{child}|\n</body>
              </html>
            '';
          };
        };
        variables = {
          lang = "ja";
        };
      };
    };
  };

  # Добавляем настройку для tsx файлов
}
