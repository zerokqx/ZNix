{ lib, config, ... }:
let
  monitors = config.znix.monitors.list;
  names = builtins.attrNames monitors;
  namesSorted = lib.sort builtins.lessThan names;
  defaultNoctalia =
    if namesSorted == [ ] then null else [
      (builtins.elemAt namesSorted 0)
    ];
in
{
  options.znix.monitors.list = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { ... }:
        {
          options = {
            mode = lib.mkOption {
              type = lib.types.str;
              example = "1920x1080@165Hz";
            };
            pos = lib.mkOption {
              type = lib.types.str;
              example = "0 0";
            };
          };
        }
      )
    );
    default = { };
    description = "Конфигурация мониторов (ключ = имя выхода)";
  };

  options.znix.monitors.noctaliaMonitors = lib.mkOption {
    type =
      lib.types.nullOr (
        lib.types.either lib.types.str (lib.types.listOf lib.types.str)
      );
    default = defaultNoctalia;

    description = "Список мониторов из znix.monitors.list для панели Noctalia (или null). Может быть строкой (один выход) или списком.";
  };

  config = {
    assertions =
      let
        noctaliaMonitors = config.znix.monitors.noctaliaMonitors;
        monitorList =
          if noctaliaMonitors == null then [ ]
          else if lib.isList noctaliaMonitors then noctaliaMonitors else [ noctaliaMonitors ];
      in
      [
        {
          assertion = noctaliaMonitors == null || lib.all (name: builtins.hasAttr name monitors) monitorList;
          message = "znix.monitors.noctaliaMonitors должны ссылаться на ключи znix.monitors.list";
        }
      ];
  };
}
