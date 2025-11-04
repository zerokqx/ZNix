{ key }:
let
  config = {
    git = {
      userEmail = "swiftkey382@gmail.com";
      userName = "zerokqx";

    };
    gemini = {
      api = "AIzaSyDWhZ84N3NwbuFz8JQnYXoSh2uHxsdXWJU";
      model = "";
    };

  };
in if builtins.hasAttr key config then config.${key} else null
