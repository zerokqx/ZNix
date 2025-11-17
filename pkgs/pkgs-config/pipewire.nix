{
  config,
  pkgs,
  lib,
  ...
}:

{
  ####################
  ## PulseAudio     ##
  ####################
  nixpkgs.config.pulseaudio = true;
  # Жёстко включаем сервис PulseAudio
  services.pulseaudio.enable = lib.mkForce true; # важно перебить pipewire.nix[web:56][web:62][web:73]

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
    extraConfig = ''
            .ifexists module-bluetooth-discover.so
              load-module module-bluetooth-discover
            .endif

      load-module module-combine-sink

            .ifexists module-switch-on-connect.so
              load-module module-switch-on-connect
            .endif
    '';
  };

  security.rtkit.enable = true; # для нормальных приоритетов звука[web:52][web:61][web:73]

  ####################
  ## PipeWire OFF   ##
  ####################

  services.pipewire = {
    enable = false; # полностью гасим PipeWire как sound server[web:62][web:73][web:86]
    alsa.enable = false;
    alsa.support32Bit = false;
    pulse.enable = false;
    jack.enable = false;
  };

  ####################
  ## Пакеты         ##
  ####################

  environment.systemPackages = with pkgs; [
    pavucontrol # GUI‑микшер для PulseAudio[web:76][web:92][web:98]
    pamixer # CLI‑микшер
    pulseaudio # утилиты: pactl, pacmd, paplay, parecord[web:92][web:98]
  ];
}
