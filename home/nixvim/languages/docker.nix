{ pkgs, lib, ... }:
{
  plugins = {
    lsp.servers = {
      dockerls = {
        enable = true;
        filetypes = [ "dockerfile" "Dockerfile" ];
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
