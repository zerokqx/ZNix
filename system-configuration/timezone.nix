{ ... }: {
  time.timeZone = "Europe/Moscow";

  i18n = let
    ru = "ru_RU.UTF-8";
    en = "en_US.UTF-8";

    makeExtraLocaleSettings = locale: {
      LC_ADDRESS = locale;
      LC_IDENTIFICATION = locale;
      LC_MEASUREMENT = locale;
      LC_MONETARY = locale;
      LC_NAME = locale;
      LC_NUMERIC = locale;
      LC_PAPER = locale;
      LC_TELEPHONE = locale;
      LC_TIME = locale;
    };
  in {
    defaultLocale = en;
    extraLocaleSettings = makeExtraLocaleSettings ru;
  };
}
