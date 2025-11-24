let
  terminal = bind: class: app: ({ ${bind} = "$TERM --class ${class} -e ${app}"; });
in
{
  _module.args.mkBind = {
    inherit terminal;
  };
}
