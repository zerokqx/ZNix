{ lib, config, ... }:
let
  znix = config.znix.monitors;
  monitors = znix.list;
  noctaliaList = lib.optionals (znix.noctaliaMonitors != null) (
    if lib.isList znix.noctaliaMonitors then
      znix.noctaliaMonitors
    else
      [ znix.noctaliaMonitors ]
  );

  parseNumber = value:
    if builtins.isInt value || builtins.isFloat value then
      value
    else if builtins.isString value then
      builtins.fromJSON value
    else
      throw "Ожидалось число или строка с числом, получено `${builtins.typeOf value}`";

  parsePos = name: pos:
    if lib.isAttrs pos then
      {
        x = parseNumber pos.x;
        y = parseNumber pos.y;
      }
    else
      let
        parts = lib.splitString " " pos;
      in
      if builtins.length parts != 2 then
        throw "znix.monitors.list.${name}.pos должен быть в формате \"X Y\" или { x = X; y = Y; }"
      else
        {
          x = parseNumber (builtins.elemAt parts 0);
          y = parseNumber (builtins.elemAt parts 1);
        };

  parseMode = name: mode:
    if lib.isAttrs mode then
      {
        width = parseNumber mode.width;
        height = parseNumber mode.height;
      }
    else
      let
        m = builtins.match "([0-9]+)x([0-9]+)(@([0-9]+(\\.[0-9]+)?)Hz)?" mode;
      in
      if m == null then
        throw "znix.monitors.list.${name}.mode должен быть в формате \"1920x1080@165Hz\" или \"1920x1080\""
      else
        {
          width = parseNumber (builtins.elemAt m 0);
          height = parseNumber (builtins.elemAt m 1);
        };

  mapMonitor = name: mon:
    lib.filterAttrs (_: value: value != null) {
      mode = if mon ? mode then parseMode name mon.mode else null;
      position = if mon ? pos then parsePos name mon.pos else null;
      scale = if mon ? scale then parseNumber mon.scale else null;
      focus-at-startup = if builtins.elem name noctaliaList then true else null;
    };

in
{
  programs.niri.settings.outputs = lib.mapAttrs mapMonitor monitors;
}
