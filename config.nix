{ key }:
let
  config = {
    git = {
      userEmail = "swiftkey382@gmail.com";
      userName = "zerokqx";
    };
    gemini = {
      api = "AIzaSyAKnKgk7RLWf2VNzmKTLmXkRSQ_auJsQ1M";
      model = "";
    };

  };

in
if builtins.hasAttr key config then config.${key} else null
