{ ... }:
{
  users.users.zerok = {
    isNormalUser = true;
    description = "zerok";
    isSystemUser = false;
    initialPassword = "1";
    extraGroups = [
      "nixosvmtest"
      "networkmanager"
      "kvm"
      "docker"
      "wheel"
      "video"
      "input"
      "audio"
      "render"
    ];

  };

}
