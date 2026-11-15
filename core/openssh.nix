{
  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = false;
      PubkeyAuthentication = true;
      MaxAuthTries = 3;
      LoginGraceTime = "20s";
      LogLevel = "VERBOSE";
    };

  };
}
