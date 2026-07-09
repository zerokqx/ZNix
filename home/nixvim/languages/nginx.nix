{ pkgs, ... }:
{
  # home.packages = with pkgs; [
  #   nginx-config-formatter
  # ];
  plugins.lsp.servers.nginx_language_server = {
    enable = true;
    filetypes = [ "nginx" ];
  };
  # plugins.conform-nvim = {
  #   formatters = {
  #     nginxfmt = {
  #       command = "nginxfmt";
  #     };
  #   };
  #   enable = true;
  #
  #   formattersByFt = {
  #     nginx = [ "nginxfmt" ];
  #   };
  # };
}
