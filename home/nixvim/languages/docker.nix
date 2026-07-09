{ pkgs, lib, ... }:
{
  plugins = {
    lsp.servers = {
      dockerls = {
        enable = true;
        filetypes = [ "dockerfile" ];
      };
      docker_compose_language_service = {
        enable = true;
        filetypes = [ "yaml.docker-compose" ];
      };
    };

    lint = {
      lintersByFt = {
        docker = [ "hadolint" ];
      };

      linters = {
        hadolint.cmd = lib.getExe pkgs.hadolint;
      };
    };
  };
}
